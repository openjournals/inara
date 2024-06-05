local pandoc = require 'pandoc'
local utils = require 'pandoc.utils'
local citeproc, stringify = utils.citeproc, utils.stringify
function make_placeholder_doc(meta, reference)
  local tmpmeta = {
    ['references'] = {reference},
    ['nocite'] = {pandoc.Cite({}, {pandoc.Citation('*', "NormalCitation")})},
    ['csl'] = meta.csl,
    ['citation-abbreviations'] = meta['citation-abbreviations'],
    ['lang'] = meta['lang'],
    ['notes-after-punctuation'] = meta['notes-after-punctuation'],
  }
  return pandoc.Pandoc({}, tmpmeta)
end

local function make_unstructured_citation(meta, reference)
  local tmpdoc = citeproc(make_placeholder_doc(meta, reference))
  return stringify(tmpdoc.blocks)
end

function Meta (meta)
  for _, ref in ipairs(meta.references) do
    ref.unstructured_citation = make_unstructured_citation(meta, ref)
    for k, v in pairs(ref) do
      if utils.type(v) == 'Inlines' then
        ref[k] = stringify(v)
      end
    end
    if ref.type == 'book' then
      ref.isbook = true
    end
  end
  return meta
end
