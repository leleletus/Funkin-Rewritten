-- Dispatcher de eventos en formato Psych Engine (la lista aplanada que
-- devuelve charts/psych/converter.lua: { {time=, name=, value1=, value2=}, ... }).
--
-- weeks.lua llama a M.trigger(ev) cuando musicTime alcanza ev.time. Todas las
-- acciones leen/escriben las globales del motor (cam, camScale, speed, health,
-- score, misses, boyfriend, enemy, girlfriend, weeks, Timer, _G.disableAutoCam,
-- _G.gfDanceBeats) — eventos no soportados o con datos inválidos solo generan
-- un print de warning y nunca interrumpen la canción.

local animnames = require("charts.psych.animnames")
local characters = require("charts.psych.characters")
local icons = require("sprites.icons")

local M = {}

-- spriteTimers de weeks.lua: 1=girlfriend, 2=enemy, 3=boyfriend
local TIMER_ID = { girlfriend = 1, enemy = 2, boyfriend = 3 }

-- Resuelve a qué sprite/slot se refiere un identificador de personaje Psych
-- ("", "bf", "boyfriend", "player1" -> boyfriend; "gf", "girlfriend" -> girlfriend;
-- cualquier otra cosa ("dad", "2", "opponent", ...) -> enemy/dad).
local function spriteFor(who)
	who = tostring(who or ""):lower()

	if who == "" or who == "bf" or who == "boyfriend" or who == "player1" or who == "1" then
		return boyfriend, "boyfriend"
	elseif who == "gf" or who == "girlfriend" then
		return girlfriend, "girlfriend"
	else
		return enemy, "enemy"
	end
end

-- Convierte el value de un evento (normalmente string) a número/booleano si
-- corresponde; si no, lo deja como string.
local function coerce(value)
	if value == "true" then return true end
	if value == "false" then return false end

	local n = tonumber(value)
	if n then return n end

	return value
end

-- ===================== Set Property =====================
-- Tabla curada de propiedades soportadas. Cualquier ruta no listada aquí
-- genera un warning y se ignora (no hay reflexión genérica en Lua).
local propertyMap = {
	health         = function(v) health = coerce(v) end,
	score          = function(v) score = coerce(v) end,
	misses         = function(v) misses = coerce(v) end,
	speed          = function(v) speed = coerce(v) end,
	scrollSpeed    = function(v) speed = coerce(v) end,
	["cam.x"]      = function(v) cam.x = coerce(v) end,
	["cam.y"]      = function(v) cam.y = coerce(v) end,
	["cam.zoom"]   = function(v) camScale.x, camScale.y = coerce(v), coerce(v) end,
	["camScale.x"] = function(v) camScale.x = coerce(v) end,
	["camScale.y"] = function(v) camScale.y = coerce(v) end,
	-- defaultCamZoom es el nombre real de la propiedad pública de PlayState.hx
	-- (el zoom "en reposo" al que la cámara vuelve) -- camScale es exactamente
	-- ese concepto en este puerto.
	defaultCamZoom = function(v) camScale.x, camScale.y = coerce(v), coerce(v) end,
	disableAutoCam = function(v) _G.disableAutoCam = coerce(v) and true or false end,
}

-- ===================== Handlers por tipo de evento =====================

local handlers = {}

-- PlayState.hx triggerEvent 'Hey!': value1 decide quién reacciona.
-- "bf"/"boyfriend"/"0" -> solo bf; "gf"/"girlfriend"/"1" -> solo gf;
-- cualquier otro valor (incluido vacío) -> ambos.
handlers["Hey!"] = function(ev)
	local who = tostring(ev.value1 or ""):lower():match("^%s*(.-)%s*$")
	local value = 2
	if who == "bf" or who == "boyfriend" or who == "0" then
		value = 0
	elseif who == "gf" or who == "girlfriend" or who == "1" then
		value = 1
	end

	if value ~= 0 and girlfriend and girlfriend.anims and girlfriend.anims["cheer"] then
		weeks:safeAnimate(girlfriend, "cheer", false, TIMER_ID.girlfriend)
	end
	if value ~= 1 then
		weeks:safeAnimate(boyfriend, "hey", false, TIMER_ID.boyfriend)
	end
end

handlers["Set GF Speed"] = function(ev)
	local beats = tonumber(ev.value1)
	if beats and beats > 0 then
		_G.gfDanceBeats = beats
	end
end

-- "Add Camera Zoom" en Psych (PlayState.hx) NO modifica defaultCamZoom: suma a
-- FlxG.camera.zoom (con tope < 1.35), que luego decae solo de vuelta a
-- defaultCamZoom (ver el lerp en update()). Aquí equivale a sumar a
-- camZoomBump (decae hacia 0 en weeks.lua), dejando camScale (defaultCamZoom)
-- intacto.
handlers["Add Camera Zoom"] = function(ev)
	local camAmount = tonumber(ev.value1)
	if camAmount == nil then camAmount = 0.015 end

	if camScale.x + camZoomBump.x < 1.35 then
		camZoomBump.x = camZoomBump.x + camAmount
		camZoomBump.y = camZoomBump.y + camAmount
	end
end

handlers["Play Animation"] = function(ev)
	local sprite, slot = spriteFor(ev.value2)
	local animName = animnames.toInternal(ev.value1)
	weeks:safeAnimate(sprite, animName, false, TIMER_ID[slot])
end

handlers["Camera Follow Pos"] = function(ev)
	local x = tonumber(ev.value1)
	local y = tonumber(ev.value2)
	if not x or not y then return end

	if camTimer and Timer and Timer.cancel then Timer.cancel(camTimer) end
	camTimer = Timer.tween(1.25, cam, {x = -x + 100, y = -y + 75}, "out-quad")
end

local altIdleState = { boyfriend = false, girlfriend = false, enemy = false }

handlers["Alt Idle Animation"] = function(ev)
	local sprite, slot = spriteFor(ev.value1)
	altIdleState[slot] = not altIdleState[slot]

	local animName = altIdleState[slot] and "idle alt" or "idle"
	weeks:safeAnimate(sprite, animName, false, TIMER_ID[slot])
end

handlers["Screen Shake"] = function(ev)
	local duration = tonumber(ev.value1) or 0
	local intensity = tonumber(ev.value2) or 0
	if duration <= 0 or intensity <= 0 then return end

	local baseX, baseY = cam.x, cam.y
	local amplitude = intensity * 100

	local function shakeStep(remaining)
		if remaining <= 0 then
			cam.x, cam.y = baseX, baseY
			return
		end

		cam.x = baseX + (love.math.random() * 2 - 1) * amplitude
		cam.y = baseY + (love.math.random() * 2 - 1) * amplitude

		Timer.after(0.05, function() shakeStep(remaining - 1) end)
	end

	shakeStep(math.max(1, math.floor(duration / 0.05)))
end

handlers["Change Character"] = function(ev)
	local _, slot = spriteFor(ev.value1)
	local ok, entry = characters.loadInto(slot, ev.value2)

	if ok and entry then
		-- BUG corregido (round 45): preferir el "healthicon" ya corregido
		-- del propio JSON del personaje (charts/psych/character.lua:
		-- sprite.psychChar.healthicon) sobre entry.icon (la tabla
		-- registro) -- mismo patrón que states/weeks.lua:
		-- healthIconNameFor(), ver el comentario completo ahí.
		local sprite = (slot == "enemy") and enemy or (slot == "boyfriend") and boyfriend or nil
		local psychChar = sprite and sprite.psychChar
		local iconName = (psychChar and psychChar.healthicon) or entry.icon
		if iconName then
			if slot == "enemy" and enemyIcon then
				icons.animate(enemyIcon, iconName, false)
			elseif slot == "boyfriend" and boyfriendIcon then
				icons.animate(boyfriendIcon, iconName, false)
			end
		end
	end
end

handlers["Change Scroll Speed"] = function(ev)
	local newSpeed = tonumber(ev.value1)
	if newSpeed and newSpeed > 0 then
		speed = newSpeed
	end
end

handlers["Set Property"] = function(ev)
	local path = tostring(ev.value1)
	local setter = propertyMap[path]

	if setter then
		setter(ev.value2)
	else
		print("WARN: Set Property '" .. path .. "' no soportado, ignorado")
	end
end

handlers["Play Sound"] = function(ev)
	local name = tostring(ev.value1)
	if name == "" then return end

	local ok, source = pcall(love.audio.newSource, "sounds/" .. name .. ".ogg", "static")
	if not ok or not source then
		print("WARN: no se pudo reproducir el sonido Psych '" .. name .. "': " .. tostring(source))
		return
	end

	local volume = tonumber(ev.value2)
	if volume then source:setVolume(volume) end

	source:play()
end

-- Permite que un week/stage registre (o sobrescriba) un handler para un
-- evento Psych concreto, igual que StageWeek1.hx sobrescribe eventCalled()
-- para "Dadbattle Spotlight" (evento que solo tiene sentido en ese stage).
function M.registerHandler(name, fn)
	handlers[name] = fn
end

-- ev: { time=, name=, value1=, value2= }
function M.trigger(ev)
	local handler = handlers[ev.name]

	if not handler then
		print("WARN: evento Psych '" .. tostring(ev.name) .. "' no soportado, ignorado")
		return
	end

	local ok, err = pcall(handler, ev)
	if not ok then
		print("WARN: error al procesar el evento Psych '" .. tostring(ev.name) .. "': " .. tostring(err))
	end
end

return M
