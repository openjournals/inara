-- This filter rewrites the affiliation list inside the
-- author dictionary to contain all the information, not
-- just the index in the global affiliation list

function Meta (meta)
  -- note that there's a difference between meta.authors (the original)
  -- and meta.author (the processed one)
  for _, author in ipairs(meta.authors or {}) do
    local xml = "<affiliations>"
    for i, affiliation_list in ipairs(author.affiliation) do
        local index = tonumber(affiliation_list[1].text)
        local affiliation = meta.affiliations[index]
        xml = xml.. "\n  <institution><institution_name>"
        for _, v in ipairs(affiliation.name) do
          if v.text then
            xml = xml .. v.text
          else
            xml = xml .. " "
          end
        end
        xml = xml .. "</institution_name>"
        if affiliation.ror then
          xml = xml .. "<institution_id type=\"ror\">https://ror.org/" .. affiliation.ror[1].text .. "</institution_id>"
        end
        xml = xml.. "</institution>"
    end
    xml = xml .. "\n</affiliations>"
    -- afxml - (af)filiation xml
    author.afxml = pandoc.RawInline('html', xml)
  end
  return meta
end
