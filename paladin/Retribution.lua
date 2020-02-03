
--Abilites
local SPELL_CRUSADER_STRIKE = Spell(35395)
local SPELL_TEMPLARS_VERDICT = Spell(85256)
local SPELL_JUDGMENT = Spell(20271)
local SPELL_BLADE_OF_JUSTICE = Spell(184575)
local SPELL_DIVINE_STORM = Spell(53385, 12)
local SPELL_FLASH_OF_LIGHT = Spell(19750)
local SPELL_SHIELD_OF_VENGEANCE = Spell(184662)
local SPELL_DIVINE_SHIELD = Spell(642)
local SPELL_LAY_ON_HANDS = Spell(633)
local SPELL_BLESSING_OF_PROTECTION = Spell(1022)
local SPELL_AVENGING_WRATH = Spell(31884)
local SPELL_BLESSING_OF_FREEDOM = Spell(1044)
local SPELL_HAMMER_OF_JUSTICE = Spell(853)
local SPELL_HAND_OF_HINDRANCE = Spell(183218)
local SPELL_REBUKE = Spell(96231)
local SPELL_CLEANSE_TOXINS = Spell(213644)
local SPELL_DIVINE_STEED = Spell(190784)
local SPELL_GREATER_BLESSING_OF_KINGS = Spell(203538)
local SPELL_GREATER_BLESSING_OF_WISDOM = Spell(203539)
local SPELL_REDEMPTION = Spell(7328)
local SPELL_BLINDING_LIGHT = Spell(115750)
local SPELL_CONSECRATION = Spell(205228)
local SPELL_EYE_FOR_AN_EYE = Spell(205191)
local SPELL_CRUSADE = Spell(231895)
local SPELL_DIVINE_PURPOSE = Spell(223817)
local SPELL_FIRES_OF_JUSTICE = Spell(203316)

--Talents
local SPELL_EXECUTION_SENTENCE = Spell(267798)
local SPELL_HAMMER_OF_WRATH = Spell(24275)
local SPELL_CONSECRATION = Spell(205228)
local SPELL_WAKE_OF_ASHES = Spell(255937)
local SPELL_WORD_OF_GLORY = Spell(210191)
local SPELL_INQUISITUION = Spell(84963)
local SPELL_DIVINE_PURPOSE = Spell(223817)
local SPELL_REPENTANCE = Spell(20066)

--Buffs
local AURA_DIVINE_PURPOSE_BUFF = 223819
local AURA_FIRES_OF_JUSTICE_BUFF = 209785
local AURA_INQUISITUION = 84963
local AURA_BLADE_OF_WRATH = 231832
local AURA_AVENGING_WRATH = 31884

local Retribution = {}

function Retribution.DoCombat(player, target)
	if #player:GetNearbyEnemyUnits(9) > 2 then
		Retribution.AoERotation(player, target)
	else
		Retribution.SingleRotation(player, target)
	end
end

function Retribution.AoERotation(player, target)
	if player:GetHolyPower() >= 3 and SPELL_DIVINE_STORM:CanCast(target) then
		SPELL_DIVINE_STORM:Cast(player)
		return
	end

	if player:HasAura(AURA_DIVINE_PURPOSE_BUFF) and SPELL_DIVINE_STORM:CanCast(target) then
		SPELL_DIVINE_STORM:Cast(target)
		return
	end
	
	if SPELL_CONSECRATION:CanCast() then
		SPELL_CONSECRATION:Cast(player)
		return
	end

	Retribution.SingleRotation(player, target)
end

function Retribution.SingleRotation(player, target)

	if player:GetHolyPower() <= 1 and SPELL_WAKE_OF_ASHES:CanCast() and player:GetDistance(target) <= 11 then
		SPELL_WAKE_OF_ASHES:Cast(target)
		return
	end
	
	--REAPPLY WHEN LESS THAN 4 SECONDS LEFT
	local InquisituionAura = player:GetAuraByPlayer(84963)
    if SPELL_INQUISITUION:CanCast() and player:GetHolyPower() >= 3 and (InquisituionAura == nil or InquisituionAura:GetTimeleft() < 4000) then
        SPELL_INQUISITUION:Cast(player)
        return
    end
	
	--POISON Cleanse "NEED ATTENTION"
	--local friendlyUnits = player:NearbyFriendlyUnits(40)
	--require('Common.Dispell')
   -- for i = 1, #friendlyUnits do
     --   local auras = friendlyUnits[i].Auras
    --    for k = 1, #auras do
    --        if ShouldDispell(unit) and auras[k].Type == SpellType.Poison and SPELL_CLEANSE_TOXINS:CanCast(friendlUnits[i]) then
     --           SPELL_CLEANSE_TOXINS:Cast(friendlyUnits[i])
    --        end
    --    end
    --end
	
	--DISEASE Cleanse "NEED ATTENTION"
	--local friendlyUnits = player:NearbyFriendlyUnits(40)
	--require('Common.Dispell')
    --for i = 1, #friendlyUnits do
    --    local auras = friendlyUnits[i].Auras
     --   for k = 1, #auras do
     --       if ShouldDispell(unit) and auras[k].Type == SpellType.Disease and SPELL_CLEANSE_TOXINS:CanCast(friendlUnits[i]) then
     --           SPELL_CLEANSE_TOXINS:Cast(friendlyUnits[i])
      --      end
     --   end
    --end
	
	if player:GetHolyPower() >= 3 and player:GetHealthPercent() < 30 and SPELL_WORD_OF_GLORY:CanCast() then 
		SPELL_WORD_OF_GLORY:Cast(player)
		return
	end
	
	if player:GetHealthPercent() < 10 and SPELL_DIVINE_SHIELD:CanCast() then
		SPELL_DIVINE_SHIELD:Cast(player)
		return
	end
	
	if player:GetHealthPercent() < 70 and SPELL_EYE_FOR_AN_EYE:CanCast() then
		SPELL_EYE_FOR_AN_EYE:Cast(player)
		return
	end
	
	if player:GetHealthPercent() < 60 and SPELL_SHIELD_OF_VENGEANCE:CanCast() then
		SPELL_SHIELD_OF_VENGEANCE:Cast(player)
		return
	end

	if player:HasAura(AURA_DIVINE_PURPOSE_BUFF) and SPELL_TEMPLARS_VERDICT:CanCast(target) then
		SPELL_TEMPLARS_VERDICT:Cast(target)
		return
	end

	if player:GetHolyPower() <= 3 and SPELL_BLADE_OF_JUSTICE:CanCast(target) and player:GetDistance(target) <= 12 then
		SPELL_BLADE_OF_JUSTICE:Cast(target)
		return
	end
	
	if player:HasAura(AURA_BLADE_OF_WRATH) and player:GetHolyPower() <= 3 and SPELL_BLADE_OF_JUSTICE:CanCast(target) then
		SPELL_BLADE_OF_JUSTICE:Cast(target)
		return
	end

	if player:GetHolyPower() >= 3 and SPELL_EXECUTION_SENTENCE:CanCast(target) and player:GetDistance(target) <= 20 then
		SPELL_EXECUTION_SENTENCE:Cast(target)
		return
	end

	if player:GetHolyPower() >= 4 and SPELL_TEMPLARS_VERDICT:CanCast(target) then
		SPELL_TEMPLARS_VERDICT:Cast(target)
		return
	end

	if player:GetHolyPower() <= 4 and SPELL_JUDGMENT:CanCast(target) and player:GetDistance(target) <= 30 then
		SPELL_JUDGMENT:Cast(target)
		return
	end
	
	if player:GetHolyPower() <= 4 and SPELL_HAMMER_OF_WRATH:CanCast(target) and (target:GetHealthPercent() < 20 or (player:HasAura(AURA_AVENGING_WRATH))) then
		SPELL_HAMMER_OF_WRATH:Cast(target)
		return
	end
	
	if SPELL_CONSECRATION:CanCast() then
		SPELL_CONSECRATION:Cast(player)
		return
	end

	if player:GetHolyPower() <= 4 and SPELL_CRUSADER_STRIKE:CanCast(target) then
		SPELL_CRUSADER_STRIKE:Cast(target)
		return
	end
end

return Retribution