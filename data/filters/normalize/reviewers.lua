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
    return {name = stringify(unparsed_name)}
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
  table = function (t)
    name = t.name or t.literal
    t.literal = nil
    t.name = name and stringify(name) or nil
    return t
  end
}

--- Normalize the name(s) of a reviewer. The return value is a table
--- object with the following fields:
--
-- `name`: full name / display name (string)
-- `given-names`: given names
-- `surname`: family name or last name
--
-- All fields but `name` are optional.
local function normalize_name (name)
  -- ensure basic table structure
  local namify = to_name_table[type(name)] or
    error('Cannot normalize reviewer name of type ' .. type(name))
  name = namify(name)

  -- normalize given name field
  local given = 'given-names'
  name[given] = name[given] and stringify(name[given]) or nil
  local given_names_aliases = {'given', 'given_name', 'first', 'firstname'}
  for _, alias in ipairs(given_names_aliases) do
    name[given] = name[given] or
      (name[alias] and stringify(name[alias]))
    name[alias] = nil
  end

  -- normalize surname name field
  name.surname = name.surname and stringify(name.surname) or nil
  local surname_aliases = {'family_name', 'family', 'last', 'lastname'}
  for _, alias in ipairs(surname_aliases) do
    name.surname = name.surname or
      (name[alias] and stringify(name[alias]))
    name[alias] = nil
  end

  -- ensure full name (a.k.a, display name) is set and of type 'string'.
  name.name = name.name and stringify(name.name) or nil
  if not name.name then
    local literal = pandoc.List{}
    for _, name_part in ipairs{'given-names', 'dropping-particle',
                               'non-dropping-particle', 'surname',
                               'suffix'} do
      literal:extend(name[name_part] and {stringify(name[name_part])} or {})
    end
    name.name = table.concat(literal, ' ')
  end

  return name
end

-- ORCID validation (same as authors)
local orcid_pattern =
  '^(%d%d%d%d)%-?(%d%d%d%d)%-?(%d%d%d%d)%-?(%d%d%d)([%dXx])$'
local function normalize_orcid (orcid)
  if not orcid then
    return nil
  end
  orcid_str = stringify(orcid)

  -- Strictly speaking, an ORCID is an URL, but we allow users to
  -- omit schema and host. Keep the digits.
  orcid_str = orcid_str:gsub('^https://orcid%.org/', '')
  local b1, b2, b3, b4, check = orcid_str:match(orcid_pattern)
  if not (b1 and b2 and b3 and b4 and check) then
    return nil
  end

  local digits = b1 .. b2 .. b3 .. b4

  local total = 0;
  for digit in digits:gmatch '.' do
    total = (total + tonumber(digit)) * 2
  end

  local remainder = total % 11
  local result = (12 - remainder) % 11

  local is_valid = result == 10
    and check:upper() == "X"
    or tonumber(check) == result

  return is_valid
    and string.format('%s-%s-%s-%s%s', b1, b2, b3, b4, check)
    or nil
end

return function (meta)
  local reviewers = meta.reviewers or List()
  local normalized_reviewers = List()

  for i, reviewer in ipairs(reviewers) do
    local reviewer_obj

    -- Handle old format: simple string (GitHub handle)
    if type(reviewer) == 'string' or type(reviewer) == 'Inlines' then
      local handle = stringify(reviewer):gsub('^@', '')
      reviewer_obj = {
        name = '@' .. handle,
        url = 'https://github.com/' .. handle,
        github = handle
      }
    -- Handle new format: table with name and optional orcid
    elseif type(reviewer) == 'table' then
      reviewer_obj = reviewer

      -- Normalize name if present
      if reviewer_obj.name or reviewer_obj['given-names'] or reviewer_obj.surname or
         reviewer_obj.given or reviewer_obj.first or reviewer_obj.firstname or
         reviewer_obj.last or reviewer_obj.lastname or reviewer_obj.family then
        local name_data = normalize_name(reviewer_obj)
        for k, v in pairs(name_data) do
          reviewer_obj[k] = v
        end
      end

      -- Validate and normalize ORCID
      if reviewer_obj.orcid then
        reviewer_obj.orcid = normalize_orcid(reviewer_obj.orcid)
      end
    end

    normalized_reviewers:insert(reviewer_obj)
  end

  meta.reviewers = normalized_reviewers

  return meta
end
