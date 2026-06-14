local img = love.graphics.newImage(graphics.imagePath("pixel/pixelNoteHoldCover"))
img:setFilter("nearest", "nearest")
return graphics.newSprite(
    img,
    {
        -- loop frames
        {x = 0, y = 0, width = 36, height = 32, offsetX = 56, offsetY = 10, offsetWidth = 200, offsetHeight = 59},
        {x = 36, y = 0, width = 36, height = 32, offsetX = 56, offsetY = 10, offsetWidth = 200, offsetHeight = 59},
        {x = 72, y = 0, width = 36, height = 32, offsetX = 56, offsetY = 10, offsetWidth = 200, offsetHeight = 59},
        {x = 108, y = 0, width = 36, height = 32, offsetX = 56, offsetY = 10, offsetWidth = 200, offsetHeight = 59},
        {x = 0, y = 32, width = 36, height = 32, offsetX = 56, offsetY = 10, offsetWidth = 200, offsetHeight = 59},
        {x = 36, y = 32, width = 36, height = 32, offsetX = 56, offsetY = 10, offsetWidth = 200, offsetHeight = 59},
        {x = 72, y = 32, width = 36, height = 32, offsetX = 56, offsetY = 10, offsetWidth = 200, offsetHeight = 59},
        {x = 108, y = 32, width = 36, height = 32, offsetX = 56, offsetY = 10, offsetWidth = 200, offsetHeight = 59},
        -- explode frames
        {x = 0, y = 64, width = 36, height = 32, offsetX = 56, offsetY = 10, offsetWidth = 200, offsetHeight = 59},
        {x = 36, y = 64, width = 36, height = 32, offsetX = 56, offsetY = 10, offsetWidth = 200, offsetHeight = 59},
        {x = 72, y = 64, width = 36, height = 32, offsetX = 56, offsetY = 10, offsetWidth = 200, offsetHeight = 59},
        {x = 108, y = 64, width = 36, height = 32, offsetX = 56, offsetY = 10, offsetWidth = 200, offsetHeight = 59},
        {x = 0, y = 96, width = 36, height = 32, offsetX = 56, offsetY = 10, offsetWidth = 200, offsetHeight = 59},
        {x = 36, y = 96, width = 36, height = 32, offsetX = 56, offsetY = 10, offsetWidth = 200, offsetHeight = 59},
        {x = 72, y = 96, width = 36, height = 32, offsetX = 56, offsetY = 10, offsetWidth = 200, offsetHeight = 59},
        {x = 108, y = 96, width = 36, height = 32, offsetX = 56, offsetY = 10, offsetWidth = 200, offsetHeight = 59}
    },
    {
        ["start"] = {start = 1, stop = 1, speed = 24, offsetX = -140, offsetY = -20},
        ["loop"]  = {start = 1, stop = 8, speed = 24, offsetX = -140, offsetY = -20},
        ["end"]   = {start = 9, stop = 16, speed = 24, offsetX = -140, offsetY = -20}
    },
    "start",
    false
)