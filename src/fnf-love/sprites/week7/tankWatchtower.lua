-- Puerto 1:1 de states/stages/Tank.hx: new BGSprite('tankWatchtower', 100, 50, 0.5, 0.5, ['watchtower gradient color'])
-- x,y los sigue fijando stages/military/stage.lua -- acá solo se modernizó
-- la fuente de frames (atlas real en vez de tabla hardcodeada). Nombre
-- real de Psych ("watchtower gradient color"), no "anim".
local bgsprite = require("charts.psych.bgsprite")
return bgsprite.new("week7/tankWatchtower", 0, 0, {"watchtower gradient color"})
