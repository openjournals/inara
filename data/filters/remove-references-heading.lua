-- Remove heading of references section (to be used with JATS output)
function Header (h)
  return h.identifier == 'references' and {} or nil
end
