--[[----------------------------------------------------------------------------
This file is part of Friday Night Funkin' Rewritten

Copyright (C) 2021  HTV04

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
------------------------------------------------------------------------------]]

return function()
    return graphics.newSprite(
        love.graphics.newImage(graphics.imagePath("daSTAT")),
        {
            {x = 0, y = 0, width = 402, height = 299, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 1
            {x = 402, y = 0, width = 402, height = 299, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 2
            {x = 0, y = 299, width = 402, height = 299, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 3
            {x = 402, y = 299, width = 402, height = 299, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 4
        },
        {
            ["staticFLASH"] = {start = 1, stop = 4, speed = 24, offsetX = 0, offsetY = 0}
        },
        "staticFLASH"
    )
end