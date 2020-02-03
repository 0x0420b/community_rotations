-- TODO
-- Add Glacial Spike rotation
-- Add AoE rotation when >= 5 mobs
-- Add checks if target is Frozen
-- Bugs
-- Doesn't cast Rune of Power

-- Target Spells
local SPELL_ICE_LANCE = Spell(30455)
local SPELL_FLURRY = Spell(44614)
local SPELL_FROZEN_ORB = Spell(84714, 40)
local SPELL_RAY_OF_FROST = Spell(205021)
local SPELL_EBONBOLT = Spell(257537)
local SPELL_COMET_STORM = Spell(153595)
local SPELL_ICE_NOVA = Spell(157997)
local SPELL_FROSTBOLT = Spell(116)
local SPELL_BLIZZARD = Spell(190356, 35)
local SPELL_GLACIAL_SPIKE = Spell(199786)
local SPELL_COUNTERSPELL = Spell(2139)

-- Self Casts
local SPELL_RUNE_OF_POWER = Spell(116011)
local SPELL_MIRROR_IMAGE = Spell(55342)
local SPELL_ICY_VEINS = Spell(12472)
local SPELL_ICE_BARRIER = Spell(11426)

-- Pet
local SPELL_PET_SUMMON = Spell(31687)
local SPELL_PET_FREEZE = Spell(33395, 0, true)
local SPELL_PET_WATERBOLT = Spell(31707, 0, true)

-- Buffs
local AURA_BRAIN_FREEZE = 190446
local AURA_FREEZING_RAIN = 270232
local AURA_FINGERS_OF_FROST = 44544
local AURA_WINTERS_REACH = 0
local AURA_ICICLES = 205473
local AURA_GLACIAL_SPIKE = 199844

-- Debuffs
local AURA_PET_FREEZE = 33395
local AURA_FROST_NOVA = 122
local AURA_ICE_NOVA = 157997
local AURA_GLACIAL_SPIKE_FREEZE = 228600
local AURA_FROSTBITE = 198121

local Frost = {}
Frost.LastSpell = 0
Frost.LastROP = 0

function Frost.IsFrozen(target)
	if target:HasAura(AURA_PET_FREEZE) or target:HasAura(AURA_FROST_NOVA) or target:HasAura(AURA_ICE_NOVA) or target:HasAura(AURA_GLACIAL_SPIKE_FREEZE) or target:HasAura(AURA_FROSTBITE) then
		return true
	end

	return false
end

function Frost.DoCombat(player, target)
	--[[ Proof of concept, it works but we are not smart enough to do this yet.
	local units = player:GetNearbyEnemyUnits(40)
	for i = 1, #units do
		if units[i].IsCasting or units[i].IsChanneling then
			if SPELL_COUNTERSPELL:CanCast(units[i]) then
				SPELL_COUNTERSPELL:Cast(units[i])
				return
			end
		end
	end
	]]--

	if not player:GetPet() and SPELL_PET_SUMMON:CanCast() then
		Frost.Cast(SPELL_PET_SUMMON, player)
		return
	end
	
	if #player:GetNearbyEnemyUnits(12) > 0 and SPELL_ICE_BARRIER:CanCast() then
		Frost.Cast(SPELL_ICE_BARRIER, player)
		return
	end
	
	if #target:GetNearbyEnemyUnits(12) > 1 then
		Frost.AoERotation(player, target)
	else
		Frost.SingleRotation(player, target)
	end
end

function Frost.AoERotation(player, target)
	Frost.SingleRotation(player, target)
end

function Frost.SingleRotation(player, target)
	local isMoving = player:IsMoving()
	
	local pet = player:GetPet()
	if pet and SPELL_PET_FREEZE:CanCast(target) then
		SPELL_PET_FREEZE:Cast(target)
		return
	end
	
	if pet and not pet:IsCasting() and SPELL_PET_WATERBOLT:CanCast(target) then
		SPELL_PET_WATERBOLT:Cast(target)
		return
	end
	
	if Frost.LastSpell == SPELL_FLURRY:GetSpellId() and SPELL_ICE_LANCE:CanCast(target) then
		Frost.Cast(SPELL_ICE_LANCE, target)
		return
	end

	if Frost.IsFrozen(target) and SPELL_ICE_LANCE:CanCast(target) and #target:GetNearbyEnemyUnits(12) <= 2 then
		Frost.Cast(SPELL_ICE_LANCE, target)
	end

	if not isMoving and SPELL_MIRROR_IMAGE:CanCast() then
		Frost.Cast(SPELL_MIRROR_IMAGE, player)
		return
	end

	if SPELL_ICY_VEINS:CanCast() then
		Frost.Cast(SPELL_ICY_VEINS, player)
		return
	end

	if not isMoving and Frost.ShouldCastROP(target) then
		Frost.Cast(SPELL_RUNE_OF_POWER, player)
		Frost.LastROP = os.clock()
		return
	end

	-- Ice Nova Icon Ice Nova if Winter's Chill is still up after your
	-- Ice Lance Icon Ice Lance's Global Cooldown, if talented for.

	if player:HasAura(AURA_BRAIN_FREEZE) and SPELL_FLURRY:CanCast(target) and (Frost.LastSpell == SPELL_EBONBOLT:GetSpellId() or Frost.LastSpell == SPELL_FROSTBOLT:GetSpellId()) then
		Frost.Cast(SPELL_FLURRY, target)
		return
	end

	if SPELL_FROZEN_ORB:CanCast(target) and player:IsFacing(target:GetPosition()) then
		Frost.Cast(SPELL_FROZEN_ORB, player)
		return
	end

	if not isMoving and SPELL_BLIZZARD:CanCast(target) and (#target:GetNearbyEnemyUnits(12) > 2 or (player:HasAura(AURA_FREEZING_RAIN) and #target:GetNearbyEnemyUnits(12) > 1)) then
		SPELL_BLIZZARD:Cast(target)
		Frost.LastSpell = SPELL_BLIZZARD
		return
	end

	if player:HasAura(AURA_FINGERS_OF_FROST) and SPELL_ICE_LANCE:CanCast(target) then
		Frost.Cast(SPELL_ICE_LANCE, target)
		return
	end

	if not isMoving and SPELL_RAY_OF_FROST:CanCast(target) then
		Frost.Cast(SPELL_RAY_OF_FROST, target)
		return
	end

	if SPELL_COMET_STORM:CanCast(target) then
		Frost.Cast(SPELL_COMET_STORM, target)
		return
	end

	if not isMoving and SPELL_EBONBOLT:CanCast(target) then
		Frost.Cast(SPELL_EBONBOLT, target)
		return
	end

	local icicles = player:GetAura(AURA_ICICLES)
	if not isMoving and icicles ~= nil and icicles:GetStacks() == 5 and SPELL_GLACIAL_SPIKE:CanCast(target) and not player:HasAura(AURA_BRAIN_FREEZE) then
		Frost.Cast(SPELL_GLACIAL_SPIKE, target)
		return
	end

	if not isMoving and SPELL_BLIZZARD:CanCast(target) and (#target:GetNearbyEnemyUnits(12) > 1 or player:HasAura(AURA_FREEZING_RAIN)) then
		SPELL_BLIZZARD:CastAoF(target)
		Frost.LastSpell = SPELL_BLIZZARD
		return
	end
	
	if SPELL_ICE_NOVA:CanCast(target) then
		Frost.Cast(SPELL_ICE_NOVA, target)
		return
	end

	-- Flurry if winters reach

	if not isMoving and SPELL_FROSTBOLT:CanCast(target) then
		Frost.Cast(SPELL_FROSTBOLT, target)
		return
	end
end

function Frost.ShouldCastROP(target)
	if SPELL_RUNE_OF_POWER:CanCast() and os.clock() - Frost.LastROP > 10 and
	(Frost.LastSpell == SPELL_FROZEN_ORB:GetSpellId() or (not SPELL_RAY_OF_FROST:CanCast(target) and not SPELL_EBONBOLT:CanCast(target) and not SPELL_COMET_STORM:CanCast(target)))
		then
		return true
	end

	return false
end

function Frost.Cast(spell, target)
	spell:Cast(target)
	Frost.LastSpell = spell:GetSpellId()
end

--[[ Old routine
function Frost.SingleRotation(player, target)
	if Frost.LastSpell == SPELL_FLURRY then --and player:CanCast(SPELL_ICE_LANCE, 'Ice Lance', true) then
		--Frost.Cast(SPELL_ICE_LANCE)
		-- Due to unknown bug we have to cast Ice Lance by name and can't check if its castable.
		player:CastByName("Ice Lance")
		Frost.LastSpell = SPELL_ICE_LANCE
		return
	end

	if not isMoving and player:CanCast(SPELL_MIRROR_IMAGE, 'Mirror Image', false) then
		Frost.Cast(SPELL_MIRROR_IMAGE)
		return
	end

	if player:CanCast(SPELL_ICY_VEINS, 'Icy Veins', false) then
		Frost.Cast(SPELL_ICY_VEINS)
		return
	end

	if not isMoving and Frost.ShouldCastROP() then
		Frost.Cast(SPELL_RUNE_OF_POWER)
		Frost.LastROP = os.clock()
		return
	end

	-- Ice Nova Icon Ice Nova if Winter's Chill is still up after your
	-- Ice Lance Icon Ice Lance's Global Cooldown, if talented for.

	if player:HasAura(AURA_BRAIN_FREEZE) and player:CanCast(SPELL_FLURRY, 'Flurry', true) and (Frost.LastSpell == SPELL_EBONBOLT or Frost.LastSpell == SPELL_FROSTBOLT) then
		Frost.Cast(SPELL_FLURRY)
		return
	end

	if player:CanCast(SPELL_FROZEN_ORB, 'Frozen Orb', false) then
		Frost.Cast(SPELL_FROZEN_ORB)
		return
	end

	if not isMoving and player:CanCast(SPELL_BLIZZARD, 'Blizzard', false) and (#target:NearbyUnits(12) > 2 or (player:HasAura(AURA_FREEZING_RAIN) and #target:NearbyUnits(12) > 1)) then
		player:CastAoF(SPELL_BLIZZARD, target:GetPosition())
		Frost.LastSpell = SPELL_BLIZZARD
		return
	end

	if player:HasAura(AURA_FINGERS_OF_FROST) then --and player:CanCast(SPELL_ICE_LANCE, 'Ice Lance', false) then
		--Frost.Cast(SPELL_ICE_LANCE)
		-- Due to unknown bug we have to cast Ice Lance by name and can't check if its castable.
		player:CastByName("Ice Lance")
		Frost.LastSpell = SPELL_ICE_LANCE
		return
	end

	if not isMoving and player:CanCast(SPELL_RAY_OF_FROST, 'Ray of Frost', true) then
		Frost.Cast(SPELL_RAY_OF_FROST)
		return
	end

	if player:CanCast(SPELL_COMET_STORM, 'Comet Storm', true) then
		Frost.Cast(SPELL_COMET_STORM)
		return
	end

	if not isMoving and player:CanCast(SPELL_EBONBOLT, 'Ebonbolt', true) then
		Frost.Cast(SPELL_EBONBOLT)
		return
	end

	if not isMoving and player:CanCast(SPELL_BLIZZARD, 'Blizzard', false) and (#target:NearbyUnits(12) > 1 or player:HasAura(AURA_FREEZING_RAIN)) then
		player:CastAoF(SPELL_BLIZZARD, target:GetPosition())
		Frost.LastSpell = SPELL_BLIZZARD
		return
	end

	if player:CanCast(SPELL_ICE_NOVA, 'Ice Nova', true) then
		Frost.Cast(SPELL_ICE_NOVA)
		return
	end

	-- Flurry if winters reach

	if not isMoving and player:CanCast(SPELL_FROSTBOLT, 'Frostbolt', true) then
		Frost.Cast(SPELL_FROSTBOLT)
		return
	end
end

function Frost.ShouldCastROP()
	if Me:CanCast(SPELL_RUNE_OF_POWER, 'Rune of Power', false) and
		os.clock() - Frost.LastROP > 10 and
		(Frost.LastSpell == SPELL_FROZEN_ORB or 
		(not Me:CanCast(SPELL_RAY_OF_FROST, 'Ray of Frost', true) and
		not Me:CanCast(SPELL_EBONBOLT, 'Ebonbolt', true) and
		not Me:CanCast(SPELL_COMET_STORM, 'Comet Storm', false))) then
		return true
	end

	return false
end

function Frost.Cast(spellId)
	Me:CastById(spellId)
	Frost.LastSpell = spellId
end
]]--

return Frost