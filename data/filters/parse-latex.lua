function Pandoc (doc)
  local allow_raw_latex =
    doc.meta['raw-latex'] == true or
    doc.meta['raw-latex'] == nil

  if FORMAT:match 'latex' and allow_raw_latex then
    return nil  -- do nothing
  end

  return doc:walk {
    RawBlock = function (raw)
      if raw.format:match 'tex' then
        return pandoc.read(
          -- special case: pandoc does not know how to parse a resizebox command
          raw.text:gsub('\\resizebox%{.-%}%{%!%}(%b{})', '%1'),
          'latex'
        ).blocks
      end
      if raw.format == 'tex' then
        return {}
      end
    end,

    RawInline = function (raw)
      if raw.format:match 'tex' then
        return pandoc.utils.blocks_to_inlines(
          pandoc.read(raw.text, 'latex').blocks
        )
      end
    end
  }
end
