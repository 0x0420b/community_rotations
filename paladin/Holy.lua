local Spells =
{
	Aura_Mastery = Spell(31821),
	Avenging_Wrath = Spell(31884),
	Beacon_Of_Faith = Spell(156910),
	Beacon_Of_Light = Spell(53563),
	Bestow_Faith = Spell(223306),
	Blessing_Of_Freedom = Spell(1044),
	Blessing_Of_Protection = Spell(1022),
	Blessing_Of_Sacrifice = Spell(6940),
	Blinding_Light = Spell(115750),
	Cleanse = Spell(4987),
	Consecration = Spell(26573),
	Crusader_Strike = Spell(35395),
	Divine_Favor = Spell(210294),
	Divine_Protection = Spell(498),
	Divine_Shield = Spell(642),
	Divine_Steed = Spell(190784),
	Flash_Of_Light = Spell(19750),
	Hammer_Of_Justice = Spell(853),
	Hand_Of_Reckoning = Spell(62124),
	Holy_Avenger = Spell(105809),
	Holy_Light = Spell(82326),
	Holy_Shock = Spell(20473),
	Judgement = Spell(275773),
	Lay_On_Hands = Spell(633),
	Light_Of_Dawn = Spell(85222),
	Light_Of_The_Martyr = Spell(183998),
	Rule_Of_Law = Spell(214202)
}

local Buffs = 
{
	Infusion_Of_Light = 54149,
	Beacon_Of_Light = 53563,
	Beacon_Of_Faith = 156910,
	Food = 167152
}

local Debuffs =
{
	Boss_Devour = 255421
}

Settings = 
{
	hasBoV = true,
	autoBoL = false
}


local Holy = {}

function Holy.DoCombat(player, target)
	--// Normal checks.
	if player:IsDead() or
	player:IsMounted() or
	player:IsCasting() or
	player:HasTerrainSpellActive() or
	player:HasAura(Buffs.Food) then
	return
	end
	--//

	-->> Vars
	local findTank = nil
	local toHeal = getLowest(player)
	local HealthLevel = 0
	local multiHeal = 0
	local dispellCheck = nil
	local bopCheck = nil
	--<< Vars

	-->> Inits (AVOID UNNECESARY ITERATING)
	if Spells.Cleanse:IsReady() then
		dispellCheck = findDispell(player)
	end

	if player:InParty() or player:InRaid() then
		findTank = getTank(player)
		multiHeal = MultiLow(player)
		bopCheck = bossBops(player)
	end

	--<< Inits

	-- Set player toHeal so result is never nil. (SOLO)
	if toHeal == nil then 
		toHeal = player
	end
	--
	HealthLevel = toHeal:GetHealthPercent() -- Just to make it easy.


	-->> DO BUFFS

	if Settings.autoBoL and findTank ~= nil and not findTank:HasAura(Buffs.Beacon_Of_Light) then
		Cast(Spells.Beacon_Of_Light, findTank)
	end

	if player:GetHealthPercent() < 80 then
		Cast(Spells.Divine_Protection, player)
	end

	if player:GetHealthPercent() < 15 and player:InCombat() then
		Cast(Spells.Divine_Shield, player)
	end

	if bopCheck ~= nil then
		Cast(Spells.Blessing_Of_Protection, bopCheck)
	end
	--<< BUFFS

	-->> HEALING START
	if HealthLevel <= 10 and toHeal:InCombat() then
		Cast(Spells.Lay_On_Hands, toHeal)
	end

	if multiHeal > 2 and toHeal:InCombat() then
		Cast(Spells.Holy_Avenger, player)
	end

	if multiHeal > 1 and HealthLevel <= 75 and toHeal:InCombat() then
		Cast(Spells.Avenging_Wrath, player)
	end

	if dispellCheck ~= nil then
		Cast(Spells.Cleanse, dispellCheck)
	end

	if Settings.hasBoV and multiHeal > 2 and toHeal:InCombat() then
		Cast(Spells.Beacon_Of_Light, toHeal)
	end

	if multiHeal > 1 and player:IsFacing(toHeal:GetPosition()) and player:GetDistance(toHeal) < 40 then
		Cast(Spells.Light_Of_Dawn, player)
	end

	if multiHeal > 1 then
		Cast(Spells.Aura_Mastery, player)
	end

	if (multiHeal > 1 or HealthLevel <= 70) and player:GetDistance(toHeal) > 10 then
		Cast(Spells.Rule_Of_Law, player)
	end

	if anyRooted(player) ~= nil then
		Cast(Spells.Blessing_Of_Freedom, anyRooted(player))
	end

	if HealthLevel < 100 then
		Cast(Spells.Bestow_Faith, toHeal)
	end

	if HealthLevel <= 80 and toHeal ~= player and player:GetHealthPercent() > 80 and player:IsMoving() then
		Cast(Spells.Light_Of_The_Martyr, toHeal)
	end

	if HealthLevel <= 80 then
		Cast(Spells.Holy_Shock, toHeal)
	end

	if HealthLevel <= 40 and toHeal ~= player and player:GetHealthPercent() >= 80 then
		Cast(Spells.Light_Of_The_Martyr, toHeal)
	end

	if HealthLevel <= 70 then
		Cast(Spells.Flash_Of_Light, toHeal)
	end

	if HealthLevel <= 85 and player:HasAura(Buffs.Infusion_Of_Light) then
		Cast(Spells.Holy_Light, toHeal)
	end
	--<< HEALING

	-->>DPS Rota
	if target ~= nil and target:InCombat() then
		if not ShouldAttack(player, target) or player:GetManaPercent() < 40 then
			return
		end

		if Spells.Judgement:CanCast(target) then
			Spells.Judgement:Cast(target)
			return
		end

		if Spells.Holy_Shock:CanCast(target) then
			Spells.Holy_Shock:Cast(target)
			return
		end
		
		if Spells.Crusader_Strike:CanCast(target) then
			Spells.Crusader_Strike:Cast(target)
			return
		end

		if #player:GetNearbyEnemyUnits(8) > 1 and Spells.Consecration:CanCast(player) then
			Spells.Consecration:Cast(player)
			return
		end
	end
	-->>DPS Rota
	
end

function getTank(player)
	local findTank = player:GetNearbyFriendlyPlayers(40)
	local tank = nil
	for i = 1, #findTank do
		if (findTank[i]:InParty() or findTank[i]:InRaid()) and findTank[i]:GroupRole() == 1 then
			tank = findTank[i]
		end
	end
	return tank
end

function getLowest(player)
	local friendlies = player:GetNearbyFriendlyPlayers(40)
	local lowest = nil

	for i = 1, #friendlies do
		if (friendlies[i]:InParty() or friendlies[i]:InRaid()) and lowest == nil then
			lowest = friendlies[i]
		end

		if lowest ~= nil and (friendlies[i]:InParty() or friendlies[i]:InRaid()) and friendlies[i]:GetHealthPercent() < lowest:GetHealthPercent() then
			lowest = friendlies[i]
		end
	end

	if lowest ~= nil and player:GetHealthPercent() < lowest:GetHealthPercent() then
		lowest = player
	end

	return lowest
end

function MultiLow(player)
	local friendly = player:GetNearbyFriendlyPlayers(30)
	local lowcount = 0
	local selfcounted = false

	if player:GetHealthPercent() < 80 then
		lowcount = lowcount + 1
	end

	for i = 1, #friendly do
		if (friendly[i]:InParty() or friendly[i]:InRaid()) and friendly[i]:GetHealthPercent() < 80 then
			lowcount = lowcount + 1
		end
	end
	return lowcount
end

function findDispell(player)
	local friendly = player:GetNearbyFriendlyPlayers(40)
	for i = 1, #friendly do
		if (friendly[i]:InParty() or friendly[i]:InRaid()) and #friendly[i]:GetAuras(1,false,2) > 0 or #friendly[i]:GetAuras(1,false,8) > 0 or #friendly[i]:GetAuras(1,false,16) > 0 then
			return friendly[i]
		end
	end
	if #player:GetAuras(1,false,2) > 0 or #player:GetAuras(1,false,8) > 0 or #player:GetAuras(1,false,16) > 0 then
		return player
	end
	return nil
end

function anyRooted(player)
	local friendly = player:GetNearbyFriendlyPlayers(40)
	for i = 1, #friendly do
		if (friendly[i]:InParty() or friendly[i]:InRaid()) and friendly[i]:IsRooted() then
			return friendly[i]
		end
	end
end

function bossBops(player)
	local friendly = player:GetNearbyFriendlyPlayers(40)
	for i = 1, #friendly do
		if friendly[i]:InParty() or friendly[i]:InRaid() then
			if friendly[i]:HasAura(Debuffs.Boss_Devour) then
			return friendly[i]
			end
		end
	end
	return nil
end

function Cast(Spell, Unit) -- ToDO: Add logic for last spell cast and on whom.
	if Spell:CanCast(Unit) then
		Spell:Cast(Unit)
	end
end

return Holy