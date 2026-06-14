local img = love.graphics.newImage(graphics.imagePath("pixel/pixelNoteSplash"))
img:setFilter("nearest", "nearest")
return graphics.newSprite(
    img,
    {
        {x = 0, y = 0, width = 48, height = 48, offsetX = 0, offsetY = 0, offsetWidth = 48, offsetHeight = 48},
        {x = 48, y = 0, width = 48, height = 48, offsetX = 0, offsetY = 0, offsetWidth = 48, offsetHeight = 48},
        {x = 96, y = 0, width = 48, height = 48, offsetX = 0, offsetY = 0, offsetWidth = 48, offsetHeight = 48},
        {x = 144, y = 0, width = 48, height = 48, offsetX = 0, offsetY = 0, offsetWidth = 48, offsetHeight = 48},
        {x = 192, y = 0, width = 48, height = 48, offsetX = 0, offsetY = 0, offsetWidth = 48, offsetHeight = 48},
        {x = 240, y = 0, width = 48, height = 48, offsetX = 0, offsetY = 0, offsetWidth = 48, offsetHeight = 48}
    },
    {
        ["splash"] = {start = 1, stop = 6, speed = 24, offsetX = 0, offsetY = 0}
    },
    "splash",
    false
)