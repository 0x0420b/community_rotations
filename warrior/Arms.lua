-- Arms
local SPELL_REND = Spell(772)
local SPELL_WARBREAKER = Spell(262161, 8)
local SPELL_EXECUTE = Spell(163201)
local SPELL_MORTAL_STRIKE = Spell(12294)
local SPELL_BLADESTORM = Spell(227847, 8)
local SPELL_OVERPOWER = Spell(7384)
local SPELL_SLAM = Spell(1464)
local SPELL_SWEEPING_STRIKES = Spell(260708, 10)
local SPELL_WHIRLWIND = Spell(1680, 8)
local SPELL_BATTLE_SHOUT = Spell(6673, 10)
local SPELL_VICTORY_RUSH = Spell(34428)

local AURA_REND = 772
local AURA_BATTLE_SHOUT = 6673
local AURA_VICTORIOUS = 32216
local AURA_OVERPOWER = 7384
local AURA_SUDDEN_DEATH = 52437

local Arms = {}

function Arms.DoCombat(player, target)
	if not player:HasAura(AURA_BATTLE_SHOUT) and SPELL_BATTLE_SHOUT:CanCast(target) then
		SPELL_BATTLE_SHOUT:Cast(player)
		return
	end

	if player:HasAura(AURA_VICTORIOUS) and player:GetHealthPercent() < 80 and SPELL_VICTORY_RUSH:CanCast(target) then
		SPELL_VICTORY_RUSH:Cast(target)
		return
	end

	if not target:HasAuraByPlayer(AURA_REND) and SPELL_REND:CanCast(target) then
		SPELL_REND:Cast(target)
		return
	end

	if #player:GetNearbyEnemyUnits(8) > 1 then
		Arms.AoERotation(player, target)
	else
		Arms.SingleRotation(player, target)
	end
end

function Arms.AoERotation(player, target)
	if SPELL_WARBREAKER:CanCast(target) then
		SPELL_WARBREAKER:Cast(player)
		return
	end
	
	if SPELL_BLADESTORM:CanCast(target) then
		SPELL_BLADESTORM:Cast(player)
		return
	end
	
	if SPELL_SWEEPING_STRIKES:CanCast(target) then
		SPELL_SWEEPING_STRIKES:Cast(player)
		return
	end
	
	if SPELL_MORTAL_STRIKE:CanCast(target) and player:GetRage() > 30 then
		SPELL_MORTAL_STRIKE:Cast(target)
		return
	end
	
	if SPELL_OVERPOWER:CanCast(target) then
		SPELL_OVERPOWER:Cast(target)
		return
	end
	
	if SPELL_WHIRLWIND:CanCast(target) and player:GetRage() > 30 then
		SPELL_WHIRLWIND:Cast(player)
		return
	end

	Arms.SingleRotation(player, target)
end

function Arms.SingleRotation(player, target)
	if SPELL_WARBREAKER:CanCast(target) then
		SPELL_WARBREAKER:Cast(player)
		return
	end
	
	if SPELL_EXECUTE:CanCast(target) and ((target:GetHealthPercent() < 20 and player:GetRage() > 20) or player:HasAura(AURA_SUDDEN_DEATH)) then
		SPELL_EXECUTE:Cast(target)
		return
	end
	
	if SPELL_MORTAL_STRIKE:CanCast(target) and player:GetRage() > 30 then
		SPELL_MORTAL_STRIKE:Cast(target)
		return
	end
	
	if SPELL_OVERPOWER:CanCast(target) then
		SPELL_OVERPOWER:Cast(target)
		return
	end
	
	if SPELL_SLAM:CanCast(target) and player:GetRage() > 50 then
		SPELL_SLAM:Cast(target)
		return
	end
end

return Arms