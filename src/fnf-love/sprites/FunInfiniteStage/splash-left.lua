-- sprites/FunInfiniteStage/splash-left.lua
-- Splash del carril IZQUIERDO → color PURPLE (Majin/Endless)

return graphics.newSprite(
	images.noteSplashes,
	{
		-- note splash purple 1 (frames 17-20 de endlessNoteSplashes)
		{x = 1060, y = 615,  width = 204, height = 196, offsetX = -90, offsetY = -71, offsetWidth = 382, offsetHeight = 304},
		{x = 1266, y = 615,  width = 299, height = 254, offsetX = -42, offsetY = -32, offsetWidth = 382, offsetHeight = 304},
		{x = 1567, y = 615,  width = 371, height = 295, offsetX = -3,  offsetY = -8,  offsetWidth = 382, offsetHeight = 304},
		{x = 2,    y = 921,  width = 382, height = 304, offsetX = 0,   offsetY = 0,   offsetWidth = 0,   offsetHeight = 0},
		-- note splash purple 2 (frames 21-24)
		{x = 386,  y = 921,  width = 205, height = 196, offsetX = -86, offsetY = -36, offsetWidth = 382, offsetHeight = 304},
		{x = 593,  y = 921,  width = 299, height = 254, offsetX = -41, offsetY = -18, offsetWidth = 382, offsetHeight = 304},
		{x = 894,  y = 921,  width = 371, height = 295, offsetX = -8,  offsetY = -1,  offsetWidth = 382, offsetHeight = 304},
		{x = 1267, y = 921,  width = 382, height = 304, offsetX = 0,   offsetY = 0,   offsetWidth = 0,   offsetHeight = 0},
	},
	{
		["splash 1"] = {start = 1, stop = 4, speed = 24, offsetX = 0, offsetY = 0},
		["splash 2"] = {start = 5, stop = 8, speed = 24, offsetX = 0, offsetY = 0},
		["splash"]   = {start = 1, stop = 4, speed = 24, offsetX = 0, offsetY = 0},
	},
	"splash",
	false
)
