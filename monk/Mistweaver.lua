-- New one by Neer
require('Common.Shared')

local SPELL_VIVIFY = Spell(116670)
local SPELL_RENEWING_MIST = Spell(115151)
local SPELL_ESSENCE_FONT = Spell(191837, 100)
local SPELL_TIGER_PALM = Spell(100780)
local SPELL_BLACKOUT_KICK = Spell(100784)
local SPELL_RISING_SUN_KICK = Spell(107428)
local SPELL_SPINNING_CRANE_KICK = Spell(101546)
local SPELL_FORTIFYING_BREW = Spell(243435, 100)
local SPELL_LIFE_COCOON = Spell(116849)
local SPELL_DETOX = Spell(115450)
local SPELL_ENEVELOPING_MIST = Spell(124682)
local SPELL_SOOTHING_MIST = Spell(115175)
local SPELL_JADE_SERPENT_STATUE = Spell(115313, 100)
local SPELL_HEALING_ELIXIR = Spell(122281, 100)
local SPELL_THUNDER_FOCUS_TEA = Spell(116680, 100)
local SPELL_REVIVAL = Spell(115310, 100)
local SPELL_INVOKE_CHIJI = Spell(198664)
local SPELL_BLOOD_FURY = Spell(33697)

local AURA_FOOD = 167152
local AURA_RENEWING_MIST = 119611
local AURA_ENVELOPING_MIST = 124682
local AURA_SOOTHING_MIST_STATUE = 198533
local AURA_SOOTHING_MIST_CHANNEL = 115175
local AURA_LIFE_ENVELOP = 197919
local AURA_LIFE_VIVIFY = 197916
local AURA_MONASTERY_TEACHINGS = 202090

local tempVal = 0 -- used to store values for lifecycles.
local Envelop = false
local STATUE_ID = 60849
local onlyDPS = false
local onlyHEAL = false

-- Global settings. (BOOLEANS (0 = FALSE, 2 = TRUE))
Settings = {
    doTFT = 2,
    doDPS = 2,
    LifeCycleRotation = 2,
    FortifyingBrew = 2,
    HealingElixir = 2,
    drawDebug = 0,
    SoothingPercent = 90,
    RenewPercent = 98,
    EnvelopPercent = 69,
    FixedEnvelop = 70, -- Always want envelop to boost heals. ((NO NEED FOR SETTING))
    VivifyPercent = 80,
    CocoonPercent = 25,
    AoePercent = 80,
    EssenceCount = 2,
    RevivalCount = 3,
    ChijiCount = 4,
    FortifyingBrewPercent = 70,
    HealingElixirPercent = 50
}

local Mistweaver = {}

function Mistweaver.HealingRotation(player)
    local jadestatue = CheckStatue(player)
    local findTank = GetTank(player)
    local toHeal = GetLowest(player)
    local HealthLevel = 0
    local multiHeal = MultiLow(player, Settings.AoePercent)
    local dispellCheck
    local renewTarget = getRenewTarget(player)

    if not toHeal then toHeal = player end

    HealthLevel = toHeal:GetHealthPercent()

    if Settings.LifeCycleRotation == 2 then
        if player:HasAura(AURA_LIFE_ENVELOP) and not Envelop then
            tempVal = Settings.EnvelopPercent
            Settings.EnvelopPercent = Settings.VivifyPercent
            Settings.VivifyPercent = tempVal
            Envelop = true
        elseif player:HasAura(AURA_LIFE_VIVIFY) and Envelop then
            tempVal = Settings.VivifyPercent
            Settings.VivifyPercent = Settings.EnvelopPercent
            Settings.EnvelopPercent = tempVal
            Envelop = false
        end
    end

    if SPELL_DETOX:IsReady() then 
        dispellCheck = findDispell(player)
    end

    if HealthLevel < Settings.CocoonPercent and toHeal:InCombat() and
        SPELL_LIFE_COCOON:CanCast(toHeal) then
        SPELL_LIFE_COCOON:Cast(toHeal)
        return
    end

    if multiHeal > Settings.ChijiCount and SPELL_INVOKE_CHIJI:CanCast() then
        SPELL_INVOKE_CHIJI:Cast(player)
        return
    end

    if multiHeal > Settings.RevivalCount and SPELL_REVIVAL:CanCast() then
        SPELL_REVIVAL:Cast(player)
        return
    end

    if multiHeal > Settings.EssenceCount and SPELL_ESSENCE_FONT:CanCast() and HealthLevel > 60 then
        SPELL_ESSENCE_FONT:Cast(player)
        return
    end

    if dispellCheck and SPELL_DETOX:CanCast(dispellCheck) and HealthLevel > 80 then
        SPELL_DETOX:Cast(dispellCheck)
        return
    end

    if HealthLevel < 65 and SPELL_BLOOD_FURY:CanCast() then
        SPELL_BLOOD_FURY:Cast(player)
        return
    end

    if Settings.FortifyingBrew == 2 and player:InCombat() and
        player:GetHealthPercent() < Settings.FortifyingBrewPercent and
        SPELL_FORTIFYING_BREW:CanCast() then
        SPELL_FORTIFYING_BREW:Cast(player)
        return
    end

    if Settings.HealingElixir == 2 and player:InCombat() and
        player:GetHealthPercent() < Settings.HealingElixirPercent and
        SPELL_HEALING_ELIXIR:CanCast() then
        SPELL_HEALING_ELIXIR:Cast(player)
        return
    end

    if Settings.doTFT == 2 and player:InCombat() and
        SPELL_THUNDER_FOCUS_TEA:CanCast() then
        SPELL_THUNDER_FOCUS_TEA:Cast(player)
        return
    end

    if renewTarget and (HealthLevel > 80 or player:IsMoving()) and SPELL_RENEWING_MIST:CanCast(renewTarget) and not renewTarget:HasAuraByPlayer(AURA_RENEWING_MIST) then
        SPELL_RENEWING_MIST:Cast(renewTarget)
        return
    end

    if (HealthLevel < Settings.EnvelopPercent or HealthLevel < Settings.VivifyPercent) and
        not toHeal:HasAuraByPlayer(AURA_SOOTHING_MIST_CHANNEL) and
        SPELL_SOOTHING_MIST:CanCast(toHeal) then
        SPELL_SOOTHING_MIST:Cast(toHeal)
        return
    end

    if findTank and findTank:InCombat() and
        not findTank:HasAura(AURA_SOOTHING_MIST_STATUE) and jadestatue and
        SPELL_SOOTHING_MIST:CanCast(findTank) and HealthLevel > 85 then
        SPELL_SOOTHING_MIST:Cast(findTank)
        return
    end

    if not findTank and toHeal:InCombat() and
        not toHeal:HasAura(AURA_SOOTHING_MIST_STATUE) and jadestatue and
        SPELL_SOOTHING_MIST:CanCast(toHeal) and HealthLevel > 85 then
        SPELL_SOOTHING_MIST:Cast(toHeal)
        return
    end

    if not toHeal:HasAuraByPlayer(AURA_SOOTHING_MIST_CHANNEL) and (HealthLevel < Settings.EnvelopPercent or HealthLevel < Settings.VivifyPercent) then
        return
    end
        

    if HealthLevel < Settings.FixedEnvelop and
        SPELL_ENEVELOPING_MIST:CanCast(toHeal) and
        not toHeal:HasAuraByPlayer(AURA_ENVELOPING_MIST) then
        SPELL_ENEVELOPING_MIST:Cast(toHeal)
        return
    end

    if HealthLevel < Settings.EnvelopPercent and
        SPELL_ENEVELOPING_MIST:CanCast(toHeal) and
        not toHeal:HasAuraByPlayer(AURA_ENVELOPING_MIST) then
        SPELL_ENEVELOPING_MIST:Cast(toHeal)
        return
    end

    if HealthLevel < Settings.VivifyPercent and SPELL_VIVIFY:CanCast(toHeal) then
        SPELL_VIVIFY:Cast(toHeal)
        return
    end
end

function Mistweaver.DamageRotation(player, target)
    local kickStacks = GetAuraStacks(player, AURA_MONASTERY_TEACHINGS)

    if #player:GetNearbyEnemyUnits(8) > 4 and SPELL_SPINNING_CRANE_KICK:CanCast() and GetCooldownLeft(SPELL_RISING_SUN_KICK) > 1 then
        SPELL_SPINNING_CRANE_KICK:Cast(target)
        return
    end

    if SPELL_RISING_SUN_KICK:CanCast(target) then
        SPELL_RISING_SUN_KICK:Cast(target)
        return
    end

    if GetCooldownLeft(SPELL_RISING_SUN_KICK) > 3.2 and kickStacks == 3 and SPELL_BLACKOUT_KICK:CanCast(target) then
        SPELL_BLACKOUT_KICK:Cast(target)
        return
    end

    if SPELL_TIGER_PALM:CanCast(target) and (GetCooldownLeft(SPELL_RISING_SUN_KICK) > 1.5 or kickStacks < 3) then
        SPELL_TIGER_PALM:Cast(target)
        return
    end
end

function Mistweaver.DoCombat(player, target)
    local sprop = player:GetCurrentSpell()
    if player:IsDead() or sprop and sprop == 191837 or -- LETS NOT CANCEL ESSENCE FONT
    player:IsMounted() or player:IsCasting() or player:HasTerrainSpellActive() or player:HasAura(AURA_FOOD) then
        return
    end

    -- Sheeeenanigaans
    if not onlyDPS then Mistweaver.HealingRotation(player) end

    -- Begin damage part.
    if not ShouldAttackSpecial(player, target) or Settings.doDPS ~= 2 then
        return
    end

    -- Mooore!
    if not onlyHEAL then Mistweaver.DamageRotation(player, target) end
end

function findDispell(player)
    local friendly = player:GetNearbyFriendlyPlayers(40)
    for i = 1, #friendly do
        local magicDebuff = friendly[i]:GetAuras(1, false, 2)[1]
        local diseaseDebuff = friendly[i]:GetAuras(1, false, 8)[1]
        local poisonDebuff = friendly[i]:GetAuras(1, false, 16)[1]

        if (friendly[i]:InParty() or friendly[i]:InRaid()) and
            magicDebuff and magicDebuff:GetTimeleft() >= 2000 or
            diseaseDebuff and diseaseDebuff:GetTimeleft() >= 2000 or
            poisonDebuff and poisonDebuff:GetTimeleft() >= 2000 then
            return friendly[i]
        end
    end

    local magicDebuff = player:GetAuras(1, false, 2)[1]
    local diseaseDebuff = player:GetAuras(1, false, 8)[1]
    local poisonDebuff = player:GetAuras(1, false, 16)[1]

    if magicDebuff and magicDebuff:GetTimeleft() >= 2000
    or diseaseDebuff and diseaseDebuff:GetTimeleft() >= 2000
    or poisonDebuff and poisonDebuff:GetTimeleft() >= 2000 then
        return player
    end
end

function CheckStatue(player)
    local statue
    local units = player:GetNearbyFriendlyUnits(20)

    for i = 1, #units do
        if units[i]:GetEntry() == 60849 then statue = units[i] end
    end
    return statue
end

function getRenewTarget(player)
    local friendlies = player:GetNearbyFriendlyPlayers(40)

    for i = 1, #friendlies do
        local tCheck = friendlies[i]
        if (tCheck:InParty() or tCheck:InRaid()) and not tCheck:HasAuraByPlayer(AURA_RENEWING_MIST) then
            return tCheck
        end
    end

    return player
end

function KeyPress(event, key, modifiers)
    pressedShift = (modifiers & 1) > 0
    pressedCtrl = (modifiers & 2) > 0
	pressedAlt = (modifiers & 4) > 0

    if pressedShift then
        if not onlyDPS then
            onlyDPS = true
            onlyHEAL = false
        else
            onlyDPS = false
        end
    end

    if pressedCtrl then
        if not onlyHEAL then
            onlyHEAL = true
            onlyDPS = false
        else
            onlyHEAL = false
        end
    end

    if pressedAlt then
        onlyDPS = false
        onlyHEAL = false
    end
end

-- Shift to set to only DPS Mode, CTRL To set to only heal mode. Alt to disable all.
RegisterEvent(4, KeyPress)

return Mistweaver