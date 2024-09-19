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

local function prepare_credit (meta)
  meta.hasRoles = false
  for _, author in ipairs(meta.authors or {}) do
    if author.roles then
      roleList = {}
      for _, roleDict in ipairs(author.roles) do
        roleDict = clean_role_dict(roleDict)
        role = pandoc.utils.stringify(roleDict.type)
        if invalidRole(role) then
          print("invalid role for author " .. author.name .. ": " .. role)
        elseif roleDict.degree then
          degree = capitalize_first_letter(pandoc.utils.stringify(roleDict.degree))
          if invalidDegree(degree) then
            print("invalid degree for author " .. author.name .. ": " .. degree)
            -- even though the degree is invalid, add the role anyway
            table.insert(roleList, role)
          else
            table.insert(roleList, role .. " (" .. degree .. ")")
          end
        else
          table.insert(roleList, role)
        end
      end
      if #roleList > 0 then
        meta.hasRoles = true
        author.rolesString = join_with_commas_and(roleList)
      end
    end
  end
  return meta
end

function Meta (meta)
  local ok, result = pcall(prepare_credit, meta)
  if ok then
    return result
  end
end
