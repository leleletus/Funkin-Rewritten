-- Puerto 1:1 de states/stages/Mall.hx:
--   santa = new BGSprite('christmas/santa', -840, 150, 1, 1, ['santa idle in fear']);
-- Sin setGraphicSize() -- escala 1 (default). sf=(1,1) lo aplica
-- stages/mall/stage.lua vía graphics.pushParallax(1), no este archivo.
local bgsprite = require("charts.psych.bgsprite")

return bgsprite.new("week5/santa", -840, 150, {"santa idle in fear"})
