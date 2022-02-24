local function trim(s)
  return s:gsub('^%s*', ''):gsub('%s*$', '')
end

function Pandoc (doc)
  doc.meta.references = pandoc.utils.references(doc)
  for i, ref in ipairs(doc.meta.references) do
    for k, v in pairs(ref) do
      if pandoc.utils.type(v) == 'Inlines' then
        ref[k] = pandoc.utils.stringify(v)
      end
    end
    if ref.type == 'book' then
      ref.isbook = true
    end
    if ref.doi then
      ref.doi = trim(pandoc.utils.stringify(ref.doi))
    end
  end
  doc.meta.bibliography = nil  -- prevent bibliography from being parsed twice
  return doc
end
