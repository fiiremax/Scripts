local UModule = {}

local vgs = {
    CE = game:GetService("ReplicatedStorage").CharacterEvents,
    CAS = game:GetService("ContextActionService"),
    p = game:GetService("Players").LocalPlayer,
    VIM = game:GetService("VirtualInputManager"),
    RS = game:GetService("ReplicatedStorage"),
    UIS = game:GetService("UserInputService"),
    TXS = game:GetService("TextChatService"),
    RF = game:GetService("ReplicatedFirst"),
    PS = game:GetService("PhysicsService"),
    TS = game:GetService("TweenService"),
    RunS = game:GetService("RunService"),
    SG = game:GetService("StarterGui"),
    ps = game:GetService("Players"),
    Debris = game:GetService("Debris"),
}

local gtable = getgenv()

UModule.env = setmetatable({}, {
    __newindex = function(t, key, value)
        local old = gtable[key]
        
        if old ~= nil then
            if type(old) == "boolean" then
                gtable[key] = false
                gtable[key] = nil
                gtable[key] = value
                return
            end
            if type(old) == "string" then
                gtable[key] = nil
            end
            
            if type(old) == "userdata" or (type(old) == "table" and type(rawget(old, "Disconnect")) == "function") then
                pcall(function()
                    old:Disconnect()
                end)
                gtable[key] = nil
            elseif type(old) == "table" then
                for k, v in pairs(old) do
                    if type(v) == "boolean" then
                        old[k] = false
                        old[k] = nil
                    elseif type(v) == "string" then
                        old[k] = nil
                    elseif type(v) == "userdata" or (type(v) == "table" and type(rawget(v, "Disconnect")) == "function") then
                        pcall(function()
                            v:Disconnect()
                        end)
                        old[k] = nil
                    end
                end
            end
        end
        
        gtable[key] = value
    end,
    __index = function(t, key)
        return gtable[key]
    end
})

UModule.env.ov = {
    char = vgs.p.Character or vgs.p.CharacterAdded:Wait(),
    inv = workspace[vgs.p.Name .. "SpawnedInToys"],
    cam = workspace.CurrentCamera,
    mouse = vgs.p:GetMouse(),
}

UModule.env.Valores = UModule.env.Valores or {}
UModule.env.Toggle = UModule.env.Toggle or {}
UModule.env.Conns = UModule.env.Conns or {}
UModule.env.TempV = UModule.env.TempV or {}
UModule.env.TempL = UModule.env.TempL or {}
UModule.env.TempT = UModule.env.TempT or {}
UModule.env.TempC = UModule.env.TempC or {}
UModule.env.Drops = UModule.env.Drops or {}
UModule.env.Lists = UModule.env.Lists or {}
UModule.env.l = UModule.env.l or {}
UModule.env.v = UModule.env.v or {}
UModule.env.Vars = UModule.env.Vars or {}
UModule.env.Connections = UModule.env.Connections or {}

UModule.env.fpsval = 60

if not UModule.env.fpstrack then
    UModule.env.fpstrack = vgs.RunS.RenderStepped:Connect(function(dt)
        UModule.env.fpsval = math.floor(1 / dt)
    end)
end

function UModule.fps()
    return UModule.env.fpsval
end

if UModule.env.Conns.CharAddCnn then
    UModule.env.Conns.CharAddCnn = nil
end
UModule.env.Conns.CharAddCnn = vgs.p.CharacterAdded:Connect(function(char)
    UModule.env.ov.char = char
end)

function UModule.p(...)
    local args = {...}
    local name, model, time
    
    for _, arg in ipairs(args) do
        local t = type(arg)
        if t == "string" then
            name = arg
        elseif t == "number" then
            time = arg
        elseif typeof(arg) == "Instance" then
            model = arg
        end
    end
    
    if not name or not model then return nil end
    
    if time then 
        return model:WaitForChild(name, time) 
    else 
        return model:FindFirstChild(name) 
    end
end

function UModule.MBP(name)
    return UModule.env.ov.char:WaitForChild(name)
end

function UModule.inpast(model)
    return UModule.env.ov.inv:FindFirstChild(model)
end

function UModule.GPNames(mode, arg)
    local pnames = {}
    if mode == "func" then
        for _, p in pairs(vgs.ps:GetPlayers()) do
            if p ~= vgs.p and not arg() then
                table.insert(pnames, p.Name .. " (" .. p.DisplayName .. ")")
            end
        end
        return pnames
    end
    for _, p in pairs(vgs.ps:GetPlayers()) do
        if p ~= vgs.p then
            table.insert(pnames, p.Name .. " (" .. p.DisplayName .. ")")
        end
    end
    return pnames
end

function UModule.SPE(pt, loc, cf, ang)
    if pt and loc and cf then
        vgs.RS.PlayerEvents.StickyPartEvent:FireServer(
            pt, 
            loc, 
            cf * ang or CFrame.Angles(0, 0, 0)
        )
    end
end

function UModule.SVel(...)
    local args = {...}
    local target
    
    for _, arg in ipairs(args) do
        if typeof(arg) == "Instance" then
            target = arg
            break
        end
    end
    
    if target then
        if target:IsA("BasePart") then
            target.Velocity = Vector3.zero
            target.RotVelocity = Vector3.zero
            return 
        elseif target:IsA("Model") then
            for _, part in ipairs(target:GetDescendants()) do
                if part:IsA("BasePart") then  
                    part.Velocity = Vector3.zero
                    part.RotVelocity = Vector3.zero
                end
            end
            return 
        end
    end
    
    local hrp = UModule.env.ov.char:WaitForChild("HumanoidRootPart")
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    hrp.RotVelocity = Vector3.zero
end

function UModule.FINF()
    local uray = UModule.env.ov.cam:ScreenPointToRay(UModule.env.ov.mouse.X, UModule.env.ov.mouse.Y)
    if not uray then return nil end
    
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {UModule.env.ov.char}
    params.FilterType = Enum.RaycastFilterType.Exclude
    
    local result = workspace:Raycast(uray.Origin, uray.Direction * 10000, params)
    
    if result and result.Instance:IsA("BasePart") then
        return result.Instance
    end
    
    return nil
end

function UModule.IPPP(part, mode)
    local function isin(p, m)
        return m and p:IsDescendantOf(m) or false
    end
    
    local function cfolder(name)
        return isin(part, workspace:FindFirstChild(name))
    end
    
    local function cgrab()
        if isin(part, workspace:FindFirstChild("GrabParts")) then return true end
        
        for _, char in pairs(workspace:GetChildren()) do
            if char:IsA("Model") and char ~= UModule.env.ov.char then
                if isin(part, char:FindFirstChild("GrabParts")) then return true end
            end
        end
        return false
    end
    
    local protected = cfolder("Map") or cfolder("Plots") or cfolder("Slots") 
        or cgrab() or part:IsDescendantOf(UModule.env.ov.char)
    
    if mode == 2 and part:IsDescendantOf(UModule.env.ov.inv) then
        return true
    end
    
    return protected
end

function UModule.tp(target)
    local hrp = UModule.MBP("HumanoidRootPart")
    local pos = typeof(target) == "Vector3" and target or 
              (target:IsA("Model") and (target:GetPrimaryPartCFrame().Position or 
              target:FindFirstChild("HumanoidRootPart").Position) or target.Position)
    
    if not pos then return end
    
    local hum = hrp.Parent:FindFirstChildOfClass("Humanoid")
    local hip = hum and hum.HipHeight or 0
    local offset = (hrp.Size.Y / 2) + hip + 3.5
    local current = hrp.Parent:GetPivot()
    
    hrp.Parent:PivotTo(CFrame.new(pos.X, pos.Y + offset, pos.Z) * (current - current.Position))
end

function UModule.SICF(...)
    local args = {...}
    task.spawn(function()
        local item, cf, mode
        
        for i = 1, #args do
            local arg = args[i]
            if arg ~= nil then
                local t = type(arg)
                if t == "string" then
                    if not item then
                        item = arg
                    else
                        mode = arg
                    end
                elseif typeof(arg) == "CFrame" then
                    cf = arg
                end
            end
        end
        
        if not item then return end
        
        local hrp = UModule.env.ov.char:WaitForChild("HumanoidRootPart")
        local rotation = Vector3.new(0, 0, 0)

        if mode == "Default" then
            cf = hrp.CFrame * CFrame.new(0, 0, 0)
        elseif mode == "Head" then
            cf = CFrame.new(hrp.Position + Vector3.new(0, 13, 20))
        elseif mode == "Front" then
            cf = hrp.CFrame * CFrame.new(0, 0, 15)
        end
        
        cf = cf or hrp.CFrame
        vgs.RS.MenuToys.SpawnToyRemoteFunction:InvokeServer(item, cf, rotation)
    end)
end

function UModule.IsAround(part, radius)
    local pos = part:IsA("Model") and part.PrimaryPart.Position or part.Position
    return (pos - UModule.MBP("HumanoidRootPart").Position).Magnitude <= radius
end

function UModule.FMC(...)
    local args = {...}
    local radius, cback, flag, origin
    
    for _, arg in ipairs(args) do
        local t = type(arg)
        if t == "number" then
            radius = arg
        elseif t == "function" then
            cback = arg
        elseif t == "string" and arg == "plrs" then
            flag = "plrs"
        elseif typeof(arg) == "Instance" and arg:IsA("BasePart") then
            origin = arg
        end
    end
    
    if flag == "plrs" then
        local char = vgs.p.Character
        if not char then return end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        radius = radius or 29
        
        for _, player in ipairs(vgs.ps:GetPlayers()) do
            if player.Character and player ~= vgs.p then
                local phrp = player.Character:FindFirstChild("HumanoidRootPart")
                if phrp and UModule.IsAround(phrp, radius) then
                    if cback then cback(player.Character) end
                end
            end
        end
        return
    end
    
    if not radius then
        if typeof(args[1]) == "Instance" then
            local char = args[1]:FindFirstAncestorOfClass("Model")
            return char and char:FindFirstChild("Humanoid") and vgs.ps:GetPlayerFromCharacter(char) or nil
        end
        return nil
    end
    
    local char = vgs.p.Character
    if not char then return {} end
    
    local hrp = origin or char:FindFirstChild("HumanoidRootPart")
    if not hrp then return {} end
    
    local results, seen = {}, {}
    local filter = {char}
    
    local exclude = {"Map", "Plots", "Slots", "GrabParts"}
    for _, name in ipairs(exclude) do
        local obj = workspace:FindFirstChild(name)
        if obj then table.insert(filter, obj) end
    end
    
    for _, model in ipairs(workspace:GetChildren()) do
        if model:IsA("Model") and model ~= char then
            local gp = model:FindFirstChild("GrabParts")
            if gp then table.insert(filter, gp) end
        end
    end
    
    if flag ~= 2 then
        local inv = workspace:FindFirstChild(vgs.p.Name .. "SpawnedInToys")
        if inv then table.insert(filter, inv) end
    end
    
    local params = OverlapParams.new()
    params.FilterDescendantsInstances = filter
    params.FilterType = Enum.RaycastFilterType.Exclude
    
    local parts = workspace:GetPartBoundsInBox(
        CFrame.new(hrp.Position), 
        Vector3.new(radius * 2, radius * 2, radius * 2), 
        params
    )
    
    for _, part in ipairs(parts) do
        if not UModule.IPPP(part, flag) then
            local model = part:FindFirstAncestorOfClass("Model")
            
            if cback then
                if model and cback(model) and not seen[model] then
                    seen[model] = true
                    table.insert(results, model)
                end
            else
                if model and not seen[model] then
                    seen[model] = true
                    table.insert(results, model)
                elseif not model and not seen[part] then
                    seen[part] = true
                    table.insert(results, part)
                end
            end
        end
    end
    
    return results
end

function UModule.var(a1, a2, a3)
    if type(a1) == "table" and a2 == nil then
        for k, v in pairs(a1) do
            UModule.env[k] = v
        end
        return true
    end
    
    if type(a1) == "string" and a2 == nil and a3 == nil then
        local function search(tbl, key, visited)
            visited = visited or {}
            if visited[tbl] then return nil end
            visited[tbl] = true
            
            if type(tbl) == "table" then
                if tbl[key] ~= nil then return tbl[key] end
                
                for k, v in pairs(tbl) do
                    if type(v) == "table" and k ~= "Conns" and k ~= "Connections" and k ~= "ov" then
                        local result = search(v, key, visited)
                        if result ~= nil then return result end
                    end
                end
            end
            return nil
        end
        
        return search(UModule.env, a1)
    end
    
    if type(a1) == "string" and a2 ~= nil then
        if a2 == "ref" then
            if not UModule.env[a1] then 
                UModule.env[a1] = {}
            end
            if type(UModule.env[a1]) == "table" then
                return UModule.env[a1]
            end
            return nil
        end
        
        if a2 == "get" then
            if UModule.env[a1] and type(UModule.env[a1]) == "table" and a3 then
                return UModule.env[a1][a3]
            end
            return UModule.env[a1]
        end
        
        if a2 == "merge" and type(a3) == "table" then
            if not UModule.env[a1] then 
                UModule.env[a1] = {} 
            end
            if type(UModule.env[a1]) == "table" then
                for k, v in pairs(a3) do
                    UModule.env[a1][k] = v
                end
            end
            return true
        end
        
        if a3 ~= nil then
            if not UModule.env[a1] then UModule.env[a1] = {} end
            if type(UModule.env[a1]) ~= "table" then UModule.env[a1] = {} end
            UModule.env[a1][a2] = a3
            return true
        else
            UModule.env[a1] = a2
            return true
        end
    end
    
    return nil
end

getgenv().var = UModule.var

UModule.tm = {}

function UModule.tm.Add(tbl, key, value)
    if type(tbl) ~= "table" or key == nil then return false end
    
    if value ~= nil then
        tbl[key] = value
    else
        for _, v in pairs(tbl) do
            if v == key then return true end
        end
        table.insert(tbl, key)
    end
    
    return true
end

function UModule.tm.Find(tbl, key)
    if type(tbl) ~= "table" or key == nil then return nil end
    if tbl[key] ~= nil then return tbl[key] end
    
    for i, v in pairs(tbl) do
        if v == key then return i, v end
    end
    
    return nil
end

function UModule.tm.val(tbl, key)
    if type(tbl) ~= "table" or key == nil then return false end
    
    local value = tbl[key]
    
    if value == nil then
        for _, v in pairs(tbl) do
            if v == key then return true end
        end
        return false
    end
    
    return type(value) == "boolean" and value or (value ~= nil and value ~= false)
end

function UModule.tm.Remove(tbl, key)
    if type(tbl) ~= "table" or key == nil then return false end
    
    if tbl[key] ~= nil then
        tbl[key] = nil
        return true
    end
    
    for i, v in pairs(tbl) do
        if v == key then
            if type(i) == "number" then
                table.remove(tbl, i)
            else
                tbl[i] = nil
            end
            return true
        end
    end
    
    return false
end

function UModule.tm.Clear(tbl)
    if type(tbl) ~= "table" then return false end
    for k in pairs(tbl) do tbl[k] = nil end
    return true
end

function UModule.wfc(...)
    local args = {...}
    local name, parent, timeout
    
    for _, arg in ipairs(args) do
        local t = type(arg)
        if t == "string" then
            name = arg
        elseif t == "number" then
            timeout = arg
        elseif typeof(arg) == "Instance" then
            parent = arg
        end
    end
    
    if not name then return nil end
    
    parent = parent or UModule.env.ov.char
    
    if not timeout then
        local child
        repeat
            child = parent:FindFirstChild(name)
            if child then return child end
            task.wait()
        until child
        return child
    end
    
    local startTime = tick()
    local child
    
    repeat
        child = parent:FindFirstChild(name)
        if child then return child end
        task.wait()
    until (tick() - startTime) >= timeout
    
    return nil
end

function UModule.cm(...)
    local args = {...}
    
    if #args == 2 and type(args[1]) == "string" then
        local cmd = args[2]
        local name = args[1]
        
        if cmd == "disc" or cmd == "disconnect" then
            if UModule.env.Connections[name] then
                pcall(function()
                    UModule.env.Connections[name]:Disconnect()
                end)
                UModule.env.Connections[name] = nil
            end
            return
        end
        
        if cmd == "pause" then
            if UModule.env.Connections[name] then
                UModule.env.Connections[name]._paused = true
            end
            return
        end
        
        if cmd == "resume" then
            if UModule.env.Connections[name] then
                UModule.env.Connections[name]._paused = false
            end
            return
        end
        
        if cmd == "status" then
            if not UModule.env.Connections[name] then
                return "none"
            end
            if UModule.env.Connections[name]._paused then
                return "paused"
            end
            return "active"
        end
    end
    
    local inst, cback, name, stgs, ttle, once = nil, nil, nil, {}, nil, false
    local madd = false
    
    local function gfstr(func)
        local info = debug.getinfo(func, "S")
        if info then
            local src = (info.source or "unknown"):gsub("^@", "")
            return src .. ":" .. (info.linedefined or 0) .. "-" .. (info.lastlinedefined or info.linedefined or 0)
        end
        return tostring(func)
    end
    
    for _, arg in ipairs(args) do
        local t = type(arg)
        if typeof(arg) == "Instance" then
            inst = arg
        elseif t == "function" then
            cback = arg
        elseif t == "string" then
            if arg == "Add" then
                madd = true
            elseif arg == "once" or arg == "Once" then
                once = true
            else
                table.insert(stgs, arg)
            end
        elseif t == "number" then
            ttle = arg
        elseif t == "table" then
            ttle = arg
        end
    end
    
    if madd then
        local cname = stgs[1]
        if not cname or not UModule.env.Connections[cname] then
            return
        end
        
        if not cback then
            return
        end
        
        table.insert(UModule.env.Connections[cname]._cbacks, {func = cback, once = once})
        return UModule.env.Connections[cname]
    end
    
    if not inst or not cback then return end
    
    local event = stgs[1]
    local prop = nil
    
    if not event then
        name = stgs[2] or tostring(inst) .. "_Destroying_" .. gfstr(cback)
        
        if UModule.env.Connections[name] then
            UModule.env.Connections[name] = nil
        end
        
        local conn = inst.Destroying:Connect(cback)
        
        UModule.env.Connections[name] = {
            connection = conn,
            inst = inst,
            eventType = "Destroying",
            _cbacks = {{func = cback, once = once}},
            _funcString = gfstr(cback),
            _paused = false,
            Disconnect = function(self)
                if self.connection then
                    pcall(function() self.connection:Disconnect() end)
                    self.connection = nil
                    UModule.env.Connections[name] = nil
                end
            end
        }
        
        return UModule.env.Connections[name]
    end
    
    if event == "PropertyChanged" and #stgs >= 2 then
        prop = stgs[2]
        name = stgs[3]
    else
        name = stgs[2]
    end
    
    local fstr = gfstr(cback)
    
    if not name then
        name = tostring(inst) .. "_" .. tostring(event)
        if prop then name = name .. "_" .. prop end
        name = name .. "_" .. fstr
    end
    
    if UModule.env.Connections[name] then
        if UModule.env.Connections[name]._funcString ~= fstr then
            name = name .. "_" .. tick()
        else
            UModule.env.Connections[name] = nil
        end
    end
    
    local counter = 0
    
    local function rcbs(...)
        local connData = UModule.env.Connections[name]
        if not connData then return end
        
        if connData._paused then
            return
        end
        
        if ttle then
            counter = counter + 1
            local tthVal
            if type(ttle) == "table" then
                tthVal = ttle.ref and ttle.ref[ttle.key] or ttle
            else
                tthVal = ttle
            end
            if counter < tthVal then
                return
            end
            counter = 0
        end
        
        local callbacksCopy = {}
        for i, cbEntry in ipairs(connData._cbacks) do
            table.insert(callbacksCopy, {index = i, entry = cbEntry})
        end
        
        local toRemove = {}
        for _, cbData in ipairs(callbacksCopy) do
            local success = pcall(function()
                cbData.entry.func(...)
            end)
            
            if cbData.entry.once then
                table.insert(toRemove, cbData.index)
            end
        end
        
        for i = #toRemove, 1, -1 do
            local idx = toRemove[i]
            if connData._cbacks[idx] then
                table.remove(connData._cbacks, idx)
            end
        end
        
        if once then
            task.defer(function()
                if UModule.env.Connections[name] then
                    pcall(function()
                        UModule.env.Connections[name]:Disconnect()
                    end)
                end
            end)
        end
    end
    
    local connection
    local success = pcall(function()
        if event == "PropertyChanged" then
            connection = inst:GetPropertyChangedSignal(prop):Connect(rcbs)
        else
            local evt = inst[event]
            if evt and typeof(evt) == "RBXScriptSignal" then
                connection = evt:Connect(rcbs)
            end
        end
    end)
    
    if not success then return end
    
    task.spawn(function()
        inst.Destroying:Connect(function()
            if connection then
                connection:Disconnect()
                connection = nil
                if UModule.env.Connections[name] then
                    UModule.env.Connections[name] = nil
                end
            end
        end)
    end)
    
    UModule.env.Connections[name] = {
        connection = connection,
        inst = inst,
        eventType = event,
        propName = prop,
        _cbacks = {{func = cback, once = once}},
        _funcString = fstr,
        _paused = false,
        ttle = ttle,
        Disconnect = function(self)
            if self.connection then
                pcall(function() self.connection:Disconnect() end)
                self.connection = nil
                UModule.env.Connections[name] = nil
            end
        end
    }
    
    return UModule.env.Connections[name]
end

return UModule
