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

-- Return the tank as a unit. (returns unit)
function GetTank(player)
    local findTank = player:GetNearbyFriendlyPlayers(40)
    local tank

    for i = 1, #findTank do
        if (findTank[i]:InParty() or findTank[i]:InRaid()) and findTank[i]:GroupRole() == 1 then 
            tank = findTank[i] 
        end
    end

    return tank
end

-- return the lowest damaged party/raid member as a unit. (returns unit)
function GetLowest(player)
    local friendlies = player:GetNearbyFriendlyPlayers(40)
    local lowest

    for i = 1, #friendlies do
        if not friendlies[i]:IsDead() then
            if (friendlies[i]:InParty() or friendlies[i]:InRaid()) and not lowest then
                lowest = friendlies[i]
            end

            if lowest and (friendlies[i]:InParty() or friendlies[i]:InRaid()) and
                friendlies[i]:GetHealthPercent() < lowest:GetHealthPercent() then
                lowest = friendlies[i]
            end
        end
    end

    if lowest and player:GetHealthPercent() < lowest:GetHealthPercent() then
        lowest = player
    end

    return lowest
end

-- check for multiple damaged friendly units with a threshold of x percent. (returns int)
function MultiLow(player, threshold)
    local friendly = player:GetNearbyFriendlyPlayers(30)
    local lowcount = 0

    if player:GetHealthPercent() < threshold then lowcount = lowcount + 1 end

    for i = 1, #friendly do
        if (friendly[i]:InParty() or friendly[i]:InRaid()) and
            friendly[i]:GetHealthPercent() < threshold then
            lowcount = lowcount + 1
        end
	end
	
    return lowcount
end

-- Get the cooldown left on a spell. (returns int in seconds)
function GetCooldownLeft(spell)
	return select(3, spell:GetCooldownInfo())/1000 or 999999
end

-- Returns the stacks on an aura (returns int)
function GetAuraStacks(player, aura)
	local theAura = player:GetAura(aura)
	if theAura then
		return theAura:GetStacks()
	else
		return 0
	end
end

-- returns the time left on an aura on unit specified (returns int in miliseconds)
function GetAuraTimeleft(unit, aura)
	local theAura = unit:GetAura(aura)
	if theAura then
		return theAura:GetTimeLeft()
	else
		return 0
	end
end