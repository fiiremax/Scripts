  # Orion Library Custom - Documentation

## Introduction

Orion Library Custom is an enhanced UI library for Roblox featuring advanced elements, dynamic search, theme generation, and more.

---

## Booting the Library

```lua
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/fiiremax/Scripts/refs/heads/main/Loader.lua')))()
```

---

## Creating a Window

```lua
local Window = OrionLib:MakeWindow({
    Name = "Title of the library",
    ConfigFolder = "OrionTest",
    SaveConfig = true,
    HidePremium = false,
    IntroEnabled = true,
    IntroText = "Orion Library",
    TagText = "Owner",
    IntroIcon = "rbxassetid://8834748103",
    FreeMouse = false,
    Openkey = "RightShift",
    ShowIcon = false,
    Icon = "rbxassetid://8834748103",
    CloseCallback = function()
        -- Code to execute when GUI closes
    end,
    SearchBar = true -- Enable search bar
})
```

### Configuring Window Name with Colors

```lua
Window:SetName(
    {"Orion ", "#00FF00"},  -- Green text
    {"Library", "#FF0000"}  -- Red text
)
```

---
### Configuring Window Icon with ID
```lua
Window:ChangeIcon("ID") 
--or
Window:ChangeIcon("rbxassetid://ID")
```
---

## Creating a Tab

```lua
local Tab = Window:MakeTab({
    Name = "Tab Name",
    Icon = "rbxassetid://4483345875",
    PremiumOnly = false
})
```

---

## Creating a Section

```lua
local Section = Tab:AddSection({
    Name = "Section Name"
})
```

---

## Notifications

```lua
OrionLib:MakeNotification({
    Name = "Title!",
    Content = "Notification content goes here.",
    Image = "rbxassetid://4384403532",
    Time = 5
})
```

---

## Label

Creates a simple text label.

```lua
local Label = Tab:AddLabel("Label Text")
```

### Updating Label

```lua
Label:Set("New Text")
```

### Updating Label with Colors

```lua
Label:Set("Player Health: 100", {
    ["Player"] = "#00FF00",  -- Green
    ["Health"] = "#FF0000",  -- Red
    ["100"] = "#FFFF00"      -- Yellow
})
```

---

## ColorLabel

Creates a label with custom color and alignment.

```lua
local ColorLabel = Tab:ColorLabel("Text", Color3.fromRGB(255, 0, 0), "Center")
-- Position: "Left", "Center", "Right"
```

### Updating ColorLabel

```lua
ColorLabel:Set("New Text", Color3.fromRGB(0, 255, 0), "Right")
```

---
## AddPBind

Creates a Tiny TextBox X Y Z to change Positions.

```lua
tonumber -- for all types of numbers (if not valid number or letters it will be nil.)
Tab:AddPbind({
    Name = "Position",
    DefaultX = "1",
    DefaultY = "2",
    DefaultZ = "3",
    Callback = function(x, y, z)
        print(tonumber(x), tonumber(y), tonumber(z))
    end
})

```

## Paragraph

Creates a title with description.

```lua
local Paragraph = Tab:AddParagraph("Paragraph Title", "Paragraph Content")
```

### Updating Paragraph

```lua
Paragraph:Set("New content text")
```

---

## PParagraph

Advanced paragraph with text alignment and line breaks.

```lua
local PParagraph = Tab:AddPParagraph("Title", "Line 1\\nLine 2\\nLine 3", "Center")
-- Alignment: "Left", "Center", "Right"
```

### Updating PParagraph

```lua
PParagraph:Set("New Title", "New Content\\nWith line breaks", "Left")
```

---

## Button

Creates a clickable button.

```lua
local Button = Tab:AddButton({
    Name = "Button Name",
    Icon = "rbxassetid://3944703587",
    Callback = function()
        print("Button pressed!")
    end    
})
```

### Updating Button Text

```lua
Button:Set("New Button Text")
```

---

## Toggle

Creates a toggle switch.

```lua
local Toggle = Tab:AddToggle({
    Name = "Toggle Name",
    Default = false,
    Color = Color3.fromRGB(9, 99, 195),
    Callback = function(Value)
        print("Toggle state:", Value)
    end,
    Flag = "ToggleFlag", -- For saving
    Save = true
})
```

### Updating Toggle

```lua
Toggle:Set(true) -- Enable
Toggle:Set(false) -- Disable
```

---

## Slider

Creates a slider with customizable range.

```lua
local Slider = Tab:AddSlider({
    Name = "Slider Name",
    Min = 0,
    Max = 100,
    Default = 50,
    Increment = 1,
    ValueName = "studs",
    Callback = function(Value)
        print("Slider value:", Value)
    end,
    Flag = "SliderFlag", -- For saving
    Save = true,
    Block = true -- Enable/disable based on condition
})
```

### Slider Methods

```lua
-- Update value
Slider:Set(75)

-- Change slider name
Slider:SetName("New Slider Name")

-- Change max value
Slider:SetMax(200)

-- Change min value
Slider:SetMin(10)

-- Check if user is clicking slider
if Slider.IsClicking then
    print("User is dragging slider")
end
```

### Infinite Slider

```lua
local InfiniteSlider = Tab:AddSlider({
    Name = "Infinite Slider",
    Min = 0,
    Max = math.huge, -- Infinity
    Default = 50,
    Increment = 1,
    ValueName = "value",
    Callback = function(Value)
        if Value == math.huge then
            print("Infinite!")
        else
            print("Value:", Value)
        end
    end
})
```

### Dynamic Blocking

```lua
-- Block based on toggle state With Table(Use Module, Same GitHub btw)
local BlockedSlider = Tab:AddSlider({
    Name = "Conditional Slider",
    Min = 0,
    Max = 100,
    Default = 50,
    Block = {table, value}, -- Name of toggle flag
    VarFunc = UModule.var,
    Callback = function(Value)
        print(Value)
    end
})
```
## Dropdown

Creates a dropdown menu with single or multiple selection.

### Single Selection Dropdown

```lua
local Dropdown = Tab:AddDropdown({
    Name = "Dropdown",
    Default = "Option 1",
    Options = {"Option 1", "Option 2", "Option 3"},
    Callback = function(Value)
        print("Selected:", Value)
    end,
    Flag = "DropdownFlag", -- For saving
    Save = true
})
```

### Multi Selection Dropdown

```lua
local MultiDropdown = Tab:AddDropdown({
    Name = "Multi Dropdown",
    Default = {},
    Multi = true,
    Call = true, -- Callback on each selection
    Options = {"Option 1", "Option 2", "Option 3"},
    Callback = function(Values)
        print("Selected items:", table.concat(Values, ", "))
    end
})
```

### Searchable Dropdown

```lua
local SearchDropdown = Tab:AddDropdown({
    Name = "Searchable Dropdown",
    Options = {"Apple", "Banana", "Cherry", "Date", "Elderberry"},
    Searchable = true,
    Callback = function(Value)
        print(Value)
    end
})
```

### Grouped Dropdown

```lua
local GroupedDropdown = Tab:AddDropdown({
    Name = "Grouped Dropdown",
    Grouped = true,
    Options = {
        ["Fruits"] = {"Apple", "Banana", "Orange"},
        ["Vegetables"] = {"Carrot", "Broccoli", "Lettuce"},
        ["Meats"] = {"Chicken", "Beef", "Pork"}
    },
    Callback = function(Value)
        print(Value)
    end
})
```

### Dropdown with Icons

```lua
local IconDropdown = Tab:AddDropdown({
    Name = "Icon Dropdown",
    Icons = true,
    Options = {
        {text = "Home", icon = "rbxassetid://123456", value = "home"},
        {text = "Settings", icon = "rbxassetid://789012", value = "settings"},
        {text = "Exit", icon = "rbxassetid://345678", value = "exit"}
    },
    Callback = function(Value)
        print(Value)
    end
})
```

### Player Dropdown

Automatically detects and displays player headshots.

```lua
-- Format: "PlayerName (DisplayName)"
local PlayerDropdown = Tab:AddDropdown({
    Name = "Select Player",
    Options = {"Player1 (John)", "Player2 (Jane)"},
    Callback = function(Value)
        local playerName = Value:match("^(.-) %(") or Value
        print("Selected player:", playerName)
    end
})
```

### Dropdown Methods

```lua
-- Update selected value (single)
Dropdown:Set("Option 2")

-- Update selected values (multi)
MultiDropdown:Set({"Option 1", "Option 3"})

-- Refresh options (keep existing)
Dropdown:Refresh({"New Option 1", "New Option 2"}, false)

-- Refresh options (delete old)
Dropdown:Refresh({"Completely New 1", "Completely New 2"}, true)
```

---

## Bind

Creates a keybind.

```lua
local Bind = Tab:AddBind({
    Name = "Keybind",
    Default = Enum.KeyCode.E,
    Hold = false,
    Callback = function(Value)
        if Value then
            print("Key pressed!")
        else
            print("Key released!")
        end
    end,
    Flag = "BindFlag", -- For saving
    Save = true
})
```

### Hold Mode Bind

```lua
local HoldBind = Tab:AddBind({
    Name = "Hold Key",
    Default = Enum.KeyCode.LeftShift,
    Hold = true, -- Requires holding
    Callback = function(IsHolding)
        if IsHolding then
            print("Holding key down")
        else
            print("Released key")
        end
    end
})
```

### Updating Bind

```lua
Bind:Set(Enum.KeyCode.F) -- Change to F key
```

---

## Textbox

Creates a text input field.

```lua
local Textbox = Tab:AddTextbox({
    Name = "Textbox",
    Default = "Default text",
    TextDisappear = false,
    BackGrountText = "Text",-- Default is "Input"
    Callback = function(Value)
        print("Text entered:", Value)
    end
})
```

---

## Colorpicker

Creates a color picker.

```lua
local Colorpicker = Tab:AddColorpicker({
    Name = "Color Picker",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(Value)
        print("Selected color:", Value)
    end,
    Flag = "ColorFlag", -- For saving
    Save = true
})
```

### Updating Colorpicker

```lua
Colorpicker:Set(Color3.fromRGB(0, 255, 0))
```

---

## SmartTheme

Creates an intelligent theme generator that automatically calculates complementary colors.

```lua
Tab:AddSmartTheme()
```

This adds:
- A colorpicker to choose base color
- Automatic generation of 7 theme colors (Main, Second, Stroke, Divider, Text, TextDark, Accent)
- A reset button

---

## Using Flags

Flags allow you to save and retrieve element values.

```lua
-- Create elements with flags
Tab:AddToggle({
    Name = "Feature",
    Flag = "FeatureEnabled",
    Save = true,
    Callback = function(Value) end
})

Tab:AddSlider({
    Name = "Speed",
    Min = 0,
    Max = 100,
    Flag = "SpeedValue",
    Save = true,
    Callback = function(Value) end
})

-- Access flag values
print(OrionLib.Flags["FeatureEnabled"].Value) -- true/false
print(OrionLib.Flags["SpeedValue"].Value) -- 0-100

-- Update via flags
OrionLib.Flags["FeatureEnabled"]:Set(false)
OrionLib.Flags["SpeedValue"]:Set(75)
```

---

## Advanced Features

### Search System

When `SearchBar = true` in window config:
- Search across all tabs and elements
- Automatically switches to the tab with most matches
- Highlights matching elements
- Real-time filtering

### Free Mouse Modes

```lua
-- In window config
FreeMouse = true, -- Enables free mouse

-- Create unlock mode dropdown
Tab:FreeMouseDrp() -- Adds dropdown with "ThirdPerson" and "FreeMouse" options
```

### Destroying the GUI

```lua
-- Destroy specific window
Window:Destroy()

-- Destroy entire library
OrionLib:Destroy()
```

### Auto-Load Configuration

```lua
-- Initialize after creating all elements
OrionLib:Init()
-- Automatically loads saved config for current game
```

### Manual Config Management

```lua
-- Save config
SaveCfg(game.GameId)

-- Load config (requires reading saved file)
-- Configs are saved to ConfigFolder/GameId.txt
```

---

## Special Features

### Log Element

Full-screen text display.

```lua
local Log = Tab:AddLog("Large log text here")
Log:Set("Updated log text")
```

### Player Leave Detection (Dropdown)

Player dropdowns automatically handle player leaving:

```lua
local PlayerDrop = Tab:AddDropdown({
    Name = "Players",
    Multi = true,
    Options = {"Player1 (Display1)", "Player2 (Display2)"},
    Callback = function(Value)
        print(Value)
    end
})
-- Automatically removes players when they leave the game
```

---

## Example Script

```lua
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/fiiremax/Scripts/refs/heads/main/Loader.lua')))()

local Window = OrionLib:MakeWindow({
    Name = "My Custom UI",
    SaveConfig = true,
    ConfigFolder = "MyConfig",
    SearchBar = true
})

local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345875"
})

local Section = MainTab:AddSection({
    Name = "Features"
})

MainTab:AddToggle({
    Name = "Enable ESP",
    Default = false,
    Callback = function(Value)
        print("ESP:", Value)
    end,
    Flag = "ESPToggle",
    Save = true
})

MainTab:AddSlider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 200,
    Default = 16,
    Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
    end,
    Flag = "WalkSpeedSlider",
    Save = true
})

local PlayerDrop = MainTab:AddDropdown({
    Name = "Target Player",
    Default = "",
    Options = {"Player1", "Player2"},
    Callback = function(Value)
        print("Targeting:", Value)
    end
})

MainTab:AddButton({
    Name = "Refresh Players",
    Callback = function()
        local players = {}
        for _, player in ipairs(game.Players:GetPlayers()) do
            table.insert(players, player.Name)
        end
        PlayerDrop:Refresh(players, true)
    end
})

MainTab:AddBind({
    Name = "Toggle UI",
    Default = Enum.KeyCode.RightShift,
    Callback = function() end
})

MainTab:AddColorpicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(Value)
        print("Color:", Value)
    end,
    Save = true
})

OrionLib:Init()
```

---

## Tips

1. **Always use Flags** for elements you want to save
2. **Set Save = true** to enable auto-save
3. **Use SearchBar** for better UX with many elements
4. **Call OrionLib:Init()** at the end to load saved configs
5. **Use Section** to organize elements logically
6. **Multi dropdowns with Call = true** trigger callback on each selection change
7. **Slider Block parameter** can dynamically enable/disable sliders based on conditions

---

## Notes

- Configuration files are stored in `workspace/[ConfigFolder]/[GameId].txt`
- The library automatically manages theme colors based on selected theme
- Player dropdowns automatically detect player format and display headshots
- Search system works across all tabs simultaneously
- Infinite sliders display "∞" when at maximum value          
