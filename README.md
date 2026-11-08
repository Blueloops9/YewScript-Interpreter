# YewScript-Interpreter
Yewscript is a scripting language used for computers in the Roblox game [Scarlet Skies](https://www.roblox.com/games/4649961152/Scarlet-Skies-2-The-Forbidden-Planet) (now defunct) that is somewhat reminiscent to assembly.

## Running
The interpreter is very simple to setup, just download yewscript.lua and use the main.lua program to run it:
```lua
local code = "printHello world!"

local yewscript = require("yewscript")

yewscript:Compile(code)

yewscript:Step(math.huge)
```
## Limitations
Instructions and keywords like `wait`, `Buffer`, `signal`, etc are not included with this base program since those functions are not possible through lua standalone, meaning that you would have to produce those commands yourself. (see below)

## Custom instructions/keywords
Pretty straight forward:
```lua
local code = "A=25/A=SqrtA/B=tableinit10'A/printB/destroyA"

local yewscript = require("yewscript")

yewscript.Keywords.Sqrt = math.sqrt

yewscript.Instructions.destroy = function(variable) return function()
  yewscript.Variables[variable] = nil
end end

yewscript.Instructions.tableinit = function() return function(num, multiplier)
  local newTable = {}
  for i = 1, num do
    newTable[i] = i * multiplier
  end

  return num
end end

yewscript:Compile(code)

yewscript:Step(math.huge)
```

## Helper functions
These might or might not be useful for when making custom commands.

`yewscript.luatoyew(value)` Converts a lua type to a yewscript string.
`yewscript.yewtolua(str)` Converts a yewscript string to a lua type.
`yewscript.getData(str)` Parses variable/data into a lua type
`yewscript.getDataWIndex(str)` Parses variable/keyword/data into a lua type, handles arguments as well
