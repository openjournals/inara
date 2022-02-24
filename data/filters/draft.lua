--- Removes and alters metadata for draft output
function Meta (meta)
  if meta.draft and meta.draft ~= '' then
    meta.article.doi = '10.xxxxxx/draft'
    meta.article.issue = '0'
    meta.article.volume = '0'
    meta.published = 'unpublished'
    meta.published_parts = os.date('*t')
    return meta
  end
end
