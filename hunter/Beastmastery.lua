--Abilities
local SPELL_BARBED_SHOT = Spell(217200)
local SPELL_BARBED_SHOT2 = Spell(246851)
local SPELL_BARBED_SHOT3 = Spell(246152)
local SPELL_KILL_COMMAND = Spell(34026, 150)
local SPELL_BESTIAL_WRATH = Spell(19574, 150)
local SPELL_COBRA_SHOT = Spell(193455)
local SPELL_MULTI_SHOT = Spell(2643)
local SPELL_ASPECT_OF_THE_WILD = Spell(193530)
local SPELL_BOILING_BLOOD = Spell(20572)
local SPELL_SUMMON_PET1 = Spell(883)
--Talents
local SPELL_ANIMAL_COMPANION = 267116
local SPELL_DIRE_BEAST = Spell(120679)
local SPELL_CHIMAERA_SHOT = Spell(53209)
local SPELL_A_MUDER_OF_CROWS = Spell(131894)
local SPELL_BINDING_SHOT = Spell(109248)
local SPELL_BARRAGE = Spell(120360)
local SPELL_STAMPEDE = Spell(201430)
local SPELL_ASPECT_OF_THE_BEAST = 191384
local SPELL_SPITTING_COBRA = Spell(194407)

--Buffs
local AURA_BESTIAL_WRATH = 19574
local AURA_BARBED_SHOT = 217200
local AURA_BARBED_SHOT2 = 246851
local AURA_BARBED_SHOT3 = 246152
local AURA_BEAST_CLEAVE = 268877
local AURA_BEAST_FRENZY = 272790

local Beastmastery = {}

function Beastmastery.DoCombat(player, target)
	
	local pet = player:GetPet()

	if pet ~= nil and #pet:GetNearbyEnemyUnits(8) > 2 then
		Beastmastery.AoERotation(player, target)
	else
		Beastmastery.SingleRotation(player, target)
	end
end

function Beastmastery.AoERotation(player, target)
	local pet = player:GetPet()
	
	local beastcleave = player:GetAura(AURA_BEAST_CLEAVE)

	if player:GetAura(AURA_BEAST_CLEAVE) ~= nil and beastcleave:GetTimeleft() < 1000 and SPELL_MULTI_SHOT:CanCast(target) then
		SPELL_MULTI_SHOT:Cast(target)
		return
	end

	if player:GetAura(AURA_BEAST_CLEAVE) == nil and SPELL_MULTI_SHOT:CanCast(target) then
		SPELL_MULTI_SHOT:Cast(target)
	end

	Beastmastery.SingleRotation(player, target)
end

function Beastmastery.SingleRotation(player, target)
	local pet = player:GetPet()
	
	local barbed = false;
	
	local wrath = player:GetAura(AURA_BESTIAL_WRATH)

	if pet ~= nil and pet:GetAura(AURA_BEAST_FRENZY) == nil then
		barbed = true
	end

	if pet ~= nil then
	  local frenzy = pet:GetAura(AURA_BEAST_FRENZY)
		if pet ~= nil and pet:GetAura(AURA_BEAST_FRENZY) ~= nil and frenzy:GetTimeleft() < 1500 then
			barbed = true
		
		end
	end

	if SPELL_A_MUDER_OF_CROWS:CanCast(target) then
		SPELL_A_MUDER_OF_CROWS:Cast(target)
		return
	end	
	
	if SPELL_BARBED_SHOT:CanCast(target) and barbed == true then
		SPELL_BARBED_SHOT:Cast(target)
		barbed = false
	return
	
	end

	-- if player:HasAura(AURA_BESTIAL_WRATH) and wrath.Timeleft > 10000 and SPELL_ASPECT_OF_THE_WILD:CanCast(target) then
	--	SPELL_ASPECT_OF_THE_WILD:Cast(target)
	--	SPELL_BOILING_BLOOD:Cast(target)
	-- end

	if pet ~= nil and SPELL_BESTIAL_WRATH:CanCast(target) then
		SPELL_BESTIAL_WRATH:Cast(target)
		return
	end

	if pet ~= nil and SPELL_KILL_COMMAND:CanCast(target) then
		SPELL_KILL_COMMAND:Cast(target)
		return
	end

	if SPELL_CHIMAERA_SHOT:CanCast(target) then
		SPELL_CHIMAERA_SHOT:Cast(target)
		return
	end

	if SPELL_BARRAGE:CanCast(target) then
		SPELL_BARRAGE:Cast(target)
		return
	end

	if SPELL_DIRE_BEAST:CanCast(target) then
		SPELL_DIRE_BEAST:Cast(target)
		return
	end

	if SPELL_COBRA_SHOT:CanCast(target) then
		SPELL_COBRA_SHOT:Cast(target)
		return
	end
end

return Beastmastery