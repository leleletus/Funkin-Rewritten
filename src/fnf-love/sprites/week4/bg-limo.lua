-- Puerto 1:1 de states/stages/Limo.hx:
--   bgLimo = new BGSprite('limo/bgLimo', -150, 480, 0.4, 0.4, ['background limo pink'], true);
-- x,y los sigue fijando stages/limo/stage.lua después de cargar (ver
-- comentario ahí) -- acá solo se modernizó la fuente de frames (atlas real
-- en vez de tabla hardcodeada). El nombre de la animación es el real de
-- Psych ("background limo pink"), no el genérico "anim" de antes.
local bgsprite = require("charts.psych.bgsprite")

return bgsprite.new("week4/bg-limo", 0, 0, {"background limo pink"}, true)
