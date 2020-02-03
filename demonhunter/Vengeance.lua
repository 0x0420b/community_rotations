
-- Rotation by Neer

local SPELL_SIGIL_OF_FLAME = Spell(204596, 30)
local SPELL_INFERNAL_STRIKE = Spell(189110, 30)
local SPELL_FRACTURE = Spell(263642)
local SPELL_SPIRIT_BOMB = Spell(247454, 40)
local SPELL_SOUL_CLEAVE = Spell(228477)
local SPELL_IMMOLATION_AURA = Spell(178740, 10) -- Offsensive 10 yards
local SPELL_DISRUPT = Spell(183752, 10)
local SPELL_FIERY_BRAND = Spell(204021, 30)
local SPELL_THROW_GLAIVE = Spell(204157, 30)
local SPELL_DEMON_SPIKES = Spell(203720, 10) -- Defensive 10 yards
local SPELL_CONSUME_MAGIC = Spell(278326, 30)
local SPELL_SIGIL_OF_SILENCE = Spell(202137, 30)
local SPELL_SIGIL_OF_MISERY = Spell(207684, 30)
local SPELL_METAMORPHOSIS = Spell(187827, 10)
local SPELL_IMPRISON = Spell(217832, 20)

local Vengeance = {}

function Vengeance.DoCombat(player, target)
     Vengeance.DoRotation(player, target)
end



function Vengeance.DoRotation(player, target)
	local units = player:GetNearbyEnemyUnits(30)

    if interruptReady() then
        for i = 1, #units do
            if units[i]:InCombat() and doInterrupt(units[i]) then
                if SPELL_IMPRISON:CanCast(units[i]) then
                    SPELL_IMPRISON:Cast(units[i])
                elseif SPELL_DISRUPT:CanCast(units[i]) then
                    SPELL_DISRUPT:Cast(units[i])
                elseif SPELL_SIGIL_OF_MISERY:CanCast(units[i]) then
                    SPELL_SIGIL_OF_MISERY:CastAoF(units[i]:GetPosition())
                elseif SPELL_SIGIL_OF_SILENCE:CanCast(units[i]) then
                    SPELL_SIGIL_OF_SILENCE:CastAoF(units[i]:GetPosition())
                end
            end
        end
    end

    if SPELL_CONSUME_MAGIC:IsReady() then
        for i = 1, #units do
            if #units[i]:GetAuras(2,false,2) > 0 then
                SPELL_CONSUME_MAGIC:Cast(units[i])
            end
        end
    end
    

    if SPELL_METAMORPHOSIS:CanCast(target) and player:GetHealthPercent() < 25 then
        --SPELL_METAMORPHOSIS:CastAoF(player:GetPosition())
        SPELL_METAMORPHOSIS:Cast(player)
        return
    end

    -- Demon spikes 1st charge at 80% hp
    if SPELL_DEMON_SPIKES:CanCast(target) and SPELL_DEMON_SPIKES:GetCharges() > 1 and player:GetHealthPercent() < 80 then 
        SPELL_DEMON_SPIKES:Cast(player)
        return
    end

    -- Demon spikes 2nd charge at 50% hp
    if SPELL_DEMON_SPIKES:CanCast(target) and SPELL_DEMON_SPIKES:GetCharges() == 1 and player:GetHealthPercent() < 50 then 
        SPELL_DEMON_SPIKES:Cast(player)
        return
    end

    if SPELL_SPIRIT_BOMB:CanCast(target) and getFragments(player) > 3 and player:GetPain() >= 30 then
        SPELL_SPIRIT_BOMB:Cast(player)
        return
    end

    if SPELL_SOUL_CLEAVE:CanCast(target) and player:GetPain() > 30 and getFragments(player) == 0 then
        SPELL_SOUL_CLEAVE:Cast(target)
        return
    end

    if SPELL_SOUL_CLEAVE:CanCast(target) and player:GetPain() > 30 and player:GetHealthPercent() < 50 then
        SPELL_SOUL_CLEAVE:Cast(target)
        return
    end

    if SPELL_IMMOLATION_AURA:CanCast(target) and player:GetDistance(target) < 8 then
        SPELL_IMMOLATION_AURA:Cast(player)
        return
    end

    if SPELL_FIERY_BRAND:CanCast(target) and player:GetHealthPercent() < 90 then
        SPELL_FIERY_BRAND:Cast(target)
        return
    end

    if SPELL_SIGIL_OF_FLAME:CanCast(target) and not target:IsMoving() then
        SPELL_SIGIL_OF_FLAME:CastAoF(target:GetPosition())
        return
    end

    if (SPELL_FRACTURE:CanCast(target) and getFragments(player) <= 4 and SPELL_FRACTURE:GetCharges() > 0) or (SPELL_FRACTURE:CanCast(target) and player:GetPain() < 30 and SPELL_FRACTURE:GetCharges() > 0) then
        SPELL_FRACTURE:Cast(target)
        return
    end

    if not player:IsRooted() and SPELL_INFERNAL_STRIKE:CanCast(target) and player:GetDistance(target) < 6 and not player:IsMoving() then
        SPELL_INFERNAL_STRIKE:CastAoF(player:GetPosition())
        return
    end

    if SPELL_SOUL_CLEAVE:CanCast(target) and player:GetPain() > 30 and SPELL_FRACTURE:GetCharges() == 0 and getFragments(player) < 3 then
        SPELL_SOUL_CLEAVE:Cast(target)
        return
    end

    if SPELL_SOUL_CLEAVE:CanCast(target) and player:GetPain() == 100 and getFragments(player) < 4 then
        SPELL_SOUL_CLEAVE:Cast(target)
        return
    end

    if SPELL_THROW_GLAIVE:CanCast(target) and SPELL_FRACTURE:GetCharges() == 0 and getFragments(player) < 3 then
        SPELL_THROW_GLAIVE:Cast(target)
        return
    end
end

function interruptReady()
    if SPELL_DISRUPT:IsReady() or SPELL_SIGIL_OF_MISERY:IsReady() or SPELL_SIGIL_OF_SILENCE:IsReady() or SPELL_IMPRISON:IsReady() then
        return true
    end
    return false
end

function getFragments(player)
    local aura = player:GetAura(203981)
    local fragment = 0

    if aura ~= nil then
        fragment = aura:GetStacks()
    end
    return fragment
end

function doInterrupt(unit)
	local toInterrupt = math.random(400, 700)
	if unit:IsCasting() or unit:IsChanneling() then
	  local unitSpell = unit:GetCurrentSpell()
	  if unitSpell ~= nil and unitSpell:IsInterruptible() and unitSpell:GetTimeleft() < toInterrupt then
		return true
	  end
	end
	return false
end

return Vengeance