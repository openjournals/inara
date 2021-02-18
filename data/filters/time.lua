function Meta (meta)
  local curtime = os.date('*t')
  meta.timestamp = meta.timestamp or os.date('%Y%m%d%H%M%S')
  meta.day = meta.day or tostring(curtime.day)
  meta.month = meta.month or tostring(curtime.month)
  meta.year = meta.year or tostring(curtime.year)
  return meta
end
