local Arcane = {}

function Arcane.DoCombat(player, target)
	if #player:GetNearbyUnits(12) > 1 then
		Arcane.AoERotation(player, target)
	else
		Arcane.SingleRotation(player, target)
	end
end

function Arcane.AoERotation(player, target)
	
end

function Arcane.SingleRotation(player, target)
	
end

return Arcane