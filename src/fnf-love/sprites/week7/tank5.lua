return graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("week7/tank5")),
	{
		{x = 633, y = 457, width = 312, height = 437, offsetX = 0, offsetY = 13, offsetWidth = 315, offsetHeight = 450}, -- 1
		{x = 633, y = 457, width = 312, height = 437, offsetX = 0, offsetY = 13, offsetWidth = 315, offsetHeight = 450}, -- 2
		{x = 0, y = 460, width = 307, height = 440, offsetX = 5, offsetY = 10, offsetWidth = 315, offsetHeight = 450},   -- 3
		{x = 0, y = 460, width = 307, height = 440, offsetX = 5, offsetY = 10, offsetWidth = 315, offsetHeight = 450},   -- 4
		{x = 633, y = 0, width = 306, height = 447, offsetX = 7, offsetY = 3, offsetWidth = 315, offsetHeight = 450},    -- 5
		{x = 633, y = 0, width = 306, height = 447, offsetX = 7, offsetY = 3, offsetWidth = 315, offsetHeight = 450},    -- 6
		{x = 0, y = 0, width = 307, height = 450, offsetX = 7, offsetY = 0, offsetWidth = 315, offsetHeight = 450},      -- 7
		{x = 0, y = 0, width = 307, height = 450, offsetX = 7, offsetY = 0, offsetWidth = 315, offsetHeight = 450},      -- 8
		{x = 317, y = 0, width = 306, height = 450, offsetX = 9, offsetY = 0, offsetWidth = 315, offsetHeight = 450},    -- 9
		{x = 317, y = 0, width = 306, height = 450, offsetX = 9, offsetY = 0, offsetWidth = 315, offsetHeight = 450},    -- 10
		{x = 317, y = 0, width = 306, height = 450, offsetX = 9, offsetY = 0, offsetWidth = 315, offsetHeight = 450},    -- 11
		{x = 317, y = 0, width = 306, height = 450, offsetX = 9, offsetY = 0, offsetWidth = 315, offsetHeight = 450},    -- 12
		{x = 317, y = 0, width = 306, height = 450, offsetX = 9, offsetY = 0, offsetWidth = 315, offsetHeight = 450},    -- 13
		{x = 317, y = 0, width = 306, height = 450, offsetX = 9, offsetY = 0, offsetWidth = 315, offsetHeight = 450}     -- 14
	},
	{
		["anim"] = {start = 1, stop = 14, speed = 24, offsetX = 0, offsetY = 0}
	},
	"anim",
	false
)