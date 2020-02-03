require('Common.Shared')

local arcane = require('Arcane')
local fire = require('Fire')
local frost = require('Frost')

function Tick(event, player)
	local target = player:GetTarget()

	if not ShouldAttack(player, target) then
		return
	end

	if player:GetSpecializationId() == 62 then
		arcane.DoCombat(player, target)
		return
	elseif player:GetSpecializationId() == 63 then
		fire.DoCombat(player, target)
		return
	elseif player:GetSpecializationId() == 64 then
		frost.DoCombat(player, target)
		return
	end
end

RegisterEvent(1, Tick)