-- RGH BLADE BALL ULTIMATE (FIXED V14 - THE ABSOLUTE SOLVER)
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")

-- --- CONFIGURATION ---
local DEFAULT_RANGE = 12
local DEFAULT_PAD = 12 -- Increased slightly to handle "far hits" better
local REACTION_TIME = 0.15
local DODGE_POWER = 40 -- Low/Short Dash
local DODGE_DURATION = 0.15
local PARRY_KEY = Enum.KeyCode.F
local WALK_DISTANCE = 25 
local SAFETY_DISTANCE = 20 -- Keep a bit more distance for safety

-- --- VARIABLES ---
local isDefaultSettings = true
local isParryEnabled = false
local isDodgeEnabled = false
local isWalkEnabled = false

local currentRange = DEFAULT_RANGE
local currentPad = DEFAULT_PAD

local lastParryTick = 0
local lastDodgeTick = 0

local mainLoop = nil 

-- --- UI CREATION ---
if player.PlayerGui:FindFirstChild("BladeBall_Absolute_Hub") then
    player.PlayerGui.BladeBall_Absolute_Hub:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BladeBall_Absolute_Hub"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 280, 0, 420)
mainFrame.Position = UDim2.new(0.5, -140, 0.4, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true 
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = mainFrame

local border = Instance.new("UIStroke")
border.Color = Color3.fromRGB(255, 215, 0) -- Gold (Final Version)
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
title.TextColor3 = Color3.fromRGB(255, 215, 0) 
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBlack
title.TextSize = 19
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

local subTitle = Instance.new("TextLabel")
subTitle.Text = "ABSOLUTE SOLVER (INFINITE SCALE)"
subTitle.Size = UDim2.new(1, 0, 0, 15)
subTitle.Position = UDim2.new(0, 15, 0, 28)
subTitle.TextColor3 = Color3.fromRGB(255, 240, 180) 
subTitle.BackgroundTransparency = 1
subTitle.Font = Enum.Font.GothamBold
subTitle.TextSize = 9
subTitle.TextXAlignment = Enum.TextXAlignment.Left
subTitle.Parent = mainFrame

-- Close Button
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
    if mainLoop then mainLoop:Disconnect(); mainLoop = nil end
end)

-- Settings Container
local settingsFrame = Instance.new("Frame")
settingsFrame.Size = UDim2.new(0, 250, 0, 140)
settingsFrame.Position = UDim2.new(0.5, -125, 0, 60)
settingsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
settingsFrame.BorderSizePixel = 0
settingsFrame.Parent = mainFrame
Instance.new("UICorner", settingsFrame).CornerRadius = UDim.new(0, 10)

-- Inputs
local function CreateInput(labelText, yPos, defaultVal, callback)
    local lbl = Instance.new("TextLabel")
    lbl.Text = labelText; lbl.TextColor3 = Color3.fromRGB(180, 180, 180)
    lbl.BackgroundTransparency = 1; lbl.Position = UDim2.new(0, 15, 0, yPos)
    lbl.Size = UDim2.new(0, 100, 0, 25); lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = settingsFrame

    local box = Instance.new("TextBox")
    box.Text = tostring(defaultVal); box.TextColor3 = Color3.fromRGB(100, 100, 100)
    box.BackgroundColor3 = Color3.fromRGB(12, 12, 16); box.Position = UDim2.new(1, -70, 0, yPos)
    box.Size = UDim2.new(0, 50, 0, 25); box.Font = Enum.Font.GothamBold
    box.TextEditable = false; box.Parent = settingsFrame
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
    
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
defSwitchBtn.Size = UDim2.new(1, -20, 0, 35); defSwitchBtn.Position = UDim2.new(0, 10, 0, 10)
defSwitchBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 120); defSwitchBtn.Text = "MODE: DEFAULT SETTINGS"
defSwitchBtn.TextColor3 = Color3.fromRGB(10, 10, 10); defSwitchBtn.Font = Enum.Font.GothamBold
defSwitchBtn.TextSize = 12; defSwitchBtn.Parent = settingsFrame
Instance.new("UICorner", defSwitchBtn).CornerRadius = UDim.new(0, 6)

defSwitchBtn.MouseButton1Click:Connect(function()
    isDefaultSettings = not isDefaultSettings
    if isDefaultSettings then
        defSwitchBtn.Text = "MODE: DEFAULT SETTINGS"; defSwitchBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
        defSwitchBtn.TextColor3 = Color3.fromRGB(10, 10, 10); currentRange, currentPad = DEFAULT_RANGE, DEFAULT_PAD
        rangeBox.Text = tostring(DEFAULT_RANGE); rangeBox.TextEditable = false; rangeBox.TextColor3 = Color3.fromRGB(100, 100, 100)
        padBox.Text = tostring(DEFAULT_PAD); padBox.TextEditable = false; padBox.TextColor3 = Color3.fromRGB(100, 100, 100)
    else
        defSwitchBtn.Text = "MODE: CUSTOM SETTINGS"; defSwitchBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        defSwitchBtn.TextColor3 = Color3.fromRGB(255, 255, 255); rangeBox.TextEditable = true; rangeBox.TextColor3 = Color3.fromRGB(0, 255, 255)
        padBox.TextEditable = true; padBox.TextColor3 = Color3.fromRGB(255, 200, 0)
    end
end)

-- Main Buttons
local function CreateToggleButton(btnText, yPos, color, callback)
    local btn = Instance.new("TextButton")
    btn.Text = btnText .. " [OFF]"; btn.Size = UDim2.new(0, 250, 0, 45)
    btn.Position = UDim2.new(0.5, -125, 0, yPos); btn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    btn.TextColor3 = Color3.fromRGB(255, 80, 80); btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13; btn.Parent = mainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local s = Instance.new("UIStroke", btn); s.Color = Color3.fromRGB(60, 60, 70); s.Thickness = 1.5

    btn.MouseButton1Click:Connect(function()
        local newState = callback()
        btn.Text = newState and btnText .. " [ACTIVE]" or btnText .. " [OFF]"
        btn.TextColor3 = newState and Color3.new(1,1,1) or Color3.fromRGB(255, 80, 80)
        btn.BackgroundColor3 = newState and color or Color3.fromRGB(25, 25, 30)
        s.Color = newState and color or Color3.fromRGB(60, 60, 70)
    end)
    return btn
end

CreateToggleButton("AUTO-PARRY", 210, Color3.fromRGB(0, 255, 120), function() isParryEnabled = not isParryEnabled return isParryEnabled end)
CreateToggleButton("AUTO-DODGE", 265, Color3.fromRGB(0, 150, 255), function() isDodgeEnabled = not isDodgeEnabled return isDodgeEnabled end)
CreateToggleButton("AUTO-WALK", 320, Color3.fromRGB(255, 150, 0), function() isWalkEnabled = not isWalkEnabled return isWalkEnabled end)

-- --- LOGIC ---

local function PerformSafeDodge(ballPart)
    if not root then return end
    if tick() - lastDodgeTick < 0.2 then return end 
    lastDodgeTick = tick()

    local dVec = (ballPart.Position - root.Position).Unit
    local rV = dVec:Cross(Vector3.new(0, 1, 0))
    local lV = -rV
    
    local rayP = RaycastParams.new()
    rayP.FilterDescendantsInstances = {player.Character, workspace:FindFirstChild("Balls")}
    rayP.FilterType = Enum.RaycastFilterType.Exclude

    local canR = not workspace:Raycast(root.Position, rV * 10, rayP)
    local canL = not workspace:Raycast(root.Position, lV * 10, rayP)
    
    local bVel = ballPart.AssemblyLinearVelocity
    local curve = bVel.Unit:Dot(rV)
    local dir = nil

    if canR and canL then dir = (curve > 0.1 and lV) or (curve < -0.1 and rV) or (math.random()>0.5 and rV or lV)
    elseif canR then dir = rV
    elseif canL then dir = lV
    else dir = -dVec end
    
    if dir then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "LowDodge"
        bv.Velocity = dir * DODGE_POWER -- LOW POWER
        bv.MaxForce = Vector3.new(1e5, 0, 1e5) -- Grounded
        bv.P = 1250
        bv.Parent = root
        Debris:AddItem(bv, DODGE_DURATION) -- SHORT DURATION
    end
end

local function PerformAutoWalk()
    if not root or tick() - lastDodgeTick < DODGE_DURATION then return end
    local near, dist = nil, 20 -- Check 20 studs
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local d = (p.Character.HumanoidRootPart.Position - root.Position).Magnitude
            if d < dist then dist = d; near = p end
        end
    end
    if near then
        local tPos = root.Position + (root.Position - near.Character.HumanoidRootPart.Position).Unit * SAFETY_DISTANCE
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum:MoveTo(tPos) end
    end
end

-- --- MAIN LOGIC (ABSOLUTE SOLVER) ---

mainLoop = RunService.PostSimulation:Connect(function()
    if not char or not char.Parent then char = player.Character; root = char:FindFirstChild("HumanoidRootPart") return end
    if isWalkEnabled then PerformAutoWalk() end
    if not isParryEnabled and not isDodgeEnabled then return end

    local ballsFolder = workspace:FindFirstChild("Balls")
    if not ballsFolder then return end

    for _, part in pairs(ballsFolder:GetChildren()) do
        if part:IsA("BasePart") then
            local activeRange = currentRange
            local activePad = currentPad
            
            local centerDistance = (part.Position - root.Position).Magnitude
            local velocity = part.AssemblyLinearVelocity
            local relativePos = part.Position - root.Position
            local speedTowardsMe = -relativePos.Unit:Dot(velocity)

            if speedTowardsMe > 0 then
                -- [[ ABSOLUTE SOLVER MATH ]] --
                
                -- 1. Velocity Bias (Anticipation)
                -- We assume the ball is 5% faster than it looks to counter server lag.
                -- This bias grows slightly as speed increases.
                local bias = 1.05 + (speedTowardsMe / 2000)
                local perceivedSpeed = speedTowardsMe * bias
                
                -- 2. Infinite Hitbox Scaling (The Fix for "Far Hits")
                -- Base: 1.5x (Safe for start)
                -- Growth: Adds +1.0x for every 150 speed (Aggressive scaling)
                -- Example: 900 Speed = 1.5 + 6 = 7.5x Hitbox size!
                -- There is NO LIMIT (Unlimited), so 5000 speed = Huge hitbox.
                local infiniteFactor = speedTowardsMe / 165
                local hitboxMult = 1.5 + math.max(0, infiniteFactor)
                
                -- 3. Calculate "Real" Distance
                local rawRadius = math.max(part.Size.X, part.Size.Y, part.Size.Z) / 2
                local effectiveHitbox = rawRadius * hitboxMult
                local realDistance = centerDistance - effectiveHitbox - activePad 
                
                -- 4. Hybrid Triggers
                local timeToImpact = realDistance / perceivedSpeed
                
                -- TRIGGER: PARRY
                if isParryEnabled then
                    -- CLASH MODE (Close & Fast): Spam it
                    if centerDistance < 25 and speedTowardsMe > 60 then
                        if tick() - lastParryTick > 0.02 then 
                            VirtualInputManager:SendKeyEvent(true, PARRY_KEY, false, game)
                            VirtualInputManager:SendKeyEvent(false, PARRY_KEY, false, game)
                            lastParryTick = tick()
                        end
                    -- PRECISION MODE (Far): Use Math
                    elseif timeToImpact <= REACTION_TIME then
                        if tick() - lastParryTick > 0.1 then 
                            VirtualInputManager:SendKeyEvent(true, PARRY_KEY, false, game)
                            task.wait(0.01)
                            VirtualInputManager:SendKeyEvent(false, PARRY_KEY, false, game)
                            lastParryTick = tick()
                        end
                    end
                end

                -- TRIGGER: DODGE
                if isDodgeEnabled then
                    local dodgeThreshold = REACTION_TIME + 0.15
                    if timeToImpact <= dodgeThreshold and realDistance > 5 then
                        PerformSafeDodge(part)
                    end
                end
            end
        end
    end
end)
