local FishingState =
{
	Idle = 0,
	Fishing = 1,
	Bobbing = 2
}

local CurrentState = FishingState.Idle

local Spells = 
{
	Fishing = Spell(131474)
}

-- This is fix so it doesnt recast before looting
local recastTime = 0

-- Cast counter
local castCounter = 0

-- Player position when script is "started". If we move, cancel the script.
local startPos = Vec3(0, 0, 0)

function Tick(event, player)
	bobber = player:GetFishingBobber()

	--[[ Some debugging shit
	if CurrentState == FishingState.Idle then
		DrawText("Idle", Vec2(200, 200))
	elseif CurrentState == FishingState.Fishing then
		DrawText("Fishing", Vec2(200, 200))
	elseif CurrentState == FishingState.Bobbing then
		DrawText("Bobbing", Vec2(200, 200))
	else
		DrawText("Error", Vec2(200, 200))
	end
	]]--

	-- Start fishing bot
	if CurrentState == FishingState.Idle and bobber then
		CurrentState = FishingState.Fishing
		startPos = player:GetPosition()
		return
	end

	-- Wait for bobbing
	if CurrentState == FishingState.Fishing then
		-- No longer fishing (ugly but can't compare not-equal)
		currentPos = player:GetPosition()
		if startPos:GetX() ~= currentPos:GetX() or startPos:GetY() ~= currentPos:GetY() or startPos:GetZ() ~= currentPos:GetZ() then
			CurrentState = FishingState.Idle
			return
		end

		-- Bobber is splashing, set state to bobbing so we know to recast fishing
		if bobber and bobber:IsBobbing() then
			CurrentState = FishingState.Bobbing
			bobber:Interact()
			recastTime = GetCurTimeMs() + 1000
			return
		end

		-- If the cast failed due to shallow water or whatever
		if not bobber and GetCurTimeMs() > recastTime then
			Spells.Fishing:Cast(player)
			recastTime = GetCurTimeMs() + 1000
			return
		end
	end

	-- This is where we recast fishing
	if CurrentState == FishingState.Bobbing and Spells.Fishing:CanCast() and GetCurTimeMs() > recastTime then
		CurrentState = FishingState.Fishing
		Spells.Fishing:Cast(player)
		castCounter = castCounter + 1
		return
	end

	-- If we're not idle draw how many times we casted.
	if CurrentState ~= FishingState.Idle then
		DrawText('I have casted ' .. castCounter .. ' times for you my friend', Vec2(200, 200))
	end
end

RegisterEvent(1, Tick)