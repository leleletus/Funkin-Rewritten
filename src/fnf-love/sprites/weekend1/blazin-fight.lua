-- Puerto 1:1 de states/stages/objects/DarnellBlazinHandler.hx +
-- PicoBlazinHandler.hx -- la lógica de la pelea de boxeo "Blazin Fight"
-- (Pico vs Darnell). Reconstruido desde cero contra la fuente real, NO se
-- reusó nada del backup.
--
-- Uso: stages/phillyBlazin/stage.lua llama M.new() una vez al cargar, y
-- reenvía goodNoteHit/noteMiss/noteMissPress desde
-- weeks.lua:customNoteHit/customNoteMiss/customEnemyNoteHit.
--
-- Orden de dibujado (moveToFront/moveToBack): Psych real reordena
-- FlxG.state.members (mueve el grupo de boyfriend o dad completo, dad/bf
-- como unidad). Rewritten no tiene un array de "members" equivalente --
-- se expone self.bfInFront (bool) para que el stage decida el orden de
-- :draw() de boyfriend/enemy en cada frame.
local M = {}

local graphics = require("modules.graphics")

-- Flixel real: camera.shake(intensity, duration) -- intensity es una
-- FRACCIÓN del tamaño de pantalla (0.0025 = 0.25%), no píxeles. Reusa
-- graphics.setShakeOffset() (ya construido para Too Slow) -- intensidad
-- convertida a píxeles sobre la resolución virtual (720 de alto).
local function cameraShake(intensity, duration)
	local px = math.max(1, math.floor(intensity * 720))
	local handle = Timer.every(0.02, function()
		graphics.setShakeOffset(love.math.random(-px, px), love.math.random(-px, px))
	end)
	Timer.after(duration, function()
		Timer.cancel(handle)
		graphics.setShakeOffset(0, 0)
	end)
end

function M.new()
	local self = {
		bfInFront = true,
		darnellCantUppercut = false,
		picoCantUppercut = false,
		darnellAlternate = false,
		picoAlternate = false,
	}

	-- ── Helpers comunes ──────────────────────────────────────────────────
	local function willMissBeLethal()
		return health <= 0
	end
	local function wasNoteHitPoorly(rating)
		return rating == "bad" or rating == "shit"
	end
	local function isPlayerLowHealth()
		return health <= 0.3 * 2 * 100  -- Psych: 0-1; Rewritten: 0-100
	end

	-- ============================================================
	-- DARNELL (oponente) -- DarnellBlazinHandler.hx
	-- ============================================================

	local function darnellDoAlternate()
		self.darnellAlternate = not self.darnellAlternate
		return self.darnellAlternate and "1" or "2"
	end

	local function darnellMoveToBack() self.bfInFront = true end
	local function darnellMoveToFront() self.bfInFront = false end

	local function darnellBlock()      enemy:animate("block", false);     cameraShake(0.002, 0.1);   darnellMoveToBack() end
	local function darnellCringe()     enemy:animate("cringe", false);                                darnellMoveToBack() end
	local function darnellDodge()      enemy:animate("dodge", false);                                  darnellMoveToBack() end
	local function darnellIdle()       enemy:animate("idle", false);                                  darnellMoveToBack() end
	local function darnellFakeout()    enemy:animate("fakeout", false);                                darnellMoveToBack() end
	local function darnellPissed()     enemy:animate("pissed", false);                                 darnellMoveToBack() end
	local function darnellUppercutPrep() enemy:animate("uppercutPrep", false);                          darnellMoveToFront() end
	local function darnellUppercut()   enemy:animate("uppercut", false);                                darnellMoveToFront() end
	local function darnellUppercutHit() enemy:animate("uppercutHit", false);                             darnellMoveToBack() end
	local function darnellHitHigh()    enemy:animate("hitHigh", false);   cameraShake(0.0025, 0.15); darnellMoveToBack() end
	local function darnellHitLow()     enemy:animate("hitLow", false);    cameraShake(0.0025, 0.15); darnellMoveToBack() end
	local function darnellHitSpin()    enemy:animate("hitSpin", false);   cameraShake(0.0025, 0.15); darnellMoveToBack() end
	local function darnellPunchHigh()  enemy:animate("punchHigh" .. darnellDoAlternate(), false);     darnellMoveToFront() end
	local function darnellPunchLow()   enemy:animate("punchLow" .. darnellDoAlternate(), false);      darnellMoveToFront() end

	local function darnellPissedConditional()
		if enemy:getAnimName() == "cringe" then darnellPissed() else darnellIdle() end
	end

	-- noteHit del LADO Pico (boyfriend) -- Darnell reacciona.
	function self:darnellNoteHit(note)
		if wasNoteHitPoorly(note.rating) and isPlayerLowHealth() and love.math.random() < 0.30 then
			darnellUppercutPrep()
			return
		end

		if self.darnellCantUppercut then
			darnellPunchHigh()
			self.darnellCantUppercut = false
			return
		end

		local k = note.noteTypeStr
		if k == "weekend-1-punchlow" then darnellHitLow()
		elseif k == "weekend-1-punchlowblocked" then darnellBlock()
		elseif k == "weekend-1-punchlowdodged" then darnellDodge()
		elseif k == "weekend-1-punchlowspin" then darnellHitSpin()
		elseif k == "weekend-1-punchhigh" then darnellHitHigh()
		elseif k == "weekend-1-punchhighblocked" then darnellBlock()
		elseif k == "weekend-1-punchhighdodged" then darnellDodge()
		elseif k == "weekend-1-punchhighspin" then darnellHitSpin()
		elseif k == "weekend-1-blockhigh" then darnellPunchHigh()
		elseif k == "weekend-1-blocklow" then darnellPunchLow()
		elseif k == "weekend-1-blockspin" then darnellPunchHigh()
		elseif k == "weekend-1-dodgehigh" then darnellPunchHigh()
		elseif k == "weekend-1-dodgelow" then darnellPunchLow()
		elseif k == "weekend-1-dodgespin" then darnellPunchHigh()
		elseif k == "weekend-1-hithigh" then darnellPunchHigh()
		elseif k == "weekend-1-hitlow" then darnellPunchLow()
		elseif k == "weekend-1-hitspin" then darnellPunchHigh()
		elseif k == "weekend-1-picouppercutprep" then -- nada, sigue lo que estaba sonando
		elseif k == "weekend-1-picouppercut" then darnellUppercutHit()
		elseif k == "weekend-1-darnelluppercutprep" then darnellUppercutPrep()
		elseif k == "weekend-1-darnelluppercut" then darnellUppercut()
		elseif k == "weekend-1-idle" then darnellIdle()
		elseif k == "weekend-1-fakeout" then darnellCringe()
		elseif k == "weekend-1-taunt" then darnellPissedConditional()
		elseif k == "weekend-1-tauntforce" then darnellPissed()
		elseif k == "weekend-1-reversefakeout" then darnellFakeout()
		end

		self.darnellCantUppercut = false
	end

	function self:darnellNoteMiss(note)
		if enemy:getAnimName() == "uppercutPrep" then
			darnellUppercut()
			return
		end
		if willMissBeLethal() then
			darnellPunchLow()
			return
		end
		if self.darnellCantUppercut then
			darnellPunchHigh()
			return
		end

		local k = note.noteTypeStr
		if k == "weekend-1-punchlow" then darnellPunchLow()
		elseif k == "weekend-1-punchlowblocked" then darnellPunchLow()
		elseif k == "weekend-1-punchlowdodged" then darnellPunchLow()
		elseif k == "weekend-1-punchlowspin" then darnellPunchLow()
		elseif k == "weekend-1-punchhigh" then darnellPunchHigh()
		elseif k == "weekend-1-punchhighblocked" then darnellPunchHigh()
		elseif k == "weekend-1-punchhighdodged" then darnellPunchHigh()
		elseif k == "weekend-1-punchhighspin" then darnellPunchHigh()
		elseif k == "weekend-1-blockhigh" then darnellPunchHigh()
		elseif k == "weekend-1-blocklow" then darnellPunchLow()
		elseif k == "weekend-1-blockspin" then darnellPunchHigh()
		elseif k == "weekend-1-dodgehigh" then darnellPunchHigh()
		elseif k == "weekend-1-dodgelow" then darnellPunchLow()
		elseif k == "weekend-1-dodgespin" then darnellPunchHigh()
		elseif k == "weekend-1-hithigh" then darnellPunchHigh()
		elseif k == "weekend-1-hitlow" then darnellPunchLow()
		elseif k == "weekend-1-hitspin" then darnellPunchHigh()
		elseif k == "weekend-1-picouppercutprep" then darnellHitHigh(); self.darnellCantUppercut = true
		elseif k == "weekend-1-picouppercut" then darnellDodge()
		elseif k == "weekend-1-darnelluppercutprep" then darnellUppercutPrep()
		elseif k == "weekend-1-darnelluppercut" then darnellUppercut()
		elseif k == "weekend-1-idle" then darnellIdle()
		elseif k == "weekend-1-fakeout" then darnellCringe()
		elseif k == "weekend-1-taunt" then darnellPissedConditional()
		elseif k == "weekend-1-tauntforce" then darnellPissed()
		elseif k == "weekend-1-reversefakeout" then darnellFakeout()
		end

		self.darnellCantUppercut = false
	end

	function self:darnellNoteMissPress()
		if willMissBeLethal() then
			darnellPunchLow()
		else
			if love.math.random() < 0.5 then darnellDodge() else darnellBlock() end
		end
	end

	-- ============================================================
	-- PICO (boyfriend) -- PicoBlazinHandler.hx
	-- ============================================================

	local function picoDoAlternate()
		self.picoAlternate = not self.picoAlternate
		return self.picoAlternate and "1" or "2"
	end

	local function picoMoveToBack() self.bfInFront = false end
	local function picoMoveToFront() self.bfInFront = true end

	local function isDarnellPreppingUppercut() return enemy:getAnimName() == "uppercutPrep" end
	local function isDarnellInUppercut()
		local n = enemy:getAnimName()
		return n == "uppercut" or n == "uppercut-loop"
	end

	local function picoBlock()        boyfriend:animate("block", false); cameraShake(0.002, 0.1); picoMoveToBack() end
	local function picoCringe()       boyfriend:animate("cringe", false);                          picoMoveToBack() end
	local function picoDodge()        boyfriend:animate("dodge", false);                            picoMoveToBack() end
	local function picoIdle()         boyfriend:animate("idle", false);                            picoMoveToBack() end
	local function picoFakeout()      boyfriend:animate("fakeout", false);                          picoMoveToBack() end
	local function picoUppercutPrep() boyfriend:animate("uppercutPrep", false);                      picoMoveToFront() end
	local function picoUppercutHit()  boyfriend:animate("uppercutHit", false); cameraShake(0.005, 0.25); picoMoveToBack() end
	local function picoHitHigh()      boyfriend:animate("hitHigh", false);  cameraShake(0.0025, 0.15); picoMoveToBack() end
	local function picoHitLow()       boyfriend:animate("hitLow", false);   cameraShake(0.0025, 0.15); picoMoveToBack() end
	local function picoHitSpin()      boyfriend:animate("hitSpin", false);  cameraShake(0.0025, 0.15); picoMoveToBack() end
	local function picoPunchHigh()    boyfriend:animate("punchHigh" .. picoDoAlternate(), false);   picoMoveToFront() end
	local function picoPunchLow()     boyfriend:animate("punchLow" .. picoDoAlternate(), false);    picoMoveToFront() end

	local function picoUppercut(hit)
		boyfriend:animate("uppercut", false)
		if hit then cameraShake(0.005, 0.25) end
		picoMoveToFront()
	end

	local function picoTauntConditional()
		if boyfriend:getAnimName() == "fakeout" then
			boyfriend:animate("taunt", false); picoMoveToBack()
		else
			picoIdle()
		end
	end
	local function picoTaunt() boyfriend:animate("taunt", false); picoMoveToBack() end

	function self:picoNoteHit(note)
		if wasNoteHitPoorly(note.rating) and isPlayerLowHealth() and isDarnellPreppingUppercut() then
			picoPunchHigh()
			return
		end

		if self.picoCantUppercut then
			picoBlock()
			self.picoCantUppercut = false
			return
		end

		local k = note.noteTypeStr
		if k == "weekend-1-punchlow" or k == "weekend-1-punchlowblocked" or k == "weekend-1-punchlowdodged" or k == "weekend-1-punchlowspin" then
			picoPunchLow()
		elseif k == "weekend-1-punchhigh" or k == "weekend-1-punchhighblocked" or k == "weekend-1-punchhighdodged" or k == "weekend-1-punchhighspin" then
			picoPunchHigh()
		elseif k == "weekend-1-blockhigh" or k == "weekend-1-blocklow" or k == "weekend-1-blockspin" then
			picoBlock()
		elseif k == "weekend-1-dodgehigh" or k == "weekend-1-dodgelow" or k == "weekend-1-dodgespin" then
			picoDodge()
		elseif k == "weekend-1-hithigh" then picoHitHigh()
		elseif k == "weekend-1-hitlow" then picoHitLow()
		elseif k == "weekend-1-hitspin" then picoHitSpin()
		elseif k == "weekend-1-picouppercutprep" then picoUppercutPrep()
		elseif k == "weekend-1-picouppercut" then picoUppercut(true)
		elseif k == "weekend-1-darnelluppercutprep" then picoIdle()
		elseif k == "weekend-1-darnelluppercut" then picoUppercutHit()
		elseif k == "weekend-1-idle" then picoIdle()
		elseif k == "weekend-1-fakeout" then picoFakeout()
		elseif k == "weekend-1-taunt" then picoTauntConditional()
		elseif k == "weekend-1-tauntforce" then picoTaunt()
		elseif k == "weekend-1-reversefakeout" then picoIdle()
		end
	end

	function self:picoNoteMiss(note)
		if isDarnellInUppercut() then
			picoUppercutHit()
			return
		end
		if willMissBeLethal() then
			picoHitLow()
			return
		end
		if self.picoCantUppercut then
			picoHitHigh()
			return
		end

		local k = note.noteTypeStr
		if k == "weekend-1-punchlow" or k == "weekend-1-punchlowblocked" or k == "weekend-1-punchlowdodged" then
			picoHitLow()
		elseif k == "weekend-1-punchlowspin" then picoHitSpin()
		elseif k == "weekend-1-punchhigh" or k == "weekend-1-punchhighblocked" or k == "weekend-1-punchhighdodged" then
			picoHitHigh()
		elseif k == "weekend-1-punchhighspin" then picoHitSpin()
		elseif k == "weekend-1-blockhigh" then picoHitHigh()
		elseif k == "weekend-1-blocklow" then picoHitLow()
		elseif k == "weekend-1-blockspin" then picoHitSpin()
		elseif k == "weekend-1-dodgehigh" then picoHitHigh()
		elseif k == "weekend-1-dodgelow" then picoHitLow()
		elseif k == "weekend-1-dodgespin" then picoHitSpin()
		elseif k == "weekend-1-hithigh" then picoHitHigh()
		elseif k == "weekend-1-hitlow" then picoHitLow()
		elseif k == "weekend-1-hitspin" then picoHitSpin()
		elseif k == "weekend-1-picouppercutprep" then picoPunchHigh(); self.picoCantUppercut = true
		elseif k == "weekend-1-picouppercut" then picoUppercut(false)
		elseif k == "weekend-1-darnelluppercutprep" then picoIdle()
		elseif k == "weekend-1-darnelluppercut" then picoUppercutHit()
		elseif k == "weekend-1-idle" then picoIdle()
		elseif k == "weekend-1-fakeout" then picoHitHigh()
		elseif k == "weekend-1-taunt" then picoTauntConditional()
		elseif k == "weekend-1-tauntforce" then picoTaunt()
		elseif k == "weekend-1-reversefakeout" then picoIdle()
		end
	end

	function self:picoNoteMissPress()
		if willMissBeLethal() then
			picoHitLow()
		else
			picoPunchHigh()
		end
	end

	return self
end

return M
