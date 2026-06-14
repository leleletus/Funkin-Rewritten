-- sprites/FunInfiniteStage/splash-up.lua
-- Splash del carril ARRIBA → color GREEN (Majin/Endless)

return graphics.newSprite(
	images.noteSplashes,
	{
		-- note splash green 1 (frames 9-12 de endlessNoteSplashes)
		{x = 759,  y = 308,  width = 204, height = 196, offsetX = -90, offsetY = -71, offsetWidth = 382, offsetHeight = 304},
		{x = 965,  y = 308,  width = 299, height = 254, offsetX = -42, offsetY = -32, offsetWidth = 382, offsetHeight = 304},
		{x = 1266, y = 308,  width = 371, height = 295, offsetX = -3,  offsetY = -8,  offsetWidth = 382, offsetHeight = 304},
		{x = 882,  y = 2,    width = 382, height = 304, offsetX = 0,   offsetY = 0,   offsetWidth = 0,   offsetHeight = 0},
		-- note splash green 2 (frames 13-16)
		{x = 1639, y = 308,  width = 205, height = 195, offsetX = -86, offsetY = -37, offsetWidth = 382, offsetHeight = 304},
		{x = 2,    y = 615,  width = 298, height = 254, offsetX = -41, offsetY = -18, offsetWidth = 382, offsetHeight = 304},
		{x = 302,  y = 615,  width = 372, height = 294, offsetX = -7,  offsetY = -2,  offsetWidth = 382, offsetHeight = 304},
		{x = 676,  y = 615,  width = 382, height = 304, offsetX = 0,   offsetY = 0,   offsetWidth = 0,   offsetHeight = 0},
	},
	{
		["splash 1"] = {start = 1, stop = 4, speed = 24, offsetX = 0, offsetY = 0},
		["splash 2"] = {start = 5, stop = 8, speed = 24, offsetX = 0, offsetY = 0},
		["splash"]   = {start = 1, stop = 4, speed = 24, offsetX = 0, offsetY = 0},
	},
	"splash",
	false
)
