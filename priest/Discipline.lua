require('Common.Dispell')

local SPELL_DESPERATE_PRAYER = Spell(19236, 100)
local SPELL_SMITE = Spell(585)
local SPELL_PENANCE = Spell(47540)
local SPELL_PWD_SOLACE = Spell(129250)
local SPELL_PURGE_THE_WICKED = Spell(204197)
local SPELL_PURIFY = Spell(527)
local SPELL_PWD_SHIELD = Spell(17)
local SPELL_SHADOW_MEND = Spell(186263)
local SPELL_PWD_RADIANCE = Spell(194509)
local SPELL_PAIN_SUPRESSION = Spell(33206)
local SPELL_SHADOW_COVENANT = Spell(204065)
local SPELL_FADE = Spell(586, 100)
local SPELL_LEAP_OF_FAITH = Spell(73325)

local AURA_ATONEMENT = 194384
local AURA_PURGETHEWICKED = 204213
local AURA_RAPTURE = 47536
local AURA_PWDSHIELD = 17

local NPC_TEMPLE = 133392 -- Avatar ID
local DebuffID = 274148 -- Avatar in temple debuff.

local Settings =
{
	DamageManaPercentAbove = 5, -- Main healing is from damage.
	-- Higher value = more healing
	OutOfCombatMultipler = 0.7, -- Make this higher on grievous weeks.
	HealMultiplier = 1.25, -- Lower if it seems to spam too much healing, increase if tank is Demon hunter.
	ManaMultiplier = 0.30,
	RaidMultiplier = 0.60 
}

local Discipline = {}


function Discipline.DoCombat(player, target)
	local sprop = player:GetCurrentSpell()
	if player:IsDead() or
		player:IsMounted() or
		player:HasTerrainSpellActive() or
		sprop ~= nil and sprop:GetSpellId() == 47540 then -- Do not cancel channel of Penance.
		return
	end

	-- Healing
	local healTargets = Discipline.FindHealingTargets(player)
	local numHealTargets = 0
	local CastRadiance = false
	local CastCovenant = false
	local ATONEMENTUp = false
	local recastATONEMENT = true
	local foundTank = nil
	local healNpc = false
	local npcToHeal = nil

	local getNpc = player:GetNearbyFriendlyUnits(30)
	for i = 1, #getNpc do
		if getNpc[i]:GetEntry() == NPC_TEMPLE and not getNpc[i]:HasAura(DebuffID) then
			healNpc = true
			npcToHeal = getNpc[i]
		end
	end

	if healNpc then -- Avatar in temple of seth healing.
			if SPELL_PENANCE:CanCast(npcToHeal) then
				SPELL_PENANCE:Cast(npcToHeal)
				return
			end
			if SPELL_SHADOW_MEND:CanCast(npcToHeal) then
				SPELL_SHADOW_MEND:Cast(npcToHeal)
				return
			end
	end

	-- First pass (set variables and such)
	for unit, score in spairs(healTargets, function(t, a, b) return t[b] < t[a] end) do
		local ATONEMENT = unit:GetAura(AURA_ATONEMENT)

		-- Check ATONEMENT. This is used if there are not tanks around
		if ATONEMENT ~= nil then
			ATONEMENTUp = true
			if score < 25 then
				recastATONEMENT = true
			end
		end

		-- Check if unit is tank
		if unit:GroupRole() == 1 then
			foundTank = unit
		end

		-- RADIANCE & Covenant
		if score > 35 then
			numHealTargets = numHealTargets + 1
		end

		-- Dispell, find a new place for this?
		if ShouldDispell(unit) and SPELL_PURIFY:CanCast(unit) then
			SPELL_PURIFY:Cast(unit)
			return
		end
	end

	if ((player:InRaid() and numHealTargets > 4) or numHealTargets > 2) and SPELL_PWD_RADIANCE:CanCast() then
		CastRadiance = true
	end

	if ((player:InRaid() and numHealTargets > 4) or numHealTargets > 2) and SPELL_SHADOW_COVENANT:CanCast() then
		CastCovenant = true
	end

	-- Second pass (do healing)
	for unit, score in spairs(healTargets, function(t, a, b) return t[b] < t[a] end) do
		local atone = unit:GetAuraByPlayer(AURA_ATONEMENT)

		-- SELF HEALS.
		if player:GetHealthPercent() < 40 and SPELL_DESPERATE_PRAYER:CanCast() then
			SPELL_DESPERATE_PRAYER:Cast(player)
			return
		end

		-- FADE OUT
		if player:GetHealthPercent() < 60 and SPELL_FADE:CanCast() then
			SPELL_FADE:Cast(player)
			return
		end

		-- LEAP BETA TEST!
		if score > 110 and SPELL_LEAP_OF_FAITH:CanCast(unit) then
			SPELL_LEAP_OF_FAITH:Cast(unit)
			return
		end

		-- PAIN SUPPRESS
		if score > 80 and SPELL_PAIN_SUPRESSION:CanCast(unit) then
			SPELL_PAIN_SUPRESSION:Cast(unit)
			return
		end

		if score > 25 and player:HasAura(AURA_RAPTURE) and not unit:HasAuraByPlayer(AURA_PWDSHIELD) and (unit:InParty() or unit:InRaid()) then
			SPELL_PWD_SHIELD:Cast(unit)
			return
		end
		
		if player:HasAura(AURA_RAPTURE) and not unit:HasAuraByPlayer(AURA_PWDSHIELD) and (unit:InParty() or unit:InRaid()) then
			SPELL_PWD_SHIELD:Cast(unit)
			return
		end

		-- Covenant
		if CastCovenant and SPELL_SHADOW_COVENANT:CanCast(unit) then
			SPELL_SHADOW_COVENANT:Cast(unit)
			return
		end

		-- RADIANCE
		if CastRadiance and SPELL_PWD_RADIANCE:CanCast(unit) then
			SPELL_PWD_RADIANCE:Cast(unit)
			return
		end
		
		-- Atonement checking the tank.
		if not ATONEMENTUp then
			if foundTank ~= nil and SPELL_PWD_SHIELD:CanCast(foundTank) and foundTank:InCombat() then
				SPELL_PWD_SHIELD:Cast(foundTank)
				return
			elseif foundTank == nil and recastATONEMENT and score > 30 and SPELL_PWD_SHIELD:CanCast(unit) and unit:InCombat() then
				SPELL_PWD_SHIELD:Cast(unit)
				return
			end
		end

		-- KEEP ATONE UP ON PEOPLE IF DAMAGE IS TAKEN.
		if score > 15 and atone == nil and SPELL_PWD_SHIELD:CanCast(unit) then
			SPELL_PWD_SHIELD:Cast(unit)
			return
		end

		-- SHADOW MEND TO KEEP UP WITH HIGH DAMAGE TAKEN.
		if score > 45 and SPELL_SHADOW_MEND:CanCast(unit) and not player:IsMoving() then
			SPELL_SHADOW_MEND:Cast(unit)
			return
		end
	end

	-- Only continue if we should attack and mana percentage is over 70%
	if not ShouldAttack(player, target) then
		return
	end
	
	-- Damage
	if SPELL_PURGE_THE_WICKED:CanCast(target) and not target:HasDebuffByPlayer(AURA_PURGETHEWICKED) then
		SPELL_PURGE_THE_WICKED:Cast(target)
		return
	end

	if SPELL_PWD_SOLACE:CanCast(target) and player:GetManaPercent() < 100 then
		SPELL_PWD_SOLACE:Cast(target)
		return
	end

	if SPELL_PENANCE:CanCast(target) then
		SPELL_PENANCE:Cast(target)
		return
	end

	if SPELL_SMITE:CanCast(target) then
		SPELL_SMITE:Cast(target)
		return
	end

	
end

function Discipline.FindHealingTargets(player)
	local ret = {}
	local nearby = player:GetNearbyFriendlyPlayers(40)
	table.insert(nearby, player)

	for i = 1, #nearby do
		local score = 0

		if nearby[i]:InParty() or nearby[i]:InRaid() then
			score = score + 10
			if nearby[i]:GroupRole() == 1 then -- tank
				score = score + 20
			elseif nearby[i]:GroupRole() == 3 then -- damage
				score = score + 10
			elseif nearby[i]:GroupRole() == 2 then -- healer
				score = score + 10
			end
		end

		score = score + (100 - nearby[i]:GetHealthPercent())

		if not player:HasAura(AURA_INNERVATE) then
			score = score - ((100 - player:GetManaPercent()) * Settings.ManaMultiplier)
		else
			score = score + 40
		end

		if player:InRaid() then
			score = score * Settings.RaidMultiplier
		end

		if not nearby[i]:InCombat() then
			score = score * Settings.OutOfCombatMultipler
		end

		score = score * Settings.HealMultiplier

		if score > 0 or nearby[i]:InCombat() then
			ret[nearby[i]] = score
		end
	end

	return ret
end

return Discipline