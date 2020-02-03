
local SPELL_FLAME_SHOCK = Spell(188389, 40)
local SPELL_LAVA_BURST = Spell(51505, 30)
local SPELL_CHAIN_LIGHTNING = Spell(188443, 30)
local SPELL_LIGHTNING_BOLT = Spell(188196, 30)
local SPELL_EARTH_SHOCK = Spell(8042, 30)
local SPELL_TOTEM_MASTERY = Spell(210643)
local SPELL_STORM_ELEMENTAL = Spell(192249)
local SPELL_EARTH_ELEMENTAL = Spell(198103)
local SPELL_STORMKEEPER = Spell(191634)
local SPELL_FROST_SHOCK = Spell(196840)
local SPELL_EARTHQUAKE = Spell(61882)
local SPELL_ANCESTRAL_GUIDANCE = Spell(108281)
local SPELL_ASTRAL_SHIFT = Spell(108271)
local SPELL_SKYFURY_TOTEM = Spell(204330)
local SPELL_FIRE_ELEMENTAL = Spell(198067)

local DEBUFF_FLAME_SHOCK = 188389

local BUFF_WOLF = 2645
local BUFF_TOTEMS = 210659
local BUFF_STORM_ELEMENTAL = 263806
local BUFF_LAVA_SURGE = 77762
local BUFF_STORMKEEPER = 191634
local BUFF_SURGE_OF_POWER = 285514
local BUFF_MASTER_OF_ELEMENTS = 260734

-- SETTINGS
local useCDS = true
local DefensivePercent = 60
-- SETTINGS

local Elemental = {}

function Elemental.DoCombat(player, target)
	-- Begin rotation
	if not player:HasAura(BUFF_WOLF) then
		if SPELL_SKYFURY_TOTEM:CanCast() then
			SPELL_SKYFURY_TOTEM:Cast(player)
			return
		end

		if not player:HasAura(BUFF_TOTEMS) and SPELL_TOTEM_MASTERY:CanCast() then
			SPELL_TOTEM_MASTERY:Cast(player)
			return
		end

		if player:GetHealthPercent() < 80 and SPELL_ANCESTRAL_GUIDANCE:CanCast() then
			SPELL_ANCESTRAL_GUIDANCE:Cast(player)
			return
		end


		if player:GetHealthPercent() < DefensivePercent and SPELL_ASTRAL_SHIFT:CanCast() then
			SPELL_ASTRAL_SHIFT:Cast(player)
			return
		end

		if #target:GetNearbyEnemyUnits(10) <= 3 then
			Elemental.DoRotation(player, target)
		elseif #target:GetNearbyEnemyUnits(10) > 3 then
			Elemental.DoBigRotation(player, target)
		end
	end
end

function Elemental.DoBigRotation(player, target)
	if SPELL_STORM_ELEMENTAL:CanCast() and useCDS and player:GetPet() == nil then
		SPELL_STORM_ELEMENTAL:Cast(target)
		return
	end

	if SPELL_FIRE_ELEMENTAL:CanCast() and useCDS and player:GetPet() == nil then
		SPELL_FIRE_ELEMENTAL:Cast(target)
		return
	end

	if SPELL_EARTH_ELEMENTAL:CanCast() and useCDS and player:GetPet() == nil then
		SPELL_EARTH_ELEMENTAL:Cast(target)
		return
	end

	if SPELL_STORMKEEPER:CanCast() then
		SPELL_STORMKEEPER:Cast(player)
		return
	end

	if SPELL_LAVA_BURST:CanCast(target) and player:HasAura(BUFF_LAVA_SURGE) then
		SPELL_LAVA_BURST:Cast(target)
		return
	end

	if SPELL_EARTHQUAKE:CanCast() and player:GetMaelstrom() > 60 then
		SPELL_EARTHQUAKE:CastAoF(target:GetPosition())
		return
	end

	if SPELL_CHAIN_LIGHTNING:CanCast(target) then
		SPELL_CHAIN_LIGHTNING:Cast(target)
		return
	end
end

function Elemental.DoRotation(player, target)
	local units = player:GetNearbyEnemyUnits(40)
	-- local players = player:NearbyEnemyPlayers(40) -- not now.
	local flshock = target:GetAura(DEBUFF_FLAME_SHOCK)
	local ftimer = 0
	local hasInstant = player:HasAura(BUFF_LAVA_SURGE)

	if flshock ~= nil then
		ftimer = flshock:GetTimeleft()
	end

	if SPELL_FLAME_SHOCK:CanCast(target) and ftimer < 7000 then
		SPELL_FLAME_SHOCK:Cast(target)
		return
	end

	for i = 1, #units do
		if units[i]:InCombat() and player:IsFacing(units[i]:GetPosition()) then
			if not units[i]:HasAuraByPlayer(DEBUFF_FLAME_SHOCK) and SPELL_FLAME_SHOCK:CanCast(units[i]) then
				SPELL_FLAME_SHOCK:Cast(units[i])
				return
			end
		end
	end

	if SPELL_STORMKEEPER:CanCast() then
		SPELL_STORMKEEPER:Cast(player)
		return
	end

	if SPELL_STORM_ELEMENTAL:CanCast() and useCDS and player:GetPet() == nil then
		SPELL_STORM_ELEMENTAL:Cast(target)
		return
	end

	if SPELL_FIRE_ELEMENTAL:CanCast() and useCDS and player:GetPet() == nil then
		SPELL_FIRE_ELEMENTAL:Cast(target)
		return
	end

	if SPELL_EARTH_ELEMENTAL:CanCast() and useCDS and player:GetPet() == nil then
		SPELL_EARTH_ELEMENTAL:Cast(target)
		return
	end

	-- AOE MODE
	if #target:GetNearbyEnemyUnits(10) > 1 then
		if SPELL_EARTHQUAKE:CanCast() and player:GetMaelstrom() > 60 then
			SPELL_EARTHQUAKE:CastAoF(target:GetPosition())
			return
		end
	end
		-- END AOE MODE

	if SPELL_LIGHTNING_BOLT:CanCast(target) and player:HasAura(BUFF_STORMKEEPER) and player:HasAura(BUFF_SURGE_OF_POWER) then
		SPELL_LIGHTNING_BOLT:Cast(target)
		return
	end

	if SPELL_LIGHTNING_BOLT:CanCast(target) and player:HasAura(BUFF_STORMKEEPER) and player:HasAura(BUFF_MASTER_OF_ELEMENTS) then
		SPELL_LIGHTNING_BOLT:Cast(target)
		return
	end

	if SPELL_EARTH_SHOCK:CanCast(target) and player:HasAura(BUFF_MASTER_OF_ELEMENTS) then
		SPELL_EARTH_SHOCK:Cast(target)
		return
	end

	if SPELL_LIGHTNING_BOLT:CanCast(target) and player:HasAura(BUFF_SURGE_OF_POWER) then
		SPELL_LIGHTNING_BOLT:Cast(target)
		return
	end

	if SPELL_EARTH_SHOCK:CanCast(target) and player:GetMaelstrom() > 60 then
		SPELL_EARTH_SHOCK:Cast(target)
		return
	end

	if SPELL_LAVA_BURST:CanCast(target) then
		SPELL_LAVA_BURST:Cast(target)
		return
	end

	if SPELL_LIGHTNING_BOLT:CanCast(target) then
		SPELL_LIGHTNING_BOLT:Cast(target)
		return
	end

	if player:IsMoving() and SPELL_FROST_SHOCK:CanCast(target) then
		SPELL_FROST_SHOCK:Cast(target)
		return
	end
end

return Elemental