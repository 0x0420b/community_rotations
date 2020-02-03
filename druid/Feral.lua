
local Spells =
{
	Moonfire = Spell(8921),
	Rake = Spell(1822),
	Shred = Spell(5221),
	Rip = Spell(1079),
	FerociousBite = Spell(22568),
	BrutalSlash = Spell(202028),
	Thrash = Spell(106832),
	SkullBash = Spell(106839),
	SurvivalInstincts = Spell(61336),
	Berserk = Spell(106951),
	TigersFury = Spell(5217),
	Maim = Spell(22570),
	Regrowth = Spell(8936)
}

local Buffs = 
{
	CatForm = 768,
	Prowl = 5215,
	TigersFury = 5217,
	Berserk = 106951,
	SurvivalInstincts = 61336,
	Clearcasting = 135700,
	PredatorySwiftness = 69369,
	BloodTalons = 145152
}

local Debuffs = 
{
	Moonfire = 155625,
	Rake = 155722,
	Rip = 1079,
	Thrash = 106830,
}

local Feral = {}

function Feral.DoCombat(player, target)
	local Predatory = player:GetAura(Buffs.PredatorySwiftness)

	if player:HasAura(Buffs.Prowl) or not player:HasAura(Buffs.CatForm) then return end

	if Spells.Berserk:CanCast() and player:GetEnergy() >= 30 then
		Spells.Berserk:Cast(player)
		return
	end

	if Spells.TigersFury:CanCast() and player:GetEnergy() <= 30 then
		Spells.TigersFury:Cast(player)
		return
	end

	if Spells.Regrowth:CanCast() and player:HasAura(Buffs.PredatorySwiftness) and not player:HasAura(Buffs.BloodTalons) and (player:GetComboPoints() >= 4 or player:GetHealthPercent() <= 80 or Predatory:GetTimeleft() < 2000) then
		Spells.Regrowth:Cast(player)
		return
	end

	if player:GetComboPoints() >= 4 then
		Feral.SpendPoints(player, target)
	else
		Feral.GeneratePoints(player, target)
	end
end

function Feral.SpendPoints(player, target)
	local tarRip = target:GetAura(Debuffs.Rip)
	local Enemies = player:GetNearbyEnemyUnits(8)
	for i = 1, #Enemies do
		if player:IsFacing(Enemies[i]:GetPosition()) then
			local addRip = Enemies[i]:GetAura(Debuffs.Rip)
			if (addRip == nil or addRip:GetTimeleft() < 4000) and (Enemies[i]:GetHealthPercent() > 25 or tarRip == nil) and Spells.Rip:CanCast(Enemies[i]) then
				Spells.Rip:Cast(Enemies[i])
				return
			end
			if addRip ~= nil and addRip:GetTimeleft() < 4000 and Enemies[i]:GetHealthPercent() < 25 and Spells.FerociousBite:CanCast(Enemies[i]) then
				Spells.FerociousBite:Cast(Enemies[i])
				return
			end
		end
	end

	if (tarRip == nil or tarRip:GetTimeleft() < 4000) and (target:GetHealthPercent() > 25 or tarRip == nil) then
		if Spells.Rip:CanCast(target) then
			Spells.Rip:Cast(target)
		end
		return
	end

	if Spells.FerociousBite:CanCast(target) then
		Spells.FerociousBite:Cast(target)
		return
	end
end

function Feral.GeneratePoints(player, target)
	local tarMoonfire = target:GetAura(Debuffs.Moonfire)
	local tarRake = target:GetAura(Debuffs.Rake)
	local tarThrash = target:GetAura(Debuffs.Thrash)
	local Enemies = player:GetNearbyEnemyUnits(8)

	if #Enemies > 1 and #Enemies < 5 then
		for i = 1, #Enemies do
		if player:IsFacing(Enemies[i]:GetPosition()) then
			local addRake = Enemies[i]:GetAura(Debuffs.Rake)
			local addThrash = Enemies[i]:GetAura(Debuffs.Thrash)
				if (addRake == nil or addRake:GetTimeleft() < 2500) and Spells.Rake:CanCast(Enemies[i]) then
					Spells.Rake:Cast(Enemies[i])
					return
				end

				if (addThrash == nil or addThrash:GetTimeleft() < 2000) and Spells.Thrash:CanCast(Enemies[i]) then
					Spells.Thrash:Cast(Enemies[i])
					return
				end
			end
		end
	end

	if #Enemies >= 5 and #Enemies <= 8 then
		for i = 1, #Enemies do
			if player:IsFacing(Enemies[i]:GetPosition()) then
				local addRake = Enemies[i]:GetAura(Debuffs.Rake)
				local addThrash = Enemies[i]:GetAura(Debuffs.Thrash)
				if (addThrash == nil or addThrash:GetTimeleft() < 2000) and Spells.Thrash:CanCast(Enemies[i]) then
					Spells.Thrash:Cast(Enemies[i])
					return
				end
				if (addRake == nil or addRake:GetTimeleft() < 2500) and Spells.Rake:CanCast(Enemies[i]) and player:GetEnergy() >= 40 then
					Spells.Rake:Cast(Enemies[i])
					return
				end
			end
		end
	end

	if #Enemies > 8 then
		for i = 1, #Enemies do
			if player:IsFacing(Enemies[i]:GetPosition()) then
				local addThrash = Enemies[i]:GetAura(Debuffs.Thrash)
				if (addThrash == nil or addThrash:GetTimeleft() < 2000) and Spells.Thrash:CanCast(Enemies[i]) then
					Spells.Thrash:Cast(Enemies[i])
					return
				end
			end
		end
	end

	if Spells.BrutalSlash:CanCast() and #player:GetNearbyEnemyUnits(8) > 1 then
		Spells.BrutalSlash:Cast(player)
		return
	end

	if Spells.Thrash:CanCast() and (tarThrash == nil or tarThrash:GetTimeleft() < 2000) then
		Spells.Thrash:Cast(player)
		return
	end

	if Spells.Rake:CanCast(target) and (tarRake == nil or (player:HasAura(Buffs.BloodTalons) and tarRake:GetTimeleft() < 2500)) then
		Spells.Rake:Cast(target)
		return
	end

	if Spells.Shred:CanCast(target) then
		Spells.Shred:Cast(target)
		return
	end
end

return Feral