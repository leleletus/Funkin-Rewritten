-- Puerto 1:1 de states/stages/Limo.hx (createPost()):
--   limo = new BGSprite('limo/limoDrive', -120, 550, 1, 1, ['Limo stage'], true);
-- x,y los sigue fijando stages/limo/stage.lua después de cargar -- acá solo
-- se modernizó la fuente de frames (atlas real en vez de tabla
-- hardcodeada). Nombre real de Psych ("Limo stage"), no "anim".
local bgsprite = require("charts.psych.bgsprite")

return bgsprite.new("week4/limo", 0, 0, {"Limo stage"}, true)
