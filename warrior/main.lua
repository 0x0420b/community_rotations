require('Common.Shared')

local arms = require('Arms')
local fury = require('Fury')
local protection = require('Protection')

function Tick(event, player)
	local target = player:GetTarget()
	
	if not ShouldAttack(player, target) then
		return
	end

	if player:GetSpecializationId() == 71 then
		arms.DoCombat(player, target)
		return
	elseif player:GetSpecializationId() == 72 then
		fury.DoCombat(player, target)
		return
	elseif player:GetSpecializationId() == 73 then
		protection.DoCombat(player, target)
		return
	end
end

RegisterEvent(1, Tick)