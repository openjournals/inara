-- Checks if any contributor information is available

local roles = {
    ["conceptualization"] = {
        name = "Conceptualization",
        id = "8b73531f-db56-4914-9502-4cc4d4d8ed73",
        uri = "https://credit.niso.org/contributor-roles/conceptualization/"
    },
    ["data-curation"] = {
        name = "Data curation",
        id = "f93e0f44-f2a4-4ea1-824a-4e0853b05c9d",
        uri = "https://credit.niso.org/contributor-roles/data-curation/"
    },
    ["formal-analysis"] = {
        name = "Formal analysis",
        id = "95394cbd-4dc8-4735-b589-7e5f9e622b3f",
        uri = "https://credit.niso.org/contributor-roles/formal-analysis/"
    },
    ["funding-acquisition"] = {
        name = "Funding acquisition",
        id = "34ff6d68-132f-4438-a1f4-fba61ccf364a",
        uri = "https://credit.niso.org/contributor-roles/funding-acquisition/"
    },
    ["investigation"] = {
        name = "Investigation",
        id = "2451924d-425e-4778-9f4c-36c848ca70c2",
        uri = "https://credit.niso.org/contributor-roles/investigation/"
    },
    ["methodology"] = {
        name = "Methodology",
        id = "f21e2be9-4e38-4ab7-8691-d6f72d5d5843",
        uri = "https://credit.niso.org/contributor-roles/methodology/"
    },
    ["project-administration"] = {
        name = "Project administration",
        id = "a693fe76-ea33-49ad-9dcc-5e4f3ac5f938",
        uri = "https://credit.niso.org/contributor-roles/project-administration/"
    },
    ["resources"] = {
        name = "Resources",
        id = "ebd781f0-bf79-492c-ac21-b31b9c3c990c",
        uri = "https://credit.niso.org/contributor-roles/resources/"
    },
    ["software"] = {
        name = "Software",
        id = "f89c5233-01b0-4778-93e9-cc7d107aa2c8",
        uri = "https://credit.niso.org/contributor-roles/software/"
    },
    ["supervision"] = {
        name = "Supervision",
        id = "0c8ca7d4-06ad-4527-9cea-a8801fcb8746",
        uri = "https://credit.niso.org/contributor-roles/supervision/"
    },
    ["validation"] = {
        name = "Validation",
        id = "4b1bf348-faf2-4fc4-bd66-4cd3a84b9d44",
        uri = "https://credit.niso.org/contributor-roles/validation/"
    },
    ["visualization"] = {
        name = "Visualization",
        id = "76b9d56a-e430-4e0a-84c9-59c11be343ae",
        uri = "https://credit.niso.org/contributor-roles/visualization/"
    },
    ["writing-original-draft"] = {
        name = "Writing – original draft",
        id = "43ebbd94-98b4-42f1-866b-c930cef228ca",
        uri = "https://credit.niso.org/contributor-roles/writing-original-draft/"
    },
    ["writing-review-editing"] = {
        name = "Writing – review & editing",
        id = "d3aead86-f2a2-47f7-bb99-79de6421164d",
        uri = "https://credit.niso.org/contributor-roles/writing-review-editing/"
    }
}

-- An enumeration of the JATS-recommended degrees of contribution
degrees = pandoc.List {
    "Lead",
    "Supporting",
    "Equal"
}

-- Check if the given string is one of the 14 valid
-- CRediT identifiers by looking at the `roles` dict
-- defined above
function invalidCreditID(str)
    return roles[str] == nil
end

-- Check if the degree contribution is valid based on the JATS recommendation,
-- see https://jats.taylorandfrancis.com/jats-guide/topics/author-contributions-credit/#degree-of-contribution
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
        return list[1] .. " & " .. list[2]
    else
        local result = table.concat(list, ", ", 1, len - 1)
        return result .. ", & " .. list[len]
    end
end

function capitalize_first_letter(str)
    return str:sub(1, 1):upper() .. str:sub(2)
end

-- If the data is just a string corresponding to a
-- CRediT identifier, upgrade it to a dictionary,
-- otherwise return it as is
function clean_role_dict(d)
    if d.credit then
        return d
    else
        return { ["credit"] = pandoc.utils.stringify(d) }
    end
end

local function prepare_credit (meta)
    meta.hasRoles = false
    for _, author in ipairs(meta.authors or {}) do
        if author.roles then
            roleList = {}
            for _, roleDict in ipairs(author.roles) do
                roleDict = clean_role_dict(roleDict)
                credit_id = pandoc.utils.stringify(roleDict.credit)
                if invalidCreditID(credit_id) then
                    print("invalid credit ID for author " .. author.name .. ": " .. credit_id)
                elseif roleDict.degree then
                    degree = capitalize_first_letter(pandoc.utils.stringify(roleDict.degree))
                    if invalidDegree(degree) then
                        print("invalid degree for author " .. author.name .. ": " .. degree)
                        -- even though the degree is invalid, add the role anyway
                        table.insert(roleList, roles[credit_id].name)
                    else
                        table.insert(roleList, roles[credit_id].name .. " (" .. degree .. ")")
                    end
                else
                    table.insert(roleList, roles[credit_id].name)
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

function assertEqual(expected, actual)
    assert(expected == actual, "got \"" .. actual .. "\", expected \"" .. expected .. "\"")
end

function tests()
    assert("" == join_with_commas_and({ }))
    assert("foo" == join_with_commas_and({ "foo" }))
    assert("foo & bar" == join_with_commas_and({ "foo", "bar" }))
    assert("foo, bar, & baz" == join_with_commas_and({ "foo", "bar", "baz" }))

    local m1 = {
        ["authors"] = {
            {
                ["name"] = "Author 1",
                ["roles"] = {
                    "methodology"
                }
            },
            {
                ["name"] = "Author 2",
                ['roles'] = {
                    { ["credit"] = "methodology" }
                }
            },
            {
                ["name"] = "Author 3",
                ['roles'] = {
                    { ["credit"] = "methodology" },
                    { ["credit"] = "data-curation" },
                    { ["credit"] = "conceptualization" },
                }
            },
            {
                ["name"] = "Author 4",
                ['roles'] = {
                    { ["credit"] = "methodology", ["degree"] = "lead" },
                    { ["credit"] = "data-curation", ["degree"] = "supporting" },
                    { ["credit"] = "conceptualization" },
                }
            },
        }
    }
    local m1t = prepare_credit(m1)
    assert(m1t.hasRoles, "hasRoles should be set to true")
    assertEqual("Methodology", m1t['authors'][1].rolesString)
    assertEqual("Methodology", m1t['authors'][2].rolesString)
    assertEqual("Methodology, Data curation, & Conceptualization", m1t['authors'][3].rolesString)
    assertEqual("Methodology (Lead), Data curation (Supporting), & Conceptualization", m1t['authors'][4].rolesString)

    local m2 = {
        ["authors"] = {
            {
                ["name"] = "Author 1"
            },
            {
                ["name"] = "Author 2"
            }
        }
    }
    local m2t = prepare_credit(m2)
    assert(not m2t.hasRoles, "hasRoles should be set to false")
end

tests()
