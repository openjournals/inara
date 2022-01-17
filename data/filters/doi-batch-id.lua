function Meta (meta)
  local curtime = os.time()
  meta.doi_batch_id = os.date('%Y%m%dT%H%M%S') .. '-' ..
    pandoc.utils.sha1(pandoc.utils.stringify(meta.title))
  return meta
end
