-- TODO
-- Improve combustion Rotation
-- Implement Living bomb somewhere
-- Implement Dragons Breath
-- Rune of Power, Pyroclasm and Meteor

local SPELL_FIRE_BLAST = Spell(108853)
local SPELL_PHOENIX_FLAMES = Spell(257541)
local SPELL_PYROBLAST = Spell(11366)
local SPELL_SCORCH = Spell(2948)
local SPELL_FIREBALL = Spell(133)
local SPELL_FLAMESTRIKE = Spell(2120, 40)
local SPELL_METEOR = Spell(153561)
local SPELL_LIVING_BOMB = Spell(44457)

-- Self Casts
local SPELL_BLAZING_BARRIER = Spell(235313)
local SPELL_RUNE_OF_POWER = Spell(116011)
local SPELL_COMBUSTION = Spell(190319)

-- Buffs
local AURA_PYROCLASM = 269651
local AURA_HEATING_UP = 48107
local AURA_HOT_STREAK = 48108
local AURA_COMBUSTION = 190319

local Fire = {}

Fire.LastPyroblast = 0
Fire.LastFlameStrike = 0
Fire.LastFireBlast = 0
Fire.LastPhoenix = 0
Fire.LastROP = 0

function Fire.DoCombat(player, target)
	if #player:GetNearbyEnemyUnits(12) > 0 and SPELL_BLAZING_BARRIER:CanCast() then
		SPELL_BLAZING_BARRIER:Cast(player)
		return
	end

	Fire.Rotation(player, target)
end

function Fire.Rotation(player, target)
	if not player:IsMoving() and os.clock() - Fire.LastROP > 10 and SPELL_RUNE_OF_POWER:CanCast() and not SPELL_COMBUSTION:CanCast() and not player:HasAura(AURA_COMBUSTION) then
		SPELL_RUNE_OF_POWER:Cast(player)
		Fire.LastROP = os.clock()
		return
	end

	if SPELL_LIVING_BOMB:CanCast(target) then
		SPELL_LIVING_BOMB:Cast(target)
		return
	end

	if os.clock() - Fire.LastROP < 10 and SPELL_METEOR:CanCast(target) then
		SPELL_METEOR:Cast(target)
		return
	end

	if SPELL_COMBUSTION:CanCast() and player:HasAura(AURA_HEATING_UP) then
		SPELL_COMBUSTION:Cast(player)
		Fire.LastSpell = SPELL_COMBUSTION
		return
	end

	if player:HasAura(AURA_COMBUSTION) and (SPELL_PHOENIX_FLAMES:GetCharges() > 0 or SPELL_FIRE_BLAST:GetCharges() > 0) then
		Fire.CombustionRotation(player, target)
		return
	end

	if player:HasAura(AURA_HEATING_UP) and os.clock() - Fire.LastPhoenix > 1 and os.clock() - Fire.LastFireBlast > 1 then
		local phoenixCharges = SPELL_PHOENIX_FLAMES:GetCharges()
		local blastCharges = SPELL_FIRE_BLAST:GetCharges()

		if phoenixCharges == 3 and SPELL_PHOENIX_FLAMES:CanCast(target) then
			SPELL_PHOENIX_FLAMES:Cast(target)
			Fire.LastPhoenix = os.clock()
			return
		end
			
		if blastCharges == 2 and SPELL_FIRE_BLAST:CanCast(target) then
			SPELL_FIRE_BLAST:Cast(target)
			Fire.LastFireBlast = os.clock()
			return
		end
	end

	if  os.clock() - Fire.LastPyroblast > 1 and os.clock() - Fire.LastFlameStrike > 1 and player:HasAura(AURA_HOT_STREAK) then
		if #target:GetNearbyEnemyUnits(12) >= 2 and SPELL_FLAMESTRIKE:CanCast(target) then
			SPELL_FLAMESTRIKE:CastAoF(target)
			Fire.LastFlameStrike = os.clock()
			return
		elseif SPELL_PYROBLAST:CanCast(target) then
			SPELL_PYROBLAST:Cast(target)
			Fire.LastPyroblast = os.clock()
			return
		end
	end

	if player:IsMoving() and SPELL_SCORCH:CanCast(target) then
		SPELL_SCORCH:Cast(target)
		return
	elseif not player:IsMoving() and SPELL_FIREBALL:CanCast(target) then
		SPELL_FIREBALL:Cast(target)
		return
	end
end

function Fire.CombustionRotation(player, target)
	if player:HasAura(AURA_HEATING_UP) and os.clock() - Fire.LastPhoenix > 1 and os.clock() - Fire.LastFireBlast > 1 then
		local phoenixCharges = SPELL_PHOENIX_FLAMES:GetCharges()
		local blastCharges = SPELL_FIRE_BLAST:GetCharges()

		if phoenixCharges > 0 and SPELL_PHOENIX_FLAMES:CanCast(target) then
			SPELL_PHOENIX_FLAMES:Cast(target)
			Fire.LastPhoenix = os.clock()
			return
		end

		if blastCharges > 0 and SPELL_FIRE_BLAST:CanCast(target) then
			SPELL_FIRE_BLAST:Cast(target)
			Fire.LastFireBlast = os.clock()
			return
		end
	end

	if  os.clock() - Fire.LastPyroblast > 1 and os.clock() - Fire.LastFlameStrike > 1 and player:HasAura(AURA_HOT_STREAK) and SPELL_PYROBLAST:CanCast(target) then
		SPELL_PYROBLAST:Cast(target)
		Fire.LastPyroblast = os.clock()
		return
	end
end

return Fire