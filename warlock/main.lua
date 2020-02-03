require('Common.Shared')

local affliction = require('Affliction')
local demonology = require('Demonology')
local destruction = require('Destruction')

function Tick(event, player)
	local target = player:GetTarget()

	if not ShouldAttack(player, target) then
		return
	end

	if player:GetSpecializationId() == 265 then
		affliction.DoCombat(player, target)
		return
	end
	if player:GetSpecializationId() == 266 then
		demonology.DoCombat(player, target)
		return
	elseif player:GetSpecializationId() == 267 then
		destruction.DoCombat(player, target)
		return
	end
end

RegisterEvent(1, Tick)