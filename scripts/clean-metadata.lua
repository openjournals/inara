local function to_date_table (date)
  if type(date) == 'table' then
    return date.day and date or to_date_table(pandoc.utils.stringify(date))
  elseif type(date) == 'string' then
    local year, month, day = date:match '^(%d%d%d%d)[-/](%d%d)[-/](%d%d)'
    if year and month and day then
      return {
        year = year,
        month = month,
        day = day
      }
    end
    return nil
  elseif not date then
    return nil
  else
    error("Don't know how to handle the given date: " .. tostring(date))
  end
end

local omit = {authors = true, title = true, citation_string = true}
local date_field = {submitted_at = 'submitted', published_at = 'published'}
function Meta (m)
  local result = {metadata = {}}
  for k, v in pairs(m) do
    if date_field[k] then
      result.metadata[date_field[k]] = to_date_table(v)
    elseif not omit[k] then
      result.metadata[k] = v
    end
  end
  return result
end
