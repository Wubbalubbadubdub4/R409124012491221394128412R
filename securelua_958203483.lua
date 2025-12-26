--!strict
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

-- Configuration
local PASSWORD = "ilovepearls" -- [[ ONLY THIS PASSWORD IS REQUIRED NOW ]]
local CONFIG = {
    Agent = {
        Buffer = 1.5,
        CanJump = true,
        CanClimb = true,
        WalkSpeed = 18
    },
    Visuals = {
        PathThickness = 0.2,
        ESPOffset = Vector3.new(0, 3, 0),
        ESPTextSize = 18,
        StatusColors = {
            Active = Color3.fromRGB(0, 150, 0),
            Paused = Color3.fromRGB(200, 150, 0),
            Inactive = Color3.fromRGB(150, 0, 0),
            ObstaclesRemoved = Color3.fromRGB(255, 100, 50)
        }
    },
    Navigation = {
        WaypointSpacing = 6,
        AcceptanceRadius = 2, 
        PathRefreshRate = 0.5,
        PromptTriggerDistance = 6,
        MaxWaypointAttempts = 5,
        StuckThreshold = 3,
        NoclipDuration = 10
    },
    Proximity = {
        CheckInterval = 0.5,
        Radius = 100,
        PauseDuration = 30,
        DebounceDuration = 10
    }
}

-- Security System (WHITELIST REMOVED)
local SECURITY = {
    Messages = {
        Success = "ACCESS GRANTED! Welcome.",
        Error = "Incorrect Password."
    }
}

-- Obstacle Remover Configuration
local FENCE_NAMES = {
    ["Wooden Fence"] = true,
    ["Wooden Fence Corner"] = true,
    ["Tall Wooden Fence"] = true,
    ["Tall Wooden Fence Corner"] = true,
    ["Dodecahedron"] = true,
    ["Octahedron"] = true,
    ["Cube"] = true,
    ["Tetrahedron"] = true,
    ["Icosahedron"] = true,
    ["Floor"] = true,
    ["Party Portal"] = true
}

-- Services
local Player = Players.LocalPlayer
local TargetGroup = nil

-- State Management
local State = {
    Active = false,
    PathBlacklist = {},
    Visuals = {
        ESP = {},
        Path = {}
    },
    CurrentTarget = nil,
    ProximityCheckTime = 0,
    ProximityPausedUntil = 0,
    ProximityDebounceUntil = 0,
    GUI = {
        ToggleButton = nil,
        StatusLabel = nil,
        ObstacleButton = nil
    },
    NoclipActive = false,
    LastPosition = nil,
    StuckTimer = 0,
    PasswordGUI = nil,
    Authenticated = false,
    RainbowHue = 0,
    ObstacleRemoverActive = false
}

-- Cleanup System
local function Cleanup()
    for _, part in ipairs(State.Visuals.Path) do
        part:Destroy()
    end
    for target, esp in pairs(State.Visuals.ESP) do
        esp:Destroy()
    end
    
    State.Active = false
    State.Visuals.Path = {}
    State.Visuals.ESP = {}
    State.CurrentTarget = nil
    State.PathBlacklist = {}
    
    if State.GUI.ToggleButton and State.GUI.ToggleButton.Parent then
        State.GUI.ToggleButton.Parent.Parent:Destroy()
    end
end

-- Character Initialization
local function GetCharacter()
    local character = Player.Character or Player.CharacterAdded:Wait()
    return character, character:WaitForChild("Humanoid"), character:WaitForChild("HumanoidRootPart")
end

-- Noclip System
local function ToggleNoclip(enable: boolean)
    local character = Player.Character
    if not character then return end
    
    State.NoclipActive = enable
    
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not enable
        end
    end
    
    if enable then
        task.delay(CONFIG.Navigation.NoclipDuration, function()
            if State.NoclipActive then
                ToggleNoclip(false)
            end
        end)
    end
end

-- Stuck Detection
local function CheckStuck()
    local character = Player.Character
    if not character then return false end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return false end

    if State.LastPosition then
        if (root.Position - State.LastPosition).Magnitude < 1 then
            State.StuckTimer += RunService.Heartbeat:Wait()
        else
            State.StuckTimer = 0
        end
    end
    State.LastPosition = root.Position

    if State.StuckTimer >= CONFIG.Navigation.StuckThreshold then
        ToggleNoclip(true)
        State.StuckTimer = 0
        return true
    end
    return false
end

-- Proximity Prompt Handling
local function GetValidPrompt(target: Instance): ProximityPrompt?
    return target:IsA("ProximityPrompt") and target or target:FindFirstChildOfClass("ProximityPrompt")
end

-- Generate color from name
local function GetColorFromName(name: string): Color3
    local hash = 0
    for i = 1, #name do
        hash = (hash * 31 + string.byte(name, i)) % 360
    end
    return Color3.fromHSV(hash/360, 1, 1)
end

-- Rainbow color generator
local function GetRainbowColor()
    State.RainbowHue = (State.RainbowHue + 0.01) % 1
    return Color3.fromHSV(State.RainbowHue, 1, 1)
end

-- Optimized ESP System with name-based colors
local function ManageESP(target: Instance)
    if State.Visuals.ESP[target] then return end
    
    local prompt = GetValidPrompt(target)
    if not prompt then return end

    local esp = Instance.new("BillboardGui")
    esp.Name = "MonadESP_"..HttpService:GenerateGUID(false)
    esp.Size = UDim2.new(0, 200, 0, 40)
    esp.StudsOffset = CONFIG.Visuals.ESPOffset
    esp.AlwaysOnTop = true
    esp.Adornee = target:IsA("Model") and target.PrimaryPart or target
    esp.Parent = target

    local textColor = GetColorFromName(target.Name)
    
    local label = Instance.new("TextLabel", esp)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = `{target.Name} ({prompt.ActionText})`
    label.TextColor3 = textColor
    label.Font = Enum.Font.GothamBold
    label.TextSize = CONFIG.Visuals.ESPTextSize
    label.TextStrokeTransparency = 0.5
    label.TextStrokeColor3 = Color3.new(0, 0, 0)

    State.Visuals.ESP[target] = esp

    local connection
    connection = target.AncestryChanged:Connect(function()
        if not target.Parent then
            connection:Disconnect()
            esp:Destroy()
            State.Visuals.ESP[target] = nil
        end
    end)
end

-- Rainbow Path Visualization
local function DrawPath(waypoints: {PathWaypoint})
    for _, part in ipairs(State.Visuals.Path) do
        part:Destroy()
    end
    State.Visuals.Path = {}

    if not waypoints or #waypoints < 2 then return end

    for i = 1, #waypoints - 1 do
        local start = waypoints[i].Position
        local finish = waypoints[i + 1].Position

        local part = Instance.new("Part")
        part.Name = "RainbowPathSegment_"..i
        part.Size = Vector3.new(0.1, 0.1, 0.1)
        part.Transparency = 1
        part.Anchored = true
        part.CanCollide = false
        part.Parent = workspace

        local attachment1 = Instance.new("Attachment", part)
        attachment1.WorldPosition = start
        local attachment2 = Instance.new("Attachment", part)
        attachment2.WorldPosition = finish

        local beam = Instance.new("Beam")
        beam.Attachment0 = attachment1
        beam.Attachment1 = attachment2
        beam.Color = ColorSequence.new(GetRainbowColor())
        beam.Width0 = CONFIG.Visuals.PathThickness
        beam.Width1 = CONFIG.Visuals.PathThickness
        beam.Parent = part

        table.insert(State.Visuals.Path, part)
    end
end

-- === IMPROVED PATHFINDING ===
local function CalculatePath(target: BasePart): {PathWaypoint}?
    if State.PathBlacklist[target] then return nil end

    local _, _, root = GetCharacter()
    
    local characterSize = root.Size
    local effectiveRadius = (math.max(characterSize.X, characterSize.Z) / 2) + CONFIG.Agent.Buffer
    local effectiveHeight = characterSize.Y
    
    local path = PathfindingService:CreatePath({
        AgentRadius = effectiveRadius,
        AgentHeight = effectiveHeight,
        AgentCanJump = CONFIG.Agent.CanJump,
        AgentCanClimb = CONFIG.Agent.CanClimb,
        WaypointSpacing = CONFIG.Navigation.WaypointSpacing,
        Costs = {
            Water = 20,
            Neon = math.huge 
        }
    })

    local success, result = pcall(function()
        path:ComputeAsync(root.Position, target.Position)
        if path.Status ~= Enum.PathStatus.Success then
            State.PathBlacklist[target] = true
            task.delay(1, function() State.PathBlacklist[target] = nil end)
            return nil
        end
        return path:GetWaypoints()
    end)

    return success and result or nil
end

-- [[ NAVIGATION SYSTEM ]]
local function NavigateTo(target: Instance)
    local _, humanoid, root = GetCharacter()
    local prompt = GetValidPrompt(target)
    if not prompt then return false end

    humanoid.WalkSpeed = CONFIG.Agent.WalkSpeed

    State.CurrentTarget = target
    local lastRecalculation = time()
    local targetPart = target:IsA("Model") and target.PrimaryPart or target

    while State.Active and State.CurrentTarget == target and target.Parent do
        -- Force speed
        if humanoid.WalkSpeed < CONFIG.Agent.WalkSpeed then
            humanoid.WalkSpeed = CONFIG.Agent.WalkSpeed
        end

        if time() < State.ProximityPausedUntil then
            DrawPath(nil)
            task.wait(1)
            continue
        end

        if CheckStuck() then
            task.wait(0.1)
        end

        -- Calculate Path
        local waypoints = CalculatePath(targetPart)
        
        if waypoints and #waypoints > 0 then
            DrawPath(waypoints)
            
            -- Walk through waypoints
            for index, waypoint in ipairs(waypoints) do
                if not State.Active or State.CurrentTarget ~= target then break end
                
                -- Check proximity to PEARL
                if (root.Position - targetPart.Position).Magnitude <= CONFIG.Navigation.PromptTriggerDistance then
                    humanoid:MoveTo(root.Position) -- Stop moving
                    fireproximityprompt(prompt)
                    task.wait(prompt.HoldDuration + 0.2)
                    return true -- Success
                end

                -- Jump check
                if waypoint.Action == Enum.PathWaypointAction.Jump then
                    humanoid.Jump = true
                end

                -- Move to waypoint
                humanoid:MoveTo(waypoint.Position)
                
                -- Wait for arrival with timeout
                local moveSuccess = humanoid.MoveToFinished:Wait()
                
                local distToWaypoint = (root.Position - waypoint.Position).Magnitude
                if distToWaypoint > CONFIG.Navigation.AcceptanceRadius + 3 then
                    break -- Recalculate if we drifted
                end
            end
        else
            task.wait(0.5)
        end
        task.wait()
    end
    return false
end

-- Optimized Target Finder
local function FindOptimalTarget()
    local _, _, root = GetCharacter()
    local closest, distance = nil, math.huge

    for _, child in TargetGroup:GetChildren() do
        local prompt = GetValidPrompt(child)
        local targetPart = child:IsA("Model") and child.PrimaryPart or child
        if prompt and targetPart and targetPart:IsA("BasePart") then
            local currentDistance = (targetPart.Position - root.Position).Magnitude
            if currentDistance < distance and not State.PathBlacklist[targetPart] then
                closest = child
                distance = currentDistance
            end
        end
    end
    return closest
end

-- Proximity System
local function CheckNearbyPlayers()
    local character = Player.Character
    if not character then return false end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return false end

    for _, otherPlayer in Players:GetPlayers() do
        if otherPlayer ~= Player and otherPlayer.Character then
            local otherRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
            if otherRoot and (root.Position - otherRoot.Position).Magnitude <= CONFIG.Proximity.Radius then
                return true
            end
        end
    end
    return false
end

-- State Updater
local function UpdateStatus()
    if not State.GUI.StatusLabel then return end
    
    if State.ProximityPausedUntil > time() then
        State.GUI.StatusLabel.Text = `PAUSED ({math.ceil(State.ProximityPausedUntil - time())}s)`
        State.GUI.StatusLabel.TextColor3 = CONFIG.Visuals.StatusColors.Paused
        State.GUI.ToggleButton.Text = "⏸ PAUSED"
        State.GUI.ToggleButton.BackgroundColor3 = CONFIG.Visuals.StatusColors.Paused
    elseif State.Active then
        State.GUI.StatusLabel.Text = "NAVIGATING"
        State.GUI.StatusLabel.TextColor3 = CONFIG.Visuals.StatusColors.Active
        State.GUI.ToggleButton.Text = "⏹ STOP"
        State.GUI.ToggleButton.BackgroundColor3 = CONFIG.Visuals.StatusColors.Active
    else
        State.GUI.StatusLabel.Text = "INACTIVE"
        State.GUI.StatusLabel.TextColor3 = CONFIG.Visuals.StatusColors.Inactive
        State.GUI.ToggleButton.Text = "▶ START"
        State.GUI.ToggleButton.BackgroundColor3 = CONFIG.Visuals.StatusColors.Inactive
    end
end

-- Main Controller
local function ControlLoop()
    while State.Active and State.Authenticated do
        if time() > State.ProximityDebounceUntil then
            if CheckNearbyPlayers() then
                if State.ProximityCheckTime == 0 then
                    State.ProximityCheckTime = time()
                elseif time() - State.ProximityCheckTime >= 10 then
                    State.ProximityPausedUntil = time() + CONFIG.Proximity.PauseDuration
                    State.ProximityDebounceUntil = State.ProximityPausedUntil + CONFIG.Proximity.DebounceDuration
                    State.ProximityCheckTime = 0
                    DrawPath(nil)
                end
            else
                State.ProximityCheckTime = 0
            end
        end

        local target = FindOptimalTarget()
        if target then
            ManageESP(target)
            NavigateTo(target)
        end
        
        UpdateStatus()
        task.wait(0.5)
    end
end

-- === OBSTACLE REMOVER LOGIC ===
local function TryRemoveFence(obj)
    if FENCE_NAMES[obj.Name] then
        obj:Destroy()
    end
end

local function RemoveAllFences()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        TryRemoveFence(obj)
    end
end

local function CreateBoundaryWalls()
    local baseplate = Workspace.Persistent:FindFirstChild("Baseplate")
    if not baseplate then return end

    local barrierFolder = Workspace:FindFirstChild("BarrierWalls") or Instance.new("Folder")
    barrierFolder.Name = "BarrierWalls"
    barrierFolder.Parent = Workspace

    -- Clear existing barriers
    for _, wall in ipairs(barrierFolder:GetChildren()) do
        wall:Destroy()
    end

    local wallThickness = 10
    local wallHeight = 50
    local baseplateSize = baseplate.Size

    -- Wall configurations
    local sides = {
        {name = "FrontWall", position = Vector3.new(0, wallHeight/2, baseplateSize.Z/2 + wallThickness/2), size = Vector3.new(baseplateSize.X + 2*wallThickness, wallHeight, wallThickness)},
        {name = "BackWall", position = Vector3.new(0, wallHeight/2, -baseplateSize.Z/2 - wallThickness/2), size = Vector3.new(baseplateSize.X + 2*wallThickness, wallHeight, wallThickness)},
        {name = "LeftWall", position = Vector3.new(-baseplateSize.X/2 - wallThickness/2, wallHeight/2, 0), size = Vector3.new(wallThickness, wallHeight, baseplateSize.Z)},
        {name = "RightWall", position = Vector3.new(baseplateSize.X/2 + wallThickness/2, wallHeight/2, 0), size = Vector3.new(wallThickness, wallHeight, baseplateSize.Z)}
    }

    for _, side in ipairs(sides) do
        local wall = Instance.new("Part")
        wall.Name = side.name
        wall.Size = side.size
        wall.Position = baseplate.Position + side.position
        wall.Anchored = true
        wall.CanCollide = true
        wall.Material = Enum.Material.Concrete
        wall.Color = Color3.fromRGB(120, 120, 120)
        wall.Transparency = 0.3
        wall.Parent = barrierFolder
    end
end

local function ClearNeighboringBaseplates()
    local persistentFolder = Workspace:FindFirstChild("Persistent")
    if not persistentFolder then return end
    
    for _, part in ipairs(persistentFolder:GetChildren()) do
        if part.Name == "Neighboring Baseplate" then
            part:Destroy()
        end
    end
end

local function ClearReplacedParts()
    while State.ObstacleRemoverActive do
        local replacedFolder = Workspace:FindFirstChild("ReplacedParts")
        if replacedFolder then
            for _, item in ipairs(replacedFolder:GetChildren()) do
                item:Destroy()
            end
        end
        task.wait(60)
    end
end

local function ActivateObstacleRemover()
    if State.ObstacleRemoverActive then return end
    State.ObstacleRemoverActive = true
    
    -- Immediate Cleanup
    RemoveAllFences()
    CreateBoundaryWalls()
    ClearNeighboringBaseplates()
    
    -- Start background loops
    task.spawn(ClearReplacedParts)
    
    -- Listener for new fences
    Workspace.DescendantAdded:Connect(function(descendant)
        if State.ObstacleRemoverActive then
            TryRemoveFence(descendant)
        end
    end)
    
    -- UI Feedback
    if State.GUI.ObstacleButton then
        State.GUI.ObstacleButton.Text = "☢ OBSTACLES REMOVED"
        State.GUI.ObstacleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50) -- Greenish
    end
end

-- Modern GUI with cool design
local function CreateInterface()
    if not State.Authenticated then return end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "NavigationInterface_"..HttpService:GenerateGUID(false)
    gui.ResetOnSpawn = false
    gui.Parent = Player:WaitForChild("PlayerGui")

    -- Modern container
    local container = Instance.new("Frame", gui)
    container.Size = UDim2.new(0, 300, 0, 210) 
    container.Position = UDim2.new(1, -310, 0, 10)
    container.BackgroundTransparency = 0.3
    container.BackgroundColor3 = Color3.new(0.1, 0.1, 0.15)
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 12)
    
    local gradient = Instance.new("UIGradient", container)
    gradient.Rotation = 90
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 80)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 40))
    })
    
    local glow = Instance.new("UIStroke", container)
    glow.Color = Color3.fromRGB(100, 150, 255)
    glow.Thickness = 2
    glow.Transparency = 0.7
    glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    
    local title = Instance.new("TextLabel", container)
    title.Size = UDim2.new(1, -20, 0, 30)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "MONAD NAVIGATION SYSTEM"
    title.TextColor3 = Color3.fromRGB(180, 200, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    local titleGlow = Instance.new("UIStroke", title)
    titleGlow.Thickness = 1
    titleGlow.Transparency = 0.8
    titleGlow.Color = Color3.fromRGB(100, 200, 255)

    local statusContainer = Instance.new("Frame", container)
    statusContainer.Size = UDim2.new(1, -20, 0, 30)
    statusContainer.Position = UDim2.new(0, 10, 0, 50)
    statusContainer.BackgroundColor3 = Color3.new(0.15, 0.15, 0.2)
    statusContainer.BackgroundTransparency = 0.5
    Instance.new("UICorner", statusContainer).CornerRadius = UDim.new(0, 8)
    
    local statusLabel = Instance.new("TextLabel", statusContainer)
    statusLabel.Size = UDim2.new(1, 0, 1, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Status: INACTIVE"
    statusLabel.TextColor3 = CONFIG.Visuals.StatusColors.Inactive
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextSize = 16

    local toggleButton = Instance.new("TextButton", container)
    toggleButton.Size = UDim2.new(1, -20, 0, 40)
    toggleButton.Position = UDim2.new(0, 10, 0, 90)
    toggleButton.Text = "▶ START NAVIGATION"
    toggleButton.TextColor3 = Color3.new(1, 1, 1)
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.TextSize = 16
    Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0, 8)
    
    local buttonGradient = Instance.new("UIGradient", toggleButton)
    buttonGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 150, 220)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 100, 180))
    })
    
    local buttonGlow = Instance.new("UIStroke", toggleButton)
    buttonGlow.Color = Color3.fromRGB(100, 200, 255)
    buttonGlow.Thickness = 2
    buttonGlow.Transparency = 0.7

    local obstacleButton = Instance.new("TextButton", container)
    obstacleButton.Size = UDim2.new(1, -20, 0, 40)
    obstacleButton.Position = UDim2.new(0, 10, 0, 145)
    obstacleButton.Text = "☢ REMOVE OBSTACLES"
    obstacleButton.TextColor3 = Color3.new(1, 1, 1)
    obstacleButton.Font = Enum.Font.GothamBold
    obstacleButton.TextSize = 16
    obstacleButton.BackgroundColor3 = Color3.fromRGB(200, 80, 50)
    Instance.new("UICorner", obstacleButton).CornerRadius = UDim.new(0, 8)
    
    local obsStroke = Instance.new("UIStroke", obstacleButton)
    obsStroke.Color = Color3.fromRGB(255, 100, 100)
    obsStroke.Thickness = 2
    obsStroke.Transparency = 0.5

    State.GUI.ToggleButton = toggleButton
    State.GUI.ObstacleButton = obstacleButton
    State.GUI.StatusLabel = statusLabel

    toggleButton.Activated:Connect(function()
        State.Active = not State.Active
        if State.Active then
            task.spawn(ControlLoop)
        else
            State.CurrentTarget = nil
            DrawPath(nil)
            ToggleNoclip(false)
        end
        UpdateStatus()
    end)
    
    obstacleButton.Activated:Connect(function()
        ActivateObstacleRemover()
    end)

    return toggleButton
end

-- Experience Persistence System
local function Start()
    Cleanup()
    
    repeat task.wait() until workspace:FindFirstChild("Monads")
    TargetGroup = workspace.Monads
    
    Player.CharacterAdded:Connect(GetCharacter)
    GetCharacter()
    
    CreateInterface()
    
    TargetGroup.ChildAdded:Connect(ManageESP)
    for _, child in TargetGroup:GetChildren() do
        ManageESP(child)
    end
end

-- Security Verification
local function VerifyPlayerAccess()
    -- [[ FIXED: Always allow access since password check is done in UI ]]
    return true, SECURITY.Messages.Success
end

-- Modern Password GUI with enhanced visuals
local function CreatePasswordGUI()
    if State.PasswordGUI and State.PasswordGUI.Parent then return end

    local Attempts = 0
    local MaxAttempts = 5
    local connections = {}
    
    local function destroyGUI()
        if State.PasswordGUI and State.PasswordGUI.Parent then
            State.PasswordGUI:Destroy()
        end
        State.PasswordGUI = nil
        
        for _, conn in ipairs(connections) do
            conn:Disconnect()
        end
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "MonadPasswordGUI_"..HttpService:GenerateGUID(false)
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = Player:WaitForChild("PlayerGui")
    State.PasswordGUI = gui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 450, 0, 350)
    frame.Position = UDim2.new(0.5, -225, 0.5, -175)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Parent = gui
    
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 16)
    
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(100, 150, 255)
    stroke.Thickness = 2
    
    local gradient = Instance.new("UIGradient", frame)
    gradient.Rotation = 90
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 80)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 40))
    })
    
    table.insert(connections, RunService.Heartbeat:Connect(function()
        gradient.Rotation = gradient.Rotation + 0.5
    end))
    
    local title = Instance.new("TextLabel")
    title.Text = "MONAD SECURITY SYSTEM"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 32
    title.TextColor3 = Color3.fromRGB(180, 200, 255)
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(0.8, 0, 0.2, 0)
    title.Position = UDim2.new(0.1, 0, 0.05, 0)
    title.Parent = frame
    
    local titleGlow = Instance.new("UIStroke", title)
    titleGlow.Thickness = 2
    titleGlow.Transparency = 0.8
    titleGlow.Color = Color3.fromRGB(100, 200, 255)
    
    local inputContainer = Instance.new("Frame")
    inputContainer.Size = UDim2.new(0.8, 0, 0.15, 0)
    inputContainer.Position = UDim2.new(0.1, 0, 0.4, 0)
    inputContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    inputContainer.BackgroundTransparency = 0.5
    inputContainer.BorderSizePixel = 0
    inputContainer.Parent = frame
    Instance.new("UICorner", inputContainer).CornerRadius = UDim.new(0, 8)
    
    local inputGlow = Instance.new("UIStroke", inputContainer)
    inputGlow.Color = Color3.fromRGB(100, 150, 255)
    inputGlow.Thickness = 2
    inputGlow.Transparency = 0.7
    
    local inputBox = Instance.new("TextBox", inputContainer)
    inputBox.Size = UDim2.new(0.9, 0, 0.8, 0)
    inputBox.Position = UDim2.new(0.05, 0, 0.1, 0)
    inputBox.BackgroundTransparency = 1
    inputBox.Font = Enum.Font.Gotham
    inputBox.PlaceholderText = "Enter Access Code"
    inputBox.Text = ""
    inputBox.TextColor3 = Color3.new(1, 1, 1)
    inputBox.TextSize = 18
    inputBox.ClearTextOnFocus = false
    inputBox.TextXAlignment = Enum.TextXAlignment.Center
    
    local button = Instance.new("TextButton", frame)
    button.Size = UDim2.new(0.6, 0, 0.15, 0)
    button.Position = UDim2.new(0.2, 0, 0.7, 0)
    button.Text = "AUTHENTICATE"
    button.Font = Enum.Font.GothamBold
    button.TextSize = 20
    button.TextColor3 = Color3.new(1, 1, 1)
    button.BackgroundColor3 = Color3.fromRGB(70, 70, 150)
    button.BorderSizePixel = 0
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)
    
    local buttonGradient = Instance.new("UIGradient", button)
    buttonGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 150, 220)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 100, 180))
    })
    
    local buttonGlow = Instance.new("UIStroke", button)
    buttonGlow.Color = Color3.fromRGB(100, 200, 255)
    buttonGlow.Thickness = 2
    buttonGlow.Transparency = 0.7
    
    local status = Instance.new("TextLabel", frame)
    status.Size = UDim2.new(0.8, 0, 0.1, 0)
    status.Position = UDim2.new(0.1, 0, 0.6, 0)
    status.BackgroundTransparency = 1
    status.Text = ""
    status.TextColor3 = Color3.fromRGB(255, 50, 50)
    status.Font = Enum.Font.GothamBold
    status.TextSize = 16
    
    local securityIndicator = Instance.new("TextLabel", frame)
    securityIndicator.Size = UDim2.new(0.8, 0, 0.1, 0)
    securityIndicator.Position = UDim2.new(0.1, 0, 0.3, 0)
    securityIndicator.BackgroundTransparency = 1
    securityIndicator.Text = `USER: {Player.Name}`
    securityIndicator.TextColor3 = Color3.fromRGB(180, 200, 255)
    securityIndicator.Font = Enum.Font.Gotham
    securityIndicator.TextSize = 16
    
    local particles = Instance.new("Frame", frame)
    particles.Size = UDim2.new(1, 0, 1, 0)
    particles.BackgroundTransparency = 1
    particles.ZIndex = 0
    
    for i = 1, 20 do
        local particle = Instance.new("Frame", particles)
        particle.Size = UDim2.new(0, 4, 0, 4)
        particle.Position = UDim2.new(math.random(), 0, math.random(), 0)
        particle.BackgroundColor3 = Color3.fromHSV(math.random(), 0.8, 1)
        particle.BackgroundTransparency = 0.7
        Instance.new("UICorner", particle).CornerRadius = UDim.new(1, 0)
        
        local tween = TweenService:Create(
            particle,
            TweenInfo.new(math.random(2, 5)), 
            {Position = UDim2.new(math.random(), 0, math.random(), 0)}
        )
        tween:Play()
        tween.Completed:Connect(function()
            tween:Play()
        end)
    end
    
    button.MouseButton1Click:Connect(function()
        if inputBox.Text == PASSWORD then
            local accessGranted, message = VerifyPlayerAccess()
            
            if accessGranted then
                status.Text = message
                status.TextColor3 = Color3.fromRGB(50, 255, 50)
                
                for i = 1, 30 do
                    local particle = Instance.new("Frame", frame)
                    particle.Size = UDim2.new(0, 10, 0, 10)
                    particle.Position = UDim2.new(0.5, -5, 0.5, -5)
                    particle.BackgroundColor3 = Color3.fromHSV(i/30, 1, 1)
                    particle.BackgroundTransparency = 0.7
                    Instance.new("UICorner", particle).CornerRadius = UDim.new(1, 0)
                    
                    local tween = TweenService:Create(
                        particle,
                        TweenInfo.new(0.5, Enum.EasingStyle.Quad), 
                        {
                            Position = UDim2.new(math.random(), 0, math.random(), 0),
                            Size = UDim2.new(0, 0, 0, 0),
                            BackgroundTransparency = 1
                        }
                    )
                    tween:Play()
                    tween.Completed:Connect(function()
                        particle:Destroy()
                    end)
                end
                
                local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local tween = TweenService:Create(frame, tweenInfo, {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.5, -225, 0.3, -175),
                    Size = UDim2.new(0, 0, 0, 0)
                })
                tween:Play()
                
                tween.Completed:Wait()
                
                State.Authenticated = true
                destroyGUI()
                
                if workspace:FindFirstChild("Monads") then
                    Start()
                end
            else
                status.Text = message
                status.TextColor3 = Color3.fromRGB(255, 50, 50)
                
                for _ = 1, 3 do
                    frame.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
                    task.wait(0.1)
                    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
                    task.wait(0.1)
                end
            end
        else
            Attempts = Attempts + 1
            status.Text = "Incorrect access code (" .. Attempts .. "/" .. MaxAttempts .. ")"
            
            local startPos = frame.Position
            for i = 1, 3 do
                frame.Position = UDim2.new(0.5, -240, 0.5, -175)
                task.wait(0.05)
                frame.Position = UDim2.new(0.5, -210, 0.5, -175)
                task.wait(0.05)
            end
            frame.Position = startPos
            
            if Attempts >= MaxAttempts then
                status.Text = "SYSTEM LOCKED"
                button.Text = "LOCKED"
                button.Active = false
                button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                buttonGradient:Destroy()
                task.wait(3)
                destroyGUI()
            end
        end
    end)
    
    inputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            button:Activate()
        end
    end)
    
    local closeButton = Instance.new("TextButton", frame)
    closeButton.Size = UDim2.new(0, 35, 0, 35)
    closeButton.Position = UDim2.new(1, -40, 0, 5)
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 20
    Instance.new("UICorner", closeButton).CornerRadius = UDim.new(1, 0)
    
    closeButton.MouseButton1Click:Connect(destroyGUI)
    
    table.insert(connections, UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Escape then
            destroyGUI()
        end
    end))
end

-- Auto-start system when Monads appear
workspace.ChildAdded:Connect(function(child)
    if child.Name == "Monads" then
        if not State.Authenticated and not State.PasswordGUI then
            CreatePasswordGUI()
        elseif State.Authenticated then
            Start()
        end
    end
end)

-- Initial check for Monads
if workspace:FindFirstChild("Monads") then
    if not State.Authenticated then
        CreatePasswordGUI()
    end
end

-- Rainbow path animation
task.spawn(function()
    while true do
        task.wait(0.1)
        if #State.Visuals.Path > 0 then
            for _, part in ipairs(State.Visuals.Path) do
                local beam = part:FindFirstChildOfClass("Beam")
                if beam then
                    beam.Color = ColorSequence.new(GetRainbowColor())
                end
            end
        end
    end
end)

-- [[ NEW: Aimlock / Aimbot Logic ]]
-- This keeps the camera locked on the pearl while maintaining the player's position
RunService.RenderStepped:Connect(function()
    if State.Active and State.CurrentTarget and State.Authenticated then
        local camera = workspace.CurrentCamera
        local targetPart = State.CurrentTarget:IsA("Model") and State.CurrentTarget.PrimaryPart or State.CurrentTarget
        
        if camera and targetPart then
            -- Create a new CFrame that keeps the current camera position
            -- but forces the rotation to look at the target part
            camera.CFrame = CFrame.new(camera.CFrame.Position, targetPart.Position)
        end
    end
end)
