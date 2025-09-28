
-- Luex UI (Enhanced) | Aesthetic red-black translucent UI, draggable, minimize-to-logo
-- SAFE: purely client UI + local animations
-- WIDE VERSION with Player Target Selection and Auto Kill Selected


local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
-- Premium Key Mechanism
local PREMIUM_KEY = "1"
local hasPremium = getgenv().LuexKey == PREMIUM_KEY

-- Cleanup old
pcall(function()
    if game.CoreGui:FindFirstChild("LuexUI") then
        game.CoreGui.LuexUI:Destroy()
    end
end)

-- Create ScreenGui
local screen = Instance.new("ScreenGui")
screen.Name = "LuexUI"
screen.ResetOnSpawn = false
screen.Parent = game.CoreGui

-- Main container (WIDER)
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 600, 0, 380)  -- Wider UI
main.Position = UDim2.new(0.05, 0, 0.12, 0)
main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
main.BackgroundTransparency = 0.18
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Active = true
main.Parent = screen

-- Subtle red border glow (outer)
local border = Instance.new("Frame", main)
border.Name = "BorderGlow"
border.AnchorPoint = Vector2.new(0.5, 0.5)
border.Position = UDim2.new(0.5, 0, 0.5, 0)
border.Size = UDim2.new(1, 8, 1, 8)
border.BackgroundTransparency = 1
border.ZIndex = 0
local borderStroke = Instance.new("UIStroke", border)
borderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
borderStroke.Color = Color3.fromRGB(200, 30, 30)
borderStroke.Transparency = 0.7
borderStroke.Thickness = 2

-- Top bar (drag handle)
local topBar = Instance.new("Frame", main)
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 46)
topBar.Position = UDim2.new(0, 0, 0, 0)
topBar.BackgroundTransparency = 1

-- Luex logo (TextLabel with glow + text stroke)
local logo = Instance.new("TextLabel", topBar)
logo.Name = "Logo"
logo.Text = "LUEX"
logo.Font = Enum.Font.GothamBlack
logo.TextSize = 28
logo.TextColor3 = Color3.fromRGB(255, 120, 80)
logo.TextStrokeColor3 = Color3.fromRGB(120, 10, 10)
logo.TextStrokeTransparency = 0.3
logo.BackgroundTransparency = 1
logo.Position = UDim2.new(0, 12, 0, 6)
logo.Size = UDim2.new(0, 160, 0, 34)
logo.TextXAlignment = Enum.TextXAlignment.Left
logo.ZIndex = 3

-- Subtle gradient on text (via UIGradient on a label overlay)
local gradHolder = Instance.new("Frame", logo)
gradHolder.Size = UDim2.new(1, 0, 1, 0)
gradHolder.BackgroundTransparency = 1
local uiGrad = Instance.new("UIGradient", gradHolder)
uiGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 60, 20)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 160, 80)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 40, 10))
}
uiGrad.Rotation = 10
gradHolder.ZIndex = 2

-- Crack effect: a few rotated lines layered on logo (animated)
local crackContainer = Instance.new("Frame", topBar)
crackContainer.Name = "Crack"
crackContainer.Size = UDim2.new(0, 140, 0, 34)
crackContainer.Position = UDim2.new(0, 12, 0, 6)
crackContainer.BackgroundTransparency = 1
crackContainer.ZIndex = 2

local function makeCrackLine(x, y, width, rot)
    local f = Instance.new("Frame", crackContainer)
    f.Size = UDim2.new(0, width, 0, 2)
    f.Position = UDim2.new(0, x, 0, y)
    f.BackgroundColor3 = Color3.fromRGB(255, 60, 20)
    f.BackgroundTransparency = 0.25
    f.Rotation = rot
    f.BorderSizePixel = 0
    f.ZIndex = 1
    return f
end

makeCrackLine(0.15, 18, 60, -12)
makeCrackLine(0.45, 8, 40, 8)
makeCrackLine(0.65, 22, 50, -6)

-- Minimize/restore button (top-right)
local minBtn = Instance.new("TextButton", topBar)
minBtn.Name = "Minimize"
minBtn.Size = UDim2.new(0, 36, 0, 28)
minBtn.Position = UDim2.new(1, -44, 0, 8)
minBtn.BackgroundColor3 = Color3.fromRGB(45, 8, 8)
minBtn.BorderSizePixel = 0
minBtn.Text = "-"
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 22
minBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
minBtn.ZIndex = 4

-- Content area (divided into two columns)
local content = Instance.new("Frame", main)
content.Name = "Content"
content.Position = UDim2.new(0, 12, 0, 56)
content.Size = UDim2.new(1, -24, 1, -68)
content.BackgroundTransparency = 1

-- Left column for controls
local leftColumn = Instance.new("Frame", content)
leftColumn.Name = "LeftColumn"
leftColumn.Size = UDim2.new(0.48, 0, 1, 0)
leftColumn.Position = UDim2.new(0, 0, 0, 0)
leftColumn.BackgroundTransparency = 1

-- Right column for player selection
local rightColumn = Instance.new("Frame", content)
rightColumn.Name = "RightColumn"
rightColumn.Size = UDim2.new(0.48, 0, 1, 0)
rightColumn.Position = UDim2.new(0.52, 0, 0, 0)
rightColumn.BackgroundTransparency = 1

-- Auto Kill button
local btnAuto = Instance.new("TextButton", leftColumn)
btnAuto.Size = UDim2.new(1, 0, 0, 46)
btnAuto.Position = UDim2.new(0, 0, 0, 0)
btnAuto.BackgroundColor3 = Color3.fromRGB(35, 6, 6)
btnAuto.BorderSizePixel = 0
btnAuto.Text = "Toggle Auto Kill"
btnAuto.Font = Enum.Font.GothamBold
btnAuto.TextSize = 18
btnAuto.TextColor3 = Color3.fromRGB(240, 240, 240)
btnAuto.AutoButtonColor = false

-- Hover glow
local stroke = Instance.new("UIStroke", btnAuto)
stroke.Color = Color3.fromRGB(200, 20, 20)
stroke.Transparency = 0.85
stroke.Thickness = 1.5

-- Auto Kill Selected button
local btnAutoSelected = Instance.new("TextButton", leftColumn)
btnAutoSelected.Size = UDim2.new(1, 0, 0, 46)
btnAutoSelected.Position = UDim2.new(0, 0, 0, 52)
btnAutoSelected.BackgroundColor3 = Color3.fromRGB(35, 6, 6)
btnAutoSelected.BorderSizePixel = 0
btnAutoSelected.Text = "Auto Kill Selected: OFF"
btnAutoSelected.Font = Enum.Font.GothamBold
btnAutoSelected.TextSize = 18
btnAutoSelected.TextColor3 = Color3.fromRGB(240, 240, 240)
btnAutoSelected.AutoButtonColor = false

-- Hover glow
local strokeAutoSelected = Instance.new("UIStroke", btnAutoSelected)
strokeAutoSelected.Color = Color3.fromRGB(200, 20, 20)
strokeAutoSelected.Transparency = 0.85
strokeAutoSelected.Thickness = 1.5

-- Change Player button
local btnChangePlayer = Instance.new("TextButton", leftColumn)
btnChangePlayer.Size = UDim2.new(1, 0, 0, 46)
btnChangePlayer.Position = UDim2.new(0, 0, 0, 104)
btnChangePlayer.BackgroundColor3 = Color3.fromRGB(35, 6, 6)
btnChangePlayer.BorderSizePixel = 0
btnChangePlayer.Text = "Change Player"
btnChangePlayer.Font = Enum.Font.GothamBold
btnChangePlayer.TextSize = 18
btnChangePlayer.TextColor3 = Color3.fromRGB(240, 240, 240)
btnChangePlayer.AutoButtonColor = false

-- Hover glow
local stroke2 = Instance.new("UIStroke", btnChangePlayer)
stroke2.Color = Color3.fromRGB(200, 20, 20)
stroke2.Transparency = 0.85
stroke2.Thickness = 1.5

-- Predict Direction button
local btnPredict = Instance.new("TextButton", leftColumn)
btnPredict.Size = UDim2.new(1, 0, 0, 46)
btnPredict.Position = UDim2.new(0, 0, 0, 156)
btnPredict.BackgroundColor3 = Color3.fromRGB(35, 6, 6)
btnPredict.BorderSizePixel = 0
btnPredict.Text = hasPremium and "Predict Direction: OFF" or "Predict Direction: PREMIUM"
btnPredict.Font = Enum.Font.GothamBold
btnPredict.TextSize = 18
btnPredict.TextColor3 = Color3.fromRGB(240, 240, 240)
btnPredict.AutoButtonColor = false

-- Hover glow
local stroke3 = Instance.new("UIStroke", btnPredict)
stroke3.Color = Color3.fromRGB(200, 20, 20)
stroke3.Transparency = 0.85
stroke3.Thickness = 1.5

-- Auto Server Hop button
local btnServerHop = Instance.new("TextButton", leftColumn)
btnServerHop.Size = UDim2.new(1, 0, 0, 46)
btnServerHop.Position = UDim2.new(0, 0, 0, 208)
btnServerHop.BackgroundColor3 = Color3.fromRGB(35, 6, 6)
btnServerHop.BorderSizePixel = 0
btnServerHop.Text = "Auto Server Hop: OFF"
btnServerHop.Font = Enum.Font.GothamBold
btnServerHop.TextSize = 18
btnServerHop.TextColor3 = Color3.fromRGB(240, 240, 240)
btnServerHop.AutoButtonColor = false

-- Hover glow
local stroke5 = Instance.new("UIStroke", btnServerHop)
stroke5.Color = Color3.fromRGB(200, 20, 20)
stroke5.Transparency = 0.85
stroke5.Thickness = 1.5

-- Auto Safe Zone button
local btnSafeZone = Instance.new("TextButton", leftColumn)
btnSafeZone.Size = UDim2.new(1, 0, 0, 46)
btnSafeZone.Position = UDim2.new(0, 0, 0, 260)
btnSafeZone.BackgroundColor3 = Color3.fromRGB(35, 6, 6)
btnSafeZone.BorderSizePixel = 0
btnSafeZone.Text = hasPremium and "Auto Safe Zone: OFF" or "Auto Safe Zone: PREMIUM"
btnSafeZone.Font = Enum.Font.GothamBold
btnSafeZone.TextSize = 18
btnSafeZone.TextColor3 = Color3.fromRGB(240, 240, 240)
btnSafeZone.AutoButtonColor = false

-- Hover glow
local stroke6 = Instance.new("UIStroke", btnSafeZone)
stroke6.Color = Color3.fromRGB(200, 20, 20)
stroke6.Transparency = 0.85
stroke6.Thickness = 1.5

-- Player Selection Title
local playerTitle = Instance.new("TextLabel", rightColumn)
playerTitle.Size = UDim2.new(1, 0, 0, 28)
playerTitle.Position = UDim2.new(0, 0, 0, 0)
playerTitle.BackgroundTransparency = 1
playerTitle.TextColor3 = Color3.fromRGB(255, 150, 150)
playerTitle.TextSize = 16
playerTitle.Font = Enum.Font.GothamBold
playerTitle.Text = "PLAYER SELECTION"
playerTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Player List Container
local playerListContainer = Instance.new("ScrollingFrame", rightColumn)
playerListContainer.Name = "PlayerList"
playerListContainer.Size = UDim2.new(1, 0, 0, 238) -- Reduced height to make space for buttons
playerListContainer.Position = UDim2.new(0, 0, 0, 30)
playerListContainer.BackgroundColor3 = Color3.fromRGB(20, 5, 5)
playerListContainer.BackgroundTransparency = 0.2
playerListContainer.BorderSizePixel = 0
playerListContainer.ScrollBarThickness = 6
playerListContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
playerListContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
playerListContainer.ScrollingDirection = Enum.ScrollingDirection.Y

-- Auto Refresh Toggle
local autoRefreshToggle = Instance.new("TextButton", rightColumn)
autoRefreshToggle.Size = UDim2.new(1, 0, 0, 36)
autoRefreshToggle.Position = UDim2.new(0, 0, 1, -84) -- Moved below player list
autoRefreshToggle.BackgroundColor3 = Color3.fromRGB(35, 6, 6)
autoRefreshToggle.BorderSizePixel = 0
autoRefreshToggle.Text = "Auto Refresh: OFF"
autoRefreshToggle.Font = Enum.Font.GothamBold
autoRefreshToggle.TextSize = 16
autoRefreshToggle.TextColor3 = Color3.fromRGB(240, 240, 240)
autoRefreshToggle.AutoButtonColor = false

-- Hover glow
local stroke8 = Instance.new("UIStroke", autoRefreshToggle)
stroke8.Color = Color3.fromRGB(200, 20, 20)
stroke8.Transparency = 0.85
stroke8.Thickness = 1.5

-- Refresh Button
local refreshBtn = Instance.new("TextButton", rightColumn)
refreshBtn.Size = UDim2.new(1, 0, 0, 36)
refreshBtn.Position = UDim2.new(0, 0, 1, -42) -- Moved below Auto Refresh
refreshBtn.BackgroundColor3 = Color3.fromRGB(35, 6, 6)
refreshBtn.BorderSizePixel = 0
refreshBtn.Text = "🔄 Refresh Players"
refreshBtn.Font = Enum.Font.GothamBold
refreshBtn.TextSize = 16
refreshBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
refreshBtn.AutoButtonColor = false

-- Hover glow
local stroke7 = Instance.new("UIStroke", refreshBtn)
stroke7.Color = Color3.fromRGB(200, 20, 20)
stroke7.Transparency = 0.85
stroke7.Thickness = 1.5

-- Small hint text
local hint = Instance.new("TextLabel", leftColumn)
hint.Size = UDim2.new(1, 0, 0, 28)
hint.Position = UDim2.new(0, 0, 1, -28)
hint.BackgroundTransparency = 1
hint.TextColor3 = Color3.fromRGB(200, 200, 200)
hint.TextSize = 12
hint.Font = Enum.Font.Gotham
hint.Text = "Luex v1.9 | Enhanced Combat System + Server Hop + Safe Zone"
hint.TextWrapped = true

-- Logo animation: pulsing glow
local glowFrame = Instance.new("Frame", logo)
glowFrame.Size = UDim2.new(1.6, 0, 1.6, 0)
glowFrame.Position = UDim2.new(-0.3, 0, -0.3, 0)
glowFrame.BackgroundColor3 = Color3.fromRGB(255, 60, 20)
glowFrame.BackgroundTransparency = 0.95
glowFrame.ZIndex = 1
local glowStroke = Instance.new("UIStroke", glowFrame)
glowStroke.Color = Color3.fromRGB(255, 80, 20)
glowStroke.Transparency = 0.9
glowStroke.Thickness = 6

-- Store global refs
getgenv().LuexUI = {
    Screen = screen,
    Main = main,
    Logo = logo,
    MinBtn = minBtn,
    AutoBtn = btnAuto,
    AutoSelectedBtn = btnAutoSelected,
    ChangePlayerBtn = btnChangePlayer,
    PredictBtn = btnPredict,
    ServerHopBtn = btnServerHop,
    SafeZoneBtn = btnSafeZone,
    PlayerList = playerListContainer,
    RefreshBtn = refreshBtn,
    AutoRefreshToggle = autoRefreshToggle,
    Glow = glowFrame,
    Crack = crackContainer
}

-- Enhanced drag support
local dragging = false
local dragStart, startPos

local function updateDrag(input)
    if dragging then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end

topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

topBar.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) and dragging then
        updateDrag(input)
    end
end)

-- Minimize behavior (tween) - keeps current position
local minimized = false
minBtn.MouseButton1Click:Connect(function()
    if minimized then
        TweenService:Create(main, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 600, 0, 380)}):Play()
        content.Visible = true
        logo.TextTransparency = 0
    else
        local targetSize = UDim2.new(0, 150, 0, 46)
        TweenService:Create(main, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = targetSize}):Play()
        content.Visible = false
        logo.TextTransparency = 0
    end
    minimized = not minimized
end)

-- Luex Logic | Pure Combat System
local UI = getgenv().LuexUI
local autoOn = false
local autoSelectedOn = false
local predictOn = false
local serverHopOn = false
local safeZoneOn = false
local autoRefreshOn = false
local currentTarget = nil
local highlightGui = nil
local lastAttack = 0
local lastFace = 0
local attackRate = 0.01
local faceRate = 0.01
local lastNoTargetNotify = 0
local noTargetNotifyCooldown = 5

-- Safe Zone variables
local safePlatform = nil
local wasAutoKillOn = false

-- Check if we have stored states from previous execution
if getgenv().LuexStates then
    autoOn = getgenv().LuexStates.AutoOn or false
    autoSelectedOn = getgenv().LuexStates.AutoSelectedOn or false
    predictOn = getgenv().LuexStates.PredictOn or false
    serverHopOn = getgenv().LuexStates.ServerHopOn or false
    safeZoneOn = getgenv().LuexStates.SafeZoneOn or false
    autoRefreshOn = getgenv().LuexStates.AutoRefreshOn or false

    UI.AutoBtn.Text = "Toggle Auto Kill: " .. (autoOn and "ON" or "OFF")
    UI.AutoSelectedBtn.Text = "Auto Kill Selected: " .. (autoSelectedOn and "ON" or "OFF")
    UI.PredictBtn.Text = hasPremium and "Predict Direction: " .. (predictOn and "ON" or "OFF") or "Predict Direction: PREMIUM"
    UI.ServerHopBtn.Text = "Auto Server Hop: " .. (serverHopOn and "ON" or "OFF")
    UI.SafeZoneBtn.Text = hasPremium and "Auto Safe Zone: " .. (safeZoneOn and "ON" or "OFF") or "Auto Safe Zone: PREMIUM"
    UI.AutoRefreshToggle.Text = "Auto Refresh: " .. (autoRefreshOn and "ON" or "OFF")
end

-- Tool list
local toolList = {
    "Normal Punch",
    "Consecutive Punches",
    "Shove",
    "Uppercut",
    "Death Counter",
    "Table Flip",
    "Serious Punch",
    "Omni-Directional Punch",
    "Flowing Water",
    "Lethal Whirlwind Stream",
    "Hunter's Grasp",
    "Prey's Peril",
    "Water Stream Cutting Fist",
    "The Final Hunt",
    "Rock Splitting Fist",
    "Crushed Rock",
    "Machine Gun Blows",
    "Ignition Burst",
    "Blitz Shot",
    "Jet Dive",
    "Thunder Kick",
    "Speedblitz Dropkick",
    "Flamewave Cannon",
    "Incinerate",
    "Flash Strike",
    "Whirlwind Kick",
    "Scatter",
    "Explosive Shuriken",
    "Twinblade Rush",
    "Straight On",
    "Carnage",
    "Fourfold Flashstrike",
    "Homerun",
    "Beatdown",
    "Grand Slam",
    "Foul Ball",
    "Savage Tornado",
    "Brutual Beatdown",
    "Strength Difference",
    "Death Blow",
    "Quick Slice",
    "Atmos Cleave",
    "Pinpoint Cut",
    "Split Second Counter",
    "Sunset",
    "Solar Cleave",
    "Sunrise",
    "Atomic Slash",
    "Crushing Pull",
    "Windstorm Fury",
    "Stone Coffin",
    "Expulsive Push",
    "Cosmic Strike",
    "Psychic Ricochet",
    "Terrible Tornado",
    "Sky Snatcher",
    "Bullet Barrage",
    "Vanishing Kick",
    "Whirlwind Drop",
    "Head First",
    "Grand Fissure",
    "Twin Fangs",
    "Earth Splitting Strike",
    "Last Breath"
}

-- Improved notification system
local activeNotifications = {}
local maxNotifications = 3
local notificationQueue = {}

local function cleanupNotifications()
    while #activeNotifications >= maxNotifications do
        local oldest = table.remove(activeNotifications, 1)
        if oldest and oldest.Parent then
            TweenService:Create(oldest, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(1, 10, oldest.Position.Y.Scale, 0)
            }):Play()
            spawn(function()
                wait(0.5)
                if oldest and oldest.Parent then
                    oldest:Destroy()
                end
            end)
        end
    end
end

local function processNotificationQueue()
    if #notificationQueue > 0 and #activeNotifications < maxNotifications then
        local notifData = table.remove(notificationQueue, 1)
        notify(notifData.text, notifData.sec)
    end
end

-- Modern notification function
local function notify(text, sec)
    sec = sec or 2.5
    if #activeNotifications >= maxNotifications then
        table.insert(notificationQueue, {text = text, sec = sec})
        return
    end

    local frame = Instance.new("Frame")
    frame.Name = "LuexNotification"
    frame.Size = UDim2.new(0, 260, 0, 40)
    frame.Position = UDim2.new(1, 10, 0.02, 0)
    frame.AnchorPoint = Vector2.new(1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(18, 8, 8)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.ZIndex = 100
    frame.Parent = UI.Screen

    local border = Instance.new("UIStroke", frame)
    border.Color = Color3.fromRGB(200, 30, 30)
    border.Thickness = 2
    border.Transparency = 0.3

    local innerShadow = Instance.new("Frame", frame)
    innerShadow.Size = UDim2.new(1, -4, 1, -4)
    innerShadow.Position = UDim2.new(0, 2, 0, 2)
    innerShadow.BackgroundTransparency = 1
    innerShadow.ZIndex = frame.ZIndex + 1
    local innerStroke = Instance.new("UIStroke", innerShadow)
    innerStroke.Color = Color3.fromRGB(80, 0, 0)
    innerStroke.Thickness = 1
    innerStroke.Transparency = 0.7

    local lab = Instance.new("TextLabel", frame)
    lab.Size = UDim2.new(1, -12, 1, 0)
    lab.Position = UDim2.new(0, 6, 0, 0)
    lab.BackgroundTransparency = 1
    lab.Text = text
    lab.TextXAlignment = Enum.TextXAlignment.Left
    lab.TextColor3 = Color3.fromRGB(255, 200, 200)
    lab.Font = Enum.Font.GothamBold
    lab.TextSize = 14
    lab.TextStrokeTransparency = 0.8
    lab.TextStrokeColor3 = Color3.fromRGB(100, 0, 0)
    lab.ZIndex = frame.ZIndex + 1

    table.insert(activeNotifications, frame)
    cleanupNotifications()

    for i, notif in ipairs(activeNotifications) do
        local targetY = 0.02 + (i - 1) * 0.06
        TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(1, -10, targetY, 0)
        }):Play()
    end

    TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -10, 0.02 + (#activeNotifications - 1) * 0.06, 0)
    }):Play()

    spawn(function()
        wait(sec)
        for i, notif in ipairs(activeNotifications) do
            if notif == frame then
                table.remove(activeNotifications, i)
                break
            end
        end

        TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 10, frame.Position.Y.Scale, 0)
        }):Play()
        wait(0.5)
        processNotificationQueue()

        for i, notif in ipairs(activeNotifications) do
            local targetY = 0.02 + (i - 1) * 0.06
            TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(1, -10, targetY, 0)
            }):Play()
        end
        frame:Destroy()
    end)
end

-- Highlight target
local function makeHighlight(player)
    pcall(function()
        if highlightGui and highlightGui.Parent then highlightGui:Destroy() end
        if not player or not player.Character then return end
        local root = player.Character:FindFirstChild("HumanoidRootPart") or player.Character:FindFirstChildWhichIsA("BasePart")
        if not root then return end

        local bg = Instance.new("BillboardGui")
        bg.Name = "LuexTargetHighlight"
        bg.Parent = player.Character
        bg.Adornee = root
        bg.Size = UDim2.new(0, 140, 0, 48)
        bg.AlwaysOnTop = true

        local label = Instance.new("TextLabel", bg)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 0.25
        label.BackgroundColor3 = Color3.fromRGB(40, 5, 5)
        label.Text = "TARGET: " .. player.Name
        label.TextColor3 = Color3.fromRGB(255, 200, 200)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14
        label.TextStrokeTransparency = 0.6
        highlightGui = bg
    end)
end

local function clearHighlight()
    pcall(function()
        if highlightGui and highlightGui.Parent then highlightGui:Destroy() end
        highlightGui = nil
    end)
end

-- Choose random player (excluding current target)
local function chooseRandom()
    local pls = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and
            p ~= currentTarget and
            p.Character and
            p.Character:FindFirstChild("Humanoid") and
            p.Character:FindFirstChild("Humanoid").Health > 0 then
            table.insert(pls, p)
        end
    end
    if #pls == 0 then return nil end
    return pls[math.random(1, #pls)]
end

-- Get ping function
local function getPing()
    local ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
    return math.clamp(ping, 0.05, 0.5)
end

-- Enhanced prediction using velocity and ping
local function predictTargetPosition(targetRoot)
    if not predictOn or not targetRoot then return targetRoot.Position end
    local ping = getPing()
    local extraOffset = 0.08

    if targetRoot.Velocity.Magnitude > 1 then
        return targetRoot.Position + (targetRoot.Velocity * (ping + extraOffset))
    end

    return targetRoot.Position
end

-- SINGLE-STEP teleport function
local function teleportBehindTargetStep()
    if not currentTarget or not currentTarget.Character then return end
    local targetRoot = currentTarget.Character:FindFirstChild("HumanoidRootPart")
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not targetRoot or not hrp then return end

    local targetPos = predictTargetPosition(targetRoot)
    local moveDir = targetRoot.Velocity.Magnitude > 1 and targetRoot.Velocity.Unit or targetRoot.CFrame.LookVector
    local newPos = targetPos - (moveDir * 3.5) + (targetRoot.CFrame.RightVector * 1.2)
    hrp.CFrame = CFrame.lookAt(newPos, targetPos)
end

-- SINGLE-STEP face target function
local function faceTargetStep()
    if not currentTarget or not currentTarget.Character then return end
    local targetRoot = currentTarget.Character:FindFirstChild("HumanoidRootPart")
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not targetRoot or not hrp then return end
    hrp.CFrame = CFrame.lookAt(hrp.Position, predictTargetPosition(targetRoot))
end

-- Enhanced spam tools attack
local function spamAttack()
    if not currentTarget or not LocalPlayer.Character then return end
    local remote = LocalPlayer.Character:FindFirstChild("Communicate")
    if not remote then return end

    remote:FireServer({
        MoveDirection = Vector3.zero,
        Goal = "KeyPress",
        Key = Enum.KeyCode.G
    })

    local args = {
        {
            Goal = "KeyRelease",
            Key = Enum.KeyCode.Q
        }
    }
    remote:FireServer(unpack(args))

    for i = 1, 3 do
        remote:FireServer({
            Goal = "LeftClick",
            Mobile = true
        })
    end

    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, toolName in ipairs(toolList) do
            local tool = backpack:FindFirstChild(toolName)
            if tool then
                remote:FireServer({
                    Tool = tool,
                    Goal = "Console Move"
                })
            end
        end
    end
end

-- Auto Safe Zone Functions
local function createSafePlatform()
    if not hasPremium then return end
    if safePlatform then return end

    local character = LocalPlayer.Character
    if not character then return end
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end

    wasAutoKillOn = autoOn
    autoOn = false
    autoSelectedOn = false
    UI.AutoBtn.Text = "Toggle Auto Kill: OFF"
    UI.AutoSelectedBtn.Text = "Auto Kill Selected: OFF"

    safePlatform = Instance.new("Part")
    safePlatform.Name = "LuexSafePlatform"
    safePlatform.Size = Vector3.new(1000, 1, 1000)
    safePlatform.Position = humanoidRootPart.Position + Vector3.new(0, 50, 0)
    safePlatform.Anchored = true
    safePlatform.CanCollide = true
    safePlatform.Transparency = 0.5
    safePlatform.Color = Color3.fromRGB(255, 0, 0)
    safePlatform.Parent = workspace

    humanoidRootPart.CFrame = safePlatform.CFrame + Vector3.new(0, 5, 0)
    notify("Safe Zone activated! Teleported to safety.", 3)
end

local function removeSafePlatform()
    if safePlatform then
        safePlatform:Destroy()
        safePlatform = nil

        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid and (humanoid.Health / humanoid.MaxHealth) > 0.8 then
                autoOn = wasAutoKillOn
                UI.AutoBtn.Text = "Toggle Auto Kill: " .. (autoOn and "ON" or "OFF")
                notify("Safe Zone deactivated! Auto Kill " .. (autoOn and "enabled" or "disabled") .. ".", 3)
            else
                notify("Safe Zone deactivated! Health too low for Auto Kill.", 3)
            end
        end
    end
end

-- Auto Server Hop Functions
local PlaceId = game.PlaceId

local function getServers(minPlayers)
    local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local servers = {}
    local cursor

    repeat
        local queryUrl = url .. (cursor and "&cursor=" .. cursor or "")
        local response = game:HttpGet(queryUrl)
        local data = HttpService:JSONDecode(response)

        for _, server in ipairs(data.data) do
            if server.playing >= minPlayers and server.id ~= game.JobId then
                table.insert(servers, server)
            end
        end
        cursor = data.nextPageCursor
    until not cursor

    return servers
end

local function hopServer()
    local servers = getServers(10)
    if #servers > 0 then
        local picked = servers[math.random(1, #servers)]
        TeleportService:TeleportToPlaceInstance(PlaceId, picked.id, LocalPlayer)
    else
        warn("No suitable servers found (>10 players).")
    end
end

-- Player Selection Functions
local function createPlayerButton(player, yPosition)
    local button = Instance.new("TextButton")
    button.Name = player.Name
    button.Size = UDim2.new(1, -10, 0, 40)
    button.Position = UDim2.new(0, 5, 0, yPosition)
    button.BackgroundColor3 = player == currentTarget and Color3.fromRGB(60, 10, 10) or Color3.fromRGB(30, 8, 8)
    button.BorderSizePixel = 0
    button.Text = player.Name
    button.Font = Enum.Font.Gotham
    button.TextSize = 14
    button.TextColor3 = Color3.fromRGB(240, 240, 240)
    button.AutoButtonColor = false
    button.Parent = UI.PlayerList
    
    -- Status indicator
    local statusIndicator = Instance.new("Frame", button)
    statusIndicator.Size = UDim2.new(0, 8, 0, 8)
    statusIndicator.Position = UDim2.new(1, -14, 0.5, -4)
    statusIndicator.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    statusIndicator.BorderSizePixel = 0
    
    -- Update status based on player health
    if player.Character then
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            if humanoid.Health <= 0 then
                statusIndicator.BackgroundColor3 = Color3.fromRGB(200, 30, 30)  -- Dead
            else
                statusIndicator.BackgroundColor3 = Color3.fromRGB(30, 200, 30)  -- Alive
            end
        end
    end
    
    -- Hover effect
    button.MouseEnter:Connect(function()
        if player ~= currentTarget then
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 12, 12)}):Play()
        end
    end)
    
    button.MouseLeave:Connect(function()
        if player ~= currentTarget then
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 8, 8)}):Play()
        end
    end)
    
    -- Select player on click
    button.MouseButton1Click:Connect(function()
        if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("Humanoid").Health > 0 then
            currentTarget = player
            notify("Selected: " .. player.Name, 2)
            makeHighlight(currentTarget)
            refreshPlayerList()
            
            if autoOn or autoSelectedOn then
                teleportBehindTargetStep()
                faceTargetStep()
                spamAttack()
            end
        else
            notify(player.Name .. " is not a valid target", 2)
        end
    end)
    
    return button
end

local function refreshPlayerList()
    -- Clear existing player list
    for _, child in ipairs(UI.PlayerList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    -- Add players to list
    local yPosition = 0
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            createPlayerButton(player, yPosition)
            yPosition = yPosition + 45
        end
    end
    
    -- Update canvas size
    UI.PlayerList.CanvasSize = UDim2.new(0, 0, 0, yPosition)
end

-- Auto Refresh Player List
spawn(function()
    while true do
        if autoRefreshOn then
            refreshPlayerList()
        end
        wait(5)  -- Refresh every 5 seconds
    end
end)

-- Optimized auto-kill loop
spawn(function()
    while true do
        RunService.Heartbeat:Wait()

        -- Auto Server Hop Logic
        if serverHopOn then
            if #Players:GetPlayers() < 3 then
                notify("Server too empty, hopping...", 2)
                hopServer()
            end
        end

        -- Enhanced Auto Safe Zone Logic
        if safeZoneOn and hasPremium then
            local character = LocalPlayer.Character
            if character then
                local humanoid = character:FindFirstChild("Humanoid")
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                if humanoid and humanoid.Health > 0 and humanoidRootPart then
                    local healthPercent = (humanoid.Health / humanoid.MaxHealth) * 100
                    if healthPercent < 35 and not safePlatform then
                        createSafePlatform()
                    elseif healthPercent > 80 and safePlatform then
                        removeSafePlatform()
                    end

                    if safePlatform and (humanoidRootPart.Position - safePlatform.Position).Magnitude > 10 then
                        humanoidRootPart.CFrame = safePlatform.CFrame + Vector3.new(0, 5, 0)
                    end
                end
            end
        end

        -- Auto Kill Logic (Random Targets)
        if autoOn and not safePlatform then
            if not currentTarget or not currentTarget.Character or not currentTarget.Character:FindFirstChild("Humanoid") or currentTarget.Character:FindFirstChild("Humanoid").Health <= 0 then
                currentTarget = chooseRandom()
                if currentTarget then
                    notify("Selected: " .. currentTarget.Name, 1.8)
                    makeHighlight(currentTarget)
                    lastNoTargetNotify = 0
                else
                    if tick() - lastNoTargetNotify > noTargetNotifyCooldown then
                        notify("No valid targets found.", 1.8)
                        lastNoTargetNotify = tick()
                    end
                    clearHighlight()
                end
            else
                if tick() - lastAttack > attackRate then
                    teleportBehindTargetStep()
                    spamAttack()
                    lastAttack = tick()
                end

                if tick() - lastFace > faceRate then
                    faceTargetStep()
                    lastFace = tick()
                end
            end
        end

        -- Auto Kill Selected Logic
        if autoSelectedOn and not safePlatform and currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("Humanoid") and currentTarget.Character:FindFirstChild("Humanoid").Health > 0 then
            if tick() - lastAttack > attackRate then
                teleportBehindTargetStep()
                spamAttack()
                lastAttack = tick()
            end

            if tick() - lastFace > faceRate then
                faceTargetStep()
                lastFace = tick()
            end
        end
    end
end)

-- Auto Kill button
UI.AutoBtn.MouseButton1Click:Connect(function()
    if safePlatform then
        notify("Cannot enable Auto Kill while in Safe Zone!", 2)
        return
    end

    autoOn = not autoOn
    UI.AutoBtn.Text = "Toggle Auto Kill: " .. (autoOn and "ON" or "OFF")

    if not getgenv().LuexStates then getgenv().LuexStates = {} end
    getgenv().LuexStates.AutoOn = autoOn

    if autoOn then
        notify("Auto Kill enabled. Selecting target...", 2)
        currentTarget = chooseRandom()
        if currentTarget then
            notify("Target: " .. currentTarget.Name, 2)
            makeHighlight(currentTarget)
        else
            notify("No valid targets found", 2)
        end
    else
        notify("Auto Kill disabled", 1.5)
        clearHighlight()
    end
end)

-- Auto Kill Selected button
UI.AutoSelectedBtn.MouseButton1Click:Connect(function()
    if safePlatform then
        notify("Cannot enable Auto Kill Selected while in Safe Zone!", 2)
        return
    end

    if not currentTarget then
        notify("Please select a player first!", 2)
        return
    end

    autoSelectedOn = not autoSelectedOn
    UI.AutoSelectedBtn.Text = "Auto Kill Selected: " .. (autoSelectedOn and "ON" or "OFF")

    if not getgenv().LuexStates then getgenv().LuexStates = {} end
    getgenv().LuexStates.AutoSelectedOn = autoSelectedOn

    if autoSelectedOn then
        notify("Auto Kill Selected enabled for: " .. currentTarget.Name, 2)
        makeHighlight(currentTarget)
    else
        notify("Auto Kill Selected disabled", 1.5)
    end
end)

-- Change Player button
UI.ChangePlayerBtn.MouseButton1Click:Connect(function()
    local currentTargetName = currentTarget and currentTarget.Name or nil
    local players = {}

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and
            player.Character and
            player.Character:FindFirstChild("Humanoid") and
            player.Character:FindFirstChild("Humanoid").Health > 0 and
            player.Name ~= currentTargetName then
            table.insert(players, player)
        end
    end

    if #players > 0 then
        currentTarget = players[math.random(1, #players)]
        notify("Changed target to: " .. currentTarget.Name, 2)
        makeHighlight(currentTarget)
        refreshPlayerList()

        if autoOn or autoSelectedOn then
            teleportBehindTargetStep()
            faceTargetStep()
            spamAttack()
        end
    else
        notify("No other valid targets found", 2)
    end
end)

-- Predict Direction button
UI.PredictBtn.MouseButton1Click:Connect(function()
    if not hasPremium then
        notify("Predict Direction requires premium. Set: getgenv().LuexKey = 'luexprenium'", 3)
        return
    end

    predictOn = not predictOn
    UI.PredictBtn.Text = "Predict Direction: " .. (predictOn and "ON" or "OFF")

    if not getgenv().LuexStates then getgenv().LuexStates = {} end
    getgenv().LuexStates.PredictOn = predictOn

    if predictOn then
        notify("Direction Prediction enabled (Beta)", 2)
    else
        notify("Direction Prediction disabled", 1.5)
    end
end)

-- Server Hop button
UI.ServerHopBtn.MouseButton1Click:Connect(function()
    serverHopOn = not serverHopOn
    UI.ServerHopBtn.Text = "Auto Server Hop: " .. (serverHopOn and "ON" or "OFF")

    if not getgenv().LuexStates then getgenv().LuexStates = {} end
    getgenv().LuexStates.ServerHopOn = serverHopOn

    if serverHopOn then
        notify("Auto Server Hop enabled", 2)
    else
        notify("Auto Server Hop disabled", 1.5)
    end
end)

-- Auto Safe Zone button
UI.SafeZoneBtn.MouseButton1Click:Connect(function()
    if not hasPremium then
        notify("Auto Safe Zone requires premium. Set: getgenv().LuexKey = 'luexprenium'", 3)
        return
    end

    safeZoneOn = not safeZoneOn
    UI.SafeZoneBtn.Text = "Auto Safe Zone: " .. (safeZoneOn and "ON" or "OFF")

    if not getgenv().LuexStates then getgenv().LuexStates = {} end
    getgenv().LuexStates.SafeZoneOn = safeZoneOn

    if safeZoneOn then
        notify("Auto Safe Zone enabled", 2)
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid and (humanoid.Health / humanoid.MaxHealth) < 0.35 then
                createSafePlatform()
            end
        end
    else
        notify("Auto Safe Zone disabled", 1.5)
        if safePlatform then
            removeSafePlatform()
        end
    end
end)

-- Refresh Players button
UI.RefreshBtn.MouseButton1Click:Connect(function()
    refreshPlayerList()
    notify("Player list refreshed", 1.5)
end)

-- Auto Refresh Toggle button
UI.AutoRefreshToggle.MouseButton1Click:Connect(function()
    autoRefreshOn = not autoRefreshOn
    UI.AutoRefreshToggle.Text = "Auto Refresh: " .. (autoRefreshOn and "ON" or "OFF")
    
    if not getgenv().LuexStates then getgenv().LuexStates = {} end
    getgenv().LuexStates.AutoRefreshOn = autoRefreshOn
    
    if autoRefreshOn then
        notify("Auto Refresh enabled", 1.5)
        refreshPlayerList()
    else
        notify("Auto Refresh disabled", 1.5)
    end
end)

-- Animate crack lines
spawn(function()
    while true do
        for i, child in ipairs(UI.Crack:GetChildren()) do
            if child:IsA("Frame") then
                TweenService:Create(child, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, -1, true), {BackgroundTransparency = 0.6}):Play()
            end
        end
        wait(1.2)
    end
end)

-- Pulsing logo glow
spawn(function()
    while true do
        TweenService:Create(UI.Glow, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.75}):Play()
        wait(1.2)
        TweenService:Create(UI.Glow, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.95}):Play()
        wait(1.2)
    end
end)

-- Initial player list refresh
refreshPlayerList()

-- Cleanup
Players.PlayerRemoving:Connect(function(p)
    if currentTarget == p then
        currentTarget = nil
        notify("Target left the game", 2)
        clearHighlight()

        if autoOn then
            currentTarget = chooseRandom()
            if currentTarget then
                notify("New target: " .. currentTarget.Name, 2)
                makeHighlight(currentTarget)
            end
        end
        if autoSelectedOn then
            autoSelectedOn = false
            UI.AutoSelectedBtn.Text = "Auto Kill Selected: OFF"
            notify("Auto Kill Selected disabled (target left)", 2)
        end
    end
    refreshPlayerList()
end)

Players.PlayerAdded:Connect(function(p)
    wait(2) -- Wait for player to load
    refreshPlayerList()
end)

print("Luex Enhanced Combat System v1.9 with Player Selection, Auto Kill Selected, and Auto Refresh loaded")
