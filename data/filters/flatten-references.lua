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
  local resource_path = table.concat(
    PANDOC_STATE.resource_path,
    pandoc.path.search_path_separator
  )
  local tmpdoc = pandoc.utils.run_json_filter(
    make_placeholder_doc(meta, reference),
    'pandoc',
    {'--from=json', '--citeproc', '--to=json',
     '--resource-path=' .. resource_path}
  )
  return pandoc.utils.stringify(tmpdoc.blocks)
end

function Meta (meta)
  for i, ref in ipairs(meta.references) do
    ref.unstructured_citation = make_unstructured_citation(meta, ref)
    for k, v in pairs(ref) do
      if pandoc.utils.type(v) == 'Inlines' then
        ref[k] = pandoc.utils.stringify(v)
      end
    end
    if ref.type == 'book' then
      ref.isbook = true
    end
  end
  return meta
end
