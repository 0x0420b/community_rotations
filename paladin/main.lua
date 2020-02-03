require('Common.Shared')

local holy = require('Holy')
local protection = require('Protection')
local retribution = require('Retribution')

function Tick(event, player)
	local target = player:GetTarget()
	if player:GetSpecializationId() == 65 then
		holy.DoCombat(player, target)
		return
	end

	if not ShouldAttack(player, target) then
		return
	end
	
	if player:GetSpecializationId() == 66 then
		protection.DoCombat(player, target)
		return
	elseif player:GetSpecializationId() == 70 then
		retribution.DoCombat(player, target)
		return
	end
end

RegisterEvent(1, Tick)