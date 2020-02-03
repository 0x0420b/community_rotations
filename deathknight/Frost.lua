-- TODO
-- Implement CD usage and talents

local SPELL_REMORSELESS_WINTER = Spell(196770, 12)
local SPELL_HOWLING_BLAST = Spell(49184)
local SPELL_OBLITERATE = Spell(49020)
local SPELL_EMP_RUNE_WEAPON = Spell(47568, 10)
local SPELL_HORN_OF_WINTER = Spell(57330, 10)
local SPELL_PILLAR_OF_FROST = Spell(51271, 10)
local SPELL_FROST_STRIKE = Spell(49143)
local SPELL_DEATH_STRIKE = Spell(49998)

local AURA_DARK_SUCCOR = 101568
local AURA_KILLING_MACHINE = 51124
local AURA_RIME = 59052

local Frost = {}

function Frost.DoCombat(player, target)
	if player:HasAura(AURA_DARK_SUCCOR) and SPELL_DEATH_STRIKE:CanCast(target) then
		SPELL_DEATH_STRIKE:Cast(target)
		return
	end

	if #player:GetNearbyEnemyUnits(12) > 2 then
		Frost.AoERotation(player, target)
	else
		Frost.SingleRotation(player, target)
	end
end

function Frost.AoERotation(player, target)
	Frost.SingleRotation(player, target)
end

function Frost.SingleRotation(player, target)
	Frost.NormalSingleRotation(player, target)
end

function Frost.NormalSingleRotation(player, target)
	if SPELL_REMORSELESS_WINTER:CanCast(target) then
		SPELL_REMORSELESS_WINTER:Cast(player)
		return
	end

	if SPELL_HOWLING_BLAST:CanCast(target) and player:HasAura(AURA_RIME) then
		SPELL_HOWLING_BLAST:Cast(target)
		return
	end

	if SPELL_OBLITERATE:CanCast(target) and player:NumRunesReady() > 3 then
		SPELL_OBLITERATE:Cast(target)
		return
	end

	if SPELL_FROST_STRIKE:CanCast(target) and player:GetRunicPower() > 90 then
		SPELL_FROST_STRIKE:Cast(target)
		return
	end

	if SPELL_OBLITERATE:CanCast(target) and player:HasAura(AURA_KILLING_MACHINE) then
		SPELL_OBLITERATE:Cast(target)
		return
	end

	if SPELL_FROST_STRIKE:CanCast(target) and player:GetRunicPower() > 75 then
		SPELL_FROST_STRIKE:Cast(target)
		return
	end

	if SPELL_OBLITERATE:CanCast(target) then
		SPELL_OBLITERATE:Cast(target)
		return
	end

	if SPELL_FROST_STRIKE:CanCast(target) then
		SPELL_FROST_STRIKE:Cast(target)
		return
	end
end

return Frost