local utils = require 'pandoc.utils'
local system = require 'pandoc.system'
local stringify = utils.stringify
local run_json_filter = utils.run_json_filter
local blocks_to_inlines = utils.blocks_to_inlines

local function authors_to_csl_json (authors)
  local result = pandoc.List()
  for _, author in ipairs(authors) do
    result:insert {
      ['family'] = author.surname,
      -- we don't want given names in the self citation
      -- FIXME: this should be handled by the CSL for self citations.
      -- ['given'] = author['given-names'],
      ['suffix'] = author.suffix,
      ['dropping-particle'] = author['dropping-particle'],
      ['non-dropping-particle'] = author['non-dropping-particle'],
    }
  end
  return result
end

function Meta (meta)
  meta.article = meta.article or {}
  local tmpmeta = {
    ['references'] = {
      {
        ['type'] = 'article-journal',
        ['id'] = 'self',
        ['author'] = authors_to_csl_json(meta.authors),
        ['title'] = meta.title,
        ['issued'] = {
          ['date-parts'] = {{meta.published_parts.year}}
        },
        ['publisher'] = meta.publisher,
        ['container-title'] = meta.journal.title,
        ['container-title-short'] = meta.journal['abbrev-title'],
        ['ISSN'] = meta.journal.issn,
        ['issue'] = stringify(meta.article.issue),
        ['page'] = stringify(meta.article.fpage),
        ['volume'] = stringify(meta.article.volume),
        ['submitted'] = meta.submitted,
        ['published'] = meta.published,
        ['editor'] = meta.editor.name,
        ['url'] = 'https://doi.org/' .. stringify(meta.article.doi),
        ['doi'] = meta.doi or meta.article.doi
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
