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

-- Cargamos la imagen una sola vez (para eficiencia)
local image = love.graphics.newImage(graphics.imagePath("checkboxThingie"))

-- Definimos los frames (originales + duplicados para la animación inversa)
local frames = {
    -- Frames originales (1-14)
    {x = 0, y = 198, width = 120, height = 174, offsetX = 0, offsetY = 0, offsetWidth = 140, offsetHeight = 225}, -- 1
    {x = 0, y = 198, width = 120, height = 174, offsetX = 0, offsetY = 0, offsetWidth = 140, offsetHeight = 225}, -- 2
    {x = 371, y = 0, width = 121, height = 82, offsetX = -15, offsetY = -133, offsetWidth = 140, offsetHeight = 225}, -- 3
    {x = 371, y = 0, width = 121, height = 82, offsetX = -15, offsetY = -133, offsetWidth = 140, offsetHeight = 225}, -- 4
    {x = 132, y = 0, width = 127, height = 180, offsetX = -4, offsetY = -45, offsetWidth = 140, offsetHeight = 225}, -- 5
    {x = 0, y = 0, width = 127, height = 193, offsetX = 0, offsetY = 0, offsetWidth = 140, offsetHeight = 225}, -- 6
    {x = 0, y = 0, width = 127, height = 193, offsetX = 0, offsetY = 0, offsetWidth = 140, offsetHeight = 225}, -- 7
    {x = 257, y = 185, width = 138, height = 146, offsetX = -2, offsetY = -62, offsetWidth = 140, offsetHeight = 225}, -- 8
    {x = 257, y = 185, width = 138, height = 146, offsetX = -2, offsetY = -62, offsetWidth = 140, offsetHeight = 225}, -- 9
    {x = 132, y = 185, width = 120, height = 176, offsetX = -12, offsetY = -29, offsetWidth = 140, offsetHeight = 225}, -- 10
    {x = 132, y = 185, width = 120, height = 176, offsetX = -12, offsetY = -29, offsetWidth = 140, offsetHeight = 225}, -- 11
    {x = 0, y = 198, width = 120, height = 174, offsetX = -12, offsetY = -29, offsetWidth = 140, offsetHeight = 225}, -- 12
    {x = 0, y = 198, width = 120, height = 174, offsetX = -12, offsetY = -29, offsetWidth = 140, offsetHeight = 225}, -- 13
    {x = 264, y = 0, width = 102, height = 103, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 14

    -- Frames duplicados para la animación inversa (15-25) en orden ascendente
    {x = 0, y = 198, width = 120, height = 174, offsetX = -12, offsetY = -29, offsetWidth = 140, offsetHeight = 225}, -- 15 (copia del 13)
    {x = 0, y = 198, width = 120, height = 174, offsetX = -12, offsetY = -29, offsetWidth = 140, offsetHeight = 225}, -- 16 (copia del 12)
    {x = 132, y = 185, width = 120, height = 176, offsetX = -12, offsetY = -29, offsetWidth = 140, offsetHeight = 225}, -- 17 (copia del 11)
    {x = 132, y = 185, width = 120, height = 176, offsetX = -12, offsetY = -29, offsetWidth = 140, offsetHeight = 225}, -- 18 (copia del 10)
    {x = 257, y = 185, width = 138, height = 146, offsetX = -2, offsetY = -62, offsetWidth = 140, offsetHeight = 225}, -- 19 (copia del 9)
    {x = 257, y = 185, width = 138, height = 146, offsetX = -2, offsetY = -62, offsetWidth = 140, offsetHeight = 225}, -- 20 (copia del 8)
    {x = 0, y = 0, width = 127, height = 193, offsetX = 0, offsetY = 0, offsetWidth = 140, offsetHeight = 225}, -- 21 (copia del 7)
    {x = 0, y = 0, width = 127, height = 193, offsetX = 0, offsetY = 0, offsetWidth = 140, offsetHeight = 225}, -- 22 (copia del 6)
    {x = 132, y = 0, width = 127, height = 180, offsetX = -4, offsetY = -45, offsetWidth = 140, offsetHeight = 225}, -- 23 (copia del 5)
    {x = 371, y = 0, width = 121, height = 82, offsetX = -15, offsetY = -133, offsetWidth = 140, offsetHeight = 225}, -- 24 (copia del 4)
    {x = 371, y = 0, width = 121, height = 82, offsetX = -15, offsetY = -133, offsetWidth = 140, offsetHeight = 225}, -- 25 (copia del 3)
}

-- Definimos las animaciones
local animations = {
    ["Check Box Selected Static"] = {start = 1, stop = 2, speed = 24, offsetX = -7, offsetY = 10},
    ["Check Box selecting animation"] = {start = 3, stop = 13, speed = 24, offsetX = 5, offsetY = 39},
    ["Check Box unselected"] = {start = 14, stop = 14, speed = 24, offsetX = 0, offsetY = 0},
    ["Check Box unselecting animation"] = {start = 15, stop = 25, speed = 24, offsetX = 5, offsetY = 39}, -- ahora en orden ascendente
}

-- Función generadora: devuelve un NUEVO sprite de checkbox
local function newCheckbox()
    return graphics.newSprite(image, frames, animations, "Check Box unselected")
end

return newCheckbox