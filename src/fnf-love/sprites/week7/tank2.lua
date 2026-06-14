return graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("week7/tank2")),
	{
		{x = 595, y = 327, width = 293, height = 305, offsetX = 2, offsetY = 17, offsetWidth = 295, offsetHeight = 322}, -- 1
		{x = 595, y = 327, width = 293, height = 305, offsetX = 2, offsetY = 17, offsetWidth = 295, offsetHeight = 322}, -- 2
		{x = 0, y = 331, width = 288, height = 310, offsetX = 4, offsetY = 12, offsetWidth = 295, offsetHeight = 322},   -- 3
		{x = 0, y = 331, width = 288, height = 310, offsetX = 4, offsetY = 12, offsetWidth = 295, offsetHeight = 322},   -- 4
		{x = 595, y = 0, width = 288, height = 317, offsetX = 1, offsetY = 5, offsetWidth = 295, offsetHeight = 322},    -- 5
		{x = 595, y = 0, width = 288, height = 317, offsetX = 1, offsetY = 5, offsetWidth = 295, offsetHeight = 322},    -- 6
		{x = 0, y = 0, width = 288, height = 321, offsetX = 0, offsetY = 1, offsetWidth = 295, offsetHeight = 322},      -- 7
		{x = 0, y = 0, width = 288, height = 321, offsetX = 0, offsetY = 1, offsetWidth = 295, offsetHeight = 322},      -- 8
		{x = 298, y = 0, width = 287, height = 322, offsetX = 0, offsetY = 0, offsetWidth = 295, offsetHeight = 322},    -- 9
		{x = 298, y = 0, width = 287, height = 322, offsetX = 0, offsetY = 0, offsetWidth = 295, offsetHeight = 322},    -- 10
		{x = 298, y = 0, width = 287, height = 322, offsetX = 0, offsetY = 0, offsetWidth = 295, offsetHeight = 322},    -- 11
		{x = 298, y = 0, width = 287, height = 322, offsetX = 0, offsetY = 0, offsetWidth = 295, offsetHeight = 322},    -- 12
		{x = 298, y = 0, width = 287, height = 322, offsetX = 0, offsetY = 0, offsetWidth = 295, offsetHeight = 322},    -- 13
		{x = 298, y = 0, width = 287, height = 322, offsetX = 0, offsetY = 0, offsetWidth = 295, offsetHeight = 322}     -- 14
	},
	{
		["anim"] = {start = 1, stop = 14, speed = 24, offsetX = 0, offsetY = 0}
	},
	"anim",
	false
)