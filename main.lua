local code = "errmode0/A=4;3;2;1/forA/printZ/endloop/A+10/printA"

local yewscript = require("yewscript")

yewscript:Compile(code)

yewscript:Step(math.huge)