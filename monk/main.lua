require('Common.Shared')

local brewmaster = require('Brewmaster')
local windwalker = require('Windwalker')
local mistweaver = require('Mistweaver')

function Tick(event, player)
	local target = player:GetTarget()

	if player:GetSpecializationId() == 270 then
		mistweaver.DoCombat(player, target)
		return
	end
	if player:GetSpecializationId() == 268 then
		brewmaster.DoCombat(player, target)
		return
	elseif player:GetSpecializationId() == 269 then
		windwalker.DoCombat(player, target)
		return
	end
	if not ShouldAttack(player, target) then
		return
	end

end

RegisterEvent(1, Tick)