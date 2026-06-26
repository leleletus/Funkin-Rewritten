-- Puerto de TitleState.hx:titleText -- el atlas REAL "title-screen-text"
-- (images/png/menu/title-screen-text/, copiado de
-- funkin.assets-main/preload/images/title-screen-text/) en vez de un
-- texto renderizado por fuente ("PRESS ENTER" con atlas_text), que es lo
-- que Rewritten usaba antes y no es el asset real del juego.
--
-- Animation.json real: un solo timeline raíz ("ALL ANIMS", sin símbolos
-- en SD.S) con 2 rangos de frame con label en Layer_2 -- "Idle" (frames
-- 0-44, 45 frames) e "Confirm" (frames 45-52, 8 frames), exactamente como
-- TitleState.hx:startIntro() los registra:
--   titleText.anim.addByFrameLabel('idle', "Idle", 24);
--   titleText.anim.addByFrameLabel('press', "Confirm", 24);
local animateAtlas = require("modules.animate_atlas")

local M = {}

-- BUG corregido (texto corrido a la izquierda, mitad cortada): este atlas
-- es un export "BTA" (ver Animation.json:MD.V) -- Instance.x/y no caen
-- donde caerían para un atlas normal de este proyecto. La teoría inicial
-- (restar el "TRP" de las instancias del timeline raíz, pensando que
-- representaba el centro del bounding box) no dio el resultado correcto
-- -- ajustado a mano con una herramienta de tuning en vivo (después
-- removida, ver memoria del proyecto "patrón de herramienta de ajuste de
-- offsets en vivo" para volver a armarla si hace falta de nuevo) contra
-- el x,y que pasa states/title.lua (centro deseado en pantalla, 1280/2,
-- 720*0.8) -- la corrección confirmada es +90,+60 desde ese punto, sin
-- relación con el TRP.
local OFFSET_X, OFFSET_Y = 90, 60

function M.new(x, y)
	local data = animateAtlas.load("images/png/menu/title-screen-text")
	local inst = animateAtlas.newInstance(data)
	inst.x, inst.y = (x or 0) + OFFSET_X, (y or 0) + OFFSET_Y

	-- "idle": animation.play('idle') real -- loop=true (la pose de reposo
	-- antes de confirmar, en bucle indefinido).
	function inst:playIdle()
		self:playSymbolRange("ALL ANIMS", 0, 44, true)
	end

	-- "press": animation.play('press') real -- loop=false (se reproduce
	-- una vez al confirmar, justo antes de pasar al menú principal).
	function inst:playConfirm()
		self:playSymbolRange("ALL ANIMS", 45, 52, false)
	end

	inst:playIdle()

	return inst
end

return M
