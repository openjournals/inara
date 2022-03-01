local List = require 'pandoc.List'
local stringify = pandoc.utils.stringify
local type = pandoc.utils.type

--- Split a string on the given separator char.
local function split_string (str, sep)
  local acc = List()
  for substr in str:gmatch('([^' .. sep .. ']*)') do
    acc:insert(tostring(substr:gsub('^%s*', ''):gsub('%s*$', ''))) -- trim
  end
  return acc
end

local function extract_note(metainlines)
  local note = List()
  return metainlines:walk {
      Note = function (x)
        note = pandoc.utils.blocks_to_inlines(x.content)
        return {}
      end
  }, note
end

local function is_corresponding_author_note (note)
  local str = stringify(note)
  return str:match '[Cc]orrespond'
end

local corresponding_authors = List()
local function add_corresponding_author (author)
  author.email = author.email and FORMAT:match 'jats'
    and stringify(author.email)
    or author.email
  corresponding_authors:insert(author)
  return tostring(#corresponding_authors)
end

local function is_equal_contributor_note (note)
  local str = stringify(note)
  return str:match '[Ee]qual' and str:match 'contrib'
end

return function (meta)
  local authors = meta.authors
  local affiliations = meta.affiliations
  for _, author in ipairs(authors) do
    if author.name and
       pandoc.List{'string', 'Inlines'}:includes(type(author.name))
    then
      local name, note = extract_note(author.name)
      author.name = name
      if is_equal_contributor_note(note) then
        author['equal-contrib'] = true
      elseif is_corresponding_author_note(note) or
        author['corresponding'] then
        author['cor-id'] = add_corresponding_author(author)
      else
        author['note'] = note
      end
    end
    author.affiliation = author.affiliation
      and split_string(stringify(author.affiliation), ',')
      or nil
  end
  for i, aff in ipairs(affiliations or {}) do
    aff.id = aff.index or tostring(i)
    -- ensure name is not a block
    aff.name = aff.name.t ~= 'MetaBlocks'
      and aff.name
      or pandoc.utils.blocks_to_inlines(aff.name)
  end

  -- if there is only a single equal-contributor note, then it usually means
  -- that the first two authors contributed equally; set a second mark in that
  -- case.
  local equal_contribs =
    meta.authors:filter(function (auth) return auth['equal-contrib'] end)
  if #equal_contribs == 1 and meta.authors[2] then
    meta.authors[2]['equal-contrib'] = true
  end

  meta.article = meta.article or {}
  meta.article['author-notes'] = meta.article['author-notes'] or {}
  meta.article['author-notes'].corresp = meta.article['author-notes'].corresp
    or (#corresponding_authors > 0 and
        corresponding_authors:map(function (auth, i)
          local corresp = {id = tostring(i)}
          if auth.email then
            corresp.email = auth.email
          else
            corresp.note = "Corresponding author"
          end
          return corresp
        end))
    or nil
  meta.article['has-equal-contributors'] =
    #equal_contribs > 0 or nil

  return meta
end
