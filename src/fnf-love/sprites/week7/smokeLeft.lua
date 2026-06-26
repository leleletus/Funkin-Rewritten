-- Puerto 1:1 de states/stages/Tank.hx: new BGSprite('smokeLeft', -200, -100, 0.4, 0.4, ['SmokeBlurLeft'], true)
-- x,y los sigue fijando stages/military/stage.lua -- acá solo se modernizó
-- la fuente de frames (atlas real en vez de tabla hardcodeada). Nombre
-- real de Psych ("SmokeBlurLeft"), no "anim".
local bgsprite = require("charts.psych.bgsprite")
return bgsprite.new("week7/smokeLeft", 0, 0, {"SmokeBlurLeft"}, true)
