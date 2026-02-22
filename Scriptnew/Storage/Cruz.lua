function FormCruz(x, y, z)
    local ws = workspace.Anti_CheatbfSpawnedInToys
    local m1p1 = ws:GetChildren()[3]:GetChildren()[9]
    local m1p2 = ws:GetChildren()[3].SoundPart
    local m2p1 = ws.LadderLightBrown:GetChildren()[9]
    local m2p2 = ws.LadderLightBrown.SoundPart
    
    m1p1.CanCollide = false
    m1p2.CanCollide = false
    m2p1.CanCollide = false
    m2p2.CanCollide = false
    
    local c1 = m1p1.CFrame:Lerp(m1p2.CFrame, 0.5)
    local c2 = m2p1.CFrame:Lerp(m2p2.CFrame, 0.5)
    local d1 = (m1p1.Position - c1.Position).Magnitude
    local d2 = (m2p1.Position - c2.Position).Magnitude
    
    local nc1 = CFrame.new(x, y, z)
    m1p1.CFrame = nc1 * CFrame.new(0, d1, 0)
    m1p2.CFrame = nc1 * CFrame.new(0, -d1, 0)
    
    local nc2 = CFrame.new(x, y + 3.5, z) * CFrame.Angles(0, 0, math.rad(90))
    m2p1.CFrame = nc2 * CFrame.new(0, d2, 0)
    m2p2.CFrame = nc2 * CFrame.new(0, -d2, 0)
    
---@diagnostic disable-next-line: undefined-global
    function SetBP(p)
        local bp = p:FindFirstChild("BodyPosition") or Instance.new("BodyPosition", p)
        bp.Position = p.Position
        bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bp.P = 10000
        bp.D = 1000
    end
---@diagnostic disable-next-line: undefined-global
    function SetBG(p)
        local bg = p:FindFirstChild("BodyGyro") or Instance.new("BodyGyro", p)
        bg.CFrame = p.CFrame
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.P = 10000
        bg.D = 1000
    end
    
    for _, p in pairs({m1p1, m1p2, m2p1, m2p2}) do
        SetBP(p)
        SetBG(p)
    end
end
--[[
local ws = workspace.Anti_CheatbfSpawnedInToys
local m1p1 = ws:GetChildren()[3]:GetChildren()[9]
local m1p2 = ws:GetChildren()[3].SoundPart
local m2p1 = ws.LadderLightBrown:GetChildren()[9]
local m2p2 = ws.LadderLightBrown.SoundPart

local c1 = m1p1.CFrame:Lerp(m1p2.CFrame, 0.5)
local c2 = m2p1.CFrame:Lerp(m2p2.CFrame, 0.5)
local px = (c1.Position.X + c2.Position.X) / 2
local pz = (c1.Position.Z + c2.Position.Z) / 2
local py = c1.Position.Y + 10

FormCruz(px, py, pz)
]]--

---@diagnostic disable-next-line: undefined-global
KeyTab:AddPbind({
    Name = "Position",
    DefaultX = "0",
    DefaultY = "10",
    DefaultZ = "5",
    Callback = function(x, y, z)
        --[[
        local nx = tonumber(x) or 0
        local ny = tonumber(y) or 10
        local nz = tonumber(z) or 5
        FormCruz(nx, ny, nz)
        ]]--
    end
})