-- Checks if any contributor information is available

roles = pandoc.List {
    "conceptualization",
    "data-curation",
    "formal-analysis",
    "funding-acquisition",
    "investigation",
    "methodology",
    "project-administration",
    "resources",
    "software",
    "supervision",
    "validation",
    "visualization",
    "writing-original-draft",
    "writing-review-editing"
}

degrees = pandoc.List {
    "Lead",
    "Supporting",
    "Equal"
}

function invalidRole(str)
    return not roles:includes(str)
end

function invalidDegree(str)
    return not degrees:includes(str)
end

function join_with_commas_and(list)
    local len = #list
    if len == 0 then
        return ""
    elseif len == 1 then
        return list[1]
    elseif len == 2 then
        return list[1] .. " and " .. list[2]
    else
        local result = table.concat(list, ", ", 1, len - 1)
        return result .. ", and " .. list[len]
    end
end

function capitalize_first_letter(str)
    return str:sub(1, 1):upper() .. str:sub(2)
end

function clean_role_dict(d)
  if d.type then
    return d
  else
    return {["type"] = pandoc.utils.stringify(d)}
  end
end

function Meta (meta)
  meta.hasRoles = false
  for _, author in ipairs(meta.authors or {}) do
    if author.roles then
      meta.hasRoles = true
      roleList = {}
      for _, roleDict in ipairs(author.roles) do
        roleDict = clean_role_dict(roleDict)
        role = pandoc.utils.stringify(roleDict.type)
        if invalidRole(role) then
          error("invalid role for author " .. author.name .. ": " .. role)
        end
        if roleDict.degree then
          degree = capitalize_first_letter(pandoc.utils.stringify(roleDict.degree))
          if invalidDegree(degree) then
            error("invalid degree for author " .. author.name .. ": " .. degree)
          end
          table.insert(roleList, role .. " (" .. degree .. ")")
        else
          table.insert(roleList, role)
        end
      end
      author.rolesString = join_with_commas_and(roleList)
    end
  end
  return meta
end
