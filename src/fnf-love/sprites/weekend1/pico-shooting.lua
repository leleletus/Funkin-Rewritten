-- Poses de mecánica de armas de Pico (atlas Adobe-Animate-INDEPENDIENTE --
-- ver characters/pico-playable.json: el atlas principal "Pico_FNF_assetss"
-- solo trae las poses de canto, "shoot"/"cock"/"shootMISS" viven en este
-- atlas Sparrow aparte, "Pico_Shooting", igual que en Psych real
-- (Character.hx: json.image admite una lista separada por comas de varios
-- atlas -- acá en vez de mezclarlos en el mismo sprite, este sprite
-- standalone se dibuja en el lugar del personaje principal solo durante
-- estas poses, mismo patrón que stages/military/stage.lua ya usa para
-- tankmanCutscene/boyfriendCutscene).
--
-- Offsets AJUSTADOS a mano con states/pico-gun-offset-debug.lua (editor
-- dedicado, comparado contra el Pico jugable normal) -- los offsets
-- crudos de characters/pico-playable.json real (shoot=[256,232],
-- shootMISS=[0,0], cock=[0,0]) no daban un resultado alineado en este
-- motor, ver el comentario de picoTopLeft() en stage.lua para el porqué.
local bgsprite = require("charts.psych.bgsprite")

local sprite = bgsprite.new("characters/picoAnims/Pico_Shooting", 0, 0, {
	{name = "shoot",     prefix = "Pico Shoot Hip Full", offsetX = 149, offsetY = 151},
	{name = "shootMISS", prefix = "Pico Hit Can",        offsetX = -4,  offsetY = -2},
	{name = "cock",      prefix = "Pico Reload",         offsetX = 22,  offsetY = -7},
})

return sprite
