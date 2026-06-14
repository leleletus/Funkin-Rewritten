return graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("week7/tank3")),
	{
		{x = 0, y = 422, width = 590, height = 124, offsetX = 0, offsetY = 11, offsetWidth = 590, offsetHeight = 135},  -- 1
		{x = 0, y = 422, width = 590, height = 124, offsetX = 0, offsetY = 11, offsetWidth = 590, offsetHeight = 135},  -- 2
		{x = 0, y = 286, width = 585, height = 126, offsetX = 2, offsetY = 9, offsetWidth = 590, offsetHeight = 135},   -- 3
		{x = 0, y = 286, width = 585, height = 126, offsetX = 2, offsetY = 9, offsetWidth = 590, offsetHeight = 135},   -- 4
		{x = 0, y = 145, width = 580, height = 131, offsetX = 5, offsetY = 4, offsetWidth = 590, offsetHeight = 135},   -- 5
		{x = 0, y = 145, width = 580, height = 131, offsetX = 5, offsetY = 4, offsetWidth = 590, offsetHeight = 135},   -- 6
		{x = 0, y = 0, width = 574, height = 135, offsetX = 9, offsetY = 0, offsetWidth = 590, offsetHeight = 135},     -- 7
		{x = 0, y = 0, width = 574, height = 135, offsetX = 9, offsetY = 0, offsetWidth = 590, offsetHeight = 135},     -- 8
		{x = 0, y = 0, width = 574, height = 135, offsetX = 9, offsetY = 0, offsetWidth = 590, offsetHeight = 135},     -- 9
		{x = 0, y = 0, width = 574, height = 135, offsetX = 9, offsetY = 0, offsetWidth = 590, offsetHeight = 135},     -- 10
		{x = 0, y = 0, width = 574, height = 135, offsetX = 9, offsetY = 0, offsetWidth = 590, offsetHeight = 135},     -- 11
		{x = 0, y = 0, width = 574, height = 135, offsetX = 9, offsetY = 0, offsetWidth = 590, offsetHeight = 135},     -- 12
		{x = 0, y = 0, width = 574, height = 135, offsetX = 9, offsetY = 0, offsetWidth = 590, offsetHeight = 135},     -- 13
		{x = 0, y = 0, width = 574, height = 135, offsetX = 9, offsetY = 0, offsetWidth = 590, offsetHeight = 135},     -- 14
		{x = 0, y = 0, width = 574, height = 135, offsetX = 9, offsetY = 0, offsetWidth = 590, offsetHeight = 135}      -- 15
	},
	{
		["anim"] = {start = 1, stop = 15, speed = 24, offsetX = 0, offsetY = 0}
	},
	"anim",
	false
)