-- data.lua
local json = require("lib.json")

local file = love.filesystem.read("data.json")
if not file then
    error("No se pudo encontrar data.json")
end

local data = json.decode(file)
return data