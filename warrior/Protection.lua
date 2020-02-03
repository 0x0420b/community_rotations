-- Offensive spells
local SPELL_SHIELD_SLAM = Spell(23922)
local SPELL_THUNDER_CLAP = Spell(6343, 8) 
local SPELL_DEMO_SHOUT = Spell(1160, 8)
local SPELL_REVENGE = Spell(6572, 5)
local SPELL_DEVASTATE = Spell(20243)
local SPELL_BATTLE_SHOUT = Spell(6673)
local SPELL_VICTORY_RUSH = Spell(34428)
local SPELL_PUMMEL = Spell(6552)

-- Self buffs
local SPELL_SHIELD_BLOCK = Spell(2565, 10)
local SPELL_IGNORE_PAIN = Spell(190456, 10)
local SPELL_SHIELD_WALL = Spell(871)
local SPELL_LAST_STAND = Spell(12975)
local SPELL_AVATAR = Spell(107574, 10)
local SPELL_RALLYING_CRY = Spell(97462)

-- Buffs
local AURA_SHIELD_WALL = 871
local AURA_LAST_STAND = 12975
local AURA_AVATAR = 107574
local AURA_BATTLE_SHOUT = 6673
local AURA_VICTORIOUS = 32216
local AURA_SHIELD_BLOCK = 132404
local AURA_VENGEANCE_IGNORE_PAIN = 202574

local Protection = {}

function Protection.DoCombat(player, target)

	local units = player:GetNearbyEnemyUnits(30)
	for i = 1, #units do
		if units[i]:InCombat() and doInterrupt(units[i]) then
			if SPELL_PUMMEL:CanCast(units[i]) then
				SPELL_PUMMEL:Cast(units[i])
			end
		end
	end

	if not player:HasAura(AURA_BATTLE_SHOUT) and SPELL_BATTLE_SHOUT:CanCast() then
		SPELL_BATTLE_SHOUT:Cast(player)
		return
	end

	if player:HasAura(AURA_VICTORIOUS) and player:GetHealthPercent() < 80 and SPELL_VICTORY_RUSH:CanCast(target) then
		SPELL_VICTORY_RUSH:Cast(target)
		return
	end

	if player:GetHealthPercent() < 30 and SPELL_SHIELD_WALL:CanCast() and not player:HasAura(AURA_LAST_STAND) then
		SPELL_SHIELD_WALL:Cast(player)
		return
	end

	if player:GetHealthPercent() < 20 and SPELL_LAST_STAND:CanCast() and not player:HasAura(AURA_SHIELD_WALL) then
		SPELL_LAST_STAND:Cast(player)
	end

	if player:GetHealthPercent() < 20 and SPELL_RALLYING_CRY:CanCast() and
		not SPELL_LAST_STAND:CanCast() and not player:HasAura(AURA_LAST_STAND) and
		not SPELL_SHIELD_WALL:CanCast() and not player:HasAura(AURA_SHIELD_WALL) then
		SPELL_RALLYING_CRY:Cast(player)
		return
	end

	local players = player:GetNearbyFriendlyPlayers(40)
	for i = 1, #players do
		if players[i]:GetHealthPercent() < 20 and SPELL_RALLYING_CRY:CanCast() then
			SPELL_RALLYING_CRY:Cast(player)
			return
		end
	end

	if #player:GetNearbyEnemyUnits(12) > 1 then
		Protection.AoERotation(player, target)
	else
		Protection.SingleRotation(player, target)
	end
end

function Protection.AoERotation(player, target)
	Protection.SingleRotation(player, target)
end

function Protection.SingleRotation(player, target)
	if SPELL_IGNORE_PAIN:CanCast(target) then-- and player.RagePercent > 70 then
		SPELL_IGNORE_PAIN:Cast(player)
		return
	end

	if SPELL_THUNDER_CLAP:CanCast(target) and player:GetDistance(target) < 10 then
		SPELL_THUNDER_CLAP:Cast(player)
		return
	end

	if SPELL_REVENGE:CanCast() then-- and player.RagePercent > 30 then
		SPELL_REVENGE:Cast(target)
		return
	end

	if player:GetHealthPercent() < 90 and player:GetRage() > 30 and SPELL_SHIELD_BLOCK:CanCast(target) and not player:HasAura(AURA_SHIELD_BLOCK) then
		SPELL_SHIELD_BLOCK:Cast(player)
		return
	end

	if SPELL_SHIELD_SLAM:CanCast(target) then
		SPELL_SHIELD_SLAM:Cast(target)
		return
	end

	if SPELL_DEMO_SHOUT:CanCast(target) then
		SPELL_DEMO_SHOUT:Cast(player)
		return
	end

	if SPELL_AVATAR:CanCast() then
		SPELL_AVATAR:Cast(player)
		return
	end

	if SPELL_DEVASTATE:CanCast(target) then
		SPELL_DEVASTATE:Cast(target)
		return
	end
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

return Protection