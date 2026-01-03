local vgs = {
    MS  =  game:GetService("Players").LocalPlayer:GetMouse(),
    p   =  game:GetService("Players").LocalPlayer,
    UIS =  game:GetService("UserInputService"),
    TS  =  game:GetService("TweenService"),
    HS  =  game:GetService("HttpService"),
    RS  =  game:GetService("RunService"),
    ps  =  game:GetService("Players")
}

local GuiParent = game.CoreGui

local OrionLib = {
    elmnts = {},
    ThemeObjects = {},
    Connections = {},
    Flags = {},
    Themes = {},
    SelectedTheme = "Default",
    UMouseMode = "ThirdPerson",
    Folder = nil,
    SaveCfg = false
}

function OrionLib:GenTheme(mainColor)
    local lum = 0.299 * mainColor.R + 0.587 * mainColor.G + 0.114 * mainColor.B
    local h, s, v = Color3.toHSV(mainColor)
    local dark = lum < 0.5
    local t = {Main = mainColor}
    
    if dark then
        t.Second = Color3.fromHSV(h, s * 0.95, math.clamp(v * 1.28, 0, 1))
        t.Stroke = Color3.fromHSV(h, s * 0.8, math.clamp(v * 2.4, 0, 1))
        t.Divider = Color3.fromHSV(h, s * 0.85, math.clamp(v * 2.0, 0, 1))
        local veryDark = lum < 0.15
        t.Text = Color3.fromHSV(h, math.min(s * (veryDark and 0.05 or 0.15), veryDark and 0.02 or 0.08), veryDark and 0.94 or 0.92)
        t.TextDark = Color3.fromHSV(h, math.min(s * (veryDark and 0.1 or 0.25), veryDark and 0.05 or 0.12), veryDark and 0.59 or 0.62)
        t.Accent = Color3.fromHSV(h, math.clamp(s * 1.8, 0.4, 1), math.clamp(v * 3.5, 0.3, 1))
    else
        t.Second = Color3.fromHSV(h, s * 0.9, math.clamp(v * 1.09, 0, 1))
        t.Stroke = Color3.fromHSV(h, s * 1.1, math.clamp(v * 0.82, 0, 1))
        t.Divider = Color3.fromHSV(h, s * 1.05, math.clamp(v * 0.91, 0, 1))
        local veryLight = lum > 0.85
        t.Text = Color3.fromHSV(h, math.min(s * (veryLight and 0.3 or 0.25), veryLight and 0.08 or 0.1), veryLight and 0.20 or 0.25)
        t.TextDark = Color3.fromHSV(h, math.min(s * (veryLight and 0.2 or 0.15), veryLight and 0.05 or 0.08), veryLight and 0.39 or 0.45)
        t.Accent = Color3.fromHSV(h, s * 1.2, math.clamp(v * 0.68, 0, 1))
    end
    
    return t
end

OrionLib.Themes.Default = OrionLib:GenTheme(Color3.fromRGB(25, 25, 25))
OrionLib.CurrentTheme = OrionLib.Themes.Default

local Orion = Instance.new("ScreenGui")
Orion.Name = "OrionLib"
Orion.Parent = GuiParent
for _, Interface in ipairs(GuiParent:GetChildren()) do
	if Interface.Name == Orion.Name and Interface ~= Orion then
		Interface:Destroy()
	end
end

function OrionLib:IsRunning()
	return Orion.Parent == GuiParent
end

function OrionLib:DestroyLib()
    for _, Connection in OrionLib.Connections do
        if Connection.Connected then
            Connection:Disconnect()
        end
    end
    table.clear(OrionLib.Connections)
    
    UnlockMouse(false)
    Orion:Destroy()
end

task.spawn(function()
    repeat
        task.wait(0.5)
    until not OrionLib:IsRunning()
    
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
    
    warn("ReturnProperty: Tipo não reconhecido -", Object.ClassName)
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
			vgs.p.CameraMaxZoomDistance = nz
			vgs.p.CameraMinZoomDistance = nz
			vgs.UIS.MouseBehavior = Enum.MouseBehavior.Default
			vgs.UIS.MouseIconEnabled = true
			FreeMouse.Modal = Value
		else
			vgs.p.CameraMode = Enum.CameraMode.LockFirstPerson
			vgs.p.CameraMaxZoomDistance = nz
			vgs.p.CameraMinZoomDistance = nz
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
		NotificationConfig.Time = NotificationConfig.Time or 15

		local NotificationParent = SetProps(MakeElement("TFrame"), {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = NotificationHolder
		})

		local NotificationFrame = SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(25, 25, 25), 0, 10), {
			Parent = NotificationParent, 
			Size = UDim2.new(1, 0, 0, 0),
			Position = UDim2.new(1, -55, 0, 0),
			BackgroundTransparency = 0,
			AutomaticSize = Enum.AutomaticSize.Y
		}), {
			MakeElement("Stroke", Color3.fromRGB(93, 93, 93), 1.2),
			MakeElement("Padding", 12, 12, 12, 12),
			SetProps(MakeElement("Image", NotificationConfig.Image), {
				Size = UDim2.new(0, 20, 0, 20),
				ImageColor3 = Color3.fromRGB(240, 240, 240),
				Name = "Icon"
			}),
			SetProps(MakeElement("Label", NotificationConfig.Name, 15), {
				Size = UDim2.new(1, -30, 0, 20),
				Position = UDim2.new(0, 30, 0, 0),
				Font = Enum.Font.GothamBold,
				Name = "Title"
			}),
			SetProps(MakeElement("Label", NotificationConfig.Content, 14), {
				Size = UDim2.new(1, 0, 0, 0),
				Position = UDim2.new(0, 0, 0, 25),
				Font = Enum.Font.GothamSemibold,
				Name = "Content",
				AutomaticSize = Enum.AutomaticSize.Y,
				TextColor3 = Color3.fromRGB(200, 200, 200),
				TextWrapped = true
			})
		})

		vgs.TS:Create(NotificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 0, 0, 0)}):Play()

		task.wait(NotificationConfig.Time - 0.88)
		vgs.TS:Create(NotificationFrame.Icon, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
		vgs.TS:Create(NotificationFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.6}):Play()
		task.wait(0.3)
		vgs.TS:Create(NotificationFrame.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Transparency = 0.9}):Play()
		vgs.TS:Create(NotificationFrame.Title, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0.4}):Play()
		vgs.TS:Create(NotificationFrame.Content, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0.5}):Play()
		task.wait(0.05)

		NotificationFrame:TweenPosition(UDim2.new(1, 20, 0, 0),'In','Quint',0.8,true)
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
	WindowConfig.HidePremium = WindowConfig.HidePremium or false
	if WindowConfig.IntroEnabled == nil then
		WindowConfig.IntroEnabled = true
	end
	WindowConfig.FreeMouse = WindowConfig.FreeMouse or false
	WindowConfig.Openkey = WindowConfig.Openkey or "RightShift"
	WindowConfig.IntroText = WindowConfig.IntroText or "Orion Library"
	WindowConfig.CloseCallback = WindowConfig.CloseCallback or function() end
	WindowConfig.ShowIcon = WindowConfig.ShowIcon or false
	WindowConfig.Icon = WindowConfig.Icon or "rbxassetid://8834748103"
	WindowConfig.IntroIcon = WindowConfig.IntroIcon or "rbxassetid://8834748103"
	WindowConfig.SearchBar = WindowConfig.SearchBar or nil
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

	function OrionLib:SetTheme()
		local themeData = self.Themes[self.SelectedTheme]
		if not themeData then return end
		for typeName, objects in pairs(self.ThemeObjects) do
			local color = themeData[typeName]
			if color then
				for _, obj in ipairs(objects) do
					local prop = ReturnProperty(obj)
					if prop and obj[prop] ~= nil then
						obj[prop] = color
					end
				end
			end
		end
		if resizebtt then
			resizebtt.BackgroundColor3 = themeData.Main
		end
	end

	local TabHolder = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255, 255, 255), 4),
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
            AddThemeObject(SetProps(MakeElement("Label", "", 12), {
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
	
	function RTab(tabName, containerFrame)
		SearchSystem.tabs[tabName] = containerFrame
	end
	
	function Rbutton(tabName, tabButton)
		SearchSystem.butts[tabName] = tabButton
		Tabs[tabName] = tabButton
	end
	
	function Relem(tabName, elementName, elementFrame)
		if not SearchSystem.elmnts[tabName] then
			SearchSystem.elmnts[tabName] = {}
		end
		
		SearchSystem.elmnts[tabName][elementName] = {
			frame = elementFrame,
			originalParent = elementFrame.Parent,
			visible = true
		}
	end
	function ClearR()
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
				vgs.TS:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					CanvasPosition = Vector2.new(0, 0)
				}):Play()
			end
		end
		
		SearchSystem.results = {}
		SearchSystem.isserch = false
	end
	

	function Hlight(frame, highlight)
		if not frame then return end
		
		local glow = frame:FindFirstChild("SearchGlow")
		
		if highlight then
			if not glow then
				glow = Instance.new("UIStroke")
				glow.Name = "SearchGlow"
				glow.Thickness = 2
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
	
	function Gotab(tabName)
		if not SearchSystem.butts[tabName] or not SearchSystem.tabs[tabName] then 
			return 
		end
		
		for _, Tab in pairs(TabHolder:GetChildren()) do
			if Tab:IsA("TextButton") then
				Tab.Title.Font = Enum.Font.GothamSemibold
				vgs.TS:Create(Tab.Ico, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = 0.4}):Play()
				vgs.TS:Create(Tab.Title, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0.4}):Play()
			end    
		end
		
		for _, container in pairs(SearchSystem.tabs) do
			container.Visible = false
		end
		
		local targetTabButton = SearchSystem.butts[tabName]
		vgs.TS:Create(targetTabButton.Ico, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = 0}):Play()
		vgs.TS:Create(targetTabButton.Title, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
		targetTabButton.Title.Font = Enum.Font.GothamBlack
		
		local wcontainer = SearchSystem.tabs[tabName]
		if wcontainer then
			wcontainer.Visible = true
		end
		
		SearchSystem.actvtab = tabName
		
		if SearchSystem.isserch then
			local fvelm = nil
			local minpos = math.huge
			
			for tabName2, elements in pairs(SearchSystem.elmnts) do
				for elementName, data in pairs(elements) do
					if data.frame and data.frame.Parent then
						local isInactvtab = (tabName2 == tabName)
						local matchsrch = SearchSystem.results[tabName2] and SearchSystem.results[tabName2][elementName]
						data.frame.Visible = isInactvtab and matchsrch
						
						Hlight(data.frame, isInactvtab and matchsrch)
						
						if isInactvtab and matchsrch and data.frame.AbsolutePosition.Y < minpos then
							minpos = data.frame.AbsolutePosition.Y
							fvelm = data.frame
						end
					end
				end
			end
			
			if fvelm and wcontainer then
				task.wait(0.1)
				local scrollPosition = fvelm.Position.Y.Offset
				vgs.TS:Create(wcontainer, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					CanvasPosition = Vector2.new(0, math.max(0, scrollPosition - 20))
				}):Play()
			end
		else
			for tabName2, elements in pairs(SearchSystem.elmnts) do
				for elementName, data in pairs(elements) do
					if data.frame then
						Hlight(data.frame, false)
					end
				end
			end
		end
	end
	
	function search(serchtext)
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
			ClearTextOnFocus = false
		})
		
		local tbxatual = AddThemeObject(SearchBox, "Text")
	
		local SearchBar = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 1, 6), {
			Parent = WindowStuff,
			Size = UDim2.new(0, 130, 0, 24),
			Position = UDim2.new(1, -12, 0, 12),
			AnchorPoint = Vector2.new(1, 0)
		}), {
			AddThemeObject(MakeElement("Stroke"), "Stroke"),
			tbxatual
		}), "Main")
		
		function srchhdl()
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
			local currentTime = tick()
	
			if currentTime - nresize <= 0.5 then
				local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				local tween = vgs.TS:Create(MainWindow, tweenInfo, { Size = default})
				tween:Play()
				drgg = false 
			else
				drgg = true
				mspos = input.Position
			end
	
			nresize = currentTime
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


	if WindowConfig.ShowIcon then
		WindowName.Position = UDim2.new(0, 50, 0, -24)
		local WindowIcon = SetProps(MakeElement("Image", WindowConfig.Icon), {
			Size = UDim2.new(0, 20, 0, 20),
			Position = UDim2.new(0, 25, 0, 15)
		})
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
	local minimized = false
	
	function updminframe()
		if not minimized then return end
		
		if reztween then
			reztween:Cancel()
			reztween = nil
		end
		
		local newWidth = WindowName.TextBounds.X + 140
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
			MinimizeBtn.Ico.Image = "rbxassetid://7072720870"
			
			mintween = vgs.TS:Create(MainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, WindowName.TextBounds.X + 140, 0, 50)
			})
			WindowStuff.Visible = false
			mintween:Play()
			mintween.Completed:Wait()
		else
			WindowStuff.Visible = true
			MinimizeBtn.Ico.Image = "rbxassetid://7072719338"
			
			mintween = vgs.TS:Create(MainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, 615, 0, 344)
			})
			mintween:Play()
			mintween.Completed:Wait()
			WindowStuff.Visible = true
			MainWindow.ClipsDescendants = false
		end
	end)


	function LoadSequence()
		MainWindow.Visible = false
		local LoadSequenceLogo = SetProps(MakeElement("Image", WindowConfig.IntroIcon), {
			Parent = Orion,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.4, 0),
			Size = UDim2.new(0, 28, 0, 28),
			ImageColor3 = Color3.fromRGB(255, 255, 255),
			ImageTransparency = 1
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
		wait(0.8)
		vgs.TS:Create(LoadSequenceLogo, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -(LoadSequenceText.TextBounds.X/2), 0.5, 0)}):Play()
		wait(0.3)
		vgs.TS:Create(LoadSequenceText, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
		wait(2)
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
			Gotab(TabConfig.Name)
		end)

		function Getelmnts(ItemParent)
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
			
				function commtext(str1, str2)
					local i = 1
					while i <= #str1 and i <= #str2 and str1:sub(i, i) == str2:sub(i, i) do
						i = i + 1
					end
					return i - 1
				end
			
				function anminchanges(newText, finalRichText)
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
			
				function appcol(text, colorConfig)
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
				
				Relem(ItemParent.Name, Text, LabelFrame)
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
					Size = UDim2.new(1, 0, 0, 30),
					BackgroundTransparency = 0.7,
					Parent = ItemParent
				}), {
					ContentLabel,
					AddThemeObject(MakeElement("Stroke"), "Stroke")
				}), "Second")
			
				Relem(ItemParent.Name, Text, LabelFrame)
				
				local labelfunc = {}
			
				function labelfunc:Set(ToChange, ToChangeColor, Position)
					LabelFrame.Content.Text = ToChange
			
					if ToChangeColor then
						LabelFrame.Content.TextColor3 = ToChangeColor
					else
						LabelFrame.Content.TextColor3 = Color3.fromRGB(255, 255, 255)
					end
					
					local targetPosition
					if Position == "Left" then
						targetPosition = UDim2.new(0, 12, 0, 0)
					elseif Position == "Center" then
						targetPosition = UDim2.new(0.5, -LabelFrame.Content.TextBounds.X / 2, 0, 0)
					elseif Position == "Right" then
						targetPosition = UDim2.new(1, -LabelFrame.Content.TextBounds.X - 12, 0, 0)
					else
						targetPosition = UDim2.new(0.5, -LabelFrame.Content.TextBounds.X / 2, 0, 0)
					end
			
					local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
					local tweenGoal = {Position = targetPosition}
					local tween = vgs.TS:Create(LabelFrame.Content, tweenInfo, tweenGoal)
			
					tween:Play()
				end
			
				labelfunc:Set(Text, ToChangeColor, Position)
				return labelfunc
			end

			function ElementFunction:AddParagraph(Text, Content)
				Text = Text or "Text"
				Content = Content or "Content"

				local ParagraphFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 30),
					BackgroundTransparency = 0.7,
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", Text, 15), {
						Size = UDim2.new(1, -12, 0, 14),
						Position = UDim2.new(0, 12, 0, 10),
						Font = Enum.Font.GothamBold,
						Name = "Title"
					}), "Text"),
					AddThemeObject(SetProps(MakeElement("Label", "", 13), {
						Size = UDim2.new(1, -24, 0, 0),
						Position = UDim2.new(0, 12, 0, 26),
						Font = Enum.Font.GothamSemibold,
						Name = "Content",
						TextWrapped = true
					}), "TextDark"),
					AddThemeObject(MakeElement("Stroke"), "Stroke")
				}), "Second")

				Relem(ItemParent.Name, Text, ParagraphFrame)

				AddConnection(ParagraphFrame.Content:GetPropertyChangedSignal("Text"), function()
					ParagraphFrame.Content.Size = UDim2.new(1, -24, 0, ParagraphFrame.Content.TextBounds.Y)
					ParagraphFrame.Size = UDim2.new(1, 0, 0, ParagraphFrame.Content.TextBounds.Y + 35)
				end)

				ParagraphFrame.Content.Text = Content

				local ParagraphFunction = {}
				function ParagraphFunction:Set(ToChange)
					ParagraphFrame.Content.Text = ToChange
				end
				return ParagraphFunction
			end
			
			function ElementFunction:AddPParagraph(text, Content, Align)
				Content = Content:gsub("\\n", "\n")
			
				local ParagraphFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 30),
					BackgroundTransparency = 0.7,
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", text, 15), {
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
				Relem(ItemParent.Name, text, ParagraphFrame)
				AddConnection(ParagraphFrame.Content:GetPropertyChangedSignal("Text"), function()
					ParagraphFrame.Content.Size = UDim2.new(1, -24, 0, ParagraphFrame.Content.TextBounds.Y)
					ParagraphFrame.Size = UDim2.new(1, 0, 0, ParagraphFrame.Content.TextBounds.Y + 35)
				end)
			
				ParagraphFrame.Content.Text = Content
				ParagraphFrame.Content.TextXAlignment = Enum.TextXAlignment[Align]
			
				local ParagraphFunction = {}
				function ParagraphFunction:Set(newtx, newcont, newalign)
					if newtx then
						ParagraphFrame.Title.Text = newtx
					end
					if newcont then
						ParagraphFrame.Content.Text = newcont:gsub("\\n", "\n")
					end
					if newalign then
						ParagraphFrame.Content.TextXAlignment = Enum.TextXAlignment[newalign]
						ParagraphFrame.Title.TextXAlignment = Enum.TextXAlignment[newalign]
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
				Relem(ItemParent.Name, ButtonConfig.Name, ButtonFrame)
				AddConnection(Click.MouseEnter, function()
					vgs.TS:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
				end)

				AddConnection(Click.MouseLeave, function()
					vgs.TS:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second}):Play()
				end)

				AddConnection(Click.MouseButton1Up, function()
					vgs.TS:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
					spawn(function()
						ButtonConfig.Callback()
					end)
				end)

				AddConnection(Click.MouseButton1Down, function()
					vgs.TS:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 6)}):Play()
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
				ToggleConfig.Color = ToggleConfig.Color or Color3.fromRGB(9, 99, 195)
				ToggleConfig.Flag = ToggleConfig.Flag or nil
				ToggleConfig.Save = ToggleConfig.Save or false

				local Toggle = {Value = ToggleConfig.Default, Save = ToggleConfig.Save}

				local Click = SetProps(MakeElement("Button"), {
					Size = UDim2.new(1, 0, 1, 0)
				})

				local ToggleBox = SetChildren(SetProps(MakeElement("RoundFrame", ToggleConfig.Color, 0, 4), {
					Size = UDim2.new(0, 24, 0, 24),
					Position = UDim2.new(1, -24, 0.5, 0),
					AnchorPoint = Vector2.new(0.5, 0.5)
				}), {
					SetProps(MakeElement("Stroke"), {
						Color = ToggleConfig.Color,
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
				Relem(ItemParent.Name, ToggleConfig.Name, ToggleFrame)
				function Toggle:Set(Value)
					Toggle.Value = Value
					vgs.TS:Create(ToggleBox, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Toggle.Value and ToggleConfig.Color or OrionLib.Themes.Default.Divider}):Play()
					vgs.TS:Create(ToggleBox.Stroke, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Color = Toggle.Value and ToggleConfig.Color or OrionLib.Themes.Default.Stroke}):Play()
					vgs.TS:Create(ToggleBox.Ico, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = Toggle.Value and 0 or 1, Size = Toggle.Value and UDim2.new(0, 20, 0, 20) or UDim2.new(0, 8, 0, 8)}):Play()
					ToggleConfig.Callback(Toggle.Value)
				end    

				Toggle:Set(Toggle.Value)

				AddConnection(Click.MouseEnter, function()
					vgs.TS:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
				end)

				AddConnection(Click.MouseLeave, function()
					vgs.TS:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second}):Play()
				end)

				AddConnection(Click.MouseButton1Up, function()
					vgs.TS:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
					SaveCfg(game.GameId)
					Toggle:Set(not Toggle.Value)
				end)

				AddConnection(Click.MouseButton1Down, function()
					vgs.TS:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 6)}):Play()
				end)

				if ToggleConfig.Flag then
					OrionLib.Flags[ToggleConfig.Flag] = Toggle
				end	
				return Toggle
			end
			
			function ElementFunction:AddSlider(SliderConfig)
				SliderConfig = SliderConfig or {}
				SliderConfig.Name = SliderConfig.Name or "Slider"
				SliderConfig.Min = SliderConfig.Min or 0
				SliderConfig.Max = SliderConfig.Max or 100
				SliderConfig.Increment = SliderConfig.Increment or 1
				SliderConfig.Default = SliderConfig.Default or 50
				SliderConfig.Callback = SliderConfig.Callback or function() end
				SliderConfig.ValueName = SliderConfig.ValueName or ""
				SliderConfig.Flag = SliderConfig.Flag or nil
				SliderConfig.Save = SliderConfig.Save or false
				SliderConfig.Block = SliderConfig.Block or true
				SliderConfig.VarFunc = SliderConfig.VarFunc or nil
			
				local Slider = {
					Value = SliderConfig.Default, 
					Save = SliderConfig.Save,
					IsClicking = false  
				}
				local dragging = false
				local laststate = nil
				local infinite = (SliderConfig.Max == math.huge)
				local infthresh = 0.95
			
				function forValue(value)
					if value == math.huge then return "∞"
					elseif value >= 1e6 then return string.format("%.1fM", value / 1e6)
					elseif value >= 1e3 then return string.format("%.1fK", value / 1e3)
					else return tostring(math.floor(value * 100)/100) end
				end
			
				function scale(value)
					if infinite then
						if value == math.huge then return 1 end
						local softMax = SliderConfig.Min * 5
						return math.clamp((value - SliderConfig.Min) / (softMax - SliderConfig.Min), 0, infthresh)
					else
						if SliderConfig.Max == SliderConfig.Min then return 0 end
						return math.clamp((value - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min), 0, 1)
					end
				end
			
				local SliderDrag = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(9, 149, 98), 0, 5), {
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
			
				local SliderBar = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(9, 149, 98), 0, 5), {
					Size = UDim2.new(1, -24, 0, 26),
					Position = UDim2.new(0, 12, 0, 30),
					BackgroundTransparency = 0.9
				}), {AddThemeObject(SetProps(MakeElement("Stroke"), {
					Color = Color3.fromRGB(9, 149, 98), 
					Thickness = infinite and 1.5 or 1
				}), "Stroke"),
					AddThemeObject(SetProps(MakeElement("Label", "value", 13), {
						Size = UDim2.new(1, -12, 0, 14), 
						Position = UDim2.new(0, 12, 0, 6), 
						Font = Enum.Font.GothamBold, 
						Name = "Value", 
						TextTransparency = 0.8
					}), "TextDark"),
					SliderDrag}), "Second")
			
				local SliderFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
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
					SliderBar}), "Second")
			
				Relem(ItemParent.Name, SliderConfig.Name, SliderFrame)
			
				function dcolor(color, factor)
					return Color3.new(color.R * factor, color.G * factor, color.B * factor)
				end
			
				function appblock(isBlocked)
					local accclr = OrionLib.Themes[OrionLib.SelectedTheme].Accent
					local tgcollr = isBlocked and dcolor(accclr, 0.65) or accclr
					SliderBar.Active = not isBlocked
					vgs.TS:Create(SliderDrag, TweenInfo.new(0.25), {BackgroundColor3 = tgcollr}):Play()
					vgs.TS:Create(SliderBar, TweenInfo.new(0.25), {BackgroundColor3 = tgcollr}):Play()
				end
			
				task.spawn(function()
					while SliderFrame and SliderFrame.Parent do
						local crrLstate = true
						local varFunc = SliderConfig.VarFunc or _G.var or getgenv().var
						
						if type(SliderConfig.Block) == "string" then
							if varFunc then
								local varResult = varFunc(SliderConfig.Block)
								if varResult ~= nil then
									crrLstate = varResult
								end
							elseif _G.Toggle and _G.Toggle[SliderConfig.Block] ~= nil then
								crrLstate = _G.Toggle[SliderConfig.Block]
							elseif getgenv().Toggle and getgenv().Toggle[SliderConfig.Block] ~= nil then
								crrLstate = getgenv().Toggle[SliderConfig.Block]
							end
						elseif type(SliderConfig.Block) == "boolean" then
							crrLstate = SliderConfig.Block
						elseif type(SliderConfig.Block) == "function" then
							crrLstate = SliderConfig.Block()
						end
						
						if laststate ~= crrLstate then
							laststate = crrLstate
							appblock(not crrLstate)
						end
						task.wait(0.1)
					end
				end)
			
				SliderBar.InputBegan:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 and SliderBar.Active then
						dragging = true
						Slider.IsClicking = true
						vgs.TS:Create(SliderBar, TweenInfo.new(0.15), {BackgroundTransparency = 0.7}):Play()
					end
				end)
			
				SliderBar.InputEnded:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = false
						Slider.IsClicking = false
						vgs.TS:Create(SliderBar, TweenInfo.new(0.25), {BackgroundTransparency = 0.9}):Play()
					end
				end)
			
				vgs.UIS.InputChanged:Connect(function(Input)
					if not (dragging and Input.UserInputType == Enum.UserInputType.MouseMovement and SliderBar.Active) then
						return
					end
			
					local SizeScale = math.clamp((Input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
					local newValue
			
					if infinite then
						if SizeScale >= infthresh then
							newValue = math.huge
						else
							local softMax = SliderConfig.Min * 5
							local scaledValue = SliderConfig.Min + (softMax - SliderConfig.Min) * SizeScale / infthresh
							if SliderConfig.Increment > 0 then
								local steps = math.round((scaledValue - SliderConfig.Min) / SliderConfig.Increment)
								newValue = SliderConfig.Min + (steps * SliderConfig.Increment)
							else
								newValue = scaledValue
							end
						end
					else
						local scaledValue = SliderConfig.Min + (SliderConfig.Max - SliderConfig.Min) * SizeScale
						if SliderConfig.Increment > 0 then
							local steps = math.round((scaledValue - SliderConfig.Min) / SliderConfig.Increment)
							newValue = SliderConfig.Min + (steps * SliderConfig.Increment)
						else
							newValue = scaledValue
						end
					end
			
					Slider:Set(newValue)
					SaveCfg(game.GameId)
				end)
			
				function Slider:Set(Value)
					local clampedValue = Value
					if Value ~= math.huge then
						clampedValue = math.clamp(Round(Value, SliderConfig.Increment), SliderConfig.Min, SliderConfig.Max)
					end
					
					self.Value = clampedValue
					local scaleForTween = scale(clampedValue)
					
					vgs.TS:Create(SliderDrag, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = UDim2.fromScale(scaleForTween, 1)
					}):Play()
			
					local valueText = forValue(self.Value) .. " " .. SliderConfig.ValueName
					SliderBar.Value.Text = valueText
					SliderDrag.Value.Text = valueText
					SliderConfig.Callback(self.Value)
				end
			
				function Slider:SetName(newName)
					local ContentLabel = SliderFrame.Content
					if ContentLabel.Text == newName then return end
					
					task.spawn(function()
						local current = ContentLabel.Text
						
						for i = #current, 0, -1 do
							ContentLabel.Text = string.sub(current, 1, i)
							task.wait(0.025)
						end
						
						task.wait(0.1)
						
						for i = 1, #newName do
							ContentLabel.Text = string.sub(newName, 1, i)
							task.wait(0.035)
						end
					end)
				end
						
				function Slider:SetMax(newMax)
					if newMax == SliderConfig.Max then return end
					
					SliderConfig.Max = newMax
					infinite = (newMax == math.huge)
					
					if self.Value > newMax and newMax ~= math.huge then
						self:Set(newMax)
					else
						local scaleForTween = scale(self.Value)
						vgs.TS:Create(SliderDrag, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							Size = UDim2.fromScale(scaleForTween, 1)
						}):Play()
					end
				end
				
				function Slider:SetMin(newMin)
					if newMin == SliderConfig.Min then return end
					
					SliderConfig.Min = newMin
					
					if self.Value < newMin then
						self:Set(newMin)
					else
						local scaleForTween = scale(self.Value)
						vgs.TS:Create(SliderDrag, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							Size = UDim2.fromScale(scaleForTween, 1)
						}):Play()
					end
				end
			
				Slider:Set(Slider.Value)
				if SliderConfig.Flag then OrionLib.Flags[SliderConfig.Flag] = Slider end
				return Slider
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
					isPDrop = false
				}
				
				local function DtctPDrop()
					for _, option in pairs(DropdownConfig.Options) do
						local optTxt = type(option) == "table" and (option.text or option.name) or tostring(option)
						local pName = optTxt:match("^(.-) %(") or optTxt
						
						if vgs.ps:FindFirstChild(pName) then
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
					}), {MakeElement("Stroke"), SrchBox}), "Main")
				end
			
				local DdCont = AddThemeObject(SetProps(SetChildren(MakeElement("ScrollFrame", Color3.fromRGB(40, 40, 40), 4), {
					DdList
				}), {
					Parent = ItemParent,
					Position = UDim2.new(0, 0, 0, 38),
					Size = UDim2.new(1, 0, 1, -38),
					ClipsDescendants = true,
					Visible = false
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
							Size = UDim2.new(1, -40, 1, 0),
							Position = UDim2.new(0, 0, 0, 0),
							Font = Enum.Font.Gotham,
							Name = "Selected",
							TextXAlignment = Enum.TextXAlignment.Right
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
			
				Relem(ItemParent.Name, DropdownConfig.Name, DdFrame)
				AddConnection(DdList:GetPropertyChangedSignal("AbsoluteContentSize"), function()
					DdCont.CanvasSize = UDim2.new(0, 0, 0, DdList.AbsoluteContentSize.Y)
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
							DropdownConfig.Multi and AddThemeObject(SetProps(MakeElement("RoundFrame", Color3.fromRGB(60, 60, 60), 0, 2), {
								Size = UDim2.new(0, 16, 0, 16),
								Position = UDim2.new(1, -24, 0.5, 0),
								AnchorPoint = Vector2.new(0, 0.5),
								Name = "Checkbox"
							}), "Stroke") or MakeElement("TFrame")
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
							end
							
							Dropdown:UpdVis()
						end
						SaveCfg(game.GameId)
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
			
				function Dropdown:UpdSel()
					local selTxt = ""
					if DropdownConfig.Multi then
						if type(self.Value) == "table" and #self.Value > 0 then
							local vVals = {}
							for _, v in pairs(self.Value) do
								if type(v) == "string" or type(v) == "number" then
									table.insert(vVals, tostring(v))
								end
							end
							selTxt = table.concat(vVals, ", ")
						else
							selTxt = "Select options"
						end
					else
						selTxt = tostring(self.Value ~= "" and self.Value or "Select option")
					end
					DdFrame.Header.Selected.Text = selTxt
				
					for value, btn in pairs(self.Buttons) do
						local sel = DropdownConfig.Multi and table.find(self.Value, value) or (self.Value == value)
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
				
						if DropdownConfig.Multi and btn:FindFirstChild("Checkbox") then
							local chkCol = sel and Color3.fromRGB(0, 162, 255) or Color3.fromRGB(60, 60, 60)
							vgs.TS:Create(btn.Checkbox, twInf, {BackgroundColor3 = chkCol}):Play()
						end
					end
					
					if DropdownConfig.Multi and DropdownConfig.Call then
						DropdownConfig.Callback(self.Value)
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
			
					if DropdownConfig.Searchable and SrchBox then
						if self.Toggled and self.srchMode then
							spawn(function()
								wait(0.1)
								SrchBox:CaptureFocus()
							end)
						else
							SrchBox:ReleaseFocus()
							if not self.srchMode then
								SrchBox.Text = ""
								self.srchTxt = ""
								FiltrOpts()
							end
						end
					end
				end
			
				function Dropdown:Set(Value)
					if DropdownConfig.Multi then
						self.Value = Value or {}
					else
						if not table.find(self.Options, Value) then
							self.Value = "..."
							DdFrame.Header.Selected.Text = self.Value
							for _, v in pairs(self.Buttons) do
								vgs.TS:Create(v, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
								if v:FindFirstChild("Title") then
									vgs.TS:Create(v.Title, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0.4}):Play()
								end
							end
							return
						end
			
						self.Value = Value
						DdFrame.Header.Selected.Text = self.Value
			
						for _, v in pairs(self.Buttons) do
							vgs.TS:Create(v, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
							if v:FindFirstChild("Title") then
								vgs.TS:Create(v.Title, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0.4}):Play()
							end
						end
						if self.Buttons[Value] then
							vgs.TS:Create(self.Buttons[Value], TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
							if self.Buttons[Value]:FindFirstChild("Title") then
								vgs.TS:Create(self.Buttons[Value].Title, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
							end
						end
					end
					return DropdownConfig.Callback(self.Value)
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
						Dropdown:UpdVis()
					end
				end)
			
				Dropdown:Refresh(Dropdown.Options, false)
				Dropdown:Set(Dropdown.Value)
				if DropdownConfig.Flag then
					OrionLib.Flags[DropdownConfig.Flag] = Dropdown
				end
				if Dropdown.isPDrop and vgs and vgs.ps then
					Dropdown.PlrLvConn = vgs.ps.PlayerRemoving:Connect(function(plr)
						local pName = plr.Name
						
						if DropdownConfig.Multi then
							for i = #Dropdown.Value, 1, -1 do
								local optTxt = Dropdown.Value[i]
								local name = optTxt:match("^(.-) %(") or optTxt
								
								if name == pName then
									table.remove(Dropdown.Value, i)
								end
							end
							Dropdown:UpdSel()
							DropdownConfig.Callback(Dropdown.Value)
						else
							local currName = Dropdown.Value:match("^(.-) %(") or Dropdown.Value
							if currName == pName then
								Dropdown:Set("...")
							end
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
				Relem(ItemParent.Name, BindConfig.Name, BindFrame)
				AddConnection(BindBox.Value:GetPropertyChangedSignal("Text"), function()
					vgs.TS:Create(BindBox, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, BindBox.Value.TextBounds.X + 16, 0, 24)}):Play()
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
				TextboxConfig.Callback = TextboxConfig.Callback or function() end

				local Click = SetProps(MakeElement("Button"), {
					Size = UDim2.new(1, 0, 1, 0)
				})

				local TextboxActual = AddThemeObject(Create("TextBox", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					PlaceholderColor3 = Color3.fromRGB(210,210,210),
					PlaceholderText = "Input",
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
				Relem(ItemParent.Name, TextboxConfig.Name, TextboxFrame)
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
			
				local ColorH, ColorS, ColorV = Color3.toHSV(ColorpickerConfig.Default)
				local Colorpicker = {
					Value = ColorpickerConfig.Default,
					Toggled = false,
					Type = "Colorpicker",
					Save = ColorpickerConfig.Save
				}
			
				local ColorSelection = Create("ImageLabel", {
					Size = UDim2.new(0, 18, 0, 18),
					Position = UDim2.new(ColorS, 0, 1 - ColorV),
					ScaleType = Enum.ScaleType.Fit,
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = "http://www.roblox.com/asset/?id=4805639000"
				})
				local HueSelection = Create("ImageLabel", {
					Size = UDim2.new(0, 18, 0, 18),
					Position = UDim2.new(0.5, 0, 1 - ColorH),
					ScaleType = Enum.ScaleType.Fit,
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = "http://www.roblox.com/asset/?id=4805639000"
				})
			
				local Color = Create("ImageLabel", {
					Size = UDim2.new(1, -25, 1, 0),
					Visible = false,
					Image = "rbxassetid://4155801252"
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
					Create("UICorner", {CornerRadius = UDim.new(0, 5)}),
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
				local ColorpickerBox = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
					Size = UDim2.new(0, 24, 0, 24),
					Position = UDim2.new(1, -12, 0.5, 0),
					AnchorPoint = Vector2.new(1, 0.5)
				}), {AddThemeObject(MakeElement("Stroke"), "Stroke")}), "Main")
			
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
			
				Relem(ItemParent.Name, ColorpickerConfig.Name, ColorpickerFrame)
			
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
					ColorpickerConfig.Callback(Colorpicker.Value)
					if ColorpickerConfig.Save then SaveCfg(game.GameId) end
				end
			
				AddConnection(Color.InputBegan, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						if ColorInput then ColorInput:Disconnect() end
						ColorInput = AddConnection(vgs.RS.RenderStepped, function()
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
						ColorInput:Disconnect()
						ColorInput = nil
					end
				end)
			
				AddConnection(Hue.InputBegan, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						if HueInput then HueInput:Disconnect() end
						HueInput = AddConnection(vgs.RS.RenderStepped, function()
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
						HueInput:Disconnect()
						HueInput = nil
					end
				end)
			
				function Colorpicker:Set(Value)
					Colorpicker.Value = Value
					ColorH, ColorS, ColorV = Color3.toHSV(Value)
					ColorpickerBox.BackgroundColor3 = Value
					Color.BackgroundColor3 = Color3.fromHSV(ColorH, 1, 1)
					ColorSelection.Position = UDim2.new(ColorS, 0, 1 - ColorV)
					HueSelection.Position = UDim2.new(0.5, 0, 1 - ColorH)
					ColorpickerConfig.Callback(Value)
				end
			
				Colorpicker:Set(ColorpickerConfig.Default)
				if ColorpickerConfig.Flag then OrionLib.Flags[ColorpickerConfig.Flag] = Colorpicker end
				return Colorpicker
			end
			function ElementFunction:AddSmartTheme()
				local GeneratorSection = self
				
				GeneratorSection:AddColorpicker({
					Name = "Base Color",
					Default = OrionLib.Themes[OrionLib.SelectedTheme].Main,
					Callback = function(Value)
						local newTheme = OrionLib:GenTheme(Value)
						OrionLib.Themes.Custom = newTheme
						OrionLib.SelectedTheme = "Custom"
						OrionLib:SetTheme()
					end
				})
				
				GeneratorSection:AddButton({
					Name = "Reset Theme",
					Callback = function()
						OrionLib.Themes.Custom = OrionLib:GenTheme(Color3.fromRGB(25, 25, 25))
						OrionLib.SelectedTheme = "Custom"
						OrionLib:SetTheme()
					end
				})
				OrionLib.SelectedTheme = "Default"
				OrionLib:SetTheme()
			end
			
			return ElementFunction   
		end	
		

		local ElementFunction = {}
		
		function ElementFunction:AddSection(SectionConfig)
			SectionConfig = SectionConfig or {}
			SectionConfig.Name = SectionConfig.Name or "Section"
		
			local SectionFrame = SetChildren(SetProps(MakeElement("TFrame"), {
				Size = UDim2.new(1, 0, 0, 26),
				Parent = Container
			}), {
				AddThemeObject(SetProps(MakeElement("Label", SectionConfig.Name, 14), {
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
			
			Relem(Container.Name, SectionConfig.Name, SectionFrame)
			
			AddConnection(SectionFrame.Holder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
				SectionFrame.Size = UDim2.new(1, 0, 0, SectionFrame.Holder.UIListLayout.AbsoluteContentSize.Y + 31)
				SectionFrame.Holder.Size = UDim2.new(1, 0, 0, SectionFrame.Holder.UIListLayout.AbsoluteContentSize.Y)
			end)
		
			local SectionFunction = {}
			for i, v in next, Getelmnts(SectionFrame.Holder) do
				SectionFunction[i] = v 
			end
			return SectionFunction
		end

		for i, v in next, Getelmnts(Container) do
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
