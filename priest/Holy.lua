local Holy = {}

function Holy.DoCombat(player, target)
	if #player:GetNearbyUnits(12) > 1 then
		Holy.AoERotation(player, target)
	else
		Holy.SingleRotation(player, target)
	end
end

function Holy.AoERotation(player, target)
	
end

function Holy.SingleRotation(player, target)
	
end

return Holy