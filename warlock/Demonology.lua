local SPELL_DREADSTALKERS = Spell(104316)
local SPELL_HAND_OF_GULDAN = Spell(105174)
local SPELL_DEMONBOLT = Spell(264178)
local SPELL_SHADOW_BOLT = Spell(686)
local SPELL_PET_FELSTORM = Spell(89751)
local SPELL_LIFE_DRAIN = Spell(234153)
local SPELL_HEALTH_FUNNEL = Spell(755)
local SPELL_IMPLOSION = Spell(196277)
local SPELL_SOUL_STRIKE = Spell(264057, 50)
local SPELL_MORTAL_COIL = Spell(6789)
local SPELL_GRIMOIRE_FELGUARD = Spell(111898)
local SPELL_SHADOWFURY = Spell(30283, 35)
local SPELL_DEMONIC_TYRANT = Spell(265187, 40)

-- PET AND PET ABILITIES
local SPELL_FELGUARD = Spell(30146, 100)
local SPELL_VOIDWALKER = Spell(697, 100)
local SPELL_IMP = Spell(688, 100)
local SPELL_FELHUNTER = Spell(691, 100)
local SPELL_SUCCUBUS = Spell(712, 100)

local SPELL_PET_SPELL_LOCK = Spell(119910, 40) -- Counterspell 6 sec
local SPELL_PET_AXE_TOSS = Spell(89766, 100) -- Stun target 4 sec
local SPELL_PET_SEDUCTION = Spell(119909, 40) -- Charm 30 sec
local SPELL_PET_SINGE_MAGIC = Spell(119905, 40) -- Dispell ally magic.
-- PET AND PET ABILITIES

local AURA_DEMONIC_CORE = 264173 -- Instant Demonbolt
local AURA_DEMONIC_CALLING = 205146 -- Instant Wildstalkers 1 shard

local IMPID = 55659
local DREADSTALKERID = 98035
local FELGUARDID = 17252

local Demonology = {}

function Demonology.DoCombat(player, target)
	-- PLANNED: Healthstone, Pet utilities, axe throw, seduction, interrupt, purge. Auto Soulstone usage? CR tank or healer.
	-- local tankexists = Demonology.HasTank(player) -- Only utilized in case we want to automate pets, eg summon voidwalker if no tank.
	local currentpet = player:GetPet()
	local petexists = currentpet ~= nil
	local petchoice = 0 -- Will become GUI Option in the future :) (0 = Felguard, 1 = Voidwalker, 2 = Imp, 3 = Succubus, 4 = Felhunter)
	local kick = false -- False by default since we use Pet abilities to interrupt and pet abilities are buggy.

	if petexists and SPELL_HEALTH_FUNNEL:CanCast(player) and currentpet:GetHealthPercent() < 40 and player:GetHealthPercent() > 70 and not player:IsMoving() then
		SPELL_HEALTH_FUNNEL:Cast(player)
		return
	end

	if SPELL_MORTAL_COIL:CanCast(target) and player:GetHealthPercent() < 70 then
		SPELL_MORTAL_COIL:Cast(target)
		return
	end

	if SPELL_LIFE_DRAIN:CanCast(target) and player:GetHealthPercent() < 50 and not player:IsMoving() then
		SPELL_LIFE_DRAIN:Cast(target)
		return
	end

		-- Will make a function for this in the future? 
			if not petexists or currentpet:GetHealthPercent() == 0 then
				if petchoice == 0 and SPELL_FELGUARD:CanCast(player) then
					SPELL_FELGUARD:Cast(player)
					return
				end
				if petchoice == 1 and SPELL_VOIDWALKER:CanCast(player) then
					SPELL_VOIDWALKER:Cast(player)
					return
				end
				if petchoice == 2 and SPELL_IMP:CanCast(player) then
					SPELL_IMP:Cast(player)
					return
				end
				if petchoice == 3 and SPELL_SUCCUBUS:CanCast(player) then
					SPELL_SUCCUBUS:Cast(player)
					return
				end
				if petchoice == 4 and SPELL_FELHUNTER:CanCast(player) then
					SPELL_FELHUNTER:Cast(player)
					return
				end
			end
			-- Function ETA: 2019.

	if kick then
		local units = player:GetNearbyEnemyUnits(30)
		for i = 1, #units do
			if units[i]:InCombat() and Demonology.ShouldInterrupt(units[i]) then
				if SPELL_PET_AXE_TOSS:CanCast(units[i]) then
					SPELL_PET_AXE_TOSS:Cast(units[i])
					return
				end
				if SPELL_PET_SEDUCTION:CanCast(units[i]) then
					SPELL_PET_SEDUCTION:Cast(units[i])
					return
				end
				if SPELL_PET_SPELL_LOCK:CanCast(units[i]) then
					SPELL_PET_SPELL_LOCK:Cast(units[i])
					return
				end
			end
		end
	end

	if #player:GetNearbyEnemyUnits(30) > 1 then
		Demonology.AoERotation(player, target)
	else
		Demonology.SingleRotation(player, target)
	end
end

function Demonology.AoERotation(player, target)

	-- Don't know where to put this? 
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
	-- Don't know where to put this? 
	local enemies = player:GetNearbyEnemyUnits(40) -- Get all nearby enemies.
	local GetImps = player:GetNearbyFriendlyUnits(20) -- Get imps
	local pet = player:GetPet() 
	local shard = player:GetSoulShards()
	local ImpCount = 0
	local bestUnit = BestAoETarget(player, 40, 12)

	--Draw:SetText('Debug', petcount)
	
		-- Gotta IMP em all.
		for i = 1, #GetImps do
			if GetImps[i]:GetEntry() == IMPID then
				ImpCount = ImpCount + 1
			end
		end
		-- Gotta IMP em all.

		-- Using BestAoETarget by Ian to reach top deeps.
		if bestUnit ~= nil and SPELL_DREADSTALKERS:CanCast(bestUnit) and bestUnit:InCombat() then
			SPELL_DREADSTALKERS:Cast(bestUnit)
			return
		end

		if bestUnit ~= nil and SPELL_HAND_OF_GULDAN:CanCast(bestUnit) and bestUnit:InCombat() and player:GetSoulShards() > 2 and not player:IsMoving() then
			SPELL_HAND_OF_GULDAN:Cast(bestUnit)
			return
		end

		if bestUnit ~= nil and SPELL_IMPLOSION:CanCast(bestUnit) and bestUnit:InCombat() and ImpCount > 2 and #bestUnit:GetNearbyEnemyUnits(8) > 2 then
			SPELL_IMPLOSION:Cast(bestUnit)
			return
		end

		if bestUnit ~= nil and SPELL_SHADOWFURY:CanCast(bestUnit) and bestUnit:InCombat() and not bestUnit:IsStunned() and not bestUnit:IsMoving() and #bestUnit:GetNearbyEnemyUnits(8) > 2 and not player:IsMoving() then
			SPELL_SHADOWFURY:CastAoF(bestUnit:GetPosition())
			return
		end
		-- Using BestAoETarget by Ian to reach top deeps.

	Demonology.SingleRotation(player, target)
end

function Demonology.SingleRotation(player, target)
	local shard = player:GetSoulShards()
	local core = player:HasAura(AURA_DEMONIC_CORE)
	local calling = player:HasAura(AURA_DEMONIC_CALLING)

	if SPELL_DREADSTALKERS:CanCast(target) then
		SPELL_DREADSTALKERS:Cast(target)
		return
	end

	if SPELL_SOUL_STRIKE:CanCast(target) and shard < 5 then
		SPELL_SOUL_STRIKE:Cast(target)
		return
	end

	if SPELL_DEMONIC_TYRANT:CanCast(target) and Demonology.ShouldTyrant(player, target) and not player:IsMoving() then
		SPELL_DEMONIC_TYRANT:Cast(target)
		return
	end

	if SPELL_GRIMOIRE_FELGUARD:CanCast(target) then
		SPELL_GRIMOIRE_FELGUARD:Cast(target)
		return
	end

	if SPELL_HAND_OF_GULDAN:CanCast(target) and player:GetSoulShards() > 2 and not player:IsMoving() then
		SPELL_HAND_OF_GULDAN:Cast(target)
		return
	end

	if SPELL_DEMONBOLT:CanCast(target) and shard < 4 and core == true then
		SPELL_DEMONBOLT:Cast(target)
		return
	end

	if SPELL_SHADOW_BOLT:CanCast(target) and shard < 4 and not player:IsMoving() then
		SPELL_SHADOW_BOLT:Cast(target)
		return
	end

end

function Demonology.ShouldTyrant(player, target)
	--local Draw = TextHook.Instance() -- DEBUGGING
	--Draw:AddText('Debug', Vec2(200, 200)) -- DEBUGGING
	local optimalhealth = player:GetHealthMax() * 5 -- Health required to use Tyrant, currently five times player max health.
	local GetPets = player:GetNearbyFriendlyUnits(40) -- Get Pets
	local petamount = 0
	local stalkercount = 0
	local felguardcount = 0
	
	for i = 1, #GetPets do
		if GetPets[i]:GetEntry() == IMPID or GetPets[i]:GetEntry() == FELGUARDID or GetPets[i]:GetEntry() == DREADSTALKERID then
			petamount = petamount + 1
		end
		if GetPets[i]:GetEntry() == DREADSTALKERID then
			stalkercount = stalkercount + 1 -- 0 + 1 = 1 quick maffs.
		end
		if GetPets[i]:GetEntry() == FELGUARDID then
			felguardcount = felguardcount + 1
		end

	end
	if (stalkercount > 1 or felguardcount > 1) and petamount >= 8 and target:GetHealth() >= optimalhealth then
		return true
	else
		return false
	end
end


function Demonology.HasTank(player)
	local players = player:GetNearbyFriendlyPlayers(100)
	for i = 1, #players do
		if players[i]:GroupRole() == 1 then -- tank
			return true
		end
	end
	return false
end


function Demonology.ShouldInterrupt(target)
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

return Demonology