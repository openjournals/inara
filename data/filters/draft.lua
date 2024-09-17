--- Removes and alters metadata for draft output

--- If you change this, please keep it in sync with
--- resources/default-article-info.yaml
function Meta (meta)
  if meta.draft and meta.draft ~= '' then
    local epoch = os.getenv 'SOURCE_DATE_EPOCH'
      and os.time { year = 1970, month = 1, day = 1, hour = 0, min = 0,
                  sec = tonumber(os.getenv 'SOURCE_DATE_EPOCH') }
      or os.time()
    meta.article.doi = '10.xxxxxx/draft'
    meta.article.issue = '¿ISSUE?'
    meta.article.volume = '¿VOL?'
    meta.published = 'unpublished'
    meta.published_parts = os.date('*t', epoch)
    return meta
  end
end
