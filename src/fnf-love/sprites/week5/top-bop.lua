-- Puerto 1:1 de states/stages/Mall.hx:
--   upperBoppers = new BGSprite('christmas/upperBop', -240, -90, 0.33, 0.33, ['Upper Crowd Bob']);
--   upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
--   upperBoppers.updateHitbox();
-- setGraphicSize()+updateHitbox() = escala 0.85 con recentrado de origen
-- (originScale = scale, el default de bgsprite.lua). sf=(0.33,0.33) lo
-- aplica stages/mall/stage.lua vía graphics.pushParallax(0.33).
local bgsprite = require("charts.psych.bgsprite")

return bgsprite.new("week5/top-bop", -240, -90, {"Upper Crowd Bob"}, false, 0.85)
