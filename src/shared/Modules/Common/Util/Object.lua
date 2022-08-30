function compare(object1: table, object2: table): boolean
    if type(object1) ~= type(object2) then
        return false
    end
    if type(object1) == 'table' then
        for k, v in pairs(object1) do
            if not compare(v, object2[k]) then
                return false
            end
        end
        for k, v in pairs(object2) do
            if not compare(v, object1[k]) then
                return false
            end
        end
        return true
    end
    return object1 == object2
end

local Object = {
    assign = function(target, ...)
        local sources = {...}
        for i = 1, #sources do
            local source = sources[i]
            if source then
                for k, v in pairs(source) do
                    target[k] = v
                end
            end
        end
        return target
    end,
    --[[
    The `Object.entries()` method returns an array of a given object's own enumerable string-keyed property `[key, value]` pairs. This is the same as iterating
    with a `for...in` loop, except that a `for...in` loop enumerates properties in the prototype chain as well.
    ]]
    entries = function(object: table)
        local entries = {}
        for k, v in pairs(object) do
            entries[#entries + 1] = {k, v}
        end
        return entries
    end,
    fromEntries = function(entries: table)
        local object = {}
        for i = 1, #entries do
            local entry = entries[i]
            object[entry[1]] = entry[2]
        end
        return object
    end,
    hasOwn = function(object: table, key: string): boolean
        return object[key] ~= nil
    end,
    keys = function(object: table)
        local array = {}
        for k, _ in pairs(object) do
            array[#array + 1] = k
        end
    end,
    values = function(object: table)
        local array = {}
        for _, v in pairs(object) do
            array[#array + 1] = v
        end
        return array
    end,
    compare = compare
}

return Object