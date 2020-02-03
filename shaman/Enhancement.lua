local SPELL_FLAMETONGUE = Spell(193796)
local SPELL_FERAL_SPIRIT = Spell(51533)
local SPELL_STORMSTRIKE = Spell(17364, 6)
local SPELL_SUNDERING = Spell(197214, 10)
local SPELL_ROCKBITER = Spell(193786)
local SPELL_LAVALASH = Spell(60103, 6)
local SPELL_LIGHTNING_BOLT = Spell(187837)
local SPELL_CRASH_LIGHTNING = Spell(187874, 6)
local SPELL_BLOODLUST = Spell(2825)
--local SPELL_BLOODLUSTOP = Spell(204361)
local SPELL_HEALING_SURGE = Spell(188070)
local SPELL_EARTH_ELEMENTAL = Spell(198103)
local SPELL_LIGHTNING_SHIELD = Spell(192106)
local SPELL_SKYFURY_TOTEM = Spell(204330)
local SPELL_ASTRAL_SHIFT = Spell(108271)

local BUFF_FLAMETONGUE = 194084
local BUFF_CRASH = 187878
local BUFF_SHIELD = 192106
local BUFF_HOT_HANDS = 215785

-- SETTINGS
local useCDS = false

local Enhancement = {}

function Enhancement.DoCombat(player, target)
	if SPELL_ASTRAL_SHIFT:CanCast() and player:GetHealthPercent() < 60 then
		SPELL_ASTRAL_SHIFT:Cast(player)
		return
	end

	if SPELL_HEALING_SURGE:CanCast(player) and player:GetMaelstrom() >= 80 and player:GetHealthPercent() < 80 then
		SPELL_HEALING_SURGE:Cast(player)
		return
	end
	if SPELL_EARTH_ELEMENTAL:CanCast() and player:GetHealthPercent() < 30 then
		SPELL_EARTH_ELEMENTAL:Cast(player)
		return
	end
	if SPELL_BLOODLUST:CanCast() then
		SPELL_BLOODLUST:Cast(player)
		return
	end
	Enhancement.DoRotation(player, target)
end

function Enhancement.DoRotation(player, target)
	local Ftongue = player:GetAura(BUFF_FLAMETONGUE)
	local FTimer = 0
	local hasAoeBuff = player:HasAura(BUFF_CRASH)

	if Ftongue ~= nil then
		FTimer = Ftongue:GetTimeleft()
	end

	if target:GetHealth() >= player:GetHealth() * 4 then
		useCDS = true
	end

	if not player:HasAura(BUFF_SHIELD) and SPELL_LIGHTNING_SHIELD:CanCast() then
		SPELL_LIGHTNING_SHIELD:Cast(player)
		return
	end

	if SPELL_SKYFURY_TOTEM:CanCast() and useCDS then
		SPELL_SKYFURY_TOTEM:Cast(player)
		return
	end

	if player:GetMaelstrom() > 90 and SPELL_LAVALASH:CanCast(target) then
		SPELL_LAVALASH:Cast(target)
		return
	end

	if SPELL_CRASH_LIGHTNING:CanCast(target) and #target:GetNearbyEnemyUnits(8) > 1 and not hasAoeBuff then
		SPELL_CRASH_LIGHTNING:Cast(target)
		return
	end

	if FTimer < 4500 and SPELL_FLAMETONGUE:CanCast(target) then
		SPELL_FLAMETONGUE:Cast(target)
		return
	end

	if SPELL_FERAL_SPIRIT:CanCast(target) and useCDS then
		SPELL_FERAL_SPIRIT:Cast(player)
		return
	end

	if player:HasAura(BUFF_HOT_HANDS) and SPELL_LAVALASH:CanCast(target) then
		SPELL_LAVALASH:Cast(target)
		return
	end

	if SPELL_STORMSTRIKE:CanCast(target) then
		SPELL_STORMSTRIKE:Cast(target)
		return
	end

	if SPELL_SUNDERING:CanCast(target) then
		SPELL_SUNDERING:Cast(target)
		return
	end
	
	if SPELL_ROCKBITER:CanCast(target) and player:GetMaelstrom() <= 70 and SPELL_ROCKBITER:GetCharges() > 1 then
		SPELL_ROCKBITER:Cast(target)
		return
	end

	if SPELL_LAVALASH:CanCast(target) and player:GetMaelstrom() >= 40 then
		SPELL_LAVALASH:Cast(target)
		return
	end

	if SPELL_ROCKBITER:CanCast(target) then
		SPELL_ROCKBITER:Cast(target)
		return
	end

	if SPELL_FLAMETONGUE:CanCast(target) then
		SPELL_FLAMETONGUE:Cast(target)
		return
	end

	if SPELL_LIGHTNING_BOLT:CanCast(target) and player:GetDistance(target) > 20 then
		SPELL_LIGHTNING_BOLT:Cast(target)
		return
	end
end

return Enhancement