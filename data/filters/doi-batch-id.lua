function Meta (meta)
  local timestamp = meta.timestamp or os.date('%Y%m%dT%H%M%S')
  meta.doi_batch_id = timestamp .. '-' ..
    pandoc.utils.sha1(pandoc.utils.stringify(meta.title))
  return meta
end
