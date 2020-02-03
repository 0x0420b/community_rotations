require('Common.Shared')

local blood = require('Blood')
local frost = require('Frost')
local unholy = require('Unholy')

function Tick(event, player)
	local target = player:GetTarget()

	if not ShouldAttack(player, target) then
		return
	end

	if player:GetSpecializationId() == 250 then
		blood.DoCombat(player, target)
		return
	elseif player:GetSpecializationId() == 251 then
		frost.DoCombat(player, target)
		return
	elseif player:GetSpecializationId() == 252 then
		unholy.DoCombat(player, target)
		return
	end
end

RegisterEvent(1, Tick)