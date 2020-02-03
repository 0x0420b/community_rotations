require('Common.Shared')

local assassination = require('Assassination')
local outlaw = require('Outlaw')
local subletly = require('Subtlety')

local AURA_DEADLY_POISON = 2823
local AURA_CRIPPLING_POISON = 3408
local SPELL_DEADLY_POISON = Spell(2823)
local SPELL_CRIPPLING_POISON = Spell(3408)

function Tick(event, player)
	local target = player:GetTarget()
	
	if (ShouldRogueBuff(player, target)) then 
		if player:GetSpecializationId() == 259 then
			if not player:HasAura(AURA_DEADLY_POISON) then 
				if SPELL_DEADLY_POISON:CanCast() then
					SPELL_DEADLY_POISON:Cast(player)
					return
				end
			end
			if not player:HasAura(AURA_CRIPPLING_POISON)  then
				if SPELL_CRIPPLING_POISON:CanCast() then
					SPELL_CRIPPLING_POISON:Cast(player)
					return
				end
			end
		end
	end

	if not ShouldAttack(player, target) then
		return
	end

	if player:GetSpecializationId() == 259 then
		assassination.DoCombat(player, target)
		return
	elseif player:GetSpecializationId() == 260 then
		outlaw.DoCombat(player, target)
		return
	elseif player:GetSpecializationId() == 261 then
		subletly.DoCombat(player, target)
		return
	end
end

function ShouldRogueBuff(player, target) 
    if player:IsMounted() or 
		player:InCombat() or 
        player:IsCasting() or
        player:IsChanneling() or
        player:HasTerrainSpellActive() then
        return false
    end

    return true
end

RegisterEvent(1, Tick)