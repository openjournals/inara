-- Creates the ORCID numbers into a URI.
function Meta (meta)
  for _, author in ipairs(meta.author or {}) do
    if type(author.orcid) == 'string' then
      author.orcid = 'https://orcid.org/' .. author.orcid
    end
  end
  return meta
end
