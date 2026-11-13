-- Made by blueloops9
-- Should support almost every major feature, the only one I can think of that isn't implemented is vector math

local yewscript = {}

---Separates `Str` by `Sep`
---@param Str string
---@param Sep string
---@return string[]
local function split(Str, Sep)
    local out,len = {},1
    
    for I in string.gmatch(Str,"([^"..Sep.."]+)") do
        out[len]=I
        len=len+1
    end
    
    return out
end

---Converts a lua type to a yewscript string
---@param value number | table | string?
---@return string
function yewscript.luatoyew(value)
    local valueType = type(value)

    if valueType == "table" then
        if value[1] then -- Array
            return table.concat(value, ";")
        else -- Dictionary
            local out = {}

            for i, v in pairs(value) do
                table.insert(out, (":%s::%s:"):format(i, v))
            end

            return table.concat(out)
        end
    end

    return tostring(value) or "nil"
end

---Converts a yewscript string to a lua type
---@param str string
---@return number | table | string?
function yewscript.yewtolua(str)
    if str:find(";") then
        return split(str, ";")
    elseif str:find(":") then
        local decoded, out = split(str, ":"), {}

        for i = 1, #decoded, 2 do
            out[decoded[i]] = decoded[i+1]
        end

        return out
    elseif str == "nil" then
        return nil
    else
        return tonumber(str) or str
    end
end

---Parses variable/data into a lua type
---@param str string
---@return number | table | string?
function yewscript.getData(str)
    if #str == 1 then
        local character = string.byte(str)
        
        if character > 64 and character < 91 then
            return yewscript.Variables[str]
        end
    end

    return yewscript.yewtolua(str)
end

---Parses variable/keyword/data into a lua type, handles arguments as well
---@param str string
---@return number | table | string?
function yewscript.getDataWIndex(str)
    local index, keyword = split(str, "'")

    local hasIndex = #index > 1

    if hasIndex then
        str = index[1]
        table.remove(index, 1)
    end

    for _, Keyword in pairs(yewscript.sortedKeywords) do
        if str:sub(1, #Keyword[1]) == Keyword[1] then
            keyword = Keyword[1]
            break
        end
    end

    if hasIndex then
        for i, v in pairs(index) do
            ---@diagnostic disable-next-line: assign-type-mismatch
            index[i] = yewscript.getData(v)
        end
    elseif keyword then
        ---@diagnostic disable-next-line: cast-local-type
        index = #str > #keyword and {yewscript.getData(str:sub(#keyword+1, -1))}
    end

    local value

    if keyword then
        ---@diagnostic disable-next-line: param-type-mismatch
        value = yewscript.Keywords[keyword](unpack(index or {}))
    else
        value = yewscript.getData(str)

        ---@diagnostic disable-next-line: need-check-nil
        value = hasIndex and value[index[1]] or value
    end

    return value
end

yewscript.Code = ""
yewscript.Compiled = {}
yewscript.Errormode = true

--During compilation this loops through and resets back to zero when ready
yewscript.CurrentLine = 0

yewscript.Variables = {}

yewscript.Operators = {
    ["="] = function(x, y)return y end,
    ["+"] = function(x, y)return x + y end,
    ["-"] = function(x, y)return x - y end,
    ["*"] = function(x, y)return x * y end,
    ["\\"] = function(x, y)return x / y end,
    ["^"] = function(x, y)return x ^ y end,
    ["%"] = function(x, y)return x % y end,
    ["@"] = function(x, y)
        if y == -1 then return math.floor(x)
        elseif y == 0 then return math.floor(x+.5)
        elseif y == 1 then return math.ceil(x)
        end
    end,
    [">"] = function(x, y)return x > y and y or x end,
    ["<"] = function(x, y)return x < y and y or x end,
}

yewscript.LogicOperators = {
    ["<"] = function(x, y)return x < y end,
    [">"] = function(x, y)return x > y end,
    ["{"] = function(x, y)return x <= y end,
    ["}"] = function(x, y)return x >= y end,
    ["="] = function(x, y)return yewscript.luatoyew(x) == yewscript.luatoyew(y) end,
    ["!"] = function(x, y)return yewscript.luatoyew(x) ~= yewscript.luatoyew(y) end,
    ["["] = function(x, y)return string.find(yewscript.luatoyew(x), yewscript.luatoyew(y)) ~= nil end,
    ["]"] = function(x, y)return string.find(yewscript.luatoyew(x), yewscript.luatoyew(y)) == nil end,
}

yewscript.Keywords = {
    Buffer = function(channel)
        local data = yewscript.Buffer[channel]
        yewscript.Buffer[channel] = nil
        return data
    end,
    Rand = math.random,
    Time = os.clock,
    Self = function() return yewscript.Code end,
    RealTime = function() return os.time() end,
    Length = function(data) return #data end,
    Magnitude = function(x, y, z)
        if type(x) == "table" then
            x, y, z = unpack(x)
        end

        return math.sqrt(x*x + y*y + z*z)
    end,
    Unit = function(x, y, z)
        if type(x) == "table" then
            x, y, z = unpack(x)
        end

        local magnitude = math.sqrt(x*x + y*y + z*z)

        return x/magnitude, y/magnitude, z/magnitude
    end,
    Size = function(data)
        if data[1] then -- array
            return #data
        else -- dictionary
            local count = 0

            for _, _ in pairs(data) do
                count = count + 1
            end
            
            return count
        end
    end,
    Find = function(list, data)
        for index, value in pairs(list) do
            if value == data then
                return index
            end
        end
    end,
    Sub = function(data, start, finish)
        return data:sub(start, finish)
    end,
    Swap = function(data)
        if type(data) == "string" then
            return {string.byte(data)}
        elseif type(data) == "table" then
            return string.char(unpack(data))
        end
    end,
    Abs = math.abs,
    Acos = math.acos,
    Asin = math.asin,
    Atan = math.atan,
    Cos = math.cos,
    Cosh = math.cosh,
    Deg = math.deg,
    Rad = math.rad,
    Sin = math.sin,
    Sinh = math.sinh,
    Tan = math.tan,
    Tanh = math.tanh,
    Btan = math.atan2,
}

yewscript.loopstack, yewscript.ifstack, yewscript.ifbranches = {}, {}, {}

yewscript.Instructions = {
    ["reset"] = function()return function()yewscript:Reset()end end,
    ["goto"] = function()return function(line)yewscript.CurrentLine = line - 1 end end,
    ["errmode"] = function()return function(errormode)yewscript.Errormode = errormode == 1 end end,
    ["for"] = function()return function(array)
        table.insert(yewscript.loopstack, {yewscript.CurrentLine, 1, #array, array})
        yewscript.Variables.Z = array[1]
    end end,
    ["endloop"] = function()return function()
        local currentLoop = yewscript.loopstack[#yewscript.loopstack]

        if currentLoop[2] == currentLoop[3] then
            yewscript.loopstack[#yewscript.loopstack] = nil
        else
            yewscript.CurrentLine = currentLoop[1]
            currentLoop[2] = currentLoop[2] + 1

            if currentLoop[4] then
                yewscript.Variables.Z = currentLoop[4][currentLoop[2]]
            end
        end
    end end,
    ["insert"] = function(variable)return function(_, data, pos)
        table.insert(yewscript.Variables[variable], pos or #yewscript.Variables[variable] + 1, data)
    end end,
    ["remove"] = function(variable)return function(_, pos)
        if pos == 0 then
            pos = #yewscript.Variables[variable]
        elseif pos == -1 then
            pos = 1
        end

        table.remove(variable, pos)
    end end,
    ["loop"] = function()return function(num)
        table.insert(yewscript.loopstack, {yewscript.CurrentLine, 1, num})
    end end,
    ["if"] = function(raw)
        local branch = {}

        yewscript.ifbranches[yewscript.CurrentLine] = branch
        table.insert(yewscript.ifstack, yewscript.CurrentLine)

        local operation, a, b

        for possibleOperator, func in pairs(yewscript.LogicOperators) do
            local stringSplit = split(raw, possibleOperator)
            if #stringSplit > 1 then
                operation, a, b = func, stringSplit[1], stringSplit[2]
            end
        end
        
        return function()
            if not operation( -- comparisons are slow due to types not existing
                yewscript.getData(a),
                yewscript.getData(b)) then
                if branch[2] then
                    yewscript.CurrentLine = branch[2]
                else
                    yewscript.CurrentLine = branch[1]
                end
            end
        end
    end,
    ["print"] = function()return function(data)
        print(yewscript.luatoyew(data))
    end end,
    ["else"] = function() -- You don't need to terminate the stack because end will
        local len = #yewscript.ifstack
        local branch = yewscript.ifbranches[yewscript.ifstack[len]]

        branch[2] = yewscript.CurrentLine

        return function()
            yewscript.CurrentLine = branch[1]
        end
    end,
    ["end"] = function()
        local len = #yewscript.ifstack
        yewscript.ifbranches[yewscript.ifstack[len]][1] = yewscript.CurrentLine
        table.remove(yewscript.ifstack, 1)
        
        return function()end
    end,
    ["leapto"] = function()return function(lines)
        yewscript.CurrentLine = yewscript.CurrentLine + lines - 1
    end end,
    ["sweep"] = function(variable)return function(_, data)
        local array = yewscript.Variables[variable]

        for index, value in pairs(array) do
            if data == value then
                table.remove(array, index)
            end
        end
    end end,
    ["affix"] = function(variable)return function(_, data) --This also makes affix slow
        yewscript.Variables[variable] = yewscript.yewtolua(yewscript.luatoyew(yewscript.Variables[variable])..yewscript.luatoyew(data))
    end end,
    ["dict"] = function(variable)return function(_, data, key)
        yewscript.Variables[variable][key] = data
    end end,
}

function yewscript:Reset()
    yewscript.Variables = {}
    yewscript.loopstack = {}
end

local whitespace = {
    " ",
    "\t",
}

---Compiles yewscript code, run the yewscript code via `yewscript:Step`
---@param code string
function yewscript:Compile(code)
    yewscript.Code = code

    local formatted = code:gsub("\n", "/")

    local sortedInstructions, sortedKeywords = {}, {}

    for i, v in pairs(yewscript.Instructions) do table.insert(sortedInstructions, {i, v}) end
    for i, v in pairs(yewscript.Keywords) do table.insert(sortedKeywords, {i, v}) end

    table.sort(sortedInstructions, function(a, b)return #a[1] > #b[1] end)
    table.sort(sortedKeywords, function(a, b)return #a[1] > #b[1] end)

    yewscript.sortedInstructions, yewscript.sortedKeywords = sortedInstructions, sortedKeywords

    for line, command in pairs(split(formatted, "/")) do
        for i = 1, #command do -- Format the program so there's no indentation
            if not whitespace[command:sub(i, i)] then
                command = command:sub(i, -1) break
            end
        end

        yewscript.CurrentLine = line

        if command:sub(1, 1) == "-" then -- Comment
            table.insert(yewscript.Compiled, function()end)
        elseif yewscript.Operators[command:sub(2, 2)] then -- Math operation
            local operation = yewscript.Operators[command:sub(2, 2)]

            local variable, data = command:sub(1,1), command:sub(3, -1)

            table.insert(yewscript.Compiled, function()
                local a, b = yewscript.Variables[variable], yewscript.getDataWIndex(data)
                yewscript.Variables[variable] = operation(
                    tonumber(a) or a,
                    tonumber(b) or b
                )
            end)
        else -- Instruction
            for _, pair in pairs(sortedInstructions) do
                local instruction, func = unpack(pair)

                if command:sub(1, #instruction) == instruction then
                    local arguments = split(command:sub(#instruction + 1, -1), "'")

                    table.insert(yewscript.Compiled, {func(unpack(arguments)), arguments})

                    break
                end
            end
        end
    end

    yewscript.CurrentLine = 0
end

---Returns false if the script has ended
---@param iterations number? The amount of steps to execute
---@return boolean
function yewscript:Step(iterations)
    local function run()
        yewscript.CurrentLine = yewscript.CurrentLine + 1
        if yewscript.Compiled[yewscript.CurrentLine] then
            local func = yewscript.Compiled[yewscript.CurrentLine]

            if type(func) == "function" then -- Standalone
                func()
            else -- Arguments
                local args = {}

                for i, v in pairs(func[2]) do
                    args[i] = yewscript.getData(v)
                end
                
                func[1](unpack(args))
            end
        else
            return false
        end

        return true
    end

    for i = 1, iterations do
        if yewscript.Errormode then
            if not run() then return false end
        else
            local returning

            local success, result, a = pcall(function()
                returning = run()
            end)

            if returning == false then return false end
        end
    end

    return true
end


return yewscript