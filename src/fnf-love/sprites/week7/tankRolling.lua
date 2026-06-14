return graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("week7/tankRolling")),
	{
		{x = 0, y = 0, width = 319, height = 328, offsetX = 0, offsetY = 0, offsetWidth = 319, offsetHeight = 328},     -- 1
		{x = 0, y = 332, width = 318, height = 325, offsetX = 1, offsetY = 3, offsetWidth = 319, offsetHeight = 328},   -- 2
		{x = 0, y = 661, width = 318, height = 325, offsetX = 1, offsetY = 3, offsetWidth = 319, offsetHeight = 328}    -- 3
	},
	{
		["anim"] = {start = 1, stop = 3, speed = 12, offsetX = 0, offsetY = 0}  -- velocidad más lenta para que parezca que rueda
	},
	"anim",
	false
)