local utils = require 'pandoc.utils'
local system = require 'pandoc.system'
local stringify = utils.stringify
local run_json_filter = utils.run_json_filter
local blocks_to_inlines = utils.blocks_to_inlines

local function authors_to_csl_json (authors)
  local result = pandoc.List()
  for _, author in ipairs(authors) do
    result:insert {
      family = author.surname,
      given = author['given-names'],
      suffix = author.suffix,
    }
  end
  return result
end

function Meta (meta)
  local tmpmeta = {
    ['references'] = {
      {
        ['type'] = 'article-journal',
        ['id'] = 'self',
        ['author'] = authors_to_csl_json(meta.authors),
        ['title'] = meta.title,
        ['issued'] = {
          ['date-parts'] = {{meta.year}} -- FIXME
        },
        ['publisher'] = meta.publisher,
        ['container-title'] = meta.journal_name,
        ['container-title-short'] = meta.journal_abbrev_title,
        ['ISSN'] = meta.journal_issn,
        ['issue'] = meta.issue,
        ['page'] = meta.page,
        ['volume'] = meta.volume,
        ['submitted'] = meta.submitted,
        ['editor'] = meta.editor_name,
        ['url'] = meta.paper_url,
        ['doi'] = meta.doi or meta.archive_doi
      }
    },
    ['nocite'] = {pandoc.Cite({}, {pandoc.Citation('*', "NormalCitation")})},
    ['csl'] = meta['footer-csl'],
    ['link-citations'] = meta['link-citations'],
    ['citation-abbreviations'] = meta['citation-abbreviations'],
    ['lang'] = meta['lang'],
    ['notes-after-punctuation'] = meta['notes-after-punctuation'],
  }
  local tmpdoc = run_json_filter(
    pandoc.Pandoc({}, tmpmeta),
    'pandoc',
    {'--from=json', '--citeproc', '--to=json',
     -- FIXME: use pandoc.path when available
     '--resource-path=' .. table.concat(PANDOC_STATE.resource_path, ':')
    }
  )
  meta['self-citation'] = blocks_to_inlines(tmpdoc.blocks)
  return meta
end
