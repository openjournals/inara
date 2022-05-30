local function trim(s)
  return s:gsub('^%s*', ''):gsub('%s*$', '')
end

function Pandoc (doc)
  doc.meta.references = pandoc.utils.references(doc)
  for i, ref in ipairs(doc.meta.references) do
    if ref.doi then
      ref.doi = trim(pandoc.utils.stringify(ref.doi))
    end
    -- the "ISSN" field sometimes contains two ISSNs, one for print and another
    -- for the online version. Adding both leads to bad results (and invalid
    -- JATS), so we keep only the first and discard the second.
    if ref.issn then
      ref.issn = ref.issn:match '(%d%d%d%d%-%d%d%d[%dxX])'
    end
    -- Same for ISBN
    if ref.isbn then
      ref.isbn = ref.isbn:match '([%d%-]+[%dxX])%s*$'
    end

    -- The literal name `other` as the last author is treated as `et
    -- al.`. However, APA style does not work well when this is used, as
    -- it always includes the last author (preceded by an ellipses) in
    -- the bibliography entry. We work around this by setting `others`
    -- as the family name, but it's a hack.
    local author = ref.author
    if author and #author > 0 and author[#author].literal == 'others' then
      author[#author].family = 'others'
      author[#author].literal = nil
    end
  end
  doc.meta.bibliography = nil  -- prevent bibliography from being parsed twice
  return doc
end
