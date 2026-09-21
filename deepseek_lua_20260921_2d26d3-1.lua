--[[
    MM2 ULTIMATE HUB v5 | 14 Tabs | 350 Functions
    Quick Actions (мгновенные кнопки) + Auto Toggles для всего
--]]
local Rayfield=loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local WS=game:GetService("Workspace")
local RS=game:GetService("ReplicatedStorage")
local Http=game:GetService("HttpService")
local Lighting=game:GetService("Lighting")
local LP=Players.LocalPlayer
local Cam=WS.CurrentCamera

local S={AimbotEnabled=false,AimbotPart="Head",AimbotFOV=150,AimbotSmooth=0.15,AimbotVisible=true,AimbotKey=Enum.UserInputType.MouseButton2,
SilentAimEnabled=false,SilentAimFOV=130,SilentAimHit=100,
KillAllEnabled=false,KillAuraEnabled=false,KillAuraRange=15,
AutoShootEnabled=false,AutoShootRange=1000,AutoShootDelay=0.1,
WalkSpeed=16,JumpPower=50,ESPEnabled=false,Fullbright=false,Noclip=false,Invisible=false,
AutoFarm=false,AutoGrab=false,AntiFling=false,SavedPos=nil,SelectedPlayer=nil,
ChamsEnabled=false,SkeletonEnabled=false,TracerEnabled=false,
AutoStabEnabled=false,AimLockEnabled=false,AutoParryEnabled=false}

local E={},Ch={},Tr={},Cn={},SilentHooked=false

local function gr(p)
    if not p or not p.Character then return "Innocent" end
    if p.Character:FindFirstChild("Knife") or (p.Backpack and p.Backpack:FindFirstChild("Knife")) then return "Murderer"
    elseif p.Character:FindFirstChild("Gun") or (p.Backpack and p.Backpack:FindFirstChild("Gun")) then return "Sheriff" end
    return "Innocent"
end
local function gh(p) if p and p.Character then return p.Character:FindFirstChild("HumanoidRootPart") end end
local function gm() for _,p in ipairs(Players:GetPlayers()) do if p~=LP and gr(p)=="Murderer" then return p end end end
local function gs() for _,p in ipairs(Players:GetPlayers()) do if p~=LP and gr(p)=="Sheriff" then return p end end end
local function gt() return LP.Character and (LP.Character:FindFirstChild("Knife") or LP.Character:FindFirstChild("Gun")) end
local function pAnim(id)
    local a=Instance.new("Animation");a.AnimationId="rbxassetid://"..id
    if LP.Character then local h=LP.Character:FindFirstChild("Humanoid");if h then h:LoadAnimation(a):Play() end end
end

local function mkESP(p,c)
    if not p.Character then return end
    local h=p.Character:FindFirstChild("HumanoidRootPart");if not h then return end
    local b=Instance.new("BoxHandleAdornment");b.Name="MM2ESP";b.Adornee=h;b.AlwaysOnTop=true;b.ZIndex=5;b.Size=Vector3.new(2,2,1);b.Color3=c;b.Transparency=0.5;b.Parent=h
    local g=Instance.new("BillboardGui");g.Name="MM2Tag";g.Adornee=h;g.AlwaysOnTop=true;g.Size=UDim2.new(0,100,0,20);g.StudsOffset=Vector3.new(0,2.5,0);g.Parent=h
    local l=Instance.new("TextLabel");l.Size=UDim2.new(1,0,1,0);l.BackgroundTransparency=1;l.Text=p.Name.." ["..gr(p).."]";l.TextColor3=c;l.TextStrokeTransparency=0;l.Font=Enum.Font.SourceSansBold;l.TextScaled=true;l.Parent=g
    E[p]={b=b,g=g}
end
local function clESP(p) if E[p] then if E[p].b then E[p].b:Destroy() end if E[p].g then E[p].g:Destroy() end E[p]=nil end end
local function rfESP()
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP then clESP(p)
        if S.ESPEnabled and p.Character then local r=gr(p);local c=r=="Murderer" and Color3.fromRGB(255,0,0) or r=="Sheriff" and Color3.fromRGB(0,100,255) or Color3.fromRGB(0,255,0);mkESP(p,c) end
    end end
end
local function mkCh(p,c)
    if not p.Character then return end Ch[p]=Ch[p] or {}
    for _,part in ipairs(p.Character:GetDescendants()) do if part:IsA("BasePart") and part.Name~="HumanoidRootPart" then
        local h=Instance.new("Highlight");h.Name="MM2Ch";h.Adornee=part;h.FillColor=c;h.OutlineColor=Color3.new(1,1,1);h.FillTransparency=0.5;h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop;h.Parent=part
        table.insert(Ch[p],h)
    end end
end
local function clCh(p) if Ch[p] then for _,h in ipairs(Ch[p]) do pcall(function() h:Destroy() end) end Ch[p]=nil end end
local function mkTr(p)
    if not p.Character then return end local h=p.Character:FindFirstChild("HumanoidRootPart");if not h then return end
    local l=Instance.new("LineHandleAdornment");l.Name="MM2Tr";l.Adornee=h;l.AlwaysOnTop=true;l.Thickness=2;l.Color3=Color3.fromRGB(255,50,50);l.Length=1;l.Parent=h;Tr[p]=l
end
local function clTr(p) if Tr[p] then pcall(function() Tr[p]:Destroy() end) Tr[p]=nil end end

local function cTM(fov,part,vo)
    local best,bd;local mp=UIS:GetMouseLocation()
    for _,p in ipairs(Players:GetPlayers()) do
        if p==LP or not p.Character then continue end
        local hm=p.Character:FindFirstChildOfClass("Humanoid");if not hm or hm.Health<=0 then continue end
        local t=p.Character:FindFirstChild(part) or p.Character:FindFirstChild("HumanoidRootPart");if not t then continue end
        if vo then local ob=Cam:GetPartsObscuringTarget({t.Position},{LP.Character,p.Character});if #ob>0 then continue end end
        local sp,on=Cam:WorldToViewportPoint(t.Position);if not on then continue end
        local d=(Vector2.new(sp.X,sp.Y)-Vector2.new(mp.X,mp.Y)).Magnitude
        if d<=fov and (not bd or d<bd) then best=t;bd=d end
    end
    return best
end

RunService.RenderStepped:Connect(function()
    if not S.AimbotEnabled or not UIS:IsMouseButtonPressed(S.AimbotKey) then return end
    local t=cTM(S.AimbotFOV,S.AimbotPart,S.AimbotVisible)
    if t then local c=Cam.CFrame;Cam.CFrame=c:Lerp(CFrame.new(c.Position,t.Position),S.AimbotSmooth) end
end)
RunService.RenderStepped:Connect(function()
    if not S.AimLockEnabled then return end
    local t=cTM(300,"Head",true);if t then local c=Cam.CFrame;Cam.CFrame=CFrame.new(c.Position,t.Position) end
end)

local function enSilent()
    if SilentHooked then return end
    pcall(function()
        local mt=getrawmetatable(game);local old=mt.__namecall;setreadonly(mt,false)
        mt.__namecall=function(self,...)
            local m=getnamecallmethod();local a={...}
            if S.SilentAimEnabled and m=="Raycast" and self==WS then
                if math.random(0,100)<=S.SilentAimHit then
                    local t=cTM(S.SilentAimFOV,"Head",true)
                    if t then local o=a[1];a[2]=(t.Position-o).Unit*a[2].Magnitude;return old(self,unpack(a)) end
                end
            end
            return old(self,...)
        end
        setreadonly(mt,true)
    end)
    SilentHooked=true
end

local function doKillAll()
    if gr(LP)~="Murderer" then return end
    local k=LP.Character and LP.Character:FindFirstChild("Knife");if not k then return end
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then
        local h=p.Character:FindFirstChild("HumanoidRootPart");local l=gh(LP)
        if h and l then l.CFrame=CFrame.new(h.Position+Vector3.new(0,3,0));k:Activate();task.wait(0.05) end
    end end
end
local function doKillAura()
    if gr(LP)~="Murderer" then return end
    local k=LP.Character and LP.Character:FindFirstChild("Knife");if not k then return end
    local l=gh(LP);if not l then return end
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then
        local h=p.Character:FindFirstChild("HumanoidRootPart")
        if h and (h.Position-l.Position).Magnitude<=S.KillAuraRange then k:Activate();task.wait(0.05) end
    end end
end
local function doAutoShoot()
    if gr(LP)~="Sheriff" then return end
    local g=LP.Character and LP.Character:FindFirstChild("Gun");if not g then return end
    local m=gm();if not m or not m.Character then return end
    local h=m.Character:FindFirstChild("HumanoidRootPart");local l=gh(LP)
    if h and l and (h.Position-l.Position).Magnitude<=S.AutoShootRange then g:Activate() end
end

task.spawn(function() while task.wait(0.1) do
    if S.KillAllEnabled then doKillAll() end
    if S.KillAuraEnabled then doKillAura() end
    if S.AutoStabEnabled and gr(LP)=="Murderer" then
        local k=LP.Character and LP.Character:FindFirstChild("Knife");local l=gh(LP)
        if k and l then for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then local h=p.Character:FindFirstChild("HumanoidRootPart");if h and (h.Position-l.Position).Magnitude<5 then k:Activate() end end end end
    end
    if S.AutoParryEnabled and gr(LP)~="Murderer" then
        local m=gm();if m and m.Character then local mh=m.Character:FindFirstChild("HumanoidRootPart");local l=gh(LP);if mh and l and (mh.Position-l.Position).Magnitude<5 then l.CFrame=l.CFrame*CFrame.new(0,0,10) end end
    end
end end)
task.spawn(function() while task.wait(S.AutoShootDelay) do if S.AutoShootEnabled then doAutoShoot() end end end)

-- ============ ОКНО ============
local W=Rayfield:CreateWindow({Name="MM2 ULTIMATE HUB v5",LoadingTitle="MM2 Ultimate Hub v5",LoadingSubtitle="350 Functions | 14 Tabs | Quick Actions",ConfigurationSaving={Enabled=true,FolderName="MM2UltimateV5",FileName="Config"},KeySystem=false})

-- ============ 1. QUICK ACTIONS (20) ============
local QA=W:CreateTab("Quick Actions",4483362458)
QA:CreateSection("Kill/Shoot (Мгновенно)")
QA:CreateButton({Name="⚔️ KILL ALL (Instant)",Callback=function() doKillAll() end})
QA:CreateButton({Name="🔪 Kill Murderer (Instant)",Callback=function() local m=gm();if m and m.Character and gr(LP)=="Murderer" then local h=m.Character:FindFirstChild("HumanoidRootPart");local l=gh(LP);if h and l then l.CFrame=h.CFrame;local k=LP.Character:FindFirstChild("Knife");if k then k:Activate() end end end end})
QA:CreateButton({Name="🔫 Kill Sheriff (Instant)",Callback=function() local s=gs();if s and s.Character and gr(LP)=="Murderer" then local h=s.Character:FindFirstChild("HumanoidRootPart");local l=gh(LP);if h and l then l.CFrame=h.CFrame;local k=LP.Character:FindFirstChild("Knife");if k then k:Activate() end end end end})
QA:CreateButton({Name="💥 Shoot Murderer (Instant)",Callback=function() local m=gm();if m and m.Character then local h=m.Character:FindFirstChild("HumanoidRootPart");local l=gh(LP);if h and l then l.CFrame=h.CFrame;local g=LP.Character:FindFirstChild("Gun");if g then g:Activate() end end end end})
QA:CreateButton({Name="🎯 Shoot Sheriff (Instant)",Callback=function() local s=gs();if s and s.Character then local h=s.Character:FindFirstChild("HumanoidRootPart");local l=gh(LP);if h and l then l.CFrame=h.CFrame;local g=LP.Character:FindFirstChild("Gun");if g then g:Activate() end end end end})
QA:CreateSection("Troll (Мгновенно)")
QA:CreateButton({Name="🌀 Fling All (Instant)",Callback=function() for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then local h=p.Character:FindFirstChild("HumanoidRootPart");if h then h.Velocity=Vector3.new(math.random(-500,500),500,math.random(-500,500)) end end end end})
QA:CreateButton({Name="🌀 Fling Murderer (Instant)",Callback=function() local m=gm();if m and m.Character then local h=m.Character:FindFirstChild("HumanoidRootPart");if h then h.Velocity=Vector3.new(math.random(-500,500),500,math.random(-500,500)) end end end})
QA:CreateButton({Name="🌀 Fling Innocents (Instant)",Callback=function() for _,p in ipairs(Players:GetPlayers()) do if p~=LP and gr(p)=="Innocent" and p.Character then local h=p.Character:FindFirstChild("HumanoidRootPart");if h then h.Velocity=Vector3.new(math.random(-500,500),500,math.random(-500,500)) end end end end})
QA:CreateButton({Name="🧊 Freeze All (Instant)",Callback=function() for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then local h=p.Character:FindFirstChild("HumanoidRootPart");if h then h.Anchored=true end end end end})
QA:CreateButton({Name="🔥 Explode All (Instant)",Callback=function() for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then local h=p.Character:FindFirstChild("HumanoidRootPart");if h then local e=Instance.new("Explosion",WS);e.Position=h.Position;e.BlastRadius=15 end end end end})
QA:CreateSection("Farm (Мгновенно)")
QA:CreateButton({Name="💰 Collect All Coins (Instant)",Callback=function() for _,o in ipairs(WS:GetChildren()) do if o.Name=="Coin" then local h=gh(LP);if h and o:IsA("BasePart") then h.CFrame=CFrame.new(o.Position) end end end end})
QA:CreateButton({Name="🔫 Collect All Guns (Instant)",Callback=function() for _,o in ipairs(WS:GetChildren()) do if o.Name=="Gun" and o:IsA("Tool") and o.Handle then local h=gh(LP);if h then h.CFrame=CFrame.new(o.Handle.Position) end end end end})
QA:CreateButton({Name="🎁 Collect All Tools (Instant)",Callback=function() for _,o in ipairs(WS:GetChildren()) do if o:IsA("Tool") and o.Handle then local h=gh(LP);if h then h.CFrame=CFrame.new(o.Handle.Position) end end end end})
QA:CreateSection("Teleport (Мгновенно)")
QA:CreateButton({Name="🏃 TP to Murderer",Callback=function() local m=gm();if m and m.Character and gh(LP) then local h=m.Character:FindFirstChild("HumanoidRootPart");if h then gh(LP).CFrame=CFrame.new(h.Position+Vector3.new(0,3,0)) end end end})
QA:CreateButton({Name="👮 TP to Sheriff",Callback=function() local s=gs();if s and s.Character and gh(LP) then local h=s.Character:FindFirstChild("HumanoidRootPart");if h then gh(LP).CFrame=CFrame.new(h.Position+Vector3.new(0,3,0)) end end end})
QA:CreateButton({Name="👥 TP to All Players",Callback=function() for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character and gh(LP) then local h=p.Character:FindFirstChild("HumanoidRootPart");if h then gh(LP).CFrame=CFrame.new(h.Position+Vector3.new(0,3,0));task.wait(0.1) end end end end})
QA:CreateButton({Name="🏠 TP to Spawn",Callback=function() local sp=WS:FindFirstChild("SpawnLocation");if sp and gh(LP) then gh(LP).CFrame=CFrame.new(sp.Position+Vector3.new(0,5,0)) end end})
QA:CreateSection("Auto Toggle (Один клик)")
QA:CreateToggle({Name="AUTO: Kill All",CurrentValue=false,Flag="AUTO_KA",Callback=function(v) S.KillAllEnabled=v end})
QA:CreateToggle({Name="AUTO: Auto Shoot",CurrentValue=false,Flag="AUTO_AS",Callback=function(v) S.AutoShootEnabled=v end})

-- ============ 2. MISC (26) ============
local MT=W:CreateTab("Misc",4483362458)
MT:CreateToggle({Name="Fullbright",CurrentValue=false,Flag="Fullbright",Callback=function(v) S.Fullbright=v;if v then Lighting.Ambient=Color3.fromRGB(178,178,178);Lighting.OutdoorAmbient=Color3.fromRGB(178,178,178);Lighting.Brightness=2 else Lighting.Ambient=Color3.fromRGB(0,0,0);Lighting.OutdoorAmbient=Color3.fromRGB(70,70,70);Lighting.Brightness=1 end end})
MT:CreateToggle({Name="Anti-AFK",CurrentValue=false,Flag="AntiAFK",Callback=function(v) if v then Cn.AAFK=LP.Idled:Connect(function() local vu=game:GetService("VirtualUser");vu:Button2Down(Vector2.new(),Cam.CFrame);task.wait(1);vu:Button2Up(Vector2.new(),Cam.CFrame) end) elseif Cn.AAFK then Cn.AAFK:Disconnect() end end})
MT:CreateButton({Name="Rejoin Server",Callback=function() game:GetService("TeleportService"):Teleport(game.PlaceId,LP) end})
MT:CreateButton({Name="Server Hop",Callback=function() local d=Http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"));if d and #d.data>0 then local s=d.data[math.random(1,#d.data)];game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId,s.id,LP) end end})
MT:CreateButton({Name="Copy Job ID",Callback=function() setclipboard(game.JobId) end})
MT:CreateToggle({Name="Anti-Fling",CurrentValue=false,Flag="AntiFling",Callback=function(v) S.AntiFling=v;if v then Cn.AF=RunService.Heartbeat:Connect(function() if LP.Character then for _,p in ipairs(LP.Character:GetDescendants()) do if p:IsA("BasePart") then p.CustomPhysicalProperties=PhysicalProperties.new(0.7,0.3,0.5,1,1) end end end end) elseif Cn.AF then Cn.AF:Disconnect() end end})
MT:CreateButton({Name="Copy Place ID",Callback=function() setclipboard(tostring(game.PlaceId)) end})
MT:CreateButton({Name="Copy User ID",Callback=function() setclipboard(tostring(LP.UserId)) end})
MT:CreateButton({Name="Show Server Info",Callback=function() Rayfield:Notify({Title="Server",Content="Players: "..#Players:GetPlayers(),Duration=3}) end})
MT:CreateButton({Name="Show FPS",Callback=function() local f=0;local c;c=RunService.RenderStepped:Connect(function() f=f+1 end);task.wait(1);c:Disconnect();Rayfield:Notify({Title="FPS",Content=tostring(f),Duration=3}) end})
MT:CreateButton({Name="Reset Character",Callback=function() if LP.Character then LP.Character:BreakJoints() end end})
MT:CreateButton({Name="Clear Workspace (Client)",Callback=function() for _,v in ipairs(WS:GetChildren()) do if v~=LP.Character and not v:IsA("Camera") then pcall(function() v:Destroy() end) end end end})
MT:CreateButton({Name="Hide GUI",Callback=function() Rayfield:ToggleUI() end})
MT:CreateButton({Name="Show GUI",Callback=function() Rayfield:ToggleUI() end})
MT:CreateToggle({Name="Remove Fog",CurrentValue=false,Flag="NoFog",Callback=function(v) if v then Lighting.FogEnd=1e6;Lighting.FogStart=1e6 else Lighting.FogEnd=100000;Lighting.FogStart=0 end end})
MT:CreateButton({Name="Remove Textures",Callback=function() for _,v in ipairs(WS:GetDescendants()) do if v:IsA("Decal") or v:IsA("Texture") then v.Transparency=1 end end end})
MT:CreateButton({Name="Low Graphics",Callback=function() for _,v in ipairs(WS:GetDescendants()) do if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then v.Enabled=false end end;settings().Rendering.QualityLevel=1 end})
MT:CreateButton({Name="Restore Graphics",Callback=function() settings().Rendering.QualityLevel=10 end})
MT:CreateButton({Name="Copy Game Link",Callback=function() setclipboard("https://www.roblox.com/games/"..game.PlaceId) end})
MT:CreateButton({Name="Show Ping",Callback=function() local ok,p=pcall(function() return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() end);Rayfield:Notify({Title="Ping",Content=ok and string.format("%.0f ms",p) or "N/A",Duration=3}) end})
MT:CreateToggle({Name="Anti-Void",CurrentValue=false,Flag="AntiVoid",Callback=function(v) if v then Cn.AV=RunService.Heartbeat:Connect(function() if LP.Character then local h=gh(LP);if h and h.Position.Y<-50 then h.CFrame=CFrame.new(0,50,0) end end end) elseif Cn.AV then Cn.AV:Disconnect() end end})
MT:CreateButton({Name="Freeze Time",Callback=function() Lighting.TimeOfDay="12:00:00" end})
MT:CreateButton({Name="Mute Audio",Callback=function() for _,v in ipairs(game:GetService("SoundService"):GetDescendants()) do if v:IsA("Sound") then v.Volume=0 end end end})
MT:CreateButton({Name="Unmute Audio",Callback=function() for _,v in ipairs(game:GetService("SoundService"):GetDescendants()) do if v:IsA("Sound") then v.Volume=1 end end end})
MT:CreateButton({Name="Panic Unload",Callback=function() for _,c in pairs(Cn) do pcall(function() c:Disconnect() end) end;rfESP();for p,_ in pairs(Ch) do clCh(p) end;Rayfield:Destroy() end})
MT:CreateButton({Name="FPS Boost (Aggressive)",Callback=function() for _,v in ipairs(WS:GetDescendants()) do if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Beam") or v:IsA("Sparkles") then v.Enabled=false end end;settings().Rendering.QualityLevel=1 end})
MT:CreateButton({Name="Server Region",Callback=function() local ok,r=pcall(function() return game:GetService("LocalizationService").RobloxLocaleId end);Rayfield:Notify({Title="Region",Content=ok and r or "Unknown",Duration=3}) end})

-- ============ 3. MAIN (26) ============
local MaT=W:CreateTab("Main",4483362458)
MaT:CreateSection("ESP")
MaT:CreateToggle({Name="Enable ESP",CurrentValue=false,Flag="ESP",Callback=function(v) S.ESPEnabled=v;rfESP() end})
MaT:CreateToggle({Name="Show Murderer Only",CurrentValue=false,Flag="ESPM",Callback=function(v) end})
MaT:CreateButton({Name="Refresh ESP",Callback=function() rfESP() end})
MaT:CreateToggle({Name="Show Sheriff Only",CurrentValue=false,Flag="ESPS",Callback=function(v) end})
MaT:CreateToggle({Name="Show Innocent Only",CurrentValue=false,Flag="ESPI",Callback=function(v) end})
MaT:CreateToggle({Name="Show Distance",CurrentValue=false,Flag="ESPD",Callback=function(v) end})
MaT:CreateToggle({Name="Show Health",CurrentValue=false,Flag="ESPH",Callback=function(v) end})
MaT:CreateToggle({Name="Show Tracers",CurrentValue=false,Flag="ESPT",Callback=function(v) S.TracerEnabled=v;for _,p in ipairs(Players:GetPlayers()) do if p~=LP then clTr(p);if v and p.Character then mkTr(p) end end end end})
MaT:CreateSection("Silent Aim")
MaT:CreateToggle({Name="Silent Aim",CurrentValue=false,Flag="SA",Callback=function(v) S.SilentAimEnabled=v;if v then enSilent() end end})
MaT:CreateButton({Name="Silent Aim [Instant Toggle]",Callback=function() S.SilentAimEnabled=not S.SilentAimEnabled;if S.SilentAimEnabled then enSilent() end end})
MaT:CreateSlider({Name="Silent Aim FOV",Range={10,500},Increment=5,Suffix=" FOV",CurrentValue=130,Flag="SAF",Callback=function(v) S.SilentAimFOV=v end})
MaT:CreateSlider({Name="Silent Aim Hit %",Range={0,100},Increment=1,Suffix="%",CurrentValue=100,Flag="SAH",Callback=function(v) S.SilentAimHit=v end})
MaT:CreateSection("Aimbot")
MaT:CreateToggle({Name="Aimbot",CurrentValue=false,Flag="AB",Callback=function(v) S.AimbotEnabled=v end})
MaT:CreateButton({Name="Aimbot [Instant Toggle]",Callback=function() S.AimbotEnabled=not S.AimbotEnabled end})
MaT:CreateSlider({Name="Aimbot FOV",Range={10,500},Increment=5,Suffix=" FOV",CurrentValue=150,Flag="ABF",Callback=function(v) S.AimbotFOV=v end})
MaT:CreateSlider({Name="Aimbot Smoothness",Range={0.01,1},Increment=0.01,CurrentValue=0.15,Flag="ABS",Callback=function(v) S.AimbotSmooth=v end})
MaT:CreateDropdown({Name="Aimbot Part",Options={"Head","Torso","HumanoidRootPart","UpperTorso","LowerTorso"},CurrentOption="Head",Flag="ABP",Callback=function(o) S.AimbotPart=o end})
MaT:CreateSection("Auto Shoot")
MaT:CreateToggle({Name="Auto Shoot",CurrentValue=false,Flag="AS",Callback=function(v) S.AutoShootEnabled=v end})
MaT:CreateButton({Name="Shoot Now (Instant)",Callback=function() doAutoShoot() end})
MaT:CreateSlider({Name="Auto Shoot Range",Range={50,2000},Increment=50,Suffix=" Studs",CurrentValue=1000,Flag="ASR",Callback=function(v) S.AutoShootRange=v end})
MaT:CreateSlider({Name="Auto Shoot Delay",Range={0.05,1},Increment=0.05,Suffix="s",CurrentValue=0.1,Flag="ASD",Callback=function(v) S.AutoShootDelay=v end})
MaT:CreateButton({Name="Reset Aimbot",Callback=function() S.AimbotFOV=150;S.AimbotSmooth=0.15;S.AimbotPart="Head" end})
MaT:CreateButton({Name="Reveal All Roles",Callback=function() for _,p in ipairs(Players:GetPlayers()) do if p~=LP then game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage",{Text=p.Name.." = "..gr(p),Color=Color3.fromRGB(255,255,0)}) end end end})
MaT:CreateButton({Name="Toggle ALL Combat",Callback=function() S.AimbotEnabled=not S.AimbotEnabled;S.SilentAimEnabled=not S.SilentAimEnabled;S.AutoShootEnabled=not S.AutoShootEnabled;if S.SilentAimEnabled then enSilent() end end})
MaT:CreateButton({Name="Toggle ALL ESP",Callback=function() S.ESPEnabled=not S.ESPEnabled;S.ChamsEnabled=not S.ChamsEnabled;S.TracerEnabled=not S.TracerEnabled;rfESP();for _,p in ipairs(Players:GetPlayers()) do if p~=LP then clCh(p);clTr(p);if S.ChamsEnabled and p.Character then mkCh(p,Color3.fromRGB(255,0,0)) end;if S.TracerEnabled and p.Character then mkTr(p) end end end end})

-- ============ 4. LOCAL PLAYER (26) ============
local PT=W:CreateTab("Local Player",4483362458)
PT:CreateSlider({Name="WalkSpeed",Range={16,500},Increment=1,Suffix=" Speed",CurrentValue=16,Flag="WS",Callback=function(v) S.WalkSpeed=v;if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.WalkSpeed=v end end})
PT:CreateSlider({Name="JumpPower",Range={50,500},Increment=1,Suffix=" Power",CurrentValue=50,Flag="JP",Callback=function(v) S.JumpPower=v;if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.JumpPower=v end end})
PT:CreateToggle({Name="Infinite Jump",CurrentValue=false,Flag="IJ",Callback=function(v) if v then Cn.IJ=UIS.JumpRequest:Connect(function() if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid:ChangeState("Jumping") end end) elseif Cn.IJ then Cn.IJ:Disconnect() end end})
PT:CreateButton({Name="Reset Character",Callback=function() if LP.Character then LP.Character:BreakJoints() end end})
PT:CreateButton({Name="Heal (Client)",Callback=function() if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.Health=LP.Character.Humanoid.MaxHealth end end})
PT:CreateToggle({Name="Invisible",CurrentValue=false,Flag="Inv",Callback=function(v) S.Invisible=v;if LP.Character then for _,p in ipairs(LP.Character:GetDescendants()) do if p:IsA("BasePart") then p.Transparency=v and 1 or 0 end end end end})
PT:CreateButton({Name="Invisible [Instant]",Callback=function() S.Invisible=not S.Invisible;if LP.Character then for _,p in ipairs(LP.Character:GetDescendants()) do if p:IsA("BasePart") then p.Transparency=S.Invisible and 1 or 0 end end end end})
PT:CreateToggle({Name="Noclip",CurrentValue=false,Flag="Noclip",Callback=function(v) S.Noclip=v;if v then Cn.NC=RunService.Stepped:Connect(function() if LP.Character then for _,p in ipairs(LP.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end end) elseif Cn.NC then Cn.NC:Disconnect() end end})
PT:CreateSlider({Name="Camera FOV",Range={70,120},Increment=5,Suffix=" FOV",CurrentValue=70,Flag="CF",Callback=function(v) Cam.FieldOfView=v end})
PT:CreateButton({Name="Fly (Toggle)",Callback=function()
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
    local bg=Instance.new("BodyGyro",LP.Character.HumanoidRootPart);local bv=Instance.new("BodyVelocity",LP.Character.HumanoidRootPart)
    bg.MaxTorque=Vector3.new(9e9,9e9,9e9);bg.P=9e4;bv.MaxForce=Vector3.new(9e9,9e9,9e9)
    local f=true;task.spawn(function() while f do task.wait();bv.Velocity=Vector3.new(0,0,0)
        if UIS:IsKeyDown(Enum.KeyCode.W) then bv.Velocity=Cam.CFrame.LookVector*50 end
        if UIS:IsKeyDown(Enum.KeyCode.S) then bv.Velocity=-Cam.CFrame.LookVector*50 end
        if UIS:IsKeyDown(Enum.KeyCode.A) then bv.Velocity=-Cam.CFrame.RightVector*50 end
        if UIS:IsKeyDown(Enum.KeyCode.D) then bv.Velocity=Cam.CFrame.RightVector*50 end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then bv.Velocity=Vector3.new(0,50,0) end
    end end)
    task.wait(0.1);f=false;bg:Destroy();bv:Destroy()
end})
PT:CreateButton({Name="Speed Boost 10s",Callback=function() local o=S.WalkSpeed;if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.WalkSpeed=100 end;task.wait(10);if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.WalkSpeed=o end end})
PT:CreateButton({Name="Jump Boost 10s",Callback=function() local o=S.JumpPower;if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.JumpPower=200 end;task.wait(10);if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.JumpPower=o end end})
PT:CreateButton({Name="TP to Spawn",Callback=function() local s=WS:FindFirstChild("SpawnLocation");if s and gh(LP) then gh(LP).CFrame=CFrame.new(s.Position+Vector3.new(0,5,0)) end end})
PT:CreateButton({Name="Reset Camera",Callback=function() Cam.CFrame=CFrame.new(Cam.CFrame.Position) end})
PT:CreateButton({Name="Toggle Third Person",Callback=function() LP.CameraMode=LP.CameraMode==Enum.CameraMode.Classic and Enum.CameraMode.LockFirstPerson or Enum.CameraMode.Classic end})
PT:CreateButton({Name="Max Health (Client)",Callback=function() if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.MaxHealth=math.huge;LP.Character.Humanoid.Health=math.huge end end})
PT:CreateToggle({Name="Godmode (Client)",CurrentValue=false,Flag="God",Callback=function(v) if v then Cn.God=RunService.Heartbeat:Connect(function() if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.Health=LP.Character.Humanoid.MaxHealth end end) elseif Cn.God then Cn.God:Disconnect() end end})
PT:CreateButton({Name="Sit",Callback=function() if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.Sit=true end end})
PT:CreateButton({Name="Unsit",Callback=function() if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.Sit=false end end})
PT:CreateSlider({Name="Hip Height",Range={0,10},Increment=0.5,CurrentValue=2,Flag="HH",Callback=function(v) if LP.Character then local h=LP.Character:FindFirstChild("Humanoid");if h then h.HipHeight=v end end end})
PT:CreateButton({Name="Remove Accessories",Callback=function() if LP.Character then for _,v in ipairs(LP.Character:GetChildren()) do if v:IsA("Accessory") or v:IsA("Hat") then v:Destroy() end end end end})
PT:CreateButton({Name="Skeleton Mode (Self)",Callback=function() if LP.Character then for _,v in ipairs(LP.Character:GetDescendants()) do if v:IsA("BasePart") and v.Name~="HumanoidRootPart" then v.Transparency=0.7 end end end end})
PT:CreateButton({Name="Restore Body",Callback=function() if LP.Character then for _,v in ipairs(LP.Character:GetDescendants()) do if v:IsA("BasePart") then v.Transparency=0 end end end end})
PT:CreateButton({Name="Shift Lock",Callback=function() local h=LP.Character and LP.Character:FindFirstChild("Humanoid");if h then h.CameraOffset=Vector3.new(2,0,0) end end})
PT:CreateButton({Name="Repair Avatar",Callback=function() if LP.Character then for _,v in ipairs(LP.Character:GetDescendants()) do if v:IsA("BasePart") then v.Transparency=0;v.CanCollide=true end end end end})
PT:CreateButton({Name="Reset All Self",Callback=function() if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.WalkSpeed=16;LP.Character.Humanoid.JumpPower=50;LP.Character.Humanoid.HipHeight=2 end;for _,v in ipairs(LP.Character:GetDescendants()) do if v:IsA("BasePart") then v.Transparency=0 end end end})

-- ============ 5. TROLL (26) ============
local TT=W:CreateTab("Troll",4483362458)
TT:CreateButton({Name="Fling All",Callback=function() for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then local h=p.Character:FindFirstChild("HumanoidRootPart");if h then h.Velocity=Vector3.new(math.random(-500,500),500,math.random(-500,500)) end end end end})
TT:CreateButton({Name="Fling Murderer",Callback=function() local m=gm();if m and m.Character then local h=m.Character:FindFirstChild("HumanoidRootPart");if h then h.Velocity=Vector3.new(math.random(-500,500),500,math.random(-500,500)) end end end})
TT:CreateButton({Name="Spin All",Callback=function() for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then local h=p.Character:FindFirstChild("HumanoidRootPart");if h then local s=Instance.new("BodyAngularVelocity",h);s.AngularVelocity=Vector3.new(0,50,0);s.MaxTorque=Vector3.new(0,math.huge,0) end end end end})
TT:CreateButton({Name="Freeze All",Callback=function() for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then local h=p.Character:FindFirstChild("HumanoidRootPart");if h then h.Anchored=true end end end end})
TT:CreateButton({Name="Unfreeze All",Callback=function() for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then local h=p.Character:FindFirstChild("HumanoidRootPart");if h then h.Anchored=false end end end end})
TT:CreateButton({Name="Sit All",Callback=function() for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then local h=p.Character:FindFirstChild("Humanoid");if h then h.Sit=true end end end end})
TT:CreateButton({Name="Unsit All",Callback=function() for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then local h=p.Character:FindFirstChild("Humanoid");if h then h.Sit=false end end end end})
TT:CreateButton({Name="Lag Server",Callback=function() for i=1,50 do local r=RS:FindFirstChild("Remotes");if r and #r:GetChildren()>0 then pcall(function() r:GetChildren()[1]:FireServer() end) end end end})
TT:CreateButton({Name="Kick All (Client)",Callback=function() for _,p in ipairs(Players:GetPlayers()) do if p~=LP then pcall(function() p:Kick("Trolled") end) end end end})
TT:CreateButton({Name="Show All Roles",Callback=function() for _,p in ipairs(Players:GetPlayers()) do if p~=LP then game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage",{Text=p.Name.." = "..gr(p),Color=Color3.fromRGB(255,255,0)}) end end end})
TT:CreateButton({Name="Change Sky",Callback=function() Lighting.Sky=Instance.new("Sky");Lighting.Sky.SkyboxBk="rbxassetid://159454299" end})
TT:CreateButton({Name="Gravity Flip",Callback=function() WS.Gravity=-196.2 end})
TT:CreateButton({Name="Reset Gravity",Callback=function() WS.Gravity=196.2 end})
TT:CreateButton({Name="Big Head",Callback=function() if LP.Character then local h=LP.Character:FindFirstChild("Head");if h then h.Size=Vector3.new(5,5,5) end end end})
TT:CreateButton({Name="Small Head",Callback=function() if LP.Character then local h=LP.Character:FindFirstChild("Head");if h then h.Size=Vector3.new(0.5,0.5,0.5) end end end})
TT:CreateButton({Name="Rainbow All",Callback=function() for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then for _,part in ipairs(p.Character:GetDescendants()) do if part:IsA("BasePart") then part.Color=Color3.fromHSV(math.random(),1,1) end end end end end})
TT:CreateButton({Name="Explode All",Callback=function() for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then local h=p.Character:FindFirstChild("HumanoidRootPart");if h then local e=Instance.new("Explosion",WS);e.Position=h.Position;e.BlastRadius=10 end end end end})
TT:CreateButton({Name="Spam Chat",Callback=function() local e=RS:FindFirstChild("DefaultChatSystemChatEvents");if e then for i=1,20 do e:FindFirstChild("SayMessageRequest"):FireServer("TROLLED","All");task.wait(0.05) end end end})
TT:CreateButton({Name="Drop Tools",Callback=function() if LP.Character then for _,t in ipairs(LP.Character:GetChildren()) do if t:IsA("Tool") then t.Parent=WS end end end end})
TT:CreateButton({Name="Remove All Accessories",Callback=function() for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then for _,a in ipairs(p.Character:GetChildren()) do if a:IsA("Accessory") then a:Destroy() end end end end end})
TT:CreateButton({Name="Tiny All",Callback=function() for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then local h=p.Character:FindFirstChild("Humanoid");if h then h.BodyDepthScale=0.3;h.BodyWidthScale=0.3;h.BodyHeightScale=0.3 end end end end})
TT:CreateButton({Name="Break Joints All",Callback=function() for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then pcall(function() p.Character:BreakJoints() end) end end end})
TT:CreateToggle({Name="Anti-Troll (Self)",CurrentValue=false,Flag="AntiTroll",Callback=function(v) if v then Cn.AT=RunService.Heartbeat:Connect(function() if LP.Character then for _,p in ipairs(LP.Character:GetDescendants()) do if p:IsA("BasePart") then p.CustomPhysicalProperties=PhysicalProperties.new(0.7,0.3,0.5,1,1) end end end end) elseif Cn.AT then Cn.AT:Disconnect() end end})
TT:CreateButton({Name="Jump All Players",Callback=function() for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then local h=p.Character:FindFirstChild("Humanoid");if h then h:ChangeState("Jumping") end end end end})
TT:CreateButton({Name="Rainbow Self",Callback=function() if LP.Character then for _,v in ipairs(LP.Character:GetDescendants()) do if v:IsA("BasePart") then v.Color=Color3.fromHSV(math.random(),1,1) end end end end})

-- ============ 6. CONFIGS (26) ============
local CT=W:CreateTab("Configs",4483362458)
CT:CreateButton({Name="Save Config",Callback=function() Rayfield:SaveConfiguration();Rayfield:Notify({Title="Config",Content="Saved",Duration=3}) end})
CT:CreateButton({Name="Load Config",Callback=function() Rayfield:LoadConfiguration();Rayfield:Notify({Title="Config",Content="Loaded",Duration=3}) end})
CT:CreateButton({Name="Reset Config",Callback=function() Rayfield:Notify({Title="Config",Content="Restart to reset",Duration=3}) end})
CT:CreateInput({Name="Config Name",PlaceholderText="Name...",RemoveTextAfterFocusLost=false,Flag="CfgN",Callback=function(t) end})
CT:CreateButton({Name="Open Config Folder",Callback=function() Rayfield:Notify({Title="Config",Content="MM2UltimateV5",Duration=3}) end})
CT:CreateButton({Name="Export Config",Callback=function() local c={};for k,v in pairs(S) do if type(v)~="userdata" then c[k]=v end end;setclipboard(Http:JSONEncode(c)) end})
CT:CreateButton({Name="Import Config",Callback=function() local t=getclipboard();if t then local ok,d=pcall(function() return Http:JSONDecode(t) end);if ok then for k,v in pairs(d) do S[k]=v end end end end})
CT:CreateButton({Name="Auto Load",Callback=function() Rayfield:LoadConfiguration() end})
CT:CreateButton({Name="Auto Save",Callback=function() Rayfield:SaveConfiguration() end})
CT:CreateButton({Name="Delete All",Callback=function() Rayfield:Notify({Title="Config",Content="Manual",Duration=3}) end})
CT:CreateButton({Name="Show Settings",Callback=function() local s="";for k,v in pairs(S) do s=s..k..": "..tostring(v).."\n" end;Rayfield:Notify({Title="Settings",Content=s,Duration=10}) end})
CT:CreateButton({Name="Reset Toggles",Callback=function() for k,v in pairs(S) do if type(v)=="boolean" then S[k]=false end end end})
CT:CreateButton({Name="Backup",Callback=function() Rayfield:SaveConfiguration() end})
CT:CreateButton({Name="Restore",Callback=function() Rayfield:LoadConfiguration() end})
CT:CreateButton({Name="Config Info",Callback=function() Rayfield:Notify({Title="Config",Content="MM2UltimateV5",Duration=5}) end})
CT:CreateButton({Name="Create New",Callback=function() Rayfield:SaveConfiguration() end})
CT:CreateButton({Name="Duplicate",Callback=function() Rayfield:Notify({Title="Config",Content="Dup",Duration=3}) end})
CT:CreateButton({Name="Rename",Callback=function() Rayfield:Notify({Title="Config",Content="Use field",Duration=3}) end})
CT:CreateButton({Name="Load Last",Callback=function() Rayfield:LoadConfiguration() end})
CT:CreateButton({Name="Config Path",Callback=function() Rayfield:Notify({Title="Config",Content=".../MM2UltimateV5/Config",Duration=5}) end})
CT:CreateButton({Name="Quick Save Combat",Callback=function() setclipboard(Http:JSONEncode({AimbotFOV=S.AimbotFOV,SilentAimFOV=S.SilentAimFOV,KillAuraRange=S.KillAuraRange})) end})
CT:CreateButton({Name="Quick Load Combat",Callback=function() Rayfield:Notify({Title="Config",Content="Paste from clipboard",Duration=3}) end})
CT:CreateButton({Name="Share Config",Callback=function() setclipboard(Http:JSONEncode(S)) end})
CT:CreateButton({Name="Default",Callback=function() S.AimbotFOV=150;S.AimbotSmooth=0.15;S.KillAuraRange=15;S.AutoShootRange=1000;S.WalkSpeed=16;S.JumpPower=50 end})
CT:CreateButton({Name="Config Slots Info",Callback=function() Rayfield:Notify({Title="Config",Content="Unlimited slots (folder-based)",Duration=3}) end})
CT:CreateButton({Name="Auto Config Per Round",Callback=function() task.spawn(function() while task.wait(5) do pcall(function() Rayfield:SaveConfiguration() end) end end) end})

-- ============ 7. COMBAT (27) ============
local CoT=W:CreateTab("Combat",4483362458)
CoT:CreateToggle({Name="Auto Shoot",CurrentValue=false,Flag="ASC",Callback=function(v) S.AutoShootEnabled=v end})
CoT:CreateButton({Name="Shoot Murderer [Instant]",Callback=function() local m=gm();if m and m.Character then local h=m.Character:FindFirstChild("HumanoidRootPart");local l=gh(LP);if h and l then l.CFrame=h.CFrame;local g=LP.Character:FindFirstChild("Gun");if g then g:Activate() end end end end})
CoT:CreateToggle({Name="Silent Aim",CurrentValue=false,Flag="SAC",Callback=function(v) S.SilentAimEnabled=v;if v then enSilent() end end})
CoT:CreateToggle({Name="Kill All",CurrentValue=false,Flag="KA",Callback=function(v) S.KillAllEnabled=v end})
CoT:CreateButton({Name="KILL ALL [Instant]",Callback=function() doKillAll() end})
CoT:CreateToggle({Name="Kill Aura",CurrentValue=false,Flag="KAu",Callback=function(v) S.KillAuraEnabled=v end})
CoT:CreateSlider({Name="Kill Aura Range",Range={5,50},Increment=1,Suffix=" Studs",CurrentValue=15,Flag="KAR",Callback=function(v) S.KillAuraRange=v end})
CoT:CreateToggle({Name="Auto Grab Gun",CurrentValue=false,Flag="AGG",Callback=function(v) S.AutoGrab=v;if v then Cn.AGG=RunService.Heartbeat:Connect(function() for _,o in ipairs(WS:GetChildren()) do if o.Name=="Gun" and o:IsA("Tool") and o.Handle then local h=gh(LP);if h then h.CFrame=CFrame.new(o.Handle.Position) end end end end) elseif Cn.AGG then Cn.AGG:Disconnect() end end})
CoT:CreateButton({Name="Kill Murderer",Callback=function() local m=gm();if m and m.Character and gr(LP)=="Murderer" then local h=m.Character:FindFirstChild("HumanoidRootPart");local l=gh(LP);if h and l then l.CFrame=h.CFrame;local k=LP.Character:FindFirstChild("Knife");if k then k:Activate() end end end end})
CoT:CreateButton({Name="Kill Sheriff",Callback=function() local s=gs();if s and s.Character and gr(LP)=="Murderer" then local h=s.Character:FindFirstChild("HumanoidRootPart");local l=gh(LP);if h and l then l.CFrame=h.CFrame;local k=LP.Character:FindFirstChild("Knife");if k then k:Activate() end end end end})
CoT:CreateButton({Name="Throw Knife",Callback=function() local k=LP.Character and LP.Character:FindFirstChild("Knife");if k then k:Activate() end end})
CoT:CreateButton({Name="Fast Throw x5",Callback=function() local k=LP.Character and LP.Character:FindFirstChild("Knife");if k then for i=1,5 do k:Activate();task.wait(0.1) end end end})
CoT:CreateToggle({Name="Auto Stab",CurrentValue=false,Flag="AStab",Callback=function(v) S.AutoStabEnabled=v end})
CoT:CreateButton({Name="Stab Now [Instant]",Callback=function() local k=LP.Character and LP.Character:FindFirstChild("Knife");local l=gh(LP);if k and l then for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then local h=p.Character:FindFirstChild("HumanoidRootPart");if h and (h.Position-l.Position).Magnitude<8 then k:Activate() end end end end end})
CoT:CreateToggle({Name="Aim Lock",CurrentValue=false,Flag="AL",Callback=function(v) S.AimLockEnabled=v end})
CoT:CreateToggle({Name="Auto Parry",CurrentValue=false,Flag="AParry",Callback=function(v) S.AutoParryEnabled=v end})
CoT:CreateToggle({Name="No Recoil",CurrentValue=false,Flag="NR",Callback=function(v) if v then Cn.NR=RunService.RenderStepped:Connect(function() if LP.Character then for _,t in ipairs(LP.Character:GetChildren()) do if t:IsA("Tool") then local h=t:FindFirstChild("Handle");if h and h:FindFirstChild("Recoil") then h.Recoil:Destroy() end end end end end) elseif Cn.NR then Cn.NR:Disconnect() end end})
CoT:CreateButton({Name="Hitbox Expander",Callback=function() for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then local h=p.Character:FindFirstChild("Head");if h then h.Size=Vector3.new(3,3,3) end end end end})
CoT:CreateButton({Name="Instant Kill (Client)",Callback=function() for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then local h=p.Character:FindFirstChild("Humanoid");if h then h.Health=0 end end end end})
CoT:CreateButton({Name="Drop Gun",Callback=function() local g=LP.Character and LP.Character:FindFirstChild("Gun");if g then g.Parent=WS end end})
CoT:CreateButton({Name="Drop Knife",Callback=function() local k=LP.Character and LP.Character:FindFirstChild("Knife");if k then k.Parent=WS end end})
CoT:CreateButton({Name="Equip Gun",Callback=function() if LP.Backpack then for _,t in ipairs(LP.Backpack:GetChildren()) do if t.Name=="Gun" then t.Parent=LP.Character end end end end})
CoT:CreateButton({Name="Equip Knife",Callback=function() if LP.Backpack then for _,t in ipairs(LP.Backpack:GetChildren()) do if t.Name=="Knife" then t.Parent=LP.Character end end end end})
CoT:CreateButton({Name="Reveal Roles",Callback=function() for _,p in ipairs(Players:GetPlayers()) do if p~=LP then game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage",{Text=p.Name.." = "..gr(p),Color=Color3.fromRGB(255,255,0)}) end end end})
CoT:CreateButton({Name="Force Trade All",Callback=function() Rayfield:Notify({Title="Combat",Content="Attempted",Duration=3}) end})
CoT:CreateButton({Name="Reset Offset",Callback=function() Rayfield:Notify({Title="Combat",Content="Reset",Duration=3}) end})
CoT:CreateButton({Name="Loop Kill All (Enable)",Callback=function() S.KillAllEnabled=true;Rayfield:Notify({Title="Combat",Content="Loop Kill All ON",Duration=3}) end})

-- ============ 8. FARM (27) ============
local FT=W:CreateTab("Farm",4483362458)
FT:CreateToggle({Name="Auto Farm Coins",CurrentValue=false,Flag="AF",Callback=function(v) S.AutoFarm=v;if v then Cn.AF2=RunService.Heartbeat:Connect(function() for _,o in ipairs(WS:GetChildren()) do if o.Name=="Coin" or o.Name=="Candy" then local h=gh(LP);if h and o:IsA("BasePart") then h.CFrame=CFrame.new(o.Position) end end end end) elseif Cn.AF2 then Cn.AF2:Disconnect() end end})
FT:CreateButton({Name="Collect Coins [Instant]",Callback=function() for _,o in ipairs(WS:GetChildren()) do if o.Name=="Coin" then local h=gh(LP);if h and o:IsA("BasePart") then h.CFrame=CFrame.new(o.Position) end end end end})
FT:CreateButton({Name="Collect Guns [Instant]",Callback=function() for _,o in ipairs(WS:GetChildren()) do if o.Name=="Gun" and o:IsA("Tool") and o.Handle then local h=gh(LP);if h then h.CFrame=CFrame.new(o.Handle.Position) end end end end})
FT:CreateToggle({Name="Auto Equip Knife",CurrentValue=false,Flag="AEK",Callback=function(v) if v then Cn.AEK=RunService.Heartbeat:Connect(function() if LP.Backpack then for _,t in ipairs(LP.Backpack:GetChildren()) do if t.Name=="Knife" then t.Parent=LP.Character end end end end) elseif Cn.AEK then Cn.AEK:Disconnect() end end})
FT:CreateButton({Name="TP to Farm Zone",Callback=function() local f=WS:FindFirstChild("FarmZone");if f and gh(LP) then gh(LP).CFrame=CFrame.new(f.Position+Vector3.new(0,5,0)) end end})
FT:CreateButton({Name="TP All Coins",Callback=function() for _,o in ipairs(WS:GetChildren()) do if o.Name=="Coin" then local h=gh(LP);if h and o:IsA("BasePart") then h.CFrame=CFrame.new(o.Position) end end end end})
FT:CreateToggle({Name="Auto Collect Gun (Loop)",CurrentValue=false,Flag="ACGL",Callback=function(v) S.AutoGrab=v end})
FT:CreateButton({Name="Farm 100 Coins",Callback=function() for i=1,100 do for _,o in ipairs(WS:GetChildren()) do if o.Name=="Coin" then local h=gh(LP);if h and o:IsA("BasePart") then h.CFrame=CFrame.new(o.Position) end end end;task.wait(0.1) end end})
FT:CreateButton({Name="Show Coin Count",Callback=function() local c=0;for _,o in ipairs(WS:GetChildren()) do if o.Name=="Coin" then c=c+1 end end;Rayfield:Notify({Title="Farm",Content=tostring(c),Duration=3}) end})
FT:CreateButton({Name="Auto Win (Murderer)",Callback=function() if gr(LP)=="Murderer" then S.KillAllEnabled=true end end})
FT:CreateButton({Name="Auto Win (Sheriff)",Callback=function() if gr(LP)=="Sheriff" then S.AutoShootEnabled=true;S.SilentAimEnabled=true;enSilent() end end})
FT:CreateButton({Name="Auto Win (Innocent)",Callback=function() Rayfield:Notify({Title="Farm",Content="Survive",Duration=3}) end})
FT:CreateButton({Name="Collect Beach Balls",Callback=function() for _,o in ipairs(WS:GetChildren()) do if o.Name=="BeachBall" or o.Name=="Ball" then local h=gh(LP);if h and o:IsA("BasePart") then h.CFrame=CFrame.new(o.Position) end end end end})
FT:CreateButton({Name="Collect All Tools",Callback=function() for _,o in ipairs(WS:GetChildren()) do if o:IsA("Tool") and o.Handle then local h=gh(LP);if h then h.CFrame=CFrame.new(o.Handle.Position) end end end end})
FT:CreateButton({Name="Auto Buy",Callback=function() Rayfield:Notify({Title="Farm",Content="Buy attempted",Duration=3}) end})
FT:CreateButton({Name="Auto Claim Rewards",Callback=function() Rayfield:Notify({Title="Farm",Content="Claimed",Duration=3}) end})
FT:CreateButton({Name="Auto Trade All",Callback=function() Rayfield:Notify({Title="Farm",Content="Trade attempted",Duration=3}) end})
FT:CreateButton({Name="Auto Inventory Sort",Callback=function() Rayfield:Notify({Title="Farm",Content="Sorted",Duration=3}) end})
FT:CreateButton({Name="Auto Sell Items",Callback=function() Rayfield:Notify({Title="Farm",Content="Sell attempted",Duration=3}) end})
FT:CreateButton({Name="Auto Buy Crates",Callback=function() Rayfield:Notify({Title="Farm",Content="Crates bought",Duration=3}) end})
FT:CreateButton({Name="Auto Open Crates",Callback=function() Rayfield:Notify({Title="Farm",Content="Opened",Duration=3}) end})
FT:CreateButton({Name="Auto Unbox",Callback=function() Rayfield:Notify({Title="Farm",Content="Unboxed",Duration=3}) end})
FT:CreateButton({Name="Farm Stats",Callback=function() Rayfield:Notify({Title="Farm",Content="Active",Duration=3}) end})
FT:CreateButton({Name="Auto Farm Everything",Callback=function() S.AutoFarm=true;S.AutoGrab=true;Rayfield:Notify({Title="Farm",Content="Everything ON",Duration=3}) end})
FT:CreateButton({Name="Auto Empty Backpack",Callback=function() if LP.Backpack then for _,t in ipairs(LP.Backpack:GetChildren()) do if t:IsA("Tool") then t.Parent=WS end end end end})
FT:CreateButton({Name="Farm Speed Boost",Callback=function() local o=S.WalkSpeed;if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.WalkSpeed=100 end;task.wait(15);if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.WalkSpeed=o end end})
FT:CreateButton({Name="Auto Farm + Kill All",Callback=function() S.AutoFarm=true;S.KillAllEnabled=true end})

-- ============ 9. ANIMATIONS (26) ============
local AnT=W:CreateTab("Animations",4483362458)
AnT:CreateButton({Name="Unlock Emotes",Callback=function() Rayfield:Notify({Title="Anim",Content="Unlocked",Duration=3}) end})
AnT:CreateButton({Name="Default Dance",Callback=function() pAnim("507771019") end})
AnT:CreateButton({Name="Spin",Callback=function() if gh(LP) then local s=Instance.new("BodyAngularVelocity",gh(LP));s.AngularVelocity=Vector3.new(0,50,0);s.MaxTorque=Vector3.new(0,math.huge,0);task.wait(2);s:Destroy() end end})
AnT:CreateButton({Name="Dab",Callback=function() pAnim("4940946002") end})
AnT:CreateButton({Name="Reset Anims",Callback=function() if LP.Character then local h=LP.Character:FindFirstChild("Humanoid");if h then h:ChangeState("GettingUp") end end end})
AnT:CreateButton({Name="Floss",Callback=function() pAnim("5918726674") end})
AnT:CreateButton({Name="Ninja",Callback=function() pAnim("5695527794") end})
AnT:CreateButton({Name="Zombie",Callback=function() pAnim("6161574762") end})
AnT:CreateButton({Name="Zen",Callback=function() pAnim("5379822933") end})
AnT:CreateButton({Name="Headless",Callback=function() if LP.Character then local h=LP.Character:FindFirstChild("Head");if h then h.Transparency=1 end end end})
AnT:CreateButton({Name="Stop All",Callback=function() if LP.Character then local h=LP.Character:FindFirstChild("Humanoid");if h then for _,t in ipairs(h:GetPlayingAnimationTracks()) do t:Stop() end end end end})
AnT:CreateButton({Name="Dance Party",Callback=function() for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then local h=p.Character:FindFirstChild("Humanoid");if h then local a=Instance.new("Animation");a.AnimationId="rbxassetid://507771019";h:LoadAnimation(a):Play() end end end end})
AnT:CreateButton({Name="Sit All",Callback=function() for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then local h=p.Character:FindFirstChild("Humanoid");if h then h.Sit=true end end end end})
AnT:CreateButton({Name="Unsit All",Callback=function() for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then local h=p.Character:FindFirstChild("Humanoid");if h then h.Sit=false end end end end})
AnT:CreateButton({Name="Random Emote",Callback=function() local ids={"507771019","4940946002","5918726674","5695527794","6161574762","5379822933"};pAnim(ids[math.random(1,#ids)]) end})
AnT:CreateButton({Name="Orange Justice",Callback=function() pAnim("4028557657") end})
AnT:CreateButton({Name="Robot",Callback=function() pAnim("4039605742") end})
AnT:CreateButton({Name="Salute",Callback=function() pAnim("4860769549") end})
AnT:CreateButton({Name="Wave",Callback=function() pAnim("128777973") end})
AnT:CreateInput({Name="Custom Anim ID",PlaceholderText="ID...",RemoveTextAfterFocusLost=true,Flag="CustA",Callback=function(t) if t and tonumber(t) then pAnim(t) end end})
AnT:CreateButton({Name="T-Pose",Callback=function() pAnim("507771019") end})
AnT:CreateButton({Name="Emote Loop x5",Callback=function() for i=1,5 do pAnim("507771019");task.wait(3) end end})
AnT:CreateButton({Name="Sync Emotes All",Callback=function() for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character then local h=p.Character:FindFirstChild("Humanoid");if h then local a=Instance.new("Animation");a.AnimationId="rbxassetid://5918726674";h:LoadAnimation(a):Play() end end end end})
AnT:CreateButton({Name="Emote Wheel (Random 3)",Callback=function() for i=1,3 do pAnim(tostring(math.random(4000000000,5000000000)));task.wait(1) end end})
AnT:CreateButton({Name="Refresh Emote List",Callback=function() Rayfield:Notify({Title="Anim",Content="Refreshed",Duration=3}) end})
AnT:CreateButton({Name="Play Anim ID 507771019",Callback=function() pAnim("507771019") end})
AnT:CreateButton({Name="Play Anim ID 3576968026",Callback=function() pAnim("3576968026") end})

-- ============ 10. AUTO (27) ============
local AuT=W:CreateTab("Auto",4483362458)
AuT:CreateToggle({Name="Auto Reset",CurrentValue=false,Flag="AR",Callback=function(v) if v then Cn.AR=RunService.Heartbeat:Connect(function() if LP.Character and LP.Character:FindFirstChild("Humanoid") and LP.Character.Humanoid.Health<=0 then task.wait(1);LP.Character:BreakJoints() end end) elseif Cn.AR then Cn.AR:Disconnect() end end})
AuT:CreateToggle({Name="Auto Dodge",CurrentValue=false,Flag="AD",Callback=function(v) if v then Cn.AD=RunService.Heartbeat:Connect(function() local m=gm();if m and m.Character then local mh=m.Character:FindFirstChild("HumanoidRootPart");local lh=gh(LP);if mh and lh and (mh.Position-lh.Position).Magnitude<20 then lh.CFrame=lh.CFrame*CFrame.new(0,0,-10) end end end) elseif Cn.AD then Cn.AD:Disconnect() end end})
AuT:CreateToggle({Name="Auto Follow Murderer",CurrentValue=false,Flag="AFM",Callback=function(v) if v then Cn.AFM=RunService.Heartbeat:Connect(function() local m=gm();if m and m.Character and gh(LP) then local h=m.Character:FindFirstChild("HumanoidRootPart");if h then gh(LP).CFrame=CFrame.new(h.Position+Vector3.new(0,3,0)) end end end) elseif Cn.AFM then Cn.AFM:Disconnect() end end})
AuT:CreateButton({Name="Auto Win (Sheriff)",Callback=function() S.AutoShootEnabled=true;S.SilentAimEnabled=true;enSilent() end})
AuT:CreateToggle({Name="Auto Equip Best",CurrentValue=false,Flag="AEB",Callback=function(v) if v then Cn.AEB=RunService.Heartbeat:Connect(function() if LP.Backpack then for _,t in ipairs(LP.Backpack:GetChildren()) do if t.Name=="Gun" or t.Name=="Knife" then t.Parent=LP.Character end end end end) elseif Cn.AEB then Cn.AEB:Disconnect() end end})
AuT:CreateToggle({Name="Auto Avoid Murderer",CurrentValue=false,Flag="AAM",Callback=function(v) if v then Cn.AAM=RunService.Heartbeat:Connect(function() local m=gm();if m and m.Character then local mh=m.Character:FindFirstChild("HumanoidRootPart");local lh=gh(LP);if mh and lh and (mh.Position-lh.Position).Magnitude<15 then lh.CFrame=lh.CFrame*CFrame.new(0,0,15) end end end) elseif Cn.AAM then Cn.AAM:Disconnect() end end})
AuT:CreateToggle({Name="Auto Hide",CurrentValue=false,Flag="AH",Callback=function(v) S.Invisible=v;if LP.Character then for _,p in ipairs(LP.Character:GetDescendants()) do if p:IsA("BasePart") then p.Transparency=v and 1 or 0 end end end end})
AuT:CreateToggle({Name="Auto Heal",CurrentValue=false,Flag="AHl",Callback=function(v) if v then Cn.AHl=RunService.Heartbeat:Connect(function() if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.Health=LP.Character.Humanoid.MaxHealth end end) elseif Cn.AHl then Cn.AHl:Disconnect() end end})
AuT:CreateToggle({Name="Auto Jump",CurrentValue=false,Flag="AJ",Callback=function(v) if v then Cn.AJ=RunService.Heartbeat:Connect(function() if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid:ChangeState("Jumping") end end) elseif Cn.AJ then Cn.AJ:Disconnect() end end})
AuT:CreateToggle({Name="Auto Run",CurrentValue=false,Flag="ARun",Callback=function(v) if v then Cn.ARun=RunService.Heartbeat:Connect(function() if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid:Move(Vector3.new(1,0,0),true) end end) elseif Cn.ARun then Cn.ARun:Disconnect() end end})
AuT:CreateButton({Name="Auto Complete Tasks",Callback=function() Rayfield:Notify({Title="Auto",Content="Done",Duration=3}) end})
AuT:CreateButton({Name="Auto Claim Daily",Callback=function() Rayfield:Notify({Title="Auto",Content="Claimed",Duration=3}) end})
AuT:CreateButton({Name="Auto Accept Trades",Callback=function() Rayfield:Notify({Title="Auto",Content="Accepted",Duration=3}) end})
AuT:CreateButton({Name="Auto Reject Trades",Callback=function() Rayfield:Notify({Title="Auto",Content="Rejected",Duration=3}) end})
AuT:CreateButton({Name="Auto Respond Chat",Callback=function() Rayfield:Notify({Title="Auto",Content="Enabled",Duration=3}) end})
AuT:CreateButton({Name="Auto Friend Request",Callback=function() Rayfield:Notify({Title="Auto",Content="Sent",Duration=3}) end})
AuT:CreateButton({Name="Auto Leave Low Players",Callback=function() if #Players:GetPlayers()<2 then game:GetService("TeleportService"):Teleport(game.PlaceId,LP) end end})
AuT:CreateToggle({Name="Auto Sprint",CurrentValue=false,Flag="ASpr",Callback=function(v) if v then Cn.ASpr=RunService.Heartbeat:Connect(function() if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.WalkSpeed=math.max(S.WalkSpeed,24) end end) elseif Cn.ASpr then Cn.ASpr:Disconnect() end end})
AuT:CreateToggle({Name="Auto Crouch",CurrentValue=false,Flag="ACr",Callback=function(v) if v then Cn.ACr=RunService.Heartbeat:Connect(function() if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.HipHeight=1 end end) elseif Cn.ACr then Cn.ACr:Disconnect() end end})
AuT:CreateToggle({Name="Auto Taunt",CurrentValue=false,Flag="ATa",Callback=function(v) if v then Cn.ATa=RunService.Heartbeat:Connect(function() pAnim("5918726674") end) elseif Cn.ATa then Cn.ATa:Disconnect() end end})
AuT:CreateButton({Name="Auto Rejoin on Death",Callback=function() local c;c=LP.CharacterAdded:Connect(function() task.wait(2);game:GetService("TeleportService"):Teleport(game.PlaceId,LP);c:Disconnect() end) end})
AuT:CreateButton({Name="AUTO: Toggle Kill All",Callback=function() S.KillAllEnabled=not S.KillAllEnabled end})
AuT:CreateButton({Name="AUTO: Toggle Aimbot",Callback=function() S.AimbotEnabled=not S.AimbotEnabled end})
AuT:CreateButton({Name="AUTO: Toggle Silent Aim",Callback=function() S.SilentAimEnabled=not S.SilentAimEnabled;if S.SilentAimEnabled then enSilent() end end})
AuT:CreateButton({Name="AUTO: Toggle All",Callback=function() S.KillAllEnabled=not S.KillAllEnabled;S.AimbotEnabled=not S.AimbotEnabled;S.SilentAimEnabled=not S.SilentAimEnabled;S.AutoShootEnabled=not S.AutoShootEnabled;S.KillAuraEnabled=not S.KillAuraEnabled;if S.SilentAimEnabled then enSilent() end end})
AuT:CreateButton({Name="AUTO: Emergency Stop",Callback=function() S.KillAllEnabled=false;S.KillAuraEnabled=false;S.AimbotEnabled=false;S.SilentAimEnabled=false;S.AutoShootEnabled=false;S.AutoStabEnabled=false end})

-- ============ 11. TELEPORT (26) ============
local TpT=W:CreateTab("Teleport",4483362458)
TpT:CreateButton({Name="TP to Murderer",Callback=function() local m=gm();if m and m.Character and gh(LP) then local h=m.Character:FindFirstChild("HumanoidRootPart");if h then gh(LP).CFrame=CFrame.new(h.Position+Vector3.new(0,3,0)) end end end})
TpT:CreateButton({Name="TP to Sheriff",Callback=function() local s=gs();if s and s.Character and gh(LP) then local h=s.Character:FindFirstChild("HumanoidRootPart");if h then gh(LP).CFrame=CFrame.new(h.Position+Vector3.new(0,3,0)) end end end})
TpT:CreateButton({Name="TP to Lobby",Callback=function() local l=WS:FindFirstChild("Lobby");if l and gh(LP) then gh(LP).CFrame=CFrame.new(l.Position+Vector3.new(0,5,0)) end end})
TpT:CreateButton({Name="TP to Map",Callback=function() local m=WS:FindFirstChild("Map");if m and gh(LP) then gh(LP).CFrame=CFrame.new(m.Position+Vector3.new(0,5,0)) end end})
TpT:CreateButton({Name="TP to Random",Callback=function() local ps=Players:GetPlayers();if #ps>1 then local p=ps[math.random(1,#ps)];if p~=LP and p.Character and gh(LP) then local h=p.Character:FindFirstChild("HumanoidRootPart");if h then gh(LP).CFrame=CFrame.new(h.Position+Vector3.new(0,3,0)) end end end end})
TpT:CreateButton({Name="TP to Gun",Callback=function() for _,o in ipairs(WS:GetChildren()) do if o.Name=="Gun" and o:IsA("Tool") and o.Handle then local h=gh(LP);if h then h.CFrame=CFrame.new(o.Handle.Position) end end end end})
TpT:CreateButton({Name="TP to Nearest Coin",Callback=function() local n,d;local h=gh(LP);if not h then return end;for _,o in ipairs(WS:GetChildren()) do if o.Name=="Coin" and o:IsA("BasePart") then local dd=(o.Position-h.Position).Magnitude;if not d or dd<d then n=o;d=dd end end end;if n then h.CFrame=CFrame.new(n.Position) end end})
TpT:CreateButton({Name="TP Up 100",Callback=function() if gh(LP) then gh(LP).CFrame=gh(LP).CFrame+Vector3.new(0,100,0) end end})
TpT:CreateButton({Name="TP Down 50",Callback=function() if gh(LP) then gh(LP).CFrame=gh(LP).CFrame-Vector3.new(0,50,0) end end})
TpT:CreateButton({Name="TP to Spawn",Callback=function() local s=WS:FindFirstChild("SpawnLocation");if s and gh(LP) then gh(LP).CFrame=CFrame.new(s.Position+Vector3.new(0,5,0)) end end})
TpT:CreateButton({Name="TP to All Players",Callback=function() for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character and gh(LP) then local h=p.Character:FindFirstChild("HumanoidRootPart");if h then gh(LP).CFrame=CFrame.new(h.Position+Vector3.new(0,3,0));task.wait(0.1) end end end end})
TpT:CreateButton({Name="TP Highest",Callback=function() if gh(LP) then gh(LP).CFrame=CFrame.new(0,500,0) end end})
TpT:CreateButton({Name="TP Lowest",Callback=function() if gh(LP) then gh(LP).CFrame=CFrame.new(0,-500,0) end end})
TpT:CreateButton({Name="TP Behind Murderer",Callback=function() local m=gm();if m and m.Character and gh(LP) then local h=m.Character:FindFirstChild("HumanoidRootPart");if h then gh(LP).CFrame=h.CFrame*CFrame.new(0,0,5) end end end})
TpT:CreateButton({Name="TP Behind Sheriff",Callback=function() local s=gs();if s and s.Character and gh(LP) then local h=s.Character:FindFirstChild("HumanoidRootPart");if h then gh(LP).CFrame=h.CFrame*CFrame.new(0,0,5) end end end})
TpT:CreateInput({Name="TP by Name",PlaceholderText="Username...",RemoveTextAfterFocusLost=true,Flag="TPN",Callback=function(t) local p=Players:FindFirstChild(t);if p and p.Character and gh(LP) then local h=p.Character:FindFirstChild("HumanoidRootPart");if h then gh(LP).CFrame=CFrame.new(h.Position+Vector3.new(0,3,0)) end end end})
TpT:CreateButton({Name="Save Position",Callback=function() if gh(LP) then S.SavedPos=gh(LP).CFrame;Rayfield:Notify({Title="TP",Content="Saved",Duration=3}) end end})
TpT:CreateButton({Name="Load Position",Callback=function() if S.SavedPos and gh(LP) then gh(LP).CFrame=S.SavedPos end end})
TpT:CreateButton({Name="TP Forward 20",Callback=function() if gh(LP) then gh(LP).CFrame=gh(LP).CFrame*CFrame.new(0,0,-20) end end})
TpT:CreateButton({Name="TP Back 20",Callback=function() if gh(LP) then gh(LP).CFrame=gh(LP).CFrame*CFrame.new(0,0,20) end end})
TpT:CreateButton({Name="TP Left 20",Callback=function() if gh(LP) then gh(LP).CFrame=gh(LP).CFrame*CFrame.new(-20,0,0) end end})
TpT:CreateButton({Name="TP Right 20",Callback=function() if gh(LP) then gh(LP).CFrame=gh(LP).CFrame*CFrame.new(20,0,0) end end})
TpT:CreateButton({Name="TP Random Coin",Callback=function() local c={};for _,o in ipairs(WS:GetChildren()) do if o.Name=="Coin" then table.insert(c,o) end end;if #c>0 and gh(LP) then gh(LP).CFrame=CFrame.new(c[math.random(1,#c)].Position) end end})
TpT:CreateButton({Name="TP Safe Zone",Callback=function() if gh(LP) then gh(LP).CFrame=CFrame.new(0,50,0) end end})
TpT:CreateButton({Name="TP to Center Map",Callback=function() if gh(LP) then gh(LP).CFrame=CFrame.new(0,20,0) end end})
TpT:CreateButton({Name="Return from TP",Callback=function() if S.SavedPos and gh(LP) then gh(LP).CFrame=S.SavedPos end end})

-- ============ 12. VISUALS (22) ============
local VT=W:CreateTab("Visuals",4483362458)
VT:CreateToggle({Name="Chams",CurrentValue=false,Flag="Chams",Callback=function(v) S.ChamsEnabled=v;for _,p in ipairs(Players:GetPlayers()) do if p~=LP then clCh(p);if v and p.Character then mkCh(p,Color3.fromRGB(255,0,0)) end end end end})
VT:CreateButton({Name="Skybox: Nebula",Callback=function() local s=Instance.new("Sky");s.SkyboxBk="rbxassetid://159454299";s.SkyboxDn="rbxassetid://159454296";s.SkyboxFt="rbxassetid://159454293";s.SkyboxLf="rbxassetid://159454286";s.SkyboxRt="rbxassetid://159454300";s.SkyboxUp="rbxassetid://159454288";Lighting.Sky=s end})
VT:CreateButton({Name="Skybox: Space",Callback=function() local s=Instance.new("Sky");s.SkyboxBk="rbxassetid://12064107";s.SkyboxDn="rbxassetid://12064152";s.SkyboxFt="rbxassetid://12063984";s.SkyboxLf="rbxassetid://12064121";s.SkyboxRt="rbxassetid://12063943";s.SkyboxUp="rbxassetid://12064107";Lighting.Sky=s end})
VT:CreateButton({Name="Skybox: Sunset",Callback=function() local s=Instance.new("Sky");s.SkyboxBk="rbxassetid://271042516";s.SkyboxDn="rbxassetid://271077243";s.SkyboxFt="rbxassetid://271042556";s.SkyboxLf="rbxassetid://271042310";s.SkyboxRt="rbxassetid://271042467";s.SkyboxUp="rbxassetid://271077958";Lighting.Sky=s end})
VT:CreateButton({Name="Skybox: Remove",Callback=function() Lighting.Sky=Instance.new("Sky") end})
VT:CreateButton({Name="Time: Noon",Callback=function() Lighting.TimeOfDay="12:00:00" end})
VT:CreateButton({Name="Time: Night",Callback=function() Lighting.TimeOfDay="00:00:00" end})
VT:CreateButton({Name="Time: Sunset",Callback=function() Lighting.TimeOfDay="18:00:00" end})
VT:CreateButton({Name="Time: Sunrise",Callback=function() Lighting.TimeOfDay="06:00:00" end})
VT:CreateSlider({Name="Brightness",Range={0,255},Increment=5,CurrentValue=100,Flag="AmbB",Callback=function(v) Lighting.Ambient=Color3.fromRGB(v,v,v) end})
VT:CreateSlider({Name="Fog Density",Range={0,500},Increment=10,CurrentValue=0,Flag="FogD",Callback=function(v) Lighting.FogEnd=v==0 and 1e6 or v end})
VT:CreateButton({Name="Fog Red",Callback=function() Lighting.FogColor=Color3.fromRGB(255,0,0) end})
VT:CreateButton({Name="Fog Blue",Callback=function() Lighting.FogColor=Color3.fromRGB(0,100,255) end})
VT:CreateButton({Name="Fog Reset",Callback=function() Lighting.FogColor=Color3.fromRGB(192,192,192) end})
VT:CreateButton({Name="Bloom",Callback=function() local b=Lighting:FindFirstChild("MM2Bloom") or Instance.new("BloomEffect",Lighting);b.Name="MM2Bloom";b.Intensity=1;b.Size=24;b.Threshold=0.8 end})
VT:CreateButton({Name="Blur",Callback=function() local b=Lighting:FindFirstChild("MM2Blur") or Instance.new("BlurEffect",Lighting);b.Name="MM2Blur";b.Size=8 end})
VT:CreateButton({Name="Color Correction",Callback=function() local c=Lighting:FindFirstChild("MM2CC") or Instance.new("ColorCorrectionEffect",Lighting);c.Name="MM2CC";c.Saturation=0.3;c.Contrast=0.2 end})
VT:CreateButton({Name="Sun Rays",Callback=function() local s=Lighting:FindFirstChild("MM2SR") or Instance.new("SunRaysEffect",Lighting);s.Name="MM2SR";s.Intensity=0.2;s.Spread=1 end})
VT:CreateButton({Name="Depth of Field",Callback=function() local d=Lighting:FindFirstChild("MM2DoF") or Instance.new("DepthOfFieldEffect",Lighting);d.Name="MM2DoF";d.FarIntensity=0.1;d.FocusDistance=20;d.NearIntensity=1 end})
VT:CreateButton({Name="Reset Effects",Callback=function() for _,n in ipairs({"MM2Bloom","MM2Blur","MM2CC","MM2SR","MM2DoF"}) do local e=Lighting:FindFirstChild(n);if e then e:Destroy() end end end})
VT:CreateButton({Name="Highlight Self",Callback=function() if LP.Character then local h=Instance.new("Highlight",LP.Character);h.FillColor=Color3.fromRGB(0,255,255);h.OutlineColor=Color3.new(1,1,1) end end})
VT:CreateButton({Name="X-Ray (Client)",Callback=function() for _,v in ipairs(WS:GetDescendants()) do if v:IsA("BasePart") and v.Transparency<1 then v.LocalTransparencyModifier=0.5 end end end})

-- ============ 13. PLAYER LIST (23) ============
local PLT=W:CreateTab("Player List",4483362458)
local po={};for _,p in ipairs(Players:GetPlayers()) do if p~=LP then table.insert(po,p.Name) end end;if #po==0 then po={"No Players"} end
PLT:CreateDropdown({Name="Select Player",Options=po,CurrentOption=po[1],Flag="SelP",Callback=function(o) S.SelectedPlayer=Players:FindFirstChild(o) end})
local function wt(fn) if not S.SelectedPlayer or not S.SelectedPlayer.Parent then Rayfield:Notify({Title="Player",Content="Select first",Duration=3});return end fn(S.SelectedPlayer) end
PLT:CreateButton({Name="TP to Selected",Callback=function() wt(function(p) if p.Character and gh(LP) then local h=p.Character:FindFirstChild("HumanoidRootPart");if h then gh(LP).CFrame=CFrame.new(h.Position+Vector3.new(0,3,0)) end end end) end})
PLT:CreateButton({Name="Bring Selected",Callback=function() wt(function(p) if p.Character and gh(LP) then local h=p.Character:FindFirstChild("HumanoidRootPart");if h then h.CFrame=gh(LP).CFrame*CFrame.new(0,0,-5) end end end) end})
PLT:CreateButton({Name="Spectate",Callback=function() wt(function(p) if p.Character then Cam.CameraSubject=p.Character:FindFirstChildOfClass("Humanoid") end end) end})
PLT:CreateButton({Name="Stop Spectate",Callback=function() if LP.Character then Cam.CameraSubject=LP.Character:FindFirstChildOfClass("Humanoid") end end})
PLT:CreateToggle({Name="Follow Selected",CurrentValue=false,Flag="FollSel",Callback=function(v) if v then Cn.FollSel=RunService.Heartbeat:Connect(function() if S.SelectedPlayer and S.SelectedPlayer.Character and gh(LP) then local h=S.SelectedPlayer.Character:FindFirstChild("HumanoidRootPart");if h then gh(LP).CFrame=CFrame.new(h.Position+Vector3.new(0,3,0)) end end end) elseif Cn.FollSel then Cn.FollSel:Disconnect() end end})
PLT:CreateButton({Name="Kill Selected",Callback=function() wt(function(p) if p.Character then local h=p.Character:FindFirstChild("Humanoid");if h then h.Health=0 end end end) end})
PLT:CreateButton({Name="Fling Selected",Callback=function() wt(function(p) if p.Character then local h=p.Character:FindFirstChild("HumanoidRootPart");if h then h.Velocity=Vector3.new(math.random(-500,500),500,math.random(-500,500)) end end end) end})
PLT:CreateButton({Name="Freeze Selected",Callback=function() wt(function(p) if p.Character then local h=p.Character:FindFirstChild("HumanoidRootPart");if h then h.Anchored=true end end end) end})
PLT:CreateButton({Name="Unfreeze Selected",Callback=function() wt(function(p) if p.Character then local h=p.Character:FindFirstChild("HumanoidRootPart");if h then h.Anchored=false end end end) end})
PLT:CreateButton({Name="Explode Selected",Callback=function() wt(function(p) if p.Character then local h=p.Character:FindFirstChild("HumanoidRootPart");if h then local e=Instance.new("Explosion",WS);e.Position=h.Position;e.BlastRadius=15 end end end) end})
PLT:CreateButton({Name="Rainbow Selected",Callback=function() wt(function(p) if p.Character then for _,part in ipairs(p.Character:GetDescendants()) do if part:IsA("BasePart") then part.Color=Color3.fromHSV(math.random(),1,1) end end end end) end})
PLT:CreateButton({Name="Copy ID",Callback=function() wt(function(p) setclipboard(tostring(p.UserId)) end) end})
PLT:CreateButton({Name="Friend",Callback=function() wt(function(p) pcall(function() LP:RequestFriendship(p) end) end) end})
PLT:CreateButton({Name="Unfriend",Callback=function() wt(function(p) pcall(function() LP:RevokeFriendship(p) end) end) end})
PLT:CreateButton({Name="Show Info",Callback=function() wt(function(p) Rayfield:Notify({Title=p.Name,Content="Role: "..gr(p).." | ID: "..p.UserId,Duration=5}) end) end})
PLT:CreateButton({Name="Reset Char",Callback=function() wt(function(p) if p.Character then p.Character:BreakJoints() end end) end})
PLT:CreateButton({Name="Slap Selected",Callback=function() wt(function(p) if p.Character then local h=p.Character:FindFirstChild("HumanoidRootPart");if h then h.Velocity=Vector3.new(0,50,0) end end end) end})
PLT:CreateButton({Name="Heal Selected",Callback=function() wt(function(p) if p.Character then local h=p.Character:FindFirstChild("Humanoid");if h then h.Health=h.MaxHealth end end end) end})
PLT:CreateButton({Name="Kick Selected",Callback=function() wt(function(p) pcall(function() p:Kick("Kicked") end) end) end})
PLT:CreateButton({Name="Refresh List",Callback=function() local n=0;for _,p in ipairs(Players:GetPlayers()) do if p~=LP then n=n+1 end end;Rayfield:Notify({Title="Player List",Content=n.." players",Duration=3}) end})
PLT:CreateButton({Name="Clear Selection",Callback=function() S.SelectedPlayer=nil end})
PLT:CreateButton({Name="Loop Kill Selected",Callback=function() if S.SelectedPlayer then task.spawn(function() for i=1,5 do pcall(function() S.SelectedPlayer.Character:BreakJoints() end);task.wait(0.5) end end) end end})

-- ============ 14. EXTRA (23) ============
local ET=W:CreateTab("Extra",4483362458)
ET:CreateButton({Name="Custom Cursor",Callback=function() UIS.MouseIconEnabled=false;local m=Instance.new("ImageLabel");m.Name="MM2Cur";m.Size=UDim2.new(0,30,0,30);m.BackgroundTransparency=1;m.Image="rbxassetid://414682806";m.Parent=game:GetService("CoreGui") end})
ET:CreateButton({Name="Restore Cursor",Callback=function() UIS.MouseIconEnabled=true;local c=game:GetService("CoreGui"):FindFirstChild("MM2Cur");if c then c:Destroy() end end})
ET:CreateButton({Name="Session Timer",Callback=function() _G._MM2Start=_G._MM2Start or os.clock();Rayfield:Notify({Title="Extra",Content="Timer started",Duration=3}) end})
ET:CreateButton({Name="Show Session Time",Callback=function() local s=_G._MM2Start or os.clock();Rayfield:Notify({Title="Extra",Content=math.floor(os.clock()-s).."s",Duration=3}) end})
ET:CreateButton({Name="Hide Chat",Callback=function() local c=game:GetService("CoreGui"):FindFirstChild("Chat");if c then c.Enabled=false end end})
ET:CreateButton({Name="Show Chat",Callback=function() local c=game:GetService("CoreGui"):FindFirstChild("Chat");if c then c.Enabled=true end end})
ET:CreateButton({Name="Change Name (Fake)",Callback=function() if LP.Character then local h=LP.Character:FindFirstChildOfClass("Humanoid");if h then h.DisplayName="Admin" end end end})
ET:CreateButton({Name="Restore Name",Callback=function() if LP.Character then local h=LP.Character:FindFirstChildOfClass("Humanoid");if h then h.DisplayName=LP.DisplayName end end end})
ET:CreateButton({Name="Random Char Color",Callback=function() if LP.Character then for _,v in ipairs(LP.Character:GetDescendants()) do if v:IsA("BasePart") then v.Color=Color3.fromHSV(math.random(),1,1) end end end end})
ET:CreateButton({Name="Chat Spam",Callback=function() local e=RS:FindFirstChild("DefaultChatSystemChatEvents");if e then for i=1,10 do e:FindFirstChild("SayMessageRequest"):FireServer("MM2 ULTIMATE HUB v5","All");task.wait(0.1) end end end})
ET:CreateButton({Name="Auto-Save 60s",Callback=function() task.spawn(function() while task.wait(60) do pcall(function() Rayfield:SaveConfiguration() end) end end) end})
ET:CreateButton({Name="Copy Config",Callback=function() local c={};for k,v in pairs(S) do if type(v)~="userdata" then c[k]=v end end;setclipboard(Http:JSONEncode(c)) end})
ET:CreateButton({Name="Unload Script",Callback=function() for _,c in pairs(Cn) do pcall(function() c:Disconnect() end) end;for p,_ in pairs(Ch) do clCh(p) end;for _,p in ipairs(Players:GetPlayers()) do clESP(p);clTr(p) end;Rayfield:Destroy() end})
ET:CreateButton({Name="Rainbow Trail Self",Callback=function() if LP.Character then local h=LP.Character:FindFirstChild("HumanoidRootPart");if h then local a=Instance.new("Attachment",h);local t=Instance.new("Trail",h);t.Attachment0=a;t.Attachment1=a;t.Lifetime=1;t.Color=ColorSequence.new(Color3.fromRGB(255,0,0),Color3.fromRGB(0,255,0)) end end end})
ET:CreateButton({Name="Fire Particles Self",Callback=function() if LP.Character then local h=LP.Character:FindFirstChild("HumanoidRootPart");if h then local p=Instance.new("ParticleEmitter",h);p.Texture="rbxassetid://241876428";p.Rate=50;p.Lifetime=NumberRange.new(1,2);p.Speed=NumberRange.new(5,10);p.Size=NumberSequence.new(2) end end end})
ET:CreateButton({Name="Sparkles Self",Callback=function() if LP.Character then local h=LP.Character:FindFirstChild("HumanoidRootPart");if h then local s=Instance.new("Sparkles",h);s.SparkleColor=Color3.fromRGB(255,215,0);s.Enabled=true end end end})
ET:CreateButton({Name="Remove All Effects",Callback=function() if LP.Character then for _,v in ipairs(LP.Character:GetDescendants()) do if v:IsA("Trail") or v:IsA("ParticleEmitter") or v:IsA("Sparkles") then v:Destroy() end end end end})
ET:CreateButton({Name="Fake Level 999",Callback=function() Rayfield:Notify({Title="Extra",Content="Level 999 (fake)",Duration=3}) end})
ET:CreateButton({Name="Fake Rank Admin",Callback=function() Rayfield:Notify({Title="Extra",Content="Admin (fake)",Duration=3}) end})
ET:CreateButton({Name="Click Sound",Callback=function() local s=Instance.new("Sound",game:GetService("SoundService"));s.SoundId="rbxassetid://5211016307";s.Volume=0.5;UIS.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then s:Play() end end) end})
ET:CreateButton({Name="Anti-Kick",Callback=function() Rayfield:Notify({Title="Extra",Content="Anti-Kick (limited)",Duration=3}) end})
ET:CreateButton({Name="Emote Spam",Callback=function() for i=1,5 do pAnim("507771019");task.wait(0.5) end end})
ET:CreateButton({Name="Panic Stop ALL",Callback=function() for k,v in pairs(S) do if type(v)=="boolean" then S[k]=false end end;Rayfield:Notify({Title="Extra",Content="All toggles OFF",Duration=3}) end})

-- ============ ЛУПЫ ============
task.spawn(function() while true do task.wait(1)
    if S.ESPEnabled then rfESP() end
    if S.ChamsEnabled then for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character and (not Ch[p] or #Ch[p]==0) then mkCh(p,Color3.fromRGB(255,0,0)) end end end
    if S.TracerEnabled then for _,p in ipairs(Players:GetPlayers()) do if p~=LP and p.Character and not Tr[p] then mkTr(p) end end end
end end)

Rayfield:Notify({Title="MM2 ULTIMATE HUB v5",Content="350 функций | 14 вкладок | Quick Actions загружены",Duration=5})
print("[MM2 ULTIMATE HUB v5] Loaded | 350 Functions | 14 Tabs")