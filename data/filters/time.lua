local sample_date = {
  year = 1970,
  month = 1,
  day = 1,
}
local function format_date (date_table)
  local date_format = '%d %B %Y'
  return os.date(date_format, os.time(date_table))
end

local function copy_string_values (tbl)
  local result = {}
  for k, v in pairs(tbl or {}) do
    result[k] = pandoc.utils.stringify(v)
  end
  return result
end

function Meta (meta)
  local curtime = os.date('*t')
  meta.timestamp = meta.timestamp or os.date('%Y%m%d%H%M%S')
  meta.submitted_parts = copy_string_values(meta.submitted or sample_date)
  meta.published_parts = copy_string_values(meta.published or sample_date)

  meta.day = meta.published_parts.day or meta.day or tostring(curtime.day)
  meta.month = meta.published_parts.month or meta.month or tostring(curtime.month)
  meta.year = meta.published_parts.year or meta.year or tostring(curtime.year)

  meta.submitted = format_date(meta.submitted)
  meta.published = format_date(meta.published)
  return meta
end
