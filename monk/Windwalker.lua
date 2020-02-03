local Windwalker = {}

function Windwalker.DoCombat(player, target)
	if #player:NearbyUnits(12) > 1 then
		Windwalker.AoERotation(player, target)
	else
		Windwalker.SingleRotation(player, target)
	end
end

function Windwalker.AoERotation(player, target)
	
end

function Windwalker.SingleRotation(player, target)
	
end

return Windwalker