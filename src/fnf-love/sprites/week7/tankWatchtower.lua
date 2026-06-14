return graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("week7/tankWatchtower")),
	{
		{x = 0, y = 0, width = 369, height = 679, offsetX = 0, offsetY = 3, offsetWidth = 369, offsetHeight = 682},      -- 1
		{x = 0, y = 0, width = 369, height = 679, offsetX = 0, offsetY = 3, offsetWidth = 369, offsetHeight = 682},      -- 2
		{x = 373, y = 0, width = 367, height = 680, offsetX = 1, offsetY = 2, offsetWidth = 369, offsetHeight = 682},    -- 3
		{x = 373, y = 0, width = 367, height = 680, offsetX = 1, offsetY = 2, offsetWidth = 369, offsetHeight = 682},    -- 4
		{x = 744, y = 0, width = 365, height = 682, offsetX = 2, offsetY = 0, offsetWidth = 369, offsetHeight = 682},    -- 5
		{x = 744, y = 0, width = 365, height = 682, offsetX = 2, offsetY = 0, offsetWidth = 369, offsetHeight = 682},    -- 6
		{x = 744, y = 0, width = 365, height = 682, offsetX = 2, offsetY = 0, offsetWidth = 369, offsetHeight = 682},    -- 7
		{x = 1113, y = 0, width = 365, height = 682, offsetX = 2, offsetY = 0, offsetWidth = 369, offsetHeight = 682},   -- 8
		{x = 1113, y = 0, width = 365, height = 682, offsetX = 2, offsetY = 0, offsetWidth = 369, offsetHeight = 682},   -- 9
		{x = 1113, y = 0, width = 365, height = 682, offsetX = 2, offsetY = 0, offsetWidth = 369, offsetHeight = 682},   -- 10
		{x = 1113, y = 0, width = 365, height = 682, offsetX = 2, offsetY = 0, offsetWidth = 369, offsetHeight = 682},   -- 11
		{x = 1113, y = 0, width = 365, height = 682, offsetX = 2, offsetY = 0, offsetWidth = 369, offsetHeight = 682},   -- 12
		{x = 1113, y = 0, width = 365, height = 682, offsetX = 2, offsetY = 0, offsetWidth = 369, offsetHeight = 682},   -- 13
		{x = 1113, y = 0, width = 365, height = 682, offsetX = 2, offsetY = 0, offsetWidth = 369, offsetHeight = 682}    -- 14
	},
	{
		["anim"] = {start = 1, stop = 14, speed = 24, offsetX = 0, offsetY = 0}
	},
	"anim",
	false
)