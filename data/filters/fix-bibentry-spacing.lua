function Div (div)
  if div.t == 'Div' and div.identifier == 'refs' then
    div.attributes['entry-spacing'] = '0.5'
    return div
  end
end
