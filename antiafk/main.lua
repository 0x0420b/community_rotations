function Tick(event, player)
	local lastAction = player:GetLastHardwareAction()
	local curTime = GetCurTimeMs()

	if (curTime - lastAction) > 60000 then
		player:SetLastHardwareAction(curTime)
	end
end

RegisterEvent(1, Tick)