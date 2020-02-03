local SPELL_TIGER_PALM = Spell(100780, 8)
local SPELL_BLACKOUT_STRIKE = Spell(205523)
local SPELL_CHI_WAVE = Spell(115098)
local SPELL_KEG_SMASH = Spell(121253)
local SPELL_BREATH_OF_FIRE = Spell(115181, 8)
local SPELL_SPEAR_HAND_STRIKE = Spell(116705, 8)
local SPELL_EXPEL_HARM = Spell(115072, 8)
local SPELL_RUSHING_JADE_WIND = Spell(116847, 18)
local SPELL_CHI_BURST = Spell(123986, 10)
local SPELL_FORTIFYING_BREW = Spell(115203, 100)
local SPELL_DETOX = Spell(218164)
local SPELL_VIVIFY = Spell(116670)

local SPELL_IRONSKIN_BREW = Spell(115308,100)
local SPELL_PURIFYING_BREW = Spell(119582,100)

local AURA_IRONSKINBREW = 215479
local AURA_MEDSTAGGER = 124274
local AURA_HIGHSTAGGER = 124273
local AURA_RUSHINGJADEWIND = 116847

local Brewmaster = {}	

function Brewmaster.DoCombat(player, target)
	if #player:GetNearbyEnemyUnits(10) > 1 then
		Brewmaster.AoERotation(player, target)
	else
		Brewmaster.SingleRotation(player, target)
	end
end

function Brewmaster.AoERotation(player, target)
	Brewmaster.SingleRotation(player, target)
end

function Brewmaster.SingleRotation(player, target)
	-- local Draw = TextHook.Instance()
	local energy = player:GetPower(3)
	-- local farligt = player.Debuffs

	local medstagger = player:GetAura(AURA_MEDSTAGGER)
	local highstagger = player:GetAura(AURA_HIGHSTAGGER)
	local brewexists = player:GetAura(AURA_IRONSKINBREW)
	local brewbuff = player:GetAuraByPlayer(AURA_IRONSKINBREW)
	local jadeexists = player:GetAura(AURA_RUSHINGJADEWIND)
	local rushingjade = player:GetAuraByPlayer(AURA_RUSHINGJADEWIND)


	local units = player:GetNearbyEnemyUnits(10)
	local brewtimer = 0
	local jadetimer = 0

	if jadeexists then
		jadetimer = rushingjade:GetTimeleft()
	end

	if brewexists then
		brewtimer = brewbuff:GetTimeleft()
	end

	if SPELL_FORTIFYING_BREW:CanCast() and player:GetHealthPercent() < 25 then
		SPELL_FORTIFYING_BREW:Cast(player)
		return
	end

	-- for i = 1, #farligt do
	--	if farligt[i].Type == SpellType.Poison or farligt[i].Type == SpellType.Disease then
	--		if SPELL_DETOX:CanCast(player) then
	--			SPELL_DETOX:Cast(player)
	--		end
	--	end
	-- end

	if SPELL_VIVIFY:CanCast(player) and not player:InCombat() and player:GetHealthPercent() < 85 and not player:IsMoving() then
		SPELL_VIVIFY:Cast(player)
		return
	end

	if not ShouldAttack(player, target) then
		return
	end

	for i = 1, #units do
		if units[i]:InCombat() and Brewmaster.ShouldInterrupt(units[i]) then
			if SPELL_SPEAR_HAND_STRIKE:CanCast(units[i]) then
				SPELL_SPEAR_HAND_STRIKE:Cast(units[i])
				return
			end
		end
	end

	if SPELL_EXPEL_HARM:CanCast(target) and player:GetHealthPercent() <= 70 then
		SPELL_EXPEL_HARM:Cast(target)
		return
	end

	if SPELL_PURIFYING_BREW:CanCast(target) and highstagger and brewtimer > 6000 then
		SPELL_PURIFYING_BREW:Cast(player)
		return
	end

	if SPELL_IRONSKIN_BREW:CanCast(target) and (SPELL_IRONSKIN_BREW:GetCharges() > 1 or not brewexists) and brewtimer <= 14000 then
		SPELL_IRONSKIN_BREW:Cast(player)
		return
	end

	if SPELL_RUSHING_JADE_WIND:CanCast(target) and jadetimer < 2000 then
		SPELL_RUSHING_JADE_WIND:Cast(target)
		return
	end 

	if SPELL_CHI_BURST:CanCast(target) and not SPELL_KEG_SMASH:IsReady() and not player:IsMoving() then
		SPELL_CHI_BURST:Cast(target)
		return
	end

	if SPELL_KEG_SMASH:CanCast(target) then
		SPELL_KEG_SMASH:Cast(target)
		return
	end

	if SPELL_BLACKOUT_STRIKE:CanCast(target) and not SPELL_KEG_SMASH:IsReady() then
		SPELL_BLACKOUT_STRIKE:Cast(target)
		return
	end

	if SPELL_BREATH_OF_FIRE:CanCast(target) and not player:IsMoving() and not SPELL_KEG_SMASH:CanCast(target) then
		SPELL_BREATH_OF_FIRE:Cast(target)
		return
	end

	if SPELL_TIGER_PALM:CanCast(target) and not SPELL_KEG_SMASH:IsReady() and energy >= 65 then
		SPELL_TIGER_PALM:Cast(target)
		return
	end
end

function Brewmaster.ShouldInterrupt(target)
	if target:IsCasting() or target:IsChanneling() then
		local sprop = target:GetCurrentSpell()
		local timesup = sprop:GetTimeleft()
    	if sprop ~= nil then
			if sprop:IsInterruptible() and timesup <= 400 then
                return true -- if interruptable
        end
        end
    end
    return false
end

return Brewmaster