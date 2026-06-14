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

local image = love.graphics.newImage(graphics.imagePath("week7/tankmanKilled1"))

local frames = {
    -- John Shot 100
    { x = 0, y = 2148, width = 750, height = 512, offsetX = 0, offsetY = -67, offsetWidth = 1044, offsetHeight = 622 }, -- 1
    { x = 2708, y = 2101, width = 807, height = 615, offsetX = -105, offsetY = 0, offsetWidth = 1044, offsetHeight = 622 }, -- 2
    { x = 1808, y = 2139, width = 814, height = 601, offsetX = -98, offsetY = -14, offsetWidth = 1044, offsetHeight = 622 }, -- 3
    { x = 3227, y = 624, width = 840, height = 605, offsetX = -152, offsetY = -13, offsetWidth = 1044, offsetHeight = 622 }, -- 4
    { x = 1808, y = 1556, width = 896, height = 579, offsetX = -96, offsetY = -39, offsetWidth = 1044, offsetHeight = 622 }, -- 5
    { x = 3141, y = 0, width = 914, height = 620, offsetX = -130, offsetY = 0, offsetWidth = 1044, offsetHeight = 622 }, -- 6
    { x = 2708, y = 1556, width = 935, height = 541, offsetX = -109, offsetY = -79, offsetWidth = 1044, offsetHeight = 622 }, -- 7
    { x = 3647, y = 1233, width = 426, height = 608, offsetX = -220, offsetY = -14, offsetWidth = 1044, offsetHeight = 622 }, -- 8
    { x = 3519, y = 2101, width = 534, height = 466, offsetX = -112, offsetY = -156, offsetWidth = 1044, offsetHeight = 622 }, -- 9
    { x = 3519, y = 2571, width = 521, height = 466, offsetX = -125, offsetY = -156, offsetWidth = 1044, offsetHeight = 622 }, -- 10
    { x = 3519, y = 2571, width = 521, height = 466, offsetX = -125, offsetY = -156, offsetWidth = 1044, offsetHeight = 622 }, -- 11
    { x = 2626, y = 2720, width = 459, height = 490, offsetX = -187, offsetY = -132, offsetWidth = 1044, offsetHeight = 622 }, -- 12
    { x = 0, y = 0, width = 1, height = 1, offsetX = -49, offsetY = -265, offsetWidth = 1044, offsetHeight = 622 }, -- 13
    { x = 2626, y = 2720, width = 459, height = 490, offsetX = -187, offsetY = -132, offsetWidth = 1044, offsetHeight = 622 }, -- 14
    { x = 0, y = 0, width = 1, height = 1, offsetX = -49, offsetY = -265, offsetWidth = 1044, offsetHeight = 622 }, -- 15
    { x = 2626, y = 2720, width = 459, height = 490, offsetX = -187, offsetY = -132, offsetWidth = 1044, offsetHeight = 622 }, -- 16
    { x = 0, y = 0, width = 1, height = 1, offsetX = -49, offsetY = -265, offsetWidth = 1044, offsetHeight = 622 }, -- 17
    { x = 2626, y = 2720, width = 459, height = 490, offsetX = -187, offsetY = -132, offsetWidth = 1044, offsetHeight = 622 }, -- 18
    { x = 0, y = 0, width = 1, height = 1, offsetX = -49, offsetY = -265, offsetWidth = 1044, offsetHeight = 622 }, -- 19
    { x = 0, y = 0, width = 1, height = 1, offsetX = -49, offsetY = -265, offsetWidth = 1044, offsetHeight = 622 }, -- 20
    -- John Shot 200
    { x = 0, y = 2664, width = 597, height = 429, offsetX = -243, offsetY = -212, offsetWidth = 1221, offsetHeight = 828 }, -- 21
    { x = 0, y = 1518, width = 885, height = 626, offsetX = -215, offsetY = -48, offsetWidth = 1221, offsetHeight = 828 }, -- 22
    { x = 889, y = 1556, width = 915, height = 592, offsetX = -185, offsetY = -82, offsetWidth = 1221, offsetHeight = 828 }, -- 23
    { x = 1109, y = 832, width = 1055, height = 720, offsetX = -148, offsetY = -66, offsetWidth = 1221, offsetHeight = 828 }, -- 24
    { x = 2168, y = 832, width = 1055, height = 720, offsetX = -148, offsetY = -66, offsetWidth = 1221, offsetHeight = 828 }, -- 25
    { x = 2130, y = 0, width = 1007, height = 828, offsetX = -201, offsetY = 0, offsetWidth = 1221, offsetHeight = 828 }, -- 26
    { x = 1117, y = 0, width = 1009, height = 828, offsetX = -199, offsetY = 0, offsetWidth = 1221, offsetHeight = 828 }, -- 27
    { x = 0, y = 768, width = 1105, height = 746, offsetX = -108, offsetY = -44, offsetWidth = 1221, offsetHeight = 828 }, -- 28
    { x = 0, y = 0, width = 1113, height = 764, offsetX = -108, offsetY = -44, offsetWidth = 1221, offsetHeight = 828 }, -- 29
    { x = 754, y = 2152, width = 768, height = 491, offsetX = -13, offsetY = -179, offsetWidth = 1221, offsetHeight = 828 }, -- 30
    { x = 754, y = 2152, width = 768, height = 491, offsetX = -13, offsetY = -179, offsetWidth = 1221, offsetHeight = 828 }, -- 31
    { x = 754, y = 2647, width = 781, height = 461, offsetX = 0, offsetY = -209, offsetWidth = 1221, offsetHeight = 828 }, -- 32
    { x = 0, y = 0, width = 1, height = 1, offsetX = -123, offsetY = -327, offsetWidth = 1221, offsetHeight = 828 }, -- 33
    { x = 754, y = 2647, width = 781, height = 461, offsetX = 0, offsetY = -209, offsetWidth = 1221, offsetHeight = 828 }, -- 34
    { x = 0, y = 0, width = 1, height = 1, offsetX = -123, offsetY = -327, offsetWidth = 1221, offsetHeight = 828 }, -- 35
    { x = 754, y = 2647, width = 781, height = 461, offsetX = 0, offsetY = -209, offsetWidth = 1221, offsetHeight = 828 }, -- 36
    { x = 0, y = 0, width = 1, height = 1, offsetX = -123, offsetY = -327, offsetWidth = 1221, offsetHeight = 828 }, -- 37
    { x = 754, y = 2647, width = 781, height = 461, offsetX = 0, offsetY = -209, offsetWidth = 1221, offsetHeight = 828 }, -- 38
    { x = 0, y = 0, width = 1, height = 1, offsetX = -123, offsetY = -327, offsetWidth = 1221, offsetHeight = 828 }, -- 39
    -- tankman running
    { x = 2045, y = 2744, width = 503, height = 412, offsetX = 0, offsetY = -10, offsetWidth = 505, offsetHeight = 478 }, -- 40
    { x = 2045, y = 2744, width = 503, height = 412, offsetX = 0, offsetY = -10, offsetWidth = 505, offsetHeight = 478 }, -- 41
    { x = 2045, y = 2744, width = 503, height = 412, offsetX = 0, offsetY = -10, offsetWidth = 505, offsetHeight = 478 }, -- 42
    { x = 1539, y = 2744, width = 502, height = 417, offsetX = -3, offsetY = -11, offsetWidth = 505, offsetHeight = 478 }, -- 43
    { x = 1539, y = 2744, width = 502, height = 417, offsetX = -3, offsetY = -11, offsetWidth = 505, offsetHeight = 478 }, -- 44
    { x = 3089, y = 3041, width = 434, height = 426, offsetX = -8, offsetY = -50, offsetWidth = 505, offsetHeight = 478 }, -- 45
    { x = 3089, y = 3041, width = 434, height = 426, offsetX = -8, offsetY = -50, offsetWidth = 505, offsetHeight = 478 }, -- 46
    { x = 0, y = 3097, width = 358, height = 428, offsetX = -116, offsetY = 0, offsetWidth = 505, offsetHeight = 478 }, -- 47
    { x = 0, y = 3097, width = 358, height = 428, offsetX = -116, offsetY = 0, offsetWidth = 505, offsetHeight = 478 }, -- 48
    { x = 0, y = 3097, width = 358, height = 428, offsetX = -116, offsetY = 0, offsetWidth = 505, offsetHeight = 478 }, -- 49
    { x = 3527, y = 3041, width = 366, height = 426, offsetX = -105, offsetY = -7, offsetWidth = 505, offsetHeight = 478 }, -- 50
    { x = 3527, y = 3041, width = 366, height = 426, offsetX = -105, offsetY = -7, offsetWidth = 505, offsetHeight = 478 }, -- 51
    { x = 1526, y = 2152, width = 262, height = 415, offsetX = -144, offsetY = -63, offsetWidth = 505, offsetHeight = 478 }, -- 52
    { x = 1526, y = 2152, width = 262, height = 415, offsetX = -144, offsetY = -63, offsetWidth = 505, offsetHeight = 478 }  -- 53
}

local animations = {
    shot1 = { start = 1, stop = 20, speed = 24, offsetX = -100, offsetY = 100 },
    shot2 = { start = 21, stop = 39, speed = 24, offsetX = -40, offsetY = 40 },
    running = { start = 40, stop = 53, speed = 24, offsetX = 0, offsetY = 0 }
}

-- Devolvemos una FUNCIÓN constructora en lugar de una instancia directa
return function()
    local sprite = graphics.newSprite(image, frames, animations, "running", false)
    -- Agregar método isAnimFinished
    sprite.isAnimFinished = function(self)
        return self.anim and self.anim.finished or false
    end
    return sprite
end