-- sprites/FunInfiniteStage/splash-right.lua
-- Splash del carril DERECHO → color RED (Majin/Endless)

return graphics.newSprite(
	images.noteSplashes,
	{
		-- note splash red 1 (frames 25-28 de endlessNoteSplashes)
		{x = 1651, y = 921,  width = 204, height = 196, offsetX = -90, offsetY = -71, offsetWidth = 382, offsetHeight = 304},
		{x = 2,    y = 1227, width = 299, height = 254, offsetX = -42, offsetY = -32, offsetWidth = 382, offsetHeight = 304},
		{x = 303,  y = 1227, width = 371, height = 295, offsetX = -3,  offsetY = -8,  offsetWidth = 382, offsetHeight = 304},
		{x = 676,  y = 1227, width = 382, height = 304, offsetX = 0,   offsetY = 0,   offsetWidth = 0,   offsetHeight = 0},
		-- note splash red 2 (frames 29-32)
		{x = 1060, y = 1227, width = 205, height = 195, offsetX = -86, offsetY = -37, offsetWidth = 382, offsetHeight = 304},
		{x = 1267, y = 1227, width = 298, height = 254, offsetX = -41, offsetY = -18, offsetWidth = 382, offsetHeight = 304},
		{x = 1567, y = 1227, width = 372, height = 294, offsetX = -7,  offsetY = -2,  offsetWidth = 382, offsetHeight = 304},
		{x = 2,    y = 1533, width = 382, height = 304, offsetX = 0,   offsetY = 0,   offsetWidth = 0,   offsetHeight = 0},
	},
	{
		["splash 1"] = {start = 1, stop = 4, speed = 24, offsetX = 0, offsetY = 0},
		["splash 2"] = {start = 5, stop = 8, speed = 24, offsetX = 0, offsetY = 0},
		["splash"]   = {start = 1, stop = 4, speed = 24, offsetX = 0, offsetY = 0},
	},
	"splash",
	false
)
