-- This filter rewrites the affiliation list inside the
-- author dictionary to contain all the information, not
-- just the index in the global affiliation list

local function prepare_affiliations (meta)
  -- note that there's a difference between meta.authors (the original)
  -- and meta.author (the processed one)
  for _, author in ipairs(meta.authors or {}) do
    local xml = "<affiliations>"
    for i, affiliation_index in ipairs(author.affiliation) do
        affiliation_index = tonumber(pandoc.utils.stringify(affiliation_index))
        local affiliation = meta.affiliations[affiliation_index]
        local function html_escape(str)
          local doc = pandoc.Pandoc{pandoc.Str(str)}
          return pandoc.write(doc, 'html')
        end
        xml = xml.. "\n  <institution><institution_name>"
        for _, v in ipairs(affiliation.name) do
          if v.text then
            xml = xml .. html_escape(v.text)
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

function Meta (meta)
  local ok, result = pcall(prepare_affiliations, meta)
  if ok then
    return result
  end
end
