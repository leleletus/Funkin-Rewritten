-- Puerto 1:1 de states/stages/Tank.hx: new BGSprite('tank5', 1620, 700, 1.5, 1.5, ['fg'])
-- x,y/sf los sigue fijando stages/military/stage.lua (foregroundSprites) --
-- acá solo se modernizó la fuente de frames (atlas real en vez de tabla
-- hardcodeada).
local bgsprite = require("charts.psych.bgsprite")
return bgsprite.new("week7/tank5", 0, 0, {"fg"})
