return graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("week7/tank1")),
	{
		{x = 0, y = 388, width = 472, height = 113, offsetX = 0, offsetY = 9, offsetWidth = 472, offsetHeight = 122},   -- 1
		{x = 0, y = 388, width = 472, height = 113, offsetX = 0, offsetY = 9, offsetWidth = 472, offsetHeight = 122},   -- 2
		{x = 0, y = 262, width = 468, height = 116, offsetX = 2, offsetY = 6, offsetWidth = 472, offsetHeight = 122},   -- 3
		{x = 0, y = 262, width = 468, height = 116, offsetX = 2, offsetY = 6, offsetWidth = 472, offsetHeight = 122},   -- 4
		{x = 0, y = 132, width = 460, height = 120, offsetX = 6, offsetY = 2, offsetWidth = 472, offsetHeight = 122},   -- 5
		{x = 0, y = 132, width = 460, height = 120, offsetX = 6, offsetY = 2, offsetWidth = 472, offsetHeight = 122},   -- 6
		{x = 0, y = 0, width = 459, height = 122, offsetX = 6, offsetY = 0, offsetWidth = 472, offsetHeight = 122},     -- 7
		{x = 0, y = 0, width = 459, height = 122, offsetX = 6, offsetY = 0, offsetWidth = 472, offsetHeight = 122},     -- 8
		{x = 0, y = 0, width = 459, height = 122, offsetX = 6, offsetY = 0, offsetWidth = 472, offsetHeight = 122},     -- 9
		{x = 0, y = 0, width = 459, height = 122, offsetX = 6, offsetY = 0, offsetWidth = 472, offsetHeight = 122},     -- 10
		{x = 0, y = 0, width = 459, height = 122, offsetX = 6, offsetY = 0, offsetWidth = 472, offsetHeight = 122},     -- 11
		{x = 0, y = 0, width = 459, height = 122, offsetX = 6, offsetY = 0, offsetWidth = 472, offsetHeight = 122},     -- 12
		{x = 0, y = 0, width = 459, height = 122, offsetX = 6, offsetY = 0, offsetWidth = 472, offsetHeight = 122},     -- 13
		{x = 0, y = 0, width = 459, height = 122, offsetX = 6, offsetY = 0, offsetWidth = 472, offsetHeight = 122},     -- 14
		{x = 0, y = 0, width = 459, height = 122, offsetX = 6, offsetY = 0, offsetWidth = 472, offsetHeight = 122}      -- 15
	},
	{
		["anim"] = {start = 1, stop = 15, speed = 24, offsetX = 0, offsetY = 0}
	},
	"anim",
	false
)