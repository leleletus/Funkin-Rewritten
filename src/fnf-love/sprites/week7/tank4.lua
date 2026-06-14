return graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("week7/tank4")),
	{
		{x = 0, y = 0, width = 399, height = 319, offsetX = 0, offsetY = 11, offsetWidth = 401, offsetHeight = 330},    -- 1
		{x = 0, y = 0, width = 399, height = 319, offsetX = 0, offsetY = 11, offsetWidth = 401, offsetHeight = 330},    -- 2
		{x = 0, y = 329, width = 393, height = 322, offsetX = 4, offsetY = 8, offsetWidth = 401, offsetHeight = 330},   -- 3
		{x = 0, y = 329, width = 393, height = 322, offsetX = 4, offsetY = 8, offsetWidth = 401, offsetHeight = 330},   -- 4
		{x = 403, y = 329, width = 391, height = 320, offsetX = 8, offsetY = 4, offsetWidth = 401, offsetHeight = 330}, -- 5
		{x = 403, y = 329, width = 391, height = 320, offsetX = 8, offsetY = 4, offsetWidth = 401, offsetHeight = 330}, -- 6
		{x = 403, y = 659, width = 390, height = 320, offsetX = 10, offsetY = 1, offsetWidth = 401, offsetHeight = 330},-- 7
		{x = 403, y = 659, width = 390, height = 320, offsetX = 10, offsetY = 1, offsetWidth = 401, offsetHeight = 330},-- 8
		{x = 0, y = 661, width = 390, height = 319, offsetX = 11, offsetY = 0, offsetWidth = 401, offsetHeight = 330},  -- 9
		{x = 0, y = 661, width = 390, height = 319, offsetX = 11, offsetY = 0, offsetWidth = 401, offsetHeight = 330},  -- 10
		{x = 0, y = 661, width = 390, height = 319, offsetX = 11, offsetY = 0, offsetWidth = 401, offsetHeight = 330},  -- 11
		{x = 0, y = 661, width = 390, height = 319, offsetX = 11, offsetY = 0, offsetWidth = 401, offsetHeight = 330},  -- 12
		{x = 0, y = 661, width = 390, height = 319, offsetX = 11, offsetY = 0, offsetWidth = 401, offsetHeight = 330},  -- 13
		{x = 0, y = 661, width = 390, height = 319, offsetX = 11, offsetY = 0, offsetWidth = 401, offsetHeight = 330}   -- 14
	},
	{
		["anim"] = {start = 1, stop = 14, speed = 24, offsetX = 0, offsetY = 0}
	},
	"anim",
	false
)