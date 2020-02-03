require('Common.Dispell')

local SPELL_HEALING_TIDE_TOTEM = Spell(108280)
local SPELL_HEALING_STREAM_TOTEM = Spell(5394)
local SPELL_SPIRIT_LINK_TOTEM = Spell(98008)
local SPELL_EARTHEN_WALL_TOTEM = Spell(198838)
local SPELL_SPIRIT_WALKERS_GRACE = Spell(79206)
local SPELL_TREMOR_TOTEM = Spell(8143)
local SPELL_PURIFY_SPIRIT = Spell(77130)
local SPELL_CHAIN_HEAL = Spell(1064)
local SPELL_RIPTIDE = Spell(61295)
local SPELL_EARTH_SHIELD = Spell(974)
local SPELL_ASTRAL_SHIFT = Spell(108271)
local SPELL_UNLEASH_LIFE = Spell(73685)
local SPELL_HEALING_WAVE = Spell(77472)
local SPELL_HEALING_SURGE = Spell(8004)
local SPELL_FLAME_SHOCK = Spell(188838)
local SPELL_LIGHTNING_BOLT = Spell(403)
local SPELL_LAVA_BURST = Spell(51505)
local SPELL_CHAIN_LIGHTNING = Spell(421)

local AURA_RIPTIDE = 61295
local AURA_GHOST_WOLF = 2645
local AURA_EARTH_SHIELD = 974
local AURA_FLAME_SHOCK = 188838
local AURA_LAVA_SURGE = 77762

local Settings =
{
	DamageManaPercentAbove = 70,
	-- Higher value = more healing
	OutOfCombatMultipler = 0.50,
	HealMultiplier = 1.00,
	ManaMultiplier = 0.30,
	RaidMultiplier = 0.60
}

local Restoration = {}

function Restoration.IsShapeshifted(player)
	if player:HasAura(AURA_GHOST_WOLF) then
		return true
	end

	return false
end

function Restoration.DoCombat(player, target)
	if player:IsDead() or
		player:IsMounted() or
		player:IsCasting() or
		player:IsChanneling() or
		player:HasTerrainSpellActive() or
		Restoration.IsShapeshifted(player) then
		return
	end

	-- Healing
	local healTargets = Restoration.FindHealingTargets(player)
	local numHealTargets = 0
	local castChainHeal = false
	local castBigTotem = false
	local earthshieldUP = false
	local recastEarthshield = true
	local foundTank = nil


	-- First pass (set variables and such)
	for unit, score in spairs(healTargets, function(t, a, b) return t[b] < t[a] end) do
		local riptide = unit:GetAuraByPlayer(AURA_RIPTIDE)
		local earthshield = unit:GetAuraByPlayer(AURA_EARTH_SHIELD)

		-- Check Earth Shield. This is used if there are not tanks around
		if earthshield ~= nil then
			earthshieldUP = true
			if earthshield:GetStacks() < 2 and score < 25 then
				recastEarthshield = true
			end
		end

		-- Check if unit is tank
		if unit:GroupRole() == 1 then -- tank
			foundTank = unit
		end

		-- Chain heal
		if score > 35 then
			numHealTargets = numHealTargets + 1
		end


		-- Dispell, find a new place for this?
		if ShouldDispell(unit) and SPELL_PURIFY_SPIRIT:CanCast(unit) then
			SPELL_PURIFY_SPIRIT:Cast(unit)
			return
		end
	end

	if ((player:InRaid() and numHealTargets > 4) or numHealTargets > 2) and SPELL_CHAIN_HEAL:CanCast() then
		castChainHeal = true
	end

	if ((player:InRaid() and numHealTargets > 6) or numHealTargets > 3) and SPELL_HEALING_TIDE_TOTEM:CanCast() then
		castBigTotem = true
	end

	-- Second pass (do healing)
	for unit, score in spairs(healTargets, function(t, a, b) return t[b] < t[a] end) do
		local riptide = unit:GetAuraByPlayer(AURA_RIPTIDE)
		local earthshield = unit:GetAuraByPlayer(AURA_EARTH_SHIELD)
		

		-- Astral shift Defensive
		if player:GetHealthPercent() < 50 and SPELL_ASTRAL_SHIFT:CanCast() then
			SPELL_ASTRAL_SHIFT:Cast(player)
			return
		end

		if score > 60 and player:IsMoving() and SPELL_SPIRIT_WALKERS_GRACE:CanCast() then
			SPELL_SPIRIT_WALKERS_GRACE:Cast(player)
			return
		end

		-- LIFESAVED inc.
		if score > 100 and SPELL_SPIRIT_LINK_TOTEM:CanCast(unit) then
			SPELL_SPIRIT_LINK_TOTEM:CastAoF(unit:GetPosition())
			return
		end

		if SPELL_HEALING_TIDE_TOTEM:CanCast() and castBigTotem then
			SPELL_HEALING_TIDE_TOTEM:Cast(player)
			return
		end

		-- Ultra ALPHA BETA test.
		if SPELL_EARTHEN_WALL_TOTEM:CanCast(unit) and castChainHeal then
			SPELL_EARTHEN_WALL_TOTEM:CastAoF(unit:GetPosition())
			return
		end

		-- Chain heal BETA
		if not player:IsMoving() and castChainHeal and SPELL_CHAIN_HEAL:CanCast(unit) then
			SPELL_CHAIN_HEAL:Cast(unit)
			return
		end

		-- Riptide for everyone!
		if score > 25 and riptide == nil and SPELL_RIPTIDE:CanCast(unit) then
			SPELL_RIPTIDE:Cast(unit)
			return
		end
		
		-- Earth Shield
		if not earthshieldUP then
			if foundTank ~= nil and SPELL_EARTH_SHIELD:CanCast(foundTank) and foundTank:InCombat() then
				SPELL_EARTH_SHIELD:Cast(foundTank)
				return
			elseif foundTank == nil and recastEarthshield and score > 30 and SPELL_EARTH_SHIELD:CanCast(unit) and unit:InCombat() then
				SPELL_EARTH_SHIELD:Cast(unit)
				return
			end
		end

		-- UP THE HEAL UP
		if score > 55 and SPELL_UNLEASH_LIFE:CanCast(unit) then
			SPELL_UNLEASH_LIFE:Cast(unit)
			return
		end

		-- FAST HEAL BIATCH
		if score > 50 and SPELL_HEALING_SURGE:CanCast(unit) then
			SPELL_HEALING_SURGE:Cast(unit)
			return
		end

		-- EW TOTEMS?
		if score > 30 and SPELL_HEALING_STREAM_TOTEM:CanCast() then
			SPELL_HEALING_STREAM_TOTEM:Cast(player)
			return
		end

		-- HEALING WAVE
		if not player:IsMoving() and score > 40 and SPELL_HEALING_WAVE:CanCast(unit) then
			SPELL_HEALING_WAVE:Cast(unit)
			return
		end
	end

	-- Only continue if we should attack and mana percentage is over 70%
	if not ShouldAttack(player, target) then
		return
	end
	
	-- Damage
	local FLAMESHOCK = target:GetAuraByPlayer(AURA_FLAME_SHOCK)

	
	if SPELL_LAVA_BURST:CanCast(target) and player:HasAura(AURA_LAVA_SURGE) then
		SPELL_LAVA_BURST:Cast(target)
		return
	end

	if #target:GetNearbyEnemyUnits(10) > 3 and SPELL_CHAIN_LIGHTNING:CanCast(target) then
		SPELL_CHAIN_LIGHTNING:Cast(target)
		return
	end

	if FLAMESHOCK == nil and SPELL_FLAME_SHOCK:CanCast(target) and player:GetManaPercent() > Settings.DamageManaPercentAbove then
		SPELL_FLAME_SHOCK:Cast(target)
		return
	end

	if SPELL_LAVA_BURST:CanCast(target) then
		SPELL_LAVA_BURST:Cast(target)
		return
	end

	if not player:IsMoving() and SPELL_LIGHTNING_BOLT:CanCast(target) then
		SPELL_LIGHTNING_BOLT:Cast(target)
		return
	end
end

function Restoration.FindHealingTargets(player)
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

		score = score - ((100 - player:GetManaPercent()) * Settings.ManaMultiplier)

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

return Restoration