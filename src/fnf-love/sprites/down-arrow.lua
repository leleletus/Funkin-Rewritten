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

-- Frames leídos del atlas real de Psych Engine (notes.xml) -- ver
-- charts/psych/notes.lua. Antes este archivo tenía las coordenadas escritas
-- a mano contra una imagen propia de Rewritten empaquetada distinto a la de
-- Psych; ahora notes.png/notes.xml SON los assets reales de Psych
-- (NOTE_assets.png/.xml), así que las coordenadas se leen del atlas en vez
-- de transcribirse a mano (fuente de errores -- ver el bug real encontrado
-- y corregido en left-arrow.lua antes de este cambio).
return require("charts.psych.notes").build("down", "arrowDOWN", "blue")
