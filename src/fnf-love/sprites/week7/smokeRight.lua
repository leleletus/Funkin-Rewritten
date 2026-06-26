-- Puerto 1:1 de states/stages/Tank.hx: new BGSprite('smokeRight', 1100, -100, 0.4, 0.4, ['SmokeRight'], true)
-- x,y los sigue fijando stages/military/stage.lua -- acá solo se modernizó
-- la fuente de frames (atlas real en vez de tabla hardcodeada). Nombre
-- real de Psych ("SmokeRight"), no "anim".
local bgsprite = require("charts.psych.bgsprite")
return bgsprite.new("week7/smokeRight", 0, 0, {"SmokeRight"}, true)
