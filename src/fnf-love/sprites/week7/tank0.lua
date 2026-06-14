return graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("week7/tank0")),
	{
		{x = 631, y = 457, width = 311, height = 437, offsetX = 3, offsetY = 13, offsetWidth = 314, offsetHeight = 450}, -- 1
		{x = 631, y = 457, width = 311, height = 437, offsetX = 3, offsetY = 13, offsetWidth = 314, offsetHeight = 450}, -- 2
		{x = 0, y = 460, width = 306, height = 440, offsetX = 3, offsetY = 10, offsetWidth = 314, offsetHeight = 450}, -- 3
		{x = 0, y = 460, width = 306, height = 440, offsetX = 3, offsetY = 10, offsetWidth = 314, offsetHeight = 450}, -- 4
		{x = 631, y = 0, width = 305, height = 447, offsetX = 2, offsetY = 3, offsetWidth = 314, offsetHeight = 450}, -- 5
		{x = 631, y = 0, width = 305, height = 447, offsetX = 2, offsetY = 3, offsetWidth = 314, offsetHeight = 450}, -- 6
		{x = 0, y = 0, width = 306, height = 450, offsetX = 1, offsetY = 0, offsetWidth = 314, offsetHeight = 450}, -- 7
		{x = 0, y = 0, width = 306, height = 450, offsetX = 1, offsetY = 0, offsetWidth = 314, offsetHeight = 450}, -- 8
		{x = 316, y = 0, width = 305, height = 450, offsetX = 0, offsetY = 0, offsetWidth = 314, offsetHeight = 450}, -- 9
		{x = 316, y = 0, width = 305, height = 450, offsetX = 0, offsetY = 0, offsetWidth = 314, offsetHeight = 450}, -- 10
		{x = 316, y = 0, width = 305, height = 450, offsetX = 0, offsetY = 0, offsetWidth = 314, offsetHeight = 450}, -- 11
		{x = 316, y = 0, width = 305, height = 450, offsetX = 0, offsetY = 0, offsetWidth = 314, offsetHeight = 450}, -- 12
		{x = 316, y = 0, width = 305, height = 450, offsetX = 0, offsetY = 0, offsetWidth = 314, offsetHeight = 450}, -- 13
		{x = 316, y = 0, width = 305, height = 450, offsetX = 0, offsetY = 0, offsetWidth = 314, offsetHeight = 450}  -- 14
	},
	{
		["anim"] = {start = 1, stop = 14, speed = 24, offsetX = 0, offsetY = 0}
	},
	"anim",
	false
)