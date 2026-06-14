-- sprites/sonicJUMPSCARE.lua
return function()
    return graphics.newSprite(
        love.graphics.newImage(graphics.imagePath("sonicJUMPSCARE")),
        {
            {x = 0, y = 0, width = 1155, height = 1456, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 1
            {x = 1155, y = 0, width = 1155, height = 1456, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 2
            {x = 2310, y = 0, width = 1155, height = 1456, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 3
            {x = 3465, y = 0, width = 1155, height = 1456, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 4
            {x = 4620, y = 0, width = 1155, height = 1456, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 5
            {x = 5775, y = 0, width = 1155, height = 1456, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 6
            {x = 6930, y = 0, width = 1155, height = 1456, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 7
            {x = 0, y = 1456, width = 1155, height = 1456, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 8
            {x = 1155, y = 1456, width = 1155, height = 1456, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 9
            {x = 2310, y = 1456, width = 1155, height = 1456, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 10
            {x = 3465, y = 1456, width = 1155, height = 1456, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 11
            {x = 4620, y = 1456, width = 1155, height = 1456, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 12
            {x = 5775, y = 1456, width = 1155, height = 1456, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 13
            {x = 6930, y = 1456, width = 1155, height = 1456, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 14
            {x = 0, y = 2912, width = 1155, height = 1456, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 15
            {x = 1155, y = 2912, width = 1155, height = 1456, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 16
            {x = 2310, y = 2912, width = 1155, height = 1456, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 17
            {x = 4620, y = 1456, width = 1155, height = 1456, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 18 (duplicado, pero respeta el original)
            {x = 5775, y = 1456, width = 1155, height = 1456, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 19
            {x = 6930, y = 1456, width = 1155, height = 1456, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 20
            {x = 3465, y = 2912, width = 1155, height = 1456, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 21
            {x = 4620, y = 2912, width = 1155, height = 1456, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 22
            {x = 5775, y = 2912, width = 1155, height = 1456, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 23
            {x = 6930, y = 2912, width = 1155, height = 1456, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 24
            {x = 0, y = 4368, width = 1155, height = 1456, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 25
        },
        {
            ["sonicSPOOK"] = {start = 1, stop = 25, speed = 24, offsetX = 0, offsetY = 0}
        },
        "sonicSPOOK"
    )
end