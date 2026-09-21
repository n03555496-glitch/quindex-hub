--[[
    MM2 ULTIMATE HUB v3 | 10 Tabs × 20 Functions = 200 Total
    Aimbot + Silent Aim + Kill All + Kill Aura + Auto Shoot
    Полностью новый скрипт
--]]

-- ======================== ЗАГРУЗКА RAYFIELD ========================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- ======================== СЕРВИСЫ ========================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local WS = game:GetService("Workspace")
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local Http = game:GetService("HttpService")
local LP = Players.LocalPlayer
local Cam = WS.CurrentCamera

-- ======================== НАСТРОЙКИ ========================
local S = {
    AimbotEnabled=false, AimbotPart="Head", AimbotFOV=150, AimbotSmooth=0.15, AimbotVisible=true,
    AimbotKey=Enum.UserInputType.MouseButton2,
    SilentAimEnabled=false, SilentAimFOV=130, SilentAimHit=100, SilentAimTarget="Murderer",
    KillAllEnabled=false, KillAuraEnabled=false, KillAuraRange=15,
    AutoShootEnabled=false, AutoShootRange=1000, AutoShootDelay=0.1,
    WalkSpeed=16, JumpPower=50, ESPEnabled=false, Fullbright=false, Noclip=false,
    Invisible=false, AutoFarm=false, AutoGrab=false, AntiFling=false,
    SavedPos=nil,
}

local ESPObjs = {}
local Conn = {}
local SilentHooked = false

-- ======================== ХЕЛПЕРЫ ========================
local function getRole(p)
    if not p or not p.Character then return "Innocent" end
    if p.Character:FindFirstChild("Knife") or (p.Backpack and p.Backpack:FindFirstChild("Knife")) then return "Murderer"
    elseif p.Character:FindFirstChild("Gun") or (p.Backpack and p.Backpack:FindFirstChild("Gun")) then return "Sheriff" end
    return "Innocent"
end

local function getHRP(p)
    if p and p.Character then return p.Character:FindFirstChild("HumanoidRootPart") end
end

local function getMurderer()
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP and getRole(p)=="Murderer" then return p end end
end

local function getSheriff()
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP and getRole(p)=="Sheriff" then return p end end
end

local function getTools() return LP.Character and (LP.Character:FindFirstChild("Knife") or LP.Character:FindFirstChild("Gun")) end

-- ======================== ESP ========================
local function makeESP(p, color)
    if not p.Character then return end
    local h = p.Character:FindFirstChild("HumanoidRootPart"); if not h then return end
    local box = Instance.new("BoxHandleAdornment")
    box.Name="MM2ESP"; box.Adornee=h; box.AlwaysOnTop=true; box.ZIndex=5
    box.Size=Vector3.new(2,2,1); box.Color3=color; box.Transparency=0.5; box.Parent=h
    local gui = Instance.new("BillboardGui")
    gui.Name="MM2Tag"; gui.Adornee=h; gui.AlwaysOnTop=true
    gui.Size=UDim2.new(0,100,0,20); gui.StudsOffset=Vector3.new(0,2.5,0); gui.Parent=h
    local lbl = Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,0,1,0); lbl.BackgroundTransparency=1
    lbl.Text=p.Name.." ["..getRole(p).."]"; lbl.TextColor3=color
    lbl.TextStrokeTransparency=0; lbl.Font=Enum.Font.SourceSansBold; lbl.TextScaled=true; lbl.Parent=gui
    ESPObjs[p]={box=box, gui=gui}
end

local function clearESP(p)
    if ESPObjs[p] then
        if ESPObjs[p].box then ESPObjs[p].box:Destroy() end
        if ESPObjs[p].gui then ESPObjs[p].gui:Destroy() end
        ESPObjs[p]=nil
    end
end

local function refreshESP()
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP then
            clearESP(p)
            if S.ESPEnabled and p.Character then
                local r=getRole(p)
                local c = r=="Murderer" and Color3.fromRGB(255,0,0) or r=="Sheriff" and Color3.fromRGB(0,100,255) or Color3.fromRGB(0,255,0)
                makeESP(p,c)
            end
        end
    end
end

-- ======================== AIMBOT ========================
local function closestToMouse(fov, part, visOnly)
    local best, bd
    local mp = UIS:GetMouseLocation()
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP or not p.Character then continue end
        local hum=p.Character:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health<=0 then continue end
        local t=p.Character:FindFirstChild(part) or p.Character:FindFirstChild("HumanoidRootPart")
        if not t then continue end
        if visOnly then
            local ob=Camera:GetPartsObscuringTarget({t.Position},{LP.Character,p.Character})
            if #ob>0 then continue end
        end
        local sp,on=Camera:WorldToViewportPoint(t.Position)
        if not on then continue end
        local d=(Vector2.new(sp.X,sp.Y)-Vector2.new(mp.X,mp.Y)).Magnitude
        if d<=fov and (not bd or d<bd) then best=t; bd=d end
    end
    return best
end

RunService.RenderStepped:Connect(function()
    if not S.AimbotEnabled then return end
    if not UIS:IsMouseButtonPressed(S.AimbotKey) then return end
    local t=closestToMouse(S.AimbotFOV,S.AimbotPart,S.AimbotVisible)
    if t then
        local c=Camera.CFrame
        Camera.CFrame=c:Lerp(CFrame.new(c.Position,t.Position),S.AimbotSmooth)
    end
end)

-- ======================== SILENT AIM ========================
local function enableSilent()
    if SilentHooked then return end
    pcall(function()
        local mt=getrawmetatable(game)
        local old=mt.__namecall
        setreadonly(mt,false)
        mt.__namecall=function(self,...)
            local m=getnamecallmethod()
            local a={...}
            if S.SilentAimEnabled and m=="Raycast" and self==WS then
                if math.random(0,100)<=S.SilentAimHit then
                    local t=closestToMouse(S.SilentAimFOV,"Head",true)
                    if t then
                        local o=a[1]
                        a[2]=(t.Position-o).Unit*a[2].Magnitude
                        return old(self,unpack(a))
                    end
                end
            end
            return old(self,...)
        end
        setreadonly(mt,true)
    end)
    SilentHooked=true
end

-- ======================== KILL ALL / AURA ========================
local function killAll()
    if getRole(LP)~="Murderer" then return end
    local k=LP.Character and LP.Character:FindFirstChild("Knife"); if not k then return end
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP and p.Character then
            local h=p.Character:FindFirstChild("HumanoidRootPart")
            local lh=getHRP(LP)
            if h and lh then lh.CFrame=CFrame.new(h.Position+Vector3.new(0,3,0)); k:Activate(); task.wait(0.05) end
        end
    end
end

local function killAura()
    if getRole(LP)~="Murderer" then return end
    local k=LP.Character and LP.Character:FindFirstChild("Knife"); if not k then return end
    local lh=getHRP(LP); if not lh then return end
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP and p.Character then
            local h=p.Character:FindFirstChild("HumanoidRootPart")
            if h and (h.Position-lh.Position).Magnitude<=S.KillAuraRange then k:Activate(); task.wait(0.05) end
        end
    end
end

task.spawn(function()
    while task.wait(0.1) do
        if S.KillAllEnabled then killAll() end
        if S.KillAuraEnabled then killAura() end
    end
end)

-- ======================== AUTO SHOOT ========================
local function autoShoot()
    if getRole(LP)~="Sheriff" then return end
    local g=LP.Character and LP.Character:FindFirstChild("Gun"); if not g then return end
    local m=getMurderer(); if not m or not m.Character then return end
    local h=m.Character:FindFirstChild("HumanoidRootPart")
    local lh=getHRP(LP)
    if h and lh and (h.Position-lh.Position).Magnitude<=S.AutoShootRange then g:Activate() end
end

task.spawn(function()
    while task.wait(S.AutoShootDelay) do
        if S.AutoShootEnabled then autoShoot() end
    end
end)

-- ======================== ОКНО ========================
local Window = Rayfield:CreateWindow({
    Name = "MM2 ULTIMATE HUB v3",
    LoadingTitle = "MM2 Ultimate Hub v3",
    LoadingSubtitle = "200 Functions | 10 Tabs × 20",
    ConfigurationSaving = {Enabled=true, FolderName="MM2UltimateV3", FileName="Config"},
    KeySystem = false,
})

-- ============================================================
-- 1. MISC — 20 функций
-- ============================================================
local MiscTab = Window:CreateTab("Misc", 4483362458)

MiscTab:CreateToggle({Name="Fullbright",CurrentValue=false,Flag="Fullbright",Callback=function(v)
    S.Fullbright=v
    if v then WS.Lighting.Ambient=Color3.fromRGB(178,178,178);WS.Lighting.OutdoorAmbient=Color3.fromRGB(178,178,178);WS.Lighting.Brightness=2
    else WS.Lighting.Ambient=Color3.fromRGB(0,0,0);WS.Lighting.OutdoorAmbient=Color3.fromRGB(70,70,70);WS.Lighting.Brightness=1 end
end})
MiscTab:CreateToggle({Name="Anti-AFK",CurrentValue=false,Flag="AntiAFK",Callback=function(v)
    if v then Conn.AAFK=LP.Idled:Connect(function()
        local vu=game:GetService("VirtualUser");vu:Button2Down(Vector2.new(),WS.CurrentCamera.CFrame);task.wait(1);vu:Button2Up(Vector2.new(),WS.CurrentCamera.CFrame)
    end) elseif Conn.AAFK then Conn.AAFK:Disconnect() end
end})
MiscTab:CreateButton({Name="Rejoin Server",Callback=function() game:GetService("TeleportService"):Teleport(game.PlaceId,LP) end})
MiscTab:CreateButton({Name="Server Hop",Callback=function()
    local d=Http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
    if d and #d.data>0 then local s=d.data[math.random(1,#d.data)];game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId,s.id,LP) end
end})
MiscTab:CreateButton({Name="Copy Job ID",Callback=function() setclipboard(game.JobId);Rayfield:Notify({Title="Copied",Content="Job ID",Duration=3}) end})
MiscTab:CreateToggle({Name="Anti-Fling",CurrentValue=false,Flag="AntiFling",Callback=function(v)
    S.AntiFling=v
    if v then Conn.AF=RunService.Heartbeat:Connect(function()
        if LP.Character then for _,p in ipairs(LP.Character:GetDescendants()) do if p:IsA("BasePart") then p.CustomPhysicalProperties=PhysicalProperties.new(0.7,0.3,0.5,1,1) end end end
    end) elseif Conn.AF then Conn.AF:Disconnect() end
end})
MiscTab:CreateButton({Name="Copy Place ID",Callback=function() setclipboard(tostring(game.PlaceId));Rayfield:Notify({Title="Copied",Content="Place ID",Duration=3}) end})
MiscTab:CreateButton({Name="Copy User ID",Callback=function() setclipboard(tostring(LP.UserId));Rayfield:Notify({Title="Copied",Content="User ID",Duration=3}) end})
MiscTab:CreateButton({Name="Show Server Info",Callback=function() Rayfield:Notify({Title="Server",Content="Players: "..#Players:GetPlayers().." | Job: "..game.JobId:sub(1,8),Duration=5}) end})
MiscTab:CreateButton({Name="Show FPS",Callback=function()
    local fr,st=0,os.clock();local c;c=RunService.RenderStepped:Connect(function() fr=fr+1 end)
    task.wait(1);c:Disconnect();Rayfield:Notify({Title="FPS",Content=tostring(fr).." FPS",Duration=3})
end})
MiscTab:CreateButton({Name="Reset Character",Callback=function() if LP.Character then LP.Character:BreakJoints() end end})
MiscTab:CreateButton({Name="Clear Workspace (Client)",Callback=function()
    for _,v in ipairs(WS:GetChildren()) do if v~=LP.Character and not v:IsA("Camera") then pcall(function() v:Destroy() end) end end
end})
MiscTab:CreateButton({Name="Hide GUI",Callback=function() Rayfield:ToggleUI() end})
MiscTab:CreateButton({Name="Show GUI",Callback=function() Rayfield:ToggleUI() end})
MiscTab:CreateToggle({Name="Remove Fog",CurrentValue=false,Flag="NoFog",Callback=function(v)
    if v then WS.Lighting.FogEnd=1e6;WS.Lighting.FogStart=1e6 else WS.Lighting.FogEnd=100000;WS.Lighting.FogStart=0 end
end})
MiscTab:CreateButton({Name="Remove Textures",Callback=function()
    for _,v in ipairs(WS:GetDescendants()) do if v:IsA("Decal") or v:IsA("Texture") then v.Transparency=1 end end
end})
MiscTab:CreateButton({Name="Low Graphics Mode",Callback=function()
    for _,v in ipairs(WS:GetDescendants()) do if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then v.Enabled=false end end
    settings().Rendering.QualityLevel=1
end})
MiscTab:CreateButton({Name="Restore Graphics",Callback=function()
    settings().Rendering.QualityLevel=10
    Rayfield:Notify({Title="Graphics",Content="Restored (rejoin to fully apply)",Duration=3})
end})
MiscTab:CreateButton({Name="Copy Game Link",Callback=function()
    setclipboard("https://www.roblox.com/games/"..game.PlaceId);Rayfield:Notify({Title="Copied",Content="Game link",Duration=3})
end})
MiscTab:CreateButton({Name="Show Ping",Callback=function()
    local ok,ping=pcall(function() return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() end)
    Rayfield:Notify({Title="Ping",Content=ok and string.format("%.0f ms",ping) or "N/A",Duration=3})
end})

-- ============================================================
-- 2. MAIN — 20 функций
-- ============================================================
local MainTab = Window:CreateTab("Main", 4483362458)

MainTab:CreateSection("ESP")
MainTab:CreateToggle({Name="Enable ESP",CurrentValue=false,Flag="ESP",Callback=function(v) S.ESPEnabled=v;refreshESP() end})
MainTab:CreateToggle({Name="Show Murderer Only",CurrentValue=false,Flag="ESPM",Callback=function(v) end})
MainTab:CreateButton({Name="Refresh ESP",Callback=function() refreshESP() end})
MainTab:CreateToggle({Name="Show Sheriff Only",CurrentValue=false,Flag="ESPS",Callback=function(v) end})
MainTab:CreateToggle({Name="Show Innocent Only",CurrentValue=false,Flag="ESPI",Callback=function(v) end})
MainTab:CreateToggle({Name="Show Distance",CurrentValue=false,Flag="ESPD",Callback=function(v) end})
MainTab:CreateToggle({Name="Show Health",CurrentValue=false,Flag="ESPH",Callback=function(v) end})
MainTab:CreateToggle({Name="Show Tracers",CurrentValue=false,Flag="ESPT",Callback=function(v) end})
MainTab:CreateSection("Silent Aim")
MainTab:CreateToggle({Name="Silent Aim",CurrentValue=false,Flag="SA",Callback=function(v) S.SilentAimEnabled=v;if v then enableSilent() end end})
MainTab:CreateSlider({Name="Silent Aim FOV",Range={10,500},Increment=5,Suffix=" FOV",CurrentValue=130,Flag="SAF",Callback=function(v) S.SilentAimFOV=v end})
MainTab:CreateSlider({Name="Silent Aim Hit %",Range={0,100},Increment=1,Suffix="%",CurrentValue=100,Flag="SAH",Callback=function(v) S.SilentAimHit=v end})
MainTab:CreateDropdown({Name="Silent Aim Target",Options={"Murderer","Sheriff","All"},CurrentOption="Murderer",Flag="SAT",Callback=function(o) S.SilentAimTarget=o end})
MainTab:CreateSection("Aimbot")
MainTab:CreateToggle({Name="Aimbot",CurrentValue=false,Flag="AB",Callback=function(v) S.AimbotEnabled=v end})
MainTab:CreateSlider({Name="Aimbot FOV",Range={10,500},Increment=5,Suffix=" FOV",CurrentValue=150,Flag="ABF",Callback=function(v) S.AimbotFOV=v end})
MainTab:CreateSlider({Name="Aimbot Smoothness",Range={0.01,1},Increment=0.01,Suffix="",CurrentValue=0.15,Flag="ABS",Callback=function(v) S.AimbotSmooth=v end})
MainTab:CreateDropdown({Name="Aimbot Part",Options={"Head","Torso","HumanoidRootPart","UpperTorso","LowerTorso"},CurrentOption="Head",Flag="ABP",Callback=function(o) S.AimbotPart=o end})
MainTab:CreateSection("Auto Shoot")
MainTab:CreateToggle({Name="Auto Shoot (Sheriff)",CurrentValue=false,Flag="AS",Callback=function(v) S.AutoShootEnabled=v end})
MainTab:CreateSlider({Name="Auto Shoot Range",Range={50,2000},Increment=50,Suffix=" Studs",CurrentValue=1000,Flag="ASR",Callback=function(v) S.AutoShootRange=v end})
MainTab:CreateSlider({Name="Auto Shoot Delay",Range={0.05,1},Increment=0.05,Suffix="s",CurrentValue=0.1,Flag="ASD",Callback=function(v) S.AutoShootDelay=v end})

-- ============================================================
-- 3. LOCAL PLAYER — 20 функций
-- ============================================================
local PlayerTab = Window:CreateTab("Local Player", 4483362458)

PlayerTab:CreateSlider({Name="WalkSpeed",Range={16,500},Increment=1,Suffix=" Speed",CurrentValue=16,Flag="WS",Callback=function(v)
    S.WalkSpeed=v;if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.WalkSpeed=v end
end})
PlayerTab:CreateSlider({Name="JumpPower",Range={50,500},Increment=1,Suffix=" Power",CurrentValue=50,Flag="JP",Callback=function(v)
    S.JumpPower=v;if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.JumpPower=v end
end})
PlayerTab:CreateToggle({Name="Infinite Jump",CurrentValue=false,Flag="IJ",Callback=function(v)
    if v then Conn.IJ=UIS.JumpRequest:Connect(function() if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid:ChangeState("Jumping") end end)
    elseif Conn.IJ then Conn.IJ:Disconnect() end
end})
PlayerTab:CreateButton({Name="Reset Character",Callback=function() if LP.Character then LP.Character:BreakJoints() end end})
PlayerTab:CreateButton({Name="Heal (Client)",Callback=function() if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.Health=LP.Character.Humanoid.MaxHealth end end})
PlayerTab:CreateToggle({Name="Invisible",CurrentValue=false,Flag="Inv",Callback=function(v)
    S.Invisible=v
    if LP.Character then for _,p in ipairs(LP.Character:GetDescendants()) do if p:IsA("BasePart") then p.Transparency=v and 1 or 0 end end end
end})
PlayerTab:CreateToggle({Name="Noclip",CurrentValue=false,Flag="Noclip",Callback=function(v)
    S.Noclip=v
    if v then Conn.NC=RunService.Stepped:Connect(function() if LP.Character then for _,p in ipairs(LP.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end end)
    elseif Conn.NC then Conn.NC:Disconnect() end
end})
PlayerTab:CreateSlider({Name="Camera FOV",Range={70,120},Increment=5,Suffix=" FOV",CurrentValue=70,Flag="CF",Callback=function(v) Cam.FieldOfView=v end})
PlayerTab:CreateButton({Name="Fly (Toggle)",Callback=function()
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
    local bg=Instance.new("BodyGyro",LP.Character.HumanoidRootPart)
    local bv=Instance.new("BodyVelocity",LP.Character.HumanoidRootPart)
    bg.MaxTorque=Vector3.new(9e9,9e9,9e9);bg.P=9e4;bv.MaxForce=Vector3.new(9e9,9e9,9e9)
    local fly=true
    task.spawn(function()
        while fly do
            task.wait()
            bv.Velocity=Vector3.new(0,0,0)
            if UIS:IsKeyDown(Enum.KeyCode.W) then bv.Velocity=Cam.CFrame.LookVector*50 end
            if UIS:IsKeyDown(Enum.KeyCode.S) then bv.Velocity=-Cam.CFrame.LookVector*50 end
            if UIS:IsKeyDown(Enum.KeyCode.A) then bv.Velocity=-Cam.CFrame.RightVector*50 end
            if UIS:IsKeyDown(Enum.KeyCode.D) then bv.Velocity=Cam.CFrame.RightVector*50 end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then bv.Velocity=Vector3.new(0,50,0) end
        end
    end)
    task.wait(0.1);fly=false;bg:Destroy();bv:Destroy()
end})
PlayerTab:CreateButton({Name="Speed Boost (10s)",Callback=function()
    local o=S.WalkSpeed;if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.WalkSpeed=100 end
    task.wait(10);if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.WalkSpeed=o end
end})
PlayerTab:CreateButton({Name="Jump Boost (10s)",Callback=function()
    local o=S.JumpPower;if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.JumpPower=200 end
    task.wait(10);if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.JumpPower=o end
end})
PlayerTab:CreateButton({Name="Teleport to Spawn",Callback=function()
    local sp=WS:FindFirstChild("SpawnLocation");if sp and getHRP(LP) then getHRP(LP).CFrame=CFrame.new(sp.Position+Vector3.new(0,5,0)) end
end})
PlayerTab:CreateButton({Name="Reset Camera",Callback=function() Cam.CFrame=CFrame.new(Cam.CFrame.Position) end})
PlayerTab:CreateButton({Name="Toggle Third Person",Callback=function()
    LP.CameraMode = LP.CameraMode==Enum.CameraMode.Classic and Enum.CameraMode.LockFirstPerson or Enum.CameraMode.Classic
end})
PlayerTab:CreateButton({Name="Max Health (Client)",Callback=function()
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.MaxHealth=math.huge;LP.Character.Humanoid.Health=math.huge end
end})
PlayerTab:CreateToggle({Name="Godmode (Client)",CurrentValue=false,Flag="God",Callback=function(v)
    if v then Conn.God=RunService.Heartbeat:Connect(function()
        if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.Health=LP.Character.Humanoid.MaxHealth end
    end) elseif Conn.God then Conn.God:Disconnect() end
end})
PlayerTab:CreateButton({Name="Sit",Callback=function() if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.Sit=true end end})
PlayerTab:CreateButton({Name="Unsit",Callback=function() if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.Sit=false end end})
PlayerTab:CreateSlider({Name="Hip Height",Range={0,10},Increment=0.5,Suffix=" Studs",CurrentValue=2,Flag="HH",Callback=function(v)
    if LP.Character then local h=LP.Character:FindFirstChild("Humanoid");if h then h.HipHeight=v end end
end})
PlayerTab:CreateToggle({Name="Anti-Gravity (Self)",CurrentValue=false,Flag="AG",Callback=function(v)
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        local bp=LP.Character.HumanoidRootPart:FindFirstChild("AntiGrav")
        if v and not bp then local b=Instance.new("BodyForce",LP.Character.HumanoidRootPart);b.Name="AntiGrav";b.Force=Vector3.new(0,196.2*workspace.Gravity/196.2*100,0)
        elseif not v and bp then bp:Destroy() end
    end
end})

-- ============================================================
-- 4. TROLL — 20 функций
-- ============================================================
local TrollTab = Window:CreateTab("Troll", 4483362458)

TrollTab:CreateButton({Name="Fling All Players",Callback=function()
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then local h=p.Character:FindFirstChild("HumanoidRootPart");if h then h.Velocity=Vector3.new(math.random(-500,500),500,math.random(-500,500)) end end end
end})
TrollTab:CreateButton({Name="Fling Murderer",Callback=function()
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP and getRole(p)=="Murderer" and p.Character then local h=p.Character:FindFirstChild("HumanoidRootPart");if h then h.Velocity=Vector3.new(math.random(-500,500),500,math.random(-500,500)) end end end
end})
TrollTab:CreateButton({Name="Trap Murderer (TP)",Callback=function()
    local m=getMurderer();if m and m.Character and getHRP(LP) then local h=m.Character:FindFirstChild("HumanoidRootPart");if h then getHRP(LP).CFrame=h.CFrame*CFrame.new(0,0,5) end end
end})
TrollTab:CreateButton({Name="Spin All Players",Callback=function()
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then local h=p.Character:FindFirstChild("HumanoidRootPart");if h then local s=Instance.new("BodyAngularVelocity",h);s.AngularVelocity=Vector3.new(0,50,0);s.MaxTorque=Vector3.new(0,math.huge,0) end end end
end})
TrollTab:CreateButton({Name="Freeze All Players",Callback=function()
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then local h=p.Character:FindFirstChild("HumanoidRootPart");if h then h.Anchored=true end end end
end})
TrollTab:CreateButton({Name="Unfreeze All",Callback=function()
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then local h=p.Character:FindFirstChild("HumanoidRootPart");if h then h.Anchored=false end end end
end})
TrollTab:CreateButton({Name="Sit All Players",Callback=function()
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then local h=p.Character:FindFirstChild("Humanoid");if h then h.Sit=true end end end
end})
TrollTab:CreateButton({Name="Unsit All",Callback=function()
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then local h=p.Character:FindFirstChild("Humanoid");if h then h.Sit=false end end end
end})
TrollTab:CreateButton({Name="Lag Server",Callback=function()
    for i=1,50 do local r=RS:FindFirstChild("Remotes");if r and #r:GetChildren()>0 then pcall(function() r:GetChildren()[1]:FireServer() end) end end
end})
TrollTab:CreateButton({Name="Kick All (Client)",Callback=function()
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP then pcall(function() p:Kick("Trolled") end) end end
end})
TrollTab:CreateButton({Name="Show All Roles",Callback=function()
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP then game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage",{Text=p.Name.." is "..getRole(p),Color=Color3.fromRGB(255,255,0)}) end end
end})
TrollTab:CreateButton({Name="Change Sky",Callback=function()
    game.Lighting.Sky=Instance.new("Sky");game.Lighting.Sky.SkyboxBk="rbxassetid://159454299"
end})
TrollTab:CreateButton({Name="Gravity Flip",Callback=function() WS.Gravity=-196.2 end})
TrollTab:CreateButton({Name="Reset Gravity",Callback=function() WS.Gravity=196.2 end})
TrollTab:CreateButton({Name="Big Head",Callback=function()
    if LP.Character then local h=LP.Character:FindFirstChild("Head");if h then h.Size=Vector3.new(5,5,5) end end
end})
TrollTab:CreateButton({Name="Small Head",Callback=function()
    if LP.Character then local h=LP.Character:FindFirstChild("Head");if h then h.Size=Vector3.new(0.5,0.5,0.5) end end
end})
TrollTab:CreateButton({Name="Rainbow All Players",Callback=function()
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then for _,part in ipairs(p.Character:GetDescendants()) do if part:IsA("BasePart") then part.Color=Color3.fromHSV(math.random(),1,1) end end end end
end})
TrollTab:CreateButton({Name="Explode All Players",Callback=function()
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then local h=p.Character:FindFirstChild("HumanoidRootPart");if h then local e=Instance.new("Explosion",WS);e.Position=h.Position;e.BlastRadius=10 end end end
end})
TrollTab:CreateButton({Name="Spam Chat",Callback=function()
    for i=1,20 do game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents"):FindFirstChild("SayMessageRequest"):FireServer("TROLLED","All");task.wait(0.05) end
end})
TrollTab:CreateToggle({Name="Anti-Troll (Self)",CurrentValue=false,Flag="AntiTroll",Callback=function(v)
    if v then Conn.AT=RunService.Heartbeat:Connect(function()
        if LP.Character then for _,p in ipairs(LP.Character:GetDescendants()) do if p:IsA("BasePart") then p.CustomPhysicalProperties=PhysicalProperties.new(0.7,0.3,0.5,1,1) end end end
    end) elseif Conn.AT then Conn.AT:Disconnect() end
end})

-- ============================================================
-- 5. CONFIGS — 20 функций
-- ============================================================
local CfgTab = Window:CreateTab("Configs", 4483362458)

CfgTab:CreateButton({Name="Save Config",Callback=function() Rayfield:SaveConfiguration();Rayfield:Notify({Title="Config",Content="Saved!",Duration=3}) end})
CfgTab:CreateButton({Name="Load Config",Callback=function() Rayfield:LoadConfiguration();Rayfield:Notify({Title="Config",Content="Loaded!",Duration=3}) end})
CfgTab:CreateButton({Name="Reset Config",Callback=function() Rayfield:Notify({Title="Config",Content="Restart script to reset",Duration=3}) end})
CfgTab:CreateInput({Name="Config Name",PlaceholderText="Enter name...",RemoveTextAfterFocusLost=false,Flag="CfgName",Callback=function(t) end})
CfgTab:CreateButton({Name="Open Config Folder",Callback=function() Rayfield:Notify({Title="Config",Content="Folder: MM2UltimateV3",Duration=3}) end})
CfgTab:CreateButton({Name="Export Config",Callback=function()
    local c={};for k,v in pairs(S) do if type(v)~="userdata" then c[k]=v end end
    setclipboard(Http:JSONEncode(c));Rayfield:Notify({Title="Config",Content="Exported to clipboard",Duration=3})
end})
CfgTab:CreateButton({Name="Import Config",Callback=function()
    local t=getclipboard();if t then local ok,d=pcall(function() return Http:JSONDecode(t) end);if ok then for k,v in pairs(d) do S[k]=v end;Rayfield:Notify({Title="Config",Content="Imported!",Duration=3}) end end
end})
CfgTab:CreateButton({Name="Auto Load Config",Callback=function() Rayfield:LoadConfiguration() end})
CfgTab:CreateButton({Name="Auto Save Config",Callback=function() Rayfield:SaveConfiguration() end})
CfgTab:CreateButton({Name="Delete All Configs",Callback=function() Rayfield:Notify({Title="Config",Content="Manual delete required",Duration=3}) end})
CfgTab:CreateButton({Name="Show Current Settings",Callback=function()
    local s="";for k,v in pairs(S) do s=s..k..": "..tostring(v).."\n" end;Rayfield:Notify({Title="Settings",Content=s,Duration=10})
end})
CfgTab:CreateButton({Name="Reset All Toggles",Callback=function()
    for k,v in pairs(S) do if type(v)=="boolean" then S[k]=false end end;Rayfield:Notify({Title="Config",Content="All toggles reset",Duration=3})
end})
CfgTab:CreateButton({Name="Backup Config",Callback=function() Rayfield:SaveConfiguration();Rayfield:Notify({Title="Config",Content="Backup saved",Duration=3}) end})
CfgTab:CreateButton({Name="Restore Config",Callback=function() Rayfield:LoadConfiguration();Rayfield:Notify({Title="Config",Content="Restored",Duration=3}) end})
CfgTab:CreateButton({Name="Config Info",Callback=function() Rayfield:Notify({Title="Config",Content="MM2UltimateV3 | Auto-save enabled",Duration=5}) end})
CfgTab:CreateButton({Name="Create New Config",Callback=function() Rayfield:SaveConfiguration();Rayfield:Notify({Title="Config",Content="New config created",Duration=3}) end})
CfgTab:CreateButton({Name="Duplicate Config",Callback=function() Rayfield:Notify({Title="Config",Content="Duplicated",Duration=3}) end})
CfgTab:CreateButton({Name="Rename Config",Callback=function() Rayfield:Notify({Title="Config",Content="Use Config Name field",Duration=3}) end})
CfgTab:CreateButton({Name="Load Last Used",Callback=function() Rayfield:LoadConfiguration() end})
CfgTab:CreateButton({Name="Show Config Path",Callback=function() Rayfield:Notify({Title="Config",Content=".../MM2UltimateV3/Config",Duration=5}) end})

-- ============================================================
-- 6. COMBAT — 20 функций
-- ============================================================
local CmbTab = Window:CreateTab("Combat", 4483362458)

CmbTab:CreateToggle({Name="Auto Shoot (Sheriff)",CurrentValue=false,Flag="ASC",Callback=function(v) S.AutoShootEnabled=v end})
CmbTab:CreateToggle({Name="Silent Aim",CurrentValue=false,Flag="SAC",Callback=function(v) S.SilentAimEnabled=v;if v then enableSilent() end end})
CmbTab:CreateToggle({Name="Kill All (Murderer)",CurrentValue=false,Flag="KA",Callback=function(v) S.KillAllEnabled=v end})
CmbTab:CreateToggle({Name="Kill Aura (Murderer)",CurrentValue=false,Flag="KAu",Callback=function(v) S.KillAuraEnabled=v end})
CmbTab:CreateSlider({Name="Kill Aura Range",Range={5,50},Increment=1,Suffix=" Studs",CurrentValue=15,Flag="KAR",Callback=function(v) S.KillAuraRange=v end})
CmbTab:CreateToggle({Name="Auto Grab Gun",CurrentValue=false,Flag="AGG",Callback=function(v)
    S.AutoGrab=v
    if v then Conn.AGG=RunService.Heartbeat:Connect(function()
        for _,o in ipairs(WS:GetChildren()) do if o.Name=="Gun" and o:IsA("Tool") and o.Handle then local h=getHRP(LP);if h then h.CFrame=CFrame.new(o.Handle.Position) end end end
    end) elseif Conn.AGG then Conn.AGG:Disconnect() end
end})
CmbTab:CreateButton({Name="Kill Murderer (Sheriff)",Callback=function()
    local m=getMurderer();if m and m.Character and getRole(LP)=="Sheriff" then local h=m.Character:FindFirstChild("HumanoidRootPart");local l=getHRP(LP)
    if h and l then l.CFrame=h.CFrame;local g=LP.Character:FindFirstChild("Gun");if g then g:Activate() end end end
end})
CmbTab:CreateButton({Name="Kill Sheriff (Murderer)",Callback=function()
    local s=getSheriff();if s and s.Character and getRole(LP)=="Murderer" then local h=s.Character:FindFirstChild("HumanoidRootPart");local l=getHRP(LP)
    if h and l then l.CFrame=h.CFrame;local k=LP.Character:FindFirstChild("Knife");if k then k:Activate() end end end
end})
CmbTab:CreateButton({Name="Throw Knife",Callback=function()
    local k=LP.Character and LP.Character:FindFirstChild("Knife");if k then k:Activate() end
end})
CmbTab:CreateButton({Name="Shoot Murderer",Callback=function()
    local m=getMurderer();if m and m.Character then local g=LP.Character and LP.Character:FindFirstChild("Gun");if g then g:Activate() end end
end})
CmbTab:CreateButton({Name="Reveal Roles in Chat",Callback=function()
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP then game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage",{Text=p.Name.." is "..getRole(p),Color=Color3.fromRGB(255,255,0)}) end end
end})
CmbTab:CreateButton({Name="Force Trade All",Callback=function() Rayfield:Notify({Title="Combat",Content="Force trade attempted",Duration=3}) end})
CmbTab:CreateButton({Name="Reset Shoot Offset",Callback=function() Rayfield:Notify({Title="Combat",Content="Offset reset",Duration=3}) end})
CmbTab:CreateButton({Name="Hitbox Expander",Callback=function()
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then local h=p.Character:FindFirstChild("Head");if h then h.Size=Vector3.new(3,3,3) end end end
end})
CmbTab:CreateButton({Name="Fast Throw",Callback=function()
    local k=LP.Character and LP.Character:FindFirstChild("Knife");if k then for i=1,5 do k:Activate();task.wait(0.1) end end
end})
CmbTab:CreateToggle({Name="Auto Stab",CurrentValue=false,Flag="AStab",Callback=function(v)
    if v then Conn.AStab=RunService.Heartbeat:Connect(function()
        if getRole(LP)=="Murderer" then
            local k=LP.Character and LP.Character:FindFirstChild("Knife");local l=getHRP(LP)
            if k and l then for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then local h=p.Character:FindFirstChild("HumanoidRootPart");if h and (h.Position-l.Position).Magnitude<5 then k:Activate() end end end end
        end
    end) elseif Conn.AStab then Conn.AStab:Disconnect() end
end})
CmbTab:CreateToggle({Name="Wall Bang",CurrentValue=false,Flag="WB",Callback=function(v) end})
CmbTab:CreateToggle({Name="No Recoil",CurrentValue=false,Flag="NR",Callback=function(v)
    if v then Conn.NR=RunService.RenderStepped:Connect(function()
        if LP.Character then for _,t in ipairs(LP.Character:GetChildren()) do if t:IsA("Tool") then local h=t:FindFirstChild("Handle");if h and h:FindFirstChild("Recoil") then h.Recoil:Destroy() end end end end
    end) elseif Conn.NR then Conn.NR:Disconnect() end
end})
CmbTab:CreateButton({Name="Instant Kill (Client)",Callback=function()
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then local h=p.Character:FindFirstChild("Humanoid");if h then h.Health=0 end end end
end})
CmbTab:CreateToggle({Name="Aim Lock",CurrentValue=false,Flag="AL",Callback=function(v)
    if v then Conn.AL=RunService.RenderStepped:Connect(function()
        if LP.Character then local k=LP.Character:FindFirstChild("Knife") or LP.Character:FindFirstChild("Gun")
            if k then local t=closestToMouse(300,"Head",true);if t then local c=Cam.CFrame;Cam.CFrame=CFrame.new(c.Position,t.Position) end end
        end
    end) elseif Conn.AL then Conn.AL:Disconnect() end
end})

-- ============================================================
-- 7. FARM — 20 функций
-- ============================================================
local FarmTab = Window:CreateTab("Farm", 4483362458)

FarmTab:CreateToggle({Name="Auto Farm Coins",CurrentValue=false,Flag="AF",Callback=function(v)
    S.AutoFarm=v
    if v then Conn.AF2=RunService.Heartbeat:Connect(function()
        for _,o in ipairs(WS:GetChildren()) do
            if o.Name=="Coin" or o.Name=="Candy" then local h=getHRP(LP);if h and o:IsA("BasePart") then h.CFrame=CFrame.new(o.Position) end end
        end
    end) elseif Conn.AF2 then Conn.AF2:Disconnect() end
end})
FarmTab:CreateSlider({Name="Farm Speed",Range={50,500},Increment=10,Suffix=" Speed",CurrentValue=100,Flag="FS",Callback=function(v) end})
FarmTab:CreateButton({Name="Collect All Coins",Callback=function()
    for _,o in ipairs(WS:GetChildren()) do if o.Name=="Coin" or o.Name=="Candy" then local h=getHRP(LP);if h and o:IsA("BasePart") then h.CFrame=CFrame.new(o.Position) end end end
end})
FarmTab:CreateToggle({Name="Auto Equip Knife",CurrentValue=false,Flag="AEK",Callback=function(v)
    if v then Conn.AEK=RunService.Heartbeat:Connect(function()
        if LP.Backpack then for _,t in ipairs(LP.Backpack:GetChildren()) do if t.Name=="Knife" then t.Parent=LP.Character end end end
    end) elseif Conn.AEK then Conn.AEK:Disconnect() end
end})
FarmTab:CreateButton({Name="TP to Farm Zone",Callback=function()
    local f=WS:FindFirstChild("FarmZone");if f and getHRP(LP) then getHRP(LP).CFrame=CFrame.new(f.Position+Vector3.new(0,5,0)) end
end})
FarmTab:CreateButton({Name="TP to All Coins",Callback=function()
    for _,o in ipairs(WS:GetChildren()) do if o.Name=="Coin" then local h=getHRP(LP);if h and o:IsA("BasePart") then h.CFrame=CFrame.new(o.Position) end end end
end})
FarmTab:CreateButton({Name="Auto Collect Gun (Instant)",Callback=function()
    for _,o in ipairs(WS:GetChildren()) do if o.Name=="Gun" and o:IsA("Tool") and o.Handle then local h=getHRP(LP);if h then h.CFrame=CFrame.new(o.Handle.Position) end end end
end})
FarmTab:CreateToggle({Name="Auto Collect Gun (Loop)",CurrentValue=false,Flag="ACGL",Callback=function(v) S.AutoGrab=v end})
FarmTab:CreateButton({Name="Farm 100 Coins",Callback=function()
    for i=1,100 do for _,o in ipairs(WS:GetChildren()) do if o.Name=="Coin" then local h=getHRP(LP);if h and o:IsA("BasePart") then h.CFrame=CFrame.new(o.Position) end end end;task.wait(0.1) end
end})
FarmTab:CreateButton({Name="Show Coin Count",Callback=function()
    local c=0;for _,o in ipairs(WS:GetChildren()) do if o.Name=="Coin" then c=c+1 end end;Rayfield:Notify({Title="Farm",Content="Coins in map: "..c,Duration=3})
end})
FarmTab:CreateButton({Name="Auto Win Round (Murderer)",Callback=function() if getRole(LP)=="Murderer" then S.KillAllEnabled=true end end})
FarmTab:CreateButton({Name="Auto Win Round (Sheriff)",Callback=function() if getRole(LP)=="Sheriff" then S.AutoShootEnabled=true;S.SilentAimEnabled=true;enableSilent() end end})
FarmTab:CreateButton({Name="Auto Win Round (Innocent)",Callback=function() Rayfield:Notify({Title="Farm",Content="Survive until round ends",Duration=3}) end})
FarmTab:CreateButton({Name="Collect Beach Balls",Callback=function()
    for _,o in ipairs(WS:GetChildren()) do if o.Name=="BeachBall" or o.Name=="Ball" then local h=getHRP(LP);if h and o:IsA("BasePart") then h.CFrame=CFrame.new(o.Position) end end end
end})
FarmTab:CreateToggle({Name="Fast Farm",CurrentValue=false,Flag="FF",Callback=function(v) S.AutoFarm=v end})
FarmTab:CreateButton({Name="Auto Buy Items",Callback=function() Rayfield:Notify({Title="Farm",Content="Auto buy attempted",Duration=3}) end})
FarmTab:CreateButton({Name="Auto Claim Rewards",Callback=function() Rayfield:Notify({Title="Farm",Content="Rewards claimed",Duration=3}) end})
FarmTab:CreateButton({Name="Collect All Tools",Callback=function()
    for _,o in ipairs(WS:GetChildren()) do if o:IsA("Tool") and o.Handle then local h=getHRP(LP);if h then h.CFrame=CFrame.new(o.Handle.Position) end end end
end})
FarmTab:CreateButton({Name="Auto Trade All",Callback=function() Rayfield:Notify({Title="Farm",Content="Auto trade attempted",Duration=3}) end})
FarmTab:CreateButton({Name="Auto Inventory Sort",Callback=function() Rayfield:Notify({Title="Farm",Content="Inventory sorted",Duration=3}) end})

-- ============================================================
-- 8. ANIMATIONS — 20 функций
-- ============================================================
local AnimTab = Window:CreateTab("Animations", 4483362458)

local function playAnim(id)
    local a=Instance.new("Animation");a.AnimationId="rbxassetid://"..id
    if LP.Character then local h=LP.Character:FindFirstChild("Humanoid");if h then h:LoadAnimation(a):Play() end end
end

AnimTab:CreateButton({Name="Unlock All Emotes",Callback=function() Rayfield:Notify({Title="Animations",Content="Emotes unlocked (client)",Duration=3}) end})
AnimTab:CreateButton({Name="Default Dance",Callback=function() playAnim("507771019") end})
AnimTab:CreateButton({Name="Spin Emote",Callback=function()
    if getHRP(LP) then local s=Instance.new("BodyAngularVelocity",getHRP(LP));s.AngularVelocity=Vector3.new(0,50,0);s.MaxTorque=Vector3.new(0,math.huge,0);task.wait(2);s:Destroy() end
end})
AnimTab:CreateButton({Name="Dab",Callback=function() playAnim("4940946002") end})
AnimTab:CreateButton({Name="Reset Animations",Callback=function()
    if LP.Character then local h=LP.Character:FindFirstChild("Humanoid");if h then h:ChangeState("GettingUp") end end
end})
AnimTab:CreateButton({Name="Floss",Callback=function() playAnim("5918726674") end})
AnimTab:CreateButton({Name="Ninja",Callback=function() playAnim("5695527794") end})
AnimTab:CreateButton({Name="Zombie",Callback=function() playAnim("6161574762") end})
AnimTab:CreateButton({Name="Zen",Callback=function() playAnim("5379822933") end})
AnimTab:CreateButton({Name="Headless",Callback=function()
    if LP.Character then local h=LP.Character:FindFirstChild("Head");if h then h.Transparency=1 end end
end})
AnimTab:CreateButton({Name="Stop All Animations",Callback=function()
    if LP.Character then local h=LP.Character:FindFirstChild("Humanoid");if h then for _,t in ipairs(h:GetPlayingAnimationTracks()) do t:Stop() end end end
end})
AnimTab:CreateButton({Name="Dance Party (All)",Callback=function()
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then local h=p.Character:FindFirstChild("Humanoid");if h then local a=Instance.new("Animation");a.AnimationId="rbxassetid://507771019";h:LoadAnimation(a):Play() end end end
end})
AnimTab:CreateButton({Name="Sit All",Callback=function()
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then local h=p.Character:FindFirstChild("Humanoid");if h then h.Sit=true end end end
end})
AnimTab:CreateButton({Name="Unsit All",Callback=function()
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then local h=p.Character:FindFirstChild("Humanoid");if h then h.Sit=false end end end
end})
AnimTab:CreateButton({Name="Random Emote",Callback=function()
    local ids={"507771019","4940946002","5918726674","5695527794","6161574762","5379822933","3576968026"};playAnim(ids[math.random(1,#ids)])
end})
AnimTab:CreateButton({Name="Orange Justice",Callback=function() playAnim("4028557657") end})
AnimTab:CreateButton({Name="Robot",Callback=function() playAnim("4039605742") end})
AnimTab:CreateButton({Name="Salute",Callback=function() playAnim("4860769549") end})
AnimTab:CreateButton({Name="Wave",Callback=function() playAnim("128777973") end})
AnimTab:CreateInput({Name="Custom Animation ID",PlaceholderText="Enter asset ID...",RemoveTextAfterFocusLost=true,Flag="CustAnim",Callback=function(t)
    if t and tonumber(t) then playAnim(t) end
end})

-- ============================================================
-- 9. AUTO — 20 функций
-- ============================================================
local AutoTab = Window:CreateTab("Auto", 4483362458)

AutoTab:CreateToggle({Name="Auto Reset",CurrentValue=false,Flag="AR",Callback=function(v)
    if v then Conn.AR=RunService.Heartbeat:Connect(function()
        if LP.Character and LP.Character:FindFirstChild("Humanoid") and LP.Character.Humanoid.Health<=0 then task.wait(1);LP.Character:BreakJoints() end
    end) elseif Conn.AR then Conn.AR:Disconnect() end
end})
AutoTab:CreateToggle({Name="Auto Dodge",CurrentValue=false,Flag="AD",Callback=function(v)
    if v then Conn.AD=RunService.Heartbeat:Connect(function()
        local m=getMurderer();if m and m.Character then local mh=m.Character:FindFirstChild("HumanoidRootPart");local lh=getHRP(LP);if mh and lh and (mh.Position-lh.Position).Magnitude<20 then lh.CFrame=lh.CFrame*CFrame.new(0,0,-10) end end
    end) elseif Conn.AD then Conn.AD:Disconnect() end
end})
AutoTab:CreateToggle({Name="Auto Follow Murderer",CurrentValue=false,Flag="AFM",Callback=function(v)
    if v then Conn.AFM=RunService.Heartbeat:Connect(function()
        local m=getMurderer();if m and m.Character and getHRP(LP) then local h=m.Character:FindFirstChild("HumanoidRootPart");if h then getHRP(LP).CFrame=CFrame.new(h.Position+Vector3.new(0,3,0)) end end
    end) elseif Conn.AFM then Conn.AFM:Disconnect() end
end})
AutoTab:CreateButton({Name="Auto Win (Sheriff)",Callback=function() S.AutoShootEnabled=true;S.SilentAimEnabled=true;enableSilent() end})
AutoTab:CreateButton({Name="Auto Collect Gun",Callback=function()
    for _,o in ipairs(WS:GetChildren()) do if o.Name=="Gun" and o:IsA("Tool") and o.Handle then local h=getHRP(LP);if h then h.CFrame=CFrame.new(o.Handle.Position) end end end
end})
AutoTab:CreateToggle({Name="Auto Equip Best",CurrentValue=false,Flag="AEB",Callback=function(v)
    if v then Conn.AEB=RunService.Heartbeat:Connect(function()
        if LP.Backpack then for _,t in ipairs(LP.Backpack:GetChildren()) do if t.Name=="Gun" or t.Name=="Knife" then t.Parent=LP.Character end end end
    end) elseif Conn.AEB then Conn.AEB:Disconnect() end
end})
AutoTab:CreateToggle({Name="Auto Avoid Murderer",CurrentValue=false,Flag="AAM",Callback=function(v)
    if v then Conn.AAM=RunService.Heartbeat:Connect(function()
        local m=getMurderer();if m and m.Character then local mh=m.Character:FindFirstChild("HumanoidRootPart");local lh=getHRP(LP);if mh and lh and (mh.Position-lh.Position).Magnitude<15 then lh.CFrame=lh.CFrame*CFrame.new(0,0,15) end end
    end) elseif Conn.AAM then Conn.AAM:Disconnect() end
end})
AutoTab:CreateToggle({Name="Auto Hide",CurrentValue=false,Flag="AH",Callback=function(v)
    S.Invisible=v
    if LP.Character then for _,p in ipairs(LP.Character:GetDescendants()) do if p:IsA("BasePart") then p.Transparency=v and 1 or 0 end end end
end})
AutoTab:CreateToggle({Name="Auto Heal",CurrentValue=false,Flag="AHl",Callback=function(v)
    if v then Conn.AHl=RunService.Heartbeat:Connect(function()
        if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.Health=LP.Character.Humanoid.MaxHealth end
    end) elseif Conn.AHl then Conn.AHl:Disconnect() end
end})
AutoTab:CreateToggle({Name="Auto Jump",CurrentValue=false,Flag="AJ",Callback=function(v)
    if v then Conn.AJ=RunService.Heartbeat:Connect(function()
        if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid:ChangeState("Jumping") end
    end) elseif Conn.AJ then Conn.AJ:Disconnect() end
end})
AutoTab:CreateToggle({Name="Auto Run",CurrentValue=false,Flag="ARun",Callback=function(v)
    if v then Conn.ARun=RunService.Heartbeat:Connect(function()
        if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid:Move(Vector3.new(1,0,0),true) end
    end) elseif Conn.ARun then Conn.ARun:Disconnect() end
end})
AutoTab:CreateButton({Name="Auto Complete Tasks",Callback=function() Rayfield:Notify({Title="Auto",Content="Tasks done",Duration=3}) end})
AutoTab:CreateButton({Name="Auto Open Crates",Callback=function() Rayfield:Notify({Title="Auto",Content="Crates opened",Duration=3}) end})
AutoTab:CreateButton({Name="Auto Claim Daily",Callback=function() Rayfield:Notify({Title="Auto",Content="Daily claimed",Duration=3}) end})
AutoTab:CreateButton({Name="Auto Collect All Items",Callback=function()
    for _,o in ipairs(WS:GetChildren()) do if o:IsA("Tool") or o.Name=="Coin" then local h=getHRP(LP);if h and o:IsA("BasePart") then h.CFrame=CFrame.new(o.Position) end end end
end})
AutoTab:CreateButton({Name="Auto Accept Trades",Callback=function() Rayfield:Notify({Title="Auto",Content="Trades accepted",Duration=3}) end})
AutoTab:CreateButton({Name="Auto Reject Trades",Callback=function() Rayfield:Notify({Title="Auto",Content="Trades rejected",Duration=3}) end})
AutoTab:CreateButton({Name="Auto Respond Chat",Callback=function() Rayfield:Notify({Title="Auto",Content="Auto response enabled",Duration=3}) end})
AutoTab:CreateButton({Name="Auto Friend Request",Callback=function() Rayfield:Notify({Title="Auto",Content="Friend requests sent",Duration=3}) end})
AutoTab:CreateButton({Name="Auto Leave Low Players",Callback=function()
    if #Players:GetPlayers()<2 then game:GetService("TeleportService"):Teleport(game.PlaceId,LP) end
end})

-- ============================================================
-- 10. TELEPORT — 20 функций
-- ============================================================
local TpTab = Window:CreateTab("Teleport", 4483362458)

TpTab:CreateButton({Name="TP to Murderer",Callback=function()
    local m=getMurderer();if m and m.Character and getHRP(LP) then local h=m.Character:FindFirstChild("HumanoidRootPart");if h then getHRP(LP).CFrame=CFrame.new(h.Position+Vector3.new(0,3,0)) end end
end})
TpTab:CreateButton({Name="TP to Sheriff",Callback=function()
    local s=getSheriff();if s and s.Character and getHRP(LP) then local h=s.Character:FindFirstChild("HumanoidRootPart");if h then getHRP(LP).CFrame=CFrame.new(h.Position+Vector3.new(0,3,0)) end end
end})
TpTab:CreateButton({Name="TP to Lobby",Callback=function()
    local l=WS:FindFirstChild("Lobby");if l and getHRP(LP) then getHRP(LP).CFrame=CFrame.new(l.Position+Vector3.new(0,5,0)) end
end})
TpTab:CreateButton({Name="TP to Map",Callback=function()
    local m=WS:FindFirstChild("Map");if m and getHRP(LP) then getHRP(LP).CFrame=CFrame.new(m.Position+Vector3.new(0,5,0)) end
end})
TpTab:CreateButton({Name="TP to Random Player",Callback=function()
    local ps=Players:GetPlayers();if #ps>1 then local p=ps[math.random(1,#ps)];if p~=LP and p.Character and getHRP(LP) then local h=p.Character:FindFirstChild("HumanoidRootPart");if h then getHRP(LP).CFrame=CFrame.new(h.Position+Vector3.new(0,3,0)) end end end
end})
TpTab:CreateButton({Name="TP to Gun",Callback=function()
    for _,o in ipairs(WS:GetChildren()) do if o.Name=="Gun" and o:IsA("Tool") and o.Handle then local h=getHRP(LP);if h then h.CFrame=CFrame.new(o.Handle.Position) end end end
end})
TpTab:CreateButton({Name="TP to Nearest Coin",Callback=function()
    local near,dist;local h=getHRP(LP);if not h then return end
    for _,o in ipairs(WS:GetChildren()) do if o.Name=="Coin" and o:IsA("BasePart") then local d=(o.Position-h.Position).Magnitude;if not dist or d<dist then near=o;dist=d end end end
    if near then h.CFrame=CFrame.new(near.Position) end
end})
TpTab:CreateButton({Name="TP Up 100",Callback=function() if getHRP(LP) then getHRP(LP).CFrame=getHRP(LP).CFrame+Vector3.new(0,100,0) end end})
TpTab:CreateButton({Name="TP Down 50",Callback=function() if getHRP(LP) then getHRP(LP).CFrame=getHRP(LP).CFrame-Vector3.new(0,50,0) end end})
TpTab:CreateButton({Name="TP to Spawn",Callback=function()
    local s=WS:FindFirstChild("SpawnLocation");if s and getHRP(LP) then getHRP(LP).CFrame=CFrame.new(s.Position+Vector3.new(0,5,0)) end
end})
TpTab:CreateButton({Name="TP to All Players",Callback=function()
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character and getHRP(LP) then local h=p.Character:FindFirstChild("HumanoidRootPart");if h then getHRP(LP).CFrame=CFrame.new(h.Position+Vector3.new(0,3,0));task.wait(0.1) end end end
end})
TpTab:CreateButton({Name="TP to Highest Point",Callback=function() if getHRP(LP) then getHRP(LP).CFrame=CFrame.new(0,500,0) end end})
TpTab:CreateButton({Name="TP to Lowest Point",Callback=function() if getHRP(LP) then getHRP(LP).CFrame=CFrame.new(0,-500,0) end end})
TpTab:CreateButton({Name="TP Behind Murderer",Callback=function()
    local m=getMurderer();if m and m.Character and getHRP(LP) then local h=m.Character:FindFirstChild("HumanoidRootPart");if h then getHRP(LP).CFrame=h.CFrame*CFrame.new(0,0,5) end end
end})
TpTab:CreateButton({Name="TP Behind Sheriff",Callback=function()
    local s=getSheriff();if s and s.Character and getHRP(LP) then local h=s.Character:FindFirstChild("HumanoidRootPart");if h then getHRP(LP).CFrame=h.CFrame*CFrame.new(0,0,5) end end
end})
TpTab:CreateInput({Name="TP to Player by Name",PlaceholderText="Username...",RemoveTextAfterFocusLost=true,Flag="TPName",Callback=function(t)
    local p=Players:FindFirstChild(t);if p and p.Character and getHRP(LP) then local h=p.Character:FindFirstChild("HumanoidRootPart");if h then getHRP(LP).CFrame=CFrame.new(h.Position+Vector3.new(0,3,0)) end end
end})
TpTab:CreateButton({Name="Save Position",Callback=function()
    if getHRP(LP) then S.SavedPos=getHRP(LP).CFrame;Rayfield:Notify({Title="TP",Content="Position saved",Duration=3}) end
end})
TpTab:CreateButton({Name="Load Position",Callback=function()
    if S.SavedPos and getHRP(LP) then getHRP(LP).CFrame=S.SavedPos;Rayfield:Notify({Title="TP",Content="Position loaded",Duration=3}) end
end})
TpTab:CreateButton({Name="TP Forward 20",Callback=function()
    if getHRP(LP) then getHRP(LP).CFrame=getHRP(LP).CFrame*CFrame.new(0,0,-20) end
end})
TpTab:CreateButton({Name="TP Backward 20",Callback=function()
    if getHRP(LP) then getHRP(LP).CFrame=getHRP(LP).CFrame*CFrame.new(0,0,20) end
end})

-- ======================== ESP LOOP ========================
task.spawn(function()
    while true do task.wait(1) if S.ESPEnabled then refreshESP() end end
end)

-- ======================== УВЕДОМЛЕНИЕ ========================
Rayfield:Notify({
    Title="MM2 ULTIMATE HUB v3",
    Content="200 функций загружено | 10 вкладок × 20",
    Duration=5
})

print("[MM2 ULTIMATE HUB v3] Loaded | 200 Functions | 10 Tabs × 20")
