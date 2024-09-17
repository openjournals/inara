--- Removes and alters metadata for draft output

--- If you change this, please keep it in sync with
--- resources/default-article-info.yaml
function Meta (meta)
  if meta.draft and meta.draft ~= '' then
    meta.cthdraft = true
    meta.article.doi = '10.xxxxxx/draft'
    meta.article.issue = '¿ISSUE?'
    meta.article.volume = '¿VOL?'
    meta.published = 'unpublished'
    meta.published_parts = os.date('*t')
    return meta
  else
    meta.cthdraft = false
  end
end
