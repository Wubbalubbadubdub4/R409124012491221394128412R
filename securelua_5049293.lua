-- RGH BLADE BALL ULTIMATE (AVOIDER & DISTANCE KEEPER EDITION)
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Debris = game:GetService("Debris")
local Stats = game:GetService("Stats")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

-- --- CONFIGURATION ---
local DEFAULT_RANGE = 18 -- Set to your request (15-20 range)
local DEFAULT_PAD = 10
local REACTION_TIME = 0.15

-- AVOIDER SETTINGS (Low values, smooth movement)
local DODGE_POWER = 35       -- Much lower (was 80). Acts like a fast walk/strafe.
local DODGE_DURATION = 0.25  -- Short duration to allow direction changes
local WALK_MAINTAIN_DIST = 10 -- Exact distance to keep from players

local PARRY_KEY = Enum.KeyCode.F

-- --- VARIABLES ---
local isDefaultSettings = true
local isParryEnabled = false
local isDodgeEnabled = false
local isWalkEnabled = false
local isVisualizerEnabled = false

local currentRange = DEFAULT_RANGE
local currentPad = DEFAULT_PAD

local lastParryTick = 0
local lastDodgeTick = 0
local lastWalkTick = 0
local isDodging = false -- State tracker to prevent fighting between Walk and Dodge

-- --- CACHING SYSTEM ---
local ballsFolder = workspace:WaitForChild("Balls")
local activeBalls = {}

local function CacheBall(ball)
    if not ball:IsA("BasePart") then return end
    if not table.find(activeBalls, ball) then table.insert(activeBalls, ball) end
end

local function UncacheBall(ball)
    local index = table.find(activeBalls, ball)
    if index then table.remove(activeBalls, index) end
end

for _, b in ipairs(ballsFolder:GetChildren()) do CacheBall(b) end
ballsFolder.ChildAdded:Connect(CacheBall)
ballsFolder.ChildRemoved:Connect(UncacheBall)

-- --- HELPER FUNCTIONS ---

local function GetPing()
    return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
end

local function UpdateVisualizer()
    local vizName = "BladeBallRangeViz"
    local viz = workspace:FindFirstChild(vizName)

    if not isVisualizerEnabled or not root then
        if viz then viz:Destroy() end
        return
    end

    if not viz then
        viz = Instance.new("Part")
        viz.Name = vizName
        viz.Shape = Enum.PartType.Cylinder
        viz.Material = Enum.Material.ForceField
        viz.Color = Color3.fromRGB(0, 255, 120) -- Green for "Safe Zone" feel
        viz.Transparency = 0.8
        viz.Anchored = true
        viz.CanCollide = false
        viz.CastShadow = false
        viz.Parent = workspace
    end

    local size = currentRange * 2
    viz.Size = Vector3.new(0.5, size, size)
    viz.CFrame = root.CFrame * CFrame.Angles(0, 0, math.rad(90))
end

-- --- UI CREATION ---
if player.PlayerGui:FindFirstChild("BladeBall_Avoider_Hub") then
    player.PlayerGui.BladeBall_Avoider_Hub:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BladeBall_Avoider_Hub"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 280, 0, 480)
mainFrame.Position = UDim2.new(0.5, -140, 0.4, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true 
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

-- Top Bar
local title = Instance.new("TextLabel")
title.Text = "BLADE AVOIDER"
title.Size = UDim2.new(1, -40, 0, 30)
title.Position = UDim2.new(0, 15, 0, 5)
title.TextColor3 = Color3.fromRGB(0, 255, 200) 
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBlack
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainFrame

local closeBtn = Instance.new("TextButton")
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
closeBtn.BackgroundTransparency = 1
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.Parent = mainFrame

local mainLoop = nil
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
    if mainLoop then mainLoop:Disconnect() end
    local viz = workspace:FindFirstChild("BladeBallRangeViz")
    if viz then viz:Destroy() end
end)

-- Settings
local settingsFrame = Instance.new("Frame")
settingsFrame.Size = UDim2.new(0, 250, 0, 120)
settingsFrame.Position = UDim2.new(0.5, -125, 0, 50)
settingsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
settingsFrame.Parent = mainFrame
Instance.new("UICorner", settingsFrame).CornerRadius = UDim.new(0, 8)

local function CreateInput(text, y, val, cb)
    local l = Instance.new("TextLabel")
    l.Text = text
    l.TextColor3 = Color3.fromRGB(180, 180, 180)
    l.BackgroundTransparency = 1
    l.Position = UDim2.new(0, 10, 0, y)
    l.Size = UDim2.new(0, 100, 0, 25)
    l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = settingsFrame
    
    local b = Instance.new("TextBox")
    b.Text = tostring(val)
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    b.Position = UDim2.new(1, -60, 0, y)
    b.Size = UDim2.new(0, 50, 0, 25)
    b.Font = Enum.Font.GothamBold
    b.TextEditable = false
    b.Parent = settingsFrame
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    b.FocusLost:Connect(function() 
        if not isDefaultSettings then cb(tonumber(b.Text) or val) else b.Text = tostring(val) end 
    end)
    return b
end

local rangeBox = CreateInput("Range (15-20):", 10, DEFAULT_RANGE, function(v) currentRange = v end)
local padBox = CreateInput("Hitbox Pad:", 45, DEFAULT_PAD, function(v) currentPad = v end)

-- Custom/Default Toggle
local modeBtn = Instance.new("TextButton")
modeBtn.Text = "MODE: DEFAULT"
modeBtn.Size = UDim2.new(1, -20, 0, 30)
modeBtn.Position = UDim2.new(0, 10, 0, 80)
modeBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
modeBtn.Parent = settingsFrame
Instance.new("UICorner", modeBtn).CornerRadius = UDim.new(0, 6)

modeBtn.MouseButton1Click:Connect(function()
    isDefaultSettings = not isDefaultSettings
    if isDefaultSettings then
        modeBtn.Text = "MODE: DEFAULT"
        modeBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
        currentRange = DEFAULT_RANGE; rangeBox.Text = tostring(DEFAULT_RANGE); rangeBox.TextEditable = false
        currentPad = DEFAULT_PAD; padBox.Text = tostring(DEFAULT_PAD); padBox.TextEditable = false
    else
        modeBtn.Text = "MODE: CUSTOM"
        modeBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
        rangeBox.TextEditable = true
        padBox.TextEditable = true
    end
end)

-- Toggles
local function CreateToggle(txt, y, col, cb)
    local b = Instance.new("TextButton")
    b.Text = txt .. " [OFF]"
    b.Size = UDim2.new(0, 250, 0, 40)
    b.Position = UDim2.new(0.5, -125, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    b.TextColor3 = Color3.fromRGB(150, 150, 150)
    b.Font = Enum.Font.GothamBold
    b.Parent = mainFrame
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(function()
        local s = cb()
        b.Text = txt .. (s and " [ON]" or " [OFF]")
        b.BackgroundColor3 = s and col or Color3.fromRGB(25, 25, 30)
        b.TextColor3 = s and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
    end)
end

CreateToggle("AUTO PARRY", 190, Color3.fromRGB(0, 255, 100), function() isParryEnabled = not isParryEnabled return isParryEnabled end)
CreateToggle("SMOOTH AVOIDER", 240, Color3.fromRGB(0, 180, 255), function() isDodgeEnabled = not isDodgeEnabled return isDodgeEnabled end)
CreateToggle("KEEP DISTANCE (10 STUDS)", 290, Color3.fromRGB(255, 160, 0), function() isWalkEnabled = not isWalkEnabled return isWalkEnabled end)
CreateToggle("VISUALIZER", 340, Color3.fromRGB(200, 50, 255), function() isVisualizerEnabled = not isVisualizerEnabled return isVisualizerEnabled end)

-- --- LOGIC FUNCTIONS ---

local function PerformAvoider(ballPart)
    if not root or isDodging then return end
    if tick() - lastDodgeTick < 0.3 then return end -- Cooldown
    
    lastDodgeTick = tick()
    isDodging = true

    -- Vector Math: Find perpendicular direction to ball trajectory
    local ballDir = ballPart.AssemblyLinearVelocity.Unit
    -- If ball isn't moving fast, use position difference
    if ballPart.AssemblyLinearVelocity.Magnitude < 10 then
        ballDir = (root.Position - ballPart.Position).Unit
    end

    local right = ballDir:Cross(Vector3.new(0, 1, 0))
    local left = -right
    
    -- Raycast to see which way is clear
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {player.Character, ballsFolder}
    
    local blockedRight = workspace:Raycast(root.Position, right * 10, params)
    local blockedLeft = workspace:Raycast(root.Position, left * 10, params)
    
    local chosenDir = nil
    
    -- Prefer moving consistently to one side if possible to "orbit"
    if not blockedRight then 
        chosenDir = right 
    elseif not blockedLeft then 
        chosenDir = left 
    else
        -- Cornered? Back up diagonally
        chosenDir = (root.Position - ballPart.Position).Unit + right
    end
    
    if chosenDir then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "AvoiderVelocity"
        bv.Velocity = chosenDir.Unit * DODGE_POWER -- Low power (35)
        bv.MaxForce = Vector3.new(1e5, 0, 1e5) -- Force it to override friction
        bv.P = 1500 -- Smooth power
        bv.Parent = root
        
        -- Cleanup
        task.delay(DODGE_DURATION, function()
            if bv then bv:Destroy() end
            isDodging = false
        end)
    else
        isDodging = false
    end
end

local function PerformDistanceKeeper()
    if isDodging then return end -- Don't walk if we are mid-dodge
    if tick() - lastWalkTick < 0.1 then return end
    lastWalkTick = tick()

    local nearestThreat = nil
    local minDist = 9999

    -- Find nearest player
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (p.Character.HumanoidRootPart.Position - root.Position).Magnitude
            if dist < minDist then
                minDist = dist
                nearestThreat = p.Character.HumanoidRootPart
            end
        end
    end

    if nearestThreat then
        -- Logic: If we are closer than 10 studs, back up. If we are within 25 studs, adjust.
        if minDist < WALK_MAINTAIN_DIST then
            -- Too close! Move BACK to exactly 10 studs
            local dirAway = (root.Position - nearestThreat.Position).Unit
            local targetPos = nearestThreat.Position + (dirAway * WALK_MAINTAIN_DIST)
            hum:MoveTo(targetPos)
        elseif minDist < 20 and minDist > WALK_MAINTAIN_DIST + 2 then
            -- We are safe, stop moving (don't run across map)
            hum:MoveTo(root.Position) 
        end
    end
end

-- --- MAIN LOOP ---

mainLoop = RunService.PostSimulation:Connect(function()
    if not char or not char.Parent then
        char = player.Character
        if char then 
            root = char:FindFirstChild("HumanoidRootPart") 
            hum = char:FindFirstChild("Humanoid")
        end
        return
    end

    if isVisualizerEnabled then UpdateVisualizer() end
    if isWalkEnabled then PerformDistanceKeeper() end
    if not isParryEnabled and not isDodgeEnabled then return end

    for _, ball in ipairs(activeBalls) do
        if ball and ball.Parent then
            local target = ball:GetAttribute("target")
            local isTargetingMe = (target == player.Name)
            
            local dist = (ball.Position - root.Position).Magnitude
            local speedTowardsMe = -((ball.Position - root.Position).Unit):Dot(ball.AssemblyLinearVelocity)
            
            -- Activation Condition
            if speedTowardsMe > 0 or (isTargetingMe and dist < 60) then
                
                local ping = GetPing()
                local pingOffset = math.clamp(speedTowardsMe * ping, 0, 40)
                
                -- Hitbox
                local ballRad = math.max(ball.Size.X, ball.Size.Z) / 2
                local effDist = (dist - ballRad - currentPad) - pingOffset
                
                local timeToImpact = effDist / math.max(1, speedTowardsMe)
                
                -- Reaction Calc
                local reactionThreshold = REACTION_TIME
                if speedTowardsMe > 80 then reactionThreshold = 0.18 end -- Fast ball compensation
                
                -- PARRY
                if isParryEnabled and effDist <= currentRange and timeToImpact <= reactionThreshold then
                    if tick() - lastParryTick > 0.12 then
                        VirtualInputManager:SendKeyEvent(true, PARRY_KEY, false, game)
                        VirtualInputManager:SendKeyEvent(false, PARRY_KEY, false, game)
                        lastParryTick = tick()
                    end
                end

                -- AVOIDER (Run slightly before Parry needed)
                if isDodgeEnabled then
                    -- Trigger avoid if ball is aiming at us and close-ish, OR very close
                    if (isTargetingMe and dist < 50) or (timeToImpact < 0.5 and effDist > 10) then
                        PerformAvoider(ball)
                    end
                end
            end
        else
            UncacheBall(ball)
        end
    end
end)
