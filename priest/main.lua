require('Common.Shared')

local discipline = require('Discipline')
local holy = require('Holy')
local shadow = require('Shadow')

function Tick(event, player)
	local target = player:GetTarget()

	if player:GetSpecializationId() == 256 then
		discipline.DoCombat(player, target)
		return
	elseif player:GetSpecializationId() == 258 then
		shadow.DoCombat(player, target)
		return
	end
	
	if not ShouldAttack(player, target) then
		return
	end

	if player:GetSpecializationId() == 257 then
		holy.DoCombat(player, target)
		return
	end
end

RegisterEvent(1, Tick)