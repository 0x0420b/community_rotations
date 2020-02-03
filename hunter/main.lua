require('Common.Shared')

local beastmastery = require('Beastmastery')
local marksmanship = require('Marksmanship')
local survival = require('Survival')

function Tick(event, player)
	local target = player:GetTarget()

	if not ShouldAttack(player, target) then
		return
	end

	if player:GetSpecializationId() then
		beastmastery.DoCombat(player, target)
		return
	elseif player:GetSpecializationId() == 254 then
		marksmanship.DoCombat(player, target)
		return
	elseif player:GetSpecializationId() == 255 then
		survival.DoCombat(player, target)
		return
	end
end

RegisterEvent(1, Tick)