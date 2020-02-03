require('Common.Shared')

local balance = require('Balance')
local feral = require('Feral')
local guardian = require('Guardian')
local restoration = require('Restoration')

function Tick(event, player)
	local target = player:GetTarget()

	if player:GetSpecializationId() == 105 then
		restoration.DoCombat(player, target)
		return
	end
	if player:GetSpecializationId() == 102 then
		balance.DoCombat(player, target)
		return
	end

	if not ShouldAttack(player, target) then
		return
	end

	if player:GetSpecializationId() == 103 then
		feral.DoCombat(player, target)
		return
	elseif player:GetSpecializationId() == 104 then
		guardian.DoCombat(player, target)
		return
	end
end

RegisterEvent(1, Tick)