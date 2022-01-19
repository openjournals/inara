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

--- Normalize the name(s) of an author. The return value is a table
--- object with the following fields:
--
-- `name`: full name / display name (string)
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

function Meta (meta)
  for i, author in ipairs(meta.authors) do
    local name = normalize_name(author.name or author)
    for k, v in pairs(name) do
      meta.authors[i][k] = v
    end
  end

  meta.author = meta.authors

  -- set "author-meta" field using display names
  meta['author-meta'] = table.concat(
    meta.authors:map(function (auth) return auth.name end),
    ', '
  )

  return meta
end
