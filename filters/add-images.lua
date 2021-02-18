local mediabag = require 'pandoc.mediabag'

local function insert (filepath)
  local mt, contents = mediabag.fetch(filepath)
  mediabag.insert(filepath, mt, contents)
end

function Meta (meta)
  insert(meta.aas_logo_path)
  insert(meta.logo_path)
end
