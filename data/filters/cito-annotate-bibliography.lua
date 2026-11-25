-- Copyright © 2017–2021 Albert Krewinkel, Robert Winkler
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.
--
-- Appends CiTO annotations, such as **[cito:usesMethodIn]**, to the
-- bibliography entries rendered by citeproc. The CiTO properties are
-- taken from the `citation_properties` metadata field, which is filled
-- by `extract-cito.lua`.
local stringify = pandoc.utils.stringify

local function annotation (props)
  local inlines = pandoc.List()
  for _, prop in ipairs(props) do
    inlines:insert(pandoc.Space())
    inlines:insert(pandoc.Strong{pandoc.Str('[cito:' .. stringify(prop) .. ']')})
  end
  return inlines
end

local function annotate_entry (entry, props)
  local last = entry.content[#entry.content]
  if last and (last.t == 'Para' or last.t == 'Plain') then
    last.content:extend(annotation(props))
  else
    entry.content:insert(pandoc.Plain(annotation(props)))
  end
  return entry
end

function Pandoc (doc)
  local properties = doc.meta.citation_properties
  if not properties then
    return nil
  end
  return doc:walk {
    Div = function (div)
      if div.identifier ~= 'refs' then
        return nil
      end
      div.content = div.content:map(function (entry)
        local key = entry.t == 'Div' and entry.identifier:match '^ref%-(.*)$'
        local props = key and properties[key]
        return props and annotate_entry(entry, props) or entry
      end)
      return div
    end
  }
end
