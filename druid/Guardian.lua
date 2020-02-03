local SPELL_MOONFIRE = Spell(8921)
local SPELL_THRASH = Spell(77758)
local SPELL_MANGLE = Spell(33917)
local SPELL_SWIPE = Spell(213771)
local SPELL_MAUL = Spell(6807)


local SPELL_GROWL = Spell(6795)
local SPELL_INCAPACITATING_ROAR = Spell(99)
local SPELL_SOOTHE = Spell(2908)
local SPELL_SKULL_BASH = Spell(106839)

local SPELL_IRONFUR = Spell(192081)
local SPELL_BARKSKIN = Spell(22812)
local SPELL_FRENZIED_REGENERATION = Spell(22842)
local SPELL_SURIVAL_INSTINCTS = Spell(61336)

local DEBUFF_MOONFIRE = 164812
local DEBUFF_THRASH = 192090

local BUFF_GALACTIC_GUARDIAN = 213708
local BUFF_GORE = 93622
local BUFF_FREE_IRONFUR = 279541

local Guardian = {}

function Guardian.DoCombat(player, target)

	local free_Ironfur = player:GetAura(BUFF_FREE_IRONFUR)

	if SPELL_SOOTHE:IsReady() then
		local enemyUnits = player:GetNearbyEnemyUnits(40)
		for i = 1, #enemyUnits do
			local auras = enemyUnits[i]:GetAuras()
			for k = 1, #auras do
				if auras[k]:GetType() == 9 and SPELL_SOOTHE:CanCast(enemyUnits[i]) then
					SPELL_SOOTHE:Cast(enemyUnits[i])
				end
			end
		end
	end

	if player:InCombat() and SPELL_GROWL:IsReady() then
        local units = player:GetNearbyEnemyUnits(30)
        for i = 1, #units do
         -- The unit's target
            local unit_target = units[i]:GetTarget()

            if units[i]:InCombat() and unit_target and isTeammate(unit_target) and unit_target:GetGUID():GetLoWord() ~= player:GetGUID():GetLoWord() then
				SPELL_GROWL:Cast(units[i])
				return
            end
        end
	end

	if SPELL_SKULL_BASH:IsReady() then
		local units = player:GetNearbyEnemyUnits(13)
		for i = 1, #units do
			if units[i]:InCombat() and doInterrupt(units[i], false) then
				if SPELL_SKULL_BASH:CanCast(units[i]) then
					SPELL_SKULL_BASH:Cast(units[i])
					return
				end
			end
		end
	end

	-- Defensives
	if player:InCombat() and (player:GetHealthPercent() < 97 and player:GetRage() >= 45 or player:GetRage() == 100 and player:GetHealthPercent() < 100 or free_Ironfur and free_Ironfur:GetStacks() == 3) and SPELL_IRONFUR:CanCast(player) then
		SPELL_IRONFUR:Cast(player)
		return
	end

	if player:GetRage() == 100 and SPELL_MAUL:CanCast(target) then
		SPELL_MAUL:Cast(target)
		return
	end

	if player:InCombat() and player:GetHealthPercent() < 79 and SPELL_BARKSKIN:CanCast(player) then
		SPELL_BARKSKIN:Cast(player)
		return
	end

	if player:InCombat() and player:GetHealthPercent() < 60 and SPELL_FRENZIED_REGENERATION:CanCast(player) then
		SPELL_FRENZIED_REGENERATION:Cast(player)
		return
	end

	if not target:HasAuraByPlayer(DEBUFF_MOONFIRE) and SPELL_MOONFIRE:CanCast(target) then
		SPELL_MOONFIRE:Cast(target)
		return
	end

	if SPELL_THRASH:CanCast(target) then
		SPELL_THRASH:Cast(target)
		return
	end

	if #player:GetNearbyEnemyUnits(8) > 4 and SPELL_SWIPE:CanCast(target) then
		SPELL_SWIPE:Cast(target)
		return
	end

	if #player:GetNearbyEnemyUnits(10) > 1 then
		local units = player:GetNearbyEnemyUnits(10)
		for i = 1, #units do
			if not units[i]:HasAuraByPlayer(DEBUFF_MOONFIRE) and SPELL_MOONFIRE:CanCast(units[i]) then
				SPELL_MOONFIRE:Cast(units[i])
				return
			end
		end
	end


	if SPELL_MANGLE:CanCast(target) then
		SPELL_MANGLE:Cast(target)
		return
	end

	if player:HasAura(BUFF_GALACTIC_GUARDIAN) and SPELL_MOONFIRE:CanCast(target) then
		SPELL_MOONFIRE:Cast(target)
		return
	end


	if SPELL_SWIPE:CanCast(target) then
		SPELL_SWIPE:Cast(target)
		return
	end
end

function isTeammate(unit)
	if unit:InParty() or unit:InRaid() then
		return true
	else 
		return false
	end
end

function doInterrupt(unit, instant)
	local toInterrupt = math.random(700, 1000)
	if unit:IsCasting() or unit:IsChanneling() then
	  local unitSpell = unit:GetCurrentSpell()
	  if unitSpell ~= nil and unitSpell:IsInterruptible() and (unitSpell:GetTimeleft() < toInterrupt or instant) then
		return true
	  end
	end
	return false
end

function backup()
	for i = 1, #units do
		local trash = units[i]:GetAura(DEBUFF_THRASH)
		if trash and (trash:GetStacks() < 3 or trash:GetTimeleft() <= 2000) and SPELL_THRASH:CanCast(target) then
			SPELL_MOONFIRE:Cast(units[i])
			return
		end
	end
end



return Guardian