local SPELL_CORRUPTION = Spell(172)
local SPELL_AGONY = Spell(980)
local SPELL_UNSTABLE_AFFLICTION = Spell(30108)
local SPELL_DRAIN_SOUL = Spell(198590)
local SPELL_LIFE_DRAIN = Spell(234153)
local SPELL_HEALTH_FUNNEL = Spell(755)
local SPELL_SEED_OF_CORRUPTION = Spell(27243)
local SPELL_PET_ATTACK = Spell(0)
local SPELL_PET_TAUNT = Spell(17735)
local SPELL_PET_CONSUMING_SHADOWS = Spell(3716)
local SPELL_SHADOWFURY = Spell(30283, 35)
local SPELL_SIPHON_LIFE = Spell(63106, 40)
local SPELL_SINGULARITY = Spell(205179, 40)
local SPELL_HAUNT = Spell(48181, 40)
local SPELL_SHADOWBOLT = Spell(232670, 40)
local SPELL_DARKGLARE = Spell(205180, 100)
local SPELL_DEATHBOLT = Spell(264106, 40)

local AURA_SIPHON_LIFE = 63106
local AURA_AGONY = 980
local AURA_CORRUPTION = 146739
local AURA_UNSTABLE_AFFLICTION = 233490

local DOTCAP = 6000
local BossCAP = 90000

local Affliction = {}

function Affliction.DoCombat(player, target)
	if SPELL_HEALTH_FUNNEL:CanCast(player) and player:GetPet() and player:GetPet():GetHealthPercent() < 40 and player:GetHealthPercent() > 70 then
		SPELL_HEALTH_FUNNEL:Cast(player)
		return
	end

	if SPELL_LIFE_DRAIN:CanCast(target) and player:GetHealthPercent() < 50 then
		SPELL_LIFE_DRAIN:Cast(target)
		return
	end

	if #player:GetNearbyEnemyUnits(39) > 1 then
		Affliction.AoERotation(player, target)
	else
		Affliction.SingleRotation(player, target)
	end
end

function Affliction.AoERotation(player, target)
	local function BestAoETarget(player, range, nearRange)
		local units = player:GetNearbyEnemyUnits(range)
		local bestUnit = nil
		local bestNum = 0
		for i = 1, #units do
			local nearUnits = units[i]:GetNearbyEnemyUnits(nearRange)
			if #nearUnits > bestNum then
				bestNum = #nearUnits
				bestUnit = units[i]
			end
		end
		return bestUnit
	end

	local bestUnit = BestAoETarget(player, 40, 15)
	local enemies = player:GetNearbyEnemyUnits(40) -- Get all nearby enemies.

	if bestUnit ~= nil and SPELL_SINGULARITY:CanCast(bestUnit) and bestUnit:InCombat() and #bestUnit:GetNearbyEnemyUnits(15) > 2  then
		SPELL_SINGULARITY:Cast(bestUnit)
		return
	end
	if bestUnit ~= nil and SPELL_SHADOWFURY:CanCast(bestUnit) and bestUnit:InCombat() and not bestUnit:IsStunned() and not bestUnit:IsMoving() and #bestUnit:GetNearbyEnemyUnits(8) > 2 then
		SPELL_SHADOWFURY:CastAoF(bestUnit)
		return
	end

	for i = 1, #enemies do
		local Agony = enemies[i]:GetAuraByPlayer(AURA_AGONY)
		local Corruption = enemies[i]:GetAuraByPlayer(AURA_CORRUPTION)
		local UnstableAffliction = enemies[i]:GetAuraByPlayer(AURA_UNSTABLE_AFFLICTION)
		local SeedOfCorruption = enemies[i]:GetAuraByPlayer(SPELL_SEED_OF_CORRUPTION:GetSpellId())
		local SiphonLife = enemies[i]:GetAuraByPlayer(AURA_SIPHON_LIFE)
		local Soc = #enemies[i]:GetNearbyEnemyUnits(10)

		if SPELL_SIPHON_LIFE:CanCast(enemies[i]) and enemies[i]:InCombat() and enemies[i]:GetHealth() > DOTCAP and (SiphonLife == nil or SiphonLife:GetTimeleft() < 4200) then
			SPELL_SIPHON_LIFE:Cast(enemies[i])
			return
		end

		if SPELL_AGONY:CanCast(enemies[i]) and enemies[i]:InCombat() and enemies[i]:GetHealth() > DOTCAP and (Agony == nil or Agony:GetTimeleft() < 5400) then
			SPELL_AGONY:Cast(enemies[i])
			return
		end

		if SPELL_CORRUPTION:CanCast(enemies[i]) and enemies[i]:InCombat() and enemies[i]:GetHealth() > DOTCAP and (Corruption == nil or Corruption:GetTimeleft() < 4200) then
			SPELL_CORRUPTION:Cast(enemies[i])
			return
		end

		if SPELL_UNSTABLE_AFFLICTION:CanCast(enemies[i]) and enemies[i]:InCombat() and UnstableAffliction == nil and enemies[i]:GetHealth() > DOTCAP then
			SPELL_UNSTABLE_AFFLICTION:Cast(enemies[i])
			return
		end
		
		if SPELL_SEED_OF_CORRUPTION:CanCast(enemies[i]) and enemies[i]:InCombat() and Soc > 4 and SeedOfCorruption == nil then
			SPELL_SEED_OF_CORRUPTION:Cast(enemies[i])
			return
		end

		
	end

	Affliction.SingleRotation(player, target)
end

function Affliction.SingleRotation(player, target)
	local Agony = target:GetAuraByPlayer(AURA_AGONY)
	local Corruption = target:GetAuraByPlayer(AURA_CORRUPTION)
	local SiphonLife = target:GetAuraByPlayer(AURA_SIPHON_LIFE)
	local UnstableAffliction = target:GetAuraByPlayer(AURA_UNSTABLE_AFFLICTION)
	local Dots = Affliction.DotCount(player)

	if SPELL_DARKGLARE:CanCast(target) and Dots >= 4 and target:GetHealth() > BossCAP then
		SPELL_DARKGLARE:Cast(target)
		return
	end

	if SPELL_HAUNT:CanCast(target) and target:GetHealth() > DOTCAP then
		SPELL_HAUNT:Cast(target)
		return
	end

	if SPELL_AGONY:CanCast(target) and (Agony == nil or Agony:GetTimeleft() < 5400) then
		SPELL_AGONY:Cast(target)
		return
	end

	if SPELL_SIPHON_LIFE:CanCast(target) and target:GetHealth() > DOTCAP and (SiphonLife == nil or SiphonLife:GetTimeleft() < 4500) then
		SPELL_SIPHON_LIFE:Cast(target)
		return
	end

	if SPELL_UNSTABLE_AFFLICTION:CanCast(target) and target:GetHealth() > DOTCAP then
		SPELL_UNSTABLE_AFFLICTION:Cast(target)
		return
	end

	if SPELL_CORRUPTION:CanCast(target) and (Corruption == nil or Corruption:GetTimeleft() < 4500) then
		SPELL_CORRUPTION:Cast(target)
		return
	end

	if SPELL_DEATHBOLT:CanCast(target) and Corruption ~=  nil and Agony ~= nil and UnstableAffliction ~= nil then
		SPELL_DEATHBOLT:Cast(target)
		return
	end	

	if SPELL_SHADOWBOLT:CanCast(target) then
		SPELL_SHADOWBOLT:Cast(target)
		return
	end

	if SPELL_DRAIN_SOUL:CanCast(target) then
		SPELL_DRAIN_SOUL:Cast(target)
		return
	end
end

function Affliction.DotCount(player)
	local GetEnemies = player:GetNearbyEnemyUnits(40) -- Gets all enemies.
	local Result = 0
	for i = 1, #GetEnemies do
		local Agony = GetEnemies[i]:GetAuraByPlayer(AURA_AGONY)
		local Corruption = GetEnemies[i]:GetAuraByPlayer(AURA_CORRUPTION)
		local SiphonLife = GetEnemies[i]:GetAuraByPlayer(AURA_SIPHON_LIFE)
		local UnstableAffliction = GetEnemies[i]:GetAuraByPlayer(AURA_UNSTABLE_AFFLICTION)

		if AGONY ~= nil then
			Result = Result + 1
		end
		if Corruption ~= nil then
			Result = Result + 1
		end
		if SiphonLife ~= nil then
			Result = Result + 1
		end
		if UnstableAffliction ~= nil then
			Result = Result + 1
		end
	end
return Result
end

return Affliction