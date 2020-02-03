local SPELL_ROLL_THE_BONES = Spell(193316)
local SPELL_GHOSTLY_STRIKE = Spell(196937)
local SPELL_KILLING_SPREE = Spell(51690)
local SPELL_BLADE_RUSH = Spell(271877)
local SPELL_ADRENALINE_RUSH = Spell(13750, 10)
local SPELL_MARKED_FOR_DEATH = Spell(137619)
local SPELL_BETWEEN_THE_EYES = Spell(199804)
local SPELL_DISPATCH = Spell(2098)
local SPELL_PISTOL_SHOT = Spell(185763)
local SPELL_SINISTER_STRIKE = Spell(193315)
local SPELL_BLADE_FLURRY = Spell(13877, 10)
local SPELL_SLICE_AND_DICE = Spell(5171, 10)
local SPELL_KICK = Spell(1766)

local AURA_TRUE_BEARING = 193359
local AURA_RUTHLESS_PRECISION = 193357
local AURA_SKULL_AND_CROSSBONES = 199603
local AURA_GRAND_MELEE = 193358
local AURA_BROADSIDE = 193356
local AURA_BURIED_TREASURE = 199600
local AURA_OPPORTUNITY = 195627
local AURA_ACE_UP_YOUR_SLEEVE = 278676
local AURA_DEADSHOT = 272935
local AURA_ADRENALINE_RUSH = 13750
local AURA_LOADED_DICE = 256170
local AURA_BLADE_FLURRY = 13877
local AURA_STEALTH = 1784
local AURA_VANISH = 11327
local AURA_SLICE_AND_DICE = 5171

local Outlaw = {}

function Outlaw.DoCombat(player, target)
	if player:HasAura(AURA_STEALTH) or player:HasAura(AURA_VANISH) then
		return
	end

	local units = player:GetNearbyEnemyUnits(30)
	for i = 1, #units do
		if units[i]:InCombat() and doInterrupt(units[i]) then
			if SPELL_KICK:CanCast(units[i]) then
				SPELL_KICK:Cast(units[i])
			end
		end
	end

	if #player:GetNearbyEnemyUnits(10) > 1 then
		Outlaw.AoERotation(player, target)
	else
		Outlaw.SingleRotation(player, target)
	end
end

function Outlaw.AoERotation(player, target)
	if not player:HasAura(AURA_BLADE_FLURRY) and SPELL_BLADE_FLURRY:CanCast(target) then
		SPELL_BLADE_FLURRY:Cast(player)
		return
	end

	Outlaw.SingleRotation(player, target)
end

function Outlaw.SingleRotation(player, target)
	local snd = player:HasAura(AURA_SLICE_AND_DICE)

	if not snd and player:GetComboPoints() > 4 and Outlaw.ShouldRollTheBones(player) and SPELL_ROLL_THE_BONES:CanCast() then
		SPELL_ROLL_THE_BONES:Cast(player)
		return
	end

	if Outlaw.ComboPointsToCap(player) > 0 and SPELL_GHOSTLY_STRIKE:CanCast(target) then
		SPELL_GHOSTLY_STRIKE:Cast(target)
		return
	end

	if not player:HasAura(AURA_ADRENALINE_RUSH) and SPELL_KILLING_SPREE:CanCast(target) then
		SPELL_KILLING_SPREE:Cast(target)
		return
	end

	if SPELL_BLADE_RUSH:CanCast(target) then
		SPELL_BLADE_RUSH:Cast(target)
		return
	end

	if SPELL_ADRENALINE_RUSH:CanCast(target) then
		SPELL_ADRENALINE_RUSH:Cast(player)
		return
	end

	if player:GetComboPoints() <= 1 and SPELL_MARKED_FOR_DEATH:CanCast(target) then
		SPELL_MARKED_FOR_DEATH:Cast(target)
		return
	end

	if not snd and player:GetComboPoints() >= 5 and
		(player:HasAura(AURA_RUTHLESS_PRECISION) or player:HasAura(AURA_ACE_UP_YOUR_SLEEVE) or player:HasAura(AURA_DEADSHOT)) and SPELL_BETWEEN_THE_EYES:CanCast(target) then
		SPELL_BETWEEN_THE_EYES:Cast(target)
		return
	end

	if player:GetComboPoints() >= 5 and SPELL_DISPATCH:CanCast(target) then
		SPELL_DISPATCH:Cast(target)
		return
	end

	if player:GetComboPoints() <= 4 and player:HasAura(AURA_OPPORTUNITY) and SPELL_PISTOL_SHOT:CanCast(target) then
		SPELL_PISTOL_SHOT:Cast(target)
		return
	end

	if SPELL_SINISTER_STRIKE:CanCast(target) then
		SPELL_SINISTER_STRIKE:Cast(target)
		return
	end
end

function Outlaw.ComboPointsToCap(player)
	return player:GetComboPointsMax() - player:GetComboPoints()
end

function Outlaw.ShouldRollTheBones(player)
	local numBuffs = Outlaw.NumOfRollBuffs(player)

	if numBuffs == 0 then
		return true
	end

	if numBuffs == 1 and player:HasAura(AURA_LOADED_DICE) then
		return true
	end

	if numBuffs == 1 and not player:HasAura(AURA_RUTHLESS_PRECISION) and not player:HasAura(AURA_GRAND_MELEE) then
		return true
	end

	return false
end

function Outlaw.NumOfRollBuffs(player)
	ret = 0

	if player:HasAura(AURA_TRUE_BEARING) then
		ret = ret + 1
	end
	if player:HasAura(AURA_RUTHLESS_PRECISION) then
		ret = ret + 1
	end
	if player:HasAura(AURA_SKULL_AND_CROSSBONES) then
		ret = ret + 1
	end
	if player:HasAura(AURA_GRAND_MELEE) then
		ret = ret + 1
	end
	if player:HasAura(AURA_BROADSIDE) then
		ret = ret + 1
	end
	if player:HasAura(AURA_BURIED_TREASURE) then
		ret = ret + 1
	end

	return ret;
end

function doInterrupt(unit)
	local toInterrupt = math.random(400, 700)
	if unit:IsCasting() or unit:IsChanneling() then
	  local unitSpell = unit:GetCurrentSpell()
	  if unitSpell ~= nil and unitSpell:IsInterruptible() and unitSpell:GetTimeleft() < toInterrupt then
		return true
	  end
	end
	return false
end

return Outlaw