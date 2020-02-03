local SPELL_MOONFIRE = Spell(8921)
local SPELL_SUNFIRE = Spell(93402)
local SPELL_STELLAR_FLARE = Spell(202347)
local SPELL_STARSURGE = Spell(78674)
local SPELL_LUNAR_STRIKE = Spell(194153)
local SPELL_SOLAR_WRATH = Spell(190984)
local SPELL_STARFALL = Spell(191034, 40)
local SPELL_BARKSKIN = Spell(22812)
local SPELL_ENTANGLING_ROOTS = Spell(339)
local SPELL_HIBERNATE = Spell(2637)
local SPELL_CELESTIAL_ALIGNMENT = Spell(194223, 100)
local SPELL_INCARNATION = Spell(102560, 100)
local SPELL_INNERVATE = Spell(29166)
local SPELL_SOLAR_BEAM = Spell(78675)
local SPELL_REGROWTH = Spell(8936)
local SPELL_SOOTHE = Spell(2908)
local SPELL_REMOVE_CORRUPTION = Spell(2782)
local SPELL_WARRIOR_OF_ELUNE = Spell(202425, 100)
local SPELL_MOONKINFORM = Spell(24858)
local SPELL_SWIFTMEND = Spell(18562)
local SPELL_REJUVENATION = Spell(774)
local SPELL_FORCE_OF_NATURE = Spell(205636, 40)
local SPELL_NEW_MOON = Spell(274281)
local SPELL_HALF_MOON = Spell(274282)
local SPELL_FULL_MOON = Spell(274283)
local SPELL_BEAR_FORM = Spell(5487)
local SPELL_RENEWAL = Spell(108238, 100)
local SPELL_FURY_OF_ELUNE = Spell(202770)
local SPELL_TRAVEL_FORM = Spell(783)

local SPELL_CONCENTRATED_FLAME = Spell(295373)

local RACIAL_BERSERKING = Spell(26297, 100)

local AURA_PROWL = 5215
local AURA_MOONFIRE = 164812
local AURA_SUNFIRE = 164815
local AURA_LUNAR_EMPOWERMENT = 164547
local AURA_SOLAR_EMPOWERMENT = 164545
local AURA_STELLAR_FLARE = 202347
local AURA_CATFORM = 768
local AURA_BEARFORM = 5487
local AURA_TRAVELFORM = 783
local AURA_OWLKIN_FRENZY = 157228
local AURA_WARRIOR_OF_ELUNE = 202425
local AURA_ENTANGLING_ROOTS = 339
local AURA_MOONKIN_FORM = 24858

local shouldCD = false
local shouldTravel = false
local shouldMoonkin = false




-- SETTINGS :)

-- SETTINGS :)

local Balance = {}

function Balance.DoCombat(player, target)
	local aoeTarget = BestAoETarget(player, 40, 12)

	if shouldCD then
		DrawText('(SHIFT + R) Cooldowns [[ON]]', Vec2(200, 200))
	else
		DrawText('(SHIFT + R) Cooldowns [OFF]', Vec2(200, 200))
	end

	if shouldTravel then
		DrawText('(SHIFT + W) Travel Form [[ON]]', Vec2(200, 250))
	else
		DrawText('(SHIFT + W) Travel Form [OFF]', Vec2(200, 250))
	end

	if shouldMoonkin then
		DrawText('(SHIFT + E) Moonkin Form [[ON]]', Vec2(200, 300))
	else
		DrawText('(SHIFT + E) Moonkin Form [[OFF]]', Vec2(200, 300))
	end

	if player:HasAura(AURA_PROWL) or player:IsDead() then
		return
	end

	if shouldMoonkin and not player:HasAura(AURA_MOONKIN_FORM) and SPELL_MOONKINFORM:CanCast(player) then
		SPELL_MOONKINFORM:Cast(player)
		return
	end

	if shouldTravel and not player:HasAura(AURA_TRAVELFORM) and SPELL_TRAVEL_FORM:CanCast(player) then
		SPELL_TRAVEL_FORM:Cast(player)
		return
	end

	if not shouldTravel and player:HasAura(AURA_TRAVELFORM) and SPELL_TRAVEL_FORM:CanCast(player) then
		SPELL_TRAVEL_FORM:Cast(player)
		return
	end

	if player:InCombat() and #player:GetNearbyEnemyUnits(10) > 0 and SPELL_BARKSKIN:CanCast(player) and player:GetHealthPercent() < 80 then
		SPELL_BARKSKIN:Cast(player)
		return
	end

	if IsShapeshifted(player) then
		return
	end

	if aoeTarget and #aoeTarget:GetNearbyEnemyUnits(15) > 2 and SPELL_STARFALL:CanCast() then
		SPELL_STARFALL:CastAoF(aoeTarget:GetPosition())
		return
	end

	if shouldCD and SPELL_INCARNATION:CanCast(player) then
		SPELL_INCARNATION:Cast(player)
		return
	end

	if target and target:IsEnemyWithPlayer() and not AffectedbyCCOrImmune(target) and (target:InCombat() or player:InCombat()) then
		if shouldCD and SPELL_FORCE_OF_NATURE:CanCast(target) then
			SPELL_FORCE_OF_NATURE:CastAoF(target:GetPosition())
			return
		end

		if shouldCD and SPELL_FURY_OF_ELUNE:CanCast(target) then
			SPELL_FURY_OF_ELUNE:Cast(target)
			return
		end

		if #target:GetNearbyEnemyUnits(16) < 3 then
			SingleBoomy(player, target)
		else
			MultiBoomy(player, target)
		end
	end
end

function MultiBoomy(player, target)
	local dotTargets = GetDotTargets(player, 40)

	for i = 1, #dotTargets do
		if not dotTargets[i]:HasAura(AURA_MOONFIRE) and SPELL_MOONFIRE:CanCast(dotTargets[i]) then
			SPELL_MOONFIRE:Cast(dotTargets[i])
			return
		end
		if not dotTargets[i]:HasAura(AURA_SUNFIRE) and SPELL_SUNFIRE:CanCast(dotTargets[i]) then
			SPELL_SUNFIRE:Cast(dotTargets[i])
			return
		end
	end

	SingleBoomy(player, target)
end

function SingleBoomy(player, target)
	if SPELL_CONCENTRATED_FLAME:CanCast(target) then
		SPELL_CONCENTRATED_FLAME:Cast(target)
		return
	end

	if SPELL_STARSURGE:CanCast(target) then
		SPELL_STARSURGE:Cast(target)
		return
	end

	if not target:HasAura(AURA_SUNFIRE) then
		SPELL_SUNFIRE:Cast(target)
		return
	end

	if player:HasAura(AURA_OWLKIN_FRENZY) and SPELL_LUNAR_STRIKE:CanCast(target) then
		SPELL_LUNAR_STRIKE:Cast(target)
		return
	end

	if not target:HasAura(AURA_MOONFIRE) or player:IsMoving() then
		SPELL_MOONFIRE:Cast(target)
		return
	end

	if not player:IsMoving() then	
		if player:HasAura(AURA_LUNAR_EMPOWERMENT) and SPELL_LUNAR_STRIKE:CanCast(target) then
			SPELL_LUNAR_STRIKE:Cast(target)
			return
		end

		if player:HasAura(AURA_SOLAR_EMPOWERMENT) and SPELL_SOLAR_WRATH:CanCast(target) then
			SPELL_SOLAR_WRATH:Cast(target)
			return
		end

		if #target:GetNearbyEnemyUnits(8) < 2 and SPELL_SOLAR_WRATH:CanCast(target) then
			SPELL_SOLAR_WRATH:Cast(target)
			return
		end

		if #target:GetNearbyEnemyUnits(8) > 1 and SPELL_LUNAR_STRIKE:CanCast(target) then
			SPELL_LUNAR_STRIKE:Cast(target)
			return
		end
	end
end

function BestAoETarget(player, range, nearRange)
	local units = player:GetNearbyEnemyUnits(range)
	local bestUnit = nil
	local bestNum = 0
	for i = 1, #units do
		if units[i]:InCombat() and not AffectedbyCCOrImmune(units[i]) then
		local nearUnits = units[i]:GetNearbyEnemyUnits(nearRange)
		if #nearUnits > bestNum then
			bestNum = #nearUnits
			bestUnit = units[i]
		end
	end
end
	return bestUnit
end

function KeyPress(event, key, modifiers)
    pressedShift = (modifiers & 1) > 0
    pressedCtrl = (modifiers & 2) > 0
	pressedAlt = (modifiers & 4) > 0

	if pressedShift and key == 69 and not shouldMoonkin then
		shouldTravel = false
		shouldMoonkin = true
		return
	end

	if pressedShift and key == 69 and shouldMoonkin then
		shouldTravel = false
		shouldMoonkin = false
		return
	end

	if pressedShift and key == 82 and not shouldCD then
		shouldCD = true
		return
	end

	if pressedShift and key == 82 and shouldCD then
		shouldCD = false
		return
	end

	if pressedShift and key == 87 and not shouldTravel then
		shouldTravel = true
		shouldMoonkin = false
		return
	end

	if pressedShift and key == 87 and shouldTravel then
		shouldTravel = false
		shouldMoonkin = false
		return
	end
end


function IsShapeshifted(player)
	if player:HasAura(AURA_CATFORM) or player:HasAura(AURA_BEARFORM) or player:HasAura(AURA_TRAVELFORM) then
		return true
	end

	return false
end

function AffectedbyCCOrImmune(unit)
	-- 115078 = Paralysis
	-- 122 = Frost nova
	-- 62115 = Polymorph
	-- 339 = Entangling roots
	-- 102359 = Mass entangle
	-- 209753 = Cyclone
	-- 2637 = Hibernate
	-- 217832 = Imprison
	-- 3355 = Freezing trap
	-- 642 = Bubble
	-- 20066 = Repentance
	-- 105421 = Blinding light
	-- 51514 = Hex
	-- 31224 = Cloak of shadows
	-- 47585 = Dispersion
	-- 260792 = Dust cloud
	local bads = {115078, 122, 62115, 339, 102359, 209753, 2637, 217832, 3355, 642, 20066, 105421, 51514, 31224, 47585, 260792}
	for i = 1, #bads do
		if unit:HasAura(bads[i]) then
			return true
		end
	end
	return false
end

function GetEnemiesNearbyMe(player, range)
	local targets = player:GetNearbyEnemyUnits(range)
	local realtargets = {}
	for i = 1, #targets do
		if targets[i]:InCombat() and not AffectedbyCCOrImmune(targets[i]) then
			table.insert(realtargets, targets[i])
		end
	end
	return realtargets
end

function GetDotTargets(player, range)
	local targets = player:GetNearbyEnemyUnits(range)
	local realtargets = {}
	for i = 1, #targets do
		if targets[i]:InCombat() and not AffectedbyCCOrImmune(targets[i]) and targets[i]:GetHealth() > DotHealth(player) and not targets[i]:IsTapDenied() then
			table.insert(realtargets, targets[i])
		end
	end
	return realtargets
end

function DotHealth(player)
	if player:InParty() then
		return 500000
	else if player:InRaid() then
		return 2000000
	else
		return 100000
	end
end
end

RegisterEvent(4, KeyPress)


return Balance