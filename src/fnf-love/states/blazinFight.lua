--[[----------------------------------------------------------------------------
Blazin Fight System for FNF Rewritten
Ported from Friday Night Funkin' Weekend 1

Animation names based on original Adobe Animate atlas labels:

PICO: idle, block, dodge, punchHigh1, punchHigh2, punchLow1, punchLow2,
      hitLow, hitHigh, uppercutHit, fakeHit, taunt,
      uppercutPrep, uppercutPunch, hitSpin

DARNELL: idle, uppercutPrep, uppercutPunch, fakeHit, block,
         punchHigh1, punchHigh2, punchLow1, punchLow2, dodge,
         hitHigh, hitLow, cringe, hitSpin, pissed, uppercutHit
------------------------------------------------------------------------------]]

local blazinFight = {}

-- =====================================================================
-- ANIMATION MAPPING TABLE
-- =====================================================================

local noteKindAnims = {
	-- === BLOCKING (Pico blocks Darnell's attack) ===
	["blockhigh"] = {
		picoHit = "block",            darnellHit = "punchHigh1",
		picoMiss = "hitHigh",         darnellMiss = "punchHigh1",
		healthHit = 0, healthMiss = -6,
	},
	["blocklow"] = {
		picoHit = "block",            darnellHit = "punchLow1",
		picoMiss = "hitLow",          darnellMiss = "punchLow1",
		healthHit = 0, healthMiss = -6,
	},
	["blockspin"] = {
		picoHit = "block",            darnellHit = "punchHigh2",
		picoMiss = "hitSpin",         darnellMiss = "punchHigh2",
		healthHit = 2, healthMiss = -6,
	},

	-- === PUNCHING HIGH (Pico attacks high) ===
	["punchhigh"] = {
		picoHit = "punchHigh1",       darnellHit = "hitHigh",
		picoMiss = "punchHigh1",      darnellMiss = "dodge",
		healthHit = 2, healthMiss = -3,
	},
	["punchhighblocked"] = {
		picoHit = "punchHigh2",       darnellHit = "block",
		picoMiss = "hitHigh",         darnellMiss = "block",
		healthHit = 0, healthMiss = -3,
	},
	["punchhighspin"] = {
		picoHit = "punchHigh1",       darnellHit = "hitSpin",
		picoMiss = "punchHigh1",      darnellMiss = "dodge",
		healthHit = 3, healthMiss = -5,
	},

	-- === PUNCHING LOW (Pico attacks low) ===
	["punchlow"] = {
		picoHit = "punchLow1",        darnellHit = "hitLow",
		picoMiss = "punchLow1",       darnellMiss = "dodge",
		healthHit = 2, healthMiss = -3,
	},
	["punchlowblocked"] = {
		picoHit = "punchLow2",        darnellHit = "block",
		picoMiss = "hitLow",          darnellMiss = "block",
		healthHit = 0, healthMiss = -3,
	},
	["punchlowdodged"] = {
		picoHit = "punchLow1",        darnellHit = "dodge",
		picoMiss = "hitLow",          darnellMiss = "dodge",
		healthHit = 0, healthMiss = -3,
	},
	["punchlowspin"] = {
		picoHit = "punchLow2",        darnellHit = "hitSpin",
		picoMiss = "punchLow2",       darnellMiss = "dodge",
		healthHit = 3, healthMiss = -5,
	},

	-- === DODGING (Pico dodges Darnell's attack) ===
	["dodgehigh"] = {
		picoHit = "dodge",            darnellHit = "punchHigh2",
		picoMiss = "hitHigh",         darnellMiss = "punchHigh2",
		healthHit = 2, healthMiss = -6,
	},
	["dodgelow"] = {
		picoHit = "dodge",            darnellHit = "punchLow2",
		picoMiss = "hitLow",          darnellMiss = "punchLow2",
		healthHit = 2, healthMiss = -6,
	},

	-- === HITTING (auto-played opponent notes: d >= 4) ===
	["hithigh"] = {
		picoAuto = "punchHigh1",      darnellAuto = "hitHigh",
		healthAuto = 3,
	},
	["hitlow"] = {
		picoAuto = "punchLow1",       darnellAuto = "hitLow",
		healthAuto = 3,
	},

	-- === UPPERCUTS ===
	["picouppercutprep"] = {
		picoHit = "uppercutPrep",     darnellHit = "idle",
		picoMiss = "hitHigh",         darnellMiss = "punchHigh1",
		healthHit = 0, healthMiss = -3,
	},
	["picouppercut"] = {
		picoHit = "uppercutPunch",    darnellHit = "uppercutHit",
		picoMiss = "hitHigh",         darnellMiss = "dodge",
		healthHit = 5, healthMiss = -8,
		picoLoop = true,
		darnellFreeze = true,
		holdTimer = 999999,
	},
	["darnelluppercutprep"] = {
		picoAuto = "idle",            darnellAuto = "uppercutPrep",
		healthAuto = 0,
	},
	["darnelluppercut"] = {
		picoAuto = "uppercutHit",     darnellAuto = "uppercutPunch",
		healthAuto = -5,
		picoAutoFreeze = true,
		darnellAutoLoop = true,
		holdTimer = 999999,
	},

	-- === SPECIAL ===
	["fakeout"] = {
		picoHit = "fakeHit",          darnellHit = "fakeHit",
		picoMiss = "idle",            darnellMiss = "idle",
		healthHit = 2, healthMiss = -1,
	},
	["taunt"] = {
		picoHit = "taunt",            darnellHit = "pissed",
		picoMiss = "idle",            darnellMiss = "idle",
		healthHit = 2, healthMiss = -1,
		holdTimer = 40,
	},
	["idle"] = {
		picoAuto = "idle",            darnellAuto = "idle",
		healthAuto = 0,
	},
}

-- =====================================================================
-- ANIMATION HOLD DURATION (ticks before idle can interrupt)
-- =====================================================================
local DEFAULT_HOLD_TICKS = 30
local LONG_HOLD_TICKS = 50
local FOREVER_HOLD = 999999

local animHoldTicks = {
	["uppercutHit"] = LONG_HOLD_TICKS,
	["uppercutPunch"] = LONG_HOLD_TICKS,
	["uppercutPrep"] = LONG_HOLD_TICKS,
	["hitSpin"] = LONG_HOLD_TICKS,
	["hitHigh"] = LONG_HOLD_TICKS,
	["hitLow"] = LONG_HOLD_TICKS,
	["taunt"] = 50,
	["fakeHit"] = 40,
	["pissed"] = 50,
	["cringe"] = LONG_HOLD_TICKS,
}

local function getHoldTicks(animName)
	return animHoldTicks[animName] or DEFAULT_HOLD_TICKS
end

-- =====================================================================
-- DRAW ORDER (z-ordering)
-- The attacker draws ON TOP so their fist passes in front of the
-- character who is dodging/blocking.
-- =====================================================================
local currentDrawOrder = "picoOnTop"

local darnellOnTopKinds = {
	["blockhigh"] = true,
	["blocklow"] = true,
	["blockspin"] = true,
	["dodgehigh"] = true,
	["dodgelow"] = true,
	["darnelluppercutprep"] = true,
	["darnelluppercut"] = true,
}

local function updateDrawOrder(noteKind)
	if darnellOnTopKinds[noteKind] then
		currentDrawOrder = "darnellOnTop"
	else
		currentDrawOrder = "picoOnTop"
	end
end

function blazinFight.getDrawOrder()
	return currentDrawOrder
end

-- =====================================================================
-- State
-- =====================================================================
local weekRef = nil
local weeksRef = nil
local initialized = false

-- =====================================================================
-- PUBLIC API
-- =====================================================================

function blazinFight.init(weekSelf)
	weekRef = weekSelf
	initialized = true
	_G.currentWeek = blazinFight
	weeksRef = weeks
	currentDrawOrder = "picoOnTop"
end

function blazinFight.cleanup()
	initialized = false
	weekRef = nil
	weeksRef = nil
	currentDrawOrder = "picoOnTop"
end

local function isBlazinNote(note)
	return note.noteKind ~= nil
end

local function getKindAnims(kindName)
	return noteKindAnims[kindName]
end

local function holdSprite(spriteId, ticks)
	if weeksRef and weeksRef.setSpriteTimer then
		weeksRef:setSpriteTimer(spriteId, ticks)
	end
end

-- =====================================================================
-- HOOKS called by weeks.lua
-- =====================================================================

function blazinFight.customNoteHit(self, curAnim, note, bfSprite)
	if not isBlazinNote(note) then return false end
	local anims = getKindAnims(note.noteKind)
	if not anims then
		print("blazinFight: unknown noteKind '" .. tostring(note.noteKind) .. "'")
		return false
	end

	updateDrawOrder(note.noteKind)

	local holdTime = anims.holdTimer or nil

	-- Animate Pico
	if anims.picoHit and bfSprite then
		if anims.picoLoop then
			bfSprite:animate(anims.picoHit, true)
		else
			bfSprite:animate(anims.picoHit, false)
		end
		holdSprite(3, holdTime or getHoldTicks(anims.picoHit))
	end

	-- Animate Darnell
	if anims.darnellHit and enemy then
		if anims.darnellFreeze then
			enemy:animate(anims.darnellHit, false)
			holdSprite(2, FOREVER_HOLD)
		else
			enemy:animate(anims.darnellHit, false)
			holdSprite(2, holdTime or getHoldTicks(anims.darnellHit))
		end
	end

	if anims.healthHit and anims.healthHit ~= 0 then
		health = health + anims.healthHit
	end
	return true
end

function blazinFight.customNoteMiss(self, curAnim, note, bfSprite)
	if not isBlazinNote(note) then return false end
	local anims = getKindAnims(note.noteKind)
	if not anims then return false end

	updateDrawOrder(note.noteKind)

	if anims.picoMiss and bfSprite then
		bfSprite:animate(anims.picoMiss, false)
		holdSprite(3, getHoldTicks(anims.picoMiss))
	end

	if anims.darnellMiss and enemy then
		enemy:animate(anims.darnellMiss, false)
		holdSprite(2, getHoldTicks(anims.darnellMiss))
	end

	if anims.healthMiss then
		local extra = anims.healthMiss + 2
		if extra ~= 0 then health = health + extra end
	end
	return true
end

function blazinFight.customNoteHold(self, curAnim, note, bfSprite)
	return false
end

-- =====================================================================
-- ENEMY AUTO-PLAY HANDLER
-- =====================================================================

function blazinFight.onEnemyNoteHit(noteKind)
	if not noteKind then return end
	local anims = getKindAnims(noteKind)
	if not anims then return end

	updateDrawOrder(noteKind)

	local picoAnim = anims.picoAuto or anims.picoHit
	local darnellAnim = anims.darnellAuto or anims.darnellHit
	local holdTime = anims.holdTimer or nil

	-- Animate Pico
	if picoAnim and boyfriend then
		if anims.picoAutoFreeze then
			boyfriend:animate(picoAnim, false)
			holdSprite(3, FOREVER_HOLD)
		else
			boyfriend:animate(picoAnim, false)
			holdSprite(3, holdTime or getHoldTicks(picoAnim))
		end
	end

	-- Animate Darnell
	if darnellAnim and enemy then
		if anims.darnellAutoLoop then
			enemy:animate(darnellAnim, true)
			holdSprite(2, FOREVER_HOLD)
		else
			enemy:animate(darnellAnim, false)
			holdSprite(2, holdTime or getHoldTicks(darnellAnim))
		end
	end

	if anims.healthAuto and anims.healthAuto ~= 0 then
		health = health + anims.healthAuto
	end
end

blazinFight.noteKindAnims = noteKindAnims
return blazinFight