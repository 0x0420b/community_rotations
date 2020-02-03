local Survival = {}

function Survival.DoCombat(player, target)
	if #player:NearbyUnits(12) > 1 then
		Survival.AoERotation(player, target)
	else
		Survival.SingleRotation(player, target)
	end
end

function Survival.AoERotation(player, target)
	
end

function Survival.SingleRotation(player, target)
	
end

return Survival