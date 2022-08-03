local mediabag = require 'pandoc.mediabag'

local function insert (filepath)
  local mt, contents = mediabag.fetch(filepath)
  mediabag.insert(filepath, mt, contents)
end

function Meta (meta)
  if meta.aas_logo_path then insert(meta.aas_logo_path) end
  if meta.europar_logo_path then insert(meta.europar_logo_path) end
  if meta.logo_path     then insert(meta.logo_path)     end
end
