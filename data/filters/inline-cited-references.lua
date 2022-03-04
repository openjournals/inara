local function trim(s)
  return s:gsub('^%s*', ''):gsub('%s*$', '')
end

function Pandoc (doc)
  doc.meta.references = pandoc.utils.references(doc)
  for i, ref in ipairs(doc.meta.references) do
    if ref.doi then
      ref.doi = trim(pandoc.utils.stringify(ref.doi))
    end
  end
  doc.meta.bibliography = nil  -- prevent bibliography from being parsed twice
  return doc
end
