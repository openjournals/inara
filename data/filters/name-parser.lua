local utils = require 'pandoc.utils'
local text = require 'text'
local List = require 'pandoc.List'

local particles = {
  da = true,
  de = true,
  del = true,
  della = true,
  di = true,
  du = true,
  la = true,
  mc = true,
  pietro = true,
  st = true,
  ten = true,
  ter = true,
  van = true,
  vanden = true,
  vere = true,
  von = true,
}

local function is_surname_particle (inln)
  return particles[text.lower(utils.stringify(inln))]
end

local function is_suffix (inln)
  return utils.stringify(inln):match '^%(?[IVX%.]+%)?$'
end

--- Checks whether an inline element is whitespace.
local function is_whitespace (inln)
  return inln.t == 'Space'
    or inln.t == 'SoftBreak'
    or inln.t == 'Linebreak'
    or (inln.t == 'Str' and inln.text:match '%s')
end
--- Trim whitespace from a list of inlines.
pandoc.List.trim = function (list)
  while list[1] and is_whitespace(list[1]) do
    list:remove(1)
  end
  local i = #list
  while list[i] and is_whitespace(list[i]) do
    list:remove()
    i = i - 1
  end
  return list
end

function parse_name (name)
  if type(name) ~= 'table' or name.t ~= 'MetaInlines' then
    return nil
  end
  local suffix
  local name_parts = pandoc.List(name):clone():trim()
  local last = name_parts[#name_parts]

  local suffix = is_suffix(last)
    and {name_parts:remove()}
    or nil

  -- find all surname parts
  local surname = List{name_parts:trim():remove()}
  for i = #name_parts, 2, -1 do
    local part = name_parts[i]
    if part and (is_whitespace(part) or is_surname_particle(part)) then
      surname:insert(1, name_parts:remove())
    else
      break
    end
  end

  local given_names = name_parts
  return {
    ['surname']     = surname:trim(),
    ['given-names'] = given_names:trim(),
    ['suffix']      = suffix,
  }
end


function Meta (meta)
  for i, author in ipairs(meta.authors or {}) do
    local parsed_name = parse_name(author.name)
    if type(parsed_name) == 'table' then
      for k, v in pairs(parsed_name) do
        meta.authors[i][k] = meta.authors[i][k] or v
      end
    end
  end
  return meta
end
