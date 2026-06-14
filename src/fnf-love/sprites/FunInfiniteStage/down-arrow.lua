-- sprites/FunInfiniteStage/down-arrow.lua
-- Flechas del jugador con texturas de Majin_Notes (usado a partir del GO!)

return graphics.newSprite(
	images.notes,
	{
		-- arrowDOWN0000  (frame 1)
		{x = 0,    y = 0,   width = 157, height = 154, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 1: off
		-- blue0000       (frame 5)
		{x = 622,  y = 0,   width = 157, height = 154, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 2: on
		-- blue hold end  (frame 6)
		{x = 779,  y = 0,   width = 50,  height = 64,  offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 3: end
		-- blue hold piece(frame 7)
		{x = 829,  y = 0,   width = 50,  height = 44,  offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 4: hold
		-- down confirm 0000..0003 (frames 8-11)
		{x = 879,  y = 0,   width = 238, height = 235, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 5: confirm0
		{x = 1117, y = 0,   width = 238, height = 235, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 6: confirm1
		{x = 1355, y = 0,   width = 238, height = 235, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 7: confirm2
		{x = 1355, y = 0,   width = 238, height = 235, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 8: confirm3
		-- down press 0000..0003 (frames 12-15)
		{x = 1593, y = 0,   width = 149, height = 146, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 9:  press0
		{x = 1593, y = 0,   width = 149, height = 146, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 10: press1
		{x = 1742, y = 0,   width = 149, height = 146, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 11: press2
		{x = 1742, y = 0,   width = 149, height = 146, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 12: press3
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
