if not FORMAT:match 'context' then
  return {}
end

local numbered_formula = [=[
\placeformula
\startformula
%s
\stopformula
]=]

function Span (span)
  local eq = span.content[1]
  if #span.content == 1 and eq.t == 'Math' and span.attributes.label then
    return pandoc.RawInline('context', numbered_formula:format(eq.text))
  end
end
