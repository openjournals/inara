function Meta (meta)
  local curtime = os.date('*t')
  meta.timestamp = meta.timestamp or os.date('%Y%m%d%H%M%S')
  meta.day = meta.day or tostring(curtime.day)
  meta.month = meta.month or tostring(curtime.month)
  meta.year = meta.year or tostring(curtime.year)

  local date_format = '%d %B %Y'
  meta.submitted = os.date(date_format, os.time(meta.submitted))
  meta.published = os.date(date_format, os.time(meta.published))
  return meta
end
