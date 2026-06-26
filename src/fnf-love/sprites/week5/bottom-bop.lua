-- Puerto 1:1 de states/stages/objects/MallCrowd.hx (subclase de BGSprite):
--   super(sprite, x, y, 0.9, 0.9, ['Bottom Level Boppers Idle']);
--   animation.addByPrefix('hey', 'Bottom Level Boppers HEY', 24, false);
-- Sin setGraphicSize() -- escala 1 (default). sf=(0.9,0.9) lo aplica
-- stages/mall/stage.lua vía graphics.pushParallax(0.9).
--
-- BUG real arreglado: a esta sprite SIEMPRE le faltó el .png (no existía
-- en el repo -- el stage Mall normal, canciones 1-2 de Week 5, crasheaba
-- al cargar) y la animación "hey" (el viejo archivo solo tenía "Bottom
-- Level Boppers", sin el sufijo "Idle" ni la animación HEY -- el handler
-- "Hey!" de stages/mall/stage.lua llamaba a algo que nunca existía).
local bgsprite = require("charts.psych.bgsprite")

return bgsprite.new("week5/bottom-bop", -300, 140, {
	"Bottom Level Boppers Idle",
	{name = "hey", prefix = "Bottom Level Boppers HEY"},
})
