-- screenstatic.lua modificado: devuelve una función constructora
return function()
    local static = graphics.newSprite(
        love.graphics.newImage(graphics.imagePath("screenstatic")),
        {
            {x = 0, y = 0, width = 1280, height = 720, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 1
            {x = 1280, y = 0, width = 1280, height = 720, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 2
            {x = 2560, y = 0, width = 1280, height = 720, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 3
            {x = 0, y = 720, width = 1280, height = 720, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 4
            {x = 1280, y = 720, width = 1280, height = 720, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 5
            {x = 2560, y = 720, width = 1280, height = 720, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 6
        },
        {
            ["screenSTATIC"] = {start = 1, stop = 6, speed = 24, offsetX = 0, offsetY = 0}
        },
        "screenSTATIC"
    )
    return static
end