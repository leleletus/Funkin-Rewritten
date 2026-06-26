return graphics.newSprite(
    love.graphics.newImage(graphics.imagePath("holdCoverBlue")),
    {
        -- start
        {x = 413, y = 96, width = 93, height = 93, offsetX = -111, offsetY = -107, offsetWidth = 300, offsetHeight = 400, rotated = false},
        -- loop
        {x = 407, y = 242, width = 108, height = 138, offsetX = -94, offsetY = -94, offsetWidth = 300, offsetHeight = 400, rotated = true},
        {x = 413, y = 0, width = 120, height = 96, offsetX = -100, offsetY = -104, offsetWidth = 300, offsetHeight = 400, rotated = false},
        {x = 506, y = 96, width = 93, height = 80, offsetX = -115, offsetY = -107, offsetWidth = 300, offsetHeight = 400, rotated = false},
        {x = 146, y = 423, width = 36, height = 78, offsetX = -122, offsetY = -133, offsetWidth = 300, offsetHeight = 400, rotated = true},
        -- end
        {x = 146, y = 423, width = 36, height = 78, offsetX = -122, offsetY = -133, offsetWidth = 300, offsetHeight = 400, rotated = true}, -- end0001
        {x = 0, y = 423, width = 146, height = 168, offsetX = -72, offsetY = -59, offsetWidth = 300, offsetHeight = 400, rotated = true},   -- end0002
        {x = 192, y = 242, width = 215, height = 185, offsetX = -47, offsetY = -55, offsetWidth = 300, offsetHeight = 400, rotated = false}, -- end0003
        {x = 192, y = 242, width = 215, height = 185, offsetX = -47, offsetY = -55, offsetWidth = 300, offsetHeight = 400, rotated = false}, -- end0004
        {x = 0, y = 193, width = 192, height = 230, offsetX = -44, offsetY = -62, offsetWidth = 300, offsetHeight = 400, rotated = true},   -- end0005
        {x = 0, y = 0, width = 246, height = 193, offsetX = -43, offsetY = -78, offsetWidth = 300, offsetHeight = 400, rotated = false},    -- end0006
        {x = 246, y = 0, width = 167, height = 242, offsetX = -53, offsetY = -113, offsetWidth = 300, offsetHeight = 400, rotated = true},  -- end0007
        {x = 246, y = 0, width = 167, height = 242, offsetX = -53, offsetY = -113, offsetWidth = 300, offsetHeight = 400, rotated = true},  -- end0008
    },
    {
        ["start"] = {start = 1, stop = 1, speed = 24, offsetX = 6, offsetY = -36},
        ["loop"]  = {start = 2, stop = 5, speed = 24, offsetX = 6, offsetY = -36},
        ["end"]   = {start = 6, stop = 13, speed = 24, offsetX = 6, offsetY = -36}
    },
    "start",
    false
)