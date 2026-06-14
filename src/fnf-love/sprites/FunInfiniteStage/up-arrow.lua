-- sprites/FunInfiniteStage/up-arrow.lua
-- Flechas del jugador con texturas de Majin_Notes (usado a partir del GO!)

return graphics.newSprite(
	images.notes,
	{
		-- arrowUP0000    (frame 4)
		{x = 465,  y = 0,   width = 157, height = 154, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 1: off
		-- green0000      (frame 16)
		{x = 1891, y = 0,   width = 157, height = 154, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 2: on
		-- green hold end (frame 17)
		{x = 0,    y = 235, width = 50,  height = 64,  offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 3: end
		-- green hold piece (frame 18)
		{x = 50,   y = 235, width = 50,  height = 44,  offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 4: hold
		-- up confirm 0000..0003 (frames 80-83)
		{x = 522,  y = 466, width = 236, height = 232, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 5: confirm0
		{x = 758,  y = 466, width = 236, height = 232, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 6: confirm1
		{x = 994,  y = 466, width = 236, height = 232, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 7: confirm2
		{x = 994,  y = 466, width = 236, height = 232, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 8: confirm3
		-- up press 0000..0003 (frames 84-87)
		{x = 1230, y = 466, width = 153, height = 150, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 9:  press0
		{x = 1230, y = 466, width = 153, height = 150, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 10: press1
		{x = 1383, y = 466, width = 153, height = 150, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 11: press2
		{x = 1383, y = 466, width = 153, height = 150, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 12: press3
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
