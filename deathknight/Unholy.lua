-- TODO
-- Implement more talents
-- Test and change rotation for best performance
local SPELL_OUTBREAK = Spell(77575)
local SPELL_SOUL_REAPER = Spell(130736)
local SPELL_DARK_TRANSFORMATION = Spell(63560)
local SPELL_APOCALYPSE = Spell(275699)
local SPELL_DEATH_COIL = Spell(47541)
local SPELL_DEATH_AND_DECAY = Spell(43265, 30)
local SPELL_PESTILENCE = Spell(277234)
local SPELL_DEFILE = Spell(152280, 30)
local SPELL_SCOURGE_STRIKE = Spell(55090)
local SPELL_CLAWING_SHADOWS = Spell(207311)
local SPELL_FESTERING_STRIKE = Spell(85948)
local SPELL_UNHOLY_FRENZY = Spell(207289, 12)
local SPELL_RAISE_DEAD = Spell(46584, 10)
local SPELL_ARMY_OF_THE_DEAD = Spell(42650, 30)
local SPELL_RAISE_ABOMINATION = Spell(288853, 30)
local SPELL_EPIDEMIC = Spell(207317)
local SPELL_DEATH_STRIKE = Spell(49998)
local SPELL_NECROTIC_STRIKE = Spell(223829)

local AURA_OUTBREAK = 196782
local AURA_SUDDEN_DOOM = 81340
local AURA_FESTERING_WOUNDS = 194310
local AURA_VIRULENT_PLAGUE = 191587
local AURA_DARK_SUCCOR = 101568

local Unholy = {}
local pvp = false
local interrupt = true

function Unholy.DoCombat(player, target)
	if player:GetPet() == nil and SPELL_RAISE_DEAD:CanCast(target) then
		SPELL_RAISE_DEAD:Cast(player)
	end

	Unholy.SingleRotation(player, target)
end

function Unholy.SingleRotation(player, target)

	local units = player:GetNearbyEnemyUnits(10)
	local festeringOnTarget = target:GetAuraByPlayer(AURA_FESTERING_WOUNDS)


	for i = 1, #units do
		if (units[i]):GetEntry() == 120651 and units[i]:GetHealthPercent() > 0 then
			if SPELL_DEATH_STRIKE:CanCast(units[i]) and player:GetRunicPowerPercent() > 45 then 
				SPELL_DEATH_STRIKE:Cast(units[i])
				return
			end
			if SPELL_FESTERING_STRIKE:CanCast(units[i]) then
				SPELL_FESTERING_STRIKE:Cast(units[i])
				return
			end
		end
	end
	
	if not target:HasAuraByPlayer(AURA_VIRULENT_PLAGUE) then
		if SPELL_OUTBREAK:CanCast(target) then
			SPELL_OUTBREAK:Cast(target)
			return
		end
	end


	if player:GetHealth() < player:GetHealthMax()*0.9 and player:HasAura(AURA_DARK_SUCCOR) and SPELL_DEATH_STRIKE:CanCast(target) then
		SPELL_DEATH_STRIKE:Cast(target)
	end
	
	-- oh shit moment 35% - health is returned as TOTAL so have to calculate
	if player:GetHealth() < player:GetHealthMax()*0.35 and player:GetRunicPower() >= 45 and SPELL_DEATH_STRIKE:CanCast(target) then
		SPELL_DEATH_STRIKE:Cast(target)
	end
	
	if interrupt then
		for i = 1, #units do
			if units[i]:InCombat() and Blood.ShouldInterrupt(units[i]) then
				if SPELL_MIND_FREEZE:CanCast(units[i]) then
					SPELL_MIND_FREEZE:Cast(units[i])
					return
				end
			end
		end
	end

	
	if target:HasAuraByPlayer(AURA_VIRULENT_PLAGUE) and SPELL_OUTBREAK:CanCast(target) then
		local outbreakAuraViruletPlague = target:GetAuraByPlayer(AURA_VIRULENT_PLAGUE)
		if outbreakAuraViruletPlague ~= nil and outbreakAuraViruletPlague:GetTimeleft() < 2000 then
			SPELL_OUTBREAK:Cast(target)
			return
		end
	end

	if player:NumRunesReady() < 2 and SPELL_SOUL_REAPER:CanCast(target) then
		SPELL_SOUL_REAPER:Cast(target)
		return
	end
	
	if not pvp then
		if SPELL_ARMY_OF_THE_DEAD:CanCast(target) then
			SPELL_ARMY_OF_THE_DEAD:Cast(target)
			return
		end
	end
	
	if SPELL_RAISE_ABOMINATION:CanCast(target) then
		SPELL_RAISE_ABOMINATION:CastAoF(target)
		return
	end

	if player:GetPet() ~= nil and SPELL_DARK_TRANSFORMATION:CanCast(target) then
		SPELL_DARK_TRANSFORMATION:Cast(player)
		return
	end


	
	if festeringOnTarget and festeringOnTarget:GetStacks() >= 4 and SPELL_APOCALYPSE:CanCast(target) then
		SPELL_APOCALYPSE:Cast(target)
		return
	end
	
	if player:NumRunesReady() > 1 and SPELL_UNHOLY_FRENZY:CanCast(target) then
		SPELL_UNHOLY_FRENZY:Cast(target)
		return
	end
	
	if player:HasAura(81340) and SPELL_DEATH_COIL:CanCast(target) then
		SPELL_DEATH_COIL:Cast(target)
		return
    end
	
	-- rotation for multi target part 1
	if player:GetRunicPower() > 70 then
		if #player:GetNearbyEnemyUnits(10) > 1 and SPELL_EPIDEMIC:CanCast(target)  then
			SPELL_EPIDEMIC:Cast(target)
			return
		elseif SPELL_DEATH_COIL:CanCast(target) then
			SPELL_DEATH_COIL:Cast(target)
			return
		end
	end

	if SPELL_DEFILE:CanCast(target) then
		SPELL_DEFILE:CastAoF(target)
		return
	end
	
	if SPELL_DEATH_AND_DECAY:CanCast(target) then
		SPELL_DEATH_AND_DECAY:CastAoF(target)
		return
	end
	
	if pvp then
		if festeringOnTarget and festeringOnTarget:GetStacks() >= 1 and SPELL_NECROTIC_STRIKE:CanCast(target) then
				SPELL_NECROTIC_STRIKE:Cast(target)
				return
		end
	end
	
	-- Rotation for multi target part 2
	if #player:GetNearbyEnemyUnits(10) > 1 then 
		if festeringOnTarget and festeringOnTarget:GetStacks() >= 3 and SPELL_SCOURGE_STRIKE:CanCast(target) then
			SPELL_SCOURGE_STRIKE:Cast(target)
			return
		end
	else
		if festeringOnTarget and festeringOnTarget:GetStacks() >= 1 and SPELL_SCOURGE_STRIKE:CanCast(target) then
			SPELL_SCOURGE_STRIKE:Cast(target)
			return
		end
	end

	if SPELL_FESTERING_STRIKE:CanCast(target) then
		SPELL_FESTERING_STRIKE:Cast(target)
		return
	end
end

return Unholy
