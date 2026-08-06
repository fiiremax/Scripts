--!optimize 2
--# Author: firemax(lxz_firemax)
--# Based on Orion Library
--[[
--! IK IK, this Orion has ALOT of "local function", but thats "the correct way". PS: MY VS CODE TURNS YELLOW WHEN I DONT PUT LOCAL SO YYA
ah and prob ur asking abt the comments (#, ! or sep), im using the Better Comments extention, custom colors so u can imagine it alr?

--sep = white comment with a line
--// = grey comment with a line
--# = yellow comment
--! = red comment

prob this is the style ill use for this Orion. PS: spaces before comment lines = LONG separators

ps: ignore shakira in line 2005
]]--
--sep                                                                  
--# Variables

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
	OrionColor    = Color3.fromRGB(47, 30, 64),
	SelectedTheme = "Default",
	UMouseMode    = "FreeMouse",
	ThemeObjects  = { Global = {}, Tabs = {} },
	ActiveTab     = nil,
	DirtyTabs     = {},
	Minimized     = false,
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

--sep                                                                  
--# Icons // Made by random github user(i forgot the name)

local links = {
	["Lucide"] = {
		"https://raw.githubusercontent.com/dawid-scripts/Fluent/master/src/Icons.lua"
	},
	["Gravity"] = {
		"https://cdn.jsdelivr.net/gh/Orvez83/IconFinder@main/Icons/Gravity.lua",
		"https://raw.githubusercontent.com/Orvez83/IconFinder/refs/heads/main/Icons/Gravity.lua"
	}
}

local datacache = {} 
local namecache = {}

function ReqIcon(urls: table)
    local error = nil

    for _, url in ipairs(urls) do
        for i = 1, 3 do
            local s, r = pcall(function() return game:HttpGet(url) end)
            if s then return true, r end

            error = tostring(r)
            if error:find("429") then break end
        end
    end
    return false, error
end

local function NormalizeIcon(raw)
	if type(raw) ~= "table" then return nil end
	local flat = raw.assets or raw

	local out = {}
	for name, id in pairs(flat) do
		out[name:gsub("^lucide%-", "")] = id
	end
	return out
end

local function LoadIcon(platform)
	if datacache[platform] then return datacache[platform] end

	local ok, raw = ReqIcon(links[platform])
	if not ok then return end

	ok, raw = pcall(function()
		return NormalizeIcon(assert(loadstring(raw))())
	end)
	if not ok or not raw then return end

	datacache[platform], namecache[platform] = raw, {}

	for name, id in pairs(raw) do
		namecache[platform][name:lower()] = "rbxassetid://" .. tostring(id):gsub("^rbxassetid://", "")
	end

	return raw
end

function OrionLib:ResolveIcon(icon)
	if type(icon) ~= "string" or icon == "" then return "" end
	if icon:match("^rbxassetid://") then return icon end
	if icon:match("^%d+$") then return "rbxassetid://" .. icon end

	local platform, name = icon:match("^(%a+):(.+)$")
	if platform then
		LoadIcon(platform)
		return namecache[platform] and namecache[platform][name:lower()] or ""
	end

	icon = icon:lower()
	for _, platform in ipairs({"Gravity","Lucide"}) do
		LoadIcon(platform)
		local id = namecache[platform] and namecache[platform][icon]
		if id then return id end
	end

	return ""
end
--sep                                                                  
--# Misc

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

local PTCache = {}

function ChangeBucket(objects, tname, thm)
	local color = thm[tname] or (tname == "Accent2" and thm.Accent)
	if not color then return end

	for _, obj in ipairs(objects) do
		if obj and obj.Parent then
			local prop = PTCache[obj]
			if not prop then
				prop = tname == "Accent2"
					and (obj:IsA("UIStroke") and "Color" or "BackgroundColor3")
					or ReturnProperty(obj)
				if prop then PTCache[obj] = prop end
			end
			if prop then obj[prop] = color end
		end
	end
end

function OrionLib:SetOTheme()
	local thm = self.Themes[self.SelectedTheme]
	if not thm then return end

	for tname, objects in next, self.ThemeObjects.Global do
		ChangeBucket(objects, tname, thm)
	end

	local liveTab = (not self.Minimized) and self.ActiveTab or nil

	for tabName, byType in pairs(self.ThemeObjects.Tabs) do
		if tabName == liveTab then
			for typeName, objects in pairs(byType) do
				ChangeBucket(objects, typeName, thm)
			end
			self.DirtyTabs[tabName] = nil
		else
			self.DirtyTabs[tabName] = true
		end
	end

	local function putaccent(box, on, ccolor)
		box.BackgroundColor3 = on and (ccolor or thm.Accent) or thm.Divider
		local s = box:FindFirstChild("Stroke")
		if s then s.Color = on and (ccolor or thm.Accent) or thm.Stroke end
	end

	for _, t in ipairs(self.Toggles or {}) do
		if t and t.Box and t.Box.Parent then
			if t.boxTween then t.boxTween:Cancel() end
			if t.strokeTween then t.strokeTween:Cancel() end
			putaccent(t.Box, t.Value, t.uccolor and t.ccolor)
			local ico = t.Box:FindFirstChild("Ico")
			if ico then ico.ImageTransparency = t.Value and 0 or 1 end
		end
	end

	for _, d in ipairs(self.Dropdowns or {}) do
		if d and d.Buttons then d:UpdSel(1) end
	end

	if resizebtt then resizebtt.BackgroundColor3 = thm.Main end
	for _, el in ipairs({namepbar, line}) do
		if el and el.Parent then el.BackgroundColor3 = thm.Accent end
	end
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
--sep                                                                  
--# Functions

function OrionLib:IsRunning()
	if gethui then
		return Orion.Parent == gethui()
	else
		return Orion.Parent == game:GetService("CoreGui")
	end
end
local connSet = {}

function OrionLib:DestroyLib()
    for conn in pairs(connSet) do
        if conn.Connected then
            conn:Disconnect()
        end
    end
    table.clear(connSet)
    table.clear(OrionLib.Connections)  
    Orion:Destroy()
end

function AddConnection(Signal, Function)
    if not OrionLib:IsRunning() then return end

    local SignalConnect = Signal:Connect(Function)
    connSet[SignalConnect] = true

    local function disconnect()
        if connSet[SignalConnect] then
            connSet[SignalConnect] = nil
        end
        if SignalConnect.Connected then
            SignalConnect:Disconnect()
        end
    end

    return SignalConnect, disconnect
end

local hb

hb = AddConnection(vgs.RS.Heartbeat, function()
    if not OrionLib:IsRunning() then
        if hb and hb.Connected then hb:Disconnect() end
        connSet[hb] = nil
        OrionLib:DestroyLib()
    end
end)

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

function AddThemeObject(Object, Type, TabOwner)
	local bucket

	if TabOwner then
		OrionLib.ThemeObjects.Tabs[TabOwner] = OrionLib.ThemeObjects.Tabs[TabOwner] or {}
		OrionLib.ThemeObjects.Tabs[TabOwner][Type] = OrionLib.ThemeObjects.Tabs[TabOwner][Type] or {}
		bucket = OrionLib.ThemeObjects.Tabs[TabOwner][Type]
	else
		OrionLib.ThemeObjects.Global[Type] = OrionLib.ThemeObjects.Global[Type] or {}
		bucket = OrionLib.ThemeObjects.Global[Type]
	end

	Total.AddThemeObject = Total.AddThemeObject + 1
	table.insert(bucket, Object)

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
--sep                                                                  
--# Save / Load Configuration

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
--sep                                                                  
--# UI Helpers

local WhitelistedMouse = {
	Enum.UserInputType.MouseButton3
}

local BlacklistedKeys = {
	Enum.UserInputType.MouseButton1,
	Enum.UserInputType.MouseButton2,
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
local conn = nil

function UnlockMouse(Value)

	if OrionLib.UMouseMode == "ThirdPerson" then
		if Value then
			vgs.p.CameraMode = Enum.CameraMode.LockFirstPerson
			task.wait()
			vgs.p.CameraMode = Enum.CameraMode.Classic
			vgs.UIS.MouseBehavior = Enum.MouseBehavior.Default

			if conn then
				conn:Disconnect()
				conn = nil
			end

			conn = AddConnection(vgs.RS.Heartbeat, function()
				if not vgs.UIS.MouseIconEnabled then
					vgs.UIS.MouseIconEnabled = true
				end
			end)

			vgs.UIS.MouseIconEnabled = true
			vgs.p.CameraMaxZoomDistance = OrionLib.maxds
			vgs.p.CameraMinZoomDistance = OrionLib.minds

		else
			if conn then
				conn:Disconnect()
				conn = nil
			end

			vgs.UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
			
			vgs.p.CameraMaxZoomDistance = nz
			vgs.p.CameraMinZoomDistance = nz
			vgs.p.CameraMode = Enum.CameraMode.LockFirstPerson
			FreeMouse.Modal = false
			vgs.UIS.MouseIconEnabled = false
		end

	elseif OrionLib.UMouseMode == "FreeMouse" then
		vgs.p.CameraMaxZoomDistance = nz
		vgs.p.CameraMinZoomDistance = nz
		vgs.p.CameraMode = Enum.CameraMode.LockFirstPerson
		FreeMouse.Modal = Value

		vgs.UIS.MouseBehavior = Value 
			and Enum.MouseBehavior.Default 
			or Enum.MouseBehavior.LockCenter

		if Value then
			if conn then
				conn:Disconnect()
				conn = nil
			end

			conn = AddConnection(vgs.RS.Heartbeat, function()
				if not vgs.UIS.MouseIconEnabled then
					vgs.UIS.MouseIconEnabled = true
				end
			end)

			vgs.UIS.MouseIconEnabled = true
		else
			if conn then
				conn:Disconnect()
				conn = nil
			end

			vgs.UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
			vgs.UIS.MouseIconEnabled = false
		end
	end
end

function CheckKey(Table, Key)
    return table.find(Table, Key) ~= nil
end

CreateElement("Corner", function(Scale, Offset)
	local Corner = Create("UICorner", {
		CornerRadius = UDim.new(Scale or 0, Offset or 10)
	})
	return Corner
end)

CreateElement("Stroke", function(Color, Thickness)
	local Stroke = Create("UIStroke", {
		Color        = Color or Color3.fromRGB(255, 255, 255),
		Thickness    = Thickness or 1,
		Transparency = 0.6
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
		NotificationConfig.Name     = NotificationConfig.Name     or "Notification"
		NotificationConfig.Content  = NotificationConfig.Content  or "Content"
		NotificationConfig.Image    = NotificationConfig.Image    or "rbxassetid://4384403532"
		NotificationConfig.Time     = NotificationConfig.Time     or 15
		NotificationConfig.Ask      = NotificationConfig.Ask      or false
		NotificationConfig.Callback = NotificationConfig.Callback or function() end

		game:GetService("ContentProvider"):PreloadAsync({NotificationConfig.Image})

		local key = NotificationConfig.Name .. NotificationConfig.Content
		if OrionLib.Notifys[key] then return end
		OrionLib.Notifys[key] = true

		local answered = false
		local NotificationFrame

		local NotificationParent = SetProps(MakeElement("TFrame"), {
			Size          = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent        = NotificationHolder
		})

		local ContentRow = SetProps(MakeElement("TFrame"), {
			Size          = UDim2.new(1, 0, 0, 0),
			Position      = UDim2.new(0, 0, 0, 25),
			AutomaticSize = Enum.AutomaticSize.Y
		})

		local ContentLabel = AddThemeObject(SetProps(MakeElement("Label", NotificationConfig.Content, 14), {
			Size          = NotificationConfig.Ask and UDim2.new(1, -70, 0, 0) or UDim2.new(1, 0, 0, 0),
			Font          = Enum.Font.GothamSemibold,
			Name          = "Content",
			AutomaticSize = Enum.AutomaticSize.Y,
			TextWrapped   = true,
			Parent        = ContentRow
		}), "TextDark")

		if NotificationConfig.Ask then
			local ButtonHolder = SetProps(MakeElement("TFrame"), {
				Size     = UDim2.new(0, 60, 1, 4),
				Position = UDim2.new(1, -60, 0, 4),
				Name     = "ButtonHolder",
				Parent   = ContentRow
			})

			local ButtonLayout = Instance.new("UIListLayout")
			ButtonLayout.FillDirection       = Enum.FillDirection.Horizontal
			ButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
			ButtonLayout.VerticalAlignment   = Enum.VerticalAlignment.Center
			ButtonLayout.SortOrder           = Enum.SortOrder.LayoutOrder
			ButtonLayout.Padding             = UDim.new(0, 4)
			ButtonLayout.Parent              = ButtonHolder

			local function MakeButton(label, result)
				local Btn = Instance.new("TextButton")
				Btn.AutomaticSize          = Enum.AutomaticSize.X
				Btn.Size                   = UDim2.new(0, 0, 0, 18)
				Btn.BorderSizePixel        = 0
				Btn.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
				Btn.BackgroundTransparency = 0.93
				Btn.Text                   = ""
				Btn.Parent                 = ButtonHolder

				local Corner = Instance.new("UICorner")
				Corner.CornerRadius = UDim.new(0, 4)
				Corner.Parent       = Btn

				local Padding = Instance.new("UIPadding")
				Padding.PaddingLeft  = UDim.new(0, 7)
				Padding.PaddingRight = UDim.new(0, 7)
				Padding.Parent       = Btn

				AddThemeObject(SetProps(MakeElement("Label", label, 10), {
					Size           = UDim2.new(1, 0, 1, 0),
					Font           = Enum.Font.GothamBold,
					TextXAlignment = Enum.TextXAlignment.Center,
					Parent         = Btn
				}), "Text")

				Btn.MouseButton1Click:Connect(function()
					if answered then return end
					answered = true
					pcall(function() NotificationConfig.Callback(result) end)
					NotificationFrame:TweenPosition(UDim2.new(1, 40, 0, 0), "In", "Quint", 0.8, true)
					task.wait(1.35)
					NotificationFrame:Destroy()
					OrionLib.Notifys[key] = nil
				end)
			end

			MakeButton("Yes", true)
			MakeButton("No", false)
		end

		NotificationFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(25, 25, 25), 0, 10), {
			Parent                 = NotificationParent,
			Size                   = UDim2.new(1, 0, 0, 0),
			Position               = UDim2.new(1, -55, 0, 0),
			BackgroundTransparency = 0,
			AutomaticSize          = Enum.AutomaticSize.Y
		}), {
			MakeElement("Padding", 16, 12, 12, 12),
			AddThemeObject(SetProps(MakeElement("Image", NotificationConfig.Image), {
				Size        = UDim2.new(0, 20, 0, 20),
				ImageColor3 = Color3.fromRGB(240, 240, 240),
				Name        = "Icon"
			}), "Text"),
			AddThemeObject(SetProps(MakeElement("Label", NotificationConfig.Name, 15), {
				Size     = UDim2.new(1, -30, 0, 20),
				Position = UDim2.new(0, 30, 0, 0),
				Font     = Enum.Font.GothamBold,
				Name     = "Title"
			}), "Text"),
			ContentRow
		}), "Second")

		vgs.TS:Create(NotificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
			Position = UDim2.new(0, 0, 0, 0)
		}):Play()

		if NotificationConfig.Ask then
			local start = os.clock()
			
			while not answered and os.clock() - start < NotificationConfig.Time do
				task.wait()
			end
			
			if answered then return end
		else
			task.wait(NotificationConfig.Time - 0.88)
		end

		vgs.TS:Create(NotificationFrame:WaitForChild("Icon", 5), TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
			ImageTransparency = 1
		}):Play()
		vgs.TS:Create(NotificationFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {
			BackgroundTransparency = 0.6
		}):Play()
		task.wait(0.3)
		vgs.TS:Create(NotificationFrame.Title, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {
			TextTransparency = 0.4
		}):Play()
		vgs.TS:Create(ContentLabel, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {
			TextTransparency = 0.5
		}):Play()
		task.wait(0.05)

		NotificationFrame:TweenPosition(UDim2.new(1, 40, 0, 0), "In", "Quint", 0.8, true)
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
			end
		end)
		if OrionLib.Flags["SmartThemeColor"] and (OrionLib.Flags["SmartThemeSave"] and OrionLib.Flags["SmartThemeSave"].Value) then
			local c = OrionLib.Flags["SmartThemeColor"].Value
			OrionLib.Themes.Custom = OrionLib:GenTheme(c)
			OrionLib.SelectedTheme = "Custom"
			OrionLib:SetOTheme()
		else
			OrionLib.SelectedTheme = "Default"
			OrionLib:SetOTheme()
			if OrionLib.Flags["SmartThemeColor"] then
				OrionLib.Flags["SmartThemeColor"]:Set(OrionLib.Themes.Default.Main)
			end
		end
	end
end

task.spawn(function()
    while task.wait(30) do
        if not OrionLib:IsRunning() then break end
        for typeName, objects in pairs(OrionLib.ThemeObjects) do
            for i = #objects, 1, -1 do
                if not (objects[i] and objects[i].Parent) then
                    table.remove(objects, i)
                end
            end
        end
    end
end)
--sep                                                                  
--# Orion

function OrionLib:SetTheme(r, g, b)
	if OrionLib.DefaultColor and not r then
		OrionLib.Themes.Custom = OrionLib:GenTheme(Color3.fromRGB(
			OrionLib.DefaultColor.r,
			OrionLib.DefaultColor.g,
			OrionLib.DefaultColor.b
		))
		OrionLib.SelectedTheme = "Custom"
		OrionLib:SetOTheme()

	elseif r then
		OrionLib.Themes.Custom = OrionLib:GenTheme(Color3.fromRGB(r, g, b))
		OrionLib.SelectedTheme = "Custom"
		OrionLib:SetOTheme()
	end
end

function OrionLib:MakeWindow(WindowConfig)
	local FirstTab = true 
	local minimized = false
	local UIHidden  = false
	local TabOrderCounter = 0

	WindowConfig = WindowConfig or {}
	WindowConfig.Name            = WindowConfig.Name
	WindowConfig.ConfigFolder    = WindowConfig.ConfigFolder  or WindowConfig.Name
	WindowConfig.SaveConfig      = WindowConfig.SaveConfig    or false
	WindowConfig.TagText         = WindowConfig.TagText       or ""
	WindowConfig.CustomName      = WindowConfig.CustomName    or false
	WindowConfig.HidePremium     = WindowConfig.HidePremium   or false
	WindowConfig.IntroEnabled    = WindowConfig.IntroEnabled  or false
	WindowConfig.FreeMouse       = WindowConfig.FreeMouse     or true
	WindowConfig.Openkey         = WindowConfig.Openkey       or "M"
	WindowConfig.IntroText       = WindowConfig.IntroText     or "Orion Library"
	WindowConfig.CloseCallback   = WindowConfig.CloseCallback or function() end
	WindowConfig.ShowIcon        = WindowConfig.ShowIcon      or false
	WindowConfig.Icon            = WindowConfig.Icon          or "rbxassetid://8834748103"
	WindowConfig.IconSize        = WindowConfig.IconSize      or UDim2.new(0,50,0,50)
	WindowConfig.IconPos         = WindowConfig.IconPos       or UDim2.new(0,2,0.5,0)
	WindowConfig.IntroIcon       = WindowConfig.IntroIcon     or "rbxassetid://8834748103"
	WindowConfig.IconColorChange = WindowConfig.IconColorChange or false
	
	OrionLib.Folder  = WindowConfig.ConfigFolder
	OrionLib.SaveCfg = WindowConfig.SaveConfig

	if WindowConfig.FreeMouse then
		UnlockMouse(true)
	end

	if OrionLib.DefaultColor then
        OrionLib:SetTheme()
    end

	if WindowConfig.SaveConfig then
		if (isfolder and makefolder) and not isfolder(WindowConfig.ConfigFolder) then
			makefolder(WindowConfig.ConfigFolder)
		end
	end

	local namepbar = nil
	local line  = nil 

	local TabHolder = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255, 255, 255), 0), {
		Size     = UDim2.new(1, 0, 1, -58),
		Position = UDim2.new(0, 0, 0, 10),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(0, 0, 0, 0)
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

	--# Search System // 30 % pre done on github orion lib (ty mr ySixx)
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

		OrionLib.ActiveTab = tab
		if OrionLib.DirtyTabs[tab] then
			OrionLib:SetOTheme()
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
						local isSection = d.frame:FindFirstChild("Holder") ~= nil
						
						if isSection then
							d.frame.Visible = d.visible
						else
							d.frame.Visible = (tn == tab) and d.visible
						end
						
						Hlight(d.frame, false)
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
			    if not data.visible then continue end  
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
	
	if OrionLib.SaveCfg and isfile and readfile then
		pcall(function()
			local cfgFile = OrionLib.Folder .. "/" .. game.GameId .. ".txt"
			local ok, data = pcall(function() return vgs.HS:JSONDecode(readfile(cfgFile)) end)
			if not (ok and data and data["SmartThemeSave"] == true) then return end
			local f = OrionLib.Folder .. "/_windowname.txt"
			if not isfile(f) then return end
			local saved = readfile(f)
			if saved and saved ~= "" then
				WindowConfig.Name = saved
				WindowName.Text   = saved
			end
		end)
	end
	
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

	local UiScale = Instance.new("UIScale")
	UiScale.Scale = 1
	UiScale.Parent = MainWindow

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

	local srchdly       = nil
	local srchfcs       = nil
	local ha            = false
	local ht            = nil
	local nedit         = false
	local namehitbox    = nil
	local iconha        = false
	local iconht        = nil

	local function OpenSearch()
		if minimized then return end
		if srchdly then task.cancel(srchdly); srchdly = nil end
		ha = false
		if ht then task.cancel(ht); ht = nil end
		if namepbar then namepbar.Size = UDim2.new(0, 0, 0, 2) end
		WindowName.TextTransparency = 0
		if namehitbox then namehitbox.Visible = false end

		SearchOpen = true
		local titleX = WindowName.Position.X.Offset
		SearchInput.Position = UDim2.new(0, titleX, 0, 0)
		SearchInput.Size     = UDim2.new(1, -90, 1, 0)
		line.Position    = UDim2.new(0, titleX, 1, -1)
		line.ZIndex      = 3
		WindowName.Visible   = false
		SearchInput.Visible  = true

		vgs.TS:Create(line, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
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

	local function CloseSearch()
		if not SearchOpen then return end
		SearchOpen = false
		if srchfcs then task.cancel(srchfcs); srchfcs = nil end
		if SearchInput and SearchInput.Parent then
			SearchInput:ReleaseFocus()
		end

		line.Position    = UDim2.new(0, titleX, 1, -1)
		line.ZIndex      = 3

		vgs.TS:Create(line, TweenInfo.new(0.2), {
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
			if namehitbox and namehitbox.Parent and not minimized then
				namehitbox.Visible = true
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
		CloseSearch()
	end)

	AddConnection(vgs.UIS.InputBegan, function(input, gp)
		if gp then return end
		if input.KeyCode == Enum.KeyCode.Escape and SearchOpen then
			CloseSearch()
		end
	end)

	AddConnection(MainWindow:GetPropertyChangedSignal("Size"), function()
		if SearchOpen and MainWindow.Size.Y.Offset <= 36 then
			CloseSearch()
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
	resizebtt.Position         = UDim2.new(1, -18, 1, -18)
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
	ResizeIco.Image            = "rbxassetid://123109928624974"
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
		WindowName.Position = UDim2.new(0, 50, 0, 0)

		local iconOriginal   = OrionLib:ResolveIcon(WindowConfig.Icon)
		local searchImg      = "rbxassetid://118685771787843"
		local iconSearchOpen = false

		local WindowIcon
		if not WindowConfig.IconColorChange then
			WindowIcon = SetProps(MakeElement("Image", iconOriginal), {
				Size        = WindowConfig.IconSize,
				AnchorPoint = Vector2.new(0, 0.5),
				Position    = WindowConfig.IconPos,
				Name        = "WindowIcon"
			})
		else
			WindowIcon = AddThemeObject(SetProps(MakeElement("Image", iconOriginal), {
				Size        = WindowConfig.IconSize,
				AnchorPoint = Vector2.new(0, 0.5),
				Position    = WindowConfig.IconPos,
				Name        = "WindowIcon"
			}), "Accent")
		end
		WindowIcon.Parent = MainWindow.TopBar

		local bclse = CloseSearch
		CloseSearch = function()
			bclse()
			if not iconSearchOpen then return end
			iconSearchOpen = false
			WindowIcon.Rotation = 0
			task.delay(0.05, function()
				if WindowIcon and WindowIcon.Parent then
					WindowIcon.Image = iconOriginal
					WindowIcon.Size = WindowConfig.IconSize
					WindowIcon.Position = WindowConfig.IconPos
					WindowIcon.Image = iconOriginal
				end
			end)
		end

		AddConnection(WindowIcon.InputBegan, function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
			if minimized then return end

			if iconSearchOpen then
				CloseSearch()
				return
			end

			ha = false
			if ht then task.cancel(ht); ht = nil end
			if namepbar then namepbar.Size = UDim2.new(0, 0, 0, 2) end
			WindowName.TextTransparency = 0

			iconha = true
			iconht = task.spawn(function()
				local elapsed = 0
				local dur     = 2

				while iconha and elapsed < dur do
					elapsed = elapsed + task.wait(0.016)
				 	namepbar.Size = UDim2.new(math.clamp(elapsed / dur, 0, 1), 0, 0, 2)
					WindowIcon.Rotation = 360 * math.clamp(elapsed / dur, 0, 1)
				end

			 	namepbar.Size = UDim2.new(0, 0, 0, 2)

				if iconha then
					iconSearchOpen = true
					WindowIcon.Rotation = 0
					WindowIcon.Image    = searchImg
					WindowIcon.Size = UDim2.new(0, 35, 0, 35)
					WindowIcon.Position = UDim2.new(0, 3, 0.49, 0)
					WindowIcon.Image = searchImg
					OpenSearch()
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
		 	namepbar.Size = UDim2.new(0, 0, 0, 2)

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
	
 	namepbar = AddThemeObject(Create("Frame", {
		Size             = UDim2.new(0, 0, 0, 2),
		Position         = UDim2.new(0, 0, 1, -2),
		BorderSizePixel  = 0,
		ZIndex           = 6,
		Parent           = MainWindow.TopBar
	}), "Accent")
	
	line = AddThemeObject(Create("Frame", {
		Size             = UDim2.new(0, 0, 0, 1),
		Position         = UDim2.new(0, 0, 1, -1),
		BorderSizePixel  = 0,
		ZIndex           = 6,
		Parent           = MainWindow.TopBar
	}), "Accent")

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

	namehitbox = SetProps(MakeElement("Button"), {
		ZIndex = 3, Parent = MainWindow.TopBar
	})

	local function syncsyz()
		local pos  = WindowName.Position
		local textW = math.max(1, WindowName.TextBounds.X + 4)
		namehitbox.Position   = UDim2.new(0, 50, 0, 0)
		namehitbox.Size       = UDim2.new(0, textW, 1, 0)
		nmebox.Position = UDim2.new(0, 50, 0, 0)
		nmebox.Size     = WindowName.Size
		line.ZIndex = 6
		line.Position = UDim2.new(pos.X.Scale, pos.X.Offset, 1, -1)
	end

	syncsyz()

	AddConnection(WindowName:GetPropertyChangedSignal("TextBounds"), syncsyz)
	AddConnection(MainWindow:GetPropertyChangedSignal("Size"), syncsyz)

	local function OpenName()
		if nedit then return end
		nedit = true
		ha  = false
		syncsyz()
		nmebox.Text = WindowName.ContentText ~= "" and WindowName.ContentText or WindowName.Text
		WindowName.Visible  = false
		namehitbox.Visible   = false
		nmebox.Visible = true

		line.ZIndex = 6

		vgs.TS:Create(line, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{Size = UDim2.new(nmebox.Size.X.Scale, nmebox.Size.X.Offset, 0, 1)}):Play()
		task.delay(0.1, function() if nmebox and nmebox.Parent then nmebox:CaptureFocus() end end)
	end
	
	local function CloseName(confirm)
		if not nedit then return end
		nedit = false
		pcall(function() nmebox:ReleaseFocus() end)
		line.ZIndex = 6
		line.Position = UDim2.new(0, 0, 1, -1)
		vgs.TS:Create(line, TweenInfo.new(0.2), {Size = UDim2.new(0,0,0,1)}):Play()
		if confirm and nmebox.Text ~= "" then
			WindowName.RichText = false
			WindowName.Text = nmebox.Text
			WindowConfig.Name = nmebox.Text

			local svtg = OrionLib.Flags["SmartThemeSave"]
			if OrionLib.SaveCfg and writefile and svtg and svtg.Value then
				pcall(function()
					writefile(OrionLib.Folder .. "/_windowname.txt", nmebox.Text)
				end)
			end
		end
		nmebox.Visible = false
		namehitbox.Visible = true
		WindowName.Visible = true
	end
	
	local Hcpl = false

	AddConnection(namehitbox.InputBegan, function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		if not WindowConfig.CustomName then return end
		if minimized then return end
		if iconha then
			iconha = false
			if iconht then task.cancel(iconht); iconht = nil end
			if namepbar then namepbar.Size = UDim2.new(0,0,0,2) end
		end
		ha    = true
		Hcpl = false
		ht = task.spawn(function()
			local elapsed = 0
			local dur = 2
			while ha and elapsed < dur do
				elapsed = elapsed + task.wait(0.016)
			 namepbar.Size = UDim2.new(math.clamp(elapsed/dur,0,1), 0, 0, 2)
				WindowName.TextTransparency = 0.25 * math.abs(math.sin(elapsed * 5))
			end
		 	namepbar.Size = UDim2.new(0,0,0,2)
			WindowName.TextTransparency = 0
			if ha then
				Hcpl = true
				OpenName()
			end
		end)
	end)
	
	AddConnection(namehitbox.InputEnded, function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		if Hcpl then Hcpl = false; return end
		ha = false
	 	namepbar.Size = UDim2.new(0,0,0,2)
		WindowName.TextTransparency = 0
		if ht then task.cancel(ht) ht = nil end
		if not shakira then -- shaking .-. but more funny like shakkira shakira lorelorelore (sorry .,.)
			shakira = true
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
				task.wait(0.1)
				shakira = false
			end)
		end
	end)

	AddConnection(nmebox.FocusLost, function()
		CloseName(true)
	end)

	AddConnection(vgs.UIS.InputBegan, function(input, gp)
		if gp or not nedit then return end
		if input.KeyCode == Enum.KeyCode.Escape then CloseName(false)
		elseif input.KeyCode == Enum.KeyCode.Return then CloseName(true) end
	end)

	MakeDraggable(DragPoint, MainWindow)

	AddConnection(CloseBtn.MouseButton1Up, function()
		MainWindow.Visible = false; UIHidden = true
		if WindowConfig.FreeMouse then UnlockMouse(false) end
		WindowConfig.CloseCallback()
		OrionLib:MakeNotification({Name="Interface Hidden", Content="Tap "..WindowConfig.Openkey.." to reopen the interface", Time=3})
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
		OrionLib.Minimized = minimized
		if minimized then
			MainWindow.ClipsDescendants = true
			ContentPanel.Visible = false
			MainWindow.TabStrip.Visible = false
			MinimizeBtn.Ico.Image = "rbxassetid://7072720870"
			namehitbox.Visible = false
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
			namehitbox.Visible = true
			mintween = vgs.TS:Create(MainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, 615, 0, 344)
			})
			mintween:Play()
			task.spawn(function()
				task.wait(0.05)
				MainWindow.ClipsDescendants = false
				ContentPanel.Visible = true
				MainWindow.TabStrip.Visible = true
				if OrionLib.DirtyTabs[SearchSystem.actvtab] then
					OrionLib:SetOTheme()
				end
			end)
			mintween.Completed:Wait()
		end
	end)

	local function LoadSequence()
		MainWindow.Visible = false
		local screen = workspace.CurrentCamera.ViewportSize
		local iconS  = math.clamp(math.floor(math.min(screen.X, screen.Y) * 0.07), 36, 80)
		local LoadSequenceLogo = SetProps(MakeElement("Image", OrionLib:ResolveIcon(WindowConfig.IntroIcon)), {
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

	function Functions:SetUIScale(Percent)
		local scale = math.clamp(Percent, 50, 150) / 100
		vgs.TS:Create(UiScale, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Scale = scale
		}):Play()
	end

	function Functions:ChangeIcon(IconId)
		local ficon = OrionLib:ResolveIcon(IconId)
		local WindowIcon = MainWindow.TopBar:FindFirstChild("WindowIcon")
		if WindowIcon then WindowIcon.Image = ficon
		else
			WindowConfig.ShowIcon = true
			WindowName.Position = UDim2.new(0,50,0,0)
			if not WindowConfig.IconColorChange == true then
				WindowIcon = SetProps(MakeElement("Image", ficon), {
					Size = WindowConfig.IconSize, AnchorPoint = Vector2.new(0,0.5),
					Position = WindowConfig.IconPos, Name = "WindowIcon"
				})
			else
				WindowIcon = AddThemeObject(SetProps(MakeElement("Image", ficon), {
					Size = WindowConfig.IconSize, AnchorPoint = Vector2.new(0,0.5),
					Position = WindowConfig.IconPos, Name = "WindowIcon"
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

		TabOrderCounter = TabOrderCounter + 1

		local TabFrame = SetChildren(SetProps(MakeElement("Button"), {
			Size = UDim2.new(1,2,0,36),
			Parent = TabHolder,
			LayoutOrder = TabOrderCounter
		}), {
			AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 6), {
				Size = UDim2.new(1,0,1,0),
				BackgroundTransparency = 1,
				Name = "Highlight"
			}), {}), "Second"),
			ABar,
			AddThemeObject(SetProps(MakeElement("Image", OrionLib:ResolveIcon(TabConfig.Icon)), {
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
		
		local function ctdrag(wasclicking)
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
			elseif wasclicking then
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
			Active  = true 
		}), {
		MakeElement("List", 0, 6),
			MakeElement("Padding", 15, 10, 10, 15)
		}), "Main")

		Container.Name = TabConfig.Name
		Container.ScrollBarImageTransparency = 1
		Container.AutomaticCanvasSize = Enum.AutomaticSize.Y
		Container.CanvasSize = UDim2.new(0, 0, 0, 0)

		RTab(TabConfig.Name, Container)
		Rbutton(TabConfig.Name, TabFrame)
		OrionLib:SetOTheme()
		
		if FirstTab then
			FirstTab = false
			TabFrame.Ico.ImageTransparency = 0
			TabFrame.Highlight.BackgroundTransparency = 0.82
			vgs.TS:Create(TabFrame.ABar, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Position = UDim2.new(0,0,0.5,-9), BackgroundTransparency = 0
			}):Play()
			Container.Visible = true
			SearchSystem.actvtab = TabConfig.Name
			OrionLib.ActiveTab = TabConfig.Name
			if OrionLib.DirtyTabs[TabConfig.Name] then
				OrionLib:SetOTheme()
			end
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
					}), "Text", _tabName),
					AddThemeObject(MakeElement("Stroke"), "Stroke", _tabName)
				}), "Second", _tabName)

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
					}), "Text", _tabName),
					AddThemeObject(MakeElement("Stroke"), "Stroke", _tabName)
				}), "Second", _tabName)
			
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
			
				if not ToChangeColor then
					AddThemeObject(ContentLabel, "Text", _tabName)
				end
			
				local LabelFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 33),
					BackgroundTransparency = 0.7,
					Parent = ItemParent
				}), {
					ContentLabel,
					AddThemeObject(MakeElement("Stroke"), "Stroke", _tabName)
				}), "Second", _tabName)
			
				Relem(_tabName, Text, LabelFrame)
			
				local labelfunc = {}
			
				function labelfunc:Set(ToChange, ToChangeColor, Position)
					LabelFrame.Content.Text = ToChange
			
					if ToChangeColor then
						LabelFrame.Content.TextColor3 = ToChangeColor
					else
						AddThemeObject(LabelFrame.Content, "Text", _tabName)
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
			
					vgs.TS:Create(LabelFrame.Content, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Position = tposs
					}):Play()
				end
			
				labelfunc:Set(Text, ToChangeColor, Position)
				return labelfunc
			end
			
			local function parsec(text)
				local bsize = 13
				local bldsize = bsize + 1
				return (text:gsub('<#(%x+)"([^"]+)",%s*B>', '<font color="#%1" weight="Bold" size="' .. bldsize .. '">%2</font>'):gsub('<#(%x+)"([^"]+)">', '<font color="#%1">%2</font>'))
			end
			
			function ElementFunction:AddParagraph(id, Text, Content, Align, Size, ImgSize)
				local plrp = tonumber(id) ~= nil
				if not plrp then ImgSize = Size Size = Align Align = Content Content = Text Text = id id = "" end
				Align   = Align   or "Left"
				Size    = Size    or 60
				ImgSize = ImgSize or Size - 10
			
				local isCenter  = Align == "Center"
				local isRight   = Align == "Right"
				local gap       = 6
				local innerSize = Size - 10
			
				local initH
				if plrp then
					initH = isCenter and (Size + gap + 30) or math.max(Size, 60)
				else
					initH = 30
				end
			
				local ParagraphFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size                   = UDim2.new(1, 0, 0, initH),
					BackgroundTransparency = 0.7,
					Parent                 = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", parsec(Text or ""), 15), {
						Size           = UDim2.new(1, plrp and (isCenter and -24 or -(Size + gap + 12)) or -12, 0, 14),
						Position       = UDim2.new(0, plrp and (isCenter and 12 or (isRight and 12 or Size + gap)) or 12, 0, plrp and (isCenter and (Size + gap) or 10) or 10),
						Font           = Enum.Font.GothamBold,
						Name           = "Title",
						TextWrapped    = true,
						RichText       = true,
						TextXAlignment = Enum.TextXAlignment[Align]
					}), "Text", _tabName),
					AddThemeObject(SetProps(MakeElement("Label", "", 13), {
						Size           = UDim2.new(1, plrp and (isCenter and -24 or -(Size + gap + 24)) or -24, 0, 0),
						Position       = UDim2.new(0, plrp and (isCenter and 12 or (isRight and 12 or Size + gap)) or 12, 0, plrp and (isCenter and (Size + gap + 22) or 32) or 26),
						Font           = Enum.Font.GothamSemibold,
						Name           = "Content",
						TextWrapped    = true,
						RichText       = true,
						TextXAlignment = Enum.TextXAlignment[Align]
					}), "TextDark", _tabName),
					AddThemeObject(MakeElement("Stroke"), "Stroke", _tabName)
				}), "Second", _tabName)
			
				local OptBtn
				if plrp then
					local imgPos  = isCenter and UDim2.new(0.5, -math.floor(Size / 2), 0, 0)
								 or isRight  and UDim2.new(1, -Size, 0, 0)
								 or UDim2.new(0, 0, 0, 0)
					local optSize = isCenter and UDim2.new(0, Size, 0, Size) or UDim2.new(0, Size, 1, 0)
			
					OptBtn = SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(40, 40, 40)), {
						Parent                 = ParagraphFrame,
						Size                   = optSize,
						Position               = imgPos,
						BackgroundTransparency = 1,
						ClipsDescendants       = true,
					}), {
						MakeElement("Corner", 0, 6),
						AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 10), {
							Size             = UDim2.new(0, innerSize, 0, innerSize),
							Position         = UDim2.new(0.5, -math.floor(innerSize / 2), 0.5, -math.floor(innerSize / 2)),
							ClipsDescendants = true,
						}), {
							SetChildren(SetProps(MakeElement("Image", "https://www.roblox.com/headshot-thumbnail/image?userId=" .. id .. "&width=420&height=420&format=png"), {
								Size                   = UDim2.new(0, ImgSize, 0, ImgSize),
								AnchorPoint            = Vector2.new(0.5, 0.5),
								Position               = UDim2.new(0.5, 0, 0.5, 0),
								BackgroundTransparency = 1
							}), {
								MakeElement("Corner", 0, 10)
							}),
							MakeElement("Corner", 1)
						}), "Divider", _tabName)
					})
				end
			
				Relem(_tabName, Text, ParagraphFrame)
			
				local function updtsz()
					if ParagraphFrame and ParagraphFrame.Parent then
						local titleY = ParagraphFrame.Title.TextBounds.Y
						local cntY   = Content ~= nil and ParagraphFrame.Content.TextBounds.Y or -8
			
						if plrp then
							if isCenter then
								ParagraphFrame.Title.Size       = UDim2.new(1, -24, 0, titleY)
								ParagraphFrame.Title.Position   = UDim2.new(0, 12, 0, Size + gap)
								ParagraphFrame.Content.Size     = UDim2.new(1, -24, 0, cntY)
								ParagraphFrame.Content.Position = UDim2.new(0, 12, 0, Size + gap + titleY + 8)
								ParagraphFrame.Size             = UDim2.new(1, 0, 0, math.max(Size + gap + 14, Size + gap + titleY + 8 + cntY + 10))
							elseif isRight then
								ParagraphFrame.Title.Size       = UDim2.new(1, -(Size + gap + 12), 0, titleY)
								ParagraphFrame.Title.Position   = UDim2.new(0, 12, 0, 10)
								ParagraphFrame.Content.Size     = UDim2.new(1, -(Size + gap + 24), 0, cntY)
								ParagraphFrame.Content.Position = UDim2.new(0, 12, 0, 10 + titleY + 8)
								local th = math.max(Size, 10 + titleY + 8 + cntY + 10)
								ParagraphFrame.Size             = UDim2.new(1, 0, 0, th)
								if OptBtn then
									OptBtn.Size     = UDim2.new(0, Size, 1, 0)
									OptBtn.Position = UDim2.new(1, -Size, 0, 0)
								end
							else
								ParagraphFrame.Title.Size       = UDim2.new(1, -(Size + gap + 12), 0, titleY)
								ParagraphFrame.Title.Position   = UDim2.new(0, Size + gap, 0, 10)
								ParagraphFrame.Content.Size     = UDim2.new(1, -(Size + gap + 24), 0, cntY)
								ParagraphFrame.Content.Position = UDim2.new(0, Size + gap, 0, 10 + titleY + 8)
								local th = math.max(Size, 10 + titleY + 8 + cntY + 10)
								ParagraphFrame.Size             = UDim2.new(1, 0, 0, th)
								if OptBtn then OptBtn.Size = UDim2.new(0, Size, 1, 0) end
							end
						else
							ParagraphFrame.Title.Size       = UDim2.new(1, -12, 0, titleY)
							ParagraphFrame.Content.Size     = UDim2.new(1, -24, 0, cntY)
							ParagraphFrame.Content.Position = UDim2.new(0, 12, 0, 10 + titleY + 8)
							ParagraphFrame.Size             = UDim2.new(1, 0, 0, 10 + titleY + 8 + cntY + 10)
						end
					end
				end
			
				AddConnection(ParagraphFrame.Content:GetPropertyChangedSignal("Text"), updtsz)
				AddConnection(ParagraphFrame.Content:GetPropertyChangedSignal("TextBounds"), updtsz)
				AddConnection(ParagraphFrame.Title:GetPropertyChangedSignal("TextBounds"), updtsz)

				AddConnection(ItemParent:GetPropertyChangedSignal("Visible"), function()
					if ItemParent.Visible and ContentPanel.Visible then
						updtsz()
					end
				end)
			
				local rsconn = AddConnection(MainWindow:GetPropertyChangedSignal("Size"), function()
					if not (ItemParent.Visible and ContentPanel.Visible) then return end
					task.wait()
					updtsz()
				end)
			
				AddConnection(ParagraphFrame.Destroying, function()
					if rsconn and rsconn.Connected then
						rsconn:Disconnect()
					end
				end)
			
				ParagraphFrame.Content.Text    = Content ~= nil and parsec(Content) or ""
				ParagraphFrame.Content.Visible = Content ~= nil
			
				local ParagraphFunction = {}
			
				function ParagraphFunction:Set(newtext, newcont, newalin)
					if newtext ~= nil then ParagraphFrame.Title.Text = parsec(newtext or "") end
					if newcont ~= nil then
						Content = newcont
						ParagraphFrame.Content.Text    = parsec(newcont or "")
						ParagraphFrame.Content.Visible = true
					end
					if newalin then
						Align    = newalin
						isCenter = newalin == "Center"
						isRight  = newalin == "Right"
						ParagraphFrame.Content.TextXAlignment = Enum.TextXAlignment[newalin]
						ParagraphFrame.Title.TextXAlignment   = Enum.TextXAlignment[newalin]
						if OptBtn then
							OptBtn.Position = isCenter and UDim2.new(0.5, -math.floor(Size / 2), 0, 0) or isRight and UDim2.new(1, -Size, 0, 0) or UDim2.new(0, 0, 0, 0)
							OptBtn.Size     = isCenter and UDim2.new(0, Size, 0, Size) or UDim2.new(0, Size, 1, 0)
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
					}), "Text", _tabName),
					AddThemeObject(SetProps(MakeElement("Image", OrionLib:ResolveIcon(ButtonConfig.Icon)), {
						Size = UDim2.new(0, 20, 0, 20),
						Position = UDim2.new(1, -30, 0, 7),
					}), "TextDark", _tabName),
					AddThemeObject(MakeElement("Stroke"), "Stroke", _tabName),
					Click
				}), "Second", _tabName)
				
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
				ToggleConfig.Bind = ToggleConfig.Bind or nil         
				ToggleConfig.BindFlag = ToggleConfig.BindFlag or nil  
			
				local Toggle = {
					uccolor = ToggleConfig.Color ~= nil,
					Value = ToggleConfig.Default,
					ccolor = ToggleConfig.Color,
					Save = ToggleConfig.Save,
					strokeTween = nil,
					Type = "Toggle",
					boxTween = nil,
					Box = nil,
					BindValue = ToggleConfig.Bind,
					Binding = false
				}
			
				if ToggleConfig.Flag then
					OrionLib.Flags[ToggleConfig.Flag] = Toggle
				end
			
				local hasBind = ToggleConfig.Bind ~= nil
			
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
			
				local BindBox
				if hasBind then
					BindBox = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
						Size = UDim2.new(0, 24, 0, 24),
						Position = UDim2.new(1, -44, 0.5, 0),
						AnchorPoint = Vector2.new(1, 0.5)
					}), {
						AddThemeObject(MakeElement("Stroke"), "Stroke", _tabName),
						AddThemeObject(SetProps(MakeElement("Label", "None", 14), {
							Size = UDim2.new(1, 0, 1, 0),
							Font = Enum.Font.GothamBold,
							TextXAlignment = Enum.TextXAlignment.Center,
							Name = "Value"
						}), "Text", _tabName)
					}), "Main", _tabName)
				end
			
				local ToggleFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 38),
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", ToggleConfig.Name, 15), {
						Size = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold,
						Name = "Content"
					}), "Text", _tabName),
					AddThemeObject(MakeElement("Stroke"), "Stroke", _tabName),
					ToggleBox,
					hasBind and BindBox or MakeElement("TFrame"),
					Click
				}), "Second", _tabName)
			
				Relem(_tabName, ToggleConfig.Name, ToggleFrame)
			
				function Toggle:Set(Value, Silent)
					Toggle.Value = Value
					local ac = Toggle.uccolor and Toggle.ccolor or OrionLib.Themes[OrionLib.SelectedTheme].Accent
					local ti = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			
					Toggle.boxTween = vgs.TS:Create(ToggleBox, ti, {
						BackgroundColor3 = Toggle.Value and ac or OrionLib.Themes[OrionLib.SelectedTheme].Divider
					})
					Toggle.strokeTween = vgs.TS:Create(ToggleBox:FindFirstChild("Stroke"), ti, {
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
			
				AddConnection(Click.InputEnded, function(Input)
					if Input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
			
					if hasBind then
						local bp = BindBox.AbsolutePosition
						local bs = BindBox.AbsoluteSize
						local mp = Input.Position
			
						local insideBind = mp.X >= bp.X and mp.X <= bp.X + bs.X
							and mp.Y >= bp.Y and mp.Y <= bp.Y + bs.Y
			
						if insideBind then
							if Toggle.Binding then return end
							Toggle.Binding = true
							BindBox.Value.Text = ""
							return 
						end
					end
			
					vgs.TS:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
						BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)
					}):Play()
					Toggle:Set(not Toggle.Value)
					SaveCfg(game.GameId)
				end)
			
				AddConnection(Click.MouseButton1Down, function()
					vgs.TS:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
						BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 6)
					}):Play()
				end)
			
				table.insert(OrionLib.Toggles, Toggle)
			
				if hasBind then --biiiiiiiiiiiind uhuhuhu
					function Toggle:SetBind(Key)
						Toggle.Binding = false
						Toggle.BindValue = Key or Toggle.BindValue
						local name = typeof(Toggle.BindValue) == "EnumItem" and Toggle.BindValue.Name or tostring(Toggle.BindValue)
						BindBox.Value.Text = (name == "Unknown") and "None" or name
						if ToggleConfig.BindFlag then
							OrionLib.Flags[ToggleConfig.BindFlag] = {Value = name, Type = "PBind"}
						end
					end
			
					AddConnection(BindBox.Value:GetPropertyChangedSignal("Text"), function()
						vgs.TS:Create(BindBox, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
							Size = UDim2.new(0, BindBox.Value.TextBounds.X + 19, 0, 24)
						}):Play()
					end)
			
					AddConnection(vgs.UIS.InputBegan, function(Input)
						if vgs.UIS:GetFocusedTextBox() then return end
			
						if Toggle.Binding then
							local Key
							pcall(function()
								if Input.KeyCode == Enum.KeyCode.Backspace or Input.KeyCode == Enum.KeyCode.Return then
									Key = Enum.KeyCode.Unknown
								elseif not CheckKey(BlacklistedKeys, Input.KeyCode) then
									Key = Input.KeyCode
								end
							end)
							pcall(function()
								if CheckKey(WhitelistedMouse, Input.UserInputType) and not Key then
									Key = Input.UserInputType
								end
							end)
							Key = Key or Toggle.BindValue
							Toggle:SetBind(Key)
							pcall(function() SaveCfg(game.GameId) end)
							return
						end
			
						local bv = Toggle.BindValue
						if not bv or (typeof(bv) == "EnumItem" and bv.Name == "Unknown") then return end
			
						if (Input.KeyCode == bv or Input.UserInputType == bv) and BindBox.Value.Text ~= "None" then
							Toggle:Set(not Toggle.Value)
							pcall(function() SaveCfg(game.GameId) end)
						end
					end)
			
					Toggle:SetBind(ToggleConfig.Bind)

					vgs.TS:Create(BindBox, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
						Size = UDim2.new(0, BindBox.Value.TextBounds.X + 19, 0, 24)
					}):Play()
				end


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
					}), "Text", _tabName)
			
					local lblTxt = AddThemeObject(SetProps(MakeElement("Label", lbl .. ":", 15), {
						Size = UDim2.new(0, 20, 1, 0),
						Position = UDim2.new(1, xPos - 30, 0, 0),
						AnchorPoint = Vector2.new(1, 0),
						Font = Enum.Font.GothamBold,
						TextXAlignment = Enum.TextXAlignment.Right,
						Name = "OuterLabel"
					}), "Text", _tabName)
			
					local cont = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
						Size = UDim2.new(0, 24, 0, 24),
						Position = UDim2.new(1, xPos, 0.5, 0),
						AnchorPoint = Vector2.new(1, 0.5)
					}), {
						AddThemeObject(MakeElement("Stroke"), "Stroke", _tabName),
						tb
					}), "Main", _tabName)
			
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
					}), "Text", _tabName),
					AddThemeObject(MakeElement("Stroke"), "Stroke", _tabName),
					LX, BX, LY, BY, LZ, BZ
				}), "Second", _tabName)
			
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
				local s = {Value = SliderConfig.Default, Save = SliderConfig.Save, IsClicking = false, _st = st, Name = SliderConfig.Name}
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
				}), "Text", _tabName)}), "Accent", _tabName)
			
				local sb = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(9, 149, 98), 0, 5), {
					Size = UDim2.new(1, -24, 0, 26),
					Position = UDim2.new(0, 12, 0, 30),
					BackgroundTransparency = 0.9,
					Active = true
				}), {AddThemeObject(SetProps(MakeElement("Stroke"), {
					Color = Color3.fromRGB(9, 149, 98), 
					Thickness = inf and 1.5 or 1
				}), "Stroke", _tabName),
					AddThemeObject(SetProps(MakeElement("Label", "value", 13), {
						Size = UDim2.new(1, -12, 0, 14), 
						Position = UDim2.new(0, 12, 0, 6), 
						Font = Enum.Font.GothamBold, 
						Name = "Value", 
						TextTransparency = 0.8
					}), "TextDark", _tabName),
					sd}), "Second", _tabName)
			
				local sf = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
					Size = UDim2.new(1, 0, 0, 65), 
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", SliderConfig.Name, 15), {
						Size = UDim2.new(1, -12, 0, 14), 
						Position = UDim2.new(0, 12, 0, 10), 
						Font = Enum.Font.GothamBold, 
						Name = "Content"
					}), "Text", _tabName),
					AddThemeObject(MakeElement("Stroke"), "Stroke", _tabName),
					sb}), "Second", _tabName)
			
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
						pcall(function() SaveCfg(game.GameId) end)
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
					self.Name = n  
					local cl = sf.Content
					if cl.Text == n then return end
					task.spawn(function()
						local c = cl.Text
						for i = #c, 0, -1 do cl.Text = string.sub(c, 1, i) task.wait(0.025) end
						task.wait(0.1)
						for i = 1, #n do cl.Text = string.sub(n, 1, i) task.wait(0.035) end
					end)
				end
			
				function s:SetValueName(n)
					if n == SliderConfig.ValueName then return end
					SliderConfig.ValueName = n
					local vt = fv(self.Value) .. " " .. SliderConfig.ValueName
					sb.Value.Text = vt
					sd.Value.Text = vt
				end
				
				function s:SetMax(m)
					if m == SliderConfig.Max then return end
					if m < SliderConfig.Min then SliderConfig.Min = m end
					SliderConfig.Max = m
					inf = (m == math.huge)
					if self.Value > m and m ~= math.huge then self.Value = m end
					local vt = fv(self.Value) .. " " .. SliderConfig.ValueName
					sb.Value.Text = vt
					sd.Value.Text = vt
					vgs.TS:Create(sd, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = UDim2.fromScale(sc(self.Value), 1)
					}):Play()
				end
				
				function s:SetMin(m)
					if m == SliderConfig.Min then return end
					if m > SliderConfig.Max then SliderConfig.Max = m end
					SliderConfig.Min = m
					if self.Value < m then self.Value = m end
					local vt = fv(self.Value) .. " " .. SliderConfig.ValueName
					sb.Value.Text = vt
					sd.Value.Text = vt
					vgs.TS:Create(sd, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = UDim2.fromScale(sc(self.Value), 1)
					}):Play()
				end
			
				function s:SetConfig(cfg)
					cfg = cfg or {}
			
					if cfg.Name then
						self:SetName(cfg.Name)
						SliderConfig.Name = cfg.Name
					end
			
					if cfg.ValueName then
						self:SetValueName(cfg.ValueName)
					end
			
					if cfg.Increment then
						SliderConfig.Increment = cfg.Increment
					end
			
					if cfg.Callback then
						SliderConfig.Callback = cfg.Callback
					end
			
					if cfg.Min then
						self:SetMin(cfg.Min)
					end
			
					if cfg.Max then
						self:SetMax(cfg.Max)
					end
			
					if cfg.Default ~= nil then
						self:Set(cfg.Default)
					elseif cfg.Min or cfg.Max then
						self:Set(math.clamp(self.Value, SliderConfig.Min, SliderConfig.Max))
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
				DropdownConfig.ForcePlayer = DropdownConfig.ForcePlayer or false
				DropdownConfig.Multi = DropdownConfig.Multi or false
				DropdownConfig.Call = DropdownConfig.Call or false
				DropdownConfig.Deselect = DropdownConfig.Deselect or false
				DropdownConfig.Searchable = DropdownConfig.Searchable or false
				DropdownConfig.Grouped = DropdownConfig.Grouped or false
				DropdownConfig.Icons = DropdownConfig.Icons or false
				DropdownConfig.tgl = DropdownConfig.tgl or false
				DropdownConfig.MaxHeight = DropdownConfig.MaxHeight or 200
				DropdownConfig.PlrLeftNote = DropdownConfig.PlrLeftNote or false
				DropdownConfig.Callback = DropdownConfig.Callback or function() end
				DropdownConfig.Flag = DropdownConfig.Flag or nil
				DropdownConfig.Save = DropdownConfig.Save or false
				DropdownConfig.BackToPlayer = DropdownConfig.BackToPlayer or false
				DropdownConfig.AutoPlayer = DropdownConfig.AutoPlayer or false
				
				local Dropdown = {
					Value = DropdownConfig.Multi and {} or DropdownConfig.Default,
					Options = DropdownConfig.Options,
					filOptns = {},
					Buttons = {},
					Groups = {},
					Labels = {},
					_optSig = nil,
					Toggled = false,
					srchTxt = "",
					srchMode = false,
					Type = "Dropdown",
					Save = DropdownConfig.Save,
					isPDrop = false,
					Multi = DropdownConfig.Multi,
					BackQueue = {}
				}
				Dropdown._initialized = false
				
				if DropdownConfig.Multi then
					if type(DropdownConfig.Default) == "table" then
						for _, v in ipairs(DropdownConfig.Default) do
							if table.find(Dropdown.Options, v) then
								table.insert(Dropdown.Value, v)
							end
						end
					elseif DropdownConfig.Default ~= nil then
						if table.find(Dropdown.Options, DropdownConfig.Default) then
							table.insert(Dropdown.Value, DropdownConfig.Default)
						end
					end
				end
			
				local function OptTxtOf(option)
				return type(option) == "table" and (option.text or option.name or tostring(option.value)) or tostring(option)
			end
			
			local function OptsSig(opts, grouped)
				local parts = {}
				if grouped then
					for gName, grpOpts in pairs(opts) do
						table.insert(parts, "#" .. tostring(gName))
						for _, o in pairs(grpOpts) do
							table.insert(parts, OptTxtOf(o))
						end
					end
				else
					for _, o in pairs(opts) do
						table.insert(parts, OptTxtOf(o))
					end
				end
				return table.concat(parts, "\1")
			end
			
			local function DtctPDrop()
					if DropdownConfig.ForcePlayer then return true end
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
				local MaxElems = 3
			
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
						}), "Stroke", _tabName),
						AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072706796"), {
							Size = UDim2.new(0, 16, 0, 16),
							Position = UDim2.new(1, -20, 0.5, 0),
							AnchorPoint = Vector2.new(0, 0.5),
							ImageColor3 = Color3.fromRGB(160, 160, 160),
							Rotation = 180,
							Name = "SearchArrow"
						}), "TextDark", _tabName)
					}), "Main", _tabName)
			
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
					}), {AddThemeObject(MakeElement("Stroke"), "Stroke", _tabName), SrchBox}), "Main", _tabName)
				end
			
				local hheight = 38
				local srextra = DropdownConfig.Searchable and 32 or 0
			
				local DdCont = AddThemeObject(SetProps(SetChildren(MakeElement("ScrollFrame", Color3.fromRGB(40, 40, 40), 4), {
					DdList
				}), {
					Parent = ItemParent,
					Position = UDim2.new(0, 0, 0, hheight + srextra),
					Size = UDim2.new(1, 0, 1, -(hheight + srextra)),
					ClipsDescendants = true,
					Visible = false,
					ScrollBarImageTransparency = 1,
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					CanvasSize = UDim2.new(0, 0, 0, 0)
				}), "Divider", _tabName)
			
				local Click = SetProps(MakeElement("Button"), {
					Size = UDim2.new(1, 0, 1, 0)
				})
			
				local ContentLabel = AddThemeObject(SetProps(MakeElement("Label", DropdownConfig.Name, 15), {
					Size = UDim2.new(0, 0, 1, 0),
					AutomaticSize = Enum.AutomaticSize.X,
					Position = UDim2.new(0, 12, 0, 0),
					Font = Enum.Font.GothamBold,
					Name = "Content"
				}), "Text", _tabName)
			
				local SelectedLabel = AddThemeObject(SetProps(MakeElement("Label", "Select option", 13), {
					Position = UDim2.new(0, 12, 0, 0),
					Size = UDim2.new(1, -55, 1, 0),
					Font = Enum.Font.Gotham,
					Name = "Selected",
					TextXAlignment = Enum.TextXAlignment.Right,
					TextTruncate = Enum.TextTruncate.AtEnd
				}), "TextDark", _tabName)
			
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
							Name = "Arrow",
							Rotation = 180,
						}), "TextDark", _tabName),
						SelectedLabel,
						AddThemeObject(SetProps(MakeElement("Frame"), {
							Size = UDim2.new(1, 0, 0, 1),
							Position = UDim2.new(0, 0, 1, -1),
							Name = "Line",
							Visible = false
						}), "Stroke", _tabName),
						Click
					}), {
						Size = UDim2.new(1, 0, 0, 38),
						ClipsDescendants = true,
						Name = "Header"
					}),
					AddThemeObject(MakeElement("Stroke"), "Stroke", _tabName),
					MakeElement("Corner")
				}), "Second", _tabName)
			
				Relem(_tabName, DropdownConfig.Name, DdFrame)
			
				function Dropdown:resname()
					local nameWidth = ContentLabel.TextBounds.X + 12 + 8
					SelectedLabel.Position = UDim2.new(0, nameWidth, 0, 0)
					SelectedLabel.Size = UDim2.new(1, -(nameWidth + 38), 1, 0)
				end
			
				AddConnection(ContentLabel:GetPropertyChangedSignal("TextBounds"), function()
					Dropdown:resname()
				end)
				AddConnection(DdFrame:GetPropertyChangedSignal("AbsoluteSize"), function()
					Dropdown:resname()
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
						optIcon = optData.icon and OrionLib:ResolveIcon(optData.icon) or nil
						optVal = optData.value or optTxt
					else
						optTxt = tostring(optData)
						optVal = optData
					end
			
					Dropdown.Labels[optVal] = optTxt
			
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
							}), "Text", _tabName),
							AddThemeObject(SetProps(MakeElement("Label", uname, 12, 0.3), {
								Name = "Username",
								Position = UDim2.new(0, 60, 0, 26),
								Size = UDim2.new(1, -70, 0, 14),
								Font = Enum.Font.Gotham,
								TextXAlignment = Enum.TextXAlignment.Left,
								TextColor3 = Color3.fromRGB(200, 200, 200),
								BackgroundTransparency = 1
							}), "Text", _tabName),
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
							}), "Divider", _tabName)
						}), {
							Parent = group or DdCont,
							Size = UDim2.new(1, 0, 0, optH),
							BackgroundTransparency = 1,
							ClipsDescendants = true
						}), "Divider", _tabName)
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
							}), "Text", _tabName),
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
						}), "Divider", _tabName)
					end
			
					AddConnection(OptBtn.MouseButton1Click, function()
						if DropdownConfig.Multi then
							local index = table.find(Dropdown.Value, optVal)
							if index then
								table.remove(Dropdown.Value, index)
							else
								table.insert(Dropdown.Value, optVal)
							end
						else
							if Dropdown.Value == optVal and DropdownConfig.Deselect then
								Dropdown:Set("...") 
							else
								Dropdown:Set(optVal)
							end
						
							Dropdown.Toggled = false
							Dropdown.srchMode = false
							if DropdownConfig.Searchable and SrchBox then
								SrchBox.Text = ""
								Dropdown.srchTxt = ""
								relfcs()
							end
							Dropdown:UpdVis()
						end
							Dropdown:UpdSel()
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
						}), "TextDark", _tabName)
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
				local staggerConn = nil
				
				local function StaggerAnim()
					if staggerConn then
						task.cancel(staggerConn)
						staggerConn = nil
					end
			
					local visibleBtns = {}
					for _, btn in pairs(Dropdown.Buttons) do
						if btn.Visible then table.insert(visibleBtns, btn) end
					end
			
					staggerConn = task.spawn(function()
						for i, btn in ipairs(visibleBtns) do
							if not Dropdown.Toggled then break end  
							if btn and btn.Parent then
								vgs.TS:Create(btn, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
									Position = UDim2.new(0, 0, 0, 0),
									BackgroundTransparency = btn.BackgroundTransparency
								}):Play()
							end
							if i < #visibleBtns then
								task.wait(0.02)
							end
						end
						staggerConn = nil
					end)
				end
			
				function Dropdown:UpdSel(mode)
					local selTxt = ""
					if self.Multi then
						if type(self.Value) == "table" and #self.Value > 0 then
							local vVals = {}
							for _, v in pairs(self.Value) do
								table.insert(vVals, self.Labels[v] or tostring(v))
							end
							selTxt = #vVals > 0 and table.concat(vVals, ", ") or "Select options"
						else
							selTxt = "Select options"
						end
					else
						if self.Value == "" or self.Value == "..." then
							selTxt = "Select option"
						else
							selTxt = self.Labels[self.Value] or tostring(self.Value)
						end
					end
			
					DdFrame.Header.Selected.Text = selTxt
			
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
			
					local newPos = UDim2.new(0, 0, 0, hheight + totSrchH)
					local newSz = UDim2.new(1, 0, 1, -(hheight + totSrchH))
			
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
			
					local totH = self.Toggled and (hheight + cntH) or hheight
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
							spawn(function() task.wait(0.1) SrchBox:CaptureFocus() end)
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
				
				function Dropdown:Set(...)
					local args = {...}
					
					local function resolve(input)
						local iname, idis
						if type(input) == "table" and input.Name and input.DisplayName then
							iname = input.Name
							idis = input.DisplayName
						else
							iname = tostring(input)
							idis = iname
						end
						
						for _, opt in ipairs(self.Options) do
							local val = type(opt) == "table" and (opt.value or opt.text or tostring(opt)) or opt
							local txt = tostring(val)
							
							if txt == iname or txt == idis then
								return val
							end
							
							local name = txt:match("^(.-) %(")
							if name and (name == iname or name == idis) then
								return val
							end
							
							local disp = txt:match("%((.-)%)$")
							if disp and (disp == iname or disp == idis) then
								return val
							end
						end
						return nil
					end
					
					if not self.Multi then
						local value = resolve(args[1])
						self.Value = value or "..."
						self:UpdSel()
						pcall(DropdownConfig.Callback, self.Value)
						return
					end
					
					local replace = (type(args[#args]) == "boolean") and table.remove(args)
					local newvals = {}
					for _, v in ipairs(args) do
						local r = resolve(v)
						if r then table.insert(newvals, r) end
					end
					
					if replace then
						self.Value = newvals
					else
						for _, v in ipairs(newvals) do
							if not table.find(self.Value, v) then
								table.insert(self.Value, v)
							end
						end
					end
					
					self:UpdSel(1)
					pcall(DropdownConfig.Callback, self.Value)
				end
				
				function Dropdown:Refresh(Options, Delete, HardReset)
					local newSig = OptsSig(Options, DropdownConfig.Grouped)
			
					if Delete and not HardReset and self._optSig ~= nil and newSig == self._optSig then
						return
					end
			
					local prevLabels
					if Delete then
						if self.Multi then
							prevLabels = {}
							for _, v in pairs(self.Value) do
								table.insert(prevLabels, self.Labels[v] or tostring(v))
							end
						elseif self.Value ~= "..." and self.Value ~= "" then
							prevLabels = self.Labels[self.Value]
						end
			
						for _, v in pairs(self.Buttons) do v:Destroy() end
						for _, v in pairs(self.Groups) do v:Destroy() end
						table.clear(self.Buttons)
						table.clear(self.Groups)
						table.clear(self.Labels)
					end
					self.Options = Options
					DropdownConfig.Options = Options
					self._optSig = newSig
				
					self.isPDrop = DtctPDrop()
				
					if DropdownConfig.Grouped then
						for gName, grpOpts in pairs(Options) do CrtGrp(gName, grpOpts) end
					else
						for _, option in pairs(Options) do CrtOpt(option) end
					end
					
					if prevLabels then
						if self.Multi then
							local matched = {}
							for optVal, label in pairs(self.Labels) do
								if table.find(prevLabels, label) then
									table.insert(matched, optVal)
								end
							end
							self.Value = matched
						else
							local found = false
							for optVal, label in pairs(self.Labels) do
								if label == prevLabels then
									self.Value = optVal
									found = true
									break
								end
							end
							if not found then
								self.Value = "..."
							end
						end
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
					if not Dropdown.Toggled then
						Dropdown.srchMode = false
					end
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
			
						if DropdownConfig.AutoPlayer and Dropdown.isPDrop then
							local exists = false
							for _, option in pairs(Dropdown.Options) do
								local optTxt = type(option) == "table" and (option.text or option.name) or tostring(option)
								local pName = optTxt:match("^(.-) %(") or optTxt
								if pName == plr.Name then
									exists = true
									break
								end
							end
			
							if not exists then
								local newOpt = plr.Name .. " (" .. plr.DisplayName .. ")"
								table.insert(Dropdown.Options, newOpt)
								CrtOpt(newOpt)
								if DropdownConfig.Searchable and Dropdown.srchTxt ~= "" then FiltrOpts() end
								if Dropdown.Toggled then Dropdown:UpdVis() end
								Dropdown:UpdSel()
							end
						end
			
						if DropdownConfig.BackToPlayer and #Dropdown.BackQueue > 0 then
							for i = #Dropdown.BackQueue, 1, -1 do
								local savedVal = Dropdown.BackQueue[i]
								local n = tostring(savedVal):match("^(.-) %(") or tostring(savedVal)
								if n == plr.Name then
									table.remove(Dropdown.BackQueue, i)
									if DropdownConfig.Multi then
										if not table.find(Dropdown.Value, savedVal) then
											table.insert(Dropdown.Value, savedVal)
										end
										pcall(function() DropdownConfig.Callback(Dropdown.Value) end)
									else
										Dropdown.Value = savedVal
										pcall(function() DropdownConfig.Callback(Dropdown.Value) end)
									end
									Dropdown:UpdSel()
									pcall(function() SaveCfg(game.GameId) end)
									break
								end
							end
						end
			
						if DropdownConfig.Searchable and Dropdown.srchTxt ~= "" then FiltrOpts() end
					end)
			
					local plrRemConn = AddConnection(vgs.ps.PlayerRemoving, function(plr)
						if not Dropdown.isPDrop then return end
						local pName = plr.Name
			
						if DropdownConfig.AutoPlayer then
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
						end
			
						if DropdownConfig.BackToPlayer then
							if DropdownConfig.Multi then
								for i = #Dropdown.Value, 1, -1 do
									local val = Dropdown.Value[i]
									local n = tostring(val):match("^(.-) %(") or tostring(val)
									if n == pName then
										table.insert(Dropdown.BackQueue, val)
										table.remove(Dropdown.Value, i)
									end
								end
								pcall(function() DropdownConfig.Callback(Dropdown.Value) end)
							else
								local curr = Dropdown.Value
								local n = tostring(curr):match("^(.-) %(") or tostring(curr)
								if n == pName then
									table.insert(Dropdown.BackQueue, curr)
									Dropdown:Set("...")
								end
							end
							Dropdown:UpdSel()
							pcall(function() SaveCfg(game.GameId) end)
						else
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
						end
			
						Dropdown:UpdSel()
						if DropdownConfig.Searchable and Dropdown.srchTxt ~= "" then FiltrOpts() end
						if Dropdown.Toggled then Dropdown:UpdVis() end
					end)
			
					AddConnection(DdFrame.Destroying, function()
						if plrRemConn and plrRemConn.Connected then
							plrRemConn:Disconnect()
							connSet[plrRemConn] = nil
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
					AddThemeObject(MakeElement("Stroke"), "Stroke", _tabName),
					AddThemeObject(SetProps(MakeElement("Label", BindConfig.Name, 14), {
						Size = UDim2.new(1, 0, 1, 0),
						Font = Enum.Font.GothamBold,
						TextXAlignment = Enum.TextXAlignment.Center,
						Name = "Value"
					}), "Text", _tabName)
				}), "Main", _tabName)

				local BindFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 38),
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", BindConfig.Name, 15), {
						Size = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold,
						Name = "Content"
					}), "Text", _tabName),
					AddThemeObject(MakeElement("Stroke"), "Stroke", _tabName),
					BindBox,
					Click
				}), "Second", _tabName)
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
				}), "Text", _tabName)
			
				local TextContainer = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
					Size = UDim2.new(0, 24, 0, 24),
					Position = UDim2.new(1, -12, 0.5, 0),
					AnchorPoint = Vector2.new(1, 0.5),
					ClipsDescendants = true
				}), {
					AddThemeObject(MakeElement("Stroke"), "Stroke", _tabName),
					TextboxActual
				}), "Main", _tabName)
			
				local ContentLabel = AddThemeObject(SetProps(MakeElement("Label", TextboxConfig.Name, 15), {
					Size = UDim2.new(1, -50, 1, 0),
					Position = UDim2.new(0, 12, 0, 0),
					Font = Enum.Font.GothamBold,
					Name = "Content",
					TextTruncate = Enum.TextTruncate.AtEnd
				}), "Text", _tabName)
			
				local TextboxFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 38),
					Parent = ItemParent
				}), {
					ContentLabel,
					AddThemeObject(MakeElement("Stroke"), "Stroke", _tabName),
					TextContainer,
					Click
				}), "Second", _tabName)
			
				Relem(_tabName, TextboxConfig.Name, TextboxFrame)
			
				local function updW()
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
			
				local textboxfunction = {}
			
				function textboxfunction:Set(newText)
					TextboxActual.Text = newText
				end
			
				function textboxfunction:toggle()
					TextboxFrame.Visible = not TextboxFrame.Visible
					if SearchSystem.elmnts[_tabName] and SearchSystem.elmnts[_tabName][TextboxConfig.Name] then
						SearchSystem.elmnts[_tabName][TextboxConfig.Name].visible = TextboxFrame.Visible
					end
				end
			
				function textboxfunction:remove()
					if SearchSystem.elmnts[_tabName] then
						SearchSystem.elmnts[_tabName][TextboxConfig.Name] = nil
					end
					if TextboxFrame and TextboxFrame.Parent then
						TextboxFrame:Destroy()
					end
				end
			
				return textboxfunction
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
							ColorSequenceKeypoint.new(0.000000, Color3.fromHSV(0.000000, 1, 1)),
							ColorSequenceKeypoint.new(0.052632, Color3.fromHSV(0.052632, 1, 1)),
							ColorSequenceKeypoint.new(0.105263, Color3.fromHSV(0.105263, 1, 1)),
							ColorSequenceKeypoint.new(0.157895, Color3.fromHSV(0.157895, 1, 1)),
							ColorSequenceKeypoint.new(0.210526, Color3.fromHSV(0.210526, 1, 1)),
							ColorSequenceKeypoint.new(0.263158, Color3.fromHSV(0.263158, 1, 1)),
							ColorSequenceKeypoint.new(0.315789, Color3.fromHSV(0.315789, 1, 1)),
							ColorSequenceKeypoint.new(0.368421, Color3.fromHSV(0.368421, 1, 1)),
							ColorSequenceKeypoint.new(0.421053, Color3.fromHSV(0.421053, 1, 1)),
							ColorSequenceKeypoint.new(0.473684, Color3.fromHSV(0.473684, 1, 1)),
							ColorSequenceKeypoint.new(0.526316, Color3.fromHSV(0.526316, 1, 1)),
							ColorSequenceKeypoint.new(0.578947, Color3.fromHSV(0.578947, 1, 1)),
							ColorSequenceKeypoint.new(0.631579, Color3.fromHSV(0.631579, 1, 1)),
							ColorSequenceKeypoint.new(0.684211, Color3.fromHSV(0.684211, 1, 1)),
							ColorSequenceKeypoint.new(0.736842, Color3.fromHSV(0.736842, 1, 1)),
							ColorSequenceKeypoint.new(0.789474, Color3.fromHSV(0.789474, 1, 1)),
							ColorSequenceKeypoint.new(0.842105, Color3.fromHSV(0.842105, 1, 1)),
							ColorSequenceKeypoint.new(0.894737, Color3.fromHSV(0.894737, 1, 1)),
							ColorSequenceKeypoint.new(0.947368, Color3.fromHSV(0.947368, 1, 1)),
							ColorSequenceKeypoint.new(1.000000, Color3.fromHSV(1.000000, 1, 1))
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
				}), {AddThemeObject(MakeElement("Stroke"), "Stroke", _tabName)})
			
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
						}), "Text", _tabName),
						ColorpickerBox,
						Click,
						AddThemeObject(SetProps(MakeElement("Frame"), {
							Size = UDim2.new(1, 0, 0, 1),
							Position = UDim2.new(0, 0, 1, -1),
							Name = "Line",
							Visible = false
						}), "Stroke", _tabName)
					}), {
						Size = UDim2.new(1, 0, 0, 38),
						ClipsDescendants = true,
						Name = "F"
					}),
					ColorpickerContainer,
					AddThemeObject(MakeElement("Stroke"), "Stroke", _tabName)
				}), "Second", _tabName)
			
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
						if ColorpickerConfig.Save then SaveCfg(game.GameId) end
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
						if ColorpickerConfig.Save then SaveCfg(game.GameId) end
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
				local svtg = OrionLib.Flags["SmartThemeSave"]
		
				local tmcp = gersec:AddColorpicker({
					Name = "Base Color",
					Default = OrionLib.Themes[OrionLib.SelectedTheme].Main,
					Flag = "SmartThemeColor", 
					Save = true,
					Callback = function(Value)
						local s = OrionLib.Flags["SmartThemeSave"]
						if not (s and s.Value) then 
							OrionLib.Themes.Custom = OrionLib:GenTheme(Value)
							OrionLib.SelectedTheme = "Custom"
							OrionLib:SetOTheme()
							return
						else
							OrionLib.Themes.Custom = OrionLib:GenTheme(Value)
							OrionLib.SelectedTheme = "Custom"
							OrionLib:SetOTheme()
							SaveCfg(game.GameId)
						end  
					end
				})
			
				gersec:AddButton({
					Name = "Reset Theme",
					Callback = function()
						tmcp:Set(OrionLib.Themes.Default.Main)
						if svtg and svtg.Value then SaveCfg(game.GameId) end
					end
				})
			
				gersec:AddSection()

				gersec:AddDropdown({
					Name = "UI Scale",
					Options = {"80%", "95%", "100%", "110%"},
					Default = "100%",
					Flag = "UIScale",
					Save = true,
					Callback = function(Value)
						local percent = tonumber(Value:match("%d+"))
						Functions:SetUIScale(percent)
					end
				})
				
				gersec:AddToggle({
					Name = "Save UI Configs",
					Default = false,
					Flag = "SmartThemeSave",
					Save = true,
					Callback = function(Value)
						if Value and OrionLib.SaveCfg and writefile then
							pcall(function()
								writefile(OrionLib.Folder .. "/_windowname.txt", WindowName.ContentText ~= "" and WindowName.ContentText or WindowName.Text)
								SaveCfg(game.GameId)
							end)
						end
					end
				})
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
				Visible = true,
				Parent = Container
			}), children)
			
			local rkey = hn and name or ("section_" .. tostring(SectionFrame))
			Relem(TabConfig.Name, rkey, SectionFrame)
			
			local secEntry = nil
			if SearchSystem.elmnts[TabConfig.Name] then
				for _, v in pairs(SearchSystem.elmnts[TabConfig.Name]) do
					if v.frame == SectionFrame then secEntry = v break end
				end
			end

			AddConnection(SectionFrame.Holder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
				local contentY = SectionFrame.Holder.UIListLayout.AbsoluteContentSize.Y
				SectionFrame.Size = UDim2.new(1, 0, 0, contentY + lh + (hn and 8 or 0))
				SectionFrame.Holder.Size = UDim2.new(1, 0, 0, contentY)
			end)
			
			local SectionFunction = {}
			
			function SectionFunction:toggle()
				SectionFrame.Visible = not SectionFrame.Visible
				if secEntry then secEntry.visible = SectionFrame.Visible end
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
--sep                                                                  
--# THE EEEEEEEEEEEEEEEEEENDDDD(i hope u enjoyed my code:D // ps: "my code" | 40% mine and 60% of Orion Library Creator)

function OrionLib:Destroy()
	UnlockMouse(false)
	Orion:Destroy()
end

return OrionLib
