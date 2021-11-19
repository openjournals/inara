--- substitute-in-format -- load contents from file for some formats
local path = require 'pandoc.path'

function Div (div)
  local exclude_from = div.attributes['exclude-from']
    or div.attributes['exclude-in']
  if exclude_from and FORMAT:match(exclude_from) then
    return {}
  end
  local include_in = div.attributes['include-in']
  if include_in and FORMAT:match(include_in) then
    local file = path.join {
      path.directory(PANDOC_STATE.input_files[1]),
      div.attributes.file
    }
    local fh = io.open(file)
    return fh and pandoc.RawBlock(include_in, fh:read('*a'))
      or error('file not found: ' .. file)
  end
  return nil
end
