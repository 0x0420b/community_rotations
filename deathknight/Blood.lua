-- By Neer
local SPELL_MARROWREND = Spell(195182)
local SPELL_DEATH_STRIKE = Spell(49998)
local SPELL_BLOODDRINKER = Spell(206931)
local SPELL_BLOOD_BOIL = Spell(50842, 10)
local SPELL_DEATH_AND_DECAY = Spell(43265, 30)
local SPELL_HEART_STRIKE = Spell(206930)
local SPELL_MIND_FREEZE = Spell(47528, 15)
local SPELL_BONESTORM = Spell(194844, 50)
local SPELL_DANCING_RUNE_WEAPON = Spell(49028, 30)

local AURA_DANCING_RUNE_WEAPON = 81256
local AURA_BONE_SHIELD = 195181
local AURA_BLOOD_SHIELD = 77535
local AURA_CRIMSON_SCOURGE = 81141
local AURA_BLOOD_PLAGUE = 55078
local Blood = {}

local interrupt = true

function Blood.DoCombat(player, target)
	if #player:GetNearbyEnemyUnits(12) > 1 then
		Blood.AoERotation(player, target)
	else
		Blood.SingleRotation(player, target)
	end
end

function Blood.AoERotation(player, target)
	Blood.SingleRotation(player, target)
end

function Blood.SingleRotation(player, target)
	local shieldbuff = player:GetAuraByPlayer(AURA_BONE_SHIELD)
	local shieldduration = 0
	local shieldstack = 0
	local hasCrimson = player:HasAura(AURA_CRIMSON_SCOURGE)
	local units = player:GetNearbyEnemyUnits(10)

	for i = 1, #units do
		if (units[i]):GetEntry() == 120651 and units[i]:GetHealthPercent() > 0 then
			if SPELL_DEATH_STRIKE:CanCast(units[i]) and player:GetRunicPowerPercent() > 45 then 
				SPELL_DEATH_STRIKE:Cast(units[i])
				return
			end
			if SPELL_HEART_STRIKE:CanCast(units[i]) and player:NumRunesReady() > 0 then
				SPELL_HEART_STRIKE:Cast(units[i])
				return
			end
		end
	end
	
	if shieldbuff ~= nil then
	shieldstack = shieldbuff:GetStacks()
	shieldduration = shieldbuff:GetTimeleft()
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

	if SPELL_MARROWREND:CanCast(target) and (shieldduration < 3000 or shieldstack < 7) then
		SPELL_MARROWREND:Cast(target)
		return
	end
	
	if SPELL_DEATH_STRIKE:CanCast(target) and (player:GetHealthPercent() < 80 or player:GetRunicPower() > 90) and (not SPELL_BONESTORM:IsReady() or #player:GetNearbyEnemyUnits(8) < 2) then
		SPELL_DEATH_STRIKE:Cast(target)
		return
	end

	if SPELL_BONESTORM:CanCast(target) and player:GetRunicPower() > 110 and #player:GetNearbyEnemyUnits(8) > 2 then
		SPELL_BONESTORM:Cast(player)
		return
	end

	if SPELL_DANCING_RUNE_WEAPON:CanCast(target) and not SPELL_BLOODDRINKER:IsReady() and player:GetHealthPercent() < 65 then
		SPELL_DANCING_RUNE_WEAPON:Cast(target)
		return
	end

	if SPELL_BLOODDRINKER:CanCast(target) then
		SPELL_BLOODDRINKER:Cast(target)
		return
	end

	if SPELL_BLOOD_BOIL:CanCast(target) and (SPELL_BLOOD_BOIL:GetCharges() == 2 or PlagueCheck(player)) then
		SPELL_BLOOD_BOIL:Cast(player)
		return
	end

	if (#target:GetNearbyEnemyUnits(12) > 1 or hasCrimson) and SPELL_DEATH_AND_DECAY:CanCast(target) and not target:IsMoving() then
		SPELL_DEATH_AND_DECAY:CastAoF(target)
		return
	end
	
	if SPELL_HEART_STRIKE:CanCast(target) and player:NumRunesReady() > 2 then
		SPELL_HEART_STRIKE:Cast(target)
		return
	end
end

function PlagueCheck(player)
	local enemies = player:GetNearbyEnemyUnits(10)
	for i = 1, #enemies do
		local plague = enemies[i]:GetAuraByPlayer(AURA_BLOOD_PLAGUE)
		if plague == nil then
			return true
		end
	end
	return false
end


function Blood.ShouldInterrupt(target)
	if target:IsCasting() or target:IsChanneling() then
    	local sprop = target:GetCurrentSpell()
    	if sprop ~= nil and sprop:IsInterruptible() then
			return true -- if interruptable
        end
    end
    return false
end

return Blood