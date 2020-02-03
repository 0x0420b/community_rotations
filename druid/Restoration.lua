require('Common.Dispell')

-- Spells
local SPELL_EFFLORESCENCE = Spell(145205)
local SPELL_REGROWTH = Spell(8936)
local SPELL_REJUVENATION = Spell(774)
local SPELL_LIFEBLOOM = Spell(33763)
local SPELL_SWIFTMEND = Spell(18562)
local SPELL_WILD_GROWTH = Spell(48438)
local SPELL_MOONFIRE = Spell(8921)
local SPELL_SUNFIRE = Spell(93402)
local SPELL_SOLAR_WRATH = Spell(5176)
local SPELL_RENEWAL = Spell(108238)
local SPELL_BARKSKIN = Spell(22812)
local SPELL_IRONBARK = Spell(102342)
local SPELL_CENARION_WARD = Spell(102351)
local SPELL_NATURES_CURE = Spell(88423)
local SPELL_SOOTHE = Spell(2908)
local SPELL_RAKE = Spell(1822)
local SPELL_SHRED = Spell(5221)
local SPELL_RIP = Spell(1079)
local SPELL_FEROCIOUS_BITE = Spell(22568)
local SPELL_SWIPE = Spell(106785)
local SPELL_CAT_FORM = Spell(768)

local AURA_REJUVENATION = 774
local AURA_LIFEBLOOM = 33763
local AURA_GERMINATION = 155777
local AURA_CLEARCASTING = 16870
local AURA_INNERVATE = 29166
local AURA_MOONFIRE = 164812
local AURA_SUNFIRE = 164815
local AURA_CATFORM = 768
local AURA_BEARFORM = 5487
local AURA_TRAVELFORM = 783
local AURA_TREE_OF_LIFE = 117679
local AURA_RAKE = 155722
local AURA_RIP = 1079

local AURA_DARKEST_DEPTHS = 292127
local AURA_WOUNDS = 240559

Settings =
{
	photoSynthesis = false,
	hasGermination = true,
	DamageManaPercentAbove = 70,
	OutOfCombatMultiplier = 50,
	HealMultiplier = 100,
	ManaMultiplier = 30,
	RaidMultiplier = 60
}

local Restoration = {}

function Restoration.IsShapeshifted(player)
	if player:HasAura(AURA_CATFORM) or player:HasAura(AURA_BEARFORM) or player:HasAura(AURA_TRAVELFORM) then
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
	local castWildGrowth = false
	local lifebloomUp = false
	local recastLifebloom = true
	local foundTank = nil

	local enemyUnits = player:GetNearbyEnemyUnits(40)
	for i = 1, #enemyUnits do
		local auras = enemyUnits[i]:GetAuras()
		for k = 1, #auras do
			if auras[k]:GetType() == 9 and SPELL_SOOTHE:CanCast(enemyUnits[i]) then
				SPELL_SOOTHE:Cast(enemyUnits[i])
			end
		end
	end

	if Settings.photoSynthesis then
		if not player:HasAuraByPlayer(AURA_LIFEBLOOM) and player:InCombat() and SPELL_LIFEBLOOM:CanCast(player) then
			SPELL_LIFEBLOOM:Cast(player)
			return
		end
	end

	-- First pass (set variables and such)
	for unit, score in spairs(healTargets, function(t, a, b) return t[b] < t[a] end) do
		local lifebloom = unit:GetAuraByPlayer(AURA_LIFEBLOOM)

		-- Check lifebloom. This is used if there are not tanks around
		if lifebloom then
			lifebloomUp = true
			if lifebloom:GetTimeleft() < 2000 and score < 25 then
				recastLifebloom = true
			end
		end

		-- Check if unit is tank
		if unit:GroupRole() == 1 then
			foundTank = unit
		end

		-- Wild growth
		if score > 35 then
			numHealTargets = numHealTargets + 1
		end

		-- Dispell, find a new place for this?
		if ShouldDispell(unit) and SPELL_NATURES_CURE:CanCast(unit) then
			SPELL_NATURES_CURE:Cast(unit)
			return
		end
	end

	if ((player:InRaid() and numHealTargets > 4) or numHealTargets > 2) and SPELL_WILD_GROWTH:CanCast() then
		castWildGrowth = true
	end

	-- Second pass (do healing)
	for unit, score in spairs(healTargets, function(t, a, b) return t[b] < t[a] end) do
		local rejuv = unit:GetAuraByPlayer(AURA_REJUVENATION)
		local germ = unit:GetAuraByPlayer(AURA_GERMINATION)
		local lifebloom = unit:GetAuraByPlayer(AURA_LIFEBLOOM)
		local clearcast = player:HasAura(AURA_CLEARCASTING)
		local clearcastAura = player:GetAura(AURA_CLEARCASTING)
		local treeOfLife = player:HasAura(AURA_TREE_OF_LIFE)

		-- Renewal
		if player:GetHealthPercent() < 30 and SPELL_RENEWAL:CanCast() then
			SPELL_RENEWAL:Cast(player)
			return
		end

		-- Barkskin
		if player:GetHealthPercent() < 50 and SPELL_BARKSKIN:CanCast() then
			SPELL_BARKSKIN:Cast(player)
			return
		end


		-- Ironbark
		if score > 90 and SPELL_IRONBARK:CanCast(unit) then
			SPELL_IRONBARK:Cast(unit)
			return
		end

		-- Wild growth
		if not player:IsMoving() and castWildGrowth and SPELL_WILD_GROWTH:CanCast(unit) then
			SPELL_WILD_GROWTH:Cast(unit)
			return
		end

		-- Cast regrowth when clearcast has less than 2s left so its not wasted
		if (not player:IsMoving() or treeOfLife) and clearcastAura ~= nil and clearcastAura:GetTimeleft() < 2000 and SPELL_REGROWTH:CanCast(unit) then
			SPELL_REGROWTH:Cast(unit)
			return
		end
		
		-- Lifebloom(With Photosynthesis support which means, lifebloom always up on self if its talented.)
		if not Settings.photoSynthesis then
			if not lifebloomUp then
				if foundTank ~= nil and SPELL_LIFEBLOOM:CanCast(foundTank) and foundTank:InCombat() then
					SPELL_LIFEBLOOM:Cast(foundTank)
					return
				elseif foundTank == nil and recastLifebloom and score > 30 and SPELL_LIFEBLOOM:CanCast(unit) and unit:InCombat() then
					SPELL_LIFEBLOOM:Cast(unit)
					return
				end
			end
		end
		

		-- Cenarion Ward
		if foundTank ~= nil and SPELL_CENARION_WARD:CanCast(foundTank) and foundTank:InCombat() then
			SPELL_CENARION_WARD:Cast(foundTank)
			return
		elseif foundTank == nil and SPELL_CENARION_WARD:CanCast(unit) and unit:InCombat() then
			SPELL_CENARION_WARD:Cast(unit)
			return
		end

		-- Swiftmend if we have prosperity
		if score > 55 and SPELL_SWIFTMEND:GetCharges() == 2 and SPELL_SWIFTMEND:CanCast(unit) then
			SPELL_SWIFTMEND:Cast(unit)
			return
		end

		-- Swiftmend if we have 1 charge or don't have prosperity
		if score > 65 and SPELL_SWIFTMEND:GetCharges() == 1 and SPELL_SWIFTMEND:CanCast(unit) then
			SPELL_SWIFTMEND:Cast(unit)
			return
		end

		-- Regrowth with clearcast
		if (not player:IsMoving() or treeOfLife) and clearcast and score > 35 and SPELL_REGROWTH:CanCast(unit) then
			SPELL_REGROWTH:Cast(unit)
			return
		end

		-- Rejuvenation
		if score > 25 and rejuv == nil and SPELL_REJUVENATION:CanCast(unit) then
			SPELL_REJUVENATION:Cast(unit)
			return
		end

		-- Recast rejuvenation if 2s left
		if score > 25 and rejuv ~= nil and rejuv:GetTimeleft() < 2000 and SPELL_REJUVENATION:CanCast(unit) then
			SPELL_REJUVENATION:Cast(unit)
			return
		end

		if Settings.hasGermination then
			-- Germination
			if score > 40 and rejuv ~= nil and germ == nil and SPELL_REJUVENATION:CanCast(unit) then
				SPELL_REJUVENATION:Cast(unit)
				return
			end

			-- Recast germination
			if score > 40 and rejuv ~= nil and germ ~= nil and germ:GetTimeleft() < 2000 and SPELL_REJUVENATION:CanCast(unit) then
				SPELL_REJUVENATION:Cast(unit)
				return
			end
		end

		-- Regrowth
		if (not player:IsMoving() or treeOfLife) and score > 60 and SPELL_REGROWTH:CanCast(unit) then
			SPELL_REGROWTH:Cast(unit)
			return
		end
	end

	-- Only continue if we should attack and mana percentage is over 70%
	if not ShouldAttack(player, target) then
		return
	end
		
	--[[
	if not player:HasAura(AURA_CATFORM) and SPELL_CAT_FORM:CanCast(player) and player:GetDistance(target) < 7 then
		SPELL_CAT_FORM:Cast(player)
		return
	end

	
	if player:HasAura(AURA_CATFORM)	then
		local rake = target:GetAuraByPlayer(AURA_RAKE)
		local rip = target:GetAuraByPlayer(AURA_RIP)

		if rake == nil and SPELL_RAKE:CanCast(target) then
			SPELL_RAKE:Cast(target)
			return
		end

		if player:GetComboPoints() >= 4 and SPELL_RIP:CanCast(target) and rip == nil then
			SPELL_RIP:Cast(target)
			return
		end

		if rip ~= nil and player:GetComboPoints() >= 4 and SPELL_FEROCIOUS_BITE:CanCast(target) then
			SPELL_FEROCIOUS_BITE:Cast(target)
			return
		end

		if #player:GetNearbyEnemyUnits(8) > 3 and SPELL_SWIPE:CanCast(target) and player:GetComboPoints() < 5 then
			SPELL_SWIPE:Cast(target)
			return
		end

		if rake ~= nil and player:GetComboPoints() < 4 and SPELL_SHRED:CanCast(target) then
			SPELL_SHRED:Cast(target)
			return
		end
	else
		--]]
		-- Damage
		local moonfire = target:GetAuraByPlayer(AURA_MOONFIRE)
		local sunfire = target:GetAuraByPlayer(AURA_SUNFIRE)

		if moonfire == nil and SPELL_MOONFIRE:CanCast(target) and player:GetManaPercent() > 60 then
			SPELL_MOONFIRE:Cast(target)
			return
		end

		if sunfire == nil and SPELL_SUNFIRE:CanCast(target) and player:GetManaPercent() > 60 then
			SPELL_SUNFIRE:Cast(target)
			return
		end

		if not player:IsMoving() and SPELL_SOLAR_WRATH:CanCast(target) then
			SPELL_SOLAR_WRATH:Cast(target)
			return
		end
	--end -- Belongs to catform option
end


--
function Restoration.FindHealingTargets(player)
	local ret = {}
	local nearby = player:GetNearbyFriendlyPlayers(40)
	table.insert(nearby, player)

	for i = 1, #nearby do
		local score = 0

		if nearby[i]:InParty() or nearby[i]:InRaid() then
			score = score + 10

			if nearby[i]:GroupRole() == 1 then
				score = score + 20
			elseif nearby[i]:GroupRole() == 3 then
				score = score + 10
			elseif nearby[i]:GroupRole() == 2 then
				score = score + 10
			end
		end
		
		if nearby[i]:HasAura(AURA_DARKEST_DEPTHS) then
			score = score - 10000
		end

		score = score + (100 - nearby[i]:GetHealthPercent())

		if not player:HasAura(AURA_INNERVATE) then
			score = score - ((100 - player:GetManaPercent()) * (Settings.ManaMultiplier / 100))
		else
			score = score + 40
		end
		
		if player:HasAura(AURA_WOUNDS) then
			score = score + 200
		end

		if player:InRaid() then
			score = score * (Settings.RaidMultiplier / 100)
		end

		if not nearby[i]:InCombat() then
			score = score * (Settings.OutOfCombatMultiplier / 100)
		end

		score = score * (Settings.HealMultiplier / 100)

		if score > 0 or nearby[i]:InCombat() then
			ret[nearby[i]] = score
		end
	end

	return ret
end

return Restoration