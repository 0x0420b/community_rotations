require('Common.Shared')

local elemental = require('Elemental')
local enhancement = require('Enhancement')
local restoration = require('Restoration')

function Tick(event, player)
	local target = player:GetTarget()

	if player:GetSpecializationId() == 264 then
		restoration.DoCombat(player, target)
		return
	end
	
	if not ShouldAttackSpecial(player, target) then
		return
	end

	if player:GetSpecializationId() == 263 then
		enhancement.DoCombat(player, target)
		return
	end

	if not ShouldAttack(player, target) then
		return
	end

	if player:GetSpecializationId() == 262 then
		elemental.DoCombat(player, target)
		return
	end
end

RegisterEvent(1, Tick)