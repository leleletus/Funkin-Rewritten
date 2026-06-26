-- Puerto 1:1 de states/stages/Tank.hx: new BGSprite('tank2', 450, 940, 1.5, 1.5, ['foreground'])
-- x,y/sf los sigue fijando stages/military/stage.lua (foregroundSprites) --
-- acá solo se modernizó la fuente de frames (atlas real en vez de tabla
-- hardcodeada).
local bgsprite = require("charts.psych.bgsprite")
return bgsprite.new("week7/tank2", 0, 0, {"foreground"})
