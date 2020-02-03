require('Common.Shared')

local havoc = require('Havoc')
local vengeance = require('Vengeance')

function Tick(event, player)
	local target = player:GetTarget()

	if not ShouldAttack(player, target) then
		return
	end

	if player:GetSpecializationId() == 577 then
		havoc.DoCombat(player, target)
		return
	elseif player:GetSpecializationId() == 581 then
		vengeance.DoCombat(player, target)
		return
	end
end

RegisterEvent(1, Tick)