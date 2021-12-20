function Pandoc (doc)
  doc.meta.references = pandoc.utils.references(doc)
  doc.meta.bibliography = nil  -- prevent bibliography from being parsed twice
  return doc
end
