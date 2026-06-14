local img = love.graphics.newImage(graphics.imagePath("BF"))
img:setFilter("nearest", "nearest")

local BF = graphics.newSprite(
	img,
	{
		{x = 0, y = 0, width = 42, height = 46, offsetX = 0, offsetY = 0, offsetWidth = 42, offsetHeight = 46}, -- 1: BF idle dance0000
		{x = 42, y = 0, width = 42, height = 46, offsetX = 0, offsetY = 0, offsetWidth = 42, offsetHeight = 46}, -- 2: BF idle dance0001
		{x = 84, y = 0, width = 42, height = 46, offsetX = 0, offsetY = 0, offsetWidth = 42, offsetHeight = 46}, -- 3: BF idle dance0002
		{x = 126, y = 0, width = 42, height = 46, offsetX = 0, offsetY = 0, offsetWidth = 42, offsetHeight = 46}, -- 4: BF idle dance0003
		{x = 168, y = 0, width = 42, height = 46, offsetX = 0, offsetY = 0, offsetWidth = 42, offsetHeight = 46}, -- 5: BF idle dance0004
		{x = 210, y = 0, width = 42, height = 46, offsetX = 0, offsetY = 0, offsetWidth = 42, offsetHeight = 46}, -- 6: BF NOTE DOWN0000
		{x = 0, y = 46, width = 42, height = 46, offsetX = 0, offsetY = 0, offsetWidth = 42, offsetHeight = 46}, -- 7: BF NOTE DOWN0001
		{x = 42, y = 46, width = 42, height = 46, offsetX = 0, offsetY = 0, offsetWidth = 42, offsetHeight = 46}, -- 8: BF NOTE LEFT0000
		{x = 84, y = 46, width = 42, height = 46, offsetX = 0, offsetY = 0, offsetWidth = 42, offsetHeight = 46}, -- 9: BF NOTE LEFT0001
		{x = 126, y = 46, width = 42, height = 46, offsetX = 0, offsetY = 0, offsetWidth = 42, offsetHeight = 46}, -- 10: BF NOTE UP0000
		{x = 168, y = 46, width = 42, height = 46, offsetX = 0, offsetY = 0, offsetWidth = 42, offsetHeight = 46}, -- 11: BF NOTE UP0001
		{x = 210, y = 46, width = 42, height = 46, offsetX = 0, offsetY = 0, offsetWidth = 42, offsetHeight = 46}, -- 12: BF NOTE RIGHT0000
		{x = 0, y = 92, width = 42, height = 46, offsetX = 0, offsetY = 0, offsetWidth = 42, offsetHeight = 46}, -- 13: BF NOTE RIGHT0001
		{x = 42, y = 92, width = 42, height = 46, offsetX = 0, offsetY = 0, offsetWidth = 42, offsetHeight = 46}, -- 14: BF NOTE DOWN MISS0000
		{x = 84, y = 92, width = 42, height = 46, offsetX = 0, offsetY = 0, offsetWidth = 42, offsetHeight = 46}, -- 15: BF NOTE DOWN MISS0001
		{x = 126, y = 92, width = 42, height = 46, offsetX = 0, offsetY = 0, offsetWidth = 42, offsetHeight = 46}, -- 16: BF NOTE LEFT MISS0000
		{x = 168, y = 92, width = 42, height = 46, offsetX = 0, offsetY = 0, offsetWidth = 42, offsetHeight = 46}, -- 17: BF NOTE LEFT MISS0001
		{x = 210, y = 92, width = 42, height = 46, offsetX = 0, offsetY = 0, offsetWidth = 42, offsetHeight = 46}, -- 18: BF NOTE RIGHT MISS0000
		{x = 0, y = 138, width = 42, height = 46, offsetX = 0, offsetY = 0, offsetWidth = 42, offsetHeight = 46}, -- 19: BF NOTE RIGHT MISS0001
		{x = 42, y = 138, width = 42, height = 46, offsetX = 0, offsetY = 0, offsetWidth = 42, offsetHeight = 46}, -- 20: BF NOTE UP MISS0000
		{x = 84, y = 138, width = 42, height = 46, offsetX = 0, offsetY = 0, offsetWidth = 42, offsetHeight = 46}, -- 21: BF NOTE UP MISS0001
		{x = 126, y = 138, width = 43, height = 43, offsetX = 0, offsetY = 0, offsetWidth = 43, offsetHeight = 43}, -- 22: BF dies0000
		{x = 169, y = 138, width = 43, height = 43, offsetX = 0, offsetY = 0, offsetWidth = 43, offsetHeight = 43}, -- 23: BF dies0001
		{x = 212, y = 138, width = 43, height = 43, offsetX = 0, offsetY = 0, offsetWidth = 43, offsetHeight = 43}, -- 24: BF dies0002
		{x = 0, y = 184, width = 43, height = 43, offsetX = 0, offsetY = 0, offsetWidth = 43, offsetHeight = 43}, -- 25: BF dies0003
		{x = 43, y = 184, width = 43, height = 43, offsetX = 0, offsetY = 0, offsetWidth = 43, offsetHeight = 43}, -- 26: BF dies0004
		{x = 86, y = 184, width = 43, height = 43, offsetX = 0, offsetY = 0, offsetWidth = 43, offsetHeight = 43}, -- 27: BF dies0005
		{x = 129, y = 184, width = 43, height = 43, offsetX = 0, offsetY = 0, offsetWidth = 43, offsetHeight = 43}, -- 28: BF dies0006
		{x = 172, y = 184, width = 43, height = 43, offsetX = 0, offsetY = 0, offsetWidth = 43, offsetHeight = 43}, -- 29: BF dies0007
		{x = 215, y = 184, width = 43, height = 43, offsetX = 0, offsetY = 0, offsetWidth = 43, offsetHeight = 43}, -- 30: BF dies0008
		{x = 0, y = 227, width = 43, height = 43, offsetX = 0, offsetY = 0, offsetWidth = 43, offsetHeight = 43}, -- 31: BF dies0009
		{x = 43, y = 227, width = 43, height = 43, offsetX = 0, offsetY = 0, offsetWidth = 43, offsetHeight = 43}, -- 32: BF dies0010
		{x = 86, y = 227, width = 43, height = 43, offsetX = 0, offsetY = 0, offsetWidth = 43, offsetHeight = 43}, -- 33: BF dies0011
		{x = 129, y = 227, width = 43, height = 43, offsetX = 0, offsetY = 0, offsetWidth = 43, offsetHeight = 43}, -- 34: BF dies0012
		{x = 172, y = 227, width = 43, height = 43, offsetX = 0, offsetY = 0, offsetWidth = 43, offsetHeight = 43}, -- 35: BF dies0013
		{x = 215, y = 227, width = 43, height = 43, offsetX = 0, offsetY = 0, offsetWidth = 43, offsetHeight = 43}, -- 36: BF dies0014
		{x = 0, y = 270, width = 43, height = 43, offsetX = 0, offsetY = 0, offsetWidth = 43, offsetHeight = 43}, -- 37: BF dies0015
		{x = 43, y = 270, width = 43, height = 43, offsetX = 0, offsetY = 0, offsetWidth = 43, offsetHeight = 43}, -- 38: BF Dead Loop0000
		{x = 86, y = 270, width = 43, height = 43, offsetX = 0, offsetY = 0, offsetWidth = 43, offsetHeight = 43}, -- 39: BF Dead Loop0001
		{x = 129, y = 270, width = 43, height = 43, offsetX = 0, offsetY = 0, offsetWidth = 43, offsetHeight = 43}, -- 40: BF Dead Loop0002
		{x = 172, y = 270, width = 43, height = 43, offsetX = 0, offsetY = 0, offsetWidth = 43, offsetHeight = 43}, -- 41: BF Dead Loop0003
		{x = 215, y = 270, width = 43, height = 43, offsetX = 0, offsetY = 0, offsetWidth = 43, offsetHeight = 43}, -- 42: BF Dead Loop0004
		{x = 0, y = 313, width = 43, height = 43, offsetX = 0, offsetY = 0, offsetWidth = 43, offsetHeight = 43}, -- 43: BF Dead Loop0005
	},
	{
		["dead"] = {start = 38, stop = 43, speed = 24, offsetX = 5, offsetY = -2},
		["dead confirm"] = {start = 10, stop = 11, speed = 24, offsetX = 0, offsetY = 1},
		["dies"] = {start = 22, stop = 37, speed = 24, offsetX = 5, offsetY = -2},
		["down"] = {start = 6, stop = 7, speed = 24, offsetX = 0, offsetY = 0},
		["idle"] = {start = 1, stop = 5, speed = 12, offsetX = 2, offsetY = 1},
		["left"] = {start = 8, stop = 9, speed = 24, offsetX = 0, offsetY = 0},
		["miss down"] = {start = 14, stop = 15, speed = 24, offsetX = 0, offsetY = 0},
		["miss left"] = {start = 16, stop = 17, speed = 24, offsetX = 0, offsetY = 0},
		["miss right"] = {start = 18, stop = 19, speed = 24, offsetX = 0, offsetY = 0},
		["miss up"] = {start = 20, stop = 21, speed = 24, offsetX = 0, offsetY = 0},
		["right"] = {start = 12, stop = 13, speed = 24, offsetX = 0, offsetY = 0},
		["up"] = {start = 10, stop = 11, speed = 24, offsetX = 0, offsetY = 0}
	},
	"idle"
)

return BF