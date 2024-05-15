local mediabag = require 'pandoc.mediabag'
local path = require 'pandoc.path'
local sha1 = (require 'pandoc.utils').sha1

--- Map from old image filepaths to new names.
local updated_filepath = {}

local function unnest (filepath, contents)
  if updated_filepath[filepath] then
    return updated_filepath
  end

  local newpath = path.filename(filepath)
  if updated_filepath[newpath] then
    -- the filename is already in use. Prefix with sha1 hash.
    newpath = sha1(contents) .. '-' .. filepath
  end
  updated_filepath[filepath] = newpath
  return newpath
end

function Writer (doc, opts)
  -- Ensure that all images have been fetched.
  doc = mediabag.fill(doc)
  local newpath
  for fp, mt, contents in mediabag.items() do
    -- Delete all mediabag items and re-insert them under their fixed
    -- name.
    newpath = unnest(fp, contents)
    mediabag.delete(fp)
    mediabag.insert(newpath, mt, contents)
  end
  doc = doc:walk {
    Image = function (img)
      img.src = updated_filepath[img.src] or img.src
      return img
    end
  }
  pandoc.mediabag.write('jats')
  return pandoc.write(doc, 'jats_publishing+element_citations', opts)
end

Template = pandoc.template.default 'jats_publishing'
