local List = require 'pandoc.List'
local stringify = pandoc.utils.stringify
local type = pandoc.utils.type

local bibtex_template = [[
@misc{x,
  author = {%s}
}
]]

--- Returns a CSLJSON-like name table. BibTeX knows how to parse names,
--- so we leverage that.
local function parse_name (unparsed_name)
  local bibtex = bibtex_template:format(stringify(unparsed_name))
  local name = pandoc.read(bibtex, 'bibtex').meta.references[1].author[1]
  if type(name) ~= 'table' then
    return {name = pandoc.Inlines(unparsed_name)}
  else
    -- most dropping particles are really non-dropping
    if name['dropping-particle'] and not name['non-dropping-particle'] then
      name['non-dropping-particle'] = name['dropping-particle']
      name['dropping-particle'] = nil
    end
    return name
  end
end

--- Table mapping from the type of a name to a function that converts
--- the type object into a name table.
local to_name_table = {
  Inlines = parse_name,
  Blocks = parse_name,
  string = parse_name,
  table = function (t) return t end
}

--- Normalize the name(s) of an author. The return value is a table
--- object with the following fields:
--
-- `name`: full name / display name (Inlines)
-- `given`: given names
-- `surname`: family name or last name
-- `prefix`:
--
-- All fields but `name` are optional.
local function normalize_name (name)

  -- ensure basic table structure
  local namify = to_name_table[type(name)] or
    error('Cannot normalize author of type ' .. type(name))
  name = namify(name)

  -- normalize given name field
  name.given = name.given and pandoc.Inlines(name.given) or nil
  local given_names_aliases = {'given-names', 'given_name', 'first', 'firstname'}
  for _, alias in ipairs(given_names_aliases) do
    name.given = name.given or
      (name[alias] and pandoc.Inlines(name[alias]))
    name[alias] = nil
  end

  -- normalize surname name field
  name.surname = name.surname and pandoc.Inlines(name.surname) or nil
  local surname_aliases = {'family_name', 'family', 'lastname'}
  for _, alias in ipairs(surname_aliases) do
    name.surname = name.surname or
      (name[alias] and pandoc.Inlines(name[alias]))
    name[alias] = nil
  end

  -- ensure full name (a.k.a, display name) is set and of type Inlines.
  name.name = name.name and pandoc.Inlines(name.name) or nil
  if not name.name then
    name.name = pandoc.Inlines{}
    for _, name_part in ipairs{'given', 'dropping-particle',
                               'non-dropping-particle', 'surname'} do
      name.name:extend(
        name[name_part] and
        (pandoc.Inlines(name[name_part]) .. {pandoc.Space()}) or {}
      )
    end
    -- pop trailing space
    name.name[#name.name] = nil

    name.name:extend(
      name.suffix and ({pandoc.Str',', pandoc.Space()} .. name.suffix) or {}
    )
  end

  return name
end

function Meta (meta)
  for i, author in ipairs(meta.authors) do
    local name = normalize_name(author.name or author)
    for k, v in pairs(name) do
      print(k, stringify(v))
      meta.authors[i][k] = v
    end
  end

  return meta
end
