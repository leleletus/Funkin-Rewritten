-- sprites/FunInfiniteStage/splash-down.lua
-- Splash del carril ABAJO → color BLUE (Majin/Endless)

return graphics.newSprite(
	images.noteSplashes,
	{
		-- note splash blue 1 (frames 1-4 de endlessNoteSplashes)
		{x = 2,    y = 2,   width = 204, height = 196, offsetX = -90, offsetY = -71, offsetWidth = 382, offsetHeight = 304},
		{x = 208,  y = 2,   width = 299, height = 254, offsetX = -42, offsetY = -32, offsetWidth = 382, offsetHeight = 304},
		{x = 509,  y = 2,   width = 371, height = 295, offsetX = -3,  offsetY = -8,  offsetWidth = 382, offsetHeight = 304},
		{x = 882,  y = 2,   width = 382, height = 304, offsetX = 0,   offsetY = 0,   offsetWidth = 0,   offsetHeight = 0},
		-- note splash blue 2 (frames 5-8)
		{x = 1266, y = 2,   width = 205, height = 196, offsetX = -86, offsetY = -37, offsetWidth = 382, offsetHeight = 305},
		{x = 1473, y = 2,   width = 299, height = 254, offsetX = -41, offsetY = -19, offsetWidth = 382, offsetHeight = 305},
		{x = 2,    y = 308, width = 371, height = 294, offsetX = -8,  offsetY = -2,  offsetWidth = 382, offsetHeight = 305},
		{x = 375,  y = 308, width = 382, height = 305, offsetX = 0,   offsetY = 0,   offsetWidth = 0,   offsetHeight = 0},
	},
	{
		["splash 1"] = {start = 1, stop = 4, speed = 24, offsetX = 0, offsetY = 0},
		["splash 2"] = {start = 5, stop = 8, speed = 24, offsetX = 0, offsetY = 0},
		["splash"]   = {start = 1, stop = 4, speed = 24, offsetX = 0, offsetY = 0},
	},
	"splash",
	false
)
