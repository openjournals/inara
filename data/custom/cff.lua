Template = [[
cff-version: "1.2.0"
$titleblock$
]]

local stringify = pandoc.utils.stringify

local toauthor = function (author)
  return {
    ['email'] = author.email,
    ['family-names'] = author['surname'],
    ['given-names'] = author['given-names'],
    ['name'] = not author['surname'] and author.name or nil,
    ['name-particle'] = author['dropping-particle'] or
      author['non-dropping-particle'],
    ['name-suffix'] = author.suffix,
    ['orcid'] = author.orcid,
  }
end
local function filter_authors (authors)
  return authors:map(toauthor)
end

local function is_contact (author)
  return author['cor-id']
end
local function contact (authors)
  local contact = authors:filter(is_contact):map(toauthor)
  return #contact >= 1 and contact or nil
end

local function preferred_citation(meta)
  local article = meta.article or {}
  local journal = meta.journal or {}
  return {
    ['authors'] = filter_authors(meta.author),
    ['date-published'] = os.date('%Y-%m-%d', os.time(meta.published_parts)),
    ['doi'] = article.doi,
    ['isbn'] = journal.isbn,
    ['issn'] = journal.eissn or journal.issn,
    ['issue'] = article.issue,
    ['journal'] = journal.title,
    ['keywords'] = meta.tag,
    ['publisher'] = {name = journal['publisher-name']},
    ['start'] = article.fpage,
    ['title'] = stringify(meta.title),
    ['type'] = 'article',
    ['url'] = ('%s%/papers/%s'):format(journal.url, stringify(article.doi)),
    ['volume'] = article.volume,
  }
end

local function citation_from_meta (meta)
  return {
    ['authors'] = filter_authors(meta.author),
    ['contact'] = contact(meta.author),
    ['doi'] = meta.archive_doi,
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
