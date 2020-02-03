-- Fury
local SPELL_BATTLE_SHOUT = Spell(6673, 10)
local SPELL_RECKLESSNESS = Spell(1719, 10)
local SPELL_RAMPAGE = Spell(184367)
local SPELL_DRAGON_ROAR = Spell(118000, 12)
local SPELL_BLOODTHIRST = Spell(23881)
local SPELL_EXECUTE = Spell(5308)
local SPELL_RAGING_BLOW = Spell(85288)
local SPELL_WHIRLWIND = Spell(190411, 8)
local SPELL_FURIOUS_SLASH = Spell(100130)
local SPELL_VICTORY_RUSH = Spell(34428)
local SPELL_INTIMIDATING_SHOUT = Spell(5246)
local SPELL_RALLYING_CRY = Spell(97462)
local SPELL_SIEGEBREAKER = Spell(280772)

local AURA_BATTLE_SHOUT = 6673
local AURA_VICTORIOUS = 32216
local AURA_WHIRLWIND = 85739
local AURA_ENRAGED_REGENERATION = 184364
local AURA_ENRAGED = 184362
local AURA_CRUSADER = 20007
local AURA_FURIOUSSLASH = 202539
local AURA_SUDDEN_DEATH = 280776

local NPC_EXPLOSIVE = 120651

local BossHealth = 600000

local Fury = {}

function Fury.DoCombat(player, target)
	local nearbyUnits = player:GetNearbyEnemyUnits(8)
	for i = 1, #nearbyUnits do
		if nearbyUnits[i]:GetEntry() == NPC_EXPLOSIVE then
			if SPELL_RAGING_BLOW:CanCast(nearbyUnits[i]) then
				SPELL_RAGING_BLOW:Cast(nearbyUnits[i])
				return
			end

			if SPELL_BLOODTHIRST:CanCast(nearbyUnits[i]) then
				SPELL_BLOODTHIRST:Cast(nearbyUnits[i])
				return
			end

			if player:GetRagePercent() > 75 and SPELL_RAMPAGE:CanCast(nearbyUnits[i]) then
				SPELL_RAMPAGE:Cast(nearbyUnits[i])
				return
			end
		end
	end

	local HPP = player:GetHealthPercent()
	
	if HPP < 15 and SPELL_RALLYING_CRY:CanCast() then
		SPELL_RALLYING_CRY:Cast(player)
		return
	end

	--if HPP < 35 and SPELL_INTIMIDATING_SHOUT:CanCast(target) then
	--	SPELL_INTIMIDATING_SHOUT:Cast(target)
	--	return
	--end

	if not player:HasAura(AURA_BATTLE_SHOUT) and SPELL_BATTLE_SHOUT:CanCast() then
		SPELL_BATTLE_SHOUT:Cast(player)
		return
	end

	if player:HasAura(AURA_VICTORIOUS) and HPP < 80 and SPELL_VICTORY_RUSH:CanCast(target) then
		SPELL_VICTORY_RUSH:Cast(target)
		return
	end

	if player:HasAura(AURA_ENRAGED_REGENERATION) and player:GetHealthPercent() < 80 and SPELL_BLOODTHIRST:CanCast(target) then
		SPELL_BLOODTHIRST:Cast(target)
		return
	end

	if #player:GetNearbyEnemyUnits(8) > 1 then
		Fury.AoERotation(player, target)
	else
		Fury.SingleRotation(player, target)
	end
end

function Fury.AoERotation(player, target)
	local nearUnits = player:GetNearbyEnemyUnits(8)
	if #nearUnits > 1 and #nearUnits <= 10 then
		if not player:HasAura(AURA_WHIRLWIND) and SPELL_WHIRLWIND:CanCast(target) then
			SPELL_WHIRLWIND:Cast(player)
			return
		end
	end

	if #nearUnits > 10 then
		if SPELL_WHIRLWIND:CanCast(target) then
			SPELL_WHIRLWIND:Cast(target)
			return
		end
	end

	if SPELL_BLOODTHIRST:CanCast(target) then
		SPELL_BLOODTHIRST:Cast(target)
		return
	end

	Fury.SingleRotation(player, target)
end

function Fury.SingleRotation(player, target)
	local ExecuteCheck = player:GetNearbyEnemyUnits(6)
	local FSlash = player:GetAura(AURA_FURIOUSSLASH)
	local FSlashStacks = 0
	local FSlashTime = 0
	local freeExecute = player:HasAura(AURA_SUDDEN_DEATH)

	if FSlash ~= nil then
		FSlashStacks = FSlash:GetStacks()
		FSlashTime = FSlash:GetTimeleft()
	end

	if player:GetDistance(target) < 12 then
		if SPELL_RECKLESSNESS:CanCast(target) and target:GetHealth() > BossHealth and player:GetRagePercent() < 30 then
			SPELL_RECKLESSNESS:Cast(player)
			return
		end

		if SPELL_DRAGON_ROAR:CanCast(target) and player:GetDistance(target) < 10 then
			SPELL_DRAGON_ROAR:Cast(player)
			return
		end
	end

	if SPELL_SIEGEBREAKER:CanCast(target) then
		SPELL_SIEGEBREAKER:Cast(target)
		return
	end

	local enrage_buff = player:GetAura(AURA_ENRAGED)
	--if ((not enrage_buff and player:GetRagePercent() > 75) or ((enrage_buff and enrage_buff:GetTimeleft() < 1000) or player:GetRagePercent() > 90)) and SPELL_RAMPAGE:CanCast(target) then
	--	SPELL_RAMPAGE:Cast(target)
	--	return
	--end
	if player:GetRagePercent() > 75 and SPELL_RAMPAGE:CanCast(target) then
		SPELL_RAMPAGE:Cast(target)
		return
	end

	if SPELL_BLOODTHIRST:CanCast(target) then
		SPELL_BLOODTHIRST:Cast(target)
		return
	end

	if SPELL_EXECUTE:IsReady() and #ExecuteCheck > 1 then
		for i = 1, #ExecuteCheck do
			if (ExecuteCheck[i]:GetHealthPercent() < 20 or freeExecute) and player:GetRagePercent() < 90 and player:IsFacing(ExecuteCheck[i]) and SPELL_EXECUTE:CanCast(ExecuteCheck[i]) then
				SPELL_EXECUTE:Cast(ExecuteCheck[i])
			end
		end
	end

	if (target:GetHealthPercent() < 20 or freeExecute) and player:GetRagePercent() < 90 and SPELL_EXECUTE:CanCast(target) then
		SPELL_EXECUTE:Cast(target)
		return
	end

	if SPELL_RAGING_BLOW:CanCast(target) then
		SPELL_RAGING_BLOW:Cast(target)
		return
	end

	if SPELL_FURIOUS_SLASH:CanCast(target) and (FSlashStacks < 3 or FSlashTime < 3000) then
		SPELL_FURIOUS_SLASH:Cast(target)
		return
	end

	if SPELL_WHIRLWIND:CanCast(target) and allDown(player) then
		SPELL_WHIRLWIND:Cast(target)
		return
	end
end

function allDown(player)
	if not SPELL_BLOODTHIRST:IsReady() and player:GetRagePercent() < 75 and SPELL_RAGING_BLOW:GetCharges() == 0 then
		return true
	else
		return false
	end
end

return Fury