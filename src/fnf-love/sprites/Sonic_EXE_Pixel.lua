local img = love.graphics.newImage(graphics.imagePath("Sonic_EXE_Pixel"))
img:setFilter("nearest", "nearest")

local Sonic_EXE_Pixel = graphics.newSprite(
	img,
	{
		{x = 0, y = 0, width = 51, height = 51, offsetX = 0, offsetY = 0, offsetWidth = 51, offsetHeight = 51}, -- 1: Sonic_EXE_Pixel Sonic_EXE_Pixel NOTE DOWN0000
		{x = 51, y = 0, width = 51, height = 51, offsetX = 0, offsetY = 0, offsetWidth = 51, offsetHeight = 51}, -- 2: Sonic_EXE_Pixel Sonic_EXE_Pixel NOTE DOWN0001
		{x = 102, y = 0, width = 51, height = 51, offsetX = 0, offsetY = 0, offsetWidth = 51, offsetHeight = 51}, -- 3: Sonic_EXE_Pixel idle0000
		{x = 0, y = 51, width = 51, height = 51, offsetX = 0, offsetY = 0, offsetWidth = 51, offsetHeight = 51}, -- 4: Sonic_EXE_Pixel idle0001
		{x = 51, y = 51, width = 51, height = 51, offsetX = 0, offsetY = 0, offsetWidth = 51, offsetHeight = 51}, -- 5: Sonic_EXE_Pixel idle0002
		{x = 102, y = 51, width = 51, height = 51, offsetX = 0, offsetY = 0, offsetWidth = 51, offsetHeight = 51}, -- 6: Sonic_EXE_Pixel idle0003
		{x = 0, y = 102, width = 51, height = 51, offsetX = 0, offsetY = 0, offsetWidth = 51, offsetHeight = 51}, -- 7: Sonic_EXE_Pixel idle0004
		{x = 51, y = 102, width = 51, height = 51, offsetX = 0, offsetY = 0, offsetWidth = 51, offsetHeight = 51}, -- 8: Sonic_EXE_Pixel Sonic_EXE_Pixel NOTE LEFT0000
		{x = 102, y = 102, width = 51, height = 51, offsetX = 0, offsetY = 0, offsetWidth = 51, offsetHeight = 51}, -- 9: Sonic_EXE_Pixel Sonic_EXE_Pixel NOTE LEFT0001
		{x = 0, y = 153, width = 51, height = 51, offsetX = 0, offsetY = 0, offsetWidth = 51, offsetHeight = 51}, -- 10: Sonic_EXE_Pixel NOTE RIGHT0000
		{x = 51, y = 153, width = 51, height = 51, offsetX = 0, offsetY = 0, offsetWidth = 51, offsetHeight = 51}, -- 11: Sonic_EXE_Pixel NOTE RIGHT0001
		{x = 102, y = 153, width = 51, height = 51, offsetX = 0, offsetY = 0, offsetWidth = 51, offsetHeight = 51}, -- 12: Sonic_EXE_Pixel NOTE RIGHT0002
		{x = 0, y = 204, width = 51, height = 51, offsetX = 0, offsetY = 0, offsetWidth = 51, offsetHeight = 51}, -- 13: Sonic_EXE_Pixel NOTE RIGHT0003
		{x = 51, y = 204, width = 51, height = 51, offsetX = 0, offsetY = 0, offsetWidth = 51, offsetHeight = 51}, -- 14: Sonic_EXE_Pixel NOTE UP0000
		{x = 102, y = 204, width = 51, height = 51, offsetX = 0, offsetY = 0, offsetWidth = 51, offsetHeight = 51}, -- 15: Sonic_EXE_Pixel NOTE UP0001
	},
	{
		["down"] = {start = 1, stop = 2, speed = 24, offsetX = 0, offsetY = 0},
		["idle"] = {start = 3, stop = 7, speed = 12, offsetX = 0, offsetY = 0},
		["left"] = {start = 8, stop = 9, speed = 24, offsetX = 0, offsetY = 0},
		["right"] = {start = 10, stop = 13, speed = 24, offsetX = 0, offsetY = 0},
		["up"] = {start = 14, stop = 15, speed = 24, offsetX = 0, offsetY = 0}
	},
	"idle"
)

return Sonic_EXE_Pixel