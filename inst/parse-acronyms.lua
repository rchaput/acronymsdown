--[[
    Parses acronyms in a document.

    Acronyms must be in the form `\acr{key}` where key is the acronym key.
    The first occurrence of an acronym is replaced by its long name, as
    defined by a list of acronyms in the document's metadata.
    Other occurrences are simply replaced by the acronym's short name.

    A List of Acronym is also generated (similar to a Glossary in LaTeX),
    and all occurrences contain a link to the acronym's definition in this
    List.
]]

-- The options for the List Of Acronyms, as defined in the document's metadata.
local options = {}

--[[
The "acronyms" table: contains the list of known acronyms.
Each acronym is indexed by its key, and must contain:
- a shortname,
- a longname,
- a number of occurrences (initialized to 0),
- an initial order (the order in which they are defined in the metadata),
- an usage order (the order in which they are used in the document).
This table is populated by acronyms in the metadata.
--]]
local acronyms = {}

--[[
The current "usage order" value.
We increment this value each time we find a new acronym, and we use it
to register the order in which acronyms appear.
--]]
local current_order = 0


-- A helper function to print warnings
function warn(msg)
   io.stderr:write("[WARNING][acronymsdown] " .. msg .. "\n")
end


-- Helper function to generate the ID (identifier) from an acronym key.
-- The ID can be used for, e.g., links.
function key_to_id(key)
    return options["id_prefix"] .. key
end
-- Similar helper but for the link itself (based on the ID).
function key_to_link(key)
    return "#" .. key_to_id(key)
end


function Meta(m)
    parseOptionsFromMetadata(m)
    parseAcronymsFromMetadata(m)

    return nil
end


--[[
Parse the options from the Metadata (i.e., the YAML fields).
Absent options are replaced by a default value.
--]]
function parseOptionsFromMetadata(m)
    options = m.acronyms or {}

    if options["id_prefix"] == nil then
        options["id_prefix"] = "acronyms_"
    else
        options["id_prefix"] = pandoc.utils.stringify(options["id_prefix"])
    end

    if options["sorting"] == nil then
        options["sorting"] = "alphabetical"
    else
        options["sorting"] = pandoc.utils.stringify(options["sorting"])
    end

    if options["loa_title"] == nil then
        options["loa_title"] = pandoc.MetaInlines(pandoc.Str("List Of Acronyms"))
    elseif pandoc.utils.stringify(options["loa_title"]) == "" then
        -- It seems that writing `loa_title: ""` in the YAML returns `{}`
        -- (an empty table). `pandoc.utils.stringify({})` returns `""` as well.
        -- This value indicates that the user does not want a Header.
        options["loa_title"] = ""
    end

    if options["include_unused"] == nil then
        options["include_unused"] = true
    end

    if options["insert_beginning"] == nil then
        options["insert_beginning"] = true
    end

    if options["inexisting_keys"] == nil then
        options["inexisting_keys"] = "warn"
    end
end


--[[
Populates the `acronyms` table by walking over the Metadata.
--]]
function parseAcronymsFromMetadata(m)
    -- For now, we expect the metadata to contain an `acronyms.keys` field which
    -- is a list of maps. We could also provide a path to a file and read
    -- the acronyms from this file ; however, JSON parsing in Lua is more
    -- complex. Using a library such as luajson is safer, but I prefer this
    -- filter to remain dependency-free so that all users can use it,
    -- regardless of their installation.
    if not (m.acronyms and m.acronyms.keys and m.acronyms.keys.t == "MetaList") then
       warn("The 'acronyms.keys' field in the Metadata is absent or malformed")
       return nil
    end
    -- We have a list of acronyms directly in the metadata (YAML)
    -- Iterate over the acronyms and populate the local acronyms table
    for k, v in ipairs(m.acronyms.keys) do
        if v.t == "MetaMap" then
            local key = v["key"]
            local shortname = pandoc.utils.stringify(v["shortname"])
            local longname = pandoc.utils.stringify(v["longname"])
            -- Key is optional. If not present, we use the shortname.
            if key then key = pandoc.utils.stringify(key)
            else key = shortname end
            acronyms[key] = {
                shortname = shortname,
                longname = longname,
                occurrences = 0,
                initial_order = k,
                usage_order = nil,
            }
        end
    end
end


--[[
Sort the acronyms table, based on a criteria. The criteria can be:
- alphabetical: sort acronyms by alphabetical order (using their shortname).
- usage: sort acronyms by the order in which they are used.
- initial: keep acronyms in the order they were defined.
--]]
function sortAcronyms(acronyms, criteria)
    -- I think we need to create a new table, indexed by ints
    -- so we can sort the keys themselves (and use `ipairs` on it)
    local keys = {}
    for k, v in pairs(acronyms) do
        if options["include_unused"] or v["usage_order"] ~= nil then
            table.insert(keys, k)
        end
    end
    -- Sort the keys according to the criteria and data in acronyms
    if criteria == "alphabetical" then
        table.sort(keys,
            function (a,b) return acronyms[a]["shortname"] < acronyms[b]["shortname"] end)
    elseif criteria == "usage" then
        if options["include_unused"] then
            error("When the 'usage' sorting is used, 'include_unused' must be set to false!")
        end
        table.sort(keys,
            function (a,b) return acronyms[a]["usage_order"] < acronyms[b]["usage_order"] end)
    elseif criteria == "initial" then
        table.sort(keys,
            function (a,b) return acronyms[a]["initial_order"] < acronyms[b]["initial_order"] end)
    else
        warn("Sorting criteria unrecognized: " .. criteria)
    end
    return keys
end


--[[
Generate the List Of Acronyms.
Returns 2 values: the Header, and the DefinitionList.
--]]
function generateLoA()
    -- Original idea from https://gist.github.com/RLesur/e81358c11031d06e40b8fef9fdfb2682

    -- We first get the list of sorted keys, according to the defined criteria.
    local keys = sortAcronyms(acronyms, options["sorting"])

    -- Create the table that represents the DefinitionList
    local definition_list = {}
    for i, key in ipairs(keys) do
        -- The definition's name. A Span with an ID so we can create a link.
        local name = pandoc.Span(acronyms[key]["shortname"],
            pandoc.Attr(key_to_id(key), {}, {}))
        -- The definition's value.
        local definition = pandoc.Plain(acronyms[key]["longname"])
        table.insert(definition_list, { name, definition })
    end

    -- Create the Header (only if the title is not empty)
    local header = nil
    if options["loa_title"] ~= "" then
        local loa_classes = {"loa"}
        header = pandoc.Header(1,
            { table.unpack(options["loa_title"]) },
            pandoc.Attr(key_to_id("HEADER_LOA"), loa_classes, {})
        )
    end

    return header, pandoc.DefinitionList(definition_list)
end


--[[
Append the List Of Acronyms to the document (at the beginning).
--]]
function appendLoA(doc)
    -- If disabled, do nothing
    if not options["insert_beginning"] then
        return nil
    end

    local header, definition_list = generateLoA()

    -- Insert the DefinitionList
    table.insert(doc.blocks, 1, definition_list)

    -- Insert the Header
    if header ~= nil then
        table.insert(doc.blocks, 1, header)
    end

    return pandoc.Pandoc(doc.blocks, doc.meta)
end


--[[
Place the List Of Acronyms in the document (in place of a `\printacronyms` block).
Since Header and DefinitionList are Blocks, we need to replace a Block
(Pandoc does not allow to create Blocks from Inlines).
Thus, `\printacronyms` needs to be in its own Block (no other text!).
--]]
function RawBlock(el)
    -- The block's content must be exactly "\printacronyms"
    if not (el and el.text == "\\printacronyms") then
        return nil
    end

    local header, definition_list = generateLoA()

    if header ~= nil then
        return { header, definition_list }
    else
        return definition_list
    end
end

--[[
Replace an acronym `\acr{KEY}`, where KEY is not in the `acronyms` table.
According to the options, we can either:
- ignore, and return simply the KEY as text
- print a warning, and return simply the KEY as text
- raise an error
--]]
function replaceInexistingAcronym(acr_key)
    if options["inexisting_keys"] == "ignore" then
        return pandoc.Str(acr_key)
    elseif options["inexisting_keys"] == "warn" then
        warn("Acronym key " .. key .. " not recognized, ignoring...")
        return pandoc.Str(acr_key)
    elseif options["inexisting_keys"] == "error" then
        error("Acronym key " .. key .. " not recognized, stopping!")
    else
        error("Unrecognized option inexisting_keys=" .. options["inexisting_keys"])
    end
end

--[[
Replace an acronym `\acr{KEY}`, where KEY is recognized in the `acronyms` table.
--]]
function replaceExistingAcronym(acr_key)
    acronyms[acr_key]["occurrences"] = acronyms[acr_key]["occurrences"] + 1
    if acronyms[acr_key]["occurrences"] > 1 then
        -- This acr_key already appeared at least once.
        -- We therefore display only the acronym.
        return pandoc.Link(acronyms[acr_key]["shortname"],
            key_to_link(acr_key))
    else
        -- This acr_key never appeared!
        -- We display the full name + the acronym between parenthesis
        current_order = current_order + 1
        acronyms[acr_key]["usage_order"] = current_order
        return pandoc.Link(acronyms[acr_key]["longname"] .. " (" .. acronyms[acr_key]["shortname"] .. ")",
            key_to_link(acr_key))
    end
end

--[[
Replace each `\acr{KEY}` with the correct text and link to the list of acronyms.
--]]
function replaceAcronym(el)
    local acr_key = string.match(el.text, "\\acr{(.+)}")
    if acr_key then
        -- This is an acronym, we need to parse it.
        if acronyms[acr_key] == nil then
            -- The acronym does not exists
            return replaceInexistingAcronym(acr_key)
        else
            -- The acronym exists (and is recognized)
            return replaceExistingAcronym(acr_key)
        end
    else
        -- This is not an acronym, return nil to leave it unchanged.
        return nil
    end
end

-- Force the execution of the Meta filter before the RawInline
-- (we need to load the acronyms first!)
-- RawBlock and Doc happen after RawInline so that the actual usage order
-- of acronyms is known (and we can sort the List of Acronyms accordingly)
return {
    { Meta = Meta },
    { RawInline = replaceAcronym },
    { RawBlock = RawBlock },
    { Doc = appendLoA },
}
