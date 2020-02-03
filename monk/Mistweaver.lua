-- New one by Neer
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

local tempVal = 0 -- used to store values for lifecycles.
local Envelop = false
local STATUE_ID = 60849

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

function Mistweaver.DoCombat(player, target)
    -- DEBUG PART
    if Settings.drawDebug == 2 then Debug(player) end
    -- DEBUG PART
    local sprop = player:GetCurrentSpell()
    if player:IsDead() or sprop and sprop == 191837 or -- LETS NOT CANCEL ESSENCE FONT
    player:IsMounted() or player:IsCasting() or player:HasTerrainSpellActive() or player:HasAura(AURA_FOOD) then
        return
    end

    local jadestatue = CheckStatue(player)
    local findTank = getTank(player)
    local toHeal = getLowest(player)
    local HealthLevel = 0
    local multiHeal = MultiLow(player)
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

    if HealthLevel < 100 and
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

    if not toHeal:HasAuraByPlayer(AURA_SOOTHING_MIST_CHANNEL) and HealthLevel < 100 then
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

    -- Begin damage part.
    if not ShouldAttackSpecial(player, target) or Settings.doDPS ~= 2 or HealthLevel <= 90 then
        return
    end

    if #player:GetNearbyEnemyUnits(8) > 3 and
        SPELL_SPINNING_CRANE_KICK:CanCast() then
        SPELL_SPINNING_CRANE_KICK:Cast(target)
        return
    end

    if SPELL_RISING_SUN_KICK:CanCast(target) then
        SPELL_RISING_SUN_KICK:Cast(target)
        return
    end

    if SPELL_BLACKOUT_KICK:CanCast(target) then
        SPELL_BLACKOUT_KICK:Cast(target)
        return
    end

    if SPELL_TIGER_PALM:CanCast(target) then
        SPELL_TIGER_PALM:Cast(target)
        return
    end
end

function findDispell(player)
    local friendly = player:GetNearbyFriendlyPlayers(40)
    for i = 1, #friendly do
        if (friendly[i]:InParty() or friendly[i]:InRaid()) and
            #friendly[i]:GetAuras(1, false, 2) > 0 or
            #friendly[i]:GetAuras(1, false, 8) > 0 or
            #friendly[i]:GetAuras(1, false, 16) > 0 then
            return friendly[i]
        end
    end
    if #player:GetAuras(1, false, 2) > 0 or #player:GetAuras(1, false, 8) > 0 or
        #player:GetAuras(1, false, 16) > 0 then return player end
    return nil
end

function Debug(player)
    local x = 200
    local y = 200
    local s = 0

    if CheckStatue(player) ~= nil then
        if math.floor(player:GetDistance(CheckStatue(player))) <= 30 then
            DrawText('Healing Jade Statue is UP - Distance : ' ..
                         math.floor(player:GetDistance(CheckStatue(player))),
                     Vec2(400, 130))
        elseif math.floor(player:GetDistance(CheckStatue(player))) > 30 then
            DrawText('Healing Jade Statue is OUT OF RANGE!', Vec2(400, 130))
        end
    end

    if CheckStatue(player) == nil then
        DrawText('Healing Jade Statue is DOWN', Vec2(400, 130))
    end

    for key, value in pairs(Settings) do
        DrawText("Setting:" .. key .. ' = ' .. value, Vec2(200, 200 + (s * 15)))
        s = s + 1
    end
end

function MultiLow(player)
    local friendly = player:GetNearbyFriendlyPlayers(30)
    local lowcount = 0
    local selfcounted = false

    if player:GetHealthPercent() < 80 then lowcount = lowcount + 1 end

    for i = 1, #friendly do
        if (friendly[i]:InParty() or friendly[i]:InRaid()) and
            friendly[i]:GetHealthPercent() < Settings.AoePercent then
            lowcount = lowcount + 1
        end
    end
    return lowcount
end

function CheckStatue(player)
    local statue
    local units = player:GetNearbyFriendlyUnits(20)

    for i = 1, #units do
        if units[i]:GetEntry() == 60849 then statue = units[i] end
    end
    return statue
end

function getTank(player)
    local findTank = player:GetNearbyFriendlyPlayers(40)
    local tank

    for i = 1, #findTank do
        if (findTank[i]:InParty() or findTank[i]:InRaid()) and findTank[i]:GroupRole() == 1 then 
            tank = findTank[i] 
        end
    end

    return tank
end

function getLowest(player)
    local friendlies = player:GetNearbyFriendlyPlayers(40)
    local lowest

    for i = 1, #friendlies do
        if not friendlies[i]:IsDead() then
            if (friendlies[i]:InParty() or friendlies[i]:InRaid()) and not lowest then
                lowest = friendlies[i]
            end

            if lowest and (friendlies[i]:InParty() or friendlies[i]:InRaid()) and
                friendlies[i]:GetHealthPercent() < lowest:GetHealthPercent() then
                lowest = friendlies[i]
            end
        end
    end

    if lowest and player:GetHealthPercent() < lowest:GetHealthPercent() then
        lowest = player
    end

    return lowest
end

function getRenewTarget(player)
    local friendlies = player:GetNearbyFriendlyPlayers(40)

    for i = 1, #friendlies do
        local tCheck = friendlies[i]
        if (tCheck:InParty() or tCheck:InRaid()) and not tCheck:HasAuraByPlayer(AURA_RENEWING_MIST) then
            return tCheck
        end
    end
end

return Mistweaver