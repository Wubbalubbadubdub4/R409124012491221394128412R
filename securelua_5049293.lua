-- RGH BLADE BALL ULTIMATE (V14 - 20% PANIC BUFF)
-- Updates: Panic & Last Layer Safety set to 20% (Balanced aggression)
-- Config: Pad 14, Y-Limit 15, Dodge 15

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Debris = game:GetService("Debris")
local Stats = game:GetService("Stats")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")

-- --- CONFIGURATION ---
local DEFAULT_RANGE = 20
local DEFAULT_PAD = 14        -- [USER SET] Tightened Circle Radius
local PANIC_DIST = 7          -- Layer 1 Base
local LAST_LAYER_DIST = 4     -- Layer 2 Base
local Y_AXIS_LIMIT = 15       -- [USER SET] Strict Vertical Limit
local REACTION_TIME = 0.25 
local DODGE_POWER = 15        -- [USER SET] Lower Dodge Power
local DODGE_DURATION = 0.25 
local PARRY_KEY = Enum.KeyCode.F

-- ** SCALING LOGIC **
local USE_DYNAMIC_SCALING = true
local SCALING_FACTOR = 20 
local MAX_SCALE_CAP = 60 

-- --- VARIABLES ---
local isDefaultSettings = true
local isParryEnabled = false
local isDodgeEnabled = false
local isWalkEnabled = false
local isVisualizerEnabled = false

local currentRange = DEFAULT_RANGE
local currentPad = DEFAULT_PAD

local lastDodgeTick = 0
local hasParriedCurrentInteraction = false 

local activeBall = nil 
local visualizerPart = nil

-- --- HELPER FUNCTIONS ---

local function GetPing()
    local success, ping = pcall(function()
        return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
    end)
    return success and ping or 0.1 
end

local function PressParry()
    VirtualInputManager:SendKeyEvent(true, PARRY_KEY, false, game)
    VirtualInputManager:SendKeyEvent(false, PARRY_KEY, false, game)
end

local function UpdateVisualizer(isTargeted, currentDynamicSize)
    if not root or not root.Parent then return end

    if not isVisualizerEnabled then
        if visualizerPart then visualizerPart:Destroy() visualizerPart = nil end
        return
    end

    if not visualizerPart then
        visualizerPart = Instance.new("Part")
        visualizerPart.Name = "ParryRangeVisualizer"
        visualizerPart.Shape = Enum.PartType.Cylinder
        visualizerPart.Material = Enum.Material.ForceField
        visualizerPart.Transparency = 0.8
        visualizerPart.Anchored = true
        visualizerPart.CanCollide = false
        visualizerPart.CastShadow = false
        visualizerPart.Parent = workspace
    end

    -- RED = DANGER (Targeted), BLUE = IDLE
    if isTargeted then
        visualizerPart.Color = Color3.fromRGB(255, 0, 0)
        visualizerPart.Transparency = 0.4
    else
        visualizerPart.Color = Color3.fromRGB(0, 150, 255)
        visualizerPart.Transparency = 0.85
    end

    -- Visualizes the "Circle" on the ground
    local sizeToUse = currentDynamicSize or currentRange
    local safeRange = math.clamp(sizeToUse, 5, 300) 
    local size = safeRange * 2
    
    visualizerPart.Size = Vector3.new(1, size, size) -- Flat Cylinder
    visualizerPart.CFrame = root.CFrame * CFrame.Angles(0, 0, math.rad(90))
end

-- --- UI CREATION ---
if player.PlayerGui:FindFirstChild("BladeBall_Precision_Hub") then
    player.PlayerGui.BladeBall_Precision_Hub:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BladeBall_Precision_Hub"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 280, 0, 480)
mainFrame.Position = UDim2.new(0.5, -140, 0.4, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18) 
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true 
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 14)
local border = Instance.new("UIStroke", mainFrame)
border.Color = Color3.fromRGB(0, 255, 150)
border.Thickness = 2
border.Transparency = 0.6

-- Title
local title = Instance.new("TextLabel")
title.Text = "BLADE BALL PRECISION"
title.Size = UDim2.new(1, 0, 0, 40)
title.TextColor3 = Color3.fromRGB(0, 255, 150) 
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBlack
title.TextSize = 20
title.Parent = mainFrame

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
closeBtn.BackgroundTransparency = 1
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 20
closeBtn.Parent = mainFrame
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

-- Settings Container
local settingsFrame = Instance.new("Frame")
settingsFrame.Size = UDim2.new(0, 250, 0, 140)
settingsFrame.Position = UDim2.new(0.5, -125, 0, 50)
settingsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
settingsFrame.Parent = mainFrame
Instance.new("UICorner", settingsFrame).CornerRadius = UDim.new(0, 10)

local function CreateInput(labelText, yPos, defaultVal, callback)
    local lbl = Instance.new("TextLabel")
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0, 10, 0, yPos)
    lbl.Size = UDim2.new(0, 100, 0, 25)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = settingsFrame

    local box = Instance.new("TextBox")
    box.Text = tostring(defaultVal)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    box.Position = UDim2.new(1, -60, 0, yPos)
    box.Size = UDim2.new(0, 50, 0, 25)
    box.Font = Enum.Font.GothamMedium
    box.TextEditable = false
    box.Parent = settingsFrame
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)

    box.FocusLost:Connect(function()
        if not isDefaultSettings then
            local num = tonumber(box.Text)
            if num then
                num = math.clamp(num, 0, 100)
                box.Text = tostring(num)
                callback(num)
            else 
                box.Text = tostring(defaultVal)
                callback(defaultVal)
            end
        end
    end)
    return box
end

local rangeBox = CreateInput("Base Range:", 50, DEFAULT_RANGE, function(val) currentRange = val end)
local padBox = CreateInput("Hitbox Pad:", 90, DEFAULT_PAD, function(val) currentPad = val end)

local defSwitchBtn = Instance.new("TextButton")
defSwitchBtn.Size = UDim2.new(1, -20, 0, 30)
defSwitchBtn.Position = UDim2.new(0, 10, 0, 10)
defSwitchBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 120) 
defSwitchBtn.Text = "MODE: DEFAULT"
defSwitchBtn.TextColor3 = Color3.fromRGB(10, 10, 10)
defSwitchBtn.Font = Enum.Font.GothamBold
defSwitchBtn.TextSize = 12
defSwitchBtn.Parent = settingsFrame
Instance.new("UICorner", defSwitchBtn).CornerRadius = UDim.new(0, 6)

defSwitchBtn.MouseButton1Click:Connect(function()
    isDefaultSettings = not isDefaultSettings
    if isDefaultSettings then
        defSwitchBtn.Text = "MODE: DEFAULT"
        defSwitchBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
        currentRange = DEFAULT_RANGE
        currentPad = DEFAULT_PAD
        rangeBox.TextEditable = false
        padBox.TextEditable = false
        rangeBox.Text = tostring(DEFAULT_RANGE)
        padBox.Text = tostring(DEFAULT_PAD)
    else
        defSwitchBtn.Text = "MODE: CUSTOM"
        defSwitchBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        rangeBox.TextEditable = true
        padBox.TextEditable = true
    end
end)

local function CreateToggleButton(btnText, yPos, color, callback)
    local btn = Instance.new("TextButton")
    btn.Text = btnText .. " [OFF]"
    btn.Size = UDim2.new(0, 250, 0, 45)
    btn.Position = UDim2.new(0.5, -125, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Parent = mainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local s = Instance.new("UIStroke", btn)
    s.Color = Color3.fromRGB(50, 50, 50)
    s.Thickness = 1.5

    btn.MouseButton1Click:Connect(function()
        local newState = callback()
        if newState then
            btn.Text = btnText .. " [ON]"
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.BackgroundColor3 = color
            s.Color = color
        else
            btn.Text = btnText .. " [OFF]"
            btn.TextColor3 = Color3.fromRGB(150, 150, 150)
            btn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
            s.Color = Color3.fromRGB(50, 50, 50)
        end
    end)
end

CreateToggleButton("AUTO-PARRY", 200, Color3.fromRGB(0, 255, 100), function() isParryEnabled = not isParryEnabled return isParryEnabled end)
CreateToggleButton("AUTO-DODGE", 255, Color3.fromRGB(0, 180, 255), function() isDodgeEnabled = not isDodgeEnabled return isDodgeEnabled end)
CreateToggleButton("AUTO-WALK", 310, Color3.fromRGB(255, 150, 0), function() isWalkEnabled = not isWalkEnabled return isWalkEnabled end)
CreateToggleButton("VISUALIZER", 365, Color3.fromRGB(200, 0, 255), function() 
    isVisualizerEnabled = not isVisualizerEnabled 
    if not isVisualizerEnabled and visualizerPart then visualizerPart:Destroy() visualizerPart = nil end
    return isVisualizerEnabled 
end)

-- --- LOGIC ---

local function PerformSmoothDodge(ballPart)
    if not root then return end
    lastDodgeTick = tick()
    local directionToBall = (ballPart.Position - root.Position).Unit
    local rightVector = directionToBall:Cross(Vector3.new(0, 1, 0))
    local chosenDirection = rightVector
    
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {player.Character}
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    if workspace:Raycast(root.Position, rightVector * 10, rayParams) then
        chosenDirection = -rightVector
    end

    local oldVel = root:FindFirstChild("SmoothDodge")
    if oldVel then oldVel:Destroy() end
    
    local bv = Instance.new("BodyVelocity")
    bv.Name = "SmoothDodge"
    bv.Velocity = chosenDirection * DODGE_POWER
    bv.MaxForce = Vector3.new(15000, 0, 15000) 
    bv.P = 300 
    bv.Parent = root
    Debris:AddItem(bv, DODGE_DURATION)
end

-- --- SMART BALL TRACKING ---
local function FindBestBall()
    local ballsFolder = workspace:FindFirstChild("Balls")
    if not ballsFolder then return nil end
    
    local bestBall = nil
    local shortestDist = math.huge
    local myName = player.Name
    
    for _, ball in ipairs(ballsFolder:GetChildren()) do
        if ball:IsA("BasePart") then
            local target = ball:GetAttribute("target")
            local isTargetingMe = (target == myName)
            local dist = (ball.Position - root.Position).Magnitude
            
            if isTargetingMe then
                if bestBall and bestBall:GetAttribute("target") == myName then
                    if dist < shortestDist then
                        bestBall = ball
                        shortestDist = dist
                    end
                else
                    bestBall = ball
                    shortestDist = dist
                end
            elseif not bestBall or bestBall:GetAttribute("target") ~= myName then
                if dist < shortestDist then
                    bestBall = ball
                    shortestDist = dist
                end
            end
        end
    end
    return bestBall
end

-- --- MAIN LOOP ---

RunService.PreSimulation:Connect(function()
    if not char or not char.Parent then
        char = player.Character
        if char then root = char:FindFirstChild("HumanoidRootPart") end
        return
    end
    if not root or not root.Parent then return end

    activeBall = FindBestBall()

    local isTargetingMe = false
    local finalEffectiveRange = currentRange 

    if activeBall and activeBall.Parent then 
        local targetName = activeBall:GetAttribute("target")
        isTargetingMe = (targetName == player.Name)
        
        -- DYNAMIC SCALING (Range Only)
        if isTargetingMe then
            local velocity = activeBall.AssemblyLinearVelocity
            local relativePos = activeBall.Position - root.Position
            local speedTowardsMe = -relativePos.Unit:Dot(velocity)

            if USE_DYNAMIC_SCALING and speedTowardsMe > 0 then
                local extraRange = math.clamp(speedTowardsMe / SCALING_FACTOR, 0, MAX_SCALE_CAP)
                finalEffectiveRange = currentRange + extraRange
            end
        end
    end

    if isVisualizerEnabled then UpdateVisualizer(isTargetingMe, finalEffectiveRange) end

    if not activeBall or not activeBall.Parent then return end

    if not isTargetingMe then
        hasParriedCurrentInteraction = false
    end

    if isTargetingMe then
        if not activeBall or not activeBall.Parent or not root or not root.Parent then return end 

        local velocity = activeBall.AssemblyLinearVelocity
        local relativePos = activeBall.Position - root.Position
        
        local verticalDistance = math.abs(relativePos.Y)
        local horizontalDistance = Vector3.new(relativePos.X, 0, relativePos.Z).Magnitude

        if verticalDistance > Y_AXIS_LIMIT then return end 

        local speedTowardsMe = -relativePos.Unit:Dot(velocity)
        local ping = GetPing()
        local pingOffset = speedTowardsMe * ping
        local rawRadius = math.max(activeBall.Size.X, activeBall.Size.Z) / 2
        
        local effectiveDistance = (horizontalDistance - rawRadius - currentPad) - pingOffset
        
        if isParryEnabled then
            if speedTowardsMe > 0 then
                
                local dist3D = relativePos.Magnitude 
                
                -- [LAYER 1] PANIC (Base 7 + 20% Increase)
                if dist3D <= (PANIC_DIST * 1.2) then
                      PressParry() 
                end

                -- [LAYER 2] FINAL PROTECTION (Base 4 + 20% Increase)
                if dist3D <= (LAST_LAYER_DIST * 1.2) then
                      PressParry() 
                end

                -- [LAYER 3] STANDARD PRECISION
                if effectiveDistance <= finalEffectiveRange then
                    if not hasParriedCurrentInteraction then
                        PressParry()
                        hasParriedCurrentInteraction = true 
                    end
                end
            end
        end

        if isDodgeEnabled then
            local dynamicCooldown = 0.4
            if speedTowardsMe > 0 then dynamicCooldown = 0.2 end
            
            local timeToImpact = effectiveDistance / math.max(1, speedTowardsMe)
            if timeToImpact <= (REACTION_TIME + 0.3) and effectiveDistance > 10 then
                if tick() - lastDodgeTick > dynamicCooldown then
                    PerformSmoothDodge(activeBall)
                end
            end
        end
    end
end)
