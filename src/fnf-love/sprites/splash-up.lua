--[[----------------------------------------------------------------------------
This file is part of Friday Night Funkin' Rewritten
------------------------------------------------------------------------------]]

-- Splash "vanilla" REAL de Psych Engine -- ver comentario completo en
-- sprites/splash-down.lua (este archivo es idéntico, el color lo decide el
-- shader en fireSplash() según el carril, no el sprite).
return graphics.newSprite(
	images.noteSplashes,
	{
		{x = 1, y = 313, width = 202, height = 284, offsetX = -35, offsetY = -14, offsetWidth = 274, offsetHeight = 311}, -- 1
		{x = 779, y = 272, width = 226, height = 280, offsetX = -29, offsetY = -23, offsetWidth = 274, offsetHeight = 311}, -- 2
		{x = 276, y = 1, width = 264, height = 304, offsetX = -7, offsetY = -5, offsetWidth = 274, offsetHeight = 311}, -- 3
		{x = 1, y = 1, width = 274, height = 311, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 4
		{x = 820, y = 1, width = 183, height = 215, offsetX = -50, offsetY = -40, offsetWidth = 287, offsetHeight = 281}, -- 5
		{x = 276, y = 306, width = 239, height = 251, offsetX = -23, offsetY = -21, offsetWidth = 287, offsetHeight = 281}, -- 6
		{x = 541, y = 1, width = 278, height = 270, offsetX = 0, offsetY = -11, offsetWidth = 287, offsetHeight = 281}, -- 7
		{x = 541, y = 272, width = 237, height = 271, offsetX = -50, offsetY = 0, offsetWidth = 287, offsetHeight = 281} -- 8
	},
	{
		["splash1"] = {start = 1, stop = 4, speed = 24, offsetX = -16 / 0.7, offsetY = -10 / 0.7},
		["splash2"] = {start = 5, stop = 8, speed = 24, offsetX = -4 / 0.7, offsetY = -6 / 0.7}
	},
	"splash1",
	false
)
