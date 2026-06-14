-- sprites/FunInfiniteStage/left-arrow.lua
-- Flechas del jugador con texturas de Majin_Notes (usado a partir del GO!)

return graphics.newSprite(
	images.notes,
	{
		-- arrowLEFT0000  (frame 2 de Majin_Notes)
		{x = 157, y = 0, width = 154, height = 157, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0},  -- 1: off (arrowLEFT)
		-- purple0000      (frame 44)
		{x = 1126, y = 235, width = 154, height = 157, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 2: on (purple)
		-- pruple end hold (frame 43)
		{x = 1076, y = 235, width = 50,  height = 64,  offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 3: end
		-- purple hold piece (frame 45)
		{x = 1280, y = 235, width = 50,  height = 44,  offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 4: hold
		-- left confirm 0000..0003 (frames 19-22)
		{x = 100,  y = 235, width = 228, height = 231, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 5: confirm0
		{x = 328,  y = 235, width = 228, height = 231, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 6: confirm1
		{x = 556,  y = 235, width = 228, height = 231, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 7: confirm2
		{x = 556,  y = 235, width = 228, height = 231, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 8: confirm3
		-- left press 0000..0003 (frames 23-26)
		{x = 784,  y = 235, width = 146, height = 149, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 9:  press0
		{x = 784,  y = 235, width = 146, height = 149, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 10: press1
		{x = 930,  y = 235, width = 146, height = 149, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 11: press2
		{x = 930,  y = 235, width = 146, height = 149, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 12: press3
	},
	{
		["off"]     = {start = 1,  stop = 1,  speed = 0,  offsetX = 0, offsetY = 0},
		["on"]      = {start = 2,  stop = 2,  speed = 0,  offsetX = 0, offsetY = 0},
		["end"]     = {start = 3,  stop = 3,  speed = 0,  offsetX = 0, offsetY = 0},
		["hold"]    = {start = 4,  stop = 4,  speed = 0,  offsetX = 0, offsetY = 0},
		["confirm"] = {start = 5,  stop = 8,  speed = 24, offsetX = 0, offsetY = 0},
		["press"]   = {start = 9,  stop = 12, speed = 24, offsetX = 0, offsetY = 0},
	},
	"off",
	false
)
