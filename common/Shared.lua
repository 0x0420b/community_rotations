function ShouldAttack(player, target)
	if player:IsMounted() or
		not target or
		(not player:InCombat() and not target:InCombat()) or
		target:IsDead() or
		target:IsFriendlyWithPlayer() or
		not player:IsFacing(target:GetPosition()) or
		player:IsCasting() or
		player:IsChanneling() or
		player:HasTerrainSpellActive() then
		return false
	end

	return true
end

function ShouldAttackSpecial(player, target)
	if player:IsMounted() or
		not target or
		(not player:InCombat() and not target:InCombat()) or
		target:IsDead() or
		target:IsFriendlyWithPlayer() or
		not player:IsFacing(target:GetPosition()) or
		player:IsCasting() or
		player:HasTerrainSpellActive() then
		return false
	end

	return true
end

-- Sort table function
function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end