local vgs = {
    MS  =  game:GetService("Players").LocalPlayer:GetMouse(),
	VIM =  game:GetService("VirtualInputManager"),
    p   =  game:GetService("Players").LocalPlayer,
    UIS =  game:GetService("UserInputService"),
    TS  =  game:GetService("TweenService"),
    HS  =  game:GetService("HttpService"),
    RS  =  game:GetService("RunService"),
    ps  =  game:GetService("Players")
}

local rate = 1 / 200 
local acc = 0

local OrionLib = {
    elmnts = {},
    ThemeObjects = {},
    Connections = {},
    Flags = {},
    Themes = {},
    SelectedTheme = "Default",
    UMouseMode = "FreeMouse",
    Folder = nil,
    SaveCfg = false,
    Toggles = {},
    Dropdowns = {}
}

function OrionLib:GenTheme(mainColor)
    local r, g, b = mainColor.R * 255, mainColor.G * 255, mainColor.B * 255
    local lum = 0.299 * r + 0.587 * g + 0.114 * b
    local dark = lum < 128
    local t = {Main = mainColor}
    
    if dark then
        t.Second = Color3.fromRGB(math.clamp(r * 1.12, 0, 255), math.clamp(g * 1.12, 0, 255), math.clamp(b * 1.12, 0, 255))
        t.Stroke = Color3.fromRGB(math.clamp(r * 1.45, 0, 255), math.clamp(g * 1.45, 0, 255), math.clamp(b * 1.45, 0, 255))
        t.Divider = Color3.fromRGB(math.clamp(r * 1.28, 0, 255), math.clamp(g * 1.28, 0, 255), math.clamp(b * 1.28, 0, 255))
        t.Text = Color3.fromRGB(240, 240, 242)
        t.TextDark = Color3.fromRGB(155, 155, 160)
        t.Accent = Color3.fromRGB(math.clamp(r * 1.85, 0, 255), math.clamp(g * 1.85, 0, 255), math.clamp(b * 1.85, 0, 255))
    else
        t.Second = Color3.fromRGB(math.clamp(r * 0.94, 0, 255), math.clamp(g * 0.94, 0, 255), math.clamp(b * 0.94, 0, 255))
        t.Stroke = Color3.fromRGB(math.clamp(r * 0.75, 0, 255), math.clamp(g * 0.75, 0, 255), math.clamp(b * 0.75, 0, 255))
        t.Divider = Color3.fromRGB(math.clamp(r * 0.85, 0, 255), math.clamp(g * 0.85, 0, 255), math.clamp(b * 0.85, 0, 255))
        t.Text = Color3.fromRGB(35, 35, 38)
        t.TextDark = Color3.fromRGB(110, 110, 115)
        t.Accent = Color3.fromRGB(math.clamp(r * 0.72, 0, 255), math.clamp(g * 0.72, 0, 255), math.clamp(b * 0.72, 0, 255))
    end
    
    return t
end

OrionLib.Themes.Default = OrionLib:GenTheme(Color3.fromRGB(31, 20, 37))
OrionLib.CurrentTheme = OrionLib.Themes.Default

getgenv().gethui = function() return game.CoreGui end

local Orion = Instance.new("ScreenGui", gethui())
Orion.Name = "OrionLib"

if gethui then
	for _, Interface in ipairs(gethui():GetChildren()) do
		if Interface.Name == Orion.Name and Interface ~= Orion then
			Interface:Destroy()
		end
	end
else
	for _, Interface in ipairs(game.CoreGui:GetChildren()) do
		if Interface.Name == Orion.Name and Interface ~= Orion then
			Interface:Destroy()
		end
	end
end

function OrionLib:IsRunning()
	if gethui then
		return Orion.Parent == gethui()
	else
		return Orion.Parent == game:GetService("CoreGui")
	end
end

function OrionLib:DestroyLib()
    for _, Connection in OrionLib.Connections do
        if Connection.Connected then
            Connection:Disconnect()
        end
    end
    table.clear(OrionLib.Connections)
    
    Orion:Destroy()
end

task.spawn(function()
	while (OrionLib:IsRunning()) do 
		wait()
	end
	
	OrionLib:DestroyLib()
end)

function AddConnection(Signal, Function)
    if not OrionLib:IsRunning() then
        return
    end
    
    local SignalConnect = Signal:Connect(Function)
    table.insert(OrionLib.Connections, SignalConnect)
    
    return SignalConnect, function()
        local index = table.find(OrionLib.Connections, SignalConnect)
        if index then
            table.remove(OrionLib.Connections, index)
        end
        if SignalConnect.Connected then
            SignalConnect:Disconnect()
        end
    end
end

function MakeDraggable(DragPoint, Main)
	pcall(function()
		local Dragging, DragInput, MousePos, FramePos = false
		AddConnection(DragPoint.InputBegan, function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				Dragging = true
				MousePos = Input.Position
				FramePos = Main.Position

				Input.Changed:Connect(function()
					if Input.UserInputState == Enum.UserInputState.End then
						Dragging = false
					end
				end)
			end
		end)
		AddConnection(DragPoint.InputChanged, function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseMovement then
				DragInput = Input
			end
		end)
		AddConnection(vgs.UIS.InputChanged, function(Input)
			if Input == DragInput and Dragging then
				local Delta = Input.Position - MousePos
				vgs.TS:Create(Main, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position  = UDim2.new(FramePos.X.Scale,FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)}):Play()
			end
		end)
	end)
end    

function Create(Name, Properties, Children)
	local Object = Instance.new(Name)
	for i, v in next, Properties or {} do
		Object[i] = v
	end
	for i, v in next, Children or {} do
		v.Parent = Object
	end
	return Object
end

function CreateElement(ElementName, ElementFunction)
	OrionLib.elmnts[ElementName] = function(...)
		return ElementFunction(...)
	end
end

function AddItemTable(Table, Item, Value)
	local Item = tostring(Item)
	local Count = 1

	while Table[Item] do
		Count = Count + 1
		Item = string.format('%s-%d', Item, Count)
	end

	Table[Item] = Value
end


function MakeElement(ElementName, ...)
	local NewElement = OrionLib.elmnts[ElementName](...)
	return NewElement
end

function SetProps(Element, Props)
	table.foreach(Props, function(Property, Value)
		Element[Property] = Value
	end)
	return Element
end

local Total = {
	SetChildren = 0;
	AddThemeObject = 0;
}

function SetChildren(Element, Children)
	Total.SetChildren = Total.SetChildren + 1
	table.foreach(Children, function(_, Child)
		Child.Parent = Element
	end)
	return Element
end

function Round(Number, Factor)
    if not Factor or Factor == 0 then Factor = 1 end
    local Result = math.floor(Number/Factor + (math.sign(Number) * 0.5)) * Factor
    if Result < 0 then Result = Result + Factor end
    return Result
end

function ReturnProperty(Object)
    if Object:IsA("TextLabel") or Object:IsA("TextBox") then
        return "TextColor3"
    end 
    if Object:IsA("ScrollingFrame") then
        return "ScrollBarImageColor3"
    end 
    if Object:IsA("UIStroke") then
        return "Color"
    end   
    if Object:IsA("ImageLabel") or Object:IsA("ImageButton") then
        return "ImageColor3"
    end
    if Object:IsA("Frame") or Object:IsA("TextButton") then
        return "BackgroundColor3"
    end 
    
    return nil
end

function AddThemeObject(Object, Type)
    if not OrionLib.ThemeObjects[Type] then
        OrionLib.ThemeObjects[Type] = {}
    end    
    
    Total.AddThemeObject = Total.AddThemeObject + 1
    table.insert(OrionLib.ThemeObjects[Type], Object)
    
    local themeColor = OrionLib.Themes[OrionLib.SelectedTheme][Type]
    local property = ReturnProperty(Object)
    
    if themeColor and property and Object[property] ~= nil then
        Object[property] = themeColor
    end
    
    return Object
end  

local resizebtt = Instance.new("Frame")

function PackColor(Color)
	return {R = Color.R * 255, G = Color.G * 255, B = Color.B * 255}
end    

function UnpackColor(Color)
	return Color3.fromRGB(Color.R, Color.G, Color.B)
end

function LoadCfg(Config)
    local Data = vgs.HS:JSONDecode(Config)
    table.foreach(Data, function(a,b)
        if OrionLib.Flags[a] then
            task.spawn(function() 
                if OrionLib.Flags[a].Type == "Colorpicker" then
                    OrionLib.Flags[a]:Set(UnpackColor(b))
                elseif OrionLib.Flags[a].Type == "PBind" then  
                    if type(b) == "table" then
                        OrionLib.Flags[a]:Set(b.x, b.y, b.z)
                    end
                else
                    OrionLib.Flags[a]:Set(b)
                end    
            end)
        end
    end)
end

function SaveCfg(Name)
    local Data = {}
    for i,v in pairs(OrionLib.Flags) do
        if v.Save then
            if v.Type == "Colorpicker" then
                Data[i] = PackColor(v.Value)
            elseif v.Type == "PBind" then
                Data[i] = {x = v.ValueX, y = v.ValueY, z = v.ValueZ} 
            else
                Data[i] = v.Value
            end
        end	
    end
    
    if writefile then
        writefile(OrionLib.Folder .. "/" .. Name .. ".txt", tostring(vgs.HS:JSONEncode(Data)))
    end
end

local WhitelistedMouse = {Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2,Enum.UserInputType.MouseButton3}
local BlacklistedKeys = {Enum.KeyCode.Unknown,Enum.KeyCode.W,Enum.KeyCode.A,Enum.KeyCode.S,Enum.KeyCode.D,Enum.KeyCode.Up,Enum.KeyCode.Left,Enum.KeyCode.Down,Enum.KeyCode.Right,Enum.KeyCode.Slash,Enum.KeyCode.Tab,Enum.KeyCode.Backspace,Enum.KeyCode.Escape}
local FreeMouse = Create("TextButton", {
    Name = "FMouse", 
    Size = UDim2.new(0, 100, 0, 50),  
    BackgroundTransparency = 1,        
    Text = "",                        
    Position = UDim2.new(0, 100, 0, 100),  
    Modal = false,                    
    Parent = Orion,                   
    Visible = true                   
})
local mouselock = false
local zmin = 10
local zmax = 300
local nz = 0.5

function UnlockMouse(Value)
    if OrionLib.UMouseMode == "ThirdPerson" then
        if Value then
            mouselock = true
            vgs.p.CameraMode = Enum.CameraMode.LockFirstPerson
            task.wait()
            vgs.p.CameraMode = Enum.CameraMode.Classic
            vgs.UIS.MouseBehavior = Enum.MouseBehavior.Default
            vgs.UIS.MouseIconEnabled = true
            vgs.p.CameraMaxZoomDistance = zmax
            vgs.p.CameraMinZoomDistance = zmin
        else
            mouselock = false
            vgs.UIS.MouseIconEnabled = false
            vgs.UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
            vgs.p.CameraMaxZoomDistance = nz
            vgs.p.CameraMinZoomDistance = nz
            vgs.p.CameraMode = Enum.CameraMode.LockFirstPerson
            FreeMouse.Modal = false
        end
    elseif OrionLib.UMouseMode == "FreeMouse" then
        if Value then 
            vgs.p.CameraMode = Enum.CameraMode.Classic
            vgs.p.CameraMinZoomDistance = nz
            vgs.p.CameraMaxZoomDistance = nz
            vgs.UIS.MouseBehavior = Enum.MouseBehavior.Default
            vgs.UIS.MouseIconEnabled = true
            FreeMouse.Modal = Value
        else
            vgs.p.CameraMode = Enum.CameraMode.LockFirstPerson
            vgs.p.CameraMinZoomDistance = nz
            vgs.p.CameraMaxZoomDistance = nz
            vgs.UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
            vgs.UIS.MouseIconEnabled = false
            FreeMouse.Modal = Value
        end
    end
end

function CheckKey(Table, Key)
	for _, v in next, Table do
		if v == Key then
			return true
		end
	end
end

CreateElement("Corner", function(Scale, Offset)
	local Corner = Create("UICorner", {
		CornerRadius = UDim.new(Scale or 0, Offset or 10)
	})
	return Corner
end)

CreateElement("Stroke", function(Color, Thickness)
	local Stroke = Create("UIStroke", {
		Color = Color or Color3.fromRGB(255, 255, 255),
		Thickness = Thickness or 1
	})
	return Stroke
end)

CreateElement("List", function(Scale, Offset)
	local List = Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(Scale or 0, Offset or 0)
	})
	return List
end)

CreateElement("Padding", function(Bottom, Left, Right, Top)
	local Padding = Create("UIPadding", {
		PaddingBottom = UDim.new(0, Bottom or 4),
		PaddingLeft = UDim.new(0, Left or 4),
		PaddingRight = UDim.new(0, Right or 4),
		PaddingTop = UDim.new(0, Top or 4)
	})
	return Padding
end)

CreateElement("TFrame", function()
	local TFrame = Create("Frame", {
		BackgroundTransparency = 1
	})
	return TFrame
end)

CreateElement("Frame", function(Color)
	local Frame = Create("Frame", {
		BackgroundColor3 = Color or Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0
	})
	return Frame
end)

CreateElement("RoundFrame", function(Color, Scale, Offset)
	local Frame = Create("Frame", {
		BackgroundColor3 = Color or Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0
	}, {
		Create("UICorner", {
			CornerRadius = UDim.new(Scale, Offset)
		})
	})
	return Frame
end)

CreateElement("Button", function()
	local Button = Create("TextButton", {
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0
	})
	return Button
end)

CreateElement("ScrollFrame", function(Color, Width)
	local ScrollFrame = Create("ScrollingFrame", {
		BackgroundTransparency = 1,
		MidImage = "rbxassetid://7445543667",
		BottomImage = "rbxassetid://7445543667",
		TopImage = "rbxassetid://7445543667",
		ScrollBarImageColor3 = Color,
		BorderSizePixel = 0,
		ScrollBarThickness = Width,
		CanvasSize = UDim2.new(0, 0, 0, 0)
	})
	return ScrollFrame
end)

CreateElement("Image", function(ImageID)
	local ImageNew = Create("ImageLabel", {
		Image = ImageID,
		BackgroundTransparency = 1
	})
	return ImageNew
end)

CreateElement("ImageButton", function(ImageID)
	local Image = Create("ImageButton", {
		Image = ImageID,
		BackgroundTransparency = 1
	})
	return Image
end)

CreateElement("Label", function(Text, TextSize, Transparency)
	local Label = Create("TextLabel", {
		Text = Text or "",
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextTransparency = Transparency or 0,
		TextSize = TextSize or 15,
		Font = Enum.Font.Gotham,
		RichText = true,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	return Label
end)

CreateElement("TextBox", function()
	local TextBox = Create("TextBox", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = Enum.Font.Gotham,
		TextSize = 14,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
		Text = "",
		ClearTextOnFocus = false
	})
	return TextBox
end)

local NotificationHolder = SetProps(SetChildren(MakeElement("TFrame"), {
	SetProps(MakeElement("List"), {
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Padding = UDim.new(0, 5)
	})
}), {
	Position = UDim2.new(1, -25, 1, -25),
	Size = UDim2.new(0, 300, 1, -25),
	AnchorPoint = Vector2.new(1, 1),
	Parent = Orion
})

function OrionLib:MakeNotification(NotificationConfig)
	task.spawn(function()
		NotificationConfig.Name = NotificationConfig.Name or "Notification"
		NotificationConfig.Content = NotificationConfig.Content or "Test"
		NotificationConfig.Image = NotificationConfig.Image or "rbxassetid://4384403532"
		game:GetService("ContentProvider"):PreloadAsync({NotificationConfig.Image})
		NotificationConfig.Time = NotificationConfig.Time or 15

		local NotificationParent = SetProps(MakeElement("TFrame"), {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = NotificationHolder
		})

		local NotificationFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(25, 25, 25), 0, 10), {
			Parent = NotificationParent, 
			Size = UDim2.new(1, 0, 0, 0),
			Position = UDim2.new(1, -55, 0, 0),
			BackgroundTransparency = 0,
			AutomaticSize = Enum.AutomaticSize.Y
		}), {
			MakeElement("Padding", 16, 12, 12, 12),
			AddThemeObject(SetProps(MakeElement("Image", NotificationConfig.Image), {
				Size = UDim2.new(0, 20, 0, 20),
				ImageColor3 = Color3.fromRGB(240, 240, 240),
				Name = "Icon"
			}), "Text"),
			AddThemeObject(SetProps(MakeElement("Label", NotificationConfig.Name, 15), {
				Size = UDim2.new(1, -30, 0, 20),
				Position = UDim2.new(0, 30, 0, 0),
				Font = Enum.Font.GothamBold,
				Name = "Title"
			}), "Text"),
			AddThemeObject(SetProps(MakeElement("Label", NotificationConfig.Content, 14), {
				Size = UDim2.new(1, 0, 0, 0),
				Position = UDim2.new(0, 0, 0, 25),
				Font = Enum.Font.GothamSemibold,
				Name = "Content",
				AutomaticSize = Enum.AutomaticSize.Y,
				TextColor3 = Color3.fromRGB(200, 200, 200),
				TextWrapped = true
			}), "TextDark")
		}), "Second")

		vgs.TS:Create(NotificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 0, 0, 0)}):Play()

		task.wait(NotificationConfig.Time - 0.88)
		vgs.TS:Create(NotificationFrame:WaitForChild("Icon"), TweenInfo.new(0.4, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
		vgs.TS:Create(NotificationFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.6}):Play()
		task.wait(0.3)
		vgs.TS:Create(NotificationFrame.Title, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0.4}):Play()
		vgs.TS:Create(NotificationFrame.Content, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0.5}):Play()
		task.wait(0.05)

		NotificationFrame:TweenPosition(UDim2.new(1, 40, 0, 0),'In','Quint',0.8,true)
		task.wait(1.35)
		NotificationFrame:Destroy()
	end)
end   

function OrionLib:Init()
	if OrionLib.SaveCfg and (isfile and readfile) then	
		pcall(function()
			if isfile(OrionLib.Folder .. "/" .. game.GameId .. ".txt") then
				LoadCfg(readfile(OrionLib.Folder .. "/" .. game.GameId .. ".txt"))
				OrionLib:MakeNotification({
					Name = "Configuration",
					Content = "Auto-loaded configuration for the game " .. game.GameId .. ".",
					Time = 5
				})
			end
		end)		
	end	
end	

function OrionLib:MakeWindow(WindowConfig)
	local FirstTab = true
	local minimized = false
	local Loaded = false
	local UIHidden = false

	WindowConfig = WindowConfig or {}
	WindowConfig.Name = WindowConfig.Name
	WindowConfig.ConfigFolder = WindowConfig.ConfigFolder or WindowConfig.Name
	WindowConfig.SaveConfig = WindowConfig.SaveConfig or false
	WindowConfig.TagText = WindowConfig.TagText or ""
	WindowConfig.HidePremium = WindowConfig.HidePremium or false
	if WindowConfig.IntroEnabled == nil then
		WindowConfig.IntroEnabled = true
	end
	WindowConfig.FreeMouse = WindowConfig.FreeMouse or true
	WindowConfig.Openkey = WindowConfig.Openkey or "M"
	WindowConfig.IntroText = WindowConfig.IntroText or "Orion Library"
	WindowConfig.CloseCallback = WindowConfig.CloseCallback or function() end
	WindowConfig.ShowIcon = WindowConfig.ShowIcon or false
	WindowConfig.Icon = WindowConfig.Icon or "rbxassetid://8834748103"
	WindowConfig.IntroIcon = WindowConfig.IntroIcon or "rbxassetid://8834748103"
	WindowConfig.SearchBar = WindowConfig.SearchBar or nil
	WindowConfig.IconColorChange = WindowConfig.IconColorChange or false
	OrionLib.Folder = WindowConfig.ConfigFolder
	OrionLib.SaveCfg = WindowConfig.SaveConfig

	if WindowConfig.FreeMouse then
		UnlockMouse(true)
	end

	if WindowConfig.SaveConfig then
		if (isfolder and makefolder) and not isfolder(WindowConfig.ConfigFolder) then
			makefolder(WindowConfig.ConfigFolder)
		end	
	end
	local cch = {}
	
	function OrionLib:SetTheme()
		local themeData = self.Themes[self.SelectedTheme]
		if not themeData then return end
		
		local updates = {}
		local count = 0
		
		for typeName, objects in next, self.ThemeObjects do
			local color = themeData[typeName]
			if color then
				local objCount = #objects
				for i = 1, objCount do
					local obj = objects[i]
					if obj and obj.Parent then
						local prop = cch[obj]
						if not prop then
							prop = ReturnProperty(obj)
							if prop then 
								cch[obj] = prop 
							else 
								continue 
							end
						end
						count = count + 1
						updates[count] = {obj, prop, color}
					end
				end
			end
		end
		
		for i = 1, count do
			local data = updates[i]
			data[1][data[2]] = data[3]
		end
		
		if self.Toggles then
			for _, toggle in ipairs(self.Toggles) do
				if toggle and toggle.Box and toggle.Box.Parent then
					local accolor = toggle.uccolor and toggle.ccolor or themeData.Accent
					
					if toggle.Value then
						toggle.Box.BackgroundColor3 = accolor
						if toggle.Box.Stroke then
							toggle.Box.Stroke.Color = accolor
						end
					else
						toggle.Box.BackgroundColor3 = themeData.Divider
						if toggle.Box.Stroke then
							toggle.Box.Stroke.Color = themeData.Stroke
						end
					end
				end
			end
		end
		
		if self.Dropdowns then
			for _, dropdown in ipairs(self.Dropdowns) do
				if dropdown and dropdown.Buttons then
					for value, btn in pairs(dropdown.Buttons) do
						if btn and btn.Parent and btn:FindFirstChild("Checkbox") then
							local sel = table.find(dropdown.Value, value)
							
							btn.Checkbox.BackgroundColor3 = sel and themeData.Accent or themeData.Divider
							if btn.Checkbox:FindFirstChild("Stroke") then
								btn.Checkbox.Stroke.Color = sel and themeData.Accent or themeData.Stroke
							end
						end
					end
				end
			end
		end
		
		if resizebtt then
			resizebtt.BackgroundColor3 = themeData.Main
		end
	end
	
	local TabHolder = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255, 255, 255), 0),
		WindowConfig.SearchBar and {
			Size = UDim2.new(1, 0, 1, -90),
			Position = UDim2.new(0, 0, 0, 40)
		} or {
			Size = UDim2.new(1, 0, 1, -50)
		}),
		{
			MakeElement("List"),
			MakeElement("Padding", 8, 0, 0, 8)
		}), "Divider")

	AddConnection(TabHolder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		TabHolder.CanvasSize = UDim2.new(0, 0, 0, TabHolder.UIListLayout.AbsoluteContentSize.Y + 16)
	end)

	local CloseBtn = SetChildren(SetProps(MakeElement("Button"), {
		Size = UDim2.new(0.5, 0, 1, 0),
		Position = UDim2.new(0.5, 0, 0, 0),
		BackgroundTransparency = 1
	}), {
		AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072725342"), {
			Position = UDim2.new(0, 9, 0, 6),
			Size = UDim2.new(0, 18, 0, 18)
		}), "Text")
	})

	local MinimizeBtn = SetChildren(SetProps(MakeElement("Button"), {
		Size = UDim2.new(0.5, 0, 1, 0),
		BackgroundTransparency = 1
	}), {
		AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072719338"), {
			Position = UDim2.new(0, 9, 0, 6),
			Size = UDim2.new(0, 18, 0, 18),
			Name = "Ico"
		}), "Text")
	})

	local DragPoint = SetProps(MakeElement("TFrame"), {
		Size = UDim2.new(1, 0, 0, 50)
	})

	local ThumbImage = SetProps(MakeElement("Image", "https://www.roblox.com/headshot-thumbnail/image?userId=".. vgs.p.UserId .."&width=420&height=420&format=png"), {
        Size = UDim2.new(1, 0, 1, 0)
    })
    
    local WindowStuff = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 10), {
        Size = UDim2.new(0, 150, 1, -50),
        Position = UDim2.new(0, 0, 0, 50)
    }), {
        AddThemeObject(SetProps(MakeElement("Frame"), {
            Size = UDim2.new(1, 0, 0, 10),
            Position = UDim2.new(0, 0, 0, 0)
        }), "Second"), 
        AddThemeObject(SetProps(MakeElement("Frame"), {
            Size = UDim2.new(0, 10, 1, 0),
            Position = UDim2.new(1, -10, 0, 0)
        }), "Second"), 
        AddThemeObject(SetProps(MakeElement("Frame"), {
            Size = UDim2.new(0, 1, 1, 0),
            Position = UDim2.new(1, -1, 0, 0)
        }), "Stroke"), 
        TabHolder,
        SetChildren(SetProps(MakeElement("TFrame"), {
            Size = UDim2.new(1, 0, 0, 50),
            Position = UDim2.new(0, 0, 1, -50)
        }), {
            AddThemeObject(SetProps(MakeElement("Frame"), {
                Size = UDim2.new(1, 0, 0, 1)
            }), "Stroke"), 
            AddThemeObject(SetChildren(SetProps(MakeElement("Frame"), {
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(0, 32, 0, 32),
                Position = UDim2.new(0, 10, 0.5, 0)
            }), {
                ThumbImage,
                AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://4031889928"), {
                    Size = UDim2.new(1, 0, 1, 0),
                }), "Second"),
                MakeElement("Corner", 1)
            }), "Divider"),
            SetChildren(SetProps(MakeElement("TFrame"), {
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(0, 32, 0, 32),
                Position = UDim2.new(0, 10, 0.5, 0)
            }), {
                AddThemeObject(MakeElement("Stroke"), "Stroke"),
                MakeElement("Corner", 1)
            }),
            AddThemeObject(SetProps(MakeElement("Label", vgs.p.DisplayName, WindowConfig.HidePremium and 14 or 13), {
                Size = UDim2.new(1, -60, 0, 13),
                Position = WindowConfig.HidePremium and UDim2.new(0, 50, 0, 19) or UDim2.new(0, 50, 0, 12),
                Font = Enum.Font.GothamBold,
                ClipsDescendants = true
            }), "Text"),
			AddThemeObject(SetProps(MakeElement("Label", WindowConfig.TagText, 12), {
				Size = UDim2.new(1, -60, 0, 12),
				Position = UDim2.new(0, 50, 1, -25),
				Visible = not WindowConfig.HidePremium
			}), "TextDark")
        }),
    }), "Second")
    
    AddConnection(vgs.p.CharacterAppearanceLoaded, function()
        ThumbImage.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=".. vgs.p.UserId .."&width=420&height=420&format=png&t=".. tick()
    end)
	local Tabs = {}
	
	local SearchSystem = {
		elmnts = {}, 
		results = {},
		isserch = false,
		tabs = {},
		actvtab = nil,
		butts = {}
	}
	
	local function RTab(tabName, containerFrame)
		SearchSystem.tabs[tabName] = containerFrame
	end
	
	local function Rbutton(tabName, tabButton)
		SearchSystem.butts[tabName] = tabButton
		Tabs[tabName] = tabButton
	end
	
	local function Relem(tabName, elementName, elementFrame)
		if not SearchSystem.elmnts[tabName] then
			SearchSystem.elmnts[tabName] = {}
		end
		
		SearchSystem.elmnts[tabName][elementName] = {
			frame = elementFrame,
			originalParent = elementFrame.Parent,
			visible = true
		}
	end

	local function Hlight(frame, highlight)
		if not frame then return end
		
		local glow = frame:FindFirstChild("SearchGlow")
		
		if highlight then
			if not glow then
				glow = Instance.new("UIStroke")
				glow.Name = "SearchGlow"
				glow.Thickness = 1
				glow.Transparency = 0
				glow.Parent = frame
			end
			
			glow.Color = OrionLib.Themes[OrionLib.SelectedTheme].Accent or Color3.fromRGB(0, 162, 255)
			vgs.TS:Create(glow, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Thickness = 2,
				Transparency = 0
			}):Play()
		else
			if glow then
				vgs.TS:Create(glow, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					Transparency = 1
				}):Play()
				task.delay(0.3, function()
					if glow and glow.Parent then
						glow:Destroy()
					end
				end)
			end
		end
	end
	
	local function ClearR()
		for tabName, elements in pairs(SearchSystem.elmnts) do
			for elementName, data in pairs(elements) do
				if data.frame and data.frame.Parent then
					data.frame.Visible = data.visible
					Hlight(data.frame, false)
				end
			end
		end
		
		for tabName, tabFrame in pairs(Tabs) do
			if tabFrame:IsA('TextButton') then
				tabFrame.Visible = true
			end
		end
		
		for _, container in pairs(SearchSystem.tabs) do
			if container then
				for _, c in pairs(container:GetChildren()) do
					if c:IsA("Frame") and c:FindFirstChild("Holder") then
						c.Visible = true
					end
				end
				vgs.TS:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					CanvasPosition = Vector2.new(0, 0)
				}):Play()
			end
		end
		
		SearchSystem.results = {}
		SearchSystem.isserch = false
		SearchSystem.srchTxt = ""
	end
	
	local function Gotab(tab)
		if not SearchSystem.butts[tab] or not SearchSystem.tabs[tab] then
			return
		end
	
		for _, b in pairs(TabHolder:GetChildren()) do
			if b:IsA("TextButton") then
				b.Title.Font = Enum.Font.GothamSemibold
				vgs.TS:Create(b.Ico, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = 0.4}):Play()
				vgs.TS:Create(b.Title, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0.4}):Play()
				if b:FindFirstChild("Highlight") then
					vgs.TS:Create(b.Highlight, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
				end
			end
		end
	
		local tb = SearchSystem.butts[tab]
		vgs.TS:Create(tb.Ico, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = 0}):Play()
		vgs.TS:Create(tb.Title, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
		tb.Title.Font = Enum.Font.GothamBlack
		if tb:FindFirstChild("Highlight") then
			vgs.TS:Create(tb.Highlight, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
		end
	
		local cont = SearchSystem.tabs[tab]
		if cont then
			cont.Visible = true
		end
	
		SearchSystem.actvtab = tab
	
		for _, container in pairs(SearchSystem.tabs) do
			if container ~= cont then
				container.Visible = false
			end
		end
	
		if SearchSystem.isserch then
			local f = nil
			local y = math.huge
	
			for tn, t in pairs(SearchSystem.elmnts) do
				for k, d in pairs(t) do
					if d.frame and d.frame.Parent and not d.frame:FindFirstChild("Holder") then
						local ok = (tn == tab)
						local hit = SearchSystem.results[tn] and SearchSystem.results[tn][k]
						d.frame.Visible = ok and hit
						Hlight(d.frame, ok and hit)
	
						if ok and hit and d.frame.AbsolutePosition.Y < y then
							y = d.frame.AbsolutePosition.Y
							f = d.frame
						end
					end
				end
			end
	
			if cont then
				local q = {}
	
				for _, child in pairs(cont:GetChildren()) do
					if child:IsA("GuiObject") and child.Name ~= "UIListLayout" and child.Name ~= "UIPadding" then
						local sec = child:FindFirstChild("Holder") ~= nil
						if sec then
							table.insert(q, {f = child, s = true})
						elseif child.Visible then
							table.insert(q, {f = child, s = false})
						end
					end
				end
	
				local prev = false
				local spnsecc = false
	
				for _, e in ipairs(q) do
					if e.s then
						local l = e.f:FindFirstChild("TextLabel")
						local n = l and l.Text or ""
						local vazio = n == "" or n:match("^%s*$")
	
						local s = string.lower(SearchSystem.srchTxt or "")
						local match = not vazio and s ~= "" and string.find(string.lower(n), s, 1, true) ~= nil
	
						if match then
							e.f.Visible = true
							prev = true
							spnsecc = false
						elseif vazio then
							if spnsecc then
								e.f.Visible = false
							else
								e.f.Visible = prev
								if e.f.Visible then
									spnsecc = true 
								end
							end
						else
							e.f.Visible = false
						end
					else
						prev = true
						spnsecc = false  
					end
				end
			end
	
			if f and cont then
				task.wait(0.1)
				vgs.TS:Create(cont, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					CanvasPosition = Vector2.new(0, math.max(0, f.Position.Y.Offset - 20))
				}):Play()
			end
	
		else
			for tn, t in pairs(SearchSystem.elmnts) do
				for k, d in pairs(t) do
					if d.frame and d.frame.Parent then
						d.frame.Visible = (tn == tab)
						Hlight(d.frame, false)
					end
				end
			end
	
			if cont then
				for _, c in pairs(cont:GetChildren()) do
					if c:IsA("Frame") and c:FindFirstChild("Holder") then
						c.Visible = true
					end
				end
			end
		end
	end
	
	local function search(serchtext)
		serchtext = string.lower(serchtext)
		
		if serchtext == "" then
			ClearR()
			return
		end
		
		SearchSystem.isserch = true
		SearchSystem.results = {}
		
		local scores = {}
		local btab = nil
		local bscore = 0
		
		for tabName, _ in pairs(SearchSystem.elmnts) do
			scores[tabName] = 0
		end
		
		for tabName, elements in pairs(SearchSystem.elmnts) do
			for elementName, data in pairs(elements) do
				local elmNLower = string.lower(elementName)
				local match = string.find(elmNLower, serchtext) ~= nil
				
				if match then
					scores[tabName] = scores[tabName] + 1
					SearchSystem.results[tabName] = SearchSystem.results[tabName] or {}
					SearchSystem.results[tabName][elementName] = data
					
					if scores[tabName] > bscore then
						bscore = scores[tabName]
						btab = tabName
					end
				end
			end
		end
		
		if btab then
			Gotab(btab)
		end
	end
	
	if WindowConfig.SearchBar then
		local SearchBox = Create("TextBox", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			PlaceholderColor3 = Color3.fromRGB(210,210,210),
			PlaceholderText = "Search",
			Font = Enum.Font.GothamBold,
			TextWrapped = true,
			Text = '',
			TextXAlignment = Enum.TextXAlignment.Center,
			TextSize = 14,
			ClearTextOnFocus = true
		})
		
		local tbxatual = AddThemeObject(SearchBox, "Text")
	
		local SearchBar = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0.1, 6), {
			Parent = WindowStuff,
			Size = UDim2.new(0, 130, 0, 32),
			Position = UDim2.new(1, -10, 0, 10),
			AnchorPoint = Vector2.new(1, 0)
		}), {
			AddThemeObject(MakeElement("Stroke"), "Stroke"),
			tbxatual
		}), "Main")
		
		local function srchhdl()
			local serchtext = string.lower(SearchBox.Text)
			
			if serchtext == "" then
				ClearR()
				
				for tabName, tabFrame in pairs(Tabs) do
					if tabFrame:IsA('TextButton') then
						tabFrame.Visible = true
					end
				end
				
				if SearchSystem.actvtab and SearchSystem.tabs[SearchSystem.actvtab] then
					SearchSystem.tabs[SearchSystem.actvtab].Visible = true
				end
			else
				search(serchtext)
				
				for tabName, tabFrame in pairs(Tabs) do
					if tabFrame:IsA('TextButton') then
						local hasResults = SearchSystem.results[tabName] ~= nil
						tabFrame.Visible = hasResults
					end
				end
			end
		end
	
		AddConnection(tbxatual:GetPropertyChangedSignal("Text"), srchhdl)

		AddConnection(tbxatual.FocusLost, function(enterPressed)
			if tbxatual.Text == "" then
				srchhdl()
			end
		end)
	end

	local WindowName = AddThemeObject(SetProps(MakeElement("Label", WindowConfig.Name, 14), {
		Size = UDim2.new(1, -30, 2, 0),
		Position = UDim2.new(0, 25, 0, -24),
		Font = Enum.Font.GothamBlack,
		TextSize = 20
	}), "Text")

	local WindowTopBarLine = AddThemeObject(SetProps(MakeElement("Frame"), {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, -1)
	}), "Stroke")

	local MainWindow = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 10), {
		Parent = Orion,
		Position = UDim2.new(0.5, -307, 0.5, -172),
		Size = UDim2.new(0, 615, 0, 344),
		ClipsDescendants = true
	}), {
		SetChildren(SetProps(MakeElement("TFrame"), {
			Size = UDim2.new(1, 0, 0, 50),
			Name = "TopBar"
		}), {
			WindowName,
			WindowTopBarLine,
			AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 7), {
				Size = UDim2.new(0, 70, 0, 30),
				Position = UDim2.new(1, -90, 0, 10)
			}), {
				AddThemeObject(MakeElement("Stroke"), "Stroke"),
				AddThemeObject(SetProps(MakeElement("Frame"), {
					Size = UDim2.new(0, 1, 1, 0),
					Position = UDim2.new(0.5, 0, 0, 0)
				}), "Stroke"), 
				CloseBtn,
				MinimizeBtn
			}), "Second"), 
		}),
		DragPoint,
		WindowStuff
	}), "Main")
    MainWindow.Active = true

	resizebtt.Size = UDim2.new(0, 16, 0, 16)
	resizebtt.Position = UDim2.new(1, -16, 1, -16)
	resizebtt.BorderSizePixel = 0
	resizebtt.Parent = MainWindow
	resizebtt.Visible = true
	resizebtt.AnchorPoint = Vector2.new(0.1, 0.1)
	resizebtt.BackgroundTransparency = 0
	resizebtt.ClipsDescendants = true
	
	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0.5, 0)
	UICorner.Parent = resizebtt

	resizebtt.BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Main

	local drgg = false
	local mspos
	local nresize = 0
	local default = UDim2.new(0, 615, 0, 344)

	resizebtt.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local cctime = tick()
	
			if cctime - nresize <= 0.5 then
				local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				local tween = vgs.TS:Create(MainWindow, tweenInfo, { Size = default})
				tween:Play()
				drgg = false 
			else
				drgg = true
				mspos = input.Position
			end
	
			nresize = cctime
		end
	end)
	
	vgs.UIS.InputChanged:Connect(function(input)
		if drgg and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - mspos
			mspos = input.Position
	
			local newWidth = math.max(415, MainWindow.Size.X.Offset + delta.X)
			local newHeight = math.max(307, MainWindow.Size.Y.Offset + delta.Y)
	
			MainWindow.Size = UDim2.new(0, newWidth, 0, newHeight)
		end
	end)
	
	vgs.UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			drgg = false
		end
	end)
	
	local lctime = 0
	local dctime = 0.15
	local minimized = false
	
	AddConnection(DragPoint.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local cctime2 = tick()
			local timediff = cctime2 - lctime
			
			if timediff <= dctime and minimized then
				mouse1release()
				local screenSize = workspace.CurrentCamera.ViewportSize
				local windowSize = MainWindow.AbsoluteSize
				
				local xPos = (screenSize.X - windowSize.X) / 2
				local yPos = -55
				
				local tposs = UDim2.new(0, xPos, 0, yPos)
				local crposs = MainWindow.Position
				
				local ds = math.sqrt(
					math.pow(crposs.X.Offset - xPos, 2) + 
					math.pow(crposs.Y.Offset - yPos, 2)
				)
				
				local mdss = math.sqrt(screenSize.X^2 + screenSize.Y^2)
				local ndss = math.clamp(ds / mdss, 0, 1)
				local ttime = 0.5 + (ndss * 1.5)
				
				local tinfo = TweenInfo.new(
					ttime,
					Enum.EasingStyle.Quint,
					Enum.EasingDirection.Out
				)
				
				local tween = vgs.TS:Create(MainWindow, tinfo, {Position = tposs})
				tween:Play()
				
				lctime = 0
			else
				lctime = cctime2
			end
		end
	end)
	
	if WindowConfig.ShowIcon then
		WindowName.Position = UDim2.new(0, 50, 0, -24)
		if not WindowConfig.IconColorChange then
			WindowIcon = SetProps(MakeElement("Image", WindowConfig.Icon), {
				Size = UDim2.new(0, 50, 0, 50),
				Position = UDim2.new(0, 0, 0, 0),
				Name = "WindowIcon"
			})
		else
			WindowIcon = AddThemeObject(SetProps(MakeElement("Image", WindowConfig.Icon), {
				Size = UDim2.new(0, 50, 0, 50),
				Position = UDim2.new(0, 0, 0, 0),
				Name = "WindowIcon"
			}), "Accent")
		end
		WindowIcon.Parent = MainWindow.TopBar
	end


	WindowStuff:GetPropertyChangedSignal("Visible"):Connect(function()
		resizebtt.Visible = WindowStuff.Visible
	end)

	MakeDraggable(DragPoint, MainWindow)
	
	AddConnection(CloseBtn.MouseButton1Up, function()
		MainWindow.Visible = false
		UIHidden = true
		
		if WindowConfig.FreeMouse then
			UnlockMouse(false)
		end
		
	end)

	AddConnection(vgs.UIS.InputBegan, function(Input, Focus)
		if not Focus then
			if Input.KeyCode == Enum.KeyCode[WindowConfig.Openkey] and UIHidden then
				MainWindow.Visible = true
				UIHidden = false
				if WindowConfig.FreeMouse then
					UnlockMouse(true)
				end
			elseif Input.KeyCode == Enum.KeyCode[WindowConfig.Openkey] and not UIHidden then
				MainWindow.Visible = false
				UIHidden = true

				if WindowConfig.FreeMouse then
					UnlockMouse(false)
				end
				OrionLib:MakeNotification({
					Name = "Interface Hidden",
					Content = "Tap "  .. WindowConfig.Openkey .. " to reopen the interface",
					Time = 3
				})
			end
		end
	end)
	local reztween = nil
	local mintween = nil
	
	local function updminframe()
		if not minimized then return end
		
		if reztween then
			reztween:Cancel()
			reztween = nil
		end
		
		local newWidth = WindowName.TextBounds.X + 150
		if MainWindow.Size.X.Offset == newWidth then return end
		
		reztween = vgs.TS:Create(MainWindow, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, newWidth, 0, 50)
		})
		reztween:Play()
	end
	
	WindowName:GetPropertyChangedSignal("TextBounds"):Connect(updminframe)
	
	MinimizeBtn.MouseButton1Click:Connect(function()
		if reztween then
			reztween:Cancel()
			reztween = nil
		end
		
		if mintween then
			mintween:Cancel()
			mintween = nil
		end
		
		minimized = not minimized
		
		if minimized then
			MainWindow.ClipsDescendants = true
			WindowTopBarLine.Visible = false
			WindowStuff.Visible = false
			MinimizeBtn.Ico.Image = "rbxassetid://7072720870"
			
			mintween = vgs.TS:Create(MainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, WindowName.TextBounds.X + 150, 0, 50)
			})
			mintween:Play()
			mintween.Completed:Wait()
		else
			MinimizeBtn.Ico.Image = "rbxassetid://7072719338"
			
			mintween = vgs.TS:Create(MainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, 615, 0, 344)
			})
			mintween:Play()
			task.spawn(function()
				task.wait(0.05)
				MainWindow.ClipsDescendants = false
			    WindowStuff.Visible = true
			end)
			mintween.Completed:Wait()
		end
	end)

	local function LoadSequence()
		MainWindow.Visible = false
		local LoadSequenceLogo = SetProps(MakeElement("Image", WindowConfig.IntroIcon), {
			Parent = Orion,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(1, 0, 0.4, 0),
			Size = UDim2.new(0, 50, 0, 50),
			ImageColor3 = Color3.fromRGB(255, 255, 255),
			ImageTransparency = 1,
			ScaleType = Enum.ScaleType.Fit
		})
	
		local LoadSequenceText = SetProps(MakeElement("Label", WindowConfig.IntroText, 14), {
			Parent = Orion,
			Size = UDim2.new(1, 0, 1, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 19, 0.5, 0),
			TextXAlignment = Enum.TextXAlignment.Center,
			Font = Enum.Font.GothamBold,
			TextTransparency = 1
		})
	
		vgs.TS:Create(LoadSequenceLogo, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 0, Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
		task.wait(0.8)
		vgs.TS:Create(LoadSequenceLogo, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -(LoadSequenceText.TextBounds.X/2), 0.5, 0)}):Play()
		task.wait(0.3)
		vgs.TS:Create(LoadSequenceText, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
		task.wait(2)
		vgs.TS:Create(LoadSequenceText, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1}):Play()
		MainWindow.Visible = true
		LoadSequenceLogo:Destroy()
		LoadSequenceText:Destroy()
	end

	if WindowConfig.IntroEnabled then
		LoadSequence()
	end

	if WindowConfig.FreeMouse then
		OrionLib:MakeNotification({
			Name = "Free Mouse mode is on",
			Content = "if you want it to go back to normal, just press " .. WindowConfig.Openkey .. " or close the GUI",
			Time = 5
		})
	end

	local Functions = {}

	function Functions:ChangeIcon(IconId)
		local ficon = IconId
		if not string.match(IconId, "rbxassetid://") then
			ficon = "rbxassetid://" .. IconId
		end
		
		local WindowIcon = MainWindow.TopBar:FindFirstChild("WindowIcon")
		
		if WindowIcon then
			WindowIcon.Image = ficon
		else
			WindowConfig.ShowIcon = true
			WindowName.Position = UDim2.new(0, 50, 0, -24)
			if not WindowConfig.IconColorChange == true then
				WindowIcon = SetProps(MakeElement("Image", ficon), {
					Size = UDim2.new(0, 50, 0, 50),
					Position = UDim2.new(0, 0, 0, 0),
					Name = "WindowIcon"
				})
			else
				WindowIcon = AddThemeObject(SetProps(MakeElement("Image", ficon), {
					Size = UDim2.new(0, 50, 0, 50),
					Position = UDim2.new(0, 0, 0, 0),
					Name = "WindowIcon"
				}), "Accent")
			end
			WindowIcon.Parent = MainWindow.TopBar
		end
		
		WindowConfig.Icon = ficon
	end

	function Functions:SetName(...)
		local args = {...}
		local result = ""
	
		for _, pair in ipairs(args) do
			local text, color = unpack(pair)
			color = color or "#FFFFFF"
	
			for i = 1, #text do
				local char = text:sub(i, i)
				result = result .. '<font color="' .. color .. '">' .. char .. '</font>'
			end
		end
	
		WindowName.RichText = true
		WindowName.Text = result
	end

	function Functions:MakeTab(TabConfig)
		TabConfig = TabConfig or {}
		TabConfig.Name = TabConfig.Name or "Tab"
		TabConfig.Icon = TabConfig.Icon or ""
		TabConfig.PremiumOnly = TabConfig.PremiumOnly or false
		
		local TabFrame = SetChildren(SetProps(MakeElement("Button"), {
			Size = UDim2.new(1, 0, 0, 30),
			Parent = TabHolder
		}), {
			AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 6), {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Name = "Highlight"
			}), {}), "Divider"),
			AddThemeObject(SetProps(MakeElement("Image", TabConfig.Icon), {
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.new(0, 18, 0, 18),
				Position = UDim2.new(0, 10, 0.5, 0),
				ImageTransparency = 0.4,
				Name = "Ico"
			}), "Text"),
			AddThemeObject(SetProps(MakeElement("Label", TabConfig.Name, 14), {
				Size = UDim2.new(1, -35, 1, 0),
				Position = UDim2.new(0, 35, 0, 0),
				Font = Enum.Font.GothamSemibold,
				TextTransparency = 0.4,
				Name = "Title"
			}), "Text")
		})

		AddConnection(TabFrame.MouseEnter, function()
			if TabFrame.Title.Font ~= Enum.Font.GothamBlack then
				vgs.TS:Create(TabFrame.Highlight, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0.8}):Play()
			end
		end)
		
		AddConnection(TabFrame.MouseLeave, function()
			if TabFrame.Title.Font ~= Enum.Font.GothamBlack then
				vgs.TS:Create(TabFrame.Highlight, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
			end
		end)
		AddItemTable(Tabs, TabConfig.Name, TabFrame)
		
		local Container = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255, 255, 255), 5), {
			Size = UDim2.new(1, -150, 1, -50),
			Position = UDim2.new(0, 150, 0, 50),
			Parent = MainWindow,
			Visible = false,
			Name = "ItemContainer"
		}), {
			MakeElement("List", 0, 6),
			MakeElement("Padding", 15, 10, 10, 15)
		}), "Divider")

		Container.Name = TabConfig.Name
		Container.ScrollBarImageTransparency = 1

		AddConnection(Container.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
			Container.CanvasSize = UDim2.new(0, 0, 0, Container.UIListLayout.AbsoluteContentSize.Y + 30)
		end)
		RTab(TabConfig.Name, Container)
		Rbutton(TabConfig.Name, TabFrame)
		if FirstTab then
			FirstTab = false
			TabFrame.Ico.ImageTransparency = 0
			TabFrame.Title.TextTransparency = 0
			TabFrame.Title.Font = Enum.Font.GothamBlack
			Container.Visible = true
		end

		AddConnection(TabFrame.MouseButton1Click, function()
			if TabFrame:FindFirstChild("Highlight") then
				vgs.TS:Create(TabFrame.Highlight, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
			end
			Gotab(TabConfig.Name)
		end)

		local function Getelmnts(ItemParent, _tabName)
			local ElementFunction = {}
			function ElementFunction:AddLog(Text)
				local Label = MakeElement("Label", Text, 15)
				local LogFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 0.7,
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(Label, {
						Size = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						TextXAlignment = Enum.TextXAlignment.Center,
						TextSize = 19,
						TextWrapped = true,
						Font = Enum.Font.GothamBold,
						Name = "Content"
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke")
				}), "Second")

				local LogFunction = {}
				function LogFunction:Set(ToChange)
					LogFrame.Content.Text = ToChange
				end
				return LogFunction
			end
			
			function ElementFunction:AddLabel(Text)
				local LabelFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 30),
					BackgroundTransparency = 0.7,
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", Text, 15), {
						Size = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold,
						Name = "Content",
						RichText = true
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke")
				}), "Second")
			
				local current = Text
				local animating = false
			
				local function commtext(str1, str2)
					local i = 1
					while i <= #str1 and i <= #str2 and str1:sub(i, i) == str2:sub(i, i) do
						i = i + 1
					end
					return i - 1
				end
			
				local function anminchanges(newText, finalRichText)
					if animating then return end
					animating = true
					
					LabelFrame.Content.RichText = false
					
					local comleng = commtext(current, newText)
					local trem = current:sub(comleng + 1)
					local tadd = newText:sub(comleng + 1)
					
					local tempt = current:sub(1, comleng)
					
					for i = #trem, 1, -1 do
						tempt = current:sub(1, comleng + i - 1)
						LabelFrame.Content.Text = tempt
						task.wait(0.02)
					end
					
					for i = 1, #tadd do
						tempt = current:sub(1, comleng) .. tadd:sub(1, i)
						LabelFrame.Content.Text = tempt
						task.wait(0.02)
					end
					
					LabelFrame.Content.RichText = true
					LabelFrame.Content.Text = finalRichText or newText
					
					current = newText
					animating = false
				end
			
				local function appcol(text, colorConfig)
					if type(colorConfig) == "table" then
						for word, color in pairs(colorConfig) do
							if text:find(word) then
								local escapedWord = word:gsub("([%(%)%.%+%-%*%?%[%]%^%$%%])", "%%%1")
								text = text:gsub(escapedWord, '<font color="' .. color .. '">' .. word .. '</font>')
							end
						end
					end
					return text
				end
			
				local LabelFunction = {}
				
				function LabelFunction:Set(newText, colorConfig)
					local finalText = newText
					if colorConfig then
						finalText = appcol(newText, colorConfig)
					end
					
					task.spawn(function()
						anminchanges(newText, finalText)
					end)
				end
				
				Relem(_tabName, Text, LabelFrame)
				return LabelFunction
			end
			
			function ElementFunction:ColorLabel(Text, ToChangeColor, Position)
				local ContentLabel = SetProps(MakeElement("Label", Text, 15), {
					Size = UDim2.new(1, -12, 1, 0),
					Position = UDim2.new(0, 12, 0, 0),
					Font = Enum.Font.GothamBold,
					Name = "Content",
					TextColor3 = ToChangeColor or Color3.fromRGB(255, 255, 255)
				})
				
				local LabelFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 33),
					BackgroundTransparency = 0.7,
					Parent = ItemParent
				}), {
					ContentLabel,
					AddThemeObject(MakeElement("Stroke"), "Stroke")
				}), "Second")
			
				Relem(_tabName, Text, LabelFrame)
				
				local labelfunc = {}
			
				function labelfunc:Set(ToChange, ToChangeColor, Position)
					LabelFrame.Content.Text = ToChange
			
					if ToChangeColor then
						LabelFrame.Content.TextColor3 = ToChangeColor
					else
						LabelFrame.Content.TextColor3 = Color3.fromRGB(255, 255, 255)
					end
					
					local tposs
					if Position == "Left" then
						tposs = UDim2.new(0, 12, 0, 0)
					elseif Position == "Center" then
						tposs = UDim2.new(0.5, -LabelFrame.Content.TextBounds.X / 2, 0, 0)
					elseif Position == "Right" then
						tposs = UDim2.new(1, -LabelFrame.Content.TextBounds.X - 12, 0, 0)
					else
						tposs = UDim2.new(0.5, -LabelFrame.Content.TextBounds.X / 2, 0, 0)
					end
			
					local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
					local tweenGoal = {Position = tposs}
					local tween = vgs.TS:Create(LabelFrame.Content, tweenInfo, tweenGoal)
			
					tween:Play()
				end
			
				labelfunc:Set(Text, ToChangeColor, Position)
				return labelfunc
			end
			
			function ElementFunction:AddParagraph(Text, Content, Align)
				Text = Text or "Text"
				Content = Content or "Content"
				Align = Align or "Left"
				
				local ParagraphFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 30),
					BackgroundTransparency = 0.7,
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", Text, 15), {
						Size = UDim2.new(1, -12, 0, 14),
						Position = UDim2.new(0, 12, 0, 10),
						Font = Enum.Font.GothamBold,
						Name = "Title",
						TextXAlignment = Enum.TextXAlignment[Align]
					}), "Text"),
					AddThemeObject(SetProps(MakeElement("Label", "", 13), {
						Size = UDim2.new(1, -24, 0, 0),
						Position = UDim2.new(0, 12, 0, 26),
						Font = Enum.Font.GothamSemibold,
						Name = "Content",
						TextWrapped = true,
						TextXAlignment = Enum.TextXAlignment[Align]
					}), "TextDark"),
					AddThemeObject(MakeElement("Stroke"), "Stroke")
				}), "Second")
				
				Relem(_tabName, Text, ParagraphFrame)
				
				local function updtsz()
					if ParagraphFrame and ParagraphFrame.Parent then
						ParagraphFrame.Content.Size = UDim2.new(1, -24, 0, ParagraphFrame.Content.TextBounds.Y)
						ParagraphFrame.Size = UDim2.new(1, 0, 0, ParagraphFrame.Content.TextBounds.Y + 35)
					end
				end
				
				AddConnection(ParagraphFrame.Content:GetPropertyChangedSignal("Text"), updtsz)
				AddConnection(ParagraphFrame.Content:GetPropertyChangedSignal("TextBounds"), updtsz)
				
				local rsconn = AddConnection(MainWindow:GetPropertyChangedSignal("Size"), function()
					task.wait()
					updtsz()
				end)
				
				AddConnection(ParagraphFrame.Destroying, function()
					if rsconn and rsconn.Connected then
						rsconn:Disconnect()
					end
				end)
				
				ParagraphFrame.Content.Text = Content
				
				local ParagraphFunction = {}
				function ParagraphFunction:Set(newtext, newcont, newalin)
					if newtext then
						ParagraphFrame.Title.Text = newtext
					end
					if newcont then
						ParagraphFrame.Content.Text = newcont
					end
					if newalin then
						ParagraphFrame.Content.TextXAlignment = Enum.TextXAlignment[newalin]
						ParagraphFrame.Title.TextXAlignment = Enum.TextXAlignment[newalin]
					end
				end
				return ParagraphFunction
			end
			
			function ElementFunction:AddButton(ButtonConfig)
				ButtonConfig = ButtonConfig or {}
				ButtonConfig.Name = ButtonConfig.Name or "Button"
				ButtonConfig.Callback = ButtonConfig.Callback or function() end
				ButtonConfig.Icon = ButtonConfig.Icon or "rbxassetid://3944703587"
			
				local Button = {}
				local Ihov = false
				local Ip = false
				local PIns = false  
			
				local Click = SetProps(MakeElement("Button"), {
					Size = UDim2.new(1, 0, 1, 0)
				})
			
				local ButtonFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 33),
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", ButtonConfig.Name, 15), {
						Size = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold,
						Name = "Content"
					}), "Text"),
					AddThemeObject(SetProps(MakeElement("Image", ButtonConfig.Icon), {
						Size = UDim2.new(0, 20, 0, 20),
						Position = UDim2.new(1, -30, 0, 7),
					}), "TextDark"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					Click
				}), "Second")
				
				Relem(_tabName, ButtonConfig.Name, ButtonFrame)
				
				local function UpdateColor()
					local baseColor = OrionLib.Themes[OrionLib.SelectedTheme].Second
					local offset = Ip and 6 or (Ihov and 3 or 0)
					
					if offset > 0 then
						ButtonFrame.BackgroundColor3 = Color3.fromRGB(
							math.min(baseColor.R * 255 + offset, 255),
							math.min(baseColor.G * 255 + offset, 255),
							math.min(baseColor.B * 255 + offset, 255)
						)
					else
						ButtonFrame.BackgroundColor3 = baseColor
					end
				end
				
				AddConnection(Click.MouseEnter, function()
					Ihov = true
					UpdateColor()
				end)
			
				AddConnection(Click.MouseLeave, function()
					Ihov = false
					Ip = false
					PIns = false  
					ButtonFrame.BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second
				end)
			
				AddConnection(Click.MouseButton1Down, function()
					Ip = true
					PIns = true 
					UpdateColor()
				end)
			
				AddConnection(Click.MouseButton1Up, function()
					Ip = false
					UpdateColor()
					
					if PIns then
						spawn(function()
							ButtonConfig.Callback()
						end)
					end
					
					PIns = false  
				end)
			
				function Button:Set(ButtonText)
					ButtonFrame.Content.Text = ButtonText
				end	
			
				return Button
			end
			
			function ElementFunction:AddToggle(ToggleConfig)
				ToggleConfig = ToggleConfig or {}
				ToggleConfig.Name = ToggleConfig.Name or "Toggle"
				ToggleConfig.Default = ToggleConfig.Default or false
				ToggleConfig.Callback = ToggleConfig.Callback or function() end
				ToggleConfig.Color = ToggleConfig.Color or nil
				ToggleConfig.Flag = ToggleConfig.Flag or nil
				ToggleConfig.Save = ToggleConfig.Save or false
			
				local Toggle = {
					Value = ToggleConfig.Default, 
					Save = ToggleConfig.Save, 
					Box = nil,
					uccolor = ToggleConfig.Color ~= nil, 
					ccolor = ToggleConfig.Color  
				}
			
				local Click = SetProps(MakeElement("Button"), {
					Size = UDim2.new(1, 0, 1, 0)
				})
			
				local accolor = ToggleConfig.Color or OrionLib.Themes[OrionLib.SelectedTheme].Accent
			
				local ToggleBox = SetChildren(SetProps(MakeElement("RoundFrame", accolor, 0, 4), {
					Size = UDim2.new(0, 24, 0, 24),
					Position = UDim2.new(1, -24, 0.5, 0),
					AnchorPoint = Vector2.new(0.5, 0.5)
				}), {
					SetProps(MakeElement("Stroke"), {
						Color = accolor,
						Name = "Stroke",
						Transparency = 0.5
					}),
					SetProps(MakeElement("Image", "rbxassetid://3944680095"), {
						Size = UDim2.new(0, 20, 0, 20),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.new(0.5, 0, 0.5, 0),
						ImageColor3 = Color3.fromRGB(255, 255, 255),
						Name = "Ico"
					}),
				})
				Toggle.Box = ToggleBox
			
				local ToggleFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 38),
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", ToggleConfig.Name, 15), {
						Size = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold,
						Name = "Content"
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					ToggleBox,
					Click
				}), "Second")
				
				Relem(_tabName, ToggleConfig.Name, ToggleFrame)
				
				function Toggle:Set(Value, Silent)
					Toggle.Value = Value
					local accolor = Toggle.uccolor and Toggle.ccolor or OrionLib.Themes[OrionLib.SelectedTheme].Accent
					
					vgs.TS:Create(ToggleBox, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
						BackgroundColor3 = Toggle.Value and accolor or OrionLib.Themes[OrionLib.SelectedTheme].Divider
					}):Play()
					vgs.TS:Create(ToggleBox.Stroke, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
						Color = Toggle.Value and accolor or OrionLib.Themes[OrionLib.SelectedTheme].Stroke
					}):Play()
					vgs.TS:Create(ToggleBox.Ico, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
						ImageTransparency = Toggle.Value and 0 or 1, 
						Size = Toggle.Value and UDim2.new(0, 20, 0, 20) or UDim2.new(0, 8, 0, 8)
					}):Play()
					
					if not Silent then
						ToggleConfig.Callback(Toggle.Value)
					end
				end    
			
				AddConnection(Click.MouseEnter, function()
					vgs.TS:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
						BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)
					}):Play()
				end)
			
				AddConnection(Click.MouseLeave, function()
					vgs.TS:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
						BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second
					}):Play()
				end)
			
				AddConnection(Click.MouseButton1Up, function()
					vgs.TS:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
						BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)
					}):Play()
					SaveCfg(game.GameId)
					Toggle:Set(not Toggle.Value)
				end)
			
				AddConnection(Click.MouseButton1Down, function()
					vgs.TS:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
						BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 6)
					}):Play()
				end)
			
				if ToggleConfig.Flag then
					OrionLib.Flags[ToggleConfig.Flag] = Toggle
				end
				table.insert(OrionLib.Toggles, Toggle)
				
				Toggle:Set(Toggle.Value, true)
				
				return Toggle
			end
			
			function ElementFunction:AddPbind(PBindConfig)
				PBindConfig.Name = PBindConfig.Name or "Position"
				PBindConfig.DefaultX = PBindConfig.DefaultX or ""
				PBindConfig.DefaultY = PBindConfig.DefaultY or ""
				PBindConfig.DefaultZ = PBindConfig.DefaultZ or ""
				PBindConfig.Callback = PBindConfig.Callback or function() end
				PBindConfig.Flag = PBindConfig.Flag or nil
				PBindConfig.Save = PBindConfig.Save or false
			
				local PBind = {
					ValueX = PBindConfig.DefaultX,
					ValueY = PBindConfig.DefaultY,
					ValueZ = PBindConfig.DefaultZ,
					Type = "PBind",
					Save = PBindConfig.Save
				}
			
				local function valinput(text)
					local cleaned = string.gsub(text, "[^0-9%.%-]", "")
					
					local dotcnt = 0
					cleaned = string.gsub(cleaned, "%.", function()
						dotcnt = dotcnt + 1
						return dotcnt == 1 and "." or ""
					end)
					
					if string.find(cleaned, "%-") then
						cleaned = string.gsub(cleaned, "%-", "")
						if string.sub(text, 1, 1) == "-" then
							cleaned = "-" .. cleaned
						end
					end
					
					local maxLen = string.find(cleaned, "%.") and 6 or 5
					if #cleaned > maxLen then
						cleaned = string.sub(cleaned, 1, maxLen)
					end
					
					return cleaned
				end
			
				local flds = {}
				
				local function CreateTB(xPos, lbl, defVal, idx)
					local tb = AddThemeObject(Create("TextBox", {
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundTransparency = 1,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
						PlaceholderText = "...",
						Font = Enum.Font.GothamBold,
						TextXAlignment = Enum.TextXAlignment.Center,
						TextSize = 13,
						Text = defVal,
						ClearTextOnFocus = true
					}), "Text")
			
					local lblTxt = AddThemeObject(SetProps(MakeElement("Label", lbl .. ":", 15), {
						Size = UDim2.new(0, 20, 1, 0),
						Position = UDim2.new(1, xPos - 30, 0, 0),
						AnchorPoint = Vector2.new(1, 0),
						Font = Enum.Font.GothamBold,
						TextXAlignment = Enum.TextXAlignment.Right,
						Name = "OuterLabel"
					}), "Text")
			
					local cont = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
						Size = UDim2.new(0, 24, 0, 24),
						Position = UDim2.new(1, xPos, 0.5, 0),
						AnchorPoint = Vector2.new(1, 0.5)
					}), {
						AddThemeObject(MakeElement("Stroke"), "Stroke"),
						tb
					}), "Main")
			
					flds[idx] = {
						container = cont,
						label = lblTxt,
						basePos = xPos,
						currwidth = 24,
						offset = 0
					}
			
					AddConnection(tb:GetPropertyChangedSignal("Text"), function()
						local cleaned = valinput(tb.Text)
						
						if tb.Text ~= cleaned then
							tb.Text = cleaned
							return
						end
						
						local w = math.clamp(tb.TextBounds.X + 19, 24, 80)
						local widthDiff = w - flds[idx].currwidth
						flds[idx].currwidth = w
						
						vgs.TS:Create(cont, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
							Size = UDim2.new(0, w, 0, 24)
						}):Play()
						
						vgs.TS:Create(lblTxt, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
							Position = UDim2.new(1, flds[idx].basePos - w - 6 - flds[idx].offset, 0, 0)
						}):Play()
						
						for i = 1, idx - 1 do
							flds[i].offset = flds[i].offset + widthDiff
							
							vgs.TS:Create(flds[i].container, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
								Position = UDim2.new(1, flds[i].basePos - flds[i].offset, 0.5, 0)
							}):Play()
							
							vgs.TS:Create(flds[i].label, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
								Position = UDim2.new(1, flds[i].basePos - flds[i].currwidth - 6 - flds[i].offset, 0, 0)
							}):Play()
						end
					end)
			
					return cont, tb, lblTxt
				end
			
				local BX, TBX, LX = CreateTB(-120, "X", PBindConfig.DefaultX, 1)
				local BY, TBY, LY = CreateTB(-65, "Y", PBindConfig.DefaultY, 2)
				local BZ, TBZ, LZ = CreateTB(-10, "Z", PBindConfig.DefaultZ, 3)
			
				local PBF = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 38),
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", PBindConfig.Name, 15), {
						Size = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold,
						Name = "Content"
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					LX, BX, LY, BY, LZ, BZ
				}), "Second")
			
				Relem(_tabName, PBindConfig.Name, PBF)
			
				local function UpdCb()
					PBind.ValueX = TBX.Text
					PBind.ValueY = TBY.Text
					PBind.ValueZ = TBZ.Text
					PBindConfig.Callback(PBind.ValueX, PBind.ValueY, PBind.ValueZ)
				end
			
				AddConnection(TBX.FocusLost, UpdCb)
				AddConnection(TBY.FocusLost, UpdCb)
				AddConnection(TBZ.FocusLost, UpdCb)
			
				function PBind:Set(x, y, z)
					if x then
						PBind.ValueX = tostring(x)
						TBX.Text = string.sub(PBind.ValueX, 1, 6)
					end
					if y then
						PBind.ValueY = tostring(y)
						TBY.Text = string.sub(PBind.ValueY, 1, 6)
					end
					if z then
						PBind.ValueZ = tostring(z)
						TBZ.Text = string.sub(PBind.ValueZ, 1, 6)
					end
				end
			
				if PBindConfig.Flag then
					OrionLib.Flags[PBindConfig.Flag] = PBind
				end
			
				return PBind
			end
			
			function ElementFunction:AddSlider(SliderConfig)
				SliderConfig = SliderConfig or {}
				SliderConfig.Name = SliderConfig.Name or "Slider"
				SliderConfig.Min = SliderConfig.Min or 0
				SliderConfig.Max = SliderConfig.Max or 100
				SliderConfig.Increment = SliderConfig.Increment or 1
				SliderConfig.Default = math.clamp(SliderConfig.Default or 50, SliderConfig.Min, SliderConfig.Max)
				SliderConfig.Callback = SliderConfig.Callback or function() end
				SliderConfig.ValueName = SliderConfig.ValueName or ""
				SliderConfig.Flag = SliderConfig.Flag or nil
				SliderConfig.Save = SliderConfig.Save or false
				SliderConfig.Block = SliderConfig.Block 
				SliderConfig.varFunc = SliderConfig.varFunc 
			
				local st = {drg = false, bc = nil, ic = nil}
				local s = {Value = SliderConfig.Default, Save = SliderConfig.Save, IsClicking = false, _st = st}
				local inf = (SliderConfig.Max == math.huge)
				local it = 0.95
			
				local function fv(v)
					if v == math.huge then return "∞"
					elseif v >= 1e6 then return string.format("%.1fM", v / 1e6)
					elseif v >= 1e3 then return string.format("%.1fK", v / 1e3)
					else return tostring(math.floor(v * 100)/100) end
				end
			
				local function sc(v)
					if inf then
						if v == math.huge then return 1 end
						local sm = SliderConfig.Min * 5
						return math.clamp((v - SliderConfig.Min) / (sm - SliderConfig.Min), 0, it)
					else
						if SliderConfig.Max == SliderConfig.Min then return 0 end
						return math.clamp((v - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min), 0, 1)
					end
				end
			
				local sd = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(9, 149, 98), 0, 5), {
					Size = UDim2.new(0, 0, 1, 0),
					BackgroundTransparency = 0.3,
					ClipsDescendants = true
				}), {AddThemeObject(SetProps(MakeElement("Label", "value", 13), {
					Size = UDim2.new(1, -12, 0, 14),
					Position = UDim2.new(0, 12, 0, 6),
					Font = Enum.Font.GothamBold,
					Name = "Value",
					TextTransparency = 0
				}), "Text")}), "Accent")
			
				local sb = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(9, 149, 98), 0, 5), {
					Size = UDim2.new(1, -24, 0, 26),
					Position = UDim2.new(0, 12, 0, 30),
					BackgroundTransparency = 0.9,
					Active = true
				}), {AddThemeObject(SetProps(MakeElement("Stroke"), {
					Color = Color3.fromRGB(9, 149, 98), 
					Thickness = inf and 1.5 or 1
				}), "Stroke"),
					AddThemeObject(SetProps(MakeElement("Label", "value", 13), {
						Size = UDim2.new(1, -12, 0, 14), 
						Position = UDim2.new(0, 12, 0, 6), 
						Font = Enum.Font.GothamBold, 
						Name = "Value", 
						TextTransparency = 0.8
					}), "TextDark"),
					sd}), "Second")
			
				local sf = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
					Size = UDim2.new(1, 0, 0, 65), 
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", SliderConfig.Name, 15), {
						Size = UDim2.new(1, -12, 0, 14), 
						Position = UDim2.new(0, 12, 0, 10), 
						Font = Enum.Font.GothamBold, 
						Name = "Content"
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					sb}), "Second")
			
				Relem(_tabName, SliderConfig.Name, sf)
			
				local function dc(c, f)
					return Color3.new(c.R * f, c.G * f, c.B * f)
				end
			
				local function ab(b)
					local ac = OrionLib.Themes[OrionLib.SelectedTheme].Accent
					local tc = b and dc(ac, 0.65) or ac
					sb.Active = not b
					vgs.TS:Create(sd, TweenInfo.new(0.25), {BackgroundColor3 = tc}):Play()
					vgs.TS:Create(sb, TweenInfo.new(0.25), {BackgroundColor3 = tc}):Play()
				end
				
				if SliderConfig.varFunc and SliderConfig.Block then
					local lb = nil
					st.bc = task.spawn(function()
						while sf and sf.Parent do
							local ok, b = pcall(function()
								local t = SliderConfig.varFunc(SliderConfig.Block[1])
								if type(t) ~= "table" then return true end
								return not t[SliderConfig.Block[2]]
							end)
							if ok and b ~= lb then
								lb = b
								ab(b)
							end
							task.wait(0.1)
						end
					end)
				end
			
				AddConnection(sb.InputBegan, function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 and sb.Active then
						st.drg = true
						s.IsClicking = true
						vgs.TS:Create(sb, TweenInfo.new(0.15), {BackgroundTransparency = 0.7}):Play()
					end
				end)
			
				AddConnection(sb.InputEnded, function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 then
						st.drg = false
						s.IsClicking = false
						vgs.TS:Create(sb, TweenInfo.new(0.25), {BackgroundTransparency = 0.9}):Play()
					end
				end)
			
				st.ic = AddConnection(vgs.UIS.InputChanged, function(i)
					if not st.drg then return end
					if i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
					if not sb.Active then return end
					if not sb.Parent then return end
			
					local ok, ss = pcall(function()
						return math.clamp((i.Position.X - sb.AbsolutePosition.X) / sb.AbsoluteSize.X, 0, 1)
					end)
					
					if not ok then return end
			
					local nv
			
					if inf then
						if ss >= it then
							nv = math.huge
						else
							local sm = SliderConfig.Min * 5
							local sv = SliderConfig.Min + (sm - SliderConfig.Min) * ss / it
							if SliderConfig.Increment > 0 then
								local st = math.round((sv - SliderConfig.Min) / SliderConfig.Increment)
								nv = SliderConfig.Min + (st * SliderConfig.Increment)
							else
								nv = sv
							end
						end
					else
						local sv = SliderConfig.Min + (SliderConfig.Max - SliderConfig.Min) * ss
						if SliderConfig.Increment > 0 then
							local st = math.round((sv - SliderConfig.Min) / SliderConfig.Increment)
							nv = SliderConfig.Min + (st * SliderConfig.Increment)
						else
							nv = sv
						end
					end
			
					s:Set(nv)
					pcall(function() SaveCfg(game.GameId) end)
				end)
			
				AddConnection(sf.Destroying, function()
					st.drg = false
					if st.bc then task.cancel(st.bc) st.bc = nil end
					if st.ic then pcall(function() st.ic:Disconnect() end) st.ic = nil end
				end)
			
				function s:Set(v)
					local cv = v
					if v ~= math.huge then cv = math.clamp(Round(v, SliderConfig.Increment), SliderConfig.Min, SliderConfig.Max) end
					self.Value = cv
					local stw = sc(cv)
					vgs.TS:Create(sd, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = UDim2.fromScale(stw, 1)
					}):Play()
					local vt = fv(self.Value) .. " " .. SliderConfig.ValueName
					sb.Value.Text = vt
					sd.Value.Text = vt
					pcall(function() SliderConfig.Callback(self.Value) end)
				end
			
				function s:SetName(n)
					local cl = sf.Content
					if cl.Text == n then return end
					task.spawn(function()
						local c = cl.Text
						for i = #c, 0, -1 do cl.Text = string.sub(c, 1, i) task.wait(0.025) end
						task.wait(0.1)
						for i = 1, #n do cl.Text = string.sub(n, 1, i) task.wait(0.035) end
					end)
				end
						
				function s:SetMax(m)
					if m == SliderConfig.Max then return end
					SliderConfig.Max = m
					inf = (m == math.huge)
					if self.Value > m and m ~= math.huge then
						self:Set(m)
					else
						local stw = sc(self.Value)
						vgs.TS:Create(sd, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							Size = UDim2.fromScale(stw, 1)
						}):Play()
					end
				end
				
				function s:SetMin(m)
					if m == SliderConfig.Min then return end
					SliderConfig.Min = m
					if self.Value < m then
						self:Set(m)
					else
						local stw = sc(self.Value)
						vgs.TS:Create(sd, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							Size = UDim2.fromScale(stw, 1)
						}):Play()
					end
				end
			
				s:Set(s.Value)
				if SliderConfig.Flag then OrionLib.Flags[SliderConfig.Flag] = s end
				return s
			end
			
			function ElementFunction:AddDropdown(DropdownConfig)
				DropdownConfig = DropdownConfig or {}
				DropdownConfig.Name = DropdownConfig.Name or "Dropdown"
				DropdownConfig.Options = DropdownConfig.Options or {}
				DropdownConfig.Default = DropdownConfig.Default or ""
				DropdownConfig.Multi = DropdownConfig.Multi or false
				DropdownConfig.Call = DropdownConfig.Call or false
				DropdownConfig.Searchable = DropdownConfig.Searchable or false
				DropdownConfig.Grouped = DropdownConfig.Grouped or false
				DropdownConfig.Icons = DropdownConfig.Icons or false
				DropdownConfig.MaxHeight = DropdownConfig.MaxHeight or 200
				DropdownConfig.PlrLeftNote = DropdownConfig.PlrLeftNote or false
				DropdownConfig.Callback = DropdownConfig.Callback or function() end
				DropdownConfig.Flag = DropdownConfig.Flag or nil
				DropdownConfig.Save = DropdownConfig.Save or false
			
				local Dropdown = {
					Value = DropdownConfig.Multi and {} or DropdownConfig.Default,
					Options = DropdownConfig.Options,
					filOptns = {},
					Buttons = {},
					Groups = {},
					Toggled = false,
					srchTxt = "",
					srchMode = false,
					Type = "Dropdown",
					Save = DropdownConfig.Save,
					isPDrop = false,
					Multi = DropdownConfig.Multi
				}
				
				local function DtctPDrop()
					for _, option in pairs(DropdownConfig.Options) do
						local optTxt = type(option) == "table" and (option.text or option.name) or tostring(option)
						local pName = optTxt:match("^(.-) %(") or optTxt
						
						if vgs and vgs.ps and vgs.ps:FindFirstChild(pName) then
							return true
						end
					end
					return false
				end
			
				Dropdown.isPDrop = DtctPDrop()
				local MaxElems = 5
			
				if not table.find(Dropdown.Options, Dropdown.Value) and not DropdownConfig.Multi then
					Dropdown.Value = "..."
				end
			
				local DdList = MakeElement("List")
				local SrchBox, SrchCont, SrchTgl
				
				local function relfcs()
					if DropdownConfig.Searchable and SrchBox and SrchBox:IsFocused() then
						SrchBox:ReleaseFocus()
					end
				end
			
				if DropdownConfig.Searchable then
					SrchTgl = AddThemeObject(SetChildren(SetProps(MakeElement("Button", Color3.fromRGB(255,255,255)), {
						Size = UDim2.new(1, -16, 0, 26),
						Position = UDim2.new(0, 8, 0, 43),
						Visible = false,
						Name = "SearchToggle",
						BackgroundTransparency = 1
					}), {
						AddThemeObject(SetProps(MakeElement("Frame"), {
							Size = UDim2.new(1, -30, 0, 1),
							Position = UDim2.new(0, 0, 0.5, 0),
							AnchorPoint = Vector2.new(0, 0.5),
							Name = "SearchLine"
						}), "Stroke"),
						AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072706796"), {
							Size = UDim2.new(0, 16, 0, 16),
							Position = UDim2.new(1, -20, 0.5, 0),
							AnchorPoint = Vector2.new(0, 0.5),
							ImageColor3 = Color3.fromRGB(160, 160, 160),
							Rotation = 180,
							Name = "SearchArrow"
						}), "TextDark")
					}), "Main")
			
					SrchBox = SetProps(MakeElement("TextBox"), {
						Size = UDim2.new(1, -16, 1, -6),
						Position = UDim2.new(0, 8, 0, 3),
						BackgroundTransparency = 1,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						PlaceholderColor3 = Color3.fromRGB(140, 140, 140),
						PlaceholderText = "Search...",
						Font = Enum.Font.Gotham,
						TextSize = 13,
						Text = "",
						TextXAlignment = Enum.TextXAlignment.Left
					})
			
					SrchCont = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255),0,6), {
						Size = UDim2.new(1, -16, 0, 26),
						Position = UDim2.new(0, 8, 0, 74),
						Visible = false,
						Name = "SearchContainer"
					}), {AddThemeObject(MakeElement("Stroke"), "Stroke"), SrchBox}), "Main")
				end
			
				local DdCont = AddThemeObject(SetProps(SetChildren(MakeElement("ScrollFrame", Color3.fromRGB(40, 40, 40), 4), {
					DdList
				}), {
					Parent = ItemParent,
					Position = UDim2.new(0, 0, 0, 38),
					Size = UDim2.new(1, 0, 1, -38),
					ClipsDescendants = true,
					Visible = false,
					ScrollBarImageTransparency = 1 
				}), "Divider")
			
				local Click = SetProps(MakeElement("Button"), {
					Size = UDim2.new(1, 0, 1, 0)
				})
			
				local DdFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 38),
					Parent = ItemParent,
					ClipsDescendants = true
				}), {
					DropdownConfig.Searchable and SrchTgl or MakeElement("TFrame"),
					DropdownConfig.Searchable and SrchCont or MakeElement("TFrame"),
					DdCont,
					SetProps(SetChildren(MakeElement("TFrame"), {
						AddThemeObject(SetProps(MakeElement("Label", DropdownConfig.Name, 15), {
							Size = UDim2.new(1, -12, 1, 0),
							Position = UDim2.new(0, 12, 0, 0),
							Font = Enum.Font.GothamBold,
							Name = "Content"
						}), "Text"),
						AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072706796"), {
							Size = UDim2.new(0, 20, 0, 20),
							AnchorPoint = Vector2.new(0, 0.5),
							Position = UDim2.new(1, -30, 0.5, 0),
							ImageColor3 = Color3.fromRGB(240, 240, 240),
							Name = "Arrow"
						}), "TextDark"),
						AddThemeObject(SetProps(MakeElement("Label", "Select option", 13), {
							Size = UDim2.new(1, -160, 1, 0),
							Position = UDim2.new(0, 120, 0, 0),
							Font = Enum.Font.Gotham,
							Name = "Selected",
							TextXAlignment = Enum.TextXAlignment.Right,
							TextTruncate = Enum.TextTruncate.AtEnd
						}), "TextDark"),
						AddThemeObject(SetProps(MakeElement("Frame"), {
							Size = UDim2.new(1, 0, 0, 1),
							Position = UDim2.new(0, 0, 1, -1),
							Name = "Line",
							Visible = false
						}), "Stroke"),
						Click
					}), {
						Size = UDim2.new(1, 0, 0, 38),
						ClipsDescendants = true,
						Name = "Header"
					}),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					MakeElement("Corner")
				}), "Second")
			
				Relem(_tabName, DropdownConfig.Name, DdFrame)
				AddConnection(DdList:GetPropertyChangedSignal("AbsoluteContentSize"), function()
					DdCont.CanvasSize = UDim2.new(0, 0, 0, DdList.AbsoluteContentSize.Y)
				end)
				
				local vconn = AddConnection(MainWindow:GetPropertyChangedSignal("Visible"), function()
					if not MainWindow.Visible then
						relfcs()
						if Dropdown.Toggled then
							Dropdown.Toggled = false
							Dropdown.srchMode = false
							Dropdown:UpdVis()
						end
					end
				end)
				
				AddConnection(DdFrame.Destroying, function()
					if vconn and vconn.Connected then
						vconn:Disconnect()
					end
				end)
				
				local function CrtOpt(optData, group)
					local optTxt, optIcon, optVal, dispName, uname
					
					if type(optData) == "table" then
						optTxt = optData.text or optData.name or tostring(optData.value)
						optIcon = optData.icon
						optVal = optData.value or optTxt
					else
						optTxt = tostring(optData)
						optVal = optData
					end
				
					if Dropdown.isPDrop then
						local name, dispExt = optTxt:match("^(.-)%s%((.-)%)$")
						uname = name or optTxt
						dispName = dispExt or optTxt
					end
				
					local optH = Dropdown.isPDrop and 60 or 28
					local OptBtn
				
					if Dropdown.isPDrop then
						OptBtn = AddThemeObject(SetProps(SetChildren(MakeElement("Button", Color3.fromRGB(40, 40, 40)), {
							MakeElement("Corner", 0, 6),
							AddThemeObject(SetProps(MakeElement("Label", dispName, 13, 0), {
								Name = "DisplayName",
								Position = UDim2.new(0, 60, 0, 8),
								Size = UDim2.new(1, -70, 0, 16),
								Font = Enum.Font.GothamBold,
								TextXAlignment = Enum.TextXAlignment.Left,
								TextColor3 = Color3.fromRGB(255, 255, 255),
								BackgroundTransparency = 1
							}), "Text"),
							AddThemeObject(SetProps(MakeElement("Label", uname, 12, 0.3), {
								Name = "Username",
								Position = UDim2.new(0, 60, 0, 26),
								Size = UDim2.new(1, -70, 0, 14),
								Font = Enum.Font.Gotham,
								TextXAlignment = Enum.TextXAlignment.Left,
								TextColor3 = Color3.fromRGB(200, 200, 200),
								BackgroundTransparency = 1
							}), "Text"),
							AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 10), {
								Size = UDim2.new(0, 50, 0, 50),
								Position = UDim2.new(0, 5, 0, 5)
							}), {
								SetProps(MakeElement("Image", "https://www.roblox.com/headshot-thumbnail/image?userId=" .. (vgs.ps:FindFirstChild(uname) and vgs.ps[uname].UserId or 1) .. "&width=420&height=420&format=png"), {
									Size = UDim2.new(1, 0, 1, 0),
									BackgroundTransparency = 1
								}),
								MakeElement("Corner", 1)
							}), "Divider")
						}), {
							Parent = group or DdCont,
							Size = UDim2.new(1, 0, 0, optH),
							BackgroundTransparency = 1,
							ClipsDescendants = true
						}), "Divider")
				
						local ucorn = Instance.new("UICorner", OptBtn:FindFirstChild("Frame"):FindFirstChild("ImageLabel"))
						ucorn.CornerRadius = UDim.new(0, 10)
					else
						OptBtn = AddThemeObject(SetProps(SetChildren(MakeElement("Button", Color3.fromRGB(40, 40, 40)), {
							MakeElement("Corner", 0, 6),
							optIcon and SetProps(MakeElement("Image", optIcon), {
								Size = UDim2.new(0, 16, 0, 16),
								Position = UDim2.new(0, 8, 0.5, 0),
								AnchorPoint = Vector2.new(0, 0.5),
								Name = "Icon"
							}) or MakeElement("TFrame"),
							AddThemeObject(SetProps(MakeElement("Label", optTxt, 13, 0.4), {
								Position = UDim2.new(0, optIcon and 32 or 8, 0, 0),
								Size = UDim2.new(1, optIcon and -40 or -16, 1, 0),
								Name = "Title",
								TextXAlignment = Enum.TextXAlignment.Left
							}), "Text"),
							DropdownConfig.Multi and SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(60, 60, 60), 0, 2), {
								Size = UDim2.new(0, 16, 0, 16),
								Position = UDim2.new(1, -24, 0.5, 0),
								AnchorPoint = Vector2.new(0, 0.5),
								Name = "Checkbox"
							}), {
								SetProps(MakeElement("Stroke"), {
									Color = Color3.fromRGB(60, 60, 60),
									Thickness = 1,
									Name = "Stroke"
								}),
								SetProps(MakeElement("Image", "rbxassetid://3944680095"), {
									Size = UDim2.new(0, 15, 0, 15),
									AnchorPoint = Vector2.new(0.5, 0.5),
									Position = UDim2.new(0.5, 0, 0.5, 0),
									ImageColor3 = Color3.fromRGB(255, 255, 255),
									Name = "Ico"
								})
							}) or MakeElement("TFrame")
						}), {
							Parent = group or DdCont,
							Size = UDim2.new(1, 0, 0, optH),
							BackgroundTransparency = 1,
							ClipsDescendants = true
						}), "Divider")
					end
					
					AddConnection(OptBtn.MouseButton1Click, function()
						if DropdownConfig.Multi then
							local index = table.find(Dropdown.Value, optVal)
							if index then
								table.remove(Dropdown.Value, index)
							else
								table.insert(Dropdown.Value, optVal)
							end
							Dropdown:UpdSel()
						else
							Dropdown:Set(optVal)
							Dropdown.Toggled = false
							Dropdown.srchMode = false
							
							if DropdownConfig.Searchable and SrchBox then
								SrchBox.Text = ""
								Dropdown.srchTxt = ""
								relfcs()
							end
							
							Dropdown:UpdVis()
						end
						pcall(function()
							SaveCfg(game.GameId)
						end)
					end)
				
					AddConnection(OptBtn.MouseEnter, function()
						vgs.TS:Create(OptBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.8}):Play()
					end)
				
					AddConnection(OptBtn.MouseLeave, function()
						local sel = DropdownConfig.Multi and table.find(Dropdown.Value, optVal) or (Dropdown.Value == optVal)
						vgs.TS:Create(OptBtn, TweenInfo.new(0.15), {BackgroundTransparency = sel and 0.2 or 1}):Play()
					end)
				
					Dropdown.Buttons[optVal] = OptBtn
					return OptBtn
				end
				
				local function CrtGrp(gName, opts)
					local GrpFrame = SetChildren(SetProps(MakeElement("TFrame"), {
						Size = UDim2.new(1, 0, 0, 0),
						Parent = DdCont,
						Name = " " .. gName,
						AutomaticSize = Enum.AutomaticSize.Y
					}), {
						MakeElement("List", 0, 2),
						AddThemeObject(SetProps(MakeElement("Label", " " .. gName, 12), {
							Size = UDim2.new(1, -16, 0, 20),
							Position = UDim2.new(0, 8, 0, 0),
							Font = Enum.Font.GothamBold,
							Name = "GroupHeader",
							TextXAlignment = Enum.TextXAlignment.Left
						}), "TextDark")
					})
			
					Dropdown.Groups[gName] = GrpFrame
			
					for _, option in pairs(opts) do
						CrtOpt(option, GrpFrame)
					end
			
					return GrpFrame
				end
			
				local function FiltrOpts()
					if not DropdownConfig.Searchable or Dropdown.srchTxt == "" then
						for _, btn in pairs(Dropdown.Buttons) do
							btn.Visible = true
						end
						for _, group in pairs(Dropdown.Groups) do
							group.Visible = true
						end
						return
					end
					
					local srchLow = string.lower(Dropdown.srchTxt)
					for value, btn in pairs(Dropdown.Buttons) do
						local srchTxt = ""
						if Dropdown.isPDrop then
							if btn:FindFirstChild("DisplayName") then
								srchTxt = srchTxt .. string.lower(btn.DisplayName.Text) .. " "
							end
							if btn:FindFirstChild("Username") then
								srchTxt = srchTxt .. string.lower(btn.Username.Text)
							end
						else
							if btn:FindFirstChild("Title") then
								srchTxt = string.lower(btn.Title.Text)
							end
						end
						btn.Visible = string.find(srchTxt, srchLow) ~= nil
					end
					
					for _, group in pairs(Dropdown.Groups) do
						local hasVis = false
						for _, child in pairs(group:GetChildren()) do
							if child:IsA("TextButton") and child.Visible then
								hasVis = true
								break
							end
						end
						group.Visible = hasVis
					end
				end
				
				local function StaggerAnim()
					local visibleBtns = {}
					for _, btn in pairs(Dropdown.Buttons) do
						if btn.Visible then
							table.insert(visibleBtns, btn)
						end
					end
					
					for i, btn in ipairs(visibleBtns) do
						local delay = (i - 1) * 0.02
						spawn(function()
							wait(delay)
							vgs.TS:Create(btn, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
								Position = UDim2.new(0, 0, 0, 0),
								BackgroundTransparency = btn.BackgroundTransparency
							}):Play()
						end)
					end
				end
				
				function Dropdown:UpdSel(mode)
					local selTxt = ""
					if self.Multi then  
						if type(self.Value) == "table" and #self.Value > 0 then
							local vVals = {}
							for _, v in pairs(self.Value) do
								if type(v) == "string" or type(v) == "number" then
									table.insert(vVals, tostring(v))
								end
							end
							selTxt = #vVals > 0 and table.concat(vVals, ", ") or "Select options"
						else
							selTxt = "Select options"
						end
					else
						selTxt = tostring(self.Value ~= "" and self.Value or "Select option")
					end
					DdFrame.Header.Selected.Text = selTxt
				
					for value, btn in pairs(self.Buttons) do
						local sel = self.Multi and table.find(self.Value, value) or (self.Value == value)
						local twInf = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				
						vgs.TS:Create(btn, twInf, {BackgroundTransparency = sel and 0.2 or 1}):Play()
				
						if self.isPDrop then
							if btn:FindFirstChild("DisplayName") then
								vgs.TS:Create(btn.DisplayName, twInf, {TextTransparency = sel and 0 or 0.4}):Play()
							end
							if btn:FindFirstChild("Username") then
								vgs.TS:Create(btn.Username, twInf, {TextTransparency = sel and 0 or 0.4}):Play()
							end
						else
							if btn:FindFirstChild("Title") then
								vgs.TS:Create(btn.Title, twInf, {TextTransparency = sel and 0 or 0.4}):Play()
							end
						end
				
						if self.Multi and btn:FindFirstChild("Checkbox") then
							vgs.TS:Create(btn.Checkbox, twInf, {
								BackgroundColor3 = sel and OrionLib.Themes[OrionLib.SelectedTheme].Accent or OrionLib.Themes[OrionLib.SelectedTheme].Divider
							}):Play()
							
							if btn.Checkbox:FindFirstChild("Stroke") then
								vgs.TS:Create(btn.Checkbox.Stroke, twInf, {
									Color = sel and OrionLib.Themes[OrionLib.SelectedTheme].Accent or OrionLib.Themes[OrionLib.SelectedTheme].Stroke
								}):Play()
							end
							
							if btn.Checkbox:FindFirstChild("Ico") then
								vgs.TS:Create(btn.Checkbox.Ico, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
									ImageTransparency = sel and 0 or 1, 
									Size = sel and UDim2.new(0, 15, 0, 15) or UDim2.new(0, 8, 0, 8)
								}):Play()
							end
						end
					end
					
					if self.Multi and DropdownConfig.Call and mode ~= 1 then 
						pcall(function()
							DropdownConfig.Callback(self.Value)
						end)
					end
				end
			
				function Dropdown:UpdVis()
					local srchTglH = DropdownConfig.Searchable and self.Toggled and 34 or 0
					local srchBoxH = DropdownConfig.Searchable and self.srchMode and 34 or 0
					local totSrchH = srchTglH + srchBoxH
					
					DdCont.Visible = self.Toggled
					DdFrame.Header.Line.Visible = self.Toggled
					
					if DropdownConfig.Searchable and SrchTgl then
						SrchTgl.Visible = self.Toggled
					end
					
					if DropdownConfig.Searchable and SrchCont then
						SrchCont.Visible = self.srchMode
					end
					
					if not self.Toggled or not self.srchMode then
						relfcs()
					end
					
					local newPos = UDim2.new(0, 0, 0, 38 + totSrchH)
					local newSz = UDim2.new(1, 0, 1, -(38 + totSrchH))
					
					vgs.TS:Create(DdCont, TweenInfo.new(0.15), {
						Position = newPos,
						Size = newSz
					}):Play()
					
					vgs.TS:Create(DdFrame.Header.Arrow, TweenInfo.new(0.15), {Rotation = self.Toggled and 0 or 180}):Play()
			
					local cntH = 0
					if self.Toggled then
						local totBtns = 0
						for _, btn in pairs(self.Buttons) do
							if btn.Visible then
								totBtns = totBtns + 1
							end
						end
						local btnH = self.isPDrop and 60 or 28
						cntH = math.min(totBtns, MaxElems) * btnH + totSrchH
					end
			
					local totH = self.Toggled and (38 + cntH) or 38
					vgs.TS:Create(DdFrame, TweenInfo.new(0.15), {Size = UDim2.new(1, 0, 0, totH)}):Play()
			
					if self.Toggled then
						for _, btn in pairs(self.Buttons) do
							if btn.Visible then
								btn.Position = UDim2.new(0, -10, 0, 0)
							end
						end
						task.wait(0.05)
						StaggerAnim()
					end
			
					if DropdownConfig.Searchable and SrchBox then
						if self.Toggled and self.srchMode then
							spawn(function()
								wait(0.1)
								SrchBox:CaptureFocus()
							end)
						else
							relfcs()
							if not self.srchMode then
								SrchBox.Text = ""
								self.srchTxt = ""
								FiltrOpts()
							end
						end
					end
				end
				
				function Dropdown:Get()
					return self.Value
				end
				
				function Dropdown:Has(Value)
					if DropdownConfig.Multi then
						return table.find(self.Value, Value) ~= nil
					else
						return self.Value == Value
					end
				end
				
				function Dropdown:Set(Value, AddMode)
					if DropdownConfig.Multi then
						local changed = false
						
						if AddMode ~= nil then
							local values = type(Value) == "table" and Value or {Value}
							for _, v in pairs(values) do
								if not table.find(self.Options, v) then continue end
								
								local index = table.find(self.Value, v)
								if AddMode and not index then
									table.insert(self.Value, v)
									changed = true
								elseif not AddMode and index then
									table.remove(self.Value, index)
									changed = true
								end
							end
						else
							local newValues = type(Value) == "table" and Value or {Value}
							local validValues = {}
							
							for _, v in pairs(newValues) do
								if table.find(self.Options, v) then
									table.insert(validValues, v)
								end
							end
							
							if #validValues ~= #self.Value then
								changed = true
							else
								for _, v in pairs(validValues) do
									if not table.find(self.Value, v) then
										changed = true
										break
									end
								end
							end
							
							self.Value = validValues
						end
						
						if changed then
							self:UpdSel(1)
							if DropdownConfig.Call then
								pcall(function()
									DropdownConfig.Callback(self.Value)
								end)
							end
						end
					else
						if not table.find(self.Options, Value) then
							self.Value = "..."
							DdFrame.Header.Selected.Text = self.Value
							
							for _, v in pairs(self.Buttons) do
								vgs.TS:Create(v, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
								
								if self.isPDrop then
									if v:FindFirstChild("DisplayName") then
										vgs.TS:Create(v.DisplayName, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0.4}):Play()
									end
									if v:FindFirstChild("Username") then
										vgs.TS:Create(v.Username, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0.4}):Play()
									end
								else
									if v:FindFirstChild("Title") then
										vgs.TS:Create(v.Title, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0.4}):Play()
									end
								end
							end
							return
						end
				
						self.Value = Value
						DdFrame.Header.Selected.Text = self.Value
				
						for _, v in pairs(self.Buttons) do
							vgs.TS:Create(v, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
							
							if self.isPDrop then
								if v:FindFirstChild("DisplayName") then
									vgs.TS:Create(v.DisplayName, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0.4}):Play()
								end
								if v:FindFirstChild("Username") then
									vgs.TS:Create(v.Username, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0.4}):Play()
								end
							else
								if v:FindFirstChild("Title") then
									vgs.TS:Create(v.Title, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0.4}):Play()
								end
							end
						end
						
						if self.Buttons[Value] then
							vgs.TS:Create(self.Buttons[Value], TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.2}):Play()
							
							if self.isPDrop then
								if self.Buttons[Value]:FindFirstChild("DisplayName") then
									vgs.TS:Create(self.Buttons[Value].DisplayName, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
								end
								if self.Buttons[Value]:FindFirstChild("Username") then
									vgs.TS:Create(self.Buttons[Value].Username, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
								end
							else
								if self.Buttons[Value]:FindFirstChild("Title") then
									vgs.TS:Create(self.Buttons[Value].Title, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
								end
							end
						end
						
						pcall(function()
							DropdownConfig.Callback(self.Value)
						end)
					end
				end
				
				function Dropdown:Refresh(Options, Delete)
					if Delete then
						for _, v in pairs(self.Buttons) do
							v:Destroy()
						end
						for _, v in pairs(self.Groups) do
							v:Destroy()
						end
						table.clear(self.Options)
						table.clear(self.Buttons)
						table.clear(self.Groups)
					end
					self.Options = Options
					DropdownConfig.Options = Options
					self.isPDrop = DtctPDrop()
				
					if DropdownConfig.Grouped then
						for gName, grpOpts in pairs(Options) do
							CrtGrp(gName, grpOpts)
						end
					else
						for _, option in pairs(Options) do
							CrtOpt(option)
						end
					end
					
					if self.isPDrop then
						local preload = {}
						for _, option in pairs(Options) do
							local optTxt = type(option) == "table" and (option.text or option.name) or tostring(option)
							local uname = optTxt:match("^(.-) %(") or optTxt
							if vgs and vgs.ps and vgs.ps:FindFirstChild(uname) then
								local userId = vgs.ps[uname].UserId
								local imurl = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. userId .. "&width=420&height=420&format=png"
								table.insert(preload, imurl)
							end
						end
						if #preload > 0 then
							task.spawn(function()
								game:GetService("ContentProvider"):PreloadAsync(preload)
							end)
						end
					end
					
					if DropdownConfig.Searchable and self.srchTxt ~= "" then
						FiltrOpts()
					end
					
					if self.Toggled then
						self:UpdVis()
					end
					self:UpdSel()
				end
			
				AddConnection(Click.MouseButton1Click, function()
					Dropdown.Toggled = not Dropdown.Toggled
					if not Dropdown.Toggled then
						Dropdown.srchMode = false
					end
					Dropdown:UpdVis()
				end)
			
				if DropdownConfig.Searchable and SrchTgl then
					AddConnection(SrchTgl.MouseButton1Click, function()
						Dropdown.srchMode = not Dropdown.srchMode
						vgs.TS:Create(SrchTgl.SearchArrow, TweenInfo.new(0.15), {
							Rotation = Dropdown.srchMode and 0 or 180
						}):Play()
						Dropdown:UpdVis()
					end)
			
					AddConnection(SrchTgl.MouseEnter, function()
						vgs.TS:Create(SrchTgl.SearchArrow, TweenInfo.new(0.15), {
							ImageColor3 = Color3.fromRGB(255, 255, 255)
						}):Play()
					end)
			
					AddConnection(SrchTgl.MouseLeave, function()
						vgs.TS:Create(SrchTgl.SearchArrow, TweenInfo.new(0.15), {
							ImageColor3 = Color3.fromRGB(160, 160, 160)
						}):Play()
					end)
				end
			
				if DropdownConfig.Searchable and SrchBox then
					AddConnection(SrchBox:GetPropertyChangedSignal("Text"), function()
						Dropdown.srchTxt = SrchBox.Text
						FiltrOpts()
						Dropdown:UpdVis()
					end)
			
					AddConnection(SrchBox.Focused, function()
						SrchBox.TextXAlignment = Enum.TextXAlignment.Left
					end)
					
					AddConnection(SrchBox.FocusLost, function()
						if SrchBox.Text == "" then
							SrchBox.TextXAlignment = Enum.TextXAlignment.Left
						end
					end)
				end
			
				AddConnection(vgs.UIS.InputBegan, function(input, gameProcessed)
					if gameProcessed or not Dropdown.Toggled then
						return
					end
					if input.KeyCode == Enum.KeyCode.Escape then
						Dropdown.Toggled = false
						Dropdown.srchMode = false
						relfcs()
						Dropdown:UpdVis()
					end
				end)
			
				Dropdown:Refresh(Dropdown.Options, false)
				
				if DropdownConfig.Multi then
					Dropdown:UpdSel(1)
				else
					Dropdown:Set(Dropdown.Value)
				end
				
				if DropdownConfig.Flag then
					OrionLib.Flags[DropdownConfig.Flag] = Dropdown
				end
			
				table.insert(OrionLib.Dropdowns, Dropdown)
				
				if vgs and vgs.ps then
					AddConnection(vgs.ps.PlayerAdded, function(plr)
						Dropdown.isPDrop = DtctPDrop()
						
						if DropdownConfig.Searchable and Dropdown.srchTxt ~= "" then
							FiltrOpts()
						end
					end)
					
					vgs.ps.PlayerRemoving:Connect(function(plr)
						if not Dropdown.isPDrop then return end
						
						local pName = plr.Name
						
						for i = #Dropdown.Options, 1, -1 do
							local optTxt = type(Dropdown.Options[i]) == "table" and (Dropdown.Options[i].text or Dropdown.Options[i].name) or tostring(Dropdown.Options[i])
							local name = optTxt:match("^(.-) %(") or optTxt
							
							if name == pName then
								local optVal = type(Dropdown.Options[i]) == "table" and (Dropdown.Options[i].value or optTxt) or Dropdown.Options[i]
								
								if Dropdown.Buttons[optVal] then
									Dropdown.Buttons[optVal]:Destroy()
									Dropdown.Buttons[optVal] = nil
								end
								
								table.remove(Dropdown.Options, i)
							end
						end
						
						if DropdownConfig.Multi then
							for i = #Dropdown.Value, 1, -1 do
								local optTxt = Dropdown.Value[i]
								local name = optTxt:match("^(.-) %(") or optTxt
								
								if name == pName then
									table.remove(Dropdown.Value, i)
								end
							end
							DropdownConfig.Callback(Dropdown.Value)
						else
							local currName = Dropdown.Value:match("^(.-) %(") or Dropdown.Value
							if currName == pName then
								if DropdownConfig.PlrLeftNote then
									OrionLib:MakeNotification({
										Name = "Selected Player left.",
										Content = plr.DisplayName .. " left the Game.",
										Image = "rbxassetid://7733911828",
										Time = 5
									})
								end
								Dropdown:Set("...")
							end
						end
			
						Dropdown:UpdSel()
			
						if DropdownConfig.Searchable and Dropdown.srchTxt ~= "" then
							FiltrOpts()
						end
						
						if Dropdown.Toggled then
							Dropdown:UpdVis()
						end
					end)
				end
					
				return Dropdown
			end
			
			function ElementFunction:FreeMouseDrp()
				return self:AddDropdown({
					Name = "Unlock Mouse Mode",
					Options = {"ThirdPerson", "FreeMouse"},
					Default = OrionLib.UMouseMode, 
					Callback = function(Value)
						OrionLib.UMouseMode = Value 
						if OrionLib.FreeMouse then
							UnlockMouse(false)
							task.wait(0.1)
							UnlockMouse(true)
						end
					end
				})
			end

			function ElementFunction:AddBind(BindConfig)
				BindConfig.Name = BindConfig.Name or "Bind"
				BindConfig.Default = BindConfig.Default or Enum.KeyCode.Unknown
				BindConfig.Hold = BindConfig.Hold or false
				BindConfig.Callback = BindConfig.Callback or function() end
				BindConfig.Flag = BindConfig.Flag or nil
				BindConfig.Save = BindConfig.Save or false

				local Bind = {Value, Binding = false, Type = "Bind", Save = BindConfig.Save}
				local Holding = false

				local Click = SetProps(MakeElement("Button"), {
					Size = UDim2.new(1, 0, 1, 0)
				})

				local BindBox = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
					Size = UDim2.new(0, 24, 0, 24),
					Position = UDim2.new(1, -12, 0.5, 0),
					AnchorPoint = Vector2.new(1, 0.5)
				}), {
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					AddThemeObject(SetProps(MakeElement("Label", BindConfig.Name, 14), {
						Size = UDim2.new(1, 0, 1, 0),
						Font = Enum.Font.GothamBold,
						TextXAlignment = Enum.TextXAlignment.Center,
						Name = "Value"
					}), "Text")
				}), "Main")

				local BindFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 38),
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", BindConfig.Name, 15), {
						Size = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold,
						Name = "Content"
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					BindBox,
					Click
				}), "Second")
				Relem(_tabName, BindConfig.Name, BindFrame)
				AddConnection(BindBox.Value:GetPropertyChangedSignal("Text"), function()
					vgs.TS:Create(BindBox, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, BindBox.Value.TextBounds.X + 19, 0, 24)}):Play()
				end)

				AddConnection(Click.InputEnded, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						if Bind.Binding then return end
						Bind.Binding = true
						BindBox.Value.Text = ""
					end
				end)

				AddConnection(vgs.UIS.InputBegan, function(Input)
					if vgs.UIS:GetFocusedTextBox() then return end
					if (Input.KeyCode.Name == Bind.Value or Input.UserInputType.Name == Bind.Value) and not Bind.Binding then
						if BindConfig.Hold then
							Holding = true
							BindConfig.Callback(Holding)
						else
							BindConfig.Callback(Input)
						end
					elseif Bind.Binding then
						local Key
						pcall(function()
							if not CheckKey(BlacklistedKeys, Input.KeyCode) then
								Key = Input.KeyCode
							end
						end)
						pcall(function()
							if CheckKey(WhitelistedMouse, Input.UserInputType) and not Key then
								Key = Input.UserInputType
							end
						end)
						Key = Key or Bind.Value
						Bind:Set(Key)
						SaveCfg(game.GameId)
					end
				end)

				AddConnection(vgs.UIS.InputEnded, function(Input)
					if Input.KeyCode.Name == Bind.Value or Input.UserInputType.Name == Bind.Value then
						if BindConfig.Hold and Holding then
							Holding = false
							BindConfig.Callback(Holding)
						end
					end
				end)

				AddConnection(Click.MouseEnter, function()
					vgs.TS:Create(BindFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
				end)

				AddConnection(Click.MouseLeave, function()
					vgs.TS:Create(BindFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second}):Play()
				end)

				AddConnection(Click.MouseButton1Up, function()
					vgs.TS:Create(BindFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
				end)

				AddConnection(Click.MouseButton1Down, function()
					vgs.TS:Create(BindFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 6)}):Play()
				end)

				function Bind:Set(Key)
					Bind.Binding = false
					Bind.Value = Key or Bind.Value
					Bind.Value = Bind.Value.Name or Bind.Value
					BindBox.Value.Text = Bind.Value
				end

				Bind:Set(BindConfig.Default)
				if BindConfig.Flag then				
					OrionLib.Flags[BindConfig.Flag] = Bind
				end
				return Bind
			end  
			function ElementFunction:AddTextbox(TextboxConfig)
				TextboxConfig = TextboxConfig or {}
				TextboxConfig.Name = TextboxConfig.Name or "Textbox"
				TextboxConfig.Default = TextboxConfig.Default or ""
				TextboxConfig.TextDisappear = TextboxConfig.TextDisappear or false
				TextboxConfig.BackGrountText = TextboxConfig.BackGrountText or "Input"
				TextboxConfig.Callback = TextboxConfig.Callback or function() end

				local Click = SetProps(MakeElement("Button"), {
					Size = UDim2.new(1, 0, 1, 0)
				})

				local TextboxActual = AddThemeObject(Create("TextBox", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					PlaceholderColor3 = Color3.fromRGB(210,210,210),
					PlaceholderText = TextboxConfig.BackGrountText,
					Font = Enum.Font.GothamSemibold,
					TextXAlignment = Enum.TextXAlignment.Center,
					TextSize = 14,
					ClearTextOnFocus = false
				}), "Text")

				local TextContainer = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
					Size = UDim2.new(0, 24, 0, 24),
					Position = UDim2.new(1, -12, 0.5, 0),
					AnchorPoint = Vector2.new(1, 0.5)
				}), {
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					TextboxActual
				}), "Main")


				local TextboxFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 38),
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", TextboxConfig.Name, 15), {
						Size = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold,
						Name = "Content"
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					TextContainer,
					Click
				}), "Second")
				Relem(_tabName, TextboxConfig.Name, TextboxFrame)
				AddConnection(TextboxActual:GetPropertyChangedSignal("Text"), function()
					vgs.TS:Create(TextContainer, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, TextboxActual.TextBounds.X + 16, 0, 24)}):Play()
				end)

				AddConnection(TextboxActual.FocusLost, function()
					TextboxConfig.Callback(TextboxActual.Text)
					if TextboxConfig.TextDisappear then
						TextboxActual.Text = ""
					end	
				end)

				TextboxActual.Text = TextboxConfig.Default

				AddConnection(Click.MouseEnter, function()
					vgs.TS:Create(TextboxFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
				end)

				AddConnection(Click.MouseLeave, function()
					vgs.TS:Create(TextboxFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second}):Play()
				end)

				AddConnection(Click.MouseButton1Up, function()
					vgs.TS:Create(TextboxFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
					TextboxActual:CaptureFocus()
				end)

				AddConnection(Click.MouseButton1Down, function()
					vgs.TS:Create(TextboxFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 6)}):Play()
				end)
			end 
			function ElementFunction:AddColorpicker(ColorpickerConfig)
				ColorpickerConfig = ColorpickerConfig or {}
				ColorpickerConfig.Name = ColorpickerConfig.Name or "Colorpicker"
				ColorpickerConfig.Default = ColorpickerConfig.Default or Color3.fromRGB(255, 255, 255)
				ColorpickerConfig.Callback = ColorpickerConfig.Callback or function() end
				ColorpickerConfig.Flag = ColorpickerConfig.Flag or nil
				ColorpickerConfig.Save = ColorpickerConfig.Save or false
				ColorpickerConfig.Mode = ColorpickerConfig.Mode or 1
			
				local ColorH, ColorS, ColorV = Color3.toHSV(ColorpickerConfig.Default)
				local Colorpicker = {
					Value = ColorpickerConfig.Default,
					Toggled = false,
					Type = "Colorpicker",
					Save = ColorpickerConfig.Save
				}
			
				local ColorSelection = Create("ImageLabel", {
					Size = UDim2.new(0, 10, 0, 10),
					Position = UDim2.new(ColorS, 0, 1 - ColorV),
					ScaleType = Enum.ScaleType.Stretch,
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = "http://www.roblox.com/asset/?id=4805639000"
				})
				local HueSelection = Create("ImageLabel", {
					Size = UDim2.new(0, 10, 0, 10),
					Position = UDim2.new(0.5, 0, 1 - ColorH),
					ScaleType = Enum.ScaleType.Stretch,
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = "http://www.roblox.com/asset/?id=4805639000"
				})
				
				local Color = Create("ImageLabel", {
					Size = UDim2.new(1, -25, 1, 0),
					Visible = false,
					Image = "rbxassetid://4155801252",
					ScaleType = Enum.ScaleType.Stretch,
					BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				}, {Create("UICorner", {CornerRadius = UDim.new(0, 5)}), ColorSelection})
			
				local Hue = Create("Frame", {
					Size = UDim2.new(0, 20, 1, 0),
					Position = UDim2.new(1, -20, 0, 0),
					Visible = false
				}, {
					Create("UIGradient", {
						Rotation = 270,
						Color = ColorSequence.new{
							ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 4)),
							ColorSequenceKeypoint.new(0.20, Color3.fromRGB(234, 255, 0)),
							ColorSequenceKeypoint.new(0.40, Color3.fromRGB(21, 255, 0)),
							ColorSequenceKeypoint.new(0.60, Color3.fromRGB(0, 255, 255)),
							ColorSequenceKeypoint.new(0.80, Color3.fromRGB(0, 17, 255)),
							ColorSequenceKeypoint.new(0.90, Color3.fromRGB(255, 0, 251)),
							ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 4))
						}
					}),
					Create("UICorner", {CornerRadius = UDim.new(0, 3)}),
					HueSelection
				})
			
				local ColorpickerContainer = Create("Frame", {
					Position = UDim2.new(0, 0, 0, 32),
					Size = UDim2.new(1, 0, 1, -32),
					BackgroundTransparency = 1,
					ClipsDescendants = true
				}, {
					Hue, Color,
					Create("UIPadding", {
						PaddingLeft = UDim.new(0, 35),
						PaddingRight = UDim.new(0, 35),
						PaddingBottom = UDim.new(0, 10),
						PaddingTop = UDim.new(0, 17)
					})
				})
			
				local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1, 0, 1, 0)})
				local ColorpickerBox = SetChildren(SetProps(MakeElement("RoundFrame", ColorpickerConfig.Default, 0, 4), {
					Size = UDim2.new(0, 24, 0, 24),
					Position = UDim2.new(1, -12, 0.5, 0),
					AnchorPoint = Vector2.new(1, 0.5)
				}), {AddThemeObject(MakeElement("Stroke"), "Stroke")})
			
				local ColorpickerFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 38),
					Parent = ItemParent
				}), {
					SetProps(SetChildren(MakeElement("TFrame"), {
						AddThemeObject(SetProps(MakeElement("Label", ColorpickerConfig.Name, 15), {
							Size = UDim2.new(1, -12, 1, 0),
							Position = UDim2.new(0, 12, 0, 0),
							Font = Enum.Font.GothamBold,
							Name = "Content"
						}), "Text"),
						ColorpickerBox,
						Click,
						AddThemeObject(SetProps(MakeElement("Frame"), {
							Size = UDim2.new(1, 0, 0, 1),
							Position = UDim2.new(0, 0, 1, -1),
							Name = "Line",
							Visible = false
						}), "Stroke")
					}), {
						Size = UDim2.new(1, 0, 0, 38),
						ClipsDescendants = true,
						Name = "F"
					}),
					ColorpickerContainer,
					AddThemeObject(MakeElement("Stroke"), "Stroke")
				}), "Second")
			
				Relem(_tabName, ColorpickerConfig.Name, ColorpickerFrame)
			
				local ColorInput, HueInput
			
				AddConnection(Click.MouseButton1Click, function()
					Colorpicker.Toggled = not Colorpicker.Toggled
					vgs.TS:Create(ColorpickerFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
						Size = Colorpicker.Toggled and UDim2.new(1, 0, 0, 148) or UDim2.new(1, 0, 0, 38)
					}):Play()
					Color.Visible = Colorpicker.Toggled
					Hue.Visible = Colorpicker.Toggled
					ColorpickerFrame.F.Line.Visible = Colorpicker.Toggled
				end)
			
				local function UpdateColorPicker()
					ColorpickerBox.BackgroundColor3 = Color3.fromHSV(ColorH, ColorS, ColorV)
					Color.BackgroundColor3 = Color3.fromHSV(ColorH, 1, 1)
					Colorpicker.Value = ColorpickerBox.BackgroundColor3 
					if ColorpickerConfig.Mode == 1 then
						ColorpickerConfig.Callback(Colorpicker.Value)
					end
					if ColorpickerConfig.Save then SaveCfg(game.GameId) end
				end
			
				AddConnection(Color.InputBegan, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						if ColorInput then ColorInput:Disconnect() end
						ColorInput = AddConnection(vgs.RS.Heartbeat, function(dt)
							acc += dt
							if acc < rate then
								return
							end
							acc -= rate
						
							local ax, ay = Color.AbsolutePosition.X, Color.AbsolutePosition.Y
							local aw, ah = Color.AbsoluteSize.X, Color.AbsoluteSize.Y
							local x = math.clamp(vgs.MS.X - ax, 0, aw) / aw
							local y = math.clamp(vgs.MS.Y - ay, 0, ah) / ah
						
							ColorSelection.Position = UDim2.new(x, 0, y, 0)
							ColorS, ColorV = x, 1 - y
							UpdateColorPicker()
						end)
					end
				end)
			
				AddConnection(Color.InputEnded, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 and ColorInput then
						if ColorpickerConfig.Mode == 2 then
							ColorpickerConfig.Callback(Colorpicker.Value)
						end
						ColorInput:Disconnect()
						ColorInput = nil
					end
				end)
			
				AddConnection(Hue.InputBegan, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						if HueInput then HueInput:Disconnect() end
						HueInput = AddConnection(vgs.RS.Heartbeat, function(dt)
							acc += dt
							if acc < rate then
								return
							end
							acc -= rate
							local ay, ah = Hue.AbsolutePosition.Y, Hue.AbsoluteSize.Y
							local y = math.clamp(vgs.MS.Y - ay, 0, ah) / ah
							HueSelection.Position = UDim2.new(0.5, 0, y, 0)
							ColorH = 1 - y
							UpdateColorPicker()
						end)
					end
				end)
			
				AddConnection(Hue.InputEnded, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 and HueInput then
						if ColorpickerConfig.Mode == 2 then
							ColorpickerConfig.Callback(Colorpicker.Value)
						end
						HueInput:Disconnect()
						HueInput = nil
					end
				end)
			
				function Colorpicker:Set(Value)
					Colorpicker.Value = Value
					ColorH, ColorS, ColorV = Color3.toHSV(Value)
					ColorpickerBox.BackgroundColor3 = Value
					Color.BackgroundColor3 = Color3.fromHSV(ColorH, 1, 1) --Color3.fromHSV(ColorH, 1, 1)
					ColorSelection.Position = UDim2.new(ColorS, 0, 1 - ColorV)
					HueSelection.Position = UDim2.new(0.5, 0, 1 - ColorH)
					ColorpickerConfig.Callback(Value)
				end
			
				Colorpicker:Set(ColorpickerConfig.Default)
				if ColorpickerConfig.Flag then OrionLib.Flags[ColorpickerConfig.Flag] = Colorpicker end
				return Colorpicker
			end
			function ElementFunction:AddUiBind()
				local UiBind = self:AddBind({
					Name = "Orion Bind",
					Default = WindowConfig.Openkey,
					Hold = false,
					Callback = function(Input)
					end
				})
				
				local oset = UiBind.Set
				function UiBind:Set(Key)
					local wbinding = self.Binding
					oset(self, Key)
					
					if wbinding and not self.Binding and self.Value ~= "Unknown" then
						task.wait(0.1)
						WindowConfig.Openkey = self.Value
					end
				end
				
				return UiBind
			end
			function ElementFunction:AddSmartTheme()
				local gersec = self
				
				
				gersec:AddColorpicker({
					Name = "Base Color",
					Default = OrionLib.Themes[OrionLib.SelectedTheme].Main,
					Mode = 2,
					Callback = function(Value)
						local newTheme = OrionLib:GenTheme(Value)
						OrionLib.Themes.Custom = newTheme
						OrionLib.SelectedTheme = "Custom"
						OrionLib:SetTheme()
					end
				})
				
				gersec:AddButton({
					Name = "Reset Theme",
					Callback = function()
						OrionLib.SelectedTheme = "Default"
						OrionLib:SetTheme()
					end
				})
				OrionLib.SelectedTheme = "Default"
				OrionLib:SetTheme()
			end
			
			return ElementFunction   
		end	
		

		local ElementFunction = {}
		
		function ElementFunction:AddSection(name)
			name = name or ""
		
			local SectionFrame = SetChildren(SetProps(MakeElement("TFrame"), {
				Size = UDim2.new(1, 0, 0, 26),
				Parent = Container
			}), {
				AddThemeObject(SetProps(MakeElement("Label", name, 14), {
					Size = UDim2.new(1, -12, 0, 16),
					Position = UDim2.new(0, 0, 0, 3),
					Font = Enum.Font.GothamSemibold
				}), "TextDark"),
				SetChildren(SetProps(MakeElement("TFrame"), {
					AnchorPoint = Vector2.new(0, 0),
					Size = UDim2.new(1, 0, 1, -24),
					Position = UDim2.new(0, 0, 0, 23),
					Name = "Holder"
				}), {
					MakeElement("List", 0, 6)
				}),
			})
			
			Relem(TabConfig.Name, name, SectionFrame) 
			
			AddConnection(SectionFrame.Holder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
				SectionFrame.Size = UDim2.new(1, 0, 0, SectionFrame.Holder.UIListLayout.AbsoluteContentSize.Y + 31)
				SectionFrame.Holder.Size = UDim2.new(1, 0, 0, SectionFrame.Holder.UIListLayout.AbsoluteContentSize.Y)
			end)
		
			local SectionFunction = {}
			for i, v in next, Getelmnts(SectionFrame.Holder, TabConfig.Name) do  
				SectionFunction[i] = v 
			end
			return SectionFunction
		end

		for i, v in next, Getelmnts(Container, TabConfig.Name) do
			ElementFunction[i] = v 
		end

		if TabConfig.PremiumOnly then
			for i, v in next, ElementFunction do
				ElementFunction[i] = function() end
			end    
			Container:FindFirstChild("UIListLayout"):Destroy()
			Container:FindFirstChild("UIPadding"):Destroy()
			SetChildren(SetProps(MakeElement("TFrame"), {
				Size = UDim2.new(1, 0, 1, 0),
				Parent = ItemParent
			}), {
				AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://3610239960"), {
					Size = UDim2.new(0, 18, 0, 18),
					Position = UDim2.new(0, 15, 0, 15),
					ImageTransparency = 0.4
				}), "Text"),
				AddThemeObject(SetProps(MakeElement("Label", "Unauthorised Access", 14), {
					Size = UDim2.new(1, -38, 0, 14),
					Position = UDim2.new(0, 38, 0, 18),
					TextTransparency = 0.4
				}), "Text"),
				AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://4483345875"), {
					Size = UDim2.new(0, 56, 0, 56),
					Position = UDim2.new(0, 84, 0, 110),
				}), "Text"),
				AddThemeObject(SetProps(MakeElement("Label", "Premium Features", 14), {
					Size = UDim2.new(1, -150, 0, 14),
					Position = UDim2.new(0, 150, 0, 112),
					Font = Enum.Font.GothamBold
				}), "Text")
			})
		end
		return ElementFunction   
	end
	
	function Functions:Destroy()
		for _, Connection in next, OrionLib.Connections do
			Connection:Disconnect()
		end
		MainWindow:Destroy()
	end
	
	return Functions
end   

function OrionLib:Destroy()
	UnlockMouse(false)
	Orion:Destroy()
end

return OrionLib
