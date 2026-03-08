local vgs = {
    MS  = game:GetService("Players").LocalPlayer:GetMouse(),
    VIM = game:GetService("VirtualInputManager"),
    p   = game:GetService("Players").LocalPlayer,
    UIS = game:GetService("UserInputService"),
    TS  = game:GetService("TweenService"),
    TTS = game:GetService("TextService"),
    HS  = game:GetService("HttpService"),
    RS  = game:GetService("RunService"),
    ps  = game:GetService("Players")
}

local rate = 1 / 200
local acc  = 0

local OrionLib = {
    OrionColor    = Color3.fromRGB(15, 4, 22),
    SelectedTheme = "Default",
    UMouseMode    = "FreeMouse",
    ThemeObjects  = {},
    Connections   = {},
    SaveCfg       = false,
    Dropdowns     = {},
    Toggles       = {},
    Folder        = nil,
    Notifys       = {},
    elmnts        = {},
    Themes        = {},
    Flags         = {},
    maxds         = 500,
    minds         = 10
}

function OrionLib:GenTheme(mainColor)
    local r   = mainColor.R * 255
    local g   = mainColor.G * 255
    local b   = mainColor.B * 255
    local lum = 0.299 * r + 0.587 * g + 0.114 * b
    local dark = lum < 128
    local t   = {Main = mainColor}

    if dark then
        t.Second   = Color3.fromRGB(math.clamp(r * 1.12, 0, 255), math.clamp(g * 1.12, 0, 255), math.clamp(b * 1.12, 0, 255))
        t.Stroke   = Color3.fromRGB(math.clamp(r * 1.45, 0, 255), math.clamp(g * 1.45, 0, 255), math.clamp(b * 1.45, 0, 255))
        t.Divider  = Color3.fromRGB(math.clamp(r * 1.28, 0, 255), math.clamp(g * 1.28, 0, 255), math.clamp(b * 1.28, 0, 255))
        t.Text     = Color3.fromRGB(240, 240, 242)
        t.TextDark = Color3.fromRGB(155, 155, 160)
        t.Accent   = Color3.fromRGB(math.clamp(r * 1.85, 0, 255), math.clamp(g * 1.85, 0, 255), math.clamp(b * 1.85, 0, 255))
    else
        t.Second   = Color3.fromRGB(math.clamp(r * 0.94, 0, 255), math.clamp(g * 0.94, 0, 255), math.clamp(b * 0.94, 0, 255))
        t.Stroke   = Color3.fromRGB(math.clamp(r * 0.75, 0, 255), math.clamp(g * 0.75, 0, 255), math.clamp(b * 0.75, 0, 255))
        t.Divider  = Color3.fromRGB(math.clamp(r * 0.85, 0, 255), math.clamp(g * 0.85, 0, 255), math.clamp(b * 0.85, 0, 255))
        t.Text     = Color3.fromRGB(35, 35, 38)
        t.TextDark = Color3.fromRGB(110, 110, 115)
        t.Accent   = Color3.fromRGB(math.clamp(r * 0.72, 0, 255), math.clamp(g * 0.72, 0, 255), math.clamp(b * 0.72, 0, 255))
    end

    return t
end

OrionLib.Themes.Default = OrionLib:GenTheme(OrionLib.OrionColor)
OrionLib.CurrentTheme = OrionLib.Themes.Default

getgenv().gethui = function()
    return game.CoreGui
end

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

do
    local hb
    hb = game:GetService("RunService").Heartbeat:Connect(function()
        if not OrionLib:IsRunning() then
            hb:Disconnect()
            OrionLib:DestroyLib()
        end
    end)
end

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
                Dragging  = true
                MousePos  = Input.Position
                FramePos  = Main.Position
            end
        end)

        AddConnection(vgs.UIS.InputEnded, function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                Dragging = false
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
                vgs.TS:Create(Main, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    Position = UDim2.new(
                        FramePos.X.Scale,
                        FramePos.X.Offset + Delta.X,
                        FramePos.Y.Scale,
                        FramePos.Y.Offset + Delta.Y
                    )
                }):Play()
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
    local Item  = tostring(Item)
    local Count = 1

    while Table[Item] do
        Count = Count + 1
        Item  = string.format('%s-%d', Item, Count)
    end

    Table[Item] = Value
end

function MakeElement(ElementName, ...)
    return OrionLib.elmnts[ElementName](...)
end

function SetProps(Element, Props)
    for Property, Value in pairs(Props) do
        Element[Property] = Value
    end
    return Element
end

local Total = {
    SetChildren    = 0,
    AddThemeObject = 0
}

function SetChildren(Element, Children)
    Total.SetChildren = Total.SetChildren + 1
    for _, Child in ipairs(Children) do
        Child.Parent = Element
    end
    return Element
end

function Round(Number, Factor)
    if not Factor or Factor == 0 then
        Factor = 1
    end
    local Result = math.floor(Number / Factor + (math.sign(Number) * 0.5)) * Factor
    if Result < 0 then
        Result = Result + Factor
    end
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

    local themeColor = OrionLib.Themes[OrionLib.SelectedTheme][Type] or OrionLib.Themes[OrionLib.SelectedTheme]["Accent"]

    local property

    if Type == "Accent2" then
        if Object:IsA("UIStroke") then
            property = "Color"
        else
            property = "BackgroundColor3"
        end
    else
        property = ReturnProperty(Object)
    end

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
    for a, b in pairs(Data) do
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
    end
end

function SaveCfg(Name)
    local Data = {}
    for i, v in pairs(OrionLib.Flags) do
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

local WhitelistedMouse = {
    Enum.UserInputType.MouseButton1,
    Enum.UserInputType.MouseButton2,
    Enum.UserInputType.MouseButton3
}

local BlacklistedKeys = {
    Enum.KeyCode.Unknown,
    Enum.KeyCode.W,
    Enum.KeyCode.A,
    Enum.KeyCode.S,
    Enum.KeyCode.D,
    Enum.KeyCode.Up,
    Enum.KeyCode.Left,
    Enum.KeyCode.Down,
    Enum.KeyCode.Right,
    Enum.KeyCode.Slash,
    Enum.KeyCode.Tab,
    Enum.KeyCode.Backspace,
    Enum.KeyCode.Escape,
    Enum.KeyCode.Space
}

local FreeMouse = Create("TextButton", {
    Name                   = "FMouse",
    Size                   = UDim2.new(0, 0, 0, 0),
    BackgroundTransparency = 1,
    Text                   = "",
    Position               = UDim2.new(0, 0, 0, 0),
    Modal                  = false,
    Parent                 = Orion,
    Visible                = true
})

local nz = 0.5

function UnlockMouse(Value)
    if OrionLib.UMouseMode == "ThirdPerson" then
        if Value then
            vgs.p.CameraMode = Enum.CameraMode.LockFirstPerson
            task.wait()
            vgs.p.CameraMode             = Enum.CameraMode.Classic
            vgs.UIS.MouseBehavior        = Enum.MouseBehavior.Default
            vgs.UIS.MouseIconEnabled     = true
            vgs.p.CameraMaxZoomDistance  = OrionLib.maxds
            vgs.p.CameraMinZoomDistance  = OrionLib.minds
        else
            vgs.UIS.MouseIconEnabled    = false
            vgs.UIS.MouseBehavior       = Enum.MouseBehavior.LockCenter
            vgs.p.CameraMaxZoomDistance = nz
            vgs.p.CameraMinZoomDistance = nz
            vgs.p.CameraMode            = Enum.CameraMode.LockFirstPerson
            FreeMouse.Modal             = false
        end
    elseif OrionLib.UMouseMode == "FreeMouse" then
        vgs.p.CameraMaxZoomDistance = nz
        vgs.p.CameraMinZoomDistance = nz
        vgs.p.CameraMode            = Enum.CameraMode.LockFirstPerson
        FreeMouse.Modal             = Value
        vgs.UIS.MouseBehavior       = Value and Enum.MouseBehavior.Default or Enum.MouseBehavior.LockCenter
        vgs.UIS.MouseIconEnabled    = Value
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
        Color     = Color or Color3.fromRGB(255, 255, 255),
        Thickness = Thickness or 1
    })
    return Stroke
end)

CreateElement("List", function(Scale, Offset)
    local List = Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding   = UDim.new(Scale or 0, Offset or 0)
    })
    return List
end)

CreateElement("Padding", function(Bottom, Left, Right, Top)
    local Padding = Create("UIPadding", {
        PaddingBottom = UDim.new(0, Bottom or 4),
        PaddingLeft   = UDim.new(0, Left   or 4),
        PaddingRight  = UDim.new(0, Right  or 4),
        PaddingTop    = UDim.new(0, Top    or 4)
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
        BorderSizePixel  = 0
    })
    return Frame
end)

CreateElement("RoundFrame", function(Color, Scale, Offset)
    local Frame = Create("Frame", {
        BackgroundColor3 = Color or Color3.fromRGB(255, 255, 255),
        BorderSizePixel  = 0
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(Scale, Offset)
        })
    })
    return Frame
end)

CreateElement("Button", function()
    local Button = Create("TextButton", {
        Text              = "",
        AutoButtonColor   = false,
        BackgroundTransparency = 1,
        BorderSizePixel   = 0
    })
    return Button
end)

CreateElement("ScrollFrame", function(Color, Width)
    local ScrollFrame = Create("ScrollingFrame", {
        BackgroundTransparency = 1,
        MidImage               = "rbxassetid://7445543667",
        BottomImage            = "rbxassetid://7445543667",
        TopImage               = "rbxassetid://7445543667",
        ScrollBarImageColor3   = Color,
        BorderSizePixel        = 0,
        ScrollBarThickness     = Width,
        CanvasSize             = UDim2.new(0, 0, 0, 0)
    })
    return ScrollFrame
end)

CreateElement("Image", function(ImageID)
    local ImageNew = Create("ImageLabel", {
        Image                = ImageID,
        BackgroundTransparency = 1
    })
    return ImageNew
end)

CreateElement("ImageButton", function(ImageID)
    local Image = Create("ImageButton", {
        Image                = ImageID,
        BackgroundTransparency = 1
    })
    return Image
end)

CreateElement("Label", function(Text, TextSize, Transparency)
    local Label = Create("TextLabel", {
        Text               = Text or "",
        TextColor3         = Color3.fromRGB(240, 240, 240),
        TextTransparency   = Transparency or 0,
        TextSize           = TextSize or 15,
        Font               = Enum.Font.Gotham,
        RichText           = true,
        BackgroundTransparency = 1,
        TextXAlignment     = Enum.TextXAlignment.Left
    })
    return Label
end)

CreateElement("TextBox", function()
    local TextBox = Create("TextBox", {
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Font                   = Enum.Font.Gotham,
        TextSize               = 14,
        TextColor3             = Color3.fromRGB(255, 255, 255),
        PlaceholderColor3      = Color3.fromRGB(150, 150, 150),
        Text                   = "",
        ClearTextOnFocus       = false
    })
    return TextBox
end)

local NotificationHolder = SetProps(SetChildren(MakeElement("TFrame"), {
    SetProps(MakeElement("List"), {
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder           = Enum.SortOrder.LayoutOrder,
        VerticalAlignment   = Enum.VerticalAlignment.Bottom,
        Padding             = UDim.new(0, 5)
    })
}), {
    Position    = UDim2.new(1, -25, 1, -25),
    Size        = UDim2.new(0, 300, 1, -25),
    AnchorPoint = Vector2.new(1, 1),
    Parent      = Orion
})

function OrionLib:MakeNotification(NotificationConfig)
    task.spawn(function()
        NotificationConfig.Name    = NotificationConfig.Name    or "Notification"
        NotificationConfig.Content = NotificationConfig.Content or "Test"
        NotificationConfig.Image   = NotificationConfig.Image   or "rbxassetid://4384403532"
        game:GetService("ContentProvider"):PreloadAsync({NotificationConfig.Image})
        NotificationConfig.Time = NotificationConfig.Time or 15

        local key = NotificationConfig.Name .. NotificationConfig.Content
        if OrionLib.Notifys[key] then return end
        OrionLib.Notifys[key] = true

        local NotificationParent = SetProps(MakeElement("TFrame"), {
            Size          = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent        = NotificationHolder
        })

        local NotificationFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(25, 25, 25), 0, 10), {
            Parent            = NotificationParent,
            Size              = UDim2.new(1, 0, 0, 0),
            Position          = UDim2.new(1, -55, 0, 0),
            BackgroundTransparency = 0,
            AutomaticSize     = Enum.AutomaticSize.Y
        }), {
            MakeElement("Padding", 16, 12, 12, 12),
            AddThemeObject(SetProps(MakeElement("Image", NotificationConfig.Image), {
                Size       = UDim2.new(0, 20, 0, 20),
                ImageColor3 = Color3.fromRGB(240, 240, 240),
                Name       = "Icon"
            }), "Text"),
            AddThemeObject(SetProps(MakeElement("Label", NotificationConfig.Name, 15), {
                Size     = UDim2.new(1, -30, 0, 20),
                Position = UDim2.new(0, 30, 0, 0),
                Font     = Enum.Font.GothamBold,
                Name     = "Title"
            }), "Text"),
            AddThemeObject(SetProps(MakeElement("Label", NotificationConfig.Content, 14), {
                Size          = UDim2.new(1, 0, 0, 0),
                Position      = UDim2.new(0, 0, 0, 25),
                Font          = Enum.Font.GothamSemibold,
                Name          = "Content",
                AutomaticSize = Enum.AutomaticSize.Y,
                TextColor3    = Color3.fromRGB(200, 200, 200),
                TextWrapped   = true
            }), "TextDark")
        }), "Second")

        vgs.TS:Create(NotificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
            Position = UDim2.new(0, 0, 0, 0)
        }):Play()

        task.wait(NotificationConfig.Time - 0.88)
        vgs.TS:Create(NotificationFrame:WaitForChild("Icon"), TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
            ImageTransparency = 1
        }):Play()
        vgs.TS:Create(NotificationFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {
            BackgroundTransparency = 0.6
        }):Play()
        task.wait(0.3)
        vgs.TS:Create(NotificationFrame.Title, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {
            TextTransparency = 0.4
        }):Play()
        vgs.TS:Create(NotificationFrame.Content, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {
            TextTransparency = 0.5
        }):Play()
        task.wait(0.05)

        NotificationFrame:TweenPosition(UDim2.new(1, 40, 0, 0), 'In', 'Quint', 0.8, true)
        task.wait(1.35)
        NotificationFrame:Destroy()
        OrionLib.Notifys[key] = nil
    end)
end

function OrionLib:Init()
    if OrionLib.SaveCfg and (isfile and readfile) then
        pcall(function()
            if isfile(OrionLib.Folder .. "/" .. game.GameId .. ".txt") then
                LoadCfg(readfile(OrionLib.Folder .. "/" .. game.GameId .. ".txt"))
                OrionLib:MakeNotification({
                    Name    = "Configuration",
                    Content = "Auto-loaded configuration for the game " .. game.GameId .. ".",
                    Time    = 5
                })
            end
        end)
    end
end

function OrionLib:MakeWindow(WindowConfig)
    local FirstTab = true
    local minimized = false
    local UIHidden  = false
    local tabOrderCounter = 0

    WindowConfig = WindowConfig or {}
    WindowConfig.Name            = WindowConfig.Name
    WindowConfig.ConfigFolder    = WindowConfig.ConfigFolder  or WindowConfig.Name
    WindowConfig.SaveConfig      = WindowConfig.SaveConfig    or false
    WindowConfig.TagText         = WindowConfig.TagText       or ""
    WindowConfig.HidePremium     = WindowConfig.HidePremium   or false
    if WindowConfig.IntroEnabled == nil then
        WindowConfig.IntroEnabled = true
    end
    WindowConfig.FreeMouse       = WindowConfig.FreeMouse     or true
    WindowConfig.Openkey         = WindowConfig.Openkey       or "M"
    WindowConfig.IntroText       = WindowConfig.IntroText     or "Orion Library"
    WindowConfig.CloseCallback   = WindowConfig.CloseCallback or function() end
    WindowConfig.ShowIcon        = WindowConfig.ShowIcon      or false
    WindowConfig.Icon            = WindowConfig.Icon          or "rbxassetid://8834748103"
    WindowConfig.IntroIcon       = WindowConfig.IntroIcon     or "rbxassetid://8834748103"
    WindowConfig.IconColorChange = WindowConfig.IconColorChange or false
    OrionLib.Folder  = WindowConfig.ConfigFolder
    OrionLib.SaveCfg = WindowConfig.SaveConfig

    if WindowConfig.FreeMouse then
        UnlockMouse(true)
    end

    if WindowConfig.SaveConfig then
        if (isfolder and makefolder) and not isfolder(WindowConfig.ConfigFolder) then
            makefolder(WindowConfig.ConfigFolder)
        end
    end

    local cch  = {}
    local nmpg = nil
    local SrchLn  = nil
    local Nmeline = nil
	
	function OrionLib:SetTheme()
		local themeData = self.Themes[self.SelectedTheme]
		if not themeData then return end
	
		local updates = {}
		local count   = 0
	
		for typeName, objects in next, self.ThemeObjects do
			local color = themeData[typeName]
			if not color and typeName == "Accent2" then color = themeData.Accent end
			if color then
				for i = 1, #objects do
					local obj = objects[i]
					if obj and obj.Parent then
						local prop = cch[obj]
						if not prop then
							if typeName == "Accent2" then
								prop = obj:IsA("UIStroke") and "Color" or "BackgroundColor3"
							else
								prop = ReturnProperty(obj)
							end
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
			local d = updates[i]
			d[1][d[2]] = d[3]
		end
		
		if self.Toggles then
			for _, toggle in ipairs(self.Toggles) do
				if toggle and toggle.Box and toggle.Box.Parent then
					local accolor = toggle.uccolor and toggle.ccolor or themeData.Accent
					if toggle.boxTween then toggle.boxTween:Cancel() end
					if toggle.strokeTween then toggle.strokeTween:Cancel() end
					toggle.Box.BackgroundColor3 = toggle.Value and accolor or themeData.Divider
					if toggle.Box:FindFirstChild("Stroke") then
						toggle.Box.Stroke.Color = toggle.Value and accolor or themeData.Stroke
					end
					if toggle.Box:FindFirstChild("Ico") then
						toggle.Box.Ico.ImageTransparency = toggle.Value and 0 or 1
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
	
		if nmpg and nmpg.Parent then
			nmpg.BackgroundColor3 = themeData.Accent
		end
		if SrchLn and SrchLn.Parent then
			SrchLn.BackgroundColor3 = themeData.Accent
		end
		if Nmeline and Nmeline.Parent then
			Nmeline.BackgroundColor3 = themeData.Accent
		end
	end

    local TabHolder = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255, 255, 255), 0), {
        Size     = UDim2.new(1, 0, 1, -58),
        Position = UDim2.new(0, 0, 0, 10)
    }), {
        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding   = UDim.new(0, 2),
            Parent    = nil
        }),
        Create("UIPadding", {
            PaddingTop    = UDim.new(0, 4),
            PaddingBottom = UDim.new(0, 4),
            PaddingLeft   = UDim.new(0, 4),
            PaddingRight  = UDim.new(0, 4),
            Parent        = nil
        })
    }), "Main")

    TabHolder.ScrollBarImageTransparency = 1

    AddConnection(TabHolder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        TabHolder.CanvasSize = UDim2.new(0, 0, 0, TabHolder.UIListLayout.AbsoluteContentSize.Y + 8)
    end)

    local CloseBtn = SetChildren(SetProps(MakeElement("Button"), {
        Size     = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.new(0.5, 0, 0, 0)
    }), {
        AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072725342"), {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position    = UDim2.new(0.5, 0, 0.5, 0),
            Size        = UDim2.new(0, 18, 0, 18)
        }), "Text")
    })

    local MinimizeBtn = SetChildren(SetProps(MakeElement("Button"), {
        Size = UDim2.new(0.5, 0, 1, 0)
    }), {
        AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072719338"), {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position    = UDim2.new(0.5, 0, 0.5, 0),
            Size        = UDim2.new(0, 18, 0, 18),
            Name        = "Ico"
        }), "Text")
    })

    local DragPoint = SetProps(MakeElement("TFrame"), {
        Size = UDim2.new(1, 0, 0, 36),
		Active = true
    })

    local ThumbImage = SetProps(MakeElement("Image",
        "https://www.roblox.com/headshot-thumbnail/image?userId=" .. vgs.p.UserId .. "&width=420&height=420&format=png"
    ), {
        Size = UDim2.new(1, 0, 1, 0)
    })

    local UserSection = SetChildren(SetProps(MakeElement("TFrame"), {
        Size     = UDim2.new(1, 0, 0, 48),
        Position = UDim2.new(0, 0, 1, -48)
    }), {
        AddThemeObject(SetProps(MakeElement("Frame"), {
            Size     = UDim2.new(0, 35, 0, 1),
            Position = UDim2.new(0.5, -14, 0, 0)
        }), "Stroke"),
        AddThemeObject(SetChildren(SetProps(MakeElement("Frame"), {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size        = UDim2.new(0, 34, 0, 34),
            Position    = UDim2.new(0.5, 3.5, 0.5, 1)
        }), {
            SetChildren(ThumbImage, {MakeElement("Corner", 0, 8)}),
            MakeElement("Corner", 0, 8)
        }), "Divider")
    })

    AddConnection(vgs.p.CharacterAppearanceLoaded, function()
        ThumbImage.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. vgs.p.UserId .. "&width=420&height=420&format=png&t=" .. tick()
    end)

    local ContentPanel = AddThemeObject(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 8), {
        Size             = UDim2.new(1, -52, 1, -44),
        Position         = UDim2.new(0, 48, 0, 40),
        ClipsDescendants = true,
		Active           = false
    }), "Second")

    local EmptyFrame = SetChildren(SetProps(MakeElement("TFrame"), {
        Size   = UDim2.new(1, 0, 1, 0),
        Parent = ContentPanel
    }), {
        Create("UIListLayout", {
            SortOrder           = Enum.SortOrder.LayoutOrder,
            FillDirection       = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            VerticalAlignment   = Enum.VerticalAlignment.Center,
            Padding             = UDim.new(0, 8),
            Parent              = nil
        }),
        SetProps(MakeElement("Image", "rbxassetid://2778270261"), {
            Size              = UDim2.new(0, 52, 0, 52),
            BackgroundTransparency = 1,
            ImageColor3       = Color3.fromRGB(255, 255, 255),
            ImageTransparency = 0.7,
            ScaleType         = Enum.ScaleType.Fit,
            LayoutOrder       = 1
        }),
        AddThemeObject(SetProps(MakeElement("Label", "No Tabs", 14), {
            Size           = UDim2.new(0, 160, 0, 18),
            Font           = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Center,
            LayoutOrder    = 2
        }), "TextDark"),
        AddThemeObject(SetProps(MakeElement("Label", "Add tabs with :MakeTab()", 12), {
            Size           = UDim2.new(0, 220, 0, 14),
            Font           = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Center,
            LayoutOrder    = 3
        }), "TextDark")
    })

    local Tabs = {}

    local SearchSystem = {
        elmnts   = {},
        results  = {},
        isserch  = false,
        tabs     = {},
        actvtab  = nil,
        butts    = {}
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
		local key   = tostring(elementName)
		local count = 1
		while SearchSystem.elmnts[tabName][key] do
			count = count + 1
			key = string.format('%s-%d', tostring(elementName), count)
		end
		SearchSystem.elmnts[tabName][key] = {
			frame          = elementFrame,
			originalParent = elementFrame.Parent,
			visible        = true
		}
	end

    local function Hlight(frame, highlight)
        if not frame then return end

        local glow = frame:FindFirstChild("SearchGlow")

        if highlight then
            if not glow then
                glow           = Instance.new("UIStroke")
                glow.Name      = "SearchGlow"
                glow.Thickness = 1
                glow.Transparency = 0
                glow.Parent    = frame
            end
            glow.Color = OrionLib.Themes[OrionLib.SelectedTheme].Accent or Color3.fromRGB(110, 95, 220)
            vgs.TS:Create(glow, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Thickness    = 2,
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
            if tabFrame:IsA("TextButton") then
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
                if b:FindFirstChild("Ico") then
                    vgs.TS:Create(b.Ico, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        ImageTransparency = 0.55
                    }):Play()
                end
                if b:FindFirstChild("Highlight") then
                    vgs.TS:Create(b.Highlight, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        BackgroundTransparency = 1
                    }):Play()
                end
                if b:FindFirstChild("ABar") then
                    vgs.TS:Create(b.ABar, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        Position               = UDim2.new(0, -4, 0.5, -9),
                        BackgroundTransparency = 1
                    }):Play()
                end
            end
        end

        local tb = SearchSystem.butts[tab]

        if tb:FindFirstChild("Ico") then
            vgs.TS:Create(tb.Ico, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                ImageTransparency = 0
            }):Play()
        end
        if tb:FindFirstChild("Highlight") then
            vgs.TS:Create(tb.Highlight, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0.82
            }):Play()
        end
        if tb:FindFirstChild("ABar") then
            vgs.TS:Create(tb.ABar, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position               = UDim2.new(0, 0, 0.5, -9),
                BackgroundTransparency = 0
            }):Play()
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
                        local ok  = (tn == tab)
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

                local prev    = false
                local spnsecc = false

                for _, e in ipairs(q) do
                    if e.s then
                        local l     = e.f:FindFirstChild("TextLabel")
                        local n     = l and l.Text or ""
                        local vazio = n == "" or n:match("^%s*$")
                        local s     = string.lower(SearchSystem.srchTxt or "")
                        local match = not vazio and s ~= "" and string.find(string.lower(n), s, 1, true) ~= nil

                        if match then
                            e.f.Visible = true
                            prev        = true
                            spnsecc     = false
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
                        prev    = true
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
                        d.frame.Visible = (tn == tab) and d.visible
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
	
		if #serchtext < 2 then
			ClearR()
			return
		end
	
		SearchSystem.isserch = true
		SearchSystem.results = {}
	
		local hasExact      = false
		local hasStartsWith = false
		local hasSubstring  = false
	
		for tabName, elements in pairs(SearchSystem.elmnts) do
			for elementName, _ in pairs(elements) do
				local lname = string.lower(elementName)
				if lname == serchtext then
					hasExact = true
				elseif string.sub(lname, 1, #serchtext) == serchtext then
					hasStartsWith = true
				elseif string.find(lname, serchtext, 1, true) ~= nil then
					hasSubstring = true
				end
			end
		end
	
		local matchLevel = hasExact and "exact" or (hasStartsWith and "startswith" or (hasSubstring and "substring" or nil))
		if not matchLevel then return end
	
		local scores = {}
		for tabName, _ in pairs(SearchSystem.elmnts) do
			scores[tabName] = 0
		end
	
		for tabName, elements in pairs(SearchSystem.elmnts) do
			for elementName, data in pairs(elements) do
				local lname   = string.lower(elementName)
				local matches = false
				if matchLevel == "exact" then
					matches = lname == serchtext
				elseif matchLevel == "startswith" then
					matches = string.sub(lname, 1, #serchtext) == serchtext
				else
					matches = string.find(lname, serchtext, 1, true) ~= nil
				end
				if matches then
					scores[tabName] = scores[tabName] + 1
					SearchSystem.results[tabName] = SearchSystem.results[tabName] or {}
					SearchSystem.results[tabName][elementName] = data
				end
			end
		end
	
		local btab   = nil
		local bscore = 0
	
		local currtab = SearchSystem.actvtab
		if currtab and scores[currtab] and scores[currtab] > 0 then
			btab = currtab
		else
			for tabName, score in pairs(scores) do
				if score > bscore then
					bscore = score
					btab   = tabName
				end
			end
		end
	
		if btab then
			Gotab(btab)
		end
	end

    local WindowName = AddThemeObject(SetProps(MakeElement("Label", WindowConfig.Name, 14), {
        Size         = UDim2.new(1, -90, 1, 0),
        Position     = UDim2.new(0, 12, 0, 2),
        Font         = Enum.Font.GothamBold,
        TextSize     = 15,
        TextTruncate = Enum.TextTruncate.AtEnd
    }), "Text")
	
	local MainWindow = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 12), {
		Parent           = Orion,
		Position         = UDim2.new(0.5, -307, 0.5, -172),
		Size             = UDim2.new(0, 615, 0, 344),
		ClipsDescendants = true,
		Active           = false  
	}), {
        SetChildren(SetProps(MakeElement("TFrame"), {
            Size = UDim2.new(1, 0, 0, 36),
            Name = "TopBar"
        }), {
            WindowName,
            SetChildren(SetProps(MakeElement("TFrame"), {
                Size     = UDim2.new(0, 52, 0, 30),
                Position = UDim2.new(1, -58, 0, 3)
            }), {
                CloseBtn,
                MinimizeBtn
            })
        }),
        DragPoint,
        SetChildren(SetProps(MakeElement("TFrame"), {
            Size             = UDim2.new(0, 44, 1, -36),
            Position         = UDim2.new(0, 0, 0, 36),
            Name             = "TabStrip",
            ClipsDescendants = true,
			Active           = false
        }), {
            AddThemeObject(Create("Frame", {
                Size            = UDim2.new(0, 35, 0, 1),
                AnchorPoint     = Vector2.new(0.5, 0),
                Position        = UDim2.new(0.5, -1, 0, 6),
                BorderSizePixel = 0,
                ZIndex          = 2,
                Name            = "TabSeparatorTop"
            }), "Stroke"),
            TabHolder,
            UserSection
        }),
        ContentPanel
    }), "Main")


    local SearchOpen = false

    local SearchInput = Create("TextBox", {
        Size                   = UDim2.new(1, -90, 1, 0),
        Position               = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Font                   = Enum.Font.GothamBold,
        TextSize               = 15,
        TextColor3             = Color3.fromRGB(235, 235, 245),
        PlaceholderColor3      = Color3.fromRGB(110, 110, 145),
        PlaceholderText        = "Search...",
        Text                   = "",
        ClearTextOnFocus       = false,
        TextXAlignment         = Enum.TextXAlignment.Left,
        Visible                = false,
        ZIndex                 = 3,
        Name                   = "SearchInput",
        Parent                 = MainWindow.TopBar
    })

    local Acolor = OrionLib.Themes[OrionLib.SelectedTheme].Accent

    SrchLn = Create("Frame", {
        Size             = UDim2.new(0, 0, 0, 1),
        Position         = UDim2.new(0, 12, 1, -1),
        BackgroundColor3 = Acolor,
        BorderSizePixel  = 0,
        ZIndex           = 3,
        Parent           = MainWindow.TopBar
    })

    local srchdly = nil
    local srchfcs = nil
    local ha      = false
    local ht      = nil
    local nedit   = false
    local nclc    = nil
    local iconha  = false
    local iconht  = nil

    local function Osearch()
        if minimized then return end
        if srchdly then task.cancel(srchdly); srchdly = nil end
        ha = false
        if ht then task.cancel(ht); ht = nil end
        if nmpg then nmpg.Size = UDim2.new(0, 0, 0, 2) end
        WindowName.TextTransparency = 0
        if nclc then nclc.Visible = false end

        SearchOpen = true
        local titleX = WindowName.Position.X.Offset
        SearchInput.Position = UDim2.new(0, titleX, 0, 0)
        SearchInput.Size     = UDim2.new(1, -90, 1, 0)
        SrchLn.Position      = UDim2.new(0, titleX, 1, -1)
        WindowName.Visible   = false
        SearchInput.Visible  = true

        vgs.TS:Create(SrchLn, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, -(90 + titleX), 0, 1)
        }):Play()

        if srchfcs then task.cancel(srchfcs); srchfcs = nil end
        srchfcs = task.delay(0.1, function()
            srchfcs = nil
            if SearchOpen and SearchInput and SearchInput.Parent then
                SearchInput:CaptureFocus()
            end
        end)
    end

    local function Csearch()
        if not SearchOpen then return end
        SearchOpen = false
        if srchfcs then task.cancel(srchfcs); srchfcs = nil end
        if SearchInput and SearchInput.Parent then
            SearchInput:ReleaseFocus()
        end

        vgs.TS:Create(SrchLn, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 0, 0, 1)
        }):Play()

        srchdly = task.delay(0.22, function()
            srchdly = nil
            if SearchOpen then return end
            if SearchInput and SearchInput.Parent then
                SearchInput.Text    = ""
                SearchInput.Visible = false
            end
            if WindowName and WindowName.Parent then
                WindowName.Visible = true
            end
            if nclc and nclc.Parent and not minimized then
                nclc.Visible = true
            end
        end)

        ClearR()
    end

    AddConnection(SearchInput:GetPropertyChangedSignal("Text"), function()
        search(SearchInput.Text)
        SearchSystem.srchTxt = SearchInput.Text
    end)

    AddConnection(SearchInput.FocusLost, function()
        if not SearchOpen then return end
        Csearch()
    end)

    AddConnection(vgs.UIS.InputBegan, function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.Escape and SearchOpen then
            Csearch()
        end
    end)

    AddConnection(MainWindow:GetPropertyChangedSignal("Size"), function()
        if SearchOpen and MainWindow.Size.Y.Offset <= 36 then
            Csearch()
        end
    end)
	
	local tttip = SetProps(MakeElement("Label", "", 12), {
		Size                   = UDim2.new(0, 0, 0, 26),
		AutomaticSize          = Enum.AutomaticSize.X,
		Position               = UDim2.new(0, 50, 0, 0),
		BackgroundTransparency = 0,
		TextColor3             = Color3.fromRGB(220, 220, 235),
		Font                   = Enum.Font.GothamBold,
		TextSize               = 14,
		Visible                = false,
		ZIndex                 = 10,
		Name                   = "tttip",
		TextXAlignment         = Enum.TextXAlignment.Left
	})
	
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft  = UDim.new(0, 10)
	pad.PaddingRight = UDim.new(0, 10)
	pad.Parent       = tttip
	
	local cor = Instance.new("UICorner")
	cor.CornerRadius = UDim.new(0, 5)
	cor.Parent       = tttip
	
	AddThemeObject(tttip, "Accent2")  
	
	tttip.Parent = MainWindow

    resizebtt.Size             = UDim2.new(0, 16, 0, 16)
    resizebtt.Position         = UDim2.new(1, -19, 1, -19)
    resizebtt.BorderSizePixel  = 0
    resizebtt.Parent           = MainWindow
    resizebtt.Visible          = true
    resizebtt.AnchorPoint      = Vector2.new(0.1, 0.1)
    resizebtt.BackgroundTransparency = 1
    resizebtt.ClipsDescendants = false

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0.5, 0)
    UICorner.Parent = resizebtt

    resizebtt.BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Main

    local ResizeIco = Instance.new("ImageLabel")
    ResizeIco.Size             = UDim2.new(1, 0, 1, 0)
    ResizeIco.BackgroundTransparency = 1
    ResizeIco.Image            = "rbxassetid://153287173"
    ResizeIco.ImageTransparency = 0.3
    ResizeIco.Parent           = resizebtt

    local drgg    = false
    local mspos   = nil
    local nresize = 0
    local default = UDim2.new(0, 615, 0, 344)

    AddConnection(resizebtt.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local cctime = tick()

            if cctime - nresize <= 0.5 then
                vgs.TS:Create(MainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = default
                }):Play()
                drgg = false
            else
                drgg  = true
                mspos = input.Position
            end

            nresize = cctime
        end
    end)

    AddConnection(vgs.UIS.InputChanged, function(input)
        if drgg and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - mspos
            mspos = input.Position
            MainWindow.Size = UDim2.new(
                0, math.max(415, MainWindow.Size.X.Offset + delta.X),
                0, math.max(307, MainWindow.Size.Y.Offset + delta.Y)
            )
        end
    end)

    AddConnection(vgs.UIS.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            drgg = false
        end
    end)

    local lctime = 0
    local dctime = 0.15

    AddConnection(DragPoint.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local cctime2  = tick()
            local timediff = cctime2 - lctime

            if timediff <= dctime and minimized then
                mouse1release()
                local screenSize = workspace.CurrentCamera.ViewportSize
                local windowSize = MainWindow.AbsoluteSize
                local xPos       = (screenSize.X - windowSize.X) / 2
                local yPos       = -55
                local crposs     = MainWindow.Position
                local ds         = math.sqrt(
                    math.pow(crposs.X.Offset - xPos, 2) +
                    math.pow(crposs.Y.Offset - yPos, 2)
                )
                local mdss  = math.sqrt(screenSize.X ^ 2 + screenSize.Y ^ 2)
                local ttime = 0.5 + (math.clamp(ds / mdss, 0, 1) * 1.5)

                vgs.TS:Create(MainWindow, TweenInfo.new(ttime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0, xPos, 0, yPos)
                }):Play()

                lctime = 0
            else
                lctime = cctime2
            end
        end
    end)

    if WindowConfig.ShowIcon then
        WindowName.Position = UDim2.new(0, 42, 0, 0)

        local iconOriginal   = WindowConfig.Icon
        local searchImg      = "rbxassetid://118685771787843"
        local iconSearchOpen = false

        local WindowIcon
        if not WindowConfig.IconColorChange then
            WindowIcon = SetProps(MakeElement("Image", iconOriginal), {
                Size        = UDim2.new(0, 36, 0, 36),
                AnchorPoint = Vector2.new(0, 0.5),
                Position    = UDim2.new(0, 2, 0.5, 0),
                Name        = "WindowIcon"
            })
        else
            WindowIcon = AddThemeObject(SetProps(MakeElement("Image", iconOriginal), {
                Size        = UDim2.new(0, 36, 0, 36),
                AnchorPoint = Vector2.new(0, 0.5),
                Position    = UDim2.new(0, 2, 0.5, 0),
                Name        = "WindowIcon"
            }), "Accent")
        end
        WindowIcon.Parent = MainWindow.TopBar

        local bclse = Csearch
        Csearch = function()
            bclse()
            if not iconSearchOpen then return end
            iconSearchOpen = false
            WindowIcon.Rotation = 0
            task.delay(0.05, function()
                if WindowIcon and WindowIcon.Parent then
                    WindowIcon.Image = iconOriginal
                end
            end)
        end

        AddConnection(WindowIcon.InputBegan, function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
            if minimized then return end

            if iconSearchOpen then
                Csearch()
                return
            end

            ha = false
            if ht then task.cancel(ht); ht = nil end
            if nmpg then nmpg.Size = UDim2.new(0, 0, 0, 2) end
            WindowName.TextTransparency = 0

            iconha = true
            iconht = task.spawn(function()
                local elapsed = 0
                local dur     = 3

                while iconha and elapsed < dur do
                    elapsed = elapsed + task.wait(0.016)
                    nmpg.Size = UDim2.new(math.clamp(elapsed / dur, 0, 1), 0, 0, 2)
                    WindowIcon.Rotation = 360 * math.clamp(elapsed / dur, 0, 1)
                end

                nmpg.Size = UDim2.new(0, 0, 0, 2)

                if iconha then
                    iconSearchOpen = true
                    WindowIcon.Rotation = 0
                    WindowIcon.Image    = searchImg
                    Osearch()
                else
                    vgs.TS:Create(WindowIcon, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                        Rotation = 0
                    }):Play()
                end

                iconht = nil
            end)
        end)

        AddConnection(WindowIcon.InputEnded, function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
            if not iconha then return end
            iconha    = false
            nmpg.Size = UDim2.new(0, 0, 0, 2)

            if iconht then task.cancel(iconht); iconht = nil end

            if not iconSearchOpen then
                vgs.TS:Create(WindowIcon, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Rotation = 0
                }):Play()
            end
        end)
    end

    ContentPanel:GetPropertyChangedSignal("Visible"):Connect(function()
        resizebtt.Visible = ContentPanel.Visible
    end)

    nmpg = Create("Frame", {
        Size             = UDim2.new(0, 0, 0, 2),
        Position         = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Accent,
        BorderSizePixel  = 0,
        ZIndex           = 6,
        Parent           = MainWindow.TopBar
    })

    Nmeline = Create("Frame", {
        Size             = UDim2.new(0, 0, 0, 1),
        Position         = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Accent,
        BorderSizePixel  = 0,
        ZIndex           = 6,
        Parent           = MainWindow.TopBar
    })

    local nmebox = Create("TextBox", {
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Font                   = Enum.Font.GothamBold,
        TextSize               = 15,
        TextColor3             = Color3.fromRGB(235, 235, 245),
        PlaceholderColor3      = Color3.fromRGB(110, 110, 145),
        PlaceholderText        = "New name...",
        Text                   = "",
        ClearTextOnFocus       = false,
        TextXAlignment         = Enum.TextXAlignment.Left,
        Visible                = false,
        ZIndex                 = 5,
        Name                   = "nmebox",
        Parent                 = MainWindow.TopBar
    })

	nclc = SetProps(MakeElement("Button"), {
		ZIndex = 3, Parent = MainWindow.TopBar
	})

	local function syncsyz()
		local pos  = WindowName.Position
		local textW = math.max(1, WindowName.TextBounds.X + 4)
		nclc.Position   = pos
		nclc.Size       = UDim2.new(0, textW, 1, 0)
		nmebox.Position = pos
		nmebox.Size     = WindowName.Size
		Nmeline.Position = UDim2.new(pos.X.Scale, pos.X.Offset, 1, -1)
	end
	syncsyz()
	AddConnection(WindowName:GetPropertyChangedSignal("TextBounds"), syncsyz)
	AddConnection(MainWindow:GetPropertyChangedSignal("Size"), syncsyz)

	local function Onme()
		if nedit then return end
		nedit = true
		ha  = false
		syncsyz()
		nmebox.Text = WindowName.ContentText ~= "" and WindowName.ContentText or WindowName.Text
		WindowName.Visible  = false
		nclc.Visible   = false
		nmebox.Visible = true
		vgs.TS:Create(Nmeline, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{Size = UDim2.new(nmebox.Size.X.Scale, nmebox.Size.X.Offset, 0, 1)}):Play()
		task.delay(0.1, function() if nmebox and nmebox.Parent then nmebox:CaptureFocus() end end)
	end

	local function CNe(confirm)
		if not nedit then return end
		nedit = false
		pcall(function() nmebox:ReleaseFocus() end)
		vgs.TS:Create(Nmeline, TweenInfo.new(0.2), {Size = UDim2.new(0,0,0,1)}):Play()
		if confirm and nmebox.Text ~= "" then
			WindowName.RichText = false
			WindowName.Text = nmebox.Text
			WindowConfig.Name = nmebox.Text
		end
		nmebox.Visible = false
		nclc.Visible   = true
		WindowName.Visible  = true
	end

	local Hcpl = false

	AddConnection(nclc.InputBegan, function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		if minimized then return end
		if iconha then
			iconha = false
			if iconht then task.cancel(iconht); iconht = nil end
			if nmpg then nmpg.Size = UDim2.new(0,0,0,2) end
		end
		ha    = true
		Hcpl = false
		ht = task.spawn(function()
			local elapsed = 0
			local dur = 4
			while ha and elapsed < dur do
				elapsed = elapsed + task.wait(0.016)
				nmpg.Size = UDim2.new(math.clamp(elapsed/dur,0,1), 0, 0, 2)
				WindowName.TextTransparency = 0.25 * math.abs(math.sin(elapsed * 5))
			end
			nmpg.Size = UDim2.new(0,0,0,2)
			WindowName.TextTransparency = 0
			if ha then
				Hcpl = true
				Onme()
			end
		end)
	end)

	AddConnection(nclc.InputEnded, function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		if Hcpl then Hcpl = false; return end
		ha = false
		nmpg.Size = UDim2.new(0,0,0,2)
		WindowName.TextTransparency = 0
		if ht then task.cancel(ht) ht = nil end
		task.spawn(function()
			local baseX = WindowName.Position.X.Offset
			local baseS = WindowName.Position.X.Scale
			for i = 1, 4 do
				vgs.TS:Create(WindowName, TweenInfo.new(0.04, Enum.EasingStyle.Linear),
					{Position = UDim2.new(baseS, baseX + (i%2==0 and 4 or -4), 0, 0)}):Play()
				task.wait(0.04)
			end
			vgs.TS:Create(WindowName, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{Position = UDim2.new(baseS, baseX, 0, 0)}):Play()
		end)
	end)

	AddConnection(nmebox.FocusLost, function()
		CNe(true)
	end)

	AddConnection(vgs.UIS.InputBegan, function(input, gp)
		if gp or not nedit then return end
		if input.KeyCode == Enum.KeyCode.Escape then CNe(false)
		elseif input.KeyCode == Enum.KeyCode.Return then CNe(true) end
	end)

	MakeDraggable(DragPoint, MainWindow)

	AddConnection(CloseBtn.MouseButton1Up, function()
		MainWindow.Visible = false; UIHidden = true
		if WindowConfig.FreeMouse then UnlockMouse(false) end
		WindowConfig.CloseCallback()
	end)

	AddConnection(vgs.UIS.InputBegan, function(Input, Focus)
		if not Focus then
			if Input.KeyCode == Enum.KeyCode[WindowConfig.Openkey] and UIHidden then
				MainWindow.Visible = true; UIHidden = false
				if WindowConfig.FreeMouse then UnlockMouse(true) end
			elseif Input.KeyCode == Enum.KeyCode[WindowConfig.Openkey] and not UIHidden then
				MainWindow.Visible = false; UIHidden = true
				if WindowConfig.FreeMouse then UnlockMouse(false) end
				WindowConfig.CloseCallback()
				OrionLib:MakeNotification({Name="Interface Hidden", Content="Tap "..WindowConfig.Openkey.." to reopen the interface", Time=3})
			end
		end
	end)

	local reztween = nil
	local mintween = nil

	local function gnw()
		local plain = WindowName.ContentText ~= "" and WindowName.ContentText or WindowName.Text
		return vgs.TTS:GetTextSize(plain, WindowName.TextSize, WindowName.Font, Vector2.new(math.huge, math.huge)).X
	end

	local function updminframe()
		if not minimized then return end
		if reztween then reztween:Cancel(); reztween = nil end
		local nwdth = math.clamp(gnw() + 128, 0, 1100)
		if MainWindow.Size.X.Offset == nwdth then return end
		reztween = vgs.TS:Create(MainWindow, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, nwdth, 0, 36)
		})
		reztween:Play()
	end

	AddConnection(WindowName:GetPropertyChangedSignal("TextBounds"), updminframe)

	AddConnection(MinimizeBtn.MouseButton1Click, function()
		if reztween then reztween:Cancel(); reztween = nil end
		if mintween then mintween:Cancel(); mintween = nil end
		minimized = not minimized
		if minimized then
			MainWindow.ClipsDescendants = true
			ContentPanel.Visible = false
			MainWindow.TabStrip.Visible = false
			MinimizeBtn.Ico.Image = "rbxassetid://7072720870"
			nclc.Visible = false
			local textW = gnw()
			local winW  = math.clamp(textW + 110, 0, 1100)
			if (textW + 120) <= 1100 then
				WindowName.TextTruncate = Enum.TextTruncate.None
				WindowName.Size = UDim2.new(0, textW, 1, 0)
			end
			mintween = vgs.TS:Create(MainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, winW, 0, 36)
			})
			mintween:Play(); mintween.Completed:Wait()
		else
			MinimizeBtn.Ico.Image = "rbxassetid://7072719338"
			WindowName.TextTruncate = Enum.TextTruncate.AtEnd
			WindowName.Size = UDim2.new(1, -90, 1, 0)
			nclc.Visible = true
			mintween = vgs.TS:Create(MainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, 615, 0, 344)
			})
			mintween:Play()
			task.spawn(function()
				task.wait(0.05)
				MainWindow.ClipsDescendants = false
				ContentPanel.Visible = true
				MainWindow.TabStrip.Visible = true
			end)
			mintween.Completed:Wait()
		end
	end)

	local function LoadSequence()
		MainWindow.Visible = false
		local screen = workspace.CurrentCamera.ViewportSize
		local iconS  = math.clamp(math.floor(math.min(screen.X, screen.Y) * 0.07), 36, 80)
		local LoadSequenceLogo = SetProps(MakeElement("Image", WindowConfig.IntroIcon), {
			Parent = Orion, AnchorPoint = Vector2.new(0.5,0.5),
			Position = UDim2.new(1,0,0.4,0), Size = UDim2.new(0,iconS,0,iconS),
			ImageColor3 = Color3.fromRGB(255,255,255), ImageTransparency = 1,
			ScaleType = Enum.ScaleType.Fit
		})
		
		local scconn = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			local s2 = workspace.CurrentCamera.ViewportSize
			local ns = math.clamp(math.floor(math.min(s2.X, s2.Y) * 0.07), 36, 80)
			LoadSequenceLogo.Size = UDim2.new(0, ns, 0, ns)
		end)
		local LoadSequenceText = SetProps(MakeElement("Label", WindowConfig.IntroText, 14), {
			Parent = Orion, Size = UDim2.new(1,0,1,0),
			AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new(0.5,19,0.5,0),
			TextXAlignment = Enum.TextXAlignment.Center, Font = Enum.Font.GothamBold,
			TextTransparency = 1
		})
		vgs.TS:Create(LoadSequenceLogo, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency=0, Position=UDim2.new(0.5,0,0.5,0)}):Play()
		task.wait(0.8)
		vgs.TS:Create(LoadSequenceLogo, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position=UDim2.new(0.5,-(LoadSequenceText.TextBounds.X/2),0.5,0)}):Play()
		task.wait(0.3)
		vgs.TS:Create(LoadSequenceText, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency=0}):Play()
		task.wait(2)
		vgs.TS:Create(LoadSequenceText, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency=1}):Play()
		MainWindow.Visible = true
		scconn:Disconnect()
		LoadSequenceLogo:Destroy(); LoadSequenceText:Destroy()
	end

	if WindowConfig.IntroEnabled then LoadSequence() end
	if WindowConfig.FreeMouse then
		OrionLib:MakeNotification({
			Name = "Free Mouse mode is on",
			Content = "if you want it to go back to normal, just press " .. WindowConfig.Openkey .. " or close the GUI",
			Time = 5
		})
	end

	local Functions = {}

	function Functions:ChangeIcon(IconId)
		local ficon = string.match(IconId, "rbxassetid://") and IconId or "rbxassetid://"..IconId
		local WindowIcon = MainWindow.TopBar:FindFirstChild("WindowIcon")
		if WindowIcon then WindowIcon.Image = ficon
		else
			WindowConfig.ShowIcon = true
			WindowName.Position = UDim2.new(0,42,0,0)
			if not WindowConfig.IconColorChange == true then
				WindowIcon = SetProps(MakeElement("Image", ficon), {
					Size = UDim2.new(0,36,0,36), AnchorPoint = Vector2.new(0,0.5),
					Position = UDim2.new(0,2,0.5,0), Name = "WindowIcon"
				})
			else
				WindowIcon = AddThemeObject(SetProps(MakeElement("Image", ficon), {
					Size = UDim2.new(0,36,0,36), AnchorPoint = Vector2.new(0,0.5),
					Position = UDim2.new(0,2,0.5,0), Name = "WindowIcon"
				}), "Accent")
			end
			WindowIcon.Parent = MainWindow.TopBar
		end
		WindowConfig.Icon = ficon
	end

	function Functions:SetName(...)
		local args = {...}; local result = ""
		for _, pair in ipairs(args) do
			local text, color = unpack(pair); color = color or "#FFFFFF"
			for i = 1, #text do
				result = result .. '<font color="'..color..'">'..text:sub(i,i)..'</font>'
			end
		end
		WindowName.RichText = true; WindowName.Text = result
	end

	function Functions:MakeTab(TabConfig)
		TabConfig = TabConfig or {}
		TabConfig.Name       = TabConfig.Name       or "Tab"
		TabConfig.Icon       = TabConfig.Icon       or ""
		TabConfig.PremiumOnly = TabConfig.PremiumOnly or false

		local ABar = SetProps(MakeElement("RoundFrame", OrionLib.Themes[OrionLib.SelectedTheme].Accent, 0, 2), {
			Size = UDim2.new(0,3,0,18),
			Position = UDim2.new(0,-4,0.5,-9),
			AnchorPoint = Vector2.new(0,0),
			BackgroundTransparency = 1,
			Name = "ABar"
		})
		AddThemeObject(ABar, "Accent")

		tabOrderCounter = tabOrderCounter + 1

		local TabFrame = SetChildren(SetProps(MakeElement("Button"), {
			Size = UDim2.new(1,2,0,36),
			Parent = TabHolder,
			LayoutOrder = tabOrderCounter
		}), {
			AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 6), {
				Size = UDim2.new(1,0,1,0),
				BackgroundTransparency = 1,
				Name = "Highlight"
			}), {}), "Second"),
			ABar,
			AddThemeObject(SetProps(MakeElement("Image", TabConfig.Icon), {
				AnchorPoint = Vector2.new(0.5,0.5),
				Size = UDim2.new(0,18,0,18),
				Position = UDim2.new(0.5,0,0.5,0),
				ImageTransparency = 0.55,
				Name = "Ico"
			}), "Text")
		})

		local Datc   = false
		local dtrack = false
		local dconn  = nil
		local ddend  = nil
		
		local function ctdrag(wasClick)
			dtrack = false
			if dconn then dconn(); dconn = nil end
			if ddend then ddend(); ddend = nil end
		
			if Datc then
				Datc = false
				local isActive = SearchSystem.actvtab == TabConfig.Name
				local ti = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
				vgs.TS:Create(TabFrame.Highlight, ti, {
					BackgroundColor3       = OrionLib.Themes[OrionLib.SelectedTheme].Second,
					BackgroundTransparency = isActive and 0.82 or 1
				}):Play()
				vgs.TS:Create(TabFrame.Ico, ti, { ImageTransparency = isActive and 0 or 0.55 }):Play()
			elseif wasClick then
				Gotab(TabConfig.Name)
			end
		end
		
		AddConnection(TabFrame.InputBegan, function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 or dtrack then return end
			dtrack = true
			Datc   = false
			local startY = input.Position.Y
		
			_, dconn = AddConnection(vgs.UIS.InputChanged, function(inp)
				if inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
		
				if not Datc and math.abs(inp.Position.Y - startY) > 8 then
					Datc = true
					tttip.Visible = false
					local ti = TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
					vgs.TS:Create(TabFrame.Highlight, ti, {
						BackgroundColor3       = OrionLib.Themes[OrionLib.SelectedTheme].Accent,
						BackgroundTransparency = 0.55
					}):Play()
					vgs.TS:Create(TabFrame.Ico, ti, { ImageTransparency = 0 }):Play()
				end
		
				if not Datc then return end
				local habt = TabHolder.AbsolutePosition.Y
				local canvy    = TabHolder.CanvasPosition.Y
				local msrely  = inp.Position.Y - habt + canvy
				local tabs = {}
				for _, child in pairs(TabHolder:GetChildren()) do
					if child:IsA("TextButton") and child ~= TabFrame then
						table.insert(tabs, {
							frame = child,
							midY  = child.AbsolutePosition.Y - habt + canvy + child.AbsoluteSize.Y * 0.5,
							lo    = child.LayoutOrder
						})
					end
				end
				table.sort(tabs, function(a, b) return a.lo < b.lo end)
				local insertPos = #tabs + 1
				for i, t in ipairs(tabs) do if msrely < t.midY then insertPos = i break end end
				local lo = 1
				for i, t in ipairs(tabs) do
					if i == insertPos then lo = lo + 1 end
					t.frame.LayoutOrder = lo
					lo = lo + 1
				end
				TabFrame.LayoutOrder = insertPos
			end)
		
			_, ddend = AddConnection(vgs.UIS.InputEnded, function(inp)
				if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
				ctdrag(not Datc)
			end)
		end)

		AddConnection(TabFrame.MouseEnter, function()
			if Datc then return end
			tttip.Text = TabConfig.Name
			local absPos = TabFrame.AbsolutePosition
			local mainPos = MainWindow.AbsolutePosition
			local relY = absPos.Y - mainPos.Y + (TabFrame.AbsoluteSize.Y / 2) - 13
			tttip.Position = UDim2.new(0, 50, 0, relY)
			tttip.Visible = true
			if SearchSystem.actvtab ~= TabConfig.Name then
				vgs.TS:Create(TabFrame.Highlight, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0.88}):Play()
				vgs.TS:Create(TabFrame.Ico, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = 0.25}):Play()
			end
		end)

		AddConnection(TabFrame.MouseLeave, function()
			tttip.Visible = false
			if Datc then return end
			if SearchSystem.actvtab ~= TabConfig.Name then
				vgs.TS:Create(TabFrame.Highlight, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
				vgs.TS:Create(TabFrame.Ico, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = 0.55}):Play()
			end
		end)

		AddItemTable(Tabs, TabConfig.Name, TabFrame)
		
		local Container = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255,255,255), 5), {
			Size    = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Parent  = ContentPanel,
			Visible = false,
			Name    = "ItemContainer",
			Active  = false 
		}), {
		MakeElement("List", 0, 6),
			MakeElement("Padding", 15, 10, 10, 15)
		}), "Main")

		Container.Name = TabConfig.Name
		Container.ScrollBarImageTransparency = 1

		AddConnection(Container.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
			Container.CanvasSize = UDim2.new(0,0,0, Container.UIListLayout.AbsoluteContentSize.Y + 30)
		end)

		RTab(TabConfig.Name, Container)
		Rbutton(TabConfig.Name, TabFrame)

		if FirstTab then
			FirstTab = false
			TabFrame.Ico.ImageTransparency = 0
			TabFrame.Highlight.BackgroundTransparency = 0.82
			vgs.TS:Create(TabFrame.ABar, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Position = UDim2.new(0,0,0.5,-9), BackgroundTransparency = 0
			}):Play()
			Container.Visible = true
			SearchSystem.actvtab = TabConfig.Name
			if EmptyFrame and EmptyFrame.Parent then
				vgs.TS:Create(EmptyFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
				task.delay(0.2, function() if EmptyFrame and EmptyFrame.Parent then EmptyFrame.Visible = false end end)
			end
		end

		local function Getelmnts(ItemParent, _tabName)
			local lreg = nil
			local orgrel = Relem
			local Relem = function(t, n, f) lreg = {tabName=t, name=n, frame=f}; orgrel(t, n, f) end

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
			
			local function parsec(text)
				return (text:gsub('<#(%x+)"([^"]+)">', '<font color="#%1">%2</font>'))
			end
			
				function ElementFunction:AddParagraph(id, Text, Content, Align)
					local plrp = tonumber(id) ~= nil
					if not plrp then Align = Content Content = Text Text = id id = "" end
					Align = Align or "Left"
				
					local isCenter = Align == "Center"
					local isRight  = Align == "Right"
				
					local initH = plrp and (isCenter and 90 or 60) or 30
				
					local titleXOff = plrp and (isCenter and 12 or (isRight and 12 or 62)) or 12
					local titleWOff = plrp and (isCenter and -24 or -72) or -12
					local titleYOff = plrp and (isCenter and 30 or 10) or 10
				
					local contentXOff = plrp and (isCenter and 12 or (isRight and 12 or 62)) or 12
					local contentWOff = plrp and (isCenter and -24 or -72) or -24
					local contentYOff = plrp and (isCenter and 84 or 32) or 26
				
					local ParagraphFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
						Size = UDim2.new(1, 0, 0, initH),
						BackgroundTransparency = 0.7,
						Parent = ItemParent
					}), {
						AddThemeObject(SetProps(MakeElement("Label", parsec(Text), 15), {
							Size     = UDim2.new(1, titleWOff, 0, 14),
							Position = UDim2.new(0, titleXOff, 0, titleYOff),
							Font     = Enum.Font.GothamBold,
							Name     = "Title",
							TextWrapped    = true,
							RichText       = true,
							TextXAlignment = Enum.TextXAlignment[Align]
						}), "Text"),
						AddThemeObject(SetProps(MakeElement("Label", "", 13), {
							Size     = UDim2.new(1, contentWOff, 0, 0),
							Position = UDim2.new(0, contentXOff, 0, contentYOff),
							Font     = Enum.Font.GothamSemibold,
							Name     = "Content",
							TextWrapped    = true,
							RichText       = true,
							TextXAlignment = Enum.TextXAlignment[Align]
						}), "TextDark"),
						AddThemeObject(MakeElement("Stroke"), "Stroke")
					}), "Second")
				
					local OptBtn
					if plrp then
						local imgPos = isCenter and UDim2.new(0.5, -30, 0, 0)
									or isRight  and UDim2.new(1, -60, 0, 0)
									or UDim2.new(0, 0, 0, 0)
				
						OptBtn = SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(40, 40, 40)), {
							Parent = ParagraphFrame,
							Size   = UDim2.new(0, 60, 0, 60),
							Position = imgPos,
							BackgroundTransparency = 1,
						}), {
							MakeElement("Corner", 0, 6),
							SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 10), {
								Size = UDim2.new(0, 50, 0, 50),
								Position = UDim2.new(0, 5, 0, 5),
								ClipsDescendants = true,
								BackgroundTransparency = 1
							}), {
								SetChildren(SetProps(MakeElement("Image", "https://www.roblox.com/headshot-thumbnail/image?userId=" .. id .. "&width=420&height=420&format=png"), {
									Size = UDim2.new(1, 0, 1, 0),
									BackgroundTransparency = 1
								}), {
									MakeElement("Corner", 0, 10)
								}),
								MakeElement("Corner", 1)
							})
						})
					end
				
					Relem(_tabName, Text, ParagraphFrame)
				
					function updtsz()
						if ParagraphFrame and ParagraphFrame.Parent then
							local titleY = ParagraphFrame.Title.TextBounds.Y
							local cntY = Content ~= nil and ParagraphFrame.Content.TextBounds.Y or -8
				
							if plrp then
								if isCenter then
									ParagraphFrame.Title.Size     = UDim2.new(1, -24, 0, titleY)
									ParagraphFrame.Title.Position = UDim2.new(0, 12, 0, 76)
									ParagraphFrame.Content.Size   = UDim2.new(1, -24, 0, cntY)
									ParagraphFrame.Content.Position = UDim2.new(0, 12, 0, 76 + titleY + 8)
									ParagraphFrame.Size = UDim2.new(1, 0, 0, math.max(90, 76 + titleY + 8 + cntY + 10))
								elseif isRight then
									ParagraphFrame.Title.Size     = UDim2.new(1, -72, 0, titleY)
									ParagraphFrame.Title.Position = UDim2.new(0, 12, 0, 10)
									ParagraphFrame.Content.Size   = UDim2.new(1, -72, 0, cntY)
									ParagraphFrame.Content.Position = UDim2.new(0, 12, 0, 10 + titleY + 8)
									local th = math.max(60, 10 + titleY + 8 + cntY + 10)
									ParagraphFrame.Size = UDim2.new(1, 0, 0, th)
									if OptBtn then
										OptBtn.Size     = UDim2.new(0, 60, 0, th)
										OptBtn.Position = UDim2.new(1, -60, 0, 0)
									end
								else
									ParagraphFrame.Title.Size     = UDim2.new(1, -72, 0, titleY)
									ParagraphFrame.Content.Size   = UDim2.new(1, -72, 0, cntY)
									ParagraphFrame.Content.Position = UDim2.new(0, 62, 0, 10 + titleY + 8)
									local th = math.max(60, 10 + titleY + 8 + cntY + 10)
									ParagraphFrame.Size = UDim2.new(1, 0, 0, th)
									if OptBtn then OptBtn.Size = UDim2.new(0, 60, 0, th) end
								end
							else
								ParagraphFrame.Title.Size     = UDim2.new(1, -12, 0, titleY)
								ParagraphFrame.Content.Size   = UDim2.new(1, -24, 0, cntY)
								ParagraphFrame.Content.Position = UDim2.new(0, 12, 0, 10 + titleY + 8)
								ParagraphFrame.Size = UDim2.new(1, 0, 0, 10 + titleY + 8 + cntY + 10)
							end
						end
					end
				
					AddConnection(ParagraphFrame.Content:GetPropertyChangedSignal("Text"), updtsz)
					AddConnection(ParagraphFrame.Content:GetPropertyChangedSignal("TextBounds"), updtsz)
					AddConnection(ParagraphFrame.Title:GetPropertyChangedSignal("TextBounds"), updtsz)
				
					local rsconn = AddConnection(MainWindow:GetPropertyChangedSignal("Size"), function()
						task.wait()
						updtsz()
					end)
				
					AddConnection(ParagraphFrame.Destroying, function()
						if rsconn and rsconn.Connected then
							rsconn:Disconnect()
						end
					end)
				
					ParagraphFrame.Content.Text = Content ~= nil and parsec(Content) or ""
					ParagraphFrame.Content.Visible = Content ~= nil
				
					local ParagraphFunction = {}
					function ParagraphFunction:Set(newtext, newcont, newalin)
						if newtext then ParagraphFrame.Title.Text = parsec(newtext) end
						if newcont ~= nil then 
							Content = newcont  
							ParagraphFrame.Content.Text = parsec(newcont)
							ParagraphFrame.Content.Visible = true
						end
						if newalin then
							Align    = newalin
							isCenter = newalin == "Center"
							isRight  = newalin == "Right"
							ParagraphFrame.Content.TextXAlignment = Enum.TextXAlignment[newalin]
							ParagraphFrame.Title.TextXAlignment   = Enum.TextXAlignment[newalin]
							if OptBtn then
								OptBtn.Position = isCenter and UDim2.new(0.5, -30, 0, 8) or isRight and UDim2.new(1, -60, 0, 0) or UDim2.new(0, 0, 0, 0)
							end
							updtsz()
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
					ccolor = ToggleConfig.Color,
					boxTween = nil,
					strokeTween = nil
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
					local ac = Toggle.uccolor and Toggle.ccolor or OrionLib.Themes[OrionLib.SelectedTheme].Accent
					local ti = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			
					Toggle.boxTween = vgs.TS:Create(ToggleBox, ti, {
						BackgroundColor3 = Toggle.Value and ac or OrionLib.Themes[OrionLib.SelectedTheme].Divider
					})
					Toggle.strokeTween = vgs.TS:Create(ToggleBox.Stroke, ti, {
						Color = Toggle.Value and ac or OrionLib.Themes[OrionLib.SelectedTheme].Stroke
					})
					Toggle.boxTween:Play()
					Toggle.strokeTween:Play()
			
					vgs.TS:Create(ToggleBox.Ico, ti, {
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
				DropdownConfig.tgl = DropdownConfig.tgl or false
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
						Position = UDim2.new(0, 8, 0, 70),
						Visible = false,
						Name = "SearchContainer"
					}), {AddThemeObject(MakeElement("Stroke"), "Stroke"), SrchBox}), "Main")
				end
			
				local headerHeight = 38
				local searchExtra = DropdownConfig.Searchable and 32 or 0
			
				local DdCont = AddThemeObject(SetProps(SetChildren(MakeElement("ScrollFrame", Color3.fromRGB(40, 40, 40), 4), {
					DdList
				}), {
					Parent = ItemParent,
					Position = UDim2.new(0, 0, 0, headerHeight + searchExtra),
					Size = UDim2.new(1, 0, 1, -(headerHeight + searchExtra)),
					ClipsDescendants = true,
					Visible = false,
					ScrollBarImageTransparency = 1
				}), "Divider")
			
				local Click = SetProps(MakeElement("Button"), {
					Size = UDim2.new(1, 0, 1, 0)
				})
			
				local ContentLabel = AddThemeObject(SetProps(MakeElement("Label", DropdownConfig.Name, 15), {
					Size = UDim2.new(0, 0, 1, 0),
					AutomaticSize = Enum.AutomaticSize.X,
					Position = UDim2.new(0, 12, 0, 0),
					Font = Enum.Font.GothamBold,
					Name = "Content"
				}), "Text")
			
				local SelectedLabel = AddThemeObject(SetProps(MakeElement("Label", "Select option", 13), {
					Position = UDim2.new(0, 12, 0, 0),
					Size = UDim2.new(1, -55, 1, 0),
					Font = Enum.Font.Gotham,
					Name = "Selected",
					TextXAlignment = Enum.TextXAlignment.Right,
					TextTruncate = Enum.TextTruncate.AtEnd
				}), "TextDark")
			
				local DdFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 38),
					Parent = ItemParent,
					ClipsDescendants = true
				}), {
					DropdownConfig.Searchable and SrchTgl or MakeElement("TFrame"),
					DropdownConfig.Searchable and SrchCont or MakeElement("TFrame"),
					DdCont,
					SetProps(SetChildren(MakeElement("TFrame"), {
						ContentLabel,
						AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072706796"), {
							Size = UDim2.new(0, 20, 0, 20),
							AnchorPoint = Vector2.new(0, 0.5),
							Position = UDim2.new(1, -30, 0.5, 0),
							ImageColor3 = Color3.fromRGB(240, 240, 240),
							Name = "Arrow"
						}), "TextDark"),
						SelectedLabel,
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
			
				function Dropdown:resname()
					local nameWidth = ContentLabel.TextBounds.X + 12 + 8
					local maxWidth = DdFrame.AbsoluteSize.X - 35
					local selWidth = math.max(0, maxWidth - nameWidth)
					SelectedLabel.Position = UDim2.new(0, nameWidth, 0, 0)
					SelectedLabel.Size = UDim2.new(0, selWidth, 1, 0)
				end
			
				AddConnection(ContentLabel:GetPropertyChangedSignal("TextBounds"), function()
					Dropdown:resname()
				end)
				AddConnection(DdFrame:GetPropertyChangedSignal("AbsoluteSize"), function()
					Dropdown:resname()
				end)
			
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
							}), 
							{
								SetChildren(SetProps(MakeElement("Image", "https://www.roblox.com/headshot-thumbnail/image?userId=" .. (vgs.ps:FindFirstChild(uname) and vgs.ps[uname].UserId or 1) .. "&width=420&height=420&format=png"), {
									Size = UDim2.new(1, 0, 1, 0),
									BackgroundTransparency = 1
								}), {
									MakeElement("Corner", 0, 10)
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
						pcall(function() SaveCfg(game.GameId) end)
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
						for _, btn in pairs(Dropdown.Buttons) do btn.Visible = true end
						for _, group in pairs(Dropdown.Groups) do group.Visible = true end
						return
					end
			
					local srchLow = string.lower(Dropdown.srchTxt)
					for value, btn in pairs(Dropdown.Buttons) do
						local srchTxt = ""
						if Dropdown.isPDrop then
							if btn:FindFirstChild("DisplayName") then srchTxt = srchTxt .. string.lower(btn.DisplayName.Text) .. " " end
							if btn:FindFirstChild("Username") then srchTxt = srchTxt .. string.lower(btn.Username.Text) end
						else
							if btn:FindFirstChild("Title") then srchTxt = string.lower(btn.Title.Text) end
						end
						btn.Visible = string.find(srchTxt, srchLow) ~= nil
					end
			
					for _, group in pairs(Dropdown.Groups) do
						local hasVis = false
						for _, child in pairs(group:GetChildren()) do
							if child:IsA("TextButton") and child.Visible then hasVis = true break end
						end
						group.Visible = hasVis
					end
				end
			
				local function StaggerAnim()
					local visibleBtns = {}
					for _, btn in pairs(Dropdown.Buttons) do
						if btn.Visible then table.insert(visibleBtns, btn) end
					end
					for i, btn in ipairs(visibleBtns) do
						spawn(function()
							wait((i - 1) * 0.02)
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
			
					if DdFrame:FindFirstChild("Header") then
						DdFrame.Header.Selected.Text = selTxt
						Dropdown:resname()
					end
			
					for value, btn in pairs(self.Buttons) do
						local sel = self.Multi and table.find(self.Value, value) or (self.Value == value)
						local twInf = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			
						vgs.TS:Create(btn, twInf, {BackgroundTransparency = sel and 0.2 or 1}):Play()
			
						if self.isPDrop then
							if btn:FindFirstChild("DisplayName") then vgs.TS:Create(btn.DisplayName, twInf, {TextTransparency = sel and 0 or 0.4}):Play() end
							if btn:FindFirstChild("Username") then vgs.TS:Create(btn.Username, twInf, {TextTransparency = sel and 0 or 0.4}):Play() end
						else
							if btn:FindFirstChild("Title") then vgs.TS:Create(btn.Title, twInf, {TextTransparency = sel and 0 or 0.4}):Play() end
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
						pcall(function() DropdownConfig.Callback(self.Value) end)
					end
				end
			
				function Dropdown:UpdVis()
					local srchTglH = DropdownConfig.Searchable and self.Toggled and 32 or 0
					local srchBoxH = DropdownConfig.Searchable and self.srchMode and 34 or 0
					local totSrchH = srchTglH + srchBoxH
			
					DdCont.Visible = self.Toggled
					if DdFrame:FindFirstChild("Header") then
						DdFrame.Header.Line.Visible = self.Toggled
					end
			
					if DropdownConfig.Searchable and SrchTgl then SrchTgl.Visible = self.Toggled end
					if DropdownConfig.Searchable and SrchCont then SrchCont.Visible = self.srchMode end
			
					if not self.Toggled or not self.srchMode then relfcs() end
			
					local newPos = UDim2.new(0, 0, 0, headerHeight + totSrchH)
					local newSz = UDim2.new(1, 0, 1, -(headerHeight + totSrchH))
			
					vgs.TS:Create(DdCont, TweenInfo.new(0.15), {Position = newPos, Size = newSz}):Play()
			
					if DdFrame:FindFirstChild("Header") then
						vgs.TS:Create(DdFrame.Header.Arrow, TweenInfo.new(0.15), {Rotation = self.Toggled and 0 or 180}):Play()
					end
			
					local cntH = 0
					if self.Toggled then
						local totBtns = 0
						for _, btn in pairs(self.Buttons) do
							if btn.Visible then totBtns = totBtns + 1 end
						end
						local btnH = self.isPDrop and 60 or 28
						cntH = math.min(totBtns, MaxElems) * btnH + totSrchH
					end
			
					local totH = self.Toggled and (headerHeight + cntH) or headerHeight
					vgs.TS:Create(DdFrame, TweenInfo.new(0.15), {Size = UDim2.new(1, 0, 0, totH)}):Play()
			
					if self.Toggled then
						for _, btn in pairs(self.Buttons) do
							if btn.Visible then btn.Position = UDim2.new(0, -10, 0, 0) end
						end
						task.wait(0.05)
						StaggerAnim()
					end
			
					if DropdownConfig.Searchable and SrchBox then
						if self.Toggled and self.srchMode then
							spawn(function() wait(0.1) SrchBox:CaptureFocus() end)
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
								if table.find(self.Options, v) then table.insert(validValues, v) end
							end
							if #validValues ~= #self.Value then
								changed = true
							else
								for _, v in pairs(validValues) do
									if not table.find(self.Value, v) then changed = true break end
								end
							end
							self.Value = validValues
						end
			
						if changed then
							self:UpdSel(1)
							if DropdownConfig.Call then
								pcall(function() DropdownConfig.Callback(self.Value) end)
							end
						end
					else
						if not table.find(self.Options, Value) then
							self.Value = "..."
							if DdFrame:FindFirstChild("Header") then
								DdFrame.Header.Selected.Text = self.Value
								Dropdown:resname()
							end
							for _, v in pairs(self.Buttons) do
								vgs.TS:Create(v, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
								if self.isPDrop then
									if v:FindFirstChild("DisplayName") then vgs.TS:Create(v.DisplayName, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0.4}):Play() end
									if v:FindFirstChild("Username") then vgs.TS:Create(v.Username, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0.4}):Play() end
								else
									if v:FindFirstChild("Title") then vgs.TS:Create(v.Title, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0.4}):Play() end
								end
							end
							return
						end
			
						self.Value = Value
						DdFrame.Header.Selected.Text = self.Value
						Dropdown:resname()
			
						for _, v in pairs(self.Buttons) do
							vgs.TS:Create(v, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
							if self.isPDrop then
								if v:FindFirstChild("DisplayName") then vgs.TS:Create(v.DisplayName, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0.4}):Play() end
								if v:FindFirstChild("Username") then vgs.TS:Create(v.Username, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0.4}):Play() end
							else
								if v:FindFirstChild("Title") then vgs.TS:Create(v.Title, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0.4}):Play() end
							end
						end
			
						if self.Buttons[Value] then
							vgs.TS:Create(self.Buttons[Value], TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.2}):Play()
							if self.isPDrop then
								if self.Buttons[Value]:FindFirstChild("DisplayName") then vgs.TS:Create(self.Buttons[Value].DisplayName, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play() end
								if self.Buttons[Value]:FindFirstChild("Username") then vgs.TS:Create(self.Buttons[Value].Username, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play() end
							else
								if self.Buttons[Value]:FindFirstChild("Title") then vgs.TS:Create(self.Buttons[Value].Title, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play() end
							end
						end
			
						pcall(function() DropdownConfig.Callback(self.Value) end)
					end
				end
			
				function Dropdown:Refresh(Options, Delete)
					if Delete then
						for _, v in pairs(self.Buttons) do v:Destroy() end
						for _, v in pairs(self.Groups) do v:Destroy() end
						table.clear(self.Options)
						table.clear(self.Buttons)
						table.clear(self.Groups)
					end
					self.Options = Options
					DropdownConfig.Options = Options
					self.isPDrop = DtctPDrop()
			
					if DropdownConfig.Grouped then
						for gName, grpOpts in pairs(Options) do CrtGrp(gName, grpOpts) end
					else
						for _, option in pairs(Options) do CrtOpt(option) end
					end
			
					if self.isPDrop then
						local preload = {}
						for _, option in pairs(Options) do
							local optTxt = type(option) == "table" and (option.text or option.name) or tostring(option)
							local uname = optTxt:match("^(.-) %(") or optTxt
							if vgs and vgs.ps and vgs.ps:FindFirstChild(uname) then
								table.insert(preload, "https://www.roblox.com/headshot-thumbnail/image?userId=" .. vgs.ps[uname].UserId .. "&width=420&height=420&format=png")
							end
						end
						if #preload > 0 then
							task.spawn(function() game:GetService("ContentProvider"):PreloadAsync(preload) end)
						end
					end
			
					if DropdownConfig.Searchable and self.srchTxt ~= "" then FiltrOpts() end
					if self.Toggled then self:UpdVis() end
					self:UpdSel()
				end
			
				AddConnection(Click.MouseButton1Click, function()
					Dropdown.Toggled = not Dropdown.Toggled
					if not Dropdown.Toggled then Dropdown.srchMode = false end
					Dropdown:UpdVis()
				end)
			
				if DropdownConfig.Searchable and SrchTgl then
					AddConnection(SrchTgl.MouseButton1Click, function()
						Dropdown.srchMode = not Dropdown.srchMode
						vgs.TS:Create(SrchTgl.SearchArrow, TweenInfo.new(0.15), {Rotation = Dropdown.srchMode and 0 or 180}):Play()
						Dropdown:UpdVis()
					end)
					AddConnection(SrchTgl.MouseEnter, function()
						vgs.TS:Create(SrchTgl.SearchArrow, TweenInfo.new(0.15), {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
					end)
					AddConnection(SrchTgl.MouseLeave, function()
						vgs.TS:Create(SrchTgl.SearchArrow, TweenInfo.new(0.15), {ImageColor3 = Color3.fromRGB(160, 160, 160)}):Play()
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
						if SrchBox.Text == "" then SrchBox.TextXAlignment = Enum.TextXAlignment.Left end
					end)
				end
			
				AddConnection(vgs.UIS.InputBegan, function(input, gameProcessed)
					if gameProcessed or not Dropdown.Toggled then return end
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
			
				if DropdownConfig.Flag then OrionLib.Flags[DropdownConfig.Flag] = Dropdown end
			
				table.insert(OrionLib.Dropdowns, Dropdown)
			
				if vgs and vgs.ps then
					AddConnection(vgs.ps.PlayerAdded, function(plr)
						Dropdown.isPDrop = DtctPDrop()
						if DropdownConfig.Searchable and Dropdown.srchTxt ~= "" then FiltrOpts() end
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
								if name == pName then table.remove(Dropdown.Value, i) end
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
						if DropdownConfig.Searchable and Dropdown.srchTxt ~= "" then FiltrOpts() end
						if Dropdown.Toggled then Dropdown:UpdVis() end
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
							if BindConfig.Default ~= Enum.KeyCode.Unknown then
								BindConfig.Callback(Holding)
							end
						else
							if BindConfig.Default ~= Enum.KeyCode.Unknown then
								BindConfig.Callback(Input)
							end
						end
					elseif Bind.Binding then
						local Key
						pcall(function()
							if Input.KeyCode == Enum.KeyCode.Backspace or Input.KeyCode == Enum.KeyCode.Return then
								Key = Enum.KeyCode.Unknown
							else
								if not CheckKey(BlacklistedKeys, Input.KeyCode) then
									Key = Input.KeyCode
								end
							end
						end)
						pcall(function()
							if Input.KeyCode == Enum.KeyCode.Backspace or Input.KeyCode == Enum.KeyCode.Return then
								Key = Enum.KeyCode.Unknown
							else
								if CheckKey(WhitelistedMouse, Input.UserInputType) and not Key then
									Key = Input.UserInputType
								end
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
							if BindConfig.Default ~= Enum.KeyCode.Unknown then
								BindConfig.Callback(Holding)
							end
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
					if Bind.Value == "Unknown" then
						BindBox.Value.Text = "None"
					else
						BindBox.Value.Text = Bind.Value
					end
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
				TextboxConfig.BackGroundtext = TextboxConfig.BackGrountText or "Input"
				TextboxConfig.Callback = TextboxConfig.Callback or function() end
			
				local Click = SetProps(MakeElement("Button"), {
					Size = UDim2.new(1, 0, 1, 0)
				})
			
				local TextboxActual = AddThemeObject(Create("TextBox", {
					Size = UDim2.new(1, -8, 1, 0),
					Position = UDim2.new(0, 4, 0, 0),
					BackgroundTransparency = 1,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					PlaceholderColor3 = Color3.fromRGB(210, 210, 210),
					PlaceholderText = TextboxConfig.BackGrountText,
					Font = Enum.Font.GothamSemibold,
					TextXAlignment = Enum.TextXAlignment.Center,
					TextSize = 14,
					ClearTextOnFocus = false,
				}), "Text")
			
				local TextContainer = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
					Size = UDim2.new(0, 24, 0, 24),
					Position = UDim2.new(1, -12, 0.5, 0),
					AnchorPoint = Vector2.new(1, 0.5),
					ClipsDescendants = true
				}), {
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					TextboxActual
				}), "Main")
			
				local ContentLabel = AddThemeObject(SetProps(MakeElement("Label", TextboxConfig.Name, 15), {
					Size = UDim2.new(1, -50, 1, 0),
					Position = UDim2.new(0, 12, 0, 0),
					Font = Enum.Font.GothamBold,
					Name = "Content",
					TextTruncate = Enum.TextTruncate.AtEnd
				}), "Text")
			
				local TextboxFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 38),
					Parent = ItemParent
				}), {
					ContentLabel,
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					TextContainer,
					Click
				}), "Second")
			
				Relem(_tabName, TextboxConfig.Name, TextboxFrame)
			
				function updW()
					local mw = math.max(24, TextboxFrame.AbsoluteSize.X - 12 - ContentLabel.TextBounds.X - 20)
					TextContainer.Size = UDim2.new(0, math.clamp(TextboxActual.TextBounds.X + 16, 24, mw), 0, 24)
				end
			
				AddConnection(TextboxActual:GetPropertyChangedSignal("Text"), updW)
				AddConnection(MainWindow:GetPropertyChangedSignal("Size"), updW)
			
				AddConnection(TextboxActual.FocusLost, function()
					TextboxConfig.Callback(TextboxActual.Text)
					if TextboxConfig.TextDisappear then
						TextboxActual.Text = ""
						TextContainer.Size = UDim2.new(0, 24, 0, 24)
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
					Color.BackgroundColor3 = Color3.fromHSV(ColorH, 1, 1)
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
			
				local saveToggle = gersec:AddToggle({
					Name     = "Save Theme & Name",
					Default  = false,
					Flag     = "SmartThemeSave",
					Save     = true,
					Callback = function(val) end
				})
			
				local tmcp = gersec:AddColorpicker({
					Name     = "Base Color",
					Default  = OrionLib.Themes[OrionLib.SelectedTheme].Main,
					Flag     = "SmartThemeColor",
					Save     = true,
					Mode     = 2,
					Callback = function(Value)
						local newTheme = OrionLib:GenTheme(Value)
						OrionLib.Themes.Custom = newTheme
						OrionLib.SelectedTheme = "Custom"
						OrionLib:SetTheme()
						if saveToggle.Value then
							SaveCfg(game.GameId)
						end
					end
				})
			
				gersec:AddButton({
					Name     = "Reset Theme",
					Callback = function()
						tmcp:Set(OrionLib.Themes.Default.Main)
						if saveToggle.Value then
							SaveCfg(game.GameId)
						end
					end
				})
			
				if OrionLib.Flags["SmartThemeColor"] then
					local c = OrionLib.Flags["SmartThemeColor"].Value
					OrionLib.Themes.Custom = OrionLib:GenTheme(c)
					OrionLib.SelectedTheme = "Custom"
					OrionLib:SetTheme()
				else
					OrionLib.SelectedTheme = "Default"
					OrionLib:SetTheme()
				end
			end

			for k, fn in pairs(ElementFunction) do
				if type(fn) == "function" then
					ElementFunction[k] = function(self, ...)
						lreg = nil
						local res = fn(self, ...)
						if type(res) == "table" and lreg then
							local reg = lreg
							function res:toggle()
								if reg.frame and reg.frame.Parent then
									reg.frame.Visible = not reg.frame.Visible
									if SearchSystem.elmnts[reg.tabName] and SearchSystem.elmnts[reg.tabName][reg.name] then
										SearchSystem.elmnts[reg.tabName][reg.name].visible = reg.frame.Visible
									end
								end
							end
							function res:remove()
								if SearchSystem.elmnts[reg.tabName] then
									SearchSystem.elmnts[reg.tabName][reg.name] = nil
								end
								if reg.frame and reg.frame.Parent then
									reg.frame:Destroy()
								end
							end
						end
						return res
					end
				end
			end
			
			return ElementFunction   
		end	

		local ElementFunction = {}
		
		function ElementFunction:AddSection(name, align, height)
			name = name or ""
			align = align or "Left"
		
			local hn = name ~= ""
			local lh = hn and 23 or 0
			height = height or 26
		
			local children = {
				SetChildren(SetProps(MakeElement("TFrame"), {
					AnchorPoint = Vector2.new(0, 0),
					Size = UDim2.new(1, 0, 0, 0),
					Position = UDim2.new(0, 0, 0, lh),
					Name = "Holder"
				}), {
					MakeElement("List", 0, 6)
				}),
			}
		
			if hn then
				table.insert(children, 1, AddThemeObject(SetProps(MakeElement("Label", name, 14), {
					Size = UDim2.new(1, 0, 0, 16),
					Position = UDim2.new(0, 0, 0, 3),
					Font = Enum.Font.GothamSemibold,
					TextXAlignment = Enum.TextXAlignment[align]
				}), "TextDark"))
			end
		
			local SectionFrame = SetChildren(SetProps(MakeElement("TFrame"), {
				Size = UDim2.new(1, 0, 0, height),
				Parent = Container
			}), children)
		
			local rkey = hn and name or ("section_" .. tostring(SectionFrame))
			Relem(TabConfig.Name, rkey, SectionFrame)
		
			AddConnection(SectionFrame.Holder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
				local contentY = SectionFrame.Holder.UIListLayout.AbsoluteContentSize.Y
				SectionFrame.Size = UDim2.new(1, 0, 0, contentY + lh + (hn and 8 or 0))
				SectionFrame.Holder.Size = UDim2.new(1, 0, 0, contentY)
			end)
		
			local SectionFunction = {}
		
			for i, v in next, Getelmnts(SectionFrame.Holder, TabConfig.Name) do
				SectionFunction[i] = v
			end
		
			function SectionFunction:toggle()
				SectionFrame.Visible = not SectionFrame.Visible
				if SearchSystem.elmnts[TabConfig.Name] and SearchSystem.elmnts[TabConfig.Name][rkey] then
					SearchSystem.elmnts[TabConfig.Name][rkey].visible = SectionFrame.Visible
				end
			end
		
			function SectionFunction:remove()
				if SearchSystem.elmnts[TabConfig.Name] then
					SearchSystem.elmnts[TabConfig.Name][rkey] = nil
				end
				if SectionFrame and SectionFrame.Parent then
					SectionFrame:Destroy()
				end
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