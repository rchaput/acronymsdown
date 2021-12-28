--[[

    This file defines an Acronym and the Acronyms table.

--]]


-- Define an Acronym with some default values
Acronym = {
    -- The acronym's key, or label. Used to identify it. Must be unique.
    key = nil,
    -- The acronym's short form (i.e., the acronym itself).
    shortname = nil,
    -- The acronym's definition, or description.
    longname = nil,
    -- The number of times this acronym was used.
    occurrences = 0,
    -- The order in which acronyms are defined. 1=first, 2=second, etc.
    definition_order = nil,
    -- The order in which acronyms appear in the document. 1=first, nil=never.
    usage_order = nil,
}


-- Create a new Acronym
function Acronym:new(object)
    setmetatable(object, self)
    self.__index = self

    -- Check that important attributes are non-nil
    assert(object.shortname ~= nil,
        "An Acronym shortname should not be nil!")
    assert(object.longname ~= nil,
        "An Acronym longname should not be nil!")

    -- If the key is not set, we want to use the shortname instead.
    -- (Most of the time, the key is the shortname in lower case anyway...)
    object.key = object.key or object.shortname

    return object
end


-- Debug (helper) function
function Acronym.__tostring(acronym)
    local str = "Acronym{"
    str = str .. "key=" .. acronym.key .. ";"
    str = str .. "short=" .. acronym.shortname .. ";"
    str = str .. "long=" .. acronym.longname .. ";"
    str = str .. "occurrences=" .. acronym.occurrences .. ";"
    str = str .. "definition_order=" .. tostring(acronym.definition_order) .. ";"
    str = str .. "usage_order=" .. tostring(acronym.usage_order)
    str = str .. "}"
    return str
end


-- Increment the count of occurrences
function Acronym:incrementOccurrences()
    self.occurrences = self.occurrences + 1
end


-- Is this the acronym's first occurrence?
function Acronym:isFirstUse()
    return self.occurrences <= 1
end


-- The Acronyms database.
Acronyms = {
    -- The table that contains all acronyms, indexed by their key.
    acronyms = {},

    -- The current "definition_order" value.
    -- Each time a new acronym is defined, we increment this value to keep
    -- count of the order in which acronyms are defined.
    current_definition_order = 0,
}

-- Get the Acronym with the given key, or nil if not found.
function Acronyms:get(key)
    return self.acronyms[key]
end

-- Does the table contains the given key?
function Acronyms:contains(key)
    return self:get(key) ~= nil
end

-- Add a new acronym to the table. Also handles duplicates.
function Acronyms:add(acronym, on_duplicate)
    assert(acronym.key ~= nil,
        "The acronym key should not be nil!")
    assert(on_duplicate ~= nil,
        "on_duplicate should not be nil!")

    -- Handling duplicate keys
    if self:contains(acronym.key) then
        if on_duplicate == "replace" then
            -- Do nothing, let us replace the previous acronym.
        elseif on_duplicate == "keep" then
            -- Do nothing, but do not replace: we return here.
            return
        elseif on_duplicate == "warn" then
            -- Warn, and do not replace.
            warn("Duplicate key: " .. acronym.key)
            return
        elseif on_duplicate == "error" then
            -- Stop execution.
            error("Duplicate key: " .. acronym.key)
        else
            error("Unrecognized option on_duplicate = " .. on_duplicate)
        end
    end

    self.current_definition_order = self.current_definition_order + 1
    acronym.definition_order = self.current_definition_order
    self.acronyms[acronym.key] = acronym
end
