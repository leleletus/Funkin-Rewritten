-- Convierte un chart en formato Psych Engine (JSON ya decodificado, con la
-- estructura `song.notes` / `song.events`) a la tabla interna que espera
-- `weeks:generateNotes()` en states/weeks.lua.
--
-- Fórmula de mapeo de notas (validada nota a nota contra bopeebo.json):
--   lane     = psychNoteData % 4
--   gottaHit = psychNoteData < 4          -- true = nota del jugador (0-3) en Psych
--   noteType = (gottaHit == mustHitSection) and lane or (lane + 4)

local M = {}

local function mapNoteType(psychNoteData, mustHitSection)
	local lane = psychNoteData % 4
	local gottaHit = psychNoteData < 4
	if gottaHit == mustHitSection then
		return lane, gottaHit
	else
		return lane + 4, gottaHit
	end
end

-- Aplana song.events (formato [[time, [[name,value1,value2], ...]], ...])
-- en una lista ordenada de {time=, name=, value1=, value2=}.
local function flattenEvents(rawEvents)
	local events = {}

	for _, entry in ipairs(rawEvents or {}) do
		local time = entry[1]
		local list = entry[2]

		for _, ev in ipairs(list or {}) do
			table.insert(events, {
				time = time,
				name = ev[1],
				value1 = ev[2],
				value2 = ev[3],
			})
		end
	end

	table.sort(events, function(a, b) return a.time < b.time end)

	return events
end

-- songData: tabla ya decodificada (el contenido de la clave "song" del JSON,
-- o el JSON entero si no tiene wrapper "song").
-- Devuelve: chart (tabla compatible con generateNotes), meta (datos de la canción)
function M.convertSong(songData)
	local chart = { speed = songData.speed or 1.0 }

	for i, section in ipairs(songData.notes or {}) do
		local mustHit = section.mustHitSection or false

		local seccion = {
			mustHitSection = mustHit,
			sectionNotes = {},
		}

		if section.altAnim then
			seccion.altAnim = true
		end

		if section.gfSection then
			seccion.gfSection = true
		end

		if section.sectionBeats and section.sectionBeats > 0 then
			seccion.lengthInSteps = section.sectionBeats * 4
		end

		-- BPM inicial (primera sección) o cambio explícito de BPM
		if i == 1 then
			seccion.bpm = section.bpm or songData.bpm
		elseif section.changeBPM and section.bpm then
			seccion.bpm = section.bpm
		end

		for _, note in ipairs(section.sectionNotes or {}) do
			local strumTime = note[1]
			local noteData = note[2]
			local sustainLength = note[3] or 0
			local noteTypeStr = note[4]

			-- noteData negativo = evento incrustado de charts antiguos; se ignora
			if strumTime and noteData and noteData >= 0 then
				local noteType, gottaHit = mapNoteType(noteData, mustHit)

				local altNote = (section.altAnim and not gottaHit)
					or (noteTypeStr == "Alt Animation")

				local gfNote = (section.gfSection and gottaHit == mustHit)
					or (noteTypeStr == "GF Sing")

				table.insert(seccion.sectionNotes, {
					noteTime = strumTime,
					noteType = noteType,
					noteLength = sustainLength,
					altNote = altNote and true or false,
					gfNote = gfNote and true or false,
					noteTypeStr = noteTypeStr,
				})
			end
		end

		table.insert(chart, seccion)
	end

	-- Calcular sectionStartTime (tiempo acumulado al inicio de cada sección,
	-- en ms) con la misma fórmula que weeks:generateNotes() usa para
	-- duracion_seccion -- útil para el editor de charts (timeline) y para que
	-- generateNotes pueda emitir un evento de sección por sección.
	do
		local globalBpm
		for i = 1, #chart do
			if chart[i].bpm then globalBpm = chart[i].bpm; break end
		end
		if not globalBpm then globalBpm = 100 end

		local accumTime = 0
		local bpmAnterior = nil
		for i = 1, #chart do
			local seccion = chart[i]
			local eventBpm = seccion.bpm
			local lengthInSteps = seccion.lengthInSteps or 16
			local bpmActivo = eventBpm or bpmAnterior or globalBpm

			seccion.sectionStartTime = accumTime

			accumTime = accumTime + (lengthInSteps / 16.0) * (240000.0 / bpmActivo)
			bpmAnterior = bpmActivo
		end
	end

	local meta = {
		player1 = songData.player1,
		player2 = songData.player2,
		gfVersion = songData.gfVersion,
		stage = songData.stage,
		bpm = songData.bpm,
		speed = songData.speed,
		events = flattenEvents(songData.events),
	}

	return chart, meta
end

return M
