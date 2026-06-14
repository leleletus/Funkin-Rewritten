local img = love.graphics.newImage(graphics.imagePath("Pixel_gf"))
img:setFilter("nearest", "nearest")

local Pixel_gf = graphics.newSprite(
	img,
	{
		{x = 0, y = 0, width = 77, height = 71, offsetX = 0, offsetY = 0, offsetWidth = 77, offsetHeight = 71}, -- 1: Pixel gf miss0000
		{x = 77, y = 0, width = 77, height = 71, offsetX = 0, offsetY = 0, offsetWidth = 77, offsetHeight = 71}, -- 2: Pixel gf miss0001
		{x = 154, y = 0, width = 77, height = 71, offsetX = 0, offsetY = 0, offsetWidth = 77, offsetHeight = 71}, -- 3: Pixel gf miss0002
		{x = 0, y = 71, width = 77, height = 71, offsetX = 0, offsetY = 0, offsetWidth = 77, offsetHeight = 71}, -- 4: Pixel gf miss0003
		-- idle: cada frame duplicado para que la animación dure ~1.33s a speed=24 (igual que la GF normal)
		{x = 77, y = 71, width = 77, height = 71, offsetX = 0, offsetY = 0, offsetWidth = 77, offsetHeight = 71}, -- 5: Pixel gf dance0000
		{x = 77, y = 71, width = 77, height = 71, offsetX = 0, offsetY = 0, offsetWidth = 77, offsetHeight = 71}, -- 6: Pixel gf dance0000 (dup)
		{x = 154, y = 71, width = 77, height = 71, offsetX = 0, offsetY = 0, offsetWidth = 77, offsetHeight = 71}, -- 7: Pixel gf dance0001
		{x = 154, y = 71, width = 77, height = 71, offsetX = 0, offsetY = 0, offsetWidth = 77, offsetHeight = 71}, -- 8: Pixel gf dance0001 (dup)
		{x = 0, y = 142, width = 77, height = 71, offsetX = 0, offsetY = 0, offsetWidth = 77, offsetHeight = 71}, -- 9: Pixel gf dance0002
		{x = 0, y = 142, width = 77, height = 71, offsetX = 0, offsetY = 0, offsetWidth = 77, offsetHeight = 71}, -- 10: Pixel gf dance0002 (dup)
		{x = 77, y = 142, width = 77, height = 71, offsetX = 0, offsetY = 0, offsetWidth = 77, offsetHeight = 71}, -- 11: Pixel gf dance0003
		{x = 77, y = 142, width = 77, height = 71, offsetX = 0, offsetY = 0, offsetWidth = 77, offsetHeight = 71}, -- 12: Pixel gf dance0003 (dup)
		{x = 154, y = 142, width = 77, height = 71, offsetX = 0, offsetY = 0, offsetWidth = 77, offsetHeight = 71}, -- 13: Pixel gf dance0004
		{x = 154, y = 142, width = 77, height = 71, offsetX = 0, offsetY = 0, offsetWidth = 77, offsetHeight = 71}, -- 14: Pixel gf dance0004 (dup)
		{x = 0, y = 213, width = 77, height = 71, offsetX = 0, offsetY = 0, offsetWidth = 77, offsetHeight = 71}, -- 15: Pixel gf dance0005
		{x = 0, y = 213, width = 77, height = 71, offsetX = 0, offsetY = 0, offsetWidth = 77, offsetHeight = 71}, -- 16: Pixel gf dance0005 (dup)
		{x = 77, y = 213, width = 77, height = 71, offsetX = 0, offsetY = 0, offsetWidth = 77, offsetHeight = 71}, -- 17: Pixel gf dance0006
		{x = 77, y = 213, width = 77, height = 71, offsetX = 0, offsetY = 0, offsetWidth = 77, offsetHeight = 71}, -- 18: Pixel gf dance0006 (dup)
		{x = 154, y = 213, width = 77, height = 71, offsetX = 0, offsetY = 0, offsetWidth = 77, offsetHeight = 71}, -- 19: Pixel gf dance0007
		{x = 154, y = 213, width = 77, height = 71, offsetX = 0, offsetY = 0, offsetWidth = 77, offsetHeight = 71}, -- 20: Pixel gf dance0007 (dup)
	},
	{
		["sad"] = {start = 1, stop = 4, speed = 12, offsetX = 0, offsetY = 0},
		["idle"] = {start = 5, stop = 20, speed = 12, offsetX = 0, offsetY = 0}
	},
	"idle",
	false
)

return Pixel_gf