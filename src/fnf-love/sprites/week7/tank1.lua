-- Puerto 1:1 de states/stages/Tank.hx: new BGSprite('tank1', -300, 750, 2, 0.2, ['fg'])
-- x,y/sf los sigue fijando stages/military/stage.lua (foregroundSprites) --
-- acá solo se modernizó la fuente de frames (atlas real en vez de tabla
-- hardcodeada).
local bgsprite = require("charts.psych.bgsprite")
return bgsprite.new("week7/tank1", 0, 0, {"fg"})
