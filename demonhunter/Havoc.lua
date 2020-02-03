
local SPELL_EYE_BEAM = Spell(198013, 20) -- Offsensive 20 yards
local SPELL_DISRUPT = Spell(183752, 10)
local SPELL_DEMONS_BITE = Spell(162243, 8)
local SPELL_DEATH_SWEEP = Spell(210152, 8)
local SPELL_ANNIHILATION = Spell(201427, 8)
local SPELL_BLADE_DANCE = Spell(188499, 8)
local SPELL_CHAOS_STRIKE = Spell(162794, 8)
local SPELL_IMMOLATION_AURA = Spell(258920, 8)
local SPELL_THROW_GLAIVE = Spell(185123, 20)
local SPELL_CHAOS_NOVA = Spell(179057)
local SPELL_IMPRISON = Spell(217832, 20)
local SPELL_CONSUME_MAGIC = Spell(278326)

local AURA_META = 162264

local Havoc = {}

function Havoc.DoCombat(player, target)

	if interruptReady() then
		local units = player:GetNearbyEnemyUnits(20)
		for i = 1, #units do
			if units[i]:InCombat() and doInterrupt(units[i]) then
					if SPELL_IMPRISON:CanCast(units[i]) and not SPELL_DISRUPT:IsReady() then
							SPELL_IMPRISON:Cast(units[i])
					elseif SPELL_DISRUPT:CanCast(units[i]) then
							SPELL_DISRUPT:Cast(units[i])
					end
			end		
		end
	end

	if SPELL_CONSUME_MAGIC:IsReady() then
		local units = player:GetNearbyEnemyUnits(30)
        for i = 1, #units do
            if #units[i]:GetAuras(2,false,2) > 0 then
                SPELL_CONSUME_MAGIC:Cast(units[i])
            end
        end
    end
	
		-- INTERRUPTS
	
		if #player:GetNearbyEnemyUnits(10) > 1 and SPELL_CHAOS_NOVA:CanCast(player) and not player:IsMoving() and not target:IsStunned() then
			SPELL_CHAOS_NOVA:Cast(player)
			return
		end
	
		if SPELL_BLADE_DANCE:CanCast(target) and player:GetDistance(target) < 8 then
			SPELL_BLADE_DANCE:Cast(target)
			return
		end
	
		if SPELL_IMMOLATION_AURA:CanCast(player) and player:GetFury() < 40 then
			SPELL_IMMOLATION_AURA:Cast(player)
			return
		end
	
		if SPELL_DEATH_SWEEP:CanCast(player) and player:GetDistance(target) < 8 then
			SPELL_DEATH_SWEEP:Cast(player)
			return
		end

		if SPELL_EYE_BEAM:CanCast(target) and not player:IsMoving() then
			SPELL_EYE_BEAM:Cast(target)
			return
		end	

		if SPELL_ANNIHILATION:CanCast(target) then
			SPELL_ANNIHILATION:Cast(target)
			return
		end

		if SPELL_CHAOS_STRIKE:CanCast(target) then
			SPELL_CHAOS_STRIKE:Cast(target)
			return
		end

		if SPELL_THROW_GLAIVE:CanCast(target) and #target:GetNearbyEnemyUnits(10) > 1 and not player:HasAura(AURA_META) and player:GetFury() < 15 then
			SPELL_THROW_GLAIVE:Cast(target)
			return
		end

		if SPELL_DEMONS_BITE:CanCast(target) then
			SPELL_DEMONS_BITE:Cast(target)
			return
		end
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

function interruptReady()
	if SPELL_DISRUPT:IsReady() or SPELL_IMPRISON:IsReady() then
			return true
	end
	return false
end

return Havoc