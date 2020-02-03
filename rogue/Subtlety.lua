local Subletly = {}

function Subletly.DoCombat(player, target)
	if #player:GetNearbyUnits(12) > 1 then
		Subletly.AoERotation(player, target)
	else
		Subletly.SingleRotation(player, target)
	end
end

function Subletly.AoERotation(player, target)
	
end

function Subletly.SingleRotation(player, target)
	
end

return Subletly