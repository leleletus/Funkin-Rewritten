-- sprites/FunInfiniteStage/right-arrow.lua
-- Flechas del jugador con texturas de Majin_Notes (usado a partir del GO!)

return graphics.newSprite(
	images.notes,
	{
		-- arrowRIGHT0000 (frame 3)
		{x = 311,  y = 0,   width = 154, height = 157, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 1: off
		-- red0000        (frame 46)
		{x = 1330, y = 235, width = 154, height = 157, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 2: on
		-- red hold end   (frame 47)
		{x = 1484, y = 235, width = 50,  height = 64,  offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 3: end
		-- red hold piece (frame 48)
		{x = 1534, y = 235, width = 50,  height = 44,  offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 4: hold
		-- right confirm 0000..0003 (frames 49-52)
		{x = 1584, y = 235, width = 226, height = 230, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 5: confirm0
		{x = 1810, y = 235, width = 226, height = 230, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 6: confirm1
		{x = 0,    y = 466, width = 226, height = 230, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 7: confirm2
		{x = 0,    y = 466, width = 226, height = 230, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 8: confirm3
		-- right press 0000..0003 (frames 53-56)
		{x = 226,  y = 466, width = 148, height = 151, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 9:  press0
		{x = 226,  y = 466, width = 148, height = 151, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 10: press1
		{x = 374,  y = 466, width = 148, height = 151, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 11: press2
		{x = 374,  y = 466, width = 148, height = 151, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 12: press3
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
