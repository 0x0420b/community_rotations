local SPELL_IMMOLATE = Spell(348, 40)
local SPELL_CHAOS_BOLT = Spell(116858, 40)
local SPELL_CONFLAGRATE = Spell(17962, 40)
local SPELL_CHANNEL_DEMONFIRE = Spell(196447, 40)
local SPELL_INCINERATE = Spell(29722, 40)
local SPELL_RAIN_OF_FIRE = Spell(5740, 35)
local SPELL_HAVOC = Spell(80240, 40)

local AURA_IMMOLATE = 157736

local HavocHP = 10000

local Destruction = {}

function Destruction.DoCombat(player, target)
	if #player:GetNearbyEnemyUnits(12) > 1 then
		Destruction.AoERotation(player, target)
	else
		Destruction.SingleRotation(player, target)
	end
end

function Destruction.AoERotation(player, target)
	local enemies = player:GetNearbyEnemyUnits(40) -- Get all nearby enemies.
	local shard = player:GetSoulShards()
	local function BestAoETarget(player, range, nearRange)
		local units = player:GetNearbyEnemyUnits(range)
		local bestUnit = nil
		local bestNum = 0
		for i = 1, #units do
			local nearUnits = units[i]:GetNearbyEnemyUnits(nearRange)
			if #nearUnits > bestNum then
				bestNum = #nearUnits
				bestUnit = units[i]
			end
		end
		return bestUnit
	end
	local bestUnit = BestAoETarget(player, 40, 12)
	local havocTarget = nil


	for i = 1, #enemies do
		if enemies[i]:GetHealth() > HavocHP and target ~= enemies[i] and enemies[i]:InCombat() and havocTarget == nil then
			havocTarget = enemies[i]
		end
	end

	if havocTarget ~= nil and SPELL_HAVOC:CanCast(havocTarget) then
		SPELL_HAVOC:Cast(havocTarget)
		return
	end

	if bestUnit ~= nil and bestUnit:InCombat() and SPELL_RAIN_OF_FIRE:CanCast(bestUnit) and #bestUnit:GetNearbyEnemyUnits(12) >= 5 then
		SPELL_RAIN_OF_FIRE:CastAoF(bestUnit:GetPosition())
		return
	end

	Destruction.SingleRotation(player, target)
end

function Destruction.SingleRotation(player, target)
	local Immolate = target:GetAuraByPlayer(AURA_IMMOLATE)
	local shard = player:GetSoulShards()

	if Immolate == nil and SPELL_IMMOLATE:CanCast(target) and not player:IsMoving() then
		SPELL_IMMOLATE:Cast(target)
		return
	end

	if SPELL_CONFLAGRATE:CanCast(target) then
		SPELL_CONFLAGRATE:Cast(target)
		return
	end

	if SPELL_CHANNEL_DEMONFIRE:CanCast(target) and not player:IsMoving() then
		SPELL_CHANNEL_DEMONFIRE:Cast(target)
		return
	end

	if SPELL_CHAOS_BOLT:CanCast(target) and (#target:GetNearbyEnemyUnits(15) <= 5 or shard == 5) and not player:IsMoving() then
		SPELL_CHAOS_BOLT:Cast(target)
		return
	end

	if SPELL_INCINERATE:CanCast(target) and not player:IsMoving() then
		SPELL_INCINERATE:Cast(target)
		return
	end

end

return Destruction