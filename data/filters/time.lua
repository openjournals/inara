local sample_date = '1970-01-01'

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

local function date_array(date_metavalue)
  local date_string = pandoc.utils.stringify(date_metavalue)
  local year, month, day, hour, min, sec =
    date_string:match '^(%d%d%d%d)-(%d%d)-(%d%d)'
  return {
    year = year,
    month = month,
    day = day,
  }
end

function Meta (meta)
  local curtime = os.date('*t')
  meta.timestamp = meta.timestamp or os.date('%Y%m%d%H%M%S')

  meta.submitted_parts = date_array(meta.submitted_at or sample_date)
  meta.published_parts = date_array(meta.published_at or sample_date)

  meta.day = meta.published_parts.day or tostring(curtime.day)
  meta.month = meta.published_parts.month or tostring(curtime.month)
  meta.year = meta.published_parts.year or tostring(curtime.year)

  meta.submitted = format_date(meta.submitted_parts)
  meta.published = format_date(meta.published_parts)
  return meta
end
