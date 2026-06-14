--[[----------------------------------------------------------------------------
... (licencia)
------------------------------------------------------------------------------]]
return graphics.newSprite(
    images.noteSplashes,
    {
        {x = 1850, y = 262, width = 189, height = 270, offsetX = -32, offsetY = -12, offsetWidth = 260, offsetHeight = 298}, -- 1: note impact 1 blue0000
        {x = 1540, y = 556, width = 213, height = 265, offsetX = -27, offsetY = -22, offsetWidth = 260, offsetHeight = 298}, -- 2: note impact 1 blue0001
        {x = 1056, y = 0, width = 252, height = 291, offsetX = -4, offsetY = -6, offsetWidth = 260, offsetHeight = 298}, -- 3: note impact 1 blue0002
        {x = 0, y = 0, width = 260, height = 298, offsetX = 0, offsetY = 0, offsetWidth = 260, offsetHeight = 298} -- 4: note impact 1 blue0003
    },
    {
        ["splash"] = {start = 1, stop = 4, speed = 24, offsetX = 0, offsetY = 0}
    },
    "splash",
    false
)