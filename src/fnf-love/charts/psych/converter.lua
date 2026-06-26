-- Convierte un chart en formato Psych Engine (JSON ya decodificado, con la
-- estructura `song.notes` / `song.events`) a la tabla interna que espera
-- `weeks:generateNotes()` en states/weeks.lua.
--
-- Fórmula de mapeo de notas -- verificada DIRECTO contra el código fuente
-- real de Psych Engine (FNF-PsychEngine-main/source/states/PlayState.hx,
-- línea ~1355):
--   var gottaHitNote:Bool = (songNotes[1] < totalColumns);
-- O sea: el lado de la nota (jugador/oponente) depende ÚNICAMENTE del dato
-- crudo (raw < 4 = jugador, raw >= 4 = oponente) -- mustHitSection NO entra
-- para nada en este cálculo. mustHitSection se usa en otro lado de
-- PlayState.hx (moveCameraSection(), línea ~2320: "isDad = mustHitSection
-- != true") solo para la cámara, y en el cálculo de gfNote/isAlt (que sí
-- comparan gottaHitNote contra mustHitSection, pero como dos valores
-- independientes, no como entrada del mapeo de lado).
--
-- BUG real (causó que TODOS los charts normales -- bopeebo, etc. -- dieran
-- resultados con casi todas las notas para un solo lado, EXCEPTO Too Slow):
-- una ronda anterior metió mustHitSection en este cálculo
-- (`(gottaHit == mustHitSection) and lane or lane+4`) para "arreglar" un
-- split 82%/18% en Too Slow que se asumió como bug. Verificado ahora: ese
-- split es el real de la canción (Too Slow no tiene ninguna correlación
-- entre mustHitSection y el dato crudo, la huella de un chart bien armado
-- donde mustHitSection es puramente cámara, igual que dice la fuente) --
-- el problema nunca estuvo en el mapeo, era el split genuino del chart.
-- Mientras tanto, bopeebo.json con la fórmula real da bf=59/dad=59
-- (perfecto), y con la fórmula incorrecta de la ronda anterior daba
-- bf=112/dad=6 -- la prueba de que esa "corrección" estaba al revés.

local M = {}

local function mapNoteType(psychNoteData, mustHitSection)
	local lane = psychNoteData % 4
	local gottaHit = psychNoteData < 4
	if gottaHit then
		return lane, gottaHit
	else
		return lane + 4, gottaHit
	end
end

-- Aplana song.events (formato [[time, [[name,value1,value2], ...]], ...])
-- en una lista ordenada de {time=, name=, value1=, value2=}. Exportada
-- (M.flattenEvents) porque charts/psych/loader.lua la necesita para
-- procesar el events.json hermano con el mismo formato moderno.
function M.flattenEvents(rawEvents)
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

-- Eventos incrustados en sectionNotes (formato VIEJO de Psych, antes de que
-- los eventos se guardaran aparte en events.json/song.events):
-- [tiempo, -1, "nombreEvento", value1, value2] -- mismo array de 5 elementos
-- que una nota normal, pero con noteData=-1 como marca y note[3] repropuesto
-- como STRING (nombre del evento) en vez de número (sustainLength). Antes
-- esto se descartaba sin más ("se ignora") -- algunos mods (p.ej. Too Slow/
-- Sonic.exe) SOLO traen sus eventos así.
--
-- Exportada (M.extractLegacyEvents) porque charts/psych/loader.lua TAMBIÉN
-- la necesita: el chart real de la dificultad (p.ej. too-slow-hard.json)
-- puede traer sus propios eventos incrustados en SU PROPIO songData.notes
-- (es lo que pasa hoy -- 51 eventos, confirmado), pero el events.json
-- "hermano" pensado para compartirse entre todas las dificultades TAMBIÉN
-- puede usar este mismo formato viejo en VEZ del moderno (song.events
-- aparte) -- loadSiblingEvents() solo sabía leer el moderno, así que
-- cualquier events.json en formato viejo se ignoraba por completo (0
-- eventos extraídos, aunque el archivo tuviera datos).
function M.extractLegacyEvents(songData)
	local legacyEvents = {}

	for _, section in ipairs(songData.notes or {}) do
		for _, note in ipairs(section.sectionNotes or {}) do
			local strumTime = note[1]
			local noteData = note[2]

			if strumTime and noteData and noteData < 0 and type(note[3]) == "string" then
				table.insert(legacyEvents, {
					time = strumTime,
					name = note[3],
					value1 = note[4],
					value2 = note[5],
				})
			end
		end
	end

	table.sort(legacyEvents, function(a, b) return a.time < b.time end)

	return legacyEvents
end

-- songData: tabla ya decodificada (el contenido de la clave "song" del JSON,
-- o el JSON entero si no tiene wrapper "song").
-- Devuelve: chart (tabla compatible con generateNotes), meta (datos de la canción)
function M.convertSong(songData)
	local chart = { speed = songData.speed or 1.0 }

	-- Eventos incrustados en sectionNotes (formato viejo) -- ver
	-- M.extractLegacyEvents más arriba. Se mezclan con
	-- flattenEvents(songData.events) (formato moderno) más abajo.
	local legacyEvents = M.extractLegacyEvents(songData)

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

			-- noteData negativo = evento incrustado, ya extraído arriba por
			-- M.extractLegacyEvents() -- se ignora acá para no contarlo dos veces.
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

	-- Mezcla ambos formatos de eventos (moderno: songData.events aparte;
	-- viejo: incrustados en sectionNotes, acumulados en legacyEvents más
	-- arriba) y ordena el resultado combinado por tiempo.
	local allEvents = M.flattenEvents(songData.events)
	for _, ev in ipairs(legacyEvents) do
		table.insert(allEvents, ev)
	end
	table.sort(allEvents, function(a, b) return a.time < b.time end)

	local meta = {
		player1 = songData.player1,
		player2 = songData.player2,
		gfVersion = songData.gfVersion,
		stage = songData.stage,
		bpm = songData.bpm,
		speed = songData.speed,
		events = allEvents,
	}

	return chart, meta
end

return M
