-- Decompiled with Konstant V2.1, a fast Luau decompiler made in Luau by plusgiant5 (https://discord.gg/brNTY8nX8t)
-- Decompiled on 2026-02-02 14:13:47
-- Luau version 6, Types version 3
-- Time taken: 0.071516 seconds

local ContextActionService_upvr = game:GetService("ContextActionService")
local Players_upvr = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService_upvr = game:GetService("RunService")
local UserInputService_upvr = game:GetService("UserInputService")
local module_upvr_2 = require(Players_upvr.LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("CASButtonModule"))
local var15_upvw
local var16_upvw
local ActionEvent_upvr = Players_upvr.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ControlsGui"):WaitForChild("ActionEvent")
local ExtendGrabLine_upvr = ReplicatedStorage.GrabEvents.ExtendGrabLine
local GrabNotifyEvent_upvr = Players_upvr.LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("CharacterAndBeamMove"):WaitForChild("GrabNotifyEvent")
local LocalPlayer_upvr = Players_upvr.LocalPlayer
local var21_upvw = false
local var22_upvw = false
local Crosshairs = LocalPlayer_upvr:WaitForChild("PlayerGui"):WaitForChild("Crosshairs")
local CrosshairsFrame_upvr = Crosshairs:WaitForChild("CrosshairsFrame")
Crosshairs.Enabled = true
if LocalPlayer_upvr.PlayerGui:WaitForChild("MenuGui").Enabled == false then
	UserInputService_upvr.MouseIconEnabled = false
end
local Character_upvr = Players_upvr.LocalPlayer.Character
local Humanoid_upvr = Character_upvr:WaitForChild("Humanoid")
local Head_upvr = Character_upvr:WaitForChild("Head")
local CurrentCamera_upvr = workspace.CurrentCamera
CurrentCamera_upvr.CameraType = Enum.CameraType.Custom
local var29_upvw
local var30_upvw
local Part_upvr = Instance.new("Part")
Part_upvr.CanQuery = false
Part_upvr.CanTouch = false
Part_upvr.CanCollide = false
Part_upvr.Transparency = 1
Part_upvr.Anchored = true
Part_upvr.Name = "CamPart"
Part_upvr.Parent = Character_upvr
local var33_upvw
var33_upvw = Head_upvr.AncestryChanged:Connect(function() -- Line 65
	--[[ Upvalues[3]:
		[1]: Head_upvr (readonly)
		[2]: var33_upvw (read and write)
		[3]: Part_upvr (readonly)
	]]
	if Head_upvr:IsDescendantOf(workspace) == false then
		var33_upvw:Disconnect()
		Part_upvr:Destroy()
	end
end)
local Attachment_upvr = Instance.new("Attachment")
Attachment_upvr.Parent = Part_upvr
Attachment_upvr.Position = Vector3.new(0, -2, -1)
RunService_upvr.RenderStepped:Connect(function() -- Line 76
	--[[ Upvalues[2]:
		[1]: Part_upvr (readonly)
		[2]: CurrentCamera_upvr (readonly)
	]]
	Part_upvr.CFrame = CurrentCamera_upvr.CFrame
end)
for _, v in pairs(workspace:GetChildren()) do
	if v.Name == "RotateOrientPart" then
		v:Destroy()
	end
end
local Part_upvr_2 = Instance.new("Part")
Part_upvr_2.Transparency = 1
Part_upvr_2.CanCollide = false
Part_upvr_2.CanTouch = false
Part_upvr_2.CanQuery = false
Part_upvr_2.Position = Vector3.new(0, 1000, 0)
Part_upvr_2.Anchored = true
Part_upvr_2.Name = "RotateOrientPart"
Part_upvr_2.Parent = workspace
local Attachment_upvr_2 = Instance.new("Attachment")
Attachment_upvr_2.Name = "PartOrient"
Attachment_upvr_2.Parent = Part_upvr_2
Attachment_upvr_2.Position = Vector3.new(0, 0, 0)
local function var41() -- Line 101
	--[[ Upvalues[2]:
		[1]: CurrentCamera_upvr (readonly)
		[2]: Part_upvr_2 (readonly)
	]]
	local _, any_ToOrientation_result2, _ = CurrentCamera_upvr.CFrame:ToOrientation()
	Part_upvr_2.Orientation = Vector3.new(Part_upvr_2.Orientation.x, math.deg(any_ToOrientation_result2), Part_upvr_2.Orientation.z)
end
RunService_upvr.Stepped:Connect(var41)
local var45_upvw = false
local var46_upvw = false
var41 = 20
local var47_upvw = var41
ReplicatedStorage.GamepassEvents.FurtherReachBoughtNotifier.OnClientEvent:Connect(function() -- Line 114
	--[[ Upvalues[1]:
		[1]: var47_upvw (read and write)
	]]
	var47_upvw = 30
end)
if ReplicatedStorage.GamepassEvents.CheckForGamepass:InvokeServer(20837132) == true then
	var47_upvw = 30
end
local var49_upvw = false
local var50_upvw = false
local var51_upvw = false
local DestroyGrabLine_upvr = ReplicatedStorage.GrabEvents.DestroyGrabLine
local function endGrab_upvr(arg1) -- Line 129, Named "endGrab"
	--[[ Upvalues[15]:
		[1]: var46_upvw (read and write)
		[2]: var22_upvw (read and write)
		[3]: CrosshairsFrame_upvr (readonly)
		[4]: GrabNotifyEvent_upvr (readonly)
		[5]: module_upvr_2 (readonly)
		[6]: var29_upvw (read and write)
		[7]: ContextActionService_upvr (readonly)
		[8]: var45_upvw (read and write)
		[9]: ActionEvent_upvr (readonly)
		[10]: CurrentCamera_upvr (readonly)
		[11]: RunService_upvr (readonly)
		[12]: var50_upvw (read and write)
		[13]: var49_upvw (read and write)
		[14]: DestroyGrabLine_upvr (readonly)
		[15]: var30_upvw (read and write)
	]]
	var46_upvw = false
	var22_upvw = false
	CrosshairsFrame_upvr.Size = UDim2.new(0, 11, 0, 11)
	GrabNotifyEvent_upvr:Fire(var46_upvw)
	module_upvr_2.ChangeColor("Grab")
	if var29_upvw then
		ContextActionService_upvr:UnbindAction("Throw")
		ContextActionService_upvr:UnbindAction("ZoomIn")
		ContextActionService_upvr:UnbindAction("ZoomOut")
		ContextActionService_upvr:UnbindAction("ZoomPC")
		ContextActionService_upvr:UnbindAction("Rotate")
		var45_upvw = false
		ActionEvent_upvr:Fire("GrabbingControls", false)
		ActionEvent_upvr:Fire("GrabControls", false)
		ActionEvent_upvr:Fire("RotatingControls", false)
		ActionEvent_upvr:Fire("RotateControls", false)
		CurrentCamera_upvr.CameraType = Enum.CameraType.Custom
		RunService_upvr:UnbindFromRenderStep("dragBinding")
		RunService_upvr:UnbindFromRenderStep("buttonDistanceMoving")
		var50_upvw = false
		var49_upvw = false
		var29_upvw:Destroy()
		DestroyGrabLine_upvr:FireServer(var30_upvw)
	end
end
local function distanceChangeButtonMoving_upvr() -- Line 156, Named "distanceChangeButtonMoving"
	--[[ Upvalues[5]:
		[1]: var51_upvw (read and write)
		[2]: var50_upvw (read and write)
		[3]: var49_upvw (read and write)
		[4]: ExtendGrabLine_upvr (readonly)
		[5]: var47_upvw (read and write)
	]]
	if var51_upvw == false then
		if var50_upvw == true and var49_upvw == false then
			var51_upvw = true
			if 3 < distance then
				distance = math.floor(distance - 1) -- Setting global
				ExtendGrabLine_upvr:FireServer(distance)
			end
			var51_upvw = false
			return
		end
		if var50_upvw == false and var49_upvw == true then
			var51_upvw = true
			if distance < var47_upvw then
				distance = math.ceil(distance + 1) -- Setting global
				ExtendGrabLine_upvr:FireServer(distance)
			end
			var51_upvw = false
		end
	end
end
local function drag_upvr() -- Line 176, Named "drag"
	--[[ Upvalues[6]:
		[1]: var46_upvw (read and write)
		[2]: var29_upvw (read and write)
		[3]: CurrentCamera_upvr (readonly)
		[4]: Attachment_upvr_2 (readonly)
		[5]: var30_upvw (read and write)
		[6]: endGrab_upvr (readonly)
	]]
	if var46_upvw == true then
		var29_upvw.DragPart.Position = CurrentCamera_upvr.CFrame.LookVector * distance + CurrentCamera_upvr.CFrame.Position
		var29_upvw.DragPart.DragAttach.WorldOrientation = Attachment_upvr_2.WorldOrientation
		var29_upvw.BeamPart.CFrame = CFrame.lookAt(var29_upvw.GrabPart.Position, var29_upvw.DragPart.Position, Vector3.new(0, 0, 1))
		local var54 = (var29_upvw.GrabPart.Position - var29_upvw.DragPart.Position).Magnitude * 1.5
		var29_upvw.BeamPart.GrabBeam.CurveSize1 = var54
		var29_upvw.GrabPart.BeamSound.PlaybackSpeed = var54 / 2 + 2.5
		if var30_upvw:IsDescendantOf(workspace) == false then
			endGrab_upvr("Throw")
		end
	end
end
local function throw_upvr(arg1, arg2, arg3) -- Line 201, Named "throw"
	--[[ Upvalues[4]:
		[1]: var46_upvw (read and write)
		[2]: endGrab_upvr (readonly)
		[3]: var30_upvw (read and write)
		[4]: CurrentCamera_upvr (readonly)
	]]
	-- KONSTANTWARNING: Variable analysis failed. Output will have some incorrect variable assignments
	if arg2 == Enum.UserInputState.Begin then
		if arg1 == "Throw" and var46_upvw == true then
			endGrab_upvr(arg1)
			if var30_upvw.Anchored == false then
				local var97
				if var30_upvw.Parent:IsA("Model") and var30_upvw.Parent.Name ~= "Workspace" then
					for _, v_2 in pairs(var30_upvw.Parent:GetChildren()) do
						if v_2:IsA("BasePart") then
							var97 += v_2.Mass
						end
					end
					if 100 < (CurrentCamera_upvr.CFrame.LookVector * 750 / var97 + CurrentCamera_upvr.CFrame.LookVector * 15).Magnitude then
					elseif (CurrentCamera_upvr.CFrame.LookVector * 100).Magnitude < 50 then
					end
					for _, v_3 in pairs(var30_upvw.Parent:GetChildren()) do
						if v_3:IsA("BasePart") then
							v_3.Velocity = CurrentCamera_upvr.CFrame.LookVector * 50
						end
					end
					return
				end
				local var106 = CurrentCamera_upvr.CFrame.LookVector * 750 / (var97 + var30_upvw.Mass) + CurrentCamera_upvr.CFrame.LookVector * 15
				if 100 < var106.Magnitude then
					var106 = CurrentCamera_upvr.CFrame.LookVector * 100
				end
				var30_upvw.Velocity = var106
			end
		end
	end
end
local _, _, _, _, _, _, _, _, _, _, _, _ = CurrentCamera_upvr.CFrame:GetComponents()
local HumanoidRootPart_upvr = Players_upvr.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
local var120_upvw
local any_GetGamepadState_result1 = UserInputService_upvr:GetGamepadState(Enum.UserInputType.Gamepad1)
local var122_upvw
if any_GetGamepadState_result1 then
    local var127
	for _, v_4 in pairs(any_GetGamepadState_result1) do
		({})[v_4.KeyCode] = v_4
	end
	var122_upvw = var127[Enum.KeyCode.Thumbstick2]
end
local function positionCam_upvr() -- Line 260, Named "positionCam"
	--[[ Upvalues[11]:
		[1]: UserInputService_upvr (readonly)
		[2]: CurrentCamera_upvr (readonly)
		[3]: Players_upvr (readonly)
		[4]: HumanoidRootPart_upvr (readonly)
		[5]: var120_upvw (read and write)
		[6]: Part_upvr_2 (readonly)
		[7]: var122_upvw (read and write)
		[8]: Attachment_upvr_2 (readonly)
		[9]: var46_upvw (read and write)
		[10]: RunService_upvr (readonly)
		[11]: var45_upvw (read and write)
	]]
	if UserInputService_upvr.MouseBehavior ~= Enum.MouseBehavior.LockCenter then
		UserInputService_upvr.MouseBehavior = Enum.MouseBehavior.LockCenter
	end
	if CurrentCamera_upvr.CameraType ~= Enum.CameraType.Scriptable then
		CurrentCamera_upvr.CameraType = Enum.CameraType.Scriptable
	end
	for _, v_5 in pairs(Players_upvr.LocalPlayer.Character:GetDescendants()) do
		if v_5:IsA("BasePart") then
			v_5.Transparency = 1
		end
	end
	CurrentCamera_upvr.CFrame = CFrame.new(HumanoidRootPart_upvr.CFrame * var120_upvw) * CurrentCamera_upvr.CFrame.Rotation
	local clone_3 = Part_upvr_2:Clone()
	clone_3.Anchored = true
	clone_3.Orientation = Vector3.new((clone_3.Orientation.X) - (var122_upvw.Position.Y + var122_upvw.Position.Y), (clone_3.Orientation.Y) + (var122_upvw.Position.X + var122_upvw.Position.X), clone_3.Orientation.Z)
	Attachment_upvr_2.WorldOrientation = clone_3:WaitForChild("PartOrient").WorldOrientation
	clone_3:Destroy()
	if var46_upvw == false then
		RunService_upvr:UnbindFromRenderStep("camBinding")
		CurrentCamera_upvr.CameraType = Enum.CameraType.Custom
		UserInputService_upvr.MouseBehavior = Enum.MouseBehavior.Default
		var45_upvw = false
	end
end
local function rotate_upvr(arg1, arg2, arg3, arg4, arg5) -- Line 297, Named "rotate"
	--[[ Upvalues[12]:
		[1]: var46_upvw (read and write)
		[2]: var45_upvw (read and write)
		[3]: var120_upvw (read and write)
		[4]: HumanoidRootPart_upvr (readonly)
		[5]: CurrentCamera_upvr (readonly)
		[6]: UserInputService_upvr (readonly)
		[7]: RunService_upvr (readonly)
		[8]: positionCam_upvr (readonly)
		[9]: ActionEvent_upvr (readonly)
		[10]: module_upvr_2 (readonly)
		[11]: Part_upvr_2 (readonly)
		[12]: Attachment_upvr_2 (readonly)
	]]
	if var46_upvw == true then
		if arg1 == "Rotate" and arg2 == Enum.UserInputState.Begin then
			if var45_upvw == false then
				var120_upvw = HumanoidRootPart_upvr.CFrame:ToObjectSpace(CurrentCamera_upvr.CFrame).Position
				CurrentCamera_upvr.CameraType = Enum.CameraType.Scriptable
				UserInputService_upvr.MouseBehavior = Enum.MouseBehavior.LockCenter
				RunService_upvr:BindToRenderStep("camBinding", Enum.RenderPriority.Camera.Value - 1, positionCam_upvr)
				var45_upvw = true
				ActionEvent_upvr:Fire("RotatingControls", true)
				ActionEvent_upvr:Fire("RotateControls", false)
				ActionEvent_upvr:Fire("")
				module_upvr_2.ChangeColor("Rotate", Color3.new(0, 1, 1))
			else
				CurrentCamera_upvr.CameraType = Enum.CameraType.Custom
				UserInputService_upvr.MouseBehavior = Enum.MouseBehavior.Default
				RunService_upvr:UnbindFromRenderStep("camBinding")
				var45_upvw = false
				module_upvr_2.ChangeColor("Rotate")
				ActionEvent_upvr:Fire("RotatingControls", false)
				ActionEvent_upvr:Fire("RotateControls", true)
			end
		end
		if arg1 == "rotateMove" and var45_upvw == true and arg5 == false and arg4.KeyCode ~= Enum.KeyCode.Thumbstick2 then
			local clone = Part_upvr_2:Clone()
			clone.Anchored = true
			clone.Orientation = Vector3.new(clone.Orientation.X + arg4.Delta.Y, clone.Orientation.Y + arg4.Delta.X, clone.Orientation.Z)
			Attachment_upvr_2.WorldOrientation = clone:WaitForChild("PartOrient").WorldOrientation
			clone:Destroy()
		end
	end
end
UserInputService_upvr.InputChanged:Connect(function(arg1, arg2) -- Line 335
	--[[ Upvalues[4]:
		[1]: var46_upvw (read and write)
		[2]: var45_upvw (read and write)
		[3]: Part_upvr_2 (readonly)
		[4]: Attachment_upvr_2 (readonly)
	]]
	-- KONSTANTERROR: [0] 1. Error Block 1 start (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [0] 1. Error Block 1 end (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [9] 6. Error Block 3 start (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [9] 6. Error Block 3 end (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [12] 8. Error Block 4 start (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [12] 8. Error Block 4 end (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [15] 10. Error Block 5 start (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [15] 10. Error Block 5 end (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [17] 11. Error Block 6 start (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [17] 11. Error Block 6 end (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [71] 44. Error Block 15 start (CF ANALYSIS FAILED)
	if arg1.UserInputType == Enum.UserInputType.Touch and var46_upvw == true and var45_upvw == true and arg2 == false and arg1.KeyCode ~= Enum.KeyCode.Thumbstick2 then
		local clone_2 = Part_upvr_2:Clone()
		clone_2.Anchored = true
		clone_2.Orientation = Vector3.new(clone_2.Orientation.X + arg1.Delta.Y, clone_2.Orientation.Y + arg1.Delta.X, clone_2.Orientation.Z)
		Attachment_upvr_2.WorldOrientation = clone_2:WaitForChild("PartOrient").WorldOrientation
		clone_2:Destroy()
	end
	-- KONSTANTERROR: [71] 44. Error Block 15 end (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [138] 84. Error Block 14 start (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [138] 84. Error Block 14 end (CF ANALYSIS FAILED)
end)
local function distanceChangeScrolling_upvr(arg1, arg2, arg3) -- Line 345, Named "distanceChangeScrolling"
	--[[ Upvalues[3]:
		[1]: var46_upvw (read and write)
		[2]: ExtendGrabLine_upvr (readonly)
		[3]: var47_upvw (read and write)
	]]
	if var46_upvw == true then
		if arg3.Position.Z < 0 then
			local ceiled = math.ceil(distance + arg3.Position.Z * 2)
			if ceiled < 3 then
				distance = 3 -- Setting global
			else
				distance = ceiled -- Setting global
			end
			ExtendGrabLine_upvr:FireServer(distance)
			return
		end
		if 0 < arg3.Position.Z then
			local floored = math.floor(distance + arg3.Position.Z * 2)
			if var47_upvw < floored then
				distance = var47_upvw -- Setting global
			else
				distance = floored -- Setting global
			end
			ExtendGrabLine_upvr:FireServer(distance)
		end
	end
end
local function distanceChangeButtonToggle_upvr(arg1, arg2, arg3) -- Line 367, Named "distanceChangeButtonToggle"
	--[[ Upvalues[2]:
		[1]: var49_upvw (read and write)
		[2]: var50_upvw (read and write)
	]]
	if arg2 == Enum.UserInputState.Begin then
		if arg1 == "ZoomOut" then
			var49_upvw = true
			var50_upvw = false
			return
		end
	end
	if arg2 == Enum.UserInputState.End and arg1 == "ZoomOut" or arg2 == Enum.UserInputState.Cancel and arg1 == "ZoomOut" then
		var49_upvw = false
		var50_upvw = false
	else
		if arg2 == Enum.UserInputState.Begin and arg1 == "ZoomIn" then
			var50_upvw = true
			var49_upvw = false
			return
		end
		if arg2 == Enum.UserInputState.End and arg1 == "ZoomIn" or arg2 == Enum.UserInputState.Cancel and arg1 == "ZoomIn" then
			var50_upvw = false
			var49_upvw = false
		end
	end
end
ReplicatedStorage.GrabEvents.EndGrabEarly.OnClientEvent:Connect(function() -- Line 383
	--[[ Upvalues[3]:
		[1]: var46_upvw (read and write)
		[2]: var29_upvw (read and write)
		[3]: endGrab_upvr (readonly)
	]]
	if var46_upvw == true then
		var46_upvw = false
		if var29_upvw then
			endGrab_upvr("Throw")
		end
	end
end)
Humanoid_upvr.Died:Connect(function() -- Line 392
	--[[ Upvalues[1]:
		[1]: endGrab_upvr (readonly)
	]]
	endGrab_upvr("Throw")
end)
local var141_upvw = false
script.LowQualityMode.Event:Connect(function() -- Line 398
	--[[ Upvalues[1]:
		[1]: var141_upvw (read and write)
	]]
	var141_upvw = true
end)
local GrabParts_upvr = game:GetService("ReplicatedFirst"):WaitForChild("GrabParts")
local CreateGrabLine_upvr = ReplicatedStorage.GrabEvents.CreateGrabLine
local SetNetworkOwner_upvr = ReplicatedStorage.GrabEvents.SetNetworkOwner
local function grab_upvr(arg1, arg2, arg3) -- Line 402, Named "grab"
	--[[ Upvalues[32]:
		[1]: Humanoid_upvr (readonly)
		[2]: var46_upvw (read and write)
		[3]: endGrab_upvr (readonly)
		[4]: var15_upvw (read and write)
		[5]: CrosshairsFrame_upvr (readonly)
		[6]: var16_upvw (read and write)
		[7]: ContextActionService_upvr (readonly)
		[8]: var21_upvw (read and write)
		[9]: GrabNotifyEvent_upvr (readonly)
		[10]: module_upvr_2 (readonly)
		[11]: throw_upvr (readonly)
		[12]: distanceChangeButtonToggle_upvr (readonly)
		[13]: distanceChangeScrolling_upvr (readonly)
		[14]: rotate_upvr (readonly)
		[15]: ActionEvent_upvr (readonly)
		[16]: CurrentCamera_upvr (readonly)
		[17]: var47_upvw (read and write)
		[18]: var30_upvw (read and write)
		[19]: var29_upvw (read and write)
		[20]: GrabParts_upvr (readonly)
		[21]: var141_upvw (read and write)
		[22]: CreateGrabLine_upvr (readonly)
		[23]: ExtendGrabLine_upvr (readonly)
		[24]: Players_upvr (readonly)
		[25]: Head_upvr (readonly)
		[26]: Attachment_upvr_2 (readonly)
		[27]: Attachment_upvr (readonly)
		[28]: SetNetworkOwner_upvr (readonly)
		[29]: var51_upvw (read and write)
		[30]: RunService_upvr (readonly)
		[31]: drag_upvr (readonly)
		[32]: distanceChangeButtonMoving_upvr (readonly)
	]]
	if arg1 == "Grab" and arg2 == Enum.UserInputState.Begin and 0 < Humanoid_upvr.Health then
		if var46_upvw == true then
			endGrab_upvr(arg1)
			return
		end
		if var15_upvw then
			CrosshairsFrame_upvr.Size = UDim2.new(0, 7, 0, 7)
			local Position = (var15_upvw.Instance.CFrame * var16_upvw).Position
			ContextActionService_upvr:UnbindAction("Hold")
			var21_upvw = false
			var46_upvw = true
			GrabNotifyEvent_upvr:Fire(var46_upvw)
			module_upvr_2.ChangeColor("Grab", Color3.new(0, 1, 1))
			module_upvr_2.PlaceButton("Throw", throw_upvr)
			module_upvr_2.PlaceButton("ZoomIn", distanceChangeButtonToggle_upvr)
			module_upvr_2.PlaceButton("ZoomOut", distanceChangeButtonToggle_upvr)
			module_upvr_2.PlaceButton("ZoomPC", distanceChangeScrolling_upvr)
			module_upvr_2.PlaceButton("Rotate", rotate_upvr)
			ActionEvent_upvr:Fire("HoldControls", false)
			ActionEvent_upvr:Fire("GrabbingControls", true)
			ActionEvent_upvr:Fire("GrabControls", false)
			distance = (Position - CurrentCamera_upvr.CFrame.Position).Magnitude -- Setting global
			if var47_upvw < distance then
				distance = var47_upvw -- Setting global
			elseif distance < 3 then
				distance = 3 -- Setting global
			end
			var30_upvw = var15_upvw.Instance
			var29_upvw = GrabParts_upvr:Clone()
			if var141_upvw == true then
				var29_upvw.GrabPart.LowQualityGrabPartBall.Transparency = 0
				var29_upvw.GrabPart.Transparency = 1
				var29_upvw.BeamPart.GrabBeam.Segments = 30
			end
			var29_upvw.DragPart.Position = CurrentCamera_upvr.CFrame.LookVector * distance + CurrentCamera_upvr.CFrame.Position
			CreateGrabLine_upvr:FireServer(var15_upvw.Instance, var16_upvw)
			ExtendGrabLine_upvr:FireServer(distance)
			local BeamColor = Players_upvr.LocalPlayer:WaitForChild("BeamColor")
			local FartherReach = Players_upvr.LocalPlayer:FindFirstChild("FartherReach")
			if FartherReach and FartherReach.Value == true then
				var29_upvw.BeamPart.GrabBeam.Texture = "rbxassetid://8933355899"
			end
			for _, v_6 in pairs(var29_upvw:GetDescendants()) do
				if v_6:IsA("BasePart") then
					v_6.Color = BeamColor:WaitForChild("BallColorHolder").Value
				elseif v_6:IsA("Beam") then
					v_6.Color = BeamColor:WaitForChild("ColorSequenceHolder").Color
				end
			end
			if var15_upvw.Instance.Anchored == false then
				var15_upvw.Instance.AssemblyLinearVelocity = Head_upvr.AssemblyLinearVelocity
				var15_upvw.Instance.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
			end
			var29_upvw.DragPart.Anchored = true
			var29_upvw.GrabPart.GrabAttach.Orientation = Attachment_upvr_2.WorldOrientation
			var29_upvw.DragPart.DragAttach.WorldOrientation = Attachment_upvr_2.WorldOrientation
			var29_upvw.GrabPart.WeldConstraint.Part1 = var15_upvw.Instance
			var29_upvw.GrabPart.Position = Position
			var29_upvw.GrabPart.Anchored = false
			var29_upvw.BeamPart.Anchored = true
			var29_upvw.BeamPart.GrabBeam.Attachment0 = Attachment_upvr
			var29_upvw.Parent = workspace
			SetNetworkOwner_upvr:FireServer(var15_upvw.Instance, CurrentCamera_upvr.CFrame)
			var51_upvw = false
			RunService_upvr:BindToRenderStep("dragBinding", Enum.RenderPriority.First.Value, drag_upvr)
			RunService_upvr:BindToRenderStep("buttonDistanceMoving", Enum.RenderPriority.First.Value, distanceChangeButtonMoving_upvr)
			var29_upvw.GrabPart.AttachSound:Play()
			wait()
			if var29_upvw:FindFirstChild("GrabPart") then
				var29_upvw.GrabPart.BeamSound:Play()
			end
		end
	end
end
local var154_upvw
local var155_upvw
local var156_upvw
local var157_upvw
local var158_upvw = false
local var159_upvw
local var160_upvw
local var161_upvw
local var162_upvw = false
local var163_upvw
local tbl_upvw = {}
local function _() -- Line 548, Named "destroyFakeItem"
	--[[ Upvalues[6]:
		[1]: var159_upvw (read and write)
		[2]: var157_upvw (read and write)
		[3]: var156_upvw (read and write)
		[4]: var163_upvw (read and write)
		[5]: var160_upvw (read and write)
		[6]: var162_upvw (read and write)
	]]
	if var159_upvw then
		var157_upvw:Disconnect()
		var156_upvw:Disconnect()
		var163_upvw:Disconnect()
		var159_upvw:Destroy()
		var159_upvw = nil
		var160_upvw = nil
		var162_upvw = false
	end
end
local const_number_upvw = 0
local Use_upvr = game:GetService("ReplicatedStorage").HoldEvents.Use
local function useItem_upvr(arg1, arg2, arg3) -- Line 562, Named "useItem"
	--[[ Upvalues[6]:
		[1]: var158_upvw (read and write)
		[2]: const_number_upvw (read and write)
		[3]: var161_upvw (read and write)
		[4]: Use_upvr (readonly)
		[5]: var162_upvw (read and write)
		[6]: module_upvr_2 (readonly)
	]]
	-- KONSTANTERROR: [0] 1. Error Block 1 start (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [0] 1. Error Block 1 end (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [4] 3. Error Block 2 start (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [4] 3. Error Block 2 end (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [20] 16. Error Block 6 start (CF ANALYSIS FAILED)
	var162_upvw = true
	module_upvr_2.ChangeColor("HoldUse", Color3.new(0, 1, 1))
	-- KONSTANTERROR: [20] 16. Error Block 6 end (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [41] 33. Error Block 7 start (CF ANALYSIS FAILED)
	wait(var161_upvw.HoldPart:GetAttribute("DestroysSelfTime") - 0.1)
	-- KONSTANTERROR: [41] 33. Error Block 7 end (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [56] 44. Error Block 8 start (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [56] 44. Error Block 8 end (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [61] 49. Error Block 10 start (CF ANALYSIS FAILED)
	var162_upvw = false
	module_upvr_2.ChangeColor("HoldUse")
	-- KONSTANTERROR: [61] 49. Error Block 10 end (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [68] 55. Error Block 11 start (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [68] 55. Error Block 11 end (CF ANALYSIS FAILED)
end
local ClientHoldPositions_upvr = require(script.ClientHoldPositions)
local function holdOrientation_upvr(arg1, arg2, arg3) -- Line 592, Named "holdOrientation"
	--[[ Upvalues[5]:
		[1]: ClientHoldPositions_upvr (readonly)
		[2]: var162_upvw (read and write)
		[3]: Humanoid_upvr (readonly)
		[4]: CurrentCamera_upvr (readonly)
		[5]: var155_upvw (read and write)
	]]
	local any_HoldItem_result1, any_HoldItem_result2 = ClientHoldPositions_upvr.HoldItem(var162_upvw, Humanoid_upvr, arg2, CurrentCamera_upvr, arg3, var155_upvw, arg1)
	arg2:SetPrimaryPartCFrame(CFrame.new(any_HoldItem_result1.Position) * arg3.CFrame.Rotation)
	arg2:SetPrimaryPartCFrame(arg3.CFrame:Lerp(any_HoldItem_result2, 0.1))
	var155_upvw = CurrentCamera_upvr.CFrame.Rotation
end
local function dropItem_upvr(arg1, arg2, arg3) -- Line 602, Named "dropItem"
	--[[ Upvalues[14]:
		[1]: var158_upvw (read and write)
		[2]: var161_upvw (read and write)
		[3]: var159_upvw (read and write)
		[4]: var160_upvw (read and write)
		[5]: var157_upvw (read and write)
		[6]: var156_upvw (read and write)
		[7]: var163_upvw (read and write)
		[8]: var162_upvw (read and write)
		[9]: Players_upvr (readonly)
		[10]: CurrentCamera_upvr (readonly)
		[11]: tbl_upvw (read and write)
		[12]: ContextActionService_upvr (readonly)
		[13]: ActionEvent_upvr (readonly)
		[14]: var154_upvw (read and write)
	]]
	-- KONSTANTERROR: [0] 1. Error Block 1 start (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [0] 1. Error Block 1 end (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [4] 3. Error Block 2 start (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [4] 3. Error Block 2 end (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [7] 5. Error Block 3 start (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [7] 5. Error Block 3 end (CF ANALYSIS FAILED)
end
local var170_upvw = false
local function pickUp_upvr(arg1, arg2, arg3) -- Line 673, Named "pickUp"
	--[[ Upvalues[22]:
		[1]: var161_upvw (read and write)
		[2]: var158_upvw (read and write)
		[3]: var154_upvw (read and write)
		[4]: var159_upvw (read and write)
		[5]: var157_upvw (read and write)
		[6]: var156_upvw (read and write)
		[7]: var163_upvw (read and write)
		[8]: var160_upvw (read and write)
		[9]: var162_upvw (read and write)
		[10]: tbl_upvw (read and write)
		[11]: Character_upvr (readonly)
		[12]: endGrab_upvr (readonly)
		[13]: ContextActionService_upvr (readonly)
		[14]: var170_upvw (read and write)
		[15]: module_upvr_2 (readonly)
		[16]: useItem_upvr (readonly)
		[17]: dropItem_upvr (readonly)
		[18]: ActionEvent_upvr (readonly)
		[19]: var155_upvw (read and write)
		[20]: CurrentCamera_upvr (readonly)
		[21]: RunService_upvr (readonly)
		[22]: holdOrientation_upvr (readonly)
	]]
	if var161_upvw == nil then
		if arg2 == Enum.UserInputState.Begin and var158_upvw == false then
			var158_upvw = true
			local var177_upvr = var154_upvw
			if var159_upvw then
				var157_upvw:Disconnect()
				var156_upvw:Disconnect()
				var163_upvw:Disconnect()
				var159_upvw:Destroy()
				var159_upvw = nil
				var160_upvw = nil
				var162_upvw = false
			end
			var159_upvw = var154_upvw:Clone()
			var160_upvw = var159_upvw.PrimaryPart
			var159_upvw.PrimaryPart = var159_upvw.HoldPart
			for _, v_7 in pairs(var154_upvw:GetDescendants()) do
				if v_7:IsA("BasePart") then
					table.insert(tbl_upvw, {
						PartReference = v_7;
						CanCollide = v_7.CanCollide;
						CanTouch = v_7.CanTouch;
						CanQuery = v_7.CanQuery;
						Transparency = v_7.Transparency;
					})
				elseif v_7:IsA("Decal") or v_7:IsA("Texture") then
					table.insert(tbl_upvw, {
						PartReference = v_7;
						Transparency = v_7.Transparency;
					})
				elseif v_7:IsA("SurfaceGui") then
					table.insert(tbl_upvw, {
						PartReference = v_7;
						Enabled = v_7.Enabled;
					})
				elseif v_7:IsA("ParticleEmitter") then
					table.insert(tbl_upvw, {
						PartReference = v_7;
						IsEnabled = v_7.Enabled;
					})
				end
			end
			if var177_upvr.HoldPart.HoldItemRemoteFunction:InvokeServer(var177_upvr, Character_upvr) == true then
				endGrab_upvr("Throw")
				ContextActionService_upvr:UnbindAction("Grab")
				var170_upvw = false
				var161_upvw = var177_upvr
				ContextActionService_upvr:UnbindAction("Hold")
				module_upvr_2.PlaceButton("HoldUse", useItem_upvr)
				module_upvr_2.PlaceButton("HoldDrop", dropItem_upvr)
				ActionEvent_upvr:Fire("HoldControls", false)
				ActionEvent_upvr:Fire("HoldingControls", true)
				local HoldPart_upvr = var159_upvw:WaitForChild("HoldPart")
				HoldPart_upvr:WaitForChild("RigidConstraint"):Destroy()
				var159_upvw.Parent = workspace
				var155_upvw = CurrentCamera_upvr.CFrame.Rotation
				var156_upvw = var177_upvr.AncestryChanged:Connect(function() -- Line 752
					--[[ Upvalues[12]:
						[1]: var177_upvr (readonly)
						[2]: var158_upvw (copied, read and write)
						[3]: var159_upvw (copied, read and write)
						[4]: var157_upvw (copied, read and write)
						[5]: var156_upvw (copied, read and write)
						[6]: var163_upvw (copied, read and write)
						[7]: var160_upvw (copied, read and write)
						[8]: var162_upvw (copied, read and write)
						[9]: ContextActionService_upvr (copied, readonly)
						[10]: ActionEvent_upvr (copied, readonly)
						[11]: var161_upvw (copied, read and write)
						[12]: var154_upvw (copied, read and write)
					]]
					if var177_upvr:IsDescendantOf(workspace) == false then
						var158_upvw = true
						if var159_upvw then
							var157_upvw:Disconnect()
							var156_upvw:Disconnect()
							var163_upvw:Disconnect()
							var159_upvw:Destroy()
							var159_upvw = nil
							var160_upvw = nil
							var162_upvw = false
						end
						ContextActionService_upvr:UnbindAction("HoldUse")
						ContextActionService_upvr:UnbindAction("HoldDrop")
						ActionEvent_upvr:Fire("HoldControls", false)
						ActionEvent_upvr:Fire("HoldingControls", false)
						var161_upvw = nil
						var154_upvw = nil
						var158_upvw = false
					end
				end)
				var157_upvw = var177_upvr.DescendantRemoving:Connect(function(arg1_2) -- Line 768
					--[[ Upvalues[1]:
						[1]: var159_upvw (copied, read and write)
					]]
					if arg1_2.Name == "EdiblePart" then
						for _, v_8 in pairs(var159_upvw:GetDescendants()) do
							if v_8.Name == "EdiblePart" then
								v_8:Destroy()
							end
						end
					end
				end)
				for _, v_9 in pairs(var177_upvr:GetDescendants()) do
					if v_9:IsA("BasePart") then
						v_9.CanTouch = false
						v_9.CanQuery = false
						v_9.CanCollide = false
						v_9.Transparency = 1
					elseif v_9:IsA("Decal") or v_9:IsA("Texture") then
						v_9.Transparency = 1
					elseif v_9:IsA("ParticleEmitter") then
						v_9.Enabled = false
					elseif v_9:IsA("SurfaceGui") then
						v_9.Enabled = false
					end
				end
				for _, v_10 in pairs(var159_upvw:GetDescendants()) do
					if v_10:IsA("BasePart") then
						v_10.CanTouch = false
						v_10.CanQuery = false
						v_10.CanCollide = false
						v_10.Massless = true
						v_10.Anchored = true
					elseif v_10.Name == "FoodSizzling" then
						v_10:Destroy()
					end
				end
				var159_upvw:SetPrimaryPartCFrame(CurrentCamera_upvr.CFrame + CurrentCamera_upvr.CFrame.LookVector * 1.25 + CurrentCamera_upvr.CFrame.UpVector * -0.75)
				var163_upvw = RunService_upvr.RenderStepped:Connect(function(arg1_3) -- Line 814
					--[[ Upvalues[3]:
						[1]: holdOrientation_upvr (copied, readonly)
						[2]: var159_upvw (copied, read and write)
						[3]: HoldPart_upvr (readonly)
					]]
					holdOrientation_upvr(arg1_3, var159_upvw, HoldPart_upvr)
				end)
			else
				HoldPart_upvr = var159_upvw:Destroy()
				HoldPart_upvr()
				HoldPart_upvr = nil
				var159_upvw = HoldPart_upvr
				HoldPart_upvr = {}
				tbl_upvw = HoldPart_upvr
			end
			HoldPart_upvr = false
			var158_upvw = HoldPart_upvr
		end
	end
end
Humanoid_upvr.Died:Connect(function() -- Line 830
	--[[ Upvalues[2]:
		[1]: var161_upvw (read and write)
		[2]: dropItem_upvr (readonly)
	]]
	if var161_upvw then
		dropItem_upvr(var161_upvw)
	end
end)
module_upvr_2.PlaceButton("Grab", grab_upvr)
var170_upvw = true
local var201_upvw = var170_upvw
local var202_upvw = true
local module_upvr = require(Players_upvr.LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("RaycastModule"))
game:GetService("RunService").Stepped:Connect(function() -- Line 857
	--[[ Upvalues[18]:
		[1]: var46_upvw (read and write)
		[2]: var202_upvw (read and write)
		[3]: var161_upvw (read and write)
		[4]: module_upvr (readonly)
		[5]: LocalPlayer_upvr (readonly)
		[6]: var47_upvw (read and write)
		[7]: var22_upvw (read and write)
		[8]: var201_upvw (read and write)
		[9]: module_upvr_2 (readonly)
		[10]: grab_upvr (readonly)
		[11]: ActionEvent_upvr (readonly)
		[12]: CrosshairsFrame_upvr (readonly)
		[13]: var15_upvw (read and write)
		[14]: var16_upvw (read and write)
		[15]: var21_upvw (read and write)
		[16]: var154_upvw (read and write)
		[17]: pickUp_upvr (readonly)
		[18]: ContextActionService_upvr (readonly)
	]]
	-- KONSTANTERROR: [0] 1. Error Block 1 start (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [0] 1. Error Block 1 end (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [3] 3. Error Block 2 start (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [3] 3. Error Block 2 end (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [233] 188. Error Block 25 start (CF ANALYSIS FAILED)
	var21_upvw = false
	ContextActionService_upvr:UnbindAction("Hold")
	ActionEvent_upvr:Fire("HoldControls", false)
	module_upvr_2.PlaceButton("Grab", grab_upvr)
	ActionEvent_upvr:Fire("GrabControls", true)
	var201_upvw = true
	var154_upvw = nil
	do
		return
	end
	-- KONSTANTERROR: [233] 188. Error Block 25 end (CF ANALYSIS FAILED)
	-- KONSTANTERROR: [263] 214. Error Block 29 start (CF ANALYSIS FAILED)
	if var22_upvw == false then
		var22_upvw = true
		module_upvr_2.GrayOutButton("Grab", true)
		module_upvr_2.ChangeColor("Grab", Color3.new(0, 1, 1))
		ActionEvent_upvr:Fire("GrabControls", false)
	end
	-- KONSTANTERROR: [263] 214. Error Block 29 end (CF ANALYSIS FAILED)
end)
script:WaitForChild("ToggleMobileButtonVisibility").Event:Connect(function(arg1) -- Line 968
	--[[ Upvalues[9]:
		[1]: var202_upvw (read and write)
		[2]: ActionEvent_upvr (readonly)
		[3]: dropItem_upvr (readonly)
		[4]: endGrab_upvr (readonly)
		[5]: ContextActionService_upvr (readonly)
		[6]: var21_upvw (read and write)
		[7]: var201_upvw (read and write)
		[8]: module_upvr_2 (readonly)
		[9]: grab_upvr (readonly)
	]]
	if arg1 == false then
		var202_upvw = false
		ActionEvent_upvr:Fire("RotatingControls", false)
		ActionEvent_upvr:Fire("RotateControls", false)
		ActionEvent_upvr:Fire("GrabbingControls", false)
		ActionEvent_upvr:Fire("GrabControls", false)
		ActionEvent_upvr:Fire("HoldControls", false)
		ActionEvent_upvr:Fire("HoldingControls", false)
		dropItem_upvr()
		endGrab_upvr("Throw")
		ContextActionService_upvr:UnbindAction("Grab")
		ContextActionService_upvr:UnbindAction("Throw")
		ContextActionService_upvr:UnbindAction("ZoomPC")
		ContextActionService_upvr:UnbindAction("ZoomIn")
		ContextActionService_upvr:UnbindAction("ZoomOut")
		ContextActionService_upvr:UnbindAction("Rotate")
		ContextActionService_upvr:UnbindAction("Hold")
		ContextActionService_upvr:UnbindAction("HoldUse")
		ContextActionService_upvr:UnbindAction("HoldDrop")
		var21_upvw = false
		var201_upvw = false
	else
		module_upvr_2.PlaceButton("Grab", grab_upvr)
		ActionEvent_upvr:Fire("GrabControls", true)
		var201_upvw = true
		var202_upvw = true
	end
end)
