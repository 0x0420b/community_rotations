-- EVENTS
--RegisterInputEvent(1, OnKeyDown)

-- SPELLS --
local SPELL_ARCANE_SHOT = Spell(185358)
local SPELL_AIMED_SHOT = Spell(19434)
local SPELL_MULTI_SHOT = Spell(257620)
local SPELL_RAPID_FIRE = Spell(257044)
local SPELL_PIERCING_SHOT = Spell(198670)
local SPELL_DOUBLE_TAP = Spell(260402)
local SPELL_HUNTERS_MARK = Spell(257284)
local SPELL_EXPLOSIVE_SHOT = Spell(212431)
local SPELL_AMOC = Spell(131894)
local SPELL_STEADY_SHOT = Spell(56641)
local SPELL_TRUESHOT = Spell(288613)

-- AURAS
local AURA_PRECISE_SHOTS = 260242
local AURA_MASTER_MARKSMAN = 269576
local AURA_LOCK_AND_LOAD = 194594

-- BUFFS

-- BOSS DEBUFFS
local DEBUFF_HUNTERS_MARK = 257284

-- HELPERS
local WANT_TO_BURST = false

function OnKeyDown(vk, shift)
    WANT_TO_BURST = true
end

local Marksmanship = {}

function Marksmanship.DoCombat(player, target)
	
	if WANT_TO_BURST == true then
		Marksmanship.Burst(player, target)
		return
	end

	-- if target.Health > 80 or target.Health < 20 then
	--	Marksmanship.Burst(player, target)
	-- end

	if player:IsMoving() then
		Marksmanship.MovingRotation(player, target)
		return
	end

	if #target:GetNearbyUnits(12) > 2 then
		Marksmanship.AoERotation(player, target)
	else
		Marksmanship.SingleRotation(player, target)
	end
end

function Marksmanship.AoERotation(player, target)
	
	Marksmanship.SingleRotation(player, target);
end

function Marksmanship.SingleRotation(player, target)
	local Hunters_Mark = target:GetAuraByPlayer(DEBUFF_HUNTERS_MARK)

	if (Hunters_Mark == nil) and SPELL_HUNTERS_MARK:CanCast(target) then
		SPELL_HUNTERS_MARK:Cast(target)
		return
	end

	if SPELL_DOUBLE_TAP:CanCast(player) then
		SPELL_DOUBLE_TAP:Cast(player)
		return
	end
	
	
	if not player:HasAura(AURA_PRECISE_SHOTS) and SPELL_AIMED_SHOT:CanCast(target) then
		SPELL_AIMED_SHOT:Cast(target)
		return
	end
	if SPELL_RAPID_FIRE:CanCast(target) then
		SPELL_RAPID_FIRE:Cast(target)
		return
	end

	if SPELL_PIERCING_SHOT:CanCast(target) then
		SPELL_PIERCING_SHOT:Cast(target)
		return
	end

	if SPELL_AMOC:CanCast(target) then
		SPELL_AMOC:Cast(target)
		return
	end

	if SPELL_EXPLOSIVE_SHOT:CanCast(target) then
		SPELL_EXPLOSIVE_SHOT:Cast(target)
		return
	end

	if #target:GetNearbyUnits(12) > 2 then
		if player:HasAura(AURA_PRECISE_SHOTS) and SPELL_MULTI_SHOT:CanCast(target) then
			SPELL_MULTI_SHOT:Cast(target)
			return
		end
	else
		if player:HasAura(AURA_PRECISE_SHOTS) and SPELL_ARCANE_SHOT:CanCast(target) then
			SPELL_ARCANE_SHOT:Cast(target)
			return
		end
	end
	

	if SPELL_STEADY_SHOT:CanCast(target) then
		SPELL_STEADY_SHOT:Cast(target)
		return
	end

end

function Marksmanship.MovingRotation(player, target)
	if SPELL_DOUBLE_TAP:CanCast(player) then
		SPELL_DOUBLE_TAP:Cast(player)
		return
	end

	if SPELL_RAPID_FIRE:CanCast(target) then
		SPELL_RAPID_FIRE:Cast(target)
		return
	end

	if SPELL_AMOC:CanCast(target) then
		SPELL_AMOC:Cast(target)
		return
	end

	if SPELL_EXPLOSIVE_SHOT:CanCast(target) then
		SPELL_EXPLOSIVE_SHOT:Cast(target)
		return
	end

	if not player:HasAura(AURA_PRECISE_SHOTS) and SPELL_AIMED_SHOT:CanCast(target) then
		SPELL_AIMED_SHOT:Cast(target)
		return
	end

	if SPELL_STEADY_SHOT:CanCast(target) then
		SPELL_STEADY_SHOT:Cast(target)
		return
	end
end

function Marksmanship.Burst(player, target)
	if SPELL_TRUESHOT:CanCast(target) then
		SPELL_TRUESHOT:Cast(target)
		WANT_TO_BURST = false
		return
	end
end



return Marksmanship