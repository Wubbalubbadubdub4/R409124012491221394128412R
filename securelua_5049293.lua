-- RGH BLADE BALL ULTIMATE (PING COMPENSATED + VISUALIZER EDITION)
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Debris = game:GetService("Debris")
local Stats = game:GetService("Stats")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")

-- --- CONFIGURATION ---
local DEFAULT_RANGE = 18 -- Slightly increased for safety
local DEFAULT_PAD = 10
local REACTION_TIME = 0.15
local DODGE_POWER = 80
local DODGE_DURATION = 0.3
local PARRY_KEY = Enum.KeyCode.F
local WALK_DISTANCE = 25 

-- --- VARIABLES ---
local isDefaultSettings = true
local isParryEnabled = false
local isDodgeEnabled = false
local isWalkEnabled = false
local isVisualizerEnabled = false -- New Feature

local currentRange = DEFAULT_RANGE
local currentPad = DEFAULT_PAD

local lastParryTick = 0
local lastDodgeTick = 0
local lastWalkTick = 0

local mainLoop = nil 
local visualizerPart = nil -- Stores the visualizer ring

-- --- HELPER FUNCTIONS ---

local function GetPing()
    -- Returns ping in seconds (e.g., 100ms = 0.1s)
    return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
end

local function UpdateVisualizer()
    if not isVisualizerEnabled or not root then
        if visualizerPart then visualizerPart:Destroy() visualizerPart = nil end
        return
    end

    if not visualizerPart then
        visualizerPart = Instance.new("Part")
        visualizerPart.Name = "ParryRangeVisualizer"
        visualizerPart.Shape = Enum.PartType.Cylinder
        visualizerPart.Material = Enum.Material.Neon
        visualizerPart.Color = Color3.fromRGB(130, 0, 255)
        visualizerPart.Transparency = 0.85
        visualizerPart.Anchored = true
        visualizerPart.CanCollide = false
        visualizerPart.CastShadow = false
        visualizerPart.Parent = workspace
    end

    local size = currentRange * 2
    visualizerPart.Size = Vector3.new(0.5, size, size)
    visualizerPart.CFrame = root.CFrame * CFrame.Angles(0, 0, math.rad(90))
end

-- --- UI CREATION ---
if player.PlayerGui:FindFirstChild("BladeBall_Fixed_Hub_Final") then
    player.PlayerGui.BladeBall_Fixed_Hub_Final:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BladeBall_Fixed_Hub_Final"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 280, 0, 480) -- Increased Height
mainFrame.Position = UDim2.new(0.5, -140, 0.4, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true 
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = mainFrame

local border = Instance.new("UIStroke")
border.Color = Color3.fromRGB(130, 0, 255)
border.Thickness = 2.5
border.Transparency = 0.1
border.Parent = mainFrame

-- Top Bar
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 45)
topBar.BackgroundTransparency = 1
topBar.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Text = "BLADE BALL"
title.Size = UDim2.new(1, -40, 0, 25)
title.Position = UDim2.new(0, 15, 0, 5)
title.TextColor3 = Color3.fromRGB(130, 0, 255) 
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBlack
title.TextSize = 19
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

local subTitle = Instance.new("TextLabel")
subTitle.Text = "PING COMPENSATED EDITION"
subTitle.Size = UDim2.new(1, 0, 0, 15)
subTitle.Position = UDim2.new(0, 15, 0, 28)
subTitle.TextColor3 = Color3.fromRGB(200, 200, 255) 
subTitle.BackgroundTransparency = 1
subTitle.Font = Enum.Font.GothamBold
subTitle.TextSize = 10
subTitle.TextXAlignment = Enum.TextXAlignment.Left
subTitle.Parent = mainFrame

-- --- CLOSE BUTTON ---
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "X"
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
closeBtn.BackgroundTransparency = 1
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 8)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 22
closeBtn.Parent = topBar

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
    if visualizerPart then visualizerPart:Destroy() end
    if mainLoop then
        mainLoop:Disconnect()
        mainLoop = nil
    end
end)

-- Settings Container
local settingsFrame = Instance.new("Frame")
settingsFrame.Size = UDim2.new(0, 250, 0, 140)
settingsFrame.Position = UDim2.new(0.5, -125, 0, 60)
settingsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
settingsFrame.BorderSizePixel = 0
settingsFrame.Parent = mainFrame

local settingsCorner = Instance.new("UICorner")
settingsCorner.CornerRadius = UDim.new(0, 10)
settingsCorner.Parent = settingsFrame

-- Input Creator
local function CreateInput(labelText, yPos, defaultVal, callback)
    local lbl = Instance.new("TextLabel")
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(180, 180, 180)
    lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0, 15, 0, yPos)
    lbl.Size = UDim2.new(0, 100, 0, 25)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = settingsFrame

    local box = Instance.new("TextBox")
    box.Text = tostring(defaultVal)
    box.TextColor3 = Color3.fromRGB(100, 100, 100)
    box.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
    box.Position = UDim2.new(1, -70, 0, yPos)
    box.Size = UDim2.new(0, 50, 0, 25)
    box.Font = Enum.Font.GothamBold
    box.TextEditable = false
    box.Parent = settingsFrame

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 6)
    boxCorner.Parent = box

    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(50, 50, 50)
    s.Thickness = 1
    s.Parent = box
    
    box.FocusLost:Connect(function()
        if not isDefaultSettings then
            local num = tonumber(box.Text)
            if num then callback(num) else box.Text = tostring(defaultVal) end
        end
    end)
    return box
end

local rangeBox = CreateInput("Parry Range:", 55, DEFAULT_RANGE, function(val) currentRange = val end)
local padBox = CreateInput("Hitbox Pad:", 95, DEFAULT_PAD, function(val) currentPad = val end)

-- Mode Switch
local defSwitchBtn = Instance.new("TextButton")
defSwitchBtn.Size = UDim2.new(1, -20, 0, 35)
defSwitchBtn.Position = UDim2.new(0, 10, 0, 10)
defSwitchBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 120) 
defSwitchBtn.Text = "MODE: DEFAULT SETTINGS"
defSwitchBtn.TextColor3 = Color3.fromRGB(10, 10, 10)
defSwitchBtn.Font = Enum.Font.GothamBold
defSwitchBtn.TextSize = 12
defSwitchBtn.Parent = settingsFrame

local switchCorner = Instance.new("UICorner")
switchCorner.CornerRadius = UDim.new(0, 6)
switchCorner.Parent = defSwitchBtn

defSwitchBtn.MouseButton1Click:Connect(function()
    isDefaultSettings = not isDefaultSettings
    if isDefaultSettings then
        defSwitchBtn.Text = "MODE: DEFAULT SETTINGS"
        defSwitchBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
        defSwitchBtn.TextColor3 = Color3.fromRGB(10, 10, 10)
        currentRange = DEFAULT_RANGE
        currentPad = DEFAULT_PAD
        rangeBox.Text = tostring(DEFAULT_RANGE)
        rangeBox.TextEditable = false
        padBox.Text = tostring(DEFAULT_PAD)
        padBox.TextEditable = false
    else
        defSwitchBtn.Text = "MODE: CUSTOM SETTINGS"
        defSwitchBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        defSwitchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        rangeBox.TextEditable = true
        padBox.TextEditable = true
    end
end)

-- Main Toggle Buttons
local function CreateToggleButton(btnText, yPos, color, callback)
    local btn = Instance.new("TextButton")
    btn.Text = btnText .. " [OFF]"
    btn.Size = UDim2.new(0, 250, 0, 45)
    btn.Position = UDim2.new(0.5, -125, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    btn.TextColor3 = Color3.fromRGB(255, 80, 80)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Parent = mainFrame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60, 60, 70)
    stroke.Thickness = 1.5
    stroke.Parent = btn

    btn.MouseButton1Click:Connect(function()
        local newState = callback()
        if newState then
            btn.Text = btnText .. " [ACTIVE]"
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.BackgroundColor3 = color
            stroke.Color = color
        else
            btn.Text = btnText .. " [OFF]"
            btn.TextColor3 = Color3.fromRGB(255, 80, 80)
            btn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
            stroke.Color = Color3.fromRGB(60, 60, 70)
        end
    end)
    return btn
end

CreateToggleButton("AUTO-PARRY", 210, Color3.fromRGB(0, 255, 120), function()
    isParryEnabled = not isParryEnabled
    return isParryEnabled
end)

CreateToggleButton("AUTO-DODGE", 265, Color3.fromRGB(0, 150, 255), function()
    isDodgeEnabled = not isDodgeEnabled
    return isDodgeEnabled
end)

CreateToggleButton("AUTO-WALK", 320, Color3.fromRGB(255, 150, 0), function()
    isWalkEnabled = not isWalkEnabled
    return isWalkEnabled
end)

CreateToggleButton("SHOW VISUALIZER", 375, Color3.fromRGB(200, 0, 255), function()
    isVisualizerEnabled = not isVisualizerEnabled
    if not isVisualizerEnabled and visualizerPart then 
        visualizerPart:Destroy() 
        visualizerPart = nil 
    end
    return isVisualizerEnabled
end)

-- --- LOGIC FUNCTIONS ---

local function PerformSafeDodge(ballPart)
    if not root then return end
    if tick() - lastDodgeTick < 0.5 then return end 
    lastDodgeTick = tick()

    local directionToBall = (ballPart.Position - root.Position).Unit
    local rightVector = directionToBall:Cross(Vector3.new(0, 1, 0))
    local leftVector = -rightVector 
    
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {player.Character, workspace:FindFirstChild("Balls")}
    rayParams.FilterType = Enum.RaycastFilterType.Exclude

    local canGoRight = not workspace:Raycast(root.Position, rightVector * 15, rayParams)
    local canGoLeft = not workspace:Raycast(root.Position, leftVector * 15, rayParams)
    
    local chosenDirection = nil

    if canGoRight then
        chosenDirection = rightVector
    elseif canGoLeft then
        chosenDirection = leftVector
    else
        chosenDirection = -directionToBall 
    end
    
    if chosenDirection then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "VelocityDodge"
        bv.Velocity = chosenDirection * DODGE_POWER 
        bv.MaxForce = Vector3.new(100000, 0, 100000)
        bv.P = 1250
        bv.Parent = root
        Debris:AddItem(bv, DODGE_DURATION)
    end
end

local function PerformAutoWalk()
    if tick() - lastWalkTick < 0.05 then return end
    lastWalkTick = tick()

    if (tick() - lastDodgeTick < DODGE_DURATION) or not root then return end

    local threatPos = nil
    local shortestDist = 1000

    -- Scan for nearest player (threat)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (p.Character.HumanoidRootPart.Position - root.Position).Magnitude
            if dist < shortestDist then
                shortestDist = dist
                threatPos = p.Character.HumanoidRootPart.Position
            end
        end
    end

    if threatPos and shortestDist < 40 then 
        local awayDir = (root.Position - threatPos).Unit
        local targetPos = root.Position + (awayDir * WALK_DISTANCE)
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum:MoveTo(targetPos) end
    end
end

-- --- MAIN LOGIC ---

mainLoop = RunService.PostSimulation:Connect(function()
    -- Character Refresh Safety
    if not char or not char.Parent then
        char = player.Character
        if char then root = char:FindFirstChild("HumanoidRootPart") end
        return
    end

    if isVisualizerEnabled then UpdateVisualizer() end
    if isWalkEnabled then PerformAutoWalk() end

    if not isParryEnabled and not isDodgeEnabled then return end

    local ballsFolder = workspace:FindFirstChild("Balls")
    if not ballsFolder then return end

    -- Optimize: Only check the closest ball or the one tagged for us
    local criticalBall = nil
    local closestDist = 99999

    for _, part in pairs(ballsFolder:GetChildren()) do
        if part:IsA("BasePart") then
            local dist = (part.Position - root.Position).Magnitude
            
            -- Prioritize ball tagged for LocalPlayer
            local targetAttr = part:GetAttribute("target")
            if targetAttr == player.Name then
                criticalBall = part
                break -- Found our ball, stop searching
            end

            -- Fallback: Find closest ball moving towards us
            if dist < closestDist then
                closestDist = dist
                criticalBall = part
            end
        end
    end

    if criticalBall then
        local velocity = criticalBall.AssemblyLinearVelocity
        local relativePos = criticalBall.Position - root.Position
        local speedTowardsMe = -relativePos.Unit:Dot(velocity)

        if speedTowardsMe > 0 then
            -- PING COMPENSATION
            local ping = GetPing()
            local pingOffset = speedTowardsMe * ping -- Distance traveled during lag
            
            -- Adaptive Math
            local speedFactor = math.clamp(speedTowardsMe / 200, 0, 1) 
            local hitboxMult = 1.5 + speedFactor 
            local rawRadius = math.max(criticalBall.Size.X, criticalBall.Size.Z) / 2
            
            -- Calculate Real Distance taking Lag into account
            local effectiveDistance = (relativePos.Magnitude - rawRadius - currentPad) - pingOffset
            local timeToImpact = effectiveDistance / math.max(1, speedTowardsMe)
            
            -- Dynamic Reaction Threshold
            local reactionThreshold = REACTION_TIME
            if speedTowardsMe > 100 then
                reactionThreshold = math.max(0.12, REACTION_TIME + (speedTowardsMe / 4000))
            end

            -- PARRY ACTION
            if isParryEnabled and effectiveDistance <= currentRange and timeToImpact <= reactionThreshold then
                if tick() - lastParryTick > 0.1 then
                    VirtualInputManager:SendKeyEvent(true, PARRY_KEY, false, game)
                    VirtualInputManager:SendKeyEvent(false, PARRY_KEY, false, game)
                    lastParryTick = tick()
                end
            end

            -- DODGE ACTION
            if isDodgeEnabled then
                -- Dodge slightly earlier than parry
                if timeToImpact <= (reactionThreshold + 0.2) and effectiveDistance > 8 then
                    PerformSafeDodge(criticalBall)
                end
            end
        end
    end
end)
