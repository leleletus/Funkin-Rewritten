-- Poses de Pico SOLO para la cutscene de Darnell (PhillyStreets.hx:
-- darnellCutscene()) -- atlas Sparrow aparte "Pico_Intro", igual criterio
-- que pico-shooting.lua (mismo patrón que tankmanCutscene/boyfriendCutscene
-- en stages/military/stage.lua).
--
-- Offsets AJUSTADOS a mano con states/pico-gun-offset-debug.lua (editor
-- dedicado, comparado contra el Pico jugable normal) -- ver el mismo
-- comentario en pico-shooting.lua.
local bgsprite = require("charts.psych.bgsprite")

local sprite = bgsprite.new("characters/picoAnims/Pico_Intro", 0, 0, {
	{name = "intro1",       prefix = "Pico Gets Pissed", offsetX = 8,   offsetY = 0},
	{name = "cockCutscene", prefix = "cutscene cock",    offsetX = 40,  offsetY = 13},
	{name = "intro2",       prefix = "shoot and return", offsetX = 145, offsetY = 151},
})

return sprite
