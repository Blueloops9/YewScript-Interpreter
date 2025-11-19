local loadyewscript = require("yewscript")


local Code = "printhello world!"
local Yewscript = loadyewscript()(Code)
local Stop=false

repeat Stop=Yewscript() until Stop
