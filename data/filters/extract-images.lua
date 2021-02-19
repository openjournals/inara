local List = require 'pandoc.List'
local mediabag = require 'pandoc.mediabag'

local outdir = os.getenv 'INARA_ARTIFACTS_PATH'

local function write(filename, mimetype, contents)
  -- it would be nice if we could just use mediabag functions instead.
  local fh = io.open(filename, 'w')
  fh:write(contents)
  fh:close()
end

function Image (img)
  local mimetype, contents = mediabag.fetch(img.src)
  img.src = outdir .. img.src
  write(img.src, mimetype, contents)
  return img
end
