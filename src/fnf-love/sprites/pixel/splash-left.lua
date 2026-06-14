local img = love.graphics.newImage(graphics.imagePath("pixel/pixelNoteSplash"))
img:setFilter("nearest", "nearest")
return graphics.newSprite(
    img,
    {
        {x = 192, y = 192, width = 48, height = 48, offsetX = 0, offsetY = 0, offsetWidth = 48, offsetHeight = 48},
        {x = 240, y = 192, width = 48, height = 48, offsetX = 0, offsetY = 0, offsetWidth = 48, offsetHeight = 48},
        {x = 288, y = 192, width = 48, height = 48, offsetX = 0, offsetY = 0, offsetWidth = 48, offsetHeight = 48},
        {x = 336, y = 192, width = 48, height = 48, offsetX = 0, offsetY = 0, offsetWidth = 48, offsetHeight = 48},
        {x = 384, y = 192, width = 48, height = 48, offsetX = 0, offsetY = 0, offsetWidth = 48, offsetHeight = 48},
        {x = 0, y = 240, width = 48, height = 48, offsetX = 0, offsetY = 0, offsetWidth = 48, offsetHeight = 48}
    },
    {
        ["splash"] = {start = 1, stop = 6, speed = 24, offsetX = 0, offsetY = 0}
    },
    "splash",
    false
)