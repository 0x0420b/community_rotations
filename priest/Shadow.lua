local SPELL_SHADOW_WORD_VOID = Spell(205351) -- Mind blast alternative (TALENT)
local SPELL_VAMPIRIC_TOUCH = Spell(34914)
local SPELL_SHADOW_WORD_PAIN = Spell(589)
local SPELL_DARK_ASCENSION = Spell(280711)
local SPELL_VOID_BOLT = Spell(205448, 100)
local SPELL_MINDBENDER = Spell(200174)
local SPELL_VOID_ERUPTION = Spell(228260)
local SPELL_VOID_CRASH = Spell(205385)
local SPELL_MIND_FLAY = Spell(15407)
local SPELL_VAMPIRIC_EMBRACE = Spell(15286)
local SPELL_MIND_SEAR = Spell(48045)

local AURA_SHADOW_WORD_PAIN = 589
local AURA_VAMPIRIC_TOUCH = 34914
local AURA_VOIDHASTE = 194249

local TouchLast = false

local Shadow = {}

function Shadow.DoCombat(player, target)
	local ActualCombat = false
	local members = player:GetNearbyFriendlyPlayers(40)
	
	if player:InCombat() then
		ActualCombat = true
	end

	if player:InParty() or player:InRaid() then
		for i = 1, #members do
			if (members[i]:InParty() or members[i]:InRaid()) and members[i]:InCombat() then -- If you are curious as to why we need this, ask Neer.
				ActualCombat = true
			end
		end
	end

	if ActualCombat and target ~= nil and not target:IsDead() and not player:IsMounted() and not player:IsStunned() and not player:IsMoving() then
		if player:GetHealthPercent() <= 85 and SPELL_VAMPIRIC_EMBRACE:CanCast() then
			SPELL_VAMPIRIC_EMBRACE:Cast(player)
			return
		end
		Shadow.DoRotation(player, target)
	end
end



function Shadow.DoRotation(player, target)
	local EnemiesInCombat = 0
	local SWP = target:GetAuraByPlayer(AURA_SHADOW_WORD_PAIN)
	local VT = target:GetAuraByPlayer(AURA_VAMPIRIC_TOUCH)
	local VoidBuff = player:GetAura(AURA_VOIDHASTE)
	local UseCDS = false

	local VoidStacks = 0 -- haste buff in void form.
	local SWPTime = 0 -- 4.5 sec pandemic
	local VTTime = 0 -- 6 Sec pandemic
	local enemies = player:GetNearbyEnemyUnits(40)

	for i = 1, #enemies do
		if enemies[i]:InCombat() then
			EnemiesInCombat = EnemiesInCombat + 1
		end
	end
	
	if getPartyMembers(player) >= 3 then
		if target:GetHealthMax() > player:GetHealthMax() * 8 then
			UseCDS = true
		end
	elseif getPartyMembers(player) < 3 then
		if target:GetHealthMax() > player:GetHealthMax() * 3 then
			UseCDS = true
		end
	end

	if VoidBuff ~= nil then
		VoidStacks = VoidBuff:GetStacks()
	end

	if SWP ~= nil then
		SWPTime = SWP:GetTimeleft()
	end

	if VT ~= nil then
		VTTime = VT:GetTimeleft()
	end

	if SPELL_VOID_ERUPTION:CanCast(target) then
		SPELL_VOID_ERUPTION:Cast(target)
		TouchLast = false
		return
	end

	if SPELL_DARK_ASCENSION:CanCast(target) and player:GetInsanity() < 40 then
		SPELL_DARK_ASCENSION:Cast(target)
		TouchLast = false
		return
	end

	if SPELL_VOID_BOLT:CanCast(target) then
		SPELL_VOID_BOLT:Cast(target)
		TouchLast = false
		return
	end

	if EnemiesInCombat > 5 and SPELL_VOID_CRASH:CanCast() and not target:IsMoving() then
		SPELL_VOID_CRASH:CastOnGround(target:GetPosition())
		TouchLast = false
		return
	end

	if SPELL_SHADOW_WORD_VOID:CanCast(target) then
		SPELL_SHADOW_WORD_VOID:Cast(target)
		TouchLast = false
		return
	end

	if SPELL_VAMPIRIC_TOUCH:CanCast(target) and VTTime < 6000 and not TouchLast then
		SPELL_VAMPIRIC_TOUCH:Cast(target)
		TouchLast = true
		return
	end

	if EnemiesInCombat > 1 then
		for i = 1, #enemies do
			if ShouldDot(enemies[i], player) and SPELL_VAMPIRIC_TOUCH:CanCast(enemies[i]) and enemies[i] ~= target then
				SPELL_VAMPIRIC_TOUCH:Cast(enemies[i])
				TouchLast = true
			end
		end
	end

	if SPELL_MINDBENDER:CanCast(target) and UseCDS and VoidStacks > 8 then
		SPELL_MINDBENDER:Cast(target)
		TouchLast = false
		return
	end

	if SPELL_VOID_CRASH:CanCast() and not target:IsMoving() then
		SPELL_VOID_CRASH:CastOnGround(target:GetPosition())
		TouchLast = false
		return
	end

	if SPELL_MIND_FLAY:CanCast(target) and #target:GetNearbyEnemyUnits(10) < 3 and not (player:IsCasting() or player:IsChanneling()) then
		SPELL_MIND_FLAY:Cast(target)
		TouchLast = false
		return
	end

	if SPELL_MIND_SEAR:CanCast(target) and #target:GetNearbyEnemyUnits(10) > 2 and not (player:IsCasting() or player:IsChanneling()) then
		SPELL_MIND_SEAR:Cast(target)
		TouchLast = false
		return
	end
end

function ShouldDot(unit, player)
	if getPartyMembers(player) >= 3 then
		if not TouchLast and unit:InCombat() and not unit:HasAuraByPlayer(AURA_VAMPIRIC_TOUCH) and unit:GetHealth() > player:GetHealthMax() * 1 then
			return true
		end
		return false
	elseif getPartyMembers(player) < 3 then
		if not TouchLast and unit:InCombat() and not unit:HasAuraByPlayer(AURA_VAMPIRIC_TOUCH) and unit:GetHealth() > player:GetHealthMax() * 0.3 then
			return true
		end
		return false
	end
end

function getPartyMembers(player)
	local friendlies = player:GetNearbyFriendlyPlayers(40)
	local amt = 0
	for i = 1, #friendlies do
		if friendlies[i]:InParty() then
			amt = amt + 1
		end
	end
	return amt
end

return Shadow