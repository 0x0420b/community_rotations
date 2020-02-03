
--Abilites
local SPELL_MARKED_FOR_DEATH = Spell(137619)
local SPELL_MUTILATE = Spell(1329)
local SPELL_ENVENOM = Spell(32645)
local SPELL_KIDNEY_SHOT = Spell(408)
local SPELL_RUPTURE = Spell(1943)
local SPELL_GARROTE = Spell(703)
local SPELL_CRIMSON_VIAL = Spell(185311)
local SPELL_CLOAK_OF_SHADOWS = Spell(31224)
local SPELL_EVASION = Spell(5277)
local SPELL_FEINT = Spell(1966)
local SPELL_VANDETTA = Spell(79140)
local SPELL_FAN_OF_KNIVES = Spell(51723, 10)
local SPELL_KICK = Spell(1766, 8)
local SPELL_DEADLY_POISON = Spell(2823)
local SPELL_CRIPPLING_POISON = Spell(3408)
local SPELL_TRICKS_OF_THE_TRADE = Spell(57934)

--Talents
local SPELL_TOXIC_BLADE = Spell(245388)
local SPELL_MAKRED_FOR_DEATH = Spell(137619)
local SPELL_EXSANGUINATE = Spell(200806)
local SPELL_BLINDSIDE = Spell(111240)
local SPELL_CRIMSON_TEMPEST = Spell(121411)

--Buffs
local AURA_STEALTH = 115191
local AURA_VANISH = 11327
local AURA_DEADLY_POISON = 2823
local AURA_CRIPPLING_POISON = 3408
local AURA_SUBTERFUGE = 115192

local Assassination = {}
local pvp = false
local interrupt = true

function Assassination.DoCombat(player, target)
	if player:HasAura(AURA_STEALTH) or player:HasAura(AURA_VANISH) then
		return
	end
	
	local units = player:GetNearbyEnemyUnits(5)
	for i = 1, #units do
		if (units[i]):GetEntry() == 120651 and units[i]:GetHealthPercent() > 0 then
			if SPELL_MUTILATE:CanCast(units[i]) then
				SPELL_MUTILATE:Cast(units[i])
				return
			end
		end
	end


	if #player:GetNearbyEnemyUnits(9) > 1 then
		Assassination.AoERotation(player, target)
	else
		Assassination.SingleRotation(player, target)
	end
end

function Assassination.AoERotation(player, target)
	local RupCount = 0
	local GarroteCount = 0
	local enemies = player:GetNearbyEnemyUnits(9) -- Get all nearby enemies.

	for i = 1, #enemies do
		local Rupturee = enemies[i]:GetAuraByPlayer(1943) -- 1943 is the aura caused by rupture.
		local garroteAura = enemies[i]:GetAuraByPlayer(703) -- 703 is the aura caused by Garrote.
		
		if Rupturee ~= nil then
			RupCount = RupCount + 1
		end
		if garroteAura ~= nil then
			GarroteCount = GarroteCount + 1
		end
	
		if SPELL_GARROTE:CanCast(enemies[i]) and (garroteAura == nil or garroteAura:GetTimeleft() < 3000) and GarroteCount < 3 then
			SPELL_GARROTE:Cast(enemies[i])
			return
		end
		if SPELL_RUPTURE:CanCast(enemies[i]) and (Rupturee == nil or Rupturee:GetTimeleft() < 2000) and player:GetComboPoints() >= 3 and RupCount < 3 then
			SPELL_RUPTURE:Cast(enemies[i])
			return
		end
	end
	
	if player:GetComboPoints() >= 4 and SPELL_CRIMSON_TEMPEST:CanCast(target) then
		SPELL_CRIMSON_TEMPEST:Cast(target)
		return
	end
	
	-- Only cast FoK if no enemy players are within 12 yards.
	if #player:GetNearbyEnemyPlayers(12) == 0 then
		if player:GetComboPoints() <= 4 and SPELL_FAN_OF_KNIVES:CanCast() and #player:GetNearbyEnemyUnits(9) > 2 then
			SPELL_FAN_OF_KNIVES:Cast(player)
			return
		end
	end

	
	if not SPELL_CRIMSON_TEMPEST:CanCast() and player:GetComboPoints() >= 4 and SPELL_ENVENOM:CanCast(target) then
		SPELL_ENVENOM:Cast(target)
		return
	end
	

	Assassination.SingleRotation(player, target)
end

function Assassination.SingleRotation(player, target)

	local nmycount = player:GetNearbyEnemyUnits(10)
	
	if interrupt then
		for i = 1, #nmycount do
			if Assassination.ShouldInterrupt(nmycount[i]) then
				if SPELL_KICK:CanCast(nmycount[i]) then
					SPELL_KICK:Cast(nmycount[i])
					return
				end
			end
		end
	end
	
	if SPELL_TRICKS_OF_THE_TRADE:CanCast() then
		local players = player:GetNearbyFriendlyPlayers(100)
		for i = 1, #players do
			if players[i]:GroupRole() == 1 and SPELL_TRICKS_OF_THE_TRADE:CanCast(players[i]) then
				SPELL_TRICKS_OF_THE_TRADE:Cast(players[i])
			end
		end
	end

	if player:GetHealthPercent() < 65 and player:GetEnergy() > 40 and SPELL_CRIMSON_VIAL:CanCast() then
		SPELL_CRIMSON_VIAL:Cast(player)
		return
	end
	
	local garroteAura = target:GetAuraByPlayer(703)
    if SPELL_GARROTE:CanCast(target) and (garroteAura == nil or garroteAura:GetTimeleft() < 3000) then
        SPELL_GARROTE:Cast(target)
        return
    end

	local ruptureAura = target:GetAuraByPlayer(1943)
	if player:GetComboPoints() >=4 and (ruptureAura == nil or (ruptureAura:GetTimeleft() < 5000 and SPELL_RUPTURE:CanCast(target))) then
	SPELL_RUPTURE:Cast(target)
		return
	end

	if SPELL_EXSANGUINATE:CanCast(target) then
		local condRupture = (ruptureAura ~= nil and ruptureAura:GetTimeleft() > 20 * 1000)
		local condGarrote = (garroteAura ~= nil and (garroteAura:GetTimeleft() - (garroteAura:GetDuration() * 0.5)) > 0)
		if condRupture and condGarrote then
			SPELL_EXSANGUINATE:Cast(target)
			return
		end
	end

	if pvp then
		if player:GetComboPoints() > 4 and SPELL_KIDNEY_SHOT:CanCast(target) then
			if (player:GetEnergy() < 75) then
				return
			end
			SPELL_KIDNEY_SHOT:Cast(target)
			return
		end
	end

	if player:GetComboPoints() > 4 and SPELL_ENVENOM:CanCast(target) then
		SPELL_ENVENOM:Cast(target)
		return
	end

	if player:GetComboPoints() <= 1 and SPELL_MARKED_FOR_DEATH:CanCast(target) then
		SPELL_MARKED_FOR_DEATH:Cast(target)
		return
	end

	if player:GetComboPoints() <= 4 and SPELL_TOXIC_BLADE:CanCast(target) then
		SPELL_TOXIC_BLADE:Cast(target)
		return
	end

	if player:GetComboPoints() <= 4 and SPELL_BLINDSIDE:CanCast(target) then
		SPELL_BLINDSIDE:Cast(target)
		return
	end

	if player:GetComboPoints() <= 4 and SPELL_MUTILATE:CanCast(target) then
		SPELL_MUTILATE:Cast(target)
		return
	end

end

function Assassination.ShouldInterrupt(target)
    if target:IsCasting() or target:IsChanneling() then
      	-- get info and check interruptible
    	local sprop = target:GetCurrentSpell()
    	if sprop ~= nil then
    		if sprop:IsInterruptible() then
                return true -- if interruptable
            end
        end
    end
    return false
  end

return Assassination