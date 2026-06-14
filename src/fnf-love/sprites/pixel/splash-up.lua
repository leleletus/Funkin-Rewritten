local img = love.graphics.newImage(graphics.imagePath("pixel/pixelNoteSplash"))
img:setFilter("nearest", "nearest")
return graphics.newSprite(
    img,
    {
        {x = 96, y = 96, width = 48, height = 48, offsetX = 0, offsetY = 0, offsetWidth = 48, offsetHeight = 48},
        {x = 144, y = 96, width = 48, height = 48, offsetX = 0, offsetY = 0, offsetWidth = 48, offsetHeight = 48},
        {x = 192, y = 96, width = 48, height = 48, offsetX = 0, offsetY = 0, offsetWidth = 48, offsetHeight = 48},
        {x = 240, y = 96, width = 48, height = 48, offsetX = 0, offsetY = 0, offsetWidth = 48, offsetHeight = 48},
        {x = 288, y = 96, width = 48, height = 48, offsetX = 0, offsetY = 0, offsetWidth = 48, offsetHeight = 48},
        {x = 336, y = 96, width = 48, height = 48, offsetX = 0, offsetY = 0, offsetWidth = 48, offsetHeight = 48}
    },
    {
        ["splash"] = {start = 1, stop = 6, speed = 24, offsetX = 0, offsetY = 0}
    },
    "splash",
    false
)