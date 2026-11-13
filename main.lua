local code = [[printHello world]]

local yewscript = require("yewscript")

yewscript:Compile(code)

yewscript:Step(math.huge)