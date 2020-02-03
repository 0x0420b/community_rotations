--Abilites
local SPELL_CONSECRATION = Spell(26573, 10)
local SPELL_JUDGMENT = Spell(275779)
local SPELL_AVENGER_SHIELD = Spell(31935)
local SPELL_HAMMER_OF_THE_RIGHTEOUS = Spell(53595)
local SPELL_SHIELD_OF_THE_RIGHTEOUS = Spell(53600)
local SPELL_LIGHT_OF_THE_PROTECTOR = Spell(184092)
local SPELL_LAY_ON_HANDS = Spell(633)
local SPELL_ARDENT_DEFENDER = Spell(31850)

local SPELL_BLESSING_OF_FREEDOM = Spell(1044)
local SPELL_BLESSING_OF_SACRIFICE = Spell(6940)
local SPELL_REBUKE = Spell(96231, 7)
local SPELL_HAND_OF_RECKONING = Spell(62124)

--Talents
local SPELL_BLESSED_HAMMER = Spell(204019, 10)
local SPELL_BLESSING_OF_SPELLWARDING = Spell(204018)

--Buffs
local AURA_SHIELD_OF_THE_RIGHTEOUS = 132403
local AURA_CONSECRATION = 188370


local Protection = {}

function Protection.DoCombat(player, target)
	-- Check if we have Avengers shield or rebuke ready before doing interrupts.
	if interruptReady() then 
		local units = player:GetNearbyEnemyUnits(30)
		for i = 1, #units do
			if units[i]:InCombat() and doInterrupt(units[i], false) then
				if SPELL_REBUKE:CanCast(units[i]) then
					SPELL_REBUKE:Cast(units[i])
				elseif SPELL_AVENGER_SHIELD:CanCast(units[i]) then
					SPELL_AVENGER_SHIELD:Cast(units[i])
				end
			end
		end
	end

    -- If we have taunt then taunt a target that has a teammate as target.
    if player:InCombat() and SPELL_HAND_OF_RECKONING:IsReady() then
        local units = player:GetNearbyEnemyUnits(30)
        for i = 1, #units do
         -- The unit's target
            local unit_target = units[i]:GetTarget()

            if units[i]:InCombat() and unit_target and isTeammate(unit_target) and unit_target:GetGUID():GetLoWord() ~= player:GetGUID():GetLoWord() then
                SPELL_HAND_OF_RECKONING:Cast(units[i])
            end
        end
    end

	if player:GetHealthPercent() <= 8 and SPELL_ARDENT_DEFENDER:CanCast(player) and not SPELL_LAY_ON_HANDS:CanCast(player) then
		SPELL_ARDENT_DEFENDER:Cast(player)
		return
	end

	if player:GetHealthPercent() <= 10 and SPELL_LAY_ON_HANDS:CanCast(player) then
		SPELL_LAY_ON_HANDS:Cast(player)
		return
	end

	if player:GetHealthPercent() < 60 and SPELL_LIGHT_OF_THE_PROTECTOR:CanCast() then
		SPELL_LIGHT_OF_THE_PROTECTOR:Cast(player)
		return
	end

	if SPELL_JUDGMENT:CanCast(target) then
		SPELL_JUDGMENT:Cast(target)
		return
	end

	if not player:HasAura(AURA_CONSECRATION) and SPELL_CONSECRATION:CanCast() and player:GetDistance(target) < 6 then
		SPELL_CONSECRATION:Cast(player)
		return
	end
	
	if SPELL_AVENGER_SHIELD:CanCast(target) then
		SPELL_AVENGER_SHIELD:Cast(target)
		return
	end

	if SPELL_SHIELD_OF_THE_RIGHTEOUS:CanCast(target) and SPELL_SHIELD_OF_THE_RIGHTEOUS:GetCharges() > 1 and (player:GetHealthPercent() < 95 or #player:GetNearbyEnemyUnits(10) > 3) then
		SPELL_SHIELD_OF_THE_RIGHTEOUS:Cast(target)
		return
	end

	if SPELL_HAMMER_OF_THE_RIGHTEOUS:CanCast(target) then
		SPELL_HAMMER_OF_THE_RIGHTEOUS:Cast(target)
		return
	end
end


function doInterrupt(unit, instant)
	local toInterrupt = math.random(1500, 2000)
	if unit:IsCasting() or unit:IsChanneling() then
	  local unitSpell = unit:GetCurrentSpell()
	  if unitSpell ~= nil and unitSpell:IsInterruptible() and (unitSpell:GetTimeleft() < toInterrupt or instant) then
		return true
	  end
	end
	return false
end

function interruptReady()
	if SPELL_AVENGER_SHIELD:IsReady() or SPELL_REBUKE:IsReady() then
		return true
	else
		return false
	end
end

function isTeammate(unit)
	if unit:InParty() or unit:InRaid() then
		return true
	else 
		return false
	end
end



return Protection