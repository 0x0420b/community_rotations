DispellTable = 
{
    -- Warfront
    273671, -- Poison Spear
    --271544, -- Hex WRONG ID
    262007, -- Polymorph
    79880 , -- Slow

    -- Instances
    -- Good list: https://www.icy-veins.com/wow/dispellable-mythic-dungeon-buffs-debuffs-in-battle-for-azeroth

    -- Atal'dazar
    252687, -- Venomfang Strike
    -- Unstable Hex (in condition table below)
    255371, -- Terrifying Visage
    255041, -- Terrifying Screech
    253562, -- Wildfire
    255582, -- Molten Gold

    -- Freehold
    257437, -- Poisoning Strike
    257784, -- Frost Blast
    257908, -- Oiled Blade

    -- Kings' Rest
    270865, -- Hidden Blade
    271564, -- Embalming Fluid
    270507, -- Posion Barrage
    270499, -- Frost Shock
    270492, -- Hex

    -- Shrine of the Storms
    264560, -- Choking Brine
    268233, -- Electrifying Shock
    268322, -- Touch of The Drowned
    268391, -- Mental Assault
    268896, -- Mind Rend
    269104, -- Explosive Void
    267037, -- Whisper of Power

    -- Siege of Boralus
    257168, -- Cursed Slash
    275836, -- Stinging Venom
    -- Putrid Waters (in condition table below)

    -- Temple of Sethraliss
    273563, -- Neurotoxin
    272657, -- Noxious Breath
    267027, -- Cytotoxin
    272699, -- Venomous Spit
    268013, -- Flame Shock
    268008, -- Snake Charm

    -- The MOTHERLODE!!
    280605, -- Freeze
    268797, -- Slime
    259853, -- Chemical burn


    -- The Underrot
    266265, -- Wicked Assault
    272180, -- Death Bolt
    265468, -- Withering Curse
    269838, -- Vile Explusion

    -- Tol Dagor
    265889, -- Torch Strike
    257777, -- Crippling Shiv
    258864, -- Suppression Fire
    257028, -- Fuselighter
    258917, -- Righteous Flames
    257791, -- Howling Fear
    258128, -- Debilitating Shout

    -- Waycrest Manor
    --264050, -- Infected Thorn (Disease)
    --261440, -- Virulent Pathogen (Disease)
    263891, -- Grasping Thorns (Magic)
    265352, -- Toad Blight (Magic)
    264378, -- Fragment Soul (Magic)
    263905, -- Marking Cleave (Curse)
    264105, -- Runic Mark (Curse)

    -- Raids

    -- Uldir
    278773, --Ravage Plasma

    --PvP
    286349, -- Maledict
    853, -- Hammer of justice
    339, -- Entangling roots
    20066, -- Repentenance
    3355, -- trap
}

DispellCondTable = 
{
    -- Atal'Dazar
    [252781] = function(unit) return #unit:GetNearbyFriendlyUnits(20) == 0 end, -- Unstable Hex (range 20?)

    -- Siege of Boralus
    [275014] = function(unit) return #unit:GetNearbyFriendlyUnits(10) == 0 end, -- Putrid Waters (Only dispell if no friendlies within 8 yards)
}

function ShouldDispell(unit)
    local auras = unit:GetAuras()
    
    for i = 1, #auras do
        for key, value in pairs(DispellTable) do
            if auras[i]:GetSpellID() == value and auras[i]:GetTimeleft() > 2000 then
                DrawText('Dispel ' .. value, Vec2(200, 200))
                return true
            end
        end

        for key, value in pairs(DispellCondTable) do
            if auras[i]:GetSpellID() == key and value(unit) then
                DrawText('Dispel ' .. key, Vec2(200, 200))
                return true
            end
        end
    end

    return false
end