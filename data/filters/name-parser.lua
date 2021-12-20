local read, stringify = pandoc.read, pandoc.utils.stringify

local bibtex_template = [[
@misc{x,
  author = {%s}
}
]]

--- BibTeX knows how to parse names, so we leverage that.
local function parse_name (name)
  local bibtex = bibtex_template:format(stringify(name))
  return read(bibtex, 'bibtex').meta.references[1].author[1]
end

return {
  {
    Meta = function (meta)
      for i, author in ipairs(meta.authors or {}) do
        local author = author.name and author or {name = author}
        local parsed_name = parse_name(author.name)
        if type(parsed_name) == 'table' then
          for k, v in pairs(parsed_name) do
            author[k] = author[k] or v
          end
        end
        meta.authors[i] = author
      end
      return meta
    end
  }
}
