-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2026-02-02 14:12:23
-- Luau version 6, Types version 3
-- Time taken: 0.007545 seconds

local ContextActionService_upvr = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local IsHeld_upvr = Players.LocalPlayer:WaitForChild("IsHeld")
local HeldTimer_upvr = Players.LocalPlayer:WaitForChild("HeldTimer")
local Struggle_upvr = game:GetService("ReplicatedStorage").CharacterEvents.Struggle
local ActionEvent_upvr = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ControlsGui"):WaitForChild("ActionEvent")
local Humanoid_upvr = script.Parent:WaitForChild("Humanoid")
local var8_upvw = false
Humanoid_upvr:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
Humanoid_upvr:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
local function doStruggle_upvr(arg1, arg2, arg3) -- Line 26, Named "doStruggle"
	--[[ Upvalues[1]:
		[1]: Struggle_upvr (readonly)
	]]
	if arg1 == "Escape" and arg2 == Enum.UserInputState.Begin then
		Struggle_upvr:FireServer()
	end
end
local function _() -- Line 34, Named "unbindStruggle"
	--[[ Upvalues[4]:
		[1]: ActionEvent_upvr (readonly)
		[2]: var8_upvw (read and write)
		[3]: ContextActionService_upvr (readonly)
		[4]: Humanoid_upvr (readonly)
	]]
	ActionEvent_upvr:Fire("EscapeControls", false)
	if var8_upvw == true then
		var8_upvw = false
		ContextActionService_upvr:UnbindAction("JumpRemover")
	end
	ContextActionService_upvr:UnbindAction("Escape")
	Humanoid_upvr:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
end
local module_upvr = require(Players.LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("CASButtonModule"))
local function bindStruggle_upvr() -- Line 45, Named "bindStruggle"
	--[[ Upvalues[4]:
		[1]: ActionEvent_upvr (readonly)
		[2]: module_upvr (readonly)
		[3]: doStruggle_upvr (readonly)
		[4]: Humanoid_upvr (readonly)
	]]
	ActionEvent_upvr:Fire("EscapeControls", true)
	module_upvr.PlaceButton("Escape", doStruggle_upvr)
	module_upvr.ChangeColor("Escape", Color3.new(0.682353, 1, 0.34902))
	Humanoid_upvr:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
end
Struggle_upvr.OnClientEvent:Connect(function(arg1) -- Line 52
	--[[ Upvalues[5]:
		[1]: Humanoid_upvr (readonly)
		[2]: bindStruggle_upvr (readonly)
		[3]: ActionEvent_upvr (readonly)
		[4]: var8_upvw (read and write)
		[5]: ContextActionService_upvr (readonly)
	]]
	-- KONSTANTERROR: [0] 1. Error Block 1 start (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [0] 1. Error Block 1 end (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [8] 6. Error Block 3 start (CF ANALYSIS FAILED)
	bindStruggle_upvr()
	do
		return
	end
	-- KONSTANTERROR: [8] 6. Error Block 3 end (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [11] 9. Error Block 11 start (CF ANALYSIS FAILED)
	if arg1 == "Unbind" then
		ActionEvent_upvr:Fire("EscapeControls", false)
		if var8_upvw == true then
			var8_upvw = false
			ContextActionService_upvr:UnbindAction("JumpRemover")
		end
		ContextActionService_upvr:UnbindAction("Escape")
		Humanoid_upvr:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
	end
	-- KONSTANTERROR: [11] 9. Error Block 11 end (CF ANALYSIS FAILED)
end)
Humanoid_upvr.Died:Connect(function() -- Line 63
	--[[ Upvalues[4]:
		[1]: ActionEvent_upvr (readonly)
		[2]: var8_upvw (read and write)
		[3]: ContextActionService_upvr (readonly)
		[4]: Humanoid_upvr (readonly)
	]]
	ActionEvent_upvr:Fire("EscapeControls", false)
	if var8_upvw == true then
		var8_upvw = false
		ContextActionService_upvr:UnbindAction("JumpRemover")
	end
	ContextActionService_upvr:UnbindAction("Escape")
	Humanoid_upvr:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
end)
local Ragdolled_upvr = Humanoid_upvr:WaitForChild("Ragdolled")
IsHeld_upvr.Changed:Connect(function() -- Line 68
	--[[ Upvalues[3]:
		[1]: IsHeld_upvr (readonly)
		[2]: Ragdolled_upvr (readonly)
		[3]: Humanoid_upvr (readonly)
	]]
	-- KONSTANTERROR: [0] 1. Error Block 1 start (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [0] 1. Error Block 1 end (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [10] 7. Error Block 3 start (CF ANALYSIS FAILED)
	Humanoid_upvr:ChangeState(Enum.HumanoidStateType.GettingUp)
	Humanoid_upvr.AutoRotate = true
	Humanoid_upvr:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
	do
		return
	end
	-- KONSTANTERROR: [10] 7. Error Block 3 end (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [28] 20. Error Block 4 start (CF ANALYSIS FAILED)
	Humanoid_upvr.Sit = true
	Humanoid_upvr:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	Humanoid_upvr.AutoRotate = false
	-- KONSTANTERROR: [28] 20. Error Block 4 end (CF ANALYSIS FAILED)
end)
local function dummyFunction_upvr() -- Line 92, Named "dummyFunction"
end
Humanoid_upvr.Died:Connect(function() -- Line 95
	--[[ Upvalues[2]:
		[1]: var8_upvw (read and write)
		[2]: ContextActionService_upvr (readonly)
	]]
	if var8_upvw == true then
		var8_upvw = false
		ContextActionService_upvr:UnbindAction("JumpRemover")
	end
end)
HeldTimer_upvr.Changed:Connect(function() -- Line 102
	--[[ Upvalues[4]:
		[1]: var8_upvw (read and write)
		[2]: HeldTimer_upvr (readonly)
		[3]: IsHeld_upvr (readonly)
		[4]: ContextActionService_upvr (readonly)
	]]
	if var8_upvw == true and HeldTimer_upvr.Value == 0 and IsHeld_upvr.Value == true then
		var8_upvw = false
		ContextActionService_upvr:UnbindAction("JumpRemover")
	end
end)
IsHeld_upvr.Changed:Connect(function() -- Line 110
	--[[ Upvalues[6]:
		[1]: IsHeld_upvr (readonly)
		[2]: HeldTimer_upvr (readonly)
		[3]: Humanoid_upvr (readonly)
		[4]: var8_upvw (read and write)
		[5]: ContextActionService_upvr (readonly)
		[6]: dummyFunction_upvr (readonly)
	]]
	-- KONSTANTERROR: [0] 1. Error Block 1 start (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [0] 1. Error Block 1 end (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [5] 4. Error Block 2 start (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [5] 4. Error Block 2 end (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [11] 8. Error Block 3 start (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [11] 8. Error Block 3 end (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [20] 14. Error Block 5 start (CF ANALYSIS FAILED)
	var8_upvw = true
	ContextActionService_upvr:BindAction("JumpRemover", dummyFunction_upvr, false, Enum.KeyCode.Space, Enum.KeyCode.ButtonA)
	do
		return
	end
	-- KONSTANTERROR: [20] 14. Error Block 5 end (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [34] 25. Error Block 10 start (CF ANALYSIS FAILED)
	if var8_upvw == true and IsHeld_upvr.Value == false then
		var8_upvw = false
		ContextActionService_upvr:UnbindAction("JumpRemover")
	end
	-- KONSTANTERROR: [34] 25. Error Block 10 end (CF ANALYSIS FAILED)
end)
local Ragdolled_upvr_2 = Humanoid_upvr:WaitForChild("Ragdolled")
Ragdolled_upvr_2.Changed:Connect(function() -- Line 127
	--[[ Upvalues[6]:
		[1]: Ragdolled_upvr_2 (readonly)
		[2]: Humanoid_upvr (readonly)
		[3]: var8_upvw (read and write)
		[4]: ContextActionService_upvr (readonly)
		[5]: dummyFunction_upvr (readonly)
		[6]: IsHeld_upvr (readonly)
	]]
	-- KONSTANTERROR: [0] 1. Error Block 1 start (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [0] 1. Error Block 1 end (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [5] 4. Error Block 2 start (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [5] 4. Error Block 2 end (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [14] 10. Error Block 4 start (CF ANALYSIS FAILED)
	var8_upvw = true
	ContextActionService_upvr:BindAction("JumpRemover", dummyFunction_upvr, false, Enum.KeyCode.Space, Enum.KeyCode.ButtonA)
	do
		return
	end
	-- KONSTANTERROR: [14] 10. Error Block 4 end (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [28] 21. Error Block 9 start (CF ANALYSIS FAILED)
	if var8_upvw == true and IsHeld_upvr.Value == false then
		var8_upvw = false
		ContextActionService_upvr:UnbindAction("JumpRemover")
	end
	-- KONSTANTERROR: [28] 21. Error Block 9 end (CF ANALYSIS FAILED)
end)
