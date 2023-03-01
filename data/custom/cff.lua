Template = [[
cff-version: 1.2.0
$titleblock$
]]

local function filter_authors (authors)
  local filter_author = function (author)
    return {
      ['name'] = not author['surname'] and author.name or nil,
      ['orcid'] = author.orcid,
      ['family-names'] = author['surname'],
      ['given-names'] = author['given-names'],
    }
  end
  return authors:map(filter_author)
end

local function is_contact (author)
  return author['cor-id']
end
local function tocontact (author)
  return {
    ['email'] = author.email,
    ['family-names'] = author.surname,
    ['given-names'] = author['given-names'],
    ['name'] = not author.surname and author.name or nil,
  }
end
local function contact (authors)
  local contact = authors:filter(is_contact):map(tocontact)
  return #contact >= 1 and contact or nil
end

local function preferred_citation(meta)
  local journal = meta.journal or {}
  return {
    ['authors'] = filter_authors(meta.author),
    ['date-published'] = meta.published_at,
    ['doi'] = meta.doi,
    ['isbn'] = journal.isbn,
    ['issn'] = journal.eissn or journal.issn,
    ['issue'] = meta.issue,
    ['journal'] = journal.title,
    ['keywords'] = meta.tag,
    ['publisher'] = {name = journal['publisher-name']},
    ['title'] = meta.title,
    ['type'] = 'article',
    ['url'] = meta.paper_url,
    ['volume'] = meta.volume,
  }
end

local function citation_from_meta (meta)
  return {
    ['authors'] = filter_authors(meta.author),
    ['contact'] = contact(meta.author),
    ['doi'] = meta.doi,
    ['message'] = meta.message or
      ("If you use this software, please cite our " ..
       "article in the Journal of Open Source Software."),
    ['preferred-citation'] = preferred_citation(meta),
    ['title'] = meta.title,
  }
end

function Writer (doc, opts)
  opts.template = Template
  local newdoc = pandoc.Pandoc({}, citation_from_meta(doc.meta))
  return pandoc.write(newdoc, 'markdown', opts):gsub('\n%-%-%-\n', '\n')
end
