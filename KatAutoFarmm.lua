-- ============================================================
--   NOOB TROLL HUB  |  Rayfield Edition
--   Auto re-executes itself after every server hop / teleport.
-- ============================================================

-- ============================================================
-- AUTO EXECUTE ON TELEPORT
-- This MUST be at the very top before anything else loads.
-- queue_on_teleport tells the executor to re-run this exact
-- script the moment we land in a new server.
-- ============================================================
local scriptSource = nil

-- Try to grab our own source so we can re-queue it
pcall(function()
    scriptSource = game:HttpGet("https://raw.githubusercontent.com/YourUser/YourRepo/main/NoobTrollHub.lua")
end)

-- Supported executor functions (works on Synapse, KRNL, Fluxus, etc.)
local queueTeleport = queue_on_teleport
    or (syn and syn.queue_on_teleport)
    or (fluxus and fluxus.queue_on_teleport)

-- We queue ourselves BEFORE the teleport happens so the new
-- server receives the script automatically.
if queueTeleport then
    -- We queue the full script source using getscriptbytecode / getscriptsource
    -- Fallback: queue a loadstring that re-pulls from wherever you host the script.
    -- OPTION A — if your executor supports script self-reference:
    pcall(function()
        local src = game:HttpGet("https://raw.githubusercontent.com/YourUser/YourRepo/main/NoobTrollHub.lua")
        if src and #src > 0 then
            queueTeleport(src)
        end
    end)
end

-- ============================================================
-- Wait for game to be loaded in the new server
-- ============================================================
if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(2) -- small grace period for the new server to init

-- ============================================================
-- Services
-- ============================================================
local Rayfield         = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Players          = game:GetService("Players")
local HttpService      = game:GetService("HttpService")
local TeleportService  = game:GetService("TeleportService")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local lp   = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hum  = char:WaitForChild("Humanoid")

-- ============================================================
-- SESSION ID  (ghost-loop fix)
-- ============================================================
local sessionId = 0

local function stopLoop()
    sessionId = sessionId + 1
end

local function startLoop()
    stopLoop()
    local myId = sessionId

    task.spawn(function()
        while sessionId == myId do
            local targets = {}
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= lp and plr.Character then
                    local h = plr.Character:FindFirstChildWhichIsA("Humanoid")
                    local r = plr.Character:FindFirstChild("HumanoidRootPart")
                    if h and r and h.Health > 0 then
                        table.insert(targets, plr)
                    end
                end
            end

            if #targets == 0 then task.wait(0.5); continue end

            local target     = targets[math.random(1, #targets)]
            local targetRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
            local myRoot     = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")

            if targetRoot and myRoot and sessionId == myId then
                myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, _G.BEHIND_DIST or 2)

                for i = 1, (_G.CLICK_TIMES or 3) do
                    if sessionId ~= myId then break end
                    local tool = lp.Character and lp.Character:FindFirstChildWhichIsA("Tool")
                    if tool then
                        pcall(function() tool:Activate() end)
                        pcall(function() if mouse1click then mouse1click() end end)
                    end
                    task.wait(_G.CLICK_DELAY or 0.05)
                end

                local remaining = (_G.STAY_TIME or 0.3) - ((_G.CLICK_TIMES or 3) * (_G.CLICK_DELAY or 0.05))
                if remaining > 0 and sessionId == myId then task.wait(remaining) end
            else
                task.wait(0.1)
            end
        end
    end)
end

_G.BEHIND_DIST = 2
_G.STAY_TIME   = 0.3
_G.CLICK_TIMES = 3
_G.CLICK_DELAY = 0.05

-- ============================================================
-- SERVER HOP  (re-queues the script before teleporting)
-- ============================================================
local isHopping = false

local function serverHop()
    if isHopping then return end
    isHopping = true

    Rayfield:Notify({ Title = "Server Hop", Content = "Finding a fresh server...", Duration = 4 })

    task.spawn(function()
        local placeId = game.PlaceId
        local jobId   = game.JobId

        local ok, res = pcall(function()
            return game:HttpGet(
                ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100"):format(placeId)
            )
        end)

        local found = false
        if ok and res then
            local data = HttpService:JSONDecode(res)
            if data and data.data then
                local servers = {}
                for _, s in pairs(data.data) do
                    if type(s.id) == "string" and s.id ~= jobId
                    and type(s.playing) == "number" and type(s.maxPlayers) == "number"
                    and s.playing < s.maxPlayers then
                        table.insert(servers, s.id)
                    end
                end

                if #servers > 0 then
                    found = true

                    -- ── Re-queue the script BEFORE teleporting ──────────
                    -- This is what makes it auto-execute in the new server.
                    if queueTeleport then
                        pcall(function()
                            local src = game:HttpGet("https://raw.githubusercontent.com/YourUser/YourRepo/main/NoobTrollHub.lua")
                            if src and #src > 0 then
                                queueTeleport(src)
                            end
                        end)
                    end

                    stopLoop()
                    Rayfield:Notify({ Title = "Server Hop", Content = "Script queued! See ya losers 👋", Duration = 3 })
                    task.wait(1)
                    TeleportService:TeleportToPlaceInstance(placeId, servers[math.random(1, #servers)], lp)
                end
            end
        end

        if not found then
            Rayfield:Notify({ Title = "Server Hop", Content = "No open servers found, try again!", Duration = 4 })
            isHopping = false
        end
    end)
end

-- ============================================================
-- NOOB DISGUISE HELPERS
-- ============================================================
local function applyNoobColors()
    local c = lp.Character
    if not c then return end
    local colors = {
        ["Head"]           = Color3.fromRGB(255, 204, 153),
        ["Torso"]          = Color3.fromRGB(0, 170, 0),
        ["Left Arm"]       = Color3.fromRGB(0, 170, 0),
        ["Right Arm"]      = Color3.fromRGB(0, 170, 0),
        ["Left Leg"]       = Color3.fromRGB(0, 0, 170),
        ["Right Leg"]      = Color3.fromRGB(0, 0, 170),
        ["UpperTorso"]     = Color3.fromRGB(0, 170, 0),
        ["LowerTorso"]     = Color3.fromRGB(0, 0, 170),
        ["RightUpperArm"]  = Color3.fromRGB(0, 170, 0),
        ["LeftUpperArm"]   = Color3.fromRGB(0, 170, 0),
        ["RightLowerArm"]  = Color3.fromRGB(0, 170, 0),
        ["LeftLowerArm"]   = Color3.fromRGB(0, 170, 0),
        ["RightHand"]      = Color3.fromRGB(255, 204, 153),
        ["LeftHand"]       = Color3.fromRGB(255, 204, 153),
        ["RightUpperLeg"]  = Color3.fromRGB(0, 0, 170),
        ["LeftUpperLeg"]   = Color3.fromRGB(0, 0, 170),
        ["RightLowerLeg"]  = Color3.fromRGB(0, 0, 170),
        ["LeftLowerLeg"]   = Color3.fromRGB(0, 0, 170),
        ["RightFoot"]      = Color3.fromRGB(0, 0, 170),
        ["LeftFoot"]       = Color3.fromRGB(0, 0, 170),
    }
    for partName, color in pairs(colors) do
        local part = c:FindFirstChild(partName)
        if part and part:IsA("BasePart") then
            part.BrickColor = BrickColor.new(color)
        end
    end
    for _, v in pairs(c:GetDescendants()) do
        if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("Accessory") then
            pcall(function() v:Destroy() end)
        end
    end
    Rayfield:Notify({ Title = "Noob Disguise", Content = "You now look like a fresh noob! 😂", Duration = 4 })
end

local function applyNoobWalk(enabled)
    local h2 = lp.Character and lp.Character:FindFirstChildWhichIsA("Humanoid")
    if h2 then h2.WalkSpeed = enabled and 8 or 16 end
end

local fakeTripThread = nil
local function fakeTripLoop(enabled)
    if fakeTripThread then task.cancel(fakeTripThread); fakeTripThread = nil end
    if not enabled then return end
    fakeTripThread = task.spawn(function()
        while enabled do
            task.wait(math.random(4, 9))
            local h2 = lp.Character and lp.Character:FindFirstChildWhichIsA("Humanoid")
            if h2 then
                h2.PlatformStand = true
                task.wait(0.8)
                h2.PlatformStand = false
            end
        end
    end)
end

local function noobSpin()
    local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local bav           = Instance.new("BodyAngularVelocity")
    bav.MaxTorque       = Vector3.new(0, math.huge, 0)
    bav.P               = math.huge
    bav.AngularVelocity = Vector3.new(0, 15, 0)
    bav.Parent          = root
    task.wait(2.5)
    bav:Destroy()
end

-- ============================================================
-- CHAT BAIT
-- ============================================================
local chatSpamThread   = nil
local chatSpamEnabled  = false
local chatSpamInterval = 8

local noobPhrases = {
    "pls dont kill me",
    "how do i play",
    "wait how do u use tool",
    "omg i just started",
    "pls spare me im new",
    "wait what is this game",
    "how do i run",
    "guys where do i go",
    "HELLO??",
    "wait is this like minecraft",
    "admin pls help me",
    "wtf why did u kill me im new",
    "pls give me a chance im learning",
    "bro stop im a noob",
    "i dont know how to fight",
}

local function sendChat(msg)
    pcall(function()
        if game:GetService("TextChatService").ChatVersion == Enum.ChatVersion.LegacyChatService then
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
        else
            game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(msg)
        end
    end)
end

local function startChatSpam(enabled, interval)
    if chatSpamThread then task.cancel(chatSpamThread); chatSpamThread = nil end
    if not enabled then return end
    chatSpamThread = task.spawn(function()
        while enabled do
            sendChat(noobPhrases[math.random(1, #noobPhrases)])
            task.wait(interval or 8)
        end
    end)
end

-- ============================================================
-- MOVEMENT HELPERS
-- ============================================================
local infJump   = nil
local infJumpDB = false
local function toggleInfJump(v)
    if infJump then infJump:Disconnect(); infJump = nil end
    infJumpDB = false
    if v then
        infJump = UserInputService.JumpRequest:Connect(function()
            if not infJumpDB then
                infJumpDB = true
                local h2 = lp.Character and lp.Character:FindFirstChildWhichIsA("Humanoid")
                if h2 then h2:ChangeState(Enum.HumanoidStateType.Jumping) end
                task.wait()
                infJumpDB = false
            end
        end)
    end
end

local noclipConn = nil
local function toggleNoclip(v)
    if v then
        if noclipConn then noclipConn:Disconnect() end
        noclipConn = RunService.Stepped:Connect(function()
            if lp.Character then
                for _, p in pairs(lp.Character:GetDescendants()) do
                    if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
                end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
    end
end

-- ============================================================
-- RAYFIELD WINDOW
-- ============================================================
local Window = Rayfield:CreateWindow({
    Name                = "Noob Troll Hub",
    LoadingTitle        = "Noob Troll Hub",
    LoadingSubtitle     = "Preparing the bait... 🎣",
    ConfigurationSaving = { Enabled = false },
    Discord             = { Enabled = false },
    KeySystem           = false,
})

-- ============================================================
-- TAB 1 — DISGUISE
-- ============================================================
local DisguiseTab = Window:CreateTab("Disguise", "user")

DisguiseTab:CreateButton({
    Name     = "Apply Noob Look  (remove hats + clothes)",
    Callback = function() applyNoobColors() end,
})

DisguiseTab:CreateToggle({
    Name         = "Slow Walk  (looks lost)",
    CurrentValue = false,
    Flag         = "SlowWalk",
    Callback     = function(v) applyNoobWalk(v) end,
})

DisguiseTab:CreateToggle({
    Name         = "Fake Trip  (fall randomly)",
    CurrentValue = false,
    Flag         = "FakeTrip",
    Callback     = function(v) fakeTripLoop(v) end,
})

DisguiseTab:CreateButton({
    Name     = "Noob Spin  (spin confused for 2.5s)",
    Callback = function() noobSpin() end,
})

DisguiseTab:CreateParagraph({
    Title   = "Disguise Tips",
    Content = "1. Hit 'Apply Noob Look' first to strip your avatar.\n"
           .. "2. Enable Slow Walk so you wander like lost.\n"
           .. "3. Enable Fake Trip to randomly fall — drives toxic players crazy.\n"
           .. "4. Use Noob Spin near enemies to look panicked before destroying them 😂",
})

-- ============================================================
-- TAB 2 — CHAT BAIT
-- ============================================================
local ChatTab = Window:CreateTab("Chat Bait", "message-circle")

ChatTab:CreateToggle({
    Name         = "Auto Noob Chat  (random noob phrases)",
    CurrentValue = false,
    Flag         = "ChatSpam",
    Callback     = function(v)
        chatSpamEnabled = v
        startChatSpam(v, chatSpamInterval)
    end,
})

ChatTab:CreateSlider({
    Name         = "Chat Interval",
    Range        = { 3, 30 },
    Increment    = 1,
    Suffix       = "s",
    CurrentValue = 8,
    Flag         = "ChatInterval",
    Callback     = function(v)
        chatSpamInterval = v
        if chatSpamEnabled then startChatSpam(true, v) end
    end,
})

ChatTab:CreateParagraph({
    Title   = "Noob Phrases include...",
    Content = "\"pls dont kill me\" • \"how do i play\" • \"omg i just started\" • \"wait is this like minecraft\" "
           .. "• \"admin pls help me\" • \"wtf why did u kill me im new\" • and more 😂\n\n"
           .. "Best combo: turn this on, stand near a toxic player, let them get cocky, THEN enable TP Kill.",
})

-- ============================================================
-- TAB 3 — TP KILL
-- ============================================================
local KillTab = Window:CreateTab("TP Kill", "sword")

KillTab:CreateToggle({
    Name         = "Auto TP + Auto Click  [ ON / OFF ]",
    CurrentValue = false,
    Flag         = "MainToggle",
    Callback     = function(v)
        if v then
            startLoop()
            Rayfield:Notify({ Title = "TP Kill", Content = "Activated — time to end them! 😈", Duration = 4 })
        else
            stopLoop()
            Rayfield:Notify({ Title = "TP Kill", Content = "Stopped.", Duration = 3 })
        end
    end,
})

KillTab:CreateSlider({
    Name         = "Distance Behind Target",
    Range        = { 1, 10 },
    Increment    = 1,
    Suffix       = " studs",
    CurrentValue = 2,
    Flag         = "BehindDist",
    Callback     = function(v) _G.BEHIND_DIST = v end,
})

KillTab:CreateSlider({
    Name         = "Stay Time (×0.1s)",
    Range        = { 1, 20 },
    Increment    = 1,
    Suffix       = " ×0.1s",
    CurrentValue = 3,
    Flag         = "StayTime",
    Callback     = function(v) _G.STAY_TIME = v * 0.1 end,
})

KillTab:CreateSlider({
    Name         = "Clicks Per Visit",
    Range        = { 1, 15 },
    Increment    = 1,
    Suffix       = " clicks",
    CurrentValue = 3,
    Flag         = "ClickCount",
    Callback     = function(v) _G.CLICK_TIMES = v end,
})

KillTab:CreateSlider({
    Name         = "Delay Between Clicks (ms)",
    Range        = { 10, 500 },
    Increment    = 10,
    Suffix       = " ms",
    CurrentValue = 50,
    Flag         = "ClickDelay",
    Callback     = function(v) _G.CLICK_DELAY = v / 1000 end,
})

-- ============================================================
-- TAB 4 — MOVEMENT
-- ============================================================
local MovTab = Window:CreateTab("Movement", "zap")

MovTab:CreateToggle({
    Name         = "Infinite Jump",
    CurrentValue = false,
    Flag         = "InfJump",
    Callback     = function(v) toggleInfJump(v) end,
})

MovTab:CreateToggle({
    Name         = "Noclip",
    CurrentValue = false,
    Flag         = "Noclip",
    Callback     = function(v) toggleNoclip(v) end,
})

MovTab:CreateSlider({
    Name         = "Walk Speed",
    Range        = { 0, 250 },
    Increment    = 1,
    Suffix       = " ws",
    CurrentValue = 16,
    Flag         = "WalkSpeed",
    Callback     = function(v)
        local h2 = lp.Character and lp.Character:FindFirstChildWhichIsA("Humanoid")
        if h2 then h2.WalkSpeed = v end
    end,
})

MovTab:CreateSlider({
    Name         = "Jump Power",
    Range        = { 0, 300 },
    Increment    = 1,
    Suffix       = " jp",
    CurrentValue = 50,
    Flag         = "JumpPower",
    Callback     = function(v)
        local h2 = lp.Character and lp.Character:FindFirstChildWhichIsA("Humanoid")
        if h2 then
            if h2.UseJumpPower then h2.JumpPower = v else h2.JumpHeight = v end
        end
    end,
})

MovTab:CreateSlider({
    Name         = "Gravity",
    Range        = { 0, 300 },
    Increment    = 1,
    Suffix       = " gs",
    CurrentValue = 196,
    Flag         = "Gravity",
    Callback     = function(v) workspace.Gravity = v end,
})

-- ============================================================
-- TAB 5 — ESCAPE
-- ============================================================
local EscapeTab = Window:CreateTab("Escape", "log-out")

-- Shows whether auto-execute is supported on this executor
local autoExecStatus = queueTeleport
    and "✓ Auto-execute is ACTIVE — the hub will reappear in every new server automatically!"
    or  "✗ Your executor does not support queue_on_teleport. The hub won't auto-execute after hopping. Try Synapse X, KRNL, or Fluxus."

EscapeTab:CreateParagraph({
    Title   = "Auto Execute Status",
    Content = autoExecStatus,
})

EscapeTab:CreateButton({
    Name     = "Server Hop  (auto-reloads hub in new server)",
    Callback = function()
        stopLoop()
        serverHop()
    end,
})

EscapeTab:CreateButton({
    Name     = "Rejoin Same Game",
    Callback = function()
        -- Re-queue before rejoin too
        if queueTeleport then
            pcall(function()
                local src = game:HttpGet("https://raw.githubusercontent.com/YourUser/YourRepo/main/NoobTrollHub.lua")
                if src and #src > 0 then queueTeleport(src) end
            end)
        end
        TeleportService:Teleport(game.PlaceId, lp)
    end,
})

EscapeTab:CreateParagraph({
    Title   = "The Perfect Troll Cycle",
    Content = "1. Apply Noob Look + Slow Walk + Auto Chat.\n"
           .. "2. Let toxic players brag and target you.\n"
           .. "3. Flip ON Auto TP Kill and destroy everyone.\n"
           .. "4. Hit Server Hop — the hub auto-loads in the new server 😂\n"
           .. "5. Repeat forever.",
})

-- ============================================================
-- Auto-restart TP kill loop after respawn
-- ============================================================
lp.CharacterAdded:Connect(function(newChar)
    char = newChar
    hum  = newChar:WaitForChild("Humanoid")
    local wasRunning = (sessionId % 2 == 1)
    if wasRunning then
        task.wait(2)
        startLoop()
    end
end)

-- ============================================================
-- READY
-- ============================================================
Rayfield:Notify({
    Title    = "Noob Troll Hub",
    Content  = "Loaded! Auto-execute " .. (queueTeleport and "ACTIVE ✓" or "not supported on this executor"),
    Duration = 6,
})
