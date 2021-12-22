function Pandoc (doc)
  doc.meta.references = pandoc.utils.references(doc)
  for i, ref in ipairs(doc.meta.references) do
    for k, v in pairs(ref) do
      if pandoc.utils.type(v) == 'Inlines' then
        ref[k] = pandoc.utils.stringify(v)
      end
    end
  end
  doc.meta.bibliography = nil  -- prevent bibliography from being parsed twice
  return doc
end
