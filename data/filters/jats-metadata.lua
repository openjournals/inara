local List = require 'pandoc.List'
local stringify = pandoc.utils.stringify

--- Split a string on the given separator char.
local function split_string (str, sep)
  local acc = List()
  for substr in str:gmatch('([^' .. sep .. ']*)') do
    acc:insert(tostring(substr:gsub('^%s*', ''):gsub('%s*$', ''))) -- trim
  end
  return acc
end

local function extract_notes(metainlines)
  local notes = List()
  local span = pandoc.Span(setmetatable(metainlines, {}))
  local new_span = pandoc.walk_inline(
    span, {
      Note = function (x)
        notes:insert(pandoc.Div(x.content))
        return {}
      end
  })
  return new_span.content, notes
end

local function is_corresponding_author_note (note)
  local str = stringify(note)
  return str:match '[Cc]orrespond'
end

local corresponding_authors = List()
local function add_corresponding_author (author)
  corresponding_authors:insert(author)
  return tostring(#corresponding_authors)
end

local function is_equal_contributor_note (note)
  local str = stringify(note)
  return str:match '[Ee]qual' and str:match 'contrib'
end

function Meta (meta)
  local authors = meta.authors
  local affiliations = meta.affiliations
  for _, author in ipairs(authors) do
    local name, notes = extract_notes(author.name)
    author.name = name
    author.affiliation = author.affiliation
      and split_string(stringify(author.affiliation), ',')
      or nil
    if notes:find_if(is_equal_contributor_note) then
      author['equal-contrib'] = true
    end
    if notes:find_if(is_corresponding_author_note) then
      author['cor-id'] = add_corresponding_author(author)
    end
  end
  for i, aff in ipairs(affiliations) do
    aff.id = tostring(i)
  end

  -- if there is only a single equal-contributor note, then it usually means
  -- that the first two authors contributed equally; set a second mark in that
  -- case.
  local equal_contribs =
    meta.authors:filter(function (auth) return auth['equal-contrib'] end)
  if #equal_contribs == 1 and meta.authors[2] then
    meta.authors[2]['equal-contrib'] = true
  end

  meta.article = {}
  meta.article['author-notes'] = {}
  meta.article['author-notes'].corresp = #corresponding_authors > 0 and
    corresponding_authors:map(function (auth, i)
        local corresp = {id = tostring(i)}
        if auth.email then
          corresp.email = auth.email
        else
          corresp.note = "Corresponding author"
        end
        return corresp
    end) or nil
  meta.article['author-notes']['equal-contributors'] =
    #equal_contribs > 0 or nil
  -- unset author notes unless it contains values
  if not next(meta.article['author-notes']) then
    meta.article['author-notes'] = nil
  end


  meta.author = authors
  meta.affiliation = affiliations
  return meta
end
