if FORMAT:match 'latex' then
  return {}
end

function RawBlock (raw)
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
end

function RawInline(raw)
  if raw.format:match 'tex' then
    return pandoc.utils.blocks_to_inlines(
      pandoc.read(raw.text, 'latex').blocks
    )
  end
end
