-- ============================================================
--   NOOB TROLL HUB  |  PC EDITION  v5.3
--   NEW ESP: Uses Roblox Highlight instances — works in every
--   game, shows through walls, fully customizable color.
--   Much more reliable than BoxHandleAdornment.
-- ============================================================

if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(1)

-- ============================================================
-- CACHE-BUSTED AUTO EXECUTE
-- ============================================================
local BASE_URL = "https://raw.githubusercontent.com/delajames131-hash/KatAutoFarm/refs/heads/main/KatAutoFarmm.lua"

local function getFreshURL()
    return BASE_URL.."?v="..tostring(math.random(100000,999999))
end

local function getLoadstring()
    return ([[loadstring(game:HttpGet("%s"))()]]):format(getFreshURL())
end

local queueTeleport = nil
pcall(function() queueTeleport = queue_on_teleport end)
pcall(function() if not queueTeleport and syn    then queueTeleport = syn.queue_on_teleport    end end)
pcall(function() if not queueTeleport and fluxus then queueTeleport = fluxus.queue_on_teleport end end)

local function queueSelf()
    if not queueTeleport then return end
    pcall(function() queueTeleport(getLoadstring()) end)
end
queueSelf()

-- ── Services ─────────────────────────────────────────────────
local Rayfield         = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Players          = game:GetService("Players")
local HttpService      = game:GetService("HttpService")
local TeleportService  = game:GetService("TeleportService")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")
local Stats            = game:GetService("Stats")

local lp  = Players.LocalPlayer
local cam = workspace.CurrentCamera

-- ============================================================
-- CONFIG
-- ============================================================
local CFG = { clickDelay = 0.08, stickDist = 0 }

-- ============================================================
-- SERVER HOP CONFIG
-- ============================================================
local hopRegion   = "Closest  (lowest ping)"
local hopSortMode = "ping"

local function getMyPing()
    local ok, val = pcall(function()
        return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
    end)
    return ok and val or 999
end

-- ============================================================
-- KNIFE HELPERS
-- ============================================================
local function equipSlot1()
    local bp  = lp:FindFirstChildOfClass("Backpack")
    local hum = lp.Character and lp.Character:FindFirstChildWhichIsA("Humanoid")
    if not bp or not hum then return end
    local tool = bp:FindFirstChildWhichIsA("Tool")
    if tool then pcall(function() hum:EquipTool(tool) end) end
end

local function getHeldTool()
    local char = lp.Character; if not char then return nil end
    return char:FindFirstChildWhichIsA("Tool")
end

local function stopAnims()
    local char = lp.Character; if not char then return end
    local hum  = char:FindFirstChildWhichIsA("Humanoid"); if not hum then return end
    for _, t in pairs(hum:GetPlayingAnimationTracks()) do
        pcall(function() t:Stop(0) end)
    end
end

local function fireTool(tool)
    if not tool then return end
    pcall(function() tool:Activate() end)
    pcall(function() if mouse1click then mouse1click() end end)
    for _, obj in pairs(tool:GetDescendants()) do
        if obj:IsA("RemoteEvent")    then pcall(function() obj:FireServer()   end) end
        if obj:IsA("RemoteFunction") then pcall(function() obj:InvokeServer() end) end
    end
    for _, obj in pairs(tool:GetDescendants()) do
        if obj:IsA("NumberValue") or obj:IsA("IntValue") or obj:IsA("BoolValue") then
            local n = obj.Name:lower()
            if n:find("cool") or n:find("debounce") or n:find("delay")
            or n:find("swing") or n:find("attack") or n:find("hit") then
                pcall(function()
                    if obj:IsA("BoolValue")   then obj.Value = false end
                    if obj:IsA("NumberValue") then obj.Value = 0 end
                    if obj:IsA("IntValue")    then obj.Value = 0 end
                end)
            end
        end
    end
    stopAnims()
end

-- ============================================================
-- PLAYER VALIDITY
-- ============================================================
local function isValidTarget(plr)
    if plr == lp then return false end
    local char = plr.Character; if not char then return false end
    local hum  = char:FindFirstChildWhichIsA("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return false end
    if hum.Health <= 0 then return false end
    if hum:GetState() == Enum.HumanoidStateType.Dead then return false end
    if char:FindFirstChildWhichIsA("ForceField") then return false end
    return true
end

local function isTargetDead(plr)
    if not plr or not plr.Character then return true end
    local hum = plr.Character:FindFirstChildWhichIsA("Humanoid")
    if not hum then return true end
    if hum.Health <= 0 then return true end
    if hum:GetState() == Enum.HumanoidStateType.Dead then return true end
    return false
end

local function getAliveTargets()
    local list = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if isValidTarget(plr) then table.insert(list, plr) end
    end
    return list
end

-- ============================================================
-- LOCK-ON TP KILL
-- ============================================================
local sessionId    = 0
local lockedTarget = nil

local function stopLoop()
    sessionId    = sessionId + 1
    lockedTarget = nil
end

local function pickNewTarget()
    local targets = getAliveTargets()
    if #targets == 0 then return nil end
    return targets[math.random(1, #targets)]
end

local function startLoop()
    stopLoop()
    local myId = sessionId
    equipSlot1()
    task.wait(0.3)
    task.spawn(function()
        while true do
            RunService.Heartbeat:Wait()
            if sessionId ~= myId then break end

            if not lockedTarget or not isValidTarget(lockedTarget) then
                lockedTarget = pickNewTarget()
                if not lockedTarget then continue end
                Rayfield:Notify({ Title="Locked 🎯", Content="Target: "..lockedTarget.Name, Duration=2 })
            end

            if sessionId ~= myId then break end

            local target     = lockedTarget
            local targetRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
            local myRoot     = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")

            if isTargetDead(target) then lockedTarget = nil; continue end
            if sessionId ~= myId then break end

            if targetRoot and myRoot then
                myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, CFG.stickDist)
                if sessionId ~= myId then break end
                local tool = getHeldTool()
                if not tool then
                    equipSlot1(); task.wait(0.05)
                    if sessionId ~= myId then break end
                    tool = getHeldTool()
                end
                if tool then fireTool(tool) end
                if sessionId ~= myId then break end
                if CFG.clickDelay > 0 then task.wait(CFG.clickDelay) end
            end
        end
        lockedTarget = nil
    end)
end

-- ============================================================
-- SERVER HOP
-- ============================================================
local isHopping = false

local function serverHop()
    if isHopping then return end
    isHopping = true
    Rayfield:Notify({
        Title   = "Server Hop",
        Content = ("Ping: %dms | %s\nSearching..."):format(getMyPing(), hopRegion),
        Duration = 4,
    })
    task.spawn(function()
        local placeId = game.PlaceId
        local jobId   = game.JobId

        local ok, res = pcall(function()
            return game:HttpGet(("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100"):format(placeId))
        end)

        if not ok or not res then
            Rayfield:Notify({ Title="Server Hop", Content="Failed!", Duration=4 })
            isHopping=false; return
        end

        local data = HttpService:JSONDecode(res)
        if not data or not data.data then
            Rayfield:Notify({ Title="Server Hop", Content="No data!", Duration=4 })
            isHopping=false; return
        end

        local candidates = {}
        for _, s in pairs(data.data) do
            if type(s.id)~="string" or s.id==jobId then continue end
            if type(s.playing)~="number" or type(s.maxPlayers)~="number" then continue end
            if s.playing >= s.maxPlayers then continue end

            local include = true
            if hopRegion == "Asia / Japan  (low pop)" then
                if s.playing > math.max(3, s.maxPlayers * 0.4) then include = false end
            elseif hopRegion == "US East or West  (high pop)" then
                if s.playing < s.maxPlayers * 0.5 then include = false end
            elseif hopRegion == "Europe  (mid pop)" then
                local r = s.playing/s.maxPlayers
                if r < 0.2 or r > 0.8 then include = false end
            end

            if include then
                table.insert(candidates, {
                    id=s.id, playing=s.playing, max=s.maxPlayers,
                    ping=type(s.ping)=="number" and s.ping or 999,
                })
            end
        end

        if #candidates == 0 then
            Rayfield:Notify({ Title="Server Hop", Content="No region match — using any.", Duration=3 })
            for _, s in pairs(data.data) do
                if type(s.id)=="string" and s.id~=jobId
                and type(s.playing)=="number" and type(s.maxPlayers)=="number"
                and s.playing < s.maxPlayers then
                    table.insert(candidates,{id=s.id,playing=s.playing,max=s.maxPlayers,ping=999})
                end
            end
        end

        if #candidates == 0 then
            Rayfield:Notify({ Title="Server Hop", Content="No servers found!", Duration=4 })
            isHopping=false; return
        end

        local chosen
        if hopSortMode == "random" then
            chosen = candidates[math.random(1,#candidates)]
        else
            table.sort(candidates, function(a,b)
                if a.ping~=999 and b.ping~=999 then return a.ping < b.ping end
                return a.playing < b.playing
            end)
            chosen = candidates[math.random(1, math.min(3,#candidates))]
        end

        queueSelf()
        stopLoop()
        Rayfield:Notify({
            Title   = "Server Hop",
            Content = ("Jumping! Players: %d/%d 👋"):format(chosen.playing, chosen.max),
            Duration = 3,
        })
        task.wait(1)
        TeleportService:TeleportToPlaceInstance(placeId, chosen.id, lp)
    end)
end

-- ============================================================
-- ESP  —  REBUILT USING HIGHLIGHT INSTANCES
-- Highlight is a newer Roblox API that:
--   - Works through walls (AlwaysOnTop built in)
--   - Supports fill color + outline color separately
--   - Is way more reliable than BoxHandleAdornment
--   - Works in every game
-- ============================================================
local espEnabled         = false
local espHighlights      = {}   -- [playerName] = { highlight, billboard, conn, charConn }
local espFillR           = 255
local espFillG           = 0
local espFillB           = 0
local espOutlineR        = 255
local espOutlineG        = 255
local espOutlineB        = 255
local espFillTransp      = 0.5   -- 0 = solid fill, 1 = no fill
local espOutlineTransp   = 0     -- 0 = solid outline, 1 = no outline
local espShowName        = true
local espShowHealth      = true

local function getFillColor()    return Color3.fromRGB(espFillR, espFillG, espFillB) end
local function getOutlineColor() return Color3.fromRGB(espOutlineR, espOutlineG, espOutlineB) end

local function updateAllHighlights()
    for _, data in pairs(espHighlights) do
        if data.highlight and data.highlight.Parent then
            data.highlight.FillColor       = getFillColor()
            data.highlight.OutlineColor    = getOutlineColor()
            data.highlight.FillTransparency    = espFillTransp
            data.highlight.OutlineTransparency = espOutlineTransp
        end
    end
end

local function removeESPForPlayer(plr)
    local data = espHighlights[plr.Name]
    if not data then return end
    if data.highlight  then pcall(function() data.highlight:Destroy()  end) end
    if data.billboard  then pcall(function() data.billboard:Destroy()  end) end
    if data.conn       then pcall(function() data.conn:Disconnect()    end) end
    if data.charConn   then pcall(function() data.charConn:Disconnect() end) end
    espHighlights[plr.Name] = nil
end

local function buildHighlightForChar(plr, char)
    if not espEnabled then return end
    if plr == lp then return end

    -- Clean old
    local old = espHighlights[plr.Name]
    if old then
        if old.highlight then pcall(function() old.highlight:Destroy() end) end
        if old.billboard  then pcall(function() old.billboard:Destroy()  end) end
        if old.conn       then pcall(function() old.conn:Disconnect()    end) end
    end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- ── Highlight (shows through walls) ──────────────────────
    local hl = Instance.new("Highlight")
    hl.Adornee           = char
    hl.FillColor         = getFillColor()
    hl.OutlineColor      = getOutlineColor()
    hl.FillTransparency      = espFillTransp
    hl.OutlineTransparency   = espOutlineTransp
    hl.DepthMode         = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent            = char

    -- ── Billboard: name + HP + distance above head ────────────
    local head = char:FindFirstChild("Head")
    local bb   = nil

    if head then
        bb = Instance.new("BillboardGui")
        bb.Name          = "ESPBillboard"
        bb.Adornee       = head
        bb.AlwaysOnTop   = true
        bb.Size          = UDim2.new(0, 140, 0, 50)
        bb.StudsOffset   = Vector3.new(0, 3.2, 0)
        bb.Parent        = CoreGui

        -- Name label
        local nameLabel                    = Instance.new("TextLabel")
        nameLabel.Name                     = "ESPName"
        nameLabel.Size                     = UDim2.new(1, 0, 0.5, 0)
        nameLabel.BackgroundTransparency   = 1
        nameLabel.Text                     = plr.Name
        nameLabel.TextColor3               = getFillColor()
        nameLabel.TextStrokeTransparency   = 0
        nameLabel.TextStrokeColor3         = Color3.new(0,0,0)
        nameLabel.Font                     = Enum.Font.GothamBold
        nameLabel.TextScaled               = true
        nameLabel.Visible                  = espShowName
        nameLabel.Parent                   = bb

        -- Health + distance label
        local infoLabel                    = Instance.new("TextLabel")
        infoLabel.Name                     = "ESPInfo"
        infoLabel.Size                     = UDim2.new(1, 0, 0.5, 0)
        infoLabel.Position                 = UDim2.new(0, 0, 0.5, 0)
        infoLabel.BackgroundTransparency   = 1
        infoLabel.TextColor3               = Color3.fromRGB(100, 255, 100)
        infoLabel.TextStrokeTransparency   = 0
        infoLabel.TextStrokeColor3         = Color3.new(0,0,0)
        infoLabel.Font                     = Enum.Font.Gotham
        infoLabel.TextScaled               = true
        infoLabel.Visible                  = espShowHealth
        infoLabel.Parent                   = bb
    end

    -- Live update loop
    local conn = RunService.Heartbeat:Connect(function()
        if not espEnabled or not hl.Parent then
            if conn then conn:Disconnect() end
            return
        end

        -- Update colors in case sliders changed
        hl.FillColor            = getFillColor()
        hl.OutlineColor         = getOutlineColor()
        hl.FillTransparency     = espFillTransp
        hl.OutlineTransparency  = espOutlineTransp

        if bb and bb.Parent then
            local nameL = bb:FindFirstChild("ESPName")
            local infoL = bb:FindFirstChild("ESPInfo")

            if nameL then
                nameL.TextColor3 = getFillColor()
                nameL.Visible    = espShowName
            end

            if infoL then
                infoL.Visible = espShowHealth
                local hum    = char:FindFirstChildWhichIsA("Humanoid")
                local myR    = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                local theirR = char:FindFirstChild("HumanoidRootPart")
                if hum and myR and theirR then
                    local dist = math.floor((myR.Position - theirR.Position).Magnitude)
                    local hp   = math.floor(hum.Health)
                    local maxhp= math.floor(hum.MaxHealth)
                    -- Color shifts green→yellow→red based on HP
                    local ratio = math.clamp(hp / math.max(maxhp, 1), 0, 1)
                    infoL.TextColor3 = Color3.fromRGB(
                        math.floor(255 * (1 - ratio)),
                        math.floor(255 * ratio),
                        0
                    )
                    infoL.Text = ("♥ %d/%d  |  %d studs"):format(hp, maxhp, dist)
                end
            end
        end
    end)

    espHighlights[plr.Name] = {
        highlight = hl,
        billboard = bb,
        conn      = conn,
        charConn  = nil,
    }
end

local function setupESPForPlayer(plr)
    if plr == lp then return end

    -- Build for current character
    if plr.Character then
        buildHighlightForChar(plr, plr.Character)
    end

    -- Rebuild on respawn
    local charConn = plr.CharacterAdded:Connect(function(char)
        task.wait(0.5)   -- wait for character to fully load
        if espEnabled then
            buildHighlightForChar(plr, char)
        end
    end)

    -- Store the charConn so we can clean it up
    if espHighlights[plr.Name] then
        espHighlights[plr.Name].charConn = charConn
    else
        espHighlights[plr.Name] = { charConn = charConn }
    end
end

local espPlayerAddedConn    = nil
local espPlayerRemovedConn  = nil

local function enableESP()
    espEnabled = true

    for _, plr in pairs(Players:GetPlayers()) do
        setupESPForPlayer(plr)
    end

    espPlayerAddedConn = Players.PlayerAdded:Connect(function(plr)
        if espEnabled then setupESPForPlayer(plr) end
    end)

    espPlayerRemovedConn = Players.PlayerRemoving:Connect(function(plr)
        removeESPForPlayer(plr)
    end)

    Rayfield:Notify({ Title="ESP ON ✓", Content="Highlights active — visible through walls!", Duration=3 })
end

local function disableESP()
    espEnabled = false

    if espPlayerAddedConn   then espPlayerAddedConn:Disconnect();   espPlayerAddedConn=nil   end
    if espPlayerRemovedConn then espPlayerRemovedConn:Disconnect(); espPlayerRemovedConn=nil end

    for name, data in pairs(espHighlights) do
        if data.highlight then pcall(function() data.highlight:Destroy() end) end
        if data.billboard  then pcall(function() data.billboard:Destroy()  end) end
        if data.conn       then pcall(function() data.conn:Disconnect()    end) end
        if data.charConn   then pcall(function() data.charConn:Disconnect() end) end
    end
    espHighlights = {}

    Rayfield:Notify({ Title="ESP OFF", Content="Highlights removed.", Duration=2 })
end

-- ============================================================
-- AIM ASSIST + DRAWING CIRCLE
-- ============================================================
local aaEnabled=false; local aaKeybind=Enum.KeyCode.Q; local aaRadius=120
local aaSmooth=0.1; local aaTargetPart="Head"; local aaHoldMode=false
local aaSettingKey=false; local aaConn=nil; local aaToggleRef=nil
local circleR,circleG,circleB=255,255,255
local circleThickness=2; local circleFilled=false; local circleTransp=0
local showCircleOnly=false

local aaCircle=nil
pcall(function()
    aaCircle=Drawing.new("Circle")
    aaCircle.Visible=false; aaCircle.Radius=aaRadius
    aaCircle.Color=Color3.fromRGB(255,255,255)
    aaCircle.Thickness=2; aaCircle.Filled=false
    aaCircle.Transparency=0; aaCircle.NumSides=64
end)

local function refreshCircleVisibility()
    if not aaCircle then return end
    aaCircle.Visible = aaEnabled or showCircleOnly
end

local function updateCircleStyle()
    if not aaCircle then return end
    aaCircle.Radius=aaRadius
    aaCircle.Color=Color3.fromRGB(circleR,circleG,circleB)
    aaCircle.Thickness=circleThickness
    aaCircle.Filled=circleFilled
    aaCircle.Transparency=circleTransp
end

RunService.RenderStepped:Connect(function()
    if not aaCircle then return end
    local vp=cam.ViewportSize
    aaCircle.Position=Vector2.new(vp.X/2, vp.Y/2)
end)

local function getAimTarget()
    local vp=cam.ViewportSize
    local center=Vector2.new(vp.X/2, vp.Y/2)
    local best,bestDist=nil,aaRadius
    for _,plr in pairs(Players:GetPlayers()) do
        if plr==lp then continue end
        local char=plr.Character; if not char then continue end
        local hum=char:FindFirstChildWhichIsA("Humanoid")
        local part=char:FindFirstChild(aaTargetPart)
        if not hum or not part or hum.Health<=0 then continue end
        local sp,onScreen=cam:WorldToScreenPoint(part.Position)
        if not onScreen then continue end
        local dist=(Vector2.new(sp.X,sp.Y)-center).Magnitude
        if dist<bestDist then bestDist=dist; best=plr end
    end
    return best
end

local function setAimAssist(v)
    aaEnabled=v; refreshCircleVisibility()
    if aaToggleRef then pcall(function() aaToggleRef:Set(v) end) end
end

local function startAimLoop()
    if aaConn then aaConn:Disconnect() end
    aaConn=RunService.RenderStepped:Connect(function()
        if not aaEnabled then return end
        local target=getAimTarget()
        if not target or not target.Character then return end
        local part=target.Character:FindFirstChild(aaTargetPart)
        if not part then return end
        cam.CFrame=cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position,part.Position),aaSmooth)
    end)
end
startAimLoop()

UserInputService.InputBegan:Connect(function(input,gp)
    if gp then return end
    if aaSettingKey then
        if input.UserInputType==Enum.UserInputType.Keyboard then
            aaKeybind=input.KeyCode; aaSettingKey=false
            Rayfield:Notify({Title="Keybind ✓",Content="Key → "..tostring(input.KeyCode):gsub("Enum.KeyCode.",""),Duration=3})
        end; return
    end
    if input.KeyCode~=aaKeybind then return end
    if aaHoldMode then setAimAssist(true)
    else setAimAssist(not aaEnabled)
        Rayfield:Notify({Title="Aim Assist",Content=aaEnabled and "ON 🎯" or "OFF",Duration=2})
    end
end)
UserInputService.InputEnded:Connect(function(input,gp)
    if input.KeyCode==aaKeybind and aaHoldMode then setAimAssist(false) end
end)

-- ============================================================
-- PURE MODE
-- ============================================================
local savedOpt={};local optActive=false;local optAddedConn=nil
local function purgeObject(obj)
    if obj:IsA("Texture") or obj:IsA("Decal") then savedOpt[obj]={type="transparency",val=obj.Transparency};obj.Transparency=1
    elseif obj:IsA("SpecialMesh") then savedOpt[obj]={type="mesh",val=obj.TextureId};obj.TextureId=""
    elseif obj:IsA("SurfaceAppearance") then savedOpt[obj]={type="instance",parent=obj.Parent};obj.Parent=nil
    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then savedOpt[obj]={type="enabled",val=obj.Enabled};obj.Enabled=false
    elseif obj:IsA("Sky") or obj:IsA("Atmosphere") then savedOpt[obj]={type="instance",parent=obj.Parent};obj.Parent=nil
    elseif obj:IsA("PostEffect") then savedOpt[obj]={type="enabled",val=obj.Enabled};obj.Enabled=false
    elseif obj:IsA("BasePart") and not obj:IsDescendantOf(lp.Character or game.Players) then
        savedOpt[obj]={type="material",mat=obj.Material,cast=obj.CastShadow}
        obj.Material=Enum.Material.SmoothPlastic; obj.CastShadow=false
    end
end
local function restoreObject(obj,data)
    pcall(function()
        if data.type=="transparency" then obj.Transparency=data.val
        elseif data.type=="mesh" then obj.TextureId=data.val
        elseif data.type=="instance" then obj.Parent=data.parent
        elseif data.type=="enabled" then obj.Enabled=data.val
        elseif data.type=="material" then obj.Material=data.mat;obj.CastShadow=data.cast end
    end)
end
local function enablePureMode()
    optActive=true;savedOpt={}
    for _,obj in pairs(game:GetDescendants()) do purgeObject(obj) end
    local L=game:GetService("Lighting")
    savedOpt["lighting"]={GS=L.GlobalShadows,FE=L.FogEnd,FS=L.FogStart,B=L.Brightness,OA=L.OutdoorAmbient}
    L.GlobalShadows=false;L.FogEnd=100000;L.FogStart=0;L.Brightness=2;L.OutdoorAmbient=Color3.fromRGB(128,128,128)
    if optAddedConn then optAddedConn:Disconnect() end
    optAddedConn=game.DescendantAdded:Connect(function(obj) if optActive then purgeObject(obj) end end)
    pcall(function() settings().Rendering.QualityLevel=Enum.QualityLevel.Level01 end)
    Rayfield:Notify({Title="Pure Mode ON 🚀",Content="Max FPS!",Duration=3})
end
local function disablePureMode()
    optActive=false; if optAddedConn then optAddedConn:Disconnect();optAddedConn=nil end
    for obj,data in pairs(savedOpt) do
        if obj=="lighting" then
            local L=game:GetService("Lighting")
            pcall(function() L.GlobalShadows=data.GS;L.FogEnd=data.FE;L.FogStart=data.FS;L.Brightness=data.B;L.OutdoorAmbient=data.OA end)
        else restoreObject(obj,data) end
    end
    savedOpt={}; pcall(function() settings().Rendering.QualityLevel=Enum.QualityLevel.Automatic end)
    Rayfield:Notify({Title="Pure Mode OFF",Content="Textures restored.",Duration=3})
end

-- ============================================================
-- NAME SPOOF
-- ============================================================
local originalDisplayName=lp.DisplayName;local spoofActive=false;local spoofLoopConn=nil
local currentSpoofName="noob"..tostring(math.random(1000,9999))
local noobNames={"xX_n00b_Xx","guest1337","robloxplayer101","bob_the_noob","CoolKid2009","RandomGuy_XD","IamANoob123","NewPlayer_lol","justjoined2025","helpmeplay","idk_howtoplay","notahacker_fr","plsdontkilme","skilledgamer0","baconhair_bro","guestuser404"}
local function applySpoof(name)
    currentSpoofName=name; local char=lp.Character
    if char then local hum=char:FindFirstChildWhichIsA("Humanoid"); if hum then hum.DisplayName=name end end
end
local function startSpoofLoop()
    if spoofLoopConn then spoofLoopConn:Disconnect() end
    spoofLoopConn=lp.CharacterAdded:Connect(function(char)
        if spoofActive then task.wait(0.5); local hum=char:WaitForChild("Humanoid",5); if hum then hum.DisplayName=currentSpoofName end end
    end)
end
local function stopSpoof()
    spoofActive=false; if spoofLoopConn then spoofLoopConn:Disconnect();spoofLoopConn=nil end
    local char=lp.Character; if char then local hum=char:FindFirstChildWhichIsA("Humanoid"); if hum then hum.DisplayName=originalDisplayName end end
end

-- ============================================================
-- NOOB DISGUISE
-- ============================================================
local function applyNoobColors()
    local c=lp.Character; if not c then return end
    local colors={["Head"]="ffc99a",["Torso"]="00aa00",["Left Arm"]="00aa00",["Right Arm"]="00aa00",["Left Leg"]="0000aa",["Right Leg"]="0000aa",["UpperTorso"]="00aa00",["LowerTorso"]="0000aa",["RightUpperArm"]="00aa00",["LeftUpperArm"]="00aa00",["RightLowerArm"]="00aa00",["LeftLowerArm"]="00aa00",["RightHand"]="ffc99a",["LeftHand"]="ffc99a",["RightUpperLeg"]="0000aa",["LeftUpperLeg"]="0000aa",["RightLowerLeg"]="0000aa",["LeftLowerLeg"]="0000aa",["RightFoot"]="0000aa",["LeftFoot"]="0000aa"}
    for name,hex in pairs(colors) do
        local p=c:FindFirstChild(name)
        if p and p:IsA("BasePart") then p.BrickColor=BrickColor.new(Color3.fromRGB(tonumber(hex:sub(1,2),16),tonumber(hex:sub(3,4),16),tonumber(hex:sub(5,6),16))) end
    end
    for _,v in pairs(c:GetDescendants()) do if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("Accessory") then pcall(function() v:Destroy() end) end end
    Rayfield:Notify({Title="Disguise",Content="Full noob mode 😂",Duration=4})
end
local fakeTripThread=nil
local function fakeTripLoop(enabled)
    if fakeTripThread then task.cancel(fakeTripThread);fakeTripThread=nil end
    if not enabled then return end
    fakeTripThread=task.spawn(function()
        while enabled do task.wait(math.random(4,9))
            local h=lp.Character and lp.Character:FindFirstChildWhichIsA("Humanoid")
            if h then h.PlatformStand=true;task.wait(0.8);h.PlatformStand=false end end
    end)
end
local function noobSpin()
    local root=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart"); if not root then return end
    local bav=Instance.new("BodyAngularVelocity"); bav.MaxTorque=Vector3.new(0,math.huge,0); bav.P=math.huge
    bav.AngularVelocity=Vector3.new(0,15,0); bav.Parent=root; task.wait(2.5); bav:Destroy()
end

-- ============================================================
-- CHAT BAIT
-- ============================================================
local chatThread=nil;local chatOn=false;local chatDelay=8
local phrases={"pls dont kill me","how do i play","wait how do u use tool","omg i just started","pls spare me im new","wait what is this game","how do i run","guys where do i go","HELLO??","wait is this like minecraft","admin pls help me","wtf why did u kill me im new","pls give me a chance im learning","bro stop im a noob","i dont know how to fight","how do i get coins","wait theres pvp??","bro i literally just joined","why is everyone so mean","is there a tutorial"}
local function sendChat(msg)
    pcall(function()
        if game:GetService("TextChatService").ChatVersion==Enum.ChatVersion.LegacyChatService then
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg,"All")
        else game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(msg) end
    end)
end
local function startChat(on,delay)
    if chatThread then task.cancel(chatThread);chatThread=nil end
    if not on then return end
    chatThread=task.spawn(function() while on do sendChat(phrases[math.random(1,#phrases)]);task.wait(delay or 8) end end)
end

-- ============================================================
-- MOVEMENT
-- ============================================================
local infJump=nil;local infJumpDB=false
local function toggleInfJump(v)
    if infJump then infJump:Disconnect();infJump=nil end;infJumpDB=false
    if v then infJump=UserInputService.JumpRequest:Connect(function()
        if not infJumpDB then infJumpDB=true
            local h=lp.Character and lp.Character:FindFirstChildWhichIsA("Humanoid")
            if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
            task.wait();infJumpDB=false end end) end
end
local noclipConn=nil
local function toggleNoclip(v)
    if v then
        if noclipConn then noclipConn:Disconnect() end
        noclipConn=RunService.Stepped:Connect(function()
            if lp.Character then for _,p in pairs(lp.Character:GetDescendants()) do if p:IsA("BasePart") and p.CanCollide then p.CanCollide=false end end end
        end)
    else if noclipConn then noclipConn:Disconnect();noclipConn=nil end end
end
local FLYING=false;local flySpeed=50;local flyKeyDown=nil;local flyKeyUp=nil
local function NOFLY()
    FLYING=false
    if flyKeyDown then flyKeyDown:Disconnect();flyKeyDown=nil end
    if flyKeyUp then flyKeyUp:Disconnect();flyKeyUp=nil end
    local hum=lp.Character and lp.Character:FindFirstChildWhichIsA("Humanoid")
    if hum then hum.PlatformStand=false end
    pcall(function() workspace.CurrentCamera.CameraType=Enum.CameraType.Custom end)
end
local function sFLY()
    local char=lp.Character;if not char then return end
    local T=char:FindFirstChild("HumanoidRootPart");if not T then return end
    local hum=char:FindFirstChildWhichIsA("Humanoid")
    local CTRL={F=0,B=0,L=0,R=0,Q=0,E=0};local lCTRL={F=0,B=0,L=0,R=0,Q=0,E=0}
    FLYING=true
    local BG=Instance.new("BodyGyro");BG.P=9e4;BG.MaxTorque=Vector3.new(9e9,9e9,9e9);BG.CFrame=T.CFrame;BG.Parent=T
    local BV=Instance.new("BodyVelocity");BV.MaxForce=Vector3.new(9e9,9e9,9e9);BV.Velocity=Vector3.new(0,0,0);BV.Parent=T
    task.spawn(function()
        repeat task.wait()
            local camera=workspace.CurrentCamera;local moving=CTRL.L+CTRL.R~=0 or CTRL.F+CTRL.B~=0 or CTRL.Q+CTRL.E~=0
            if hum then hum.PlatformStand=true end
            if moving then
                BV.Velocity=(camera.CFrame.LookVector*(CTRL.F+CTRL.B)+((camera.CFrame*CFrame.new(CTRL.L+CTRL.R,(CTRL.F+CTRL.B+CTRL.Q+CTRL.E)*0.2,0)).p-camera.CFrame.p))*flySpeed
                lCTRL={F=CTRL.F,B=CTRL.B,L=CTRL.L,R=CTRL.R}
            elseif lCTRL.F+lCTRL.B~=0 or lCTRL.L+lCTRL.R~=0 then
                BV.Velocity=(camera.CFrame.LookVector*(lCTRL.F+lCTRL.B)+((camera.CFrame*CFrame.new(lCTRL.L+lCTRL.R,(lCTRL.F+lCTRL.B)*0.2,0)).p-camera.CFrame.p))*flySpeed
            else BV.Velocity=Vector3.new(0,0,0) end
            BG.CFrame=camera.CFrame
        until not FLYING
        BG:Destroy();BV:Destroy(); if hum then hum.PlatformStand=false end
    end)
    flyKeyDown=UserInputService.InputBegan:Connect(function(inp,gp) if gp then return end
        if inp.KeyCode==Enum.KeyCode.W then CTRL.F=1 elseif inp.KeyCode==Enum.KeyCode.S then CTRL.B=-1
        elseif inp.KeyCode==Enum.KeyCode.A then CTRL.L=-1 elseif inp.KeyCode==Enum.KeyCode.D then CTRL.R=1
        elseif inp.KeyCode==Enum.KeyCode.E then CTRL.Q=2 elseif inp.KeyCode==Enum.KeyCode.Q then CTRL.E=-2 end end)
    flyKeyUp=UserInputService.InputEnded:Connect(function(inp,gp) if gp then return end
        if inp.KeyCode==Enum.KeyCode.W then CTRL.F=0 elseif inp.KeyCode==Enum.KeyCode.S then CTRL.B=0
        elseif inp.KeyCode==Enum.KeyCode.A then CTRL.L=0 elseif inp.KeyCode==Enum.KeyCode.D then CTRL.R=0
        elseif inp.KeyCode==Enum.KeyCode.E then CTRL.Q=0 elseif inp.KeyCode==Enum.KeyCode.Q then CTRL.E=0 end end)
end

-- ============================================================
-- WINDOW
-- ============================================================
local Window=Rayfield:CreateWindow({
    Name="Noob Troll Hub  💻 v5.3", LoadingTitle="Noob Troll Hub",
    LoadingSubtitle="Cooking... 🎣",
    ConfigurationSaving={Enabled=false}, Discord={Enabled=false}, KeySystem=false,
})

-- ============================================================
-- TAB 1 — ESP  (new Highlight-based)
-- ============================================================
local ESPTab=Window:CreateTab("ESP","eye")

ESPTab:CreateToggle({Name="ESP  [ ON / OFF ]",CurrentValue=false,Flag="ESPToggle",
    Callback=function(v) if v then enableESP() else disableESP() end end})

ESPTab:CreateToggle({Name="Show Name",CurrentValue=true,Flag="ESPShowName",
    Callback=function(v) espShowName=v end})

ESPTab:CreateToggle({Name="Show Health + Distance",CurrentValue=true,Flag="ESPShowHealth",
    Callback=function(v) espShowHealth=v end})

ESPTab:CreateDivider()
ESPTab:CreateParagraph({Title="Fill Color  (inside the highlight)",Content="Red 255/0/0 · Green 0/255/0 · Blue 0/0/255\nWhite 255/255/255 · Pink 255/0/200 · Yellow 255/220/0"})

ESPTab:CreateSlider({Name="Fill Red",  Range={0,255},Increment=1,CurrentValue=255,Flag="FillR",Callback=function(v) espFillR=v end})
ESPTab:CreateSlider({Name="Fill Green",Range={0,255},Increment=1,CurrentValue=0,  Flag="FillG",Callback=function(v) espFillG=v end})
ESPTab:CreateSlider({Name="Fill Blue", Range={0,255},Increment=1,CurrentValue=0,  Flag="FillB",Callback=function(v) espFillB=v end})
ESPTab:CreateSlider({Name="Fill Transparency",Range={0,9},Increment=1,Suffix=" (0=solid · 9=invisible)",CurrentValue=5,Flag="FillTransp",
    Callback=function(v) espFillTransp=v*0.1 end})

ESPTab:CreateDivider()
ESPTab:CreateParagraph({Title="Outline Color  (border around character)",Content="Set to white for clean visibility, or match the fill color."})

ESPTab:CreateSlider({Name="Outline Red",  Range={0,255},Increment=1,CurrentValue=255,Flag="OutR",Callback=function(v) espOutlineR=v end})
ESPTab:CreateSlider({Name="Outline Green",Range={0,255},Increment=1,CurrentValue=255,Flag="OutG",Callback=function(v) espOutlineG=v end})
ESPTab:CreateSlider({Name="Outline Blue", Range={0,255},Increment=1,CurrentValue=255,Flag="OutB",Callback=function(v) espOutlineB=v end})
ESPTab:CreateSlider({Name="Outline Transparency",Range={0,9},Increment=1,Suffix=" (0=solid · 9=invisible)",CurrentValue=0,Flag="OutTransp",
    Callback=function(v) espOutlineTransp=v*0.1 end})

-- ============================================================
-- TAB 2 — AIM ASSIST
-- ============================================================
local AATab=Window:CreateTab("Aim Assist","crosshair")
aaToggleRef=AATab:CreateToggle({Name="Aim Assist  [ ON / OFF ]",CurrentValue=false,Flag="AAToggle",
    Callback=function(v) aaEnabled=v;refreshCircleVisibility();Rayfield:Notify({Title="Aim Assist",Content=v and "ON 🎯" or "OFF",Duration=2}) end})
AATab:CreateToggle({Name="Show Circle Only  (preview)",CurrentValue=false,Flag="ShowCircle",Callback=function(v) showCircleOnly=v;refreshCircleVisibility() end})
AATab:CreateDivider()
AATab:CreateSlider({Name="FOV Radius",Range={30,400},Increment=5,Suffix=" px",CurrentValue=120,Flag="AARadius",Callback=function(v) aaRadius=v;updateCircleStyle() end})
AATab:CreateSlider({Name="Smoothness  (1=instant · 20=smooth)",Range={1,20},Increment=1,CurrentValue=4,Flag="AASmooth",Callback=function(v) aaSmooth=v*0.025 end})
AATab:CreateToggle({Name="Hold Mode",CurrentValue=false,Flag="AAHoldMode",Callback=function(v) aaHoldMode=v end})
AATab:CreateToggle({Name="Target Body  (OFF=Head · ON=Torso)",CurrentValue=false,Flag="AATargetPart",Callback=function(v) aaTargetPart=v and "HumanoidRootPart" or "Head" end})
AATab:CreateButton({Name="Set Keybind  (click then press a key)",Callback=function() aaSettingKey=true;Rayfield:Notify({Title="Keybind",Content="Press any key...",Duration=4}) end})
AATab:CreateDivider()
AATab:CreateParagraph({Title="Circle Style",Content="Customize the FOV ring on screen."})
AATab:CreateSlider({Name="Circle Red",  Range={0,255},Increment=1,CurrentValue=255,Flag="CIR",Callback=function(v) circleR=v;updateCircleStyle() end})
AATab:CreateSlider({Name="Circle Green",Range={0,255},Increment=1,CurrentValue=255,Flag="CIG",Callback=function(v) circleG=v;updateCircleStyle() end})
AATab:CreateSlider({Name="Circle Blue", Range={0,255},Increment=1,CurrentValue=255,Flag="CIB",Callback=function(v) circleB=v;updateCircleStyle() end})
AATab:CreateSlider({Name="Thickness",Range={1,8},Increment=1,Suffix=" px",CurrentValue=2,Flag="CIThick",Callback=function(v) circleThickness=v;updateCircleStyle() end})
AATab:CreateSlider({Name="Transparency",Range={0,9},Increment=1,CurrentValue=0,Flag="CITransp",Callback=function(v) circleTransp=v*0.1;updateCircleStyle() end})
AATab:CreateToggle({Name="Filled  (solid disc)",CurrentValue=false,Flag="CIFilled",Callback=function(v) circleFilled=v;updateCircleStyle() end})

-- ============================================================
-- TAB 3 — TP KILL
-- ============================================================
local KillTab=Window:CreateTab("TP Kill","sword")
KillTab:CreateToggle({Name="Lock-On TP Kill  [ ON / OFF ]",CurrentValue=false,Flag="MainToggle",
    Callback=function(v)
        if v then startLoop();Rayfield:Notify({Title="Lock-On TP Kill",Content="Active! Auto clicking 😈",Duration=4})
        else stopLoop();Rayfield:Notify({Title="TP Kill",Content="Stopped ✓",Duration=3}) end
    end})
KillTab:CreateDivider()
KillTab:CreateSlider({Name="Click Cooldown (ms)  (0=max CPS)",Range={0,500},Increment=10,Suffix=" ms",CurrentValue=80,Flag="ClickDelay",Callback=function(v) CFG.clickDelay=v/1000 end})
KillTab:CreateSlider({Name="Distance  (0=on top)",Range={0,5},Increment=1,Suffix=" studs",CurrentValue=0,Flag="StickDist",Callback=function(v) CFG.stickDist=v end})

-- ============================================================
-- TAB 4 — NAME SPOOF
-- ============================================================
local SpoofTab=Window:CreateTab("Name Spoof","user-x")
SpoofTab:CreateToggle({Name="Name Spoof  [ ON / OFF ]",CurrentValue=false,Flag="SpoofToggle",
    Callback=function(v)
        if v then spoofActive=true;applySpoof(currentSpoofName);startSpoofLoop();Rayfield:Notify({Title="Name Spoof",Content="Name → "..currentSpoofName.." 😂",Duration=4})
        else stopSpoof();Rayfield:Notify({Title="Name Spoof",Content="Restored.",Duration=3}) end
    end})
SpoofTab:CreateButton({Name="Random Noob Name",Callback=function()
    local pick=noobNames[math.random(1,#noobNames)];currentSpoofName=pick
    if spoofActive then applySpoof(pick) end;Rayfield:Notify({Title="Name Spoof",Content="Name → "..pick,Duration=3})
end})
SpoofTab:CreateInput({Name="Custom Name",PlaceholderText="Type here...",RemoveTextAfterFocusLost=false,Flag="CustomSpoofName",
    Callback=function(v) if v and #v>0 then currentSpoofName=v;if spoofActive then applySpoof(v) end;Rayfield:Notify({Title="Name Spoof",Content="Name → "..v,Duration=3}) end end})

-- ============================================================
-- TAB 5 — OPTIMIZE
-- ============================================================
local OptTab=Window:CreateTab("Optimize","zap")
OptTab:CreateToggle({Name="Pure Mode  (FULL texture removal + max FPS)",CurrentValue=false,Flag="PureMode",Callback=function(v) if v then enablePureMode() else disablePureMode() end end})
local origL={B=game:GetService("Lighting").Brightness,CT=game:GetService("Lighting").ClockTime,FE=game:GetService("Lighting").FogEnd,GS=game:GetService("Lighting").GlobalShadows,OA=game:GetService("Lighting").OutdoorAmbient}
OptTab:CreateToggle({Name="Fullbright",CurrentValue=false,Flag="Fullbright",
    Callback=function(v) local L=game:GetService("Lighting")
        if v then L.Brightness=2;L.ClockTime=14;L.FogEnd=100000;L.GlobalShadows=false;L.OutdoorAmbient=Color3.fromRGB(128,128,128)
        else L.Brightness=origL.B;L.ClockTime=origL.CT;L.FogEnd=origL.FE;L.GlobalShadows=origL.GS;L.OutdoorAmbient=origL.OA end end})

-- ============================================================
-- TAB 6 — DISGUISE
-- ============================================================
local DisguiseTab=Window:CreateTab("Disguise","user")
DisguiseTab:CreateButton({Name="Apply Noob Look",Callback=function() applyNoobColors() end})
DisguiseTab:CreateToggle({Name="Slow Walk",CurrentValue=false,Flag="SlowWalk",Callback=function(v) local h=lp.Character and lp.Character:FindFirstChildWhichIsA("Humanoid");if h then h.WalkSpeed=v and 8 or 16 end end})
DisguiseTab:CreateToggle({Name="Fake Trip",CurrentValue=false,Flag="FakeTrip",Callback=function(v) fakeTripLoop(v) end})
DisguiseTab:CreateButton({Name="Noob Spin",Callback=function() noobSpin() end})

-- ============================================================
-- TAB 7 — CHAT BAIT
-- ============================================================
local ChatTab=Window:CreateTab("Chat Bait","message-circle")
ChatTab:CreateToggle({Name="Auto Noob Chat",CurrentValue=false,Flag="ChatSpam",Callback=function(v) chatOn=v;startChat(v,chatDelay) end})
ChatTab:CreateSlider({Name="Chat Interval",Range={3,30},Increment=1,Suffix="s",CurrentValue=8,Flag="ChatInterval",Callback=function(v) chatDelay=v;if chatOn then startChat(true,v) end end})

-- ============================================================
-- TAB 8 — MOVEMENT
-- ============================================================
local MovTab=Window:CreateTab("Movement","trending-up")
MovTab:CreateToggle({Name="Fly  (WASD · Q up · E down)",CurrentValue=false,Flag="Fly",Callback=function(v) if v then NOFLY();task.wait(0.05);sFLY() else NOFLY() end end})
MovTab:CreateSlider({Name="Fly Speed",Range={5,300},Increment=5,Suffix=" sp",CurrentValue=50,Flag="FlySpeed",Callback=function(v) flySpeed=v end})
MovTab:CreateToggle({Name="Infinite Jump",CurrentValue=false,Flag="InfJump",Callback=function(v) toggleInfJump(v) end})
MovTab:CreateToggle({Name="Noclip",CurrentValue=false,Flag="Noclip",Callback=function(v) toggleNoclip(v) end})
MovTab:CreateSlider({Name="Walk Speed",Range={0,250},Increment=1,Suffix=" ws",CurrentValue=16,Flag="WalkSpeed",Callback=function(v) local h=lp.Character and lp.Character:FindFirstChildWhichIsA("Humanoid");if h then h.WalkSpeed=v end end})
MovTab:CreateSlider({Name="Jump Power",Range={0,300},Increment=1,Suffix=" jp",CurrentValue=50,Flag="JumpPower",Callback=function(v) local h=lp.Character and lp.Character:FindFirstChildWhichIsA("Humanoid");if h then if h.UseJumpPower then h.JumpPower=v else h.JumpHeight=v end end end})
MovTab:CreateSlider({Name="Gravity",Range={0,300},Increment=1,Suffix=" gs",CurrentValue=196,Flag="Gravity",Callback=function(v) workspace.Gravity=v end})

-- ============================================================
-- TAB 9 — ESCAPE
-- ============================================================
local EscapeTab=Window:CreateTab("Escape","log-out")
EscapeTab:CreateButton({Name="Check My Ping",Callback=function()
    local ping=getMyPing()
    Rayfield:Notify({Title="Your Ping",Content=ping.."ms  "..(ping<50 and "Excellent 🟢" or ping<100 and "Good 🟡" or ping<200 and "OK 🟠" or "High 🔴"),Duration=5})
end})
EscapeTab:CreateDropdown({
    Name="Server Region Preference",
    Options={"Closest  (lowest ping)","Asia / Japan  (low pop)","Europe  (mid pop)","US East or West  (high pop)","Random  (any server)"},
    CurrentOption={"Closest  (lowest ping)"},
    Flag="HopRegion",
    Callback=function(selected)
        hopRegion=selected[1] or selected
        if type(hopRegion)=="table" then hopRegion=hopRegion[1] end
        hopSortMode=hopRegion=="Random  (any server)" and "random" or "ping"
        Rayfield:Notify({Title="Region Set",Content=hopRegion,Duration=3})
    end,
})
EscapeTab:CreateDivider()
EscapeTab:CreateButton({Name="Server Hop  🌐",Callback=function() stopLoop();serverHop() end})
EscapeTab:CreateButton({Name="Rejoin Same Game",Callback=function()
    queueSelf();TeleportService:Teleport(game.PlaceId,lp)
end})

-- ============================================================
-- Respawn handling
-- ============================================================
lp.CharacterAdded:Connect(function()
    local was=(sessionId%2==1); if was then task.wait(2);startLoop() end
    if spoofActive then task.wait(0.5)
        local hum=lp.Character and lp.Character:WaitForChild("Humanoid",5)
        if hum then hum.DisplayName=currentSpoofName end end
end)

Rayfield:Notify({
    Title   = "Noob Troll Hub  💻 v5.3",
    Content = "New Highlight ESP ready! Visible through walls 🐐",
    Duration = 5,
})
