local Array = {
    --[[
        The `assign()` method is the same to Object.assign() but in array form.

        @example

            local target = { 1, 2 }
            local source = { 3, 4 }
            local result = Array.assign(target, source)

            print(result)
            --> { 1, 2, 3, 4 }
    ]]
    assign = function(target: Array<any>, ...: Array<any>)
        local sources = { ... }
        for _, source in pairs(sources) do
            for _, sourceObject in pairs(source) do
                table.insert(target, sourceObject)
            end
        end
        return target
    end,
    --[[
        The `includes()` method determines whether an array includes a certain value among its entries, returning true or false as appropriate.

        @example

            local array1 = { 1, 2, 3 }

            print(Array.includes(array1, 2))
            -- expected output: true

            local pets = { 'cat', 'dog', 'bat' }

            print(Array.includes(pets, 'cat'))
            -- expected output: true

            print(Array.includes(pets, 'at'))
            -- expected output: false
    ]]
    includes = function(array: Array<any>, searchElement: any, index: number?): boolean
        return table.find(array, searchElement, index)
    end,
    --[[
        The `map()` method creates a new array populated with the results of calling a provided function on every element in the calling array.

        @example

            local array1 = { 1, 4, 9, 16 }

            -- pass a function to map

            local map1 = Array.map(array1, function(x)
                return x * 2
            end)

            print(map1)
            -- expected output: Array { 2, 8, 18, 32 }
    ]]
    map = function(array: Array<any>, func: thread): Array<any>
        -- create a lua map function
        local newArray = {}
        for i, v in ipairs(array) do
            newArray[i] = if func then func(v) else v
        end
        return newArray
    end,
    --[[
        The `pop()` method removes the last element from an array and returns that element. This method changes the length of the array.

        @example

            local plants = { 'broccoli', 'cauliflower', 'cabbage', 'kale', 'tomato' }

            print(plants.pop())
            -- expected output: 'tomato'

            print(plants)
            -- expected output: Array { 'broccoli', 'cauliflower', 'cabbage', 'kale' }

            plants.pop()

            print(plants)
            -- expected output: Array { 'broccoli', 'cauliflower', 'cabbage' }
    ]]
    pop = function(array: Array<any>): any
        local lastElement = array[#array]
        table.remove(array, #array)
        return lastElement
    end,
    --[[
        The `shift()` method removes the first element from an array and returns that removed element. This method changes the length of the array.

        @example

            local array1 = { 1, 2, 3 }

            local firstElement = Array.shift(array1)

            print(array1)
            -- expected output: Array { 2, 3 }

            print(firstElement)
            -- expected output: 1
    ]]
    shift = function(array: Array<any>): any
        local firstElement = array[1]
        table.remove(array, 1)
        return firstElement
    end,
    --[[
        The `find()` method returns the first element in the provided array that satisfies the provided testin function. If no values satisfy the testing function,
            `nil` is returned.

        @example

            local array1 = { 5, 12, 8, 130, 44 }

            local found = Array.find(array1, function(x)
                return x > 10
            end))

            print(found)
            -- expected output: 12
    ]]
    find = function(array: Array<any>, func: thread): any
        for _, v in ipairs(array) do
            if func(v) then
                return v
            end
        end
        return nil
    end,
    --[[
        The `forEach()` method executes a provided function once for each array element.

        @example

            local array1 = { 'a', 'b', 'c' }

            Array.forEach(array1, function(element)
                print(element)
            end)

            -- expected output: a
            -- expected output: b
            -- expected output: c
    ]]
    forEach = function(array: Array<any>, func: thread)
        for _, v in ipairs(array) do
            func(v)
        end
    end,
    --[[
        The `fromDictionary()` method creates a new array populated with the key or value pairs of a dictionary.

        @example

            local dictionary = {
                name = 'John',
                age = 30,
                city = 'New York'
            }
            print(Array.fromDictionary(dictionary))
            -- expected output: Array { 'John', 30, 'New York' }

            print(Array.fromDictionary(dictionary, true))
            -- expected output: Array { 'name', 'age', 'city' }
    ]]
    fromDictionary = function(dictionary: Dictionary<any>, sortByIndex: boolean): Array<any>
        local newArray = {}
        for index, value in pairs(dictionary) do
            table.insert(newArray, if sortByIndex then index else value)
        end
        return newArray
    end,
    --[[
        The `every()` method tests whether all elements in the array pass the test implemented by the provided function. It returns a Boolean value.

        @example

            function isBelowThreshold(currentValue) return currentValue < 40 end

            local array1 = { 1, 30, 39, 29, 10, 13 }

            print(Array.every(array1, isBelowThreshold))
            -- expected output: false

    ]]
    every = function(array: Array<any>, func: thread): boolean
        for _, v in ipairs(array) do
            if not func(v) then
                return false
            end
        end
        return true
    end,
    --[[
        The `join()` method creates and returns a new string by concatenating all of the elements in an array (or an array-like object),
        separated by commas or a specified separator string. If the array has only one item, then that item will be returned without using the separator.
        If the array is empty, then an empty string is returned.

        @example

            local elements = { 'Fire', 'Air', 'Water' }

            print(Array.join(elements))
            -- expected output: Fire,Air,Water

            print(Array.join(elements, ''))
            -- expected output: FireAirWater

            print(Array.join(elements, '-'))
            -- expected output: Fire-Air-Water
    ]]
    join = function(array: Array<any>, separator: string): string
        separator = separator or ','
        return table.concat(array, separator)
    end,
    --[[
        The `reverse()` method reverses an array in place. The first array element becomes the last, and the last array element becomes the first.

        @example

            local array1 = { 'one', 'two', 'three }
            print('array1:', array1)
            -- expected output: Array { 'one', 'two', 'three' }

            local reversed = Array.reverse(array1)
            print('reversed:', reversed)
            -- expected output: Array { 'three', 'two', 'one' }
    ]]
    reverse = function(array: Array<any>): Array<any>
        local newArray = {}
        for i = #array, 1, -1 do
            newArray[#array - i + 1] = array[i]
        end
        return newArray
    end,
    --[[
        The `slice()` method returns a shallow copy of a portion of an array into a new array object
        selected from `start` to `end` (`end` not included) where `start` and `end` represent the index of items in that array. The original array will not be modified.

        @example

            local animals = { 'ant', 'bison', 'camel', 'duck', 'elephant' }

            print(Array.slice(animals, 2))
            -- expected output: Array { 'bison', 'camel', 'duck', 'elephant' }
    ]]
    slice = function(array: Array<any>, start: number, end_: number): Array<any>
        local newArray = {}
        for i = start, end_ or #array do
            newArray[#newArray + 1] = array[i]
        end
        return newArray
    end,
    -- luau function table.sort.. that simple. If no 'func' is provided, then items are sorted in ascending order.
    sort = function(array: Array<any>, func: thread)
        table.sort(array, func or function(a, b)
            return a < b
        end)
    end,
    --[[
        The some() method tests whether at least one element in the array passes the test implemented by the provided function.
        It returns true if, in the array, it finds an element for which the provided function returns true; otherwise it returns false. It doesn't modify the array.

        @example

            local array = { 1, 2, 3, 4, 5 }

            -- checks whether an element is even
            function even(element) return element % 2 === 0 end

            print(Array.some(array, even))
            -- expected output: true
    ]]
    some = function(array: Array<any>, func: thread): boolean
        for _, v in ipairs(array) do
            if func(v) then
                return true
            end
        end
        return false
    end,
    --[[
        The `push()` method adds one or more elements to the end of an array and returns the new length of the array.

        @example

            local animals = { 'pigs', 'goats', 'sheep' }

            local count = Array.push(animals, 'cows')
    ]]
    push = function(array: Array<any>, ...: any)

        for _, v in pairs({...}) do
            table.insert(array, v)
        end
        return #array
    end,
    random = function(array: Array<any>, min): any
        return array[math.random(if min then min else 1, #array)]
    end,
    unshift = function(array, ...)
        for _, v in ipairs({...}) do
            table.insert(array, 1, v)
        end
        return #array
    end
}
Array.shuffle = function(array)
    assert(typeof(array) == 'table', 'Array.shuffle: array must be a table [Array]')
    local rng = Random.new()
    local shuffled = Array.map(array)

    for i = #array, 2, -1 do
        local j = rng:NextInteger(1, i)
        shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
    end
    return shuffled
end

return Array