local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- // SETTINGS // --
local GlobalRunning = true
local SkillDebounce = {} 
local JumpDebounce = false
local ButtonNames = {"E", "Q", "R", "T"}

local State = {
    HitboxSize = 1,
    HitboxActive = false,
    AutoPlayerActive = false,   -- Human-Like Rapid
    TerminatorActive = false,   -- Machine Mode
    AutoSkillsActive = false,
    EspActive = false,
    ChatActive = false,
    ChatMode = "Rage", 
    DraggingSlider = false
}

local MoveState = {
    LastPos = Vector3.new(0,0,0),
    StuckTimer = 0,
    Path = nil,
    Waypoints = {},
    CurrentWaypointIndex = 2,
    StrafeAngle = 0,
    ActiveTarget = nil,
    ActiveTargetChar = nil,
}

-- // PATHFINDING PARAMS // --
local PathParams = {
    AgentRadius = 2.0,
    AgentHeight = 5.0,
    AgentCanJump = true,
    AgentMaxSlope = 60.0,
    WaypointSpacing = 4.0,
    Costs = { Water = 20, Air = 10 }
}

-- // QUOTE LISTS // --
local RageQuotes = {
    "Are you okay? You seem lost.", "Do you need a tutorial?", "I can teach you how to block if you want.",
    "Don't worry, everyone starts somewhere.", "Maybe try a different game? This one seems hard for you.",
    "Its okay, lag happens to the best of us (not me though).", "Did your controller die? Unlucky.",
    "Playing on a smart fridge?", "Is your monitor turned on?", "Wifi powered by a hamster wheel?",
    "Running this on a school chromebook?", "I think your mouse is unplugged.", "Are you playing with a steering wheel?",
    "Graphics card from 1999?", "FPS: 2, Ping: 9000, Skill: 0", "Did you download more RAM yet?",
    "My cat walked across my keyboard and won.", "I was tabbed out watching YouTube.", "I'm playing with one hand eating pizza.",
    "Reaction time of a sloth.", "You move like a PowerPoint presentation.", "I've seen NPCs with better AI.",
    "Did you forget to bind your attack key?", "You missed. Again. And again.", "Airball champion.",
    "Refund the game while you still can.", "Touching grass might help your aim.", "Go outside, the graphics are better.",
    "Imagine losing to a script... oh wait.", "Fatherless behavior detected.", "Maidenless gameplay.",
    "Did your little brother take the controller?", "Rent free in your head.", "Free trial of living expired.",
    "Pressing Spacebar usually makes you jump.", "Left click to attack, just so you know.", "Dodge button is 'Q', try it sometime.",
    "Cooldowns exist, skill does not.", "You just got stat checked.", "Health bar deleted successfully.",
    "404: Skill Not Found.", "Error: Player is bad.", "Please reconnect controller.",
    "Sit.", "Stay.", "Good dog.", "Bot behavior.", "Free elo.", "Thanks for the points.", "Bank account: empty. Elo: empty.",
    "Yawn.", "Boring.", "Next.", "Too easy.", "Tutorial mode.", "Warmup bot.", "Target practice.",
    "You are the reason shampoo has instructions.", "I'd roast you but my mom said not to burn trash.",
    "You play like you have mittens on.", "Did you sneeze during that fight?", "Whiffed.",
    "Aim assist couldn't save you.", "Reported for feeding.", "Inting?", "Throwing?",
    "Spectator mode activated.", "Enjoy the grey screen.", "Respawn timer: Infinite.",
    "Delete System32 to improve aim.", "Alt F4 for hacks.", "Press Power Button to win."
}

local BrainrotQuotes = {
    "Skibidi toilet rizz in ohio.", "Fanum tax deducted from your health bar.", "Sticking out your gyatt for the rizzler.",
    "You just got mogged by a level 10 gyatt.", "Grimace shake incident 2.0.", "Only in Ohio gameplay.",
    "Average day in Miller Grove.", "Bro thinks he's the main character in skibidi wars.", "G-Man toilet approves this kill.",
    "Bye bye bye (mewing streak intact).", "Negative canthal tilt detected.", "It's over for you.", "Bro forgot to looksmax.",
    "Mogged.", "Prey eyes vs Hunter eyes.", "Jawline check failed.", "Mouth breather behavior.",
    "Erm, what the sigma?", "Blud really said 'nah i'd win'.", "Bro is not him.", "Who let this blud cook?",
    "Burnt the kitchen down.", "Zero rizz detected.", "Negative aura.", "Lost 1000 aura points.",
    "Glazing me crazy right now.", "Hop off the meat.", "Doing tricks on it.", "Pause.", "No Diddy.",
    "Bomboclaat gameplay.", "Womp womp.", "Did you pray today?", "Standing on business (you are lying down).",
    "Call John Pork.", "English or Spanish? Whoever moves is dead.", "Baby you got something in your nose.",
    "We live, we love, we lie (smurf cat).", "Metal pipe falling sound effect.", "Vine boom sound effect.",
    "Bruh sound effect #2.", "Roblox OOF.", "Windows XP shutdown noise.", "Connection terminated.",
    "Freddy Fazbear looking ahh.", "Was that the bite of 87?", "Har har har har.",
    "Skibidi bop mm dada.", "Dop dop yes yes.", "Shadow wizard money gang.", "We love casting spells.",
    "Legalize nuclear bombs.", "Swag messiah.", "Bees make honey.", "I eat rocks.", "Yummers.",
    "Lobotomy kaisen domain expansion.", "Infinite void of skill.", "Malevolent shrine of bad aim.",
    "Nah i'd lose (you said).", "Stand proud, you are weak.", "Fraud watch alert.",
    "Ipad kid coughing.", "Cocomelon subscriber.", "Subway surfers gameplay on bottom.",
    "Family guy funny moments compilation.", "Slime ASMR.", "Hydraulic press vs your skill."
}

-- // GUI SETUP // --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TitaniumMimic_V18"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local EspFolder = Instance.new("Folder")
EspFolder.Name = "ESP_Visuals"
EspFolder.Parent = ScreenGui

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 560) -- Increased size for new button
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 8)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Thickness = 2
MainStroke.Color = Color3.fromRGB(255, 140, 0) 

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner", TopBar)
TopCorner.CornerRadius = UDim.new(0, 8)

local TopCover = Instance.new("Frame", TopBar)
TopCover.Size = UDim2.new(1, 0, 0, 10)
TopCover.Position = UDim2.new(0, 0, 1, -10)
TopCover.BackgroundColor3 = TopBar.BackgroundColor3
TopCover.BorderSizePixel = 0

local Title = Instance.new("TextLabel", TopBar)
Title.Text = "TITANIUM V18: TERMINATOR"
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 16
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Text = "×"
CloseBtn.Font = Enum.Font.GothamMedium
CloseBtn.TextSize = 24
CloseBtn.TextColor3 = Color3.fromRGB(200, 60, 60)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Size = UDim2.new(0, 40, 1, 0)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)

-- Container
local Container = Instance.new("Frame", MainFrame)
Container.Size = UDim2.new(1, -20, 1, -50)
Container.Position = UDim2.new(0, 10, 0, 45)
Container.BackgroundTransparency = 1

local UIList = Instance.new("UIListLayout", Container)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 8)

-- Slider
local SliderFrame = Instance.new("Frame", Container)
SliderFrame.Size = UDim2.new(1, 0, 0, 50)
SliderFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
SliderFrame.LayoutOrder = 1
local SliderCorner = Instance.new("UICorner", SliderFrame)
SliderCorner.CornerRadius = UDim.new(0, 6)

local SliderLabel = Instance.new("TextLabel", SliderFrame)
SliderLabel.Text = "HITBOX SIZE: 1"
SliderLabel.Font = Enum.Font.GothamBold
SliderLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
SliderLabel.TextSize = 12
SliderLabel.BackgroundTransparency = 1
SliderLabel.Size = UDim2.new(1, -20, 0, 20)
SliderLabel.Position = UDim2.new(0, 10, 0, 5)
SliderLabel.TextXAlignment = Enum.TextXAlignment.Left

local SliderTrack = Instance.new("Frame", SliderFrame)
SliderTrack.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
SliderTrack.Size = UDim2.new(1, -20, 0, 6)
SliderTrack.Position = UDim2.new(0, 10, 0, 32)
SliderTrack.BorderSizePixel = 0
local TrackCorner = Instance.new("UICorner", SliderTrack)
TrackCorner.CornerRadius = UDim.new(1, 0)

local SliderKnob = Instance.new("TextButton", SliderTrack)
SliderKnob.Text = ""
SliderKnob.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
SliderKnob.Size = UDim2.new(0, 14, 0, 14)
SliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
SliderKnob.Position = UDim2.new(0, 0, 0.5, 0)
local KnobCorner = Instance.new("UICorner", SliderKnob)
KnobCorner.CornerRadius = UDim.new(1, 0)

-- Toggle Helper
local function CreateToggle(text, order, colorOverride)
    local btnFrame = Instance.new("TextButton", Container)
    btnFrame.Text = ""
    btnFrame.Size = UDim2.new(1, 0, 0, 45)
    btnFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    btnFrame.AutoButtonColor = false
    btnFrame.LayoutOrder = order
    
    local btnCorner = Instance.new("UICorner", btnFrame)
    btnCorner.CornerRadius = UDim.new(0, 6)
    
    local lbl = Instance.new("TextLabel", btnFrame)
    lbl.Text = text
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextColor3 = colorOverride or Color3.fromRGB(220, 220, 220)
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.Position = UDim2.new(0, 15, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextSize = 13
    
    local indicatorBg = Instance.new("Frame", btnFrame)
    indicatorBg.Size = UDim2.new(0, 36, 0, 18)
    indicatorBg.AnchorPoint = Vector2.new(1, 0.5)
    indicatorBg.Position = UDim2.new(1, -15, 0.5, 0)
    indicatorBg.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    local indCorner = Instance.new("UICorner", indicatorBg)
    indCorner.CornerRadius = UDim.new(1, 0)
    
    local dot = Instance.new("Frame", indicatorBg)
    dot.Size = UDim2.new(0, 14, 0, 14)
    dot.AnchorPoint = Vector2.new(0, 0.5)
    dot.Position = UDim2.new(0, 2, 0.5, 0)
    dot.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
    local dotCorner = Instance.new("UICorner", dot)
    dotCorner.CornerRadius = UDim.new(1, 0)
    
    return btnFrame, indicatorBg, dot
end

-- // SUB-OPTION GUI // --
local SubOptionsFrame = Instance.new("Frame", Container)
SubOptionsFrame.Size = UDim2.new(1, 0, 0, 45)
SubOptionsFrame.BackgroundTransparency = 1
SubOptionsFrame.LayoutOrder = 8
SubOptionsFrame.Visible = false

local UIListSub = Instance.new("UIListLayout", SubOptionsFrame)
UIListSub.FillDirection = Enum.FillDirection.Horizontal
UIListSub.SortOrder = Enum.SortOrder.LayoutOrder
UIListSub.Padding = UDim.new(0, 10)

-- Rage Mode Button
local RageModeBtn = Instance.new("TextButton", SubOptionsFrame)
RageModeBtn.Size = UDim2.new(0.5, -5, 1, 0)
RageModeBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
RageModeBtn.Text = "CREATIVE RAGE"
RageModeBtn.Font = Enum.Font.GothamBold
RageModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RageModeBtn.TextSize = 11
local RageCorner = Instance.new("UICorner", RageModeBtn)
RageCorner.CornerRadius = UDim.new(0, 6)

-- Brainrot Mode Button
local BrainrotModeBtn = Instance.new("TextButton", SubOptionsFrame)
BrainrotModeBtn.Size = UDim2.new(0.5, -5, 1, 0)
BrainrotModeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
BrainrotModeBtn.Text = "BRAINROT MODE"
BrainrotModeBtn.Font = Enum.Font.GothamBold
BrainrotModeBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
BrainrotModeBtn.TextSize = 11
local BrainCorner = Instance.new("UICorner", BrainrotModeBtn)
BrainCorner.CornerRadius = UDim.new(0, 6)

-- BUTTONS
local HitboxBtn, HitboxBg, HitboxDot = CreateToggle("Hitbox Extender", 2)
local AutoBtn, AutoBg, AutoDot = CreateToggle("Auto Bot (Human-Like)", 3)
local TermBtn, TermBg, TermDot = CreateToggle("Auto Bot (TERMINATOR)", 4, Color3.fromRGB(255, 50, 50)) -- Red Text for danger
local SkillBtn, SkillBg, SkillDot = CreateToggle("Auto Skills (Smart)", 5)
local EspBtn, EspBg, EspDot = CreateToggle("Player ESP", 6)
local ChatBtn, ChatBg, ChatDot = CreateToggle("Death Message (Toggle)", 7)

-- Info
local InfoFrame = Instance.new("Frame", Container)
InfoFrame.Size = UDim2.new(1, 0, 0, 40)
InfoFrame.BackgroundTransparency = 1
InfoFrame.LayoutOrder = 9

local StatusLabel = Instance.new("TextLabel", InfoFrame)
StatusLabel.Text = "BOT: IDLE"
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 11
StatusLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
StatusLabel.Size = UDim2.new(1, 0, 0.5, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

local DebugLabel = Instance.new("TextLabel", InfoFrame)
DebugLabel.Text = "WAITING..."
DebugLabel.Font = Enum.Font.Code
DebugLabel.TextSize = 10
DebugLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
DebugLabel.Size = UDim2.new(1, 0, 0.5, 0)
DebugLabel.Position = UDim2.new(0, 0, 0.5, 0)
DebugLabel.BackgroundTransparency = 1
DebugLabel.TextXAlignment = Enum.TextXAlignment.Left

-- // UI LOGIC // --
local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
    end
end)
TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

SliderKnob.MouseButton1Down:Connect(function() State.DraggingSlider = true end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then State.DraggingSlider = false end end)
UserInputService.InputChanged:Connect(function(input)
    if State.DraggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mPos = UserInputService:GetMouseLocation().X
        local rel = math.clamp((mPos - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
        SliderKnob.Position = UDim2.new(rel, 0, 0.5, 0)
        State.HitboxSize = 1 + (rel * 49)
        SliderLabel.Text = "HITBOX SIZE: " .. math.floor(State.HitboxSize)
    end
end)

local function ToggleAnim(state, bg, dot)
    if state then
        bg.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
        dot:TweenPosition(UDim2.new(1, -16, 0.5, 0), "Out", "Quad", 0.2, true)
        dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    else
        bg.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        dot:TweenPosition(UDim2.new(0, 2, 0.5, 0), "Out", "Quad", 0.2, true)
        dot.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
    end
end

-- Update Mode Buttons Logic
local function UpdateChatMode()
    if State.ChatMode == "Rage" then
        RageModeBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
        RageModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        BrainrotModeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        BrainrotModeBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    else
        BrainrotModeBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
        BrainrotModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        RageModeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        RageModeBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    end
end

HitboxBtn.MouseButton1Click:Connect(function()
    State.HitboxActive = not State.HitboxActive
    ToggleAnim(State.HitboxActive, HitboxBg, HitboxDot)
end)

-- RAPID (HUMAN) TOGGLE
AutoBtn.MouseButton1Click:Connect(function()
    State.AutoPlayerActive = not State.AutoPlayerActive
    
    -- Mutual Exclusion
    if State.AutoPlayerActive then
        State.TerminatorActive = false
        ToggleAnim(false, TermBg, TermDot)
    end
    
    ToggleAnim(State.AutoPlayerActive, AutoBg, AutoDot)
    MoveState.Path = nil
    MoveState.ActiveTarget = nil
end)

-- TERMINATOR TOGGLE
TermBtn.MouseButton1Click:Connect(function()
    State.TerminatorActive = not State.TerminatorActive
    
    -- Mutual Exclusion
    if State.TerminatorActive then
        State.AutoPlayerActive = false
        ToggleAnim(false, AutoBg, AutoDot)
    end
    
    ToggleAnim(State.TerminatorActive, TermBg, TermDot)
    MoveState.Path = nil
    MoveState.ActiveTarget = nil
end)

SkillBtn.MouseButton1Click:Connect(function()
    State.AutoSkillsActive = not State.AutoSkillsActive
    ToggleAnim(State.AutoSkillsActive, SkillBg, SkillDot)
end)
EspBtn.MouseButton1Click:Connect(function()
    State.EspActive = not State.EspActive
    ToggleAnim(State.EspActive, EspBg, EspDot)
    if not State.EspActive then EspFolder:ClearAllChildren() end
end)
ChatBtn.MouseButton1Click:Connect(function()
    State.ChatActive = not State.ChatActive
    ToggleAnim(State.ChatActive, ChatBg, ChatDot)
    SubOptionsFrame.Visible = State.ChatActive
end)

RageModeBtn.MouseButton1Click:Connect(function()
    State.ChatMode = "Rage"
    UpdateChatMode()
end)

BrainrotModeBtn.MouseButton1Click:Connect(function()
    State.ChatMode = "Brainrot"
    UpdateChatMode()
end)

CloseBtn.MouseButton1Click:Connect(function()
    GlobalRunning = false
    ScreenGui:Destroy()
    script:Destroy()
end)

-- // HELPER FUNCTIONS // --
local function SendChat(msg)
    if ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") and 
       ReplicatedStorage.DefaultChatSystemChatEvents:FindFirstChild("SayMessageRequest") then
        ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
    elseif TextChatService.ChatInputBarConfiguration.TargetTextChannel then
        pcall(function()
            TextChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(msg)
        end)
    end
end

-- [[ KEYBOARD JUMP FUNCTION ]] --
local function PressJump()
    if not JumpDebounce then
        JumpDebounce = true
        task.spawn(function()
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
            task.wait(0.05)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            task.wait(0.05) 
            JumpDebounce = false
        end)
    end
end

local function GetPortal()
    if workspace:FindFirstChild("Portals") and workspace.Portals:FindFirstChild("Arena Frame") then
        return workspace.Portals["Arena Frame"]:FindFirstChild("Portal")
    end
    return nil
end

local function GetBestTarget(myPos)
    local closest, dist = nil, math.huge
    local targetObj = nil
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") then
            if v.Character.Humanoid.Health > 0 then
                
                -- [[ ANTI-GHOST CHECK V2 (ALL PARTS CHECK) ]] --
                local hasVisiblePart = false
                
                for _, part in pairs(v.Character:GetChildren()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        if part.Transparency <= 0.5 then
                            hasVisiblePart = true 
                            break
                        end
                    end
                end
                
                if hasVisiblePart then
                    local d = (myPos - v.Character.HumanoidRootPart.Position).Magnitude
                    if d < dist then
                        dist = d
                        closest = v.Character.HumanoidRootPart
                        targetObj = v.Character
                    end
                end
            end
        end
    end
    return closest, targetObj
end

local function IsPathBlocked(startPos, endPos)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character}
    params.FilterType = Enum.RaycastFilterType.Exclude
    local dir = endPos - startPos
    local res = workspace:Raycast(startPos, dir, params)
    if res and res.Instance then
        if res.Instance.CanCollide and res.Instance.Transparency < 0.9 then return true end
    end
    return false
end

-- [[ OBBY / GAP CHECK ]] --
local function CheckForObstacles(root)
    local start = root.Position
    local look = root.CFrame.LookVector
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character}
    params.FilterType = Enum.RaycastFilterType.Exclude

    -- 1. Void Check (Gap)
    local gapOrigin = start + (look * 4) 
    local gapDir = Vector3.new(0, -10, 0)
    local gapResult = workspace:Raycast(gapOrigin, gapDir, params)
    if not gapResult then return true end

    -- 2. Wall Check
    local wallDir = look * 2.5
    local wallResult = workspace:Raycast(start, wallDir, params)
    if wallResult and wallResult.Instance.CanCollide then return true end

    return false
end

-- // ESP LOOP // --
task.spawn(function()
    while GlobalRunning do
        task.wait(0.05)
        if State.EspActive then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                    local espName = "ESP_" .. player.Name
                    local currentEsp = EspFolder:FindFirstChild(espName)
                    local root = player.Character.HumanoidRootPart
                    local hum = player.Character.Humanoid
                    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    local dist = myRoot and (myRoot.Position - root.Position).Magnitude or 0
                    
                    if not currentEsp then
                        local bb = Instance.new("BillboardGui")
                        bb.Name = espName
                        bb.Adornee = root
                        bb.Size = UDim2.new(0, 200, 0, 50)
                        bb.StudsOffset = Vector3.new(0, 3.5, 0)
                        bb.AlwaysOnTop = true
                        bb.Parent = EspFolder
                        
                        local txt = Instance.new("TextLabel")
                        txt.Name = "Info"
                        txt.Size = UDim2.new(1, 0, 1, 0)
                        txt.BackgroundTransparency = 1
                        txt.TextStrokeTransparency = 0
                        txt.Font = Enum.Font.GothamBold
                        txt.TextSize = 14
                        txt.Parent = bb
                    else
                        local txt = currentEsp:FindFirstChild("Info")
                        if txt then
                            txt.Text = string.format("%s\nHP: %d | Dist: %d", player.Name, math.floor(hum.Health), math.floor(dist))
                            if hum.Health > 70 then txt.TextColor3 = Color3.fromRGB(0, 255, 100)
                            elseif hum.Health > 30 then txt.TextColor3 = Color3.fromRGB(255, 200, 0)
                            else txt.TextColor3 = Color3.fromRGB(255, 0, 0) end
                        end
                    end
                else
                    local deadEsp = EspFolder:FindFirstChild("ESP_" .. player.Name)
                    if deadEsp then deadEsp:Destroy() end
                end
            end
        end
    end
end)

-- // CAM LOCK // --
RunService.RenderStepped:Connect(function()
    if (State.AutoPlayerActive or State.TerminatorActive) and MoveState.ActiveTarget then
        local targetPart = MoveState.ActiveTarget
        if targetPart and targetPart.Parent then
            local hum = targetPart.Parent:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local camPos = Camera.CFrame.Position
                Camera.CFrame = CFrame.new(camPos, targetPart.Position)
            else
                MoveState.ActiveTarget = nil
            end
        end
    end
end)

-- // MAIN MOVEMENT LOOP // --
task.spawn(function()
    while GlobalRunning do
        task.wait(0.03) 
        
        -- Check if ANY bot mode is active
        if State.AutoPlayerActive or State.TerminatorActive then
            local success, err = pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                local hum = char:FindFirstChild("Humanoid")
                local root = char:FindFirstChild("HumanoidRootPart")
                if not hum or not root then return end
                
                -- [[ COMMON LOGIC: Anti-Sit & Obby ]] --
                if hum.Sit then
                    hum.Sit = false
                    PressJump()
                end
                if CheckForObstacles(root) then
                    PressJump()
                end

                local myPos = root.Position
                local portal = GetPortal()
                local targetPos = nil
                local mode = "None"
                local targetCharacter = nil
                
                -- 1. Portal Check
                if portal and (myPos - portal.Position).Magnitude < 50 then
                    targetPos = portal.Position
                    mode = "Portal"
                    MoveState.ActiveTarget = nil
                    MoveState.ActiveTargetChar = nil
                    StatusLabel.Text = "BOT: ENTERING PORTAL"
                    StatusLabel.TextColor3 = Color3.fromRGB(50, 255, 100)
                else
                    local enemyPart, enemyChar = GetBestTarget(myPos)

                    -- Death Chat
                    if State.ChatActive and MoveState.ActiveTargetChar and MoveState.ActiveTargetChar ~= enemyChar then
                         local oldHum = MoveState.ActiveTargetChar:FindFirstChild("Humanoid")
                         if oldHum and oldHum.Health <= 0 then
                             local selectedQuote = "gg"
                             if State.ChatMode == "Rage" then selectedQuote = RageQuotes[math.random(1, #RageQuotes)]
                             else selectedQuote = BrainrotQuotes[math.random(1, #BrainrotQuotes)] end
                             SendChat(selectedQuote)
                             MoveState.ActiveTargetChar = nil 
                         end
                    end

                    if enemyPart then
                        -- Prediction: Tighter for Rapid (0.13s), Ultra-Tight for Terminator (0.05s)
                        local predTime = State.TerminatorActive and 0.05 or 0.13
                        targetPos = enemyPart.Position + (enemyPart.AssemblyLinearVelocity * predTime)
                        
                        mode = "Enemy"
                        MoveState.ActiveTarget = enemyPart
                        MoveState.ActiveTargetChar = enemyChar
                        targetCharacter = enemyChar 
                        StatusLabel.Text = State.TerminatorActive and "TERMINATOR: KILLING" or "BOT: LOCKED ON"
                        StatusLabel.TextColor3 = State.TerminatorActive and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 50, 50)
                    else
                        MoveState.ActiveTarget = nil
                        StatusLabel.Text = "BOT: SCANNING..."
                        StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 50)
                    end
                end
                
                if targetPos then
                    -- Anti-Stuck
                    if (myPos - MoveState.LastPos).Magnitude < 0.3 then
                        MoveState.StuckTimer = MoveState.StuckTimer + 0.03
                    else
                        MoveState.StuckTimer = 0
                    end
                    MoveState.LastPos = myPos
                    
                    if MoveState.StuckTimer > 0.6 then
                        PressJump()
                        hum:MoveTo(myPos + Vector3.new(math.random(-10,10),0,math.random(-10,10)))
                        MoveState.StuckTimer = 0
                        task.wait(0.2)
                    end

                    local dist = (myPos - targetPos).Magnitude
                    local blocked = IsPathBlocked(myPos, targetPos)

                    -- ==========================================
                    --        TERMINATOR MODE LOGIC (NEW)
                    -- ==========================================
                    if State.TerminatorActive then
                        -- NO Human smoothing, NO hesitation. 
                        -- Calculate Vector to put Right Hitbox into Enemy.
                        
                        local toEnemy = (targetPos - myPos).Unit
                        local rightVector = toEnemy:Cross(Vector3.new(0,1,0))
                        -- Hard Left offset (-1.8 studs) to align Right Hand
                        local offset = rightVector * -1.8 
                        local killSpot = targetPos + offset
                        
                        -- Direct Movement (Spam MoveTo for responsiveness)
                        hum:MoveTo(killSpot)
                        
                        -- Terminator Jumping:
                        -- 1. If enemy jumps, we jump instantly.
                        -- 2. If we are close (< 15 studs), we bunny hop to confuse.
                        if targetCharacter then
                            local tHum = targetCharacter:FindFirstChild("Humanoid")
                            if (tHum and tHum.Jump) or dist < 15 then
                                PressJump()
                            end
                        end
                        
                    -- ==========================================
                    --        RAPID (HUMAN) MODE LOGIC
                    -- ==========================================
                    else 
                        -- Jump Logic
                        if mode == "Enemy" and dist <= 25 then PressJump() end
                        if mode == "Enemy" and dist > 25 and targetCharacter then
                            local targetHum = targetCharacter:FindFirstChild("Humanoid")
                            if targetHum and targetHum.Jump then PressJump() end
                        end

                        -- Movement Logic
                        if mode == "Portal" then
                            hum:MoveTo(targetPos)
                        elseif mode == "Enemy" and dist < 15 and not blocked then
                            -- Human strafe with sine wave
                            local toEnemy = (targetPos - myPos).Unit
                            local rightVector = toEnemy:Cross(Vector3.new(0,1,0))
                            local offset = rightVector * -1.8 
                            local adjustedTarget = targetPos + offset

                            MoveState.StrafeAngle = MoveState.StrafeAngle + 0.1
                            local offsetX = math.cos(MoveState.StrafeAngle) * 4
                            local offsetZ = math.sin(MoveState.StrafeAngle) * 4
                            hum:MoveTo(adjustedTarget + Vector3.new(offsetX, 0, offsetZ))
                            
                        elseif (dist < 20 and not blocked) then
                            hum:MoveTo(targetPos)
                        else
                            -- Pathfinding
                            if not MoveState.Path or (MoveState.Waypoints[#MoveState.Waypoints] and (MoveState.Waypoints[#MoveState.Waypoints].Position - targetPos).Magnitude > 8) then
                                local path = PathfindingService:CreatePath(PathParams)
                                local pathTarget = targetPos
                                if mode == "Enemy" then
                                    local toTarget = (targetPos - myPos).Unit
                                    local right = toTarget:Cross(Vector3.new(0,1,0))
                                    pathTarget = targetPos + (right * -1.5) 
                                end
                                path:ComputeAsync(myPos, pathTarget)
                                if path.Status == Enum.PathStatus.Success then
                                    MoveState.Path = path
                                    MoveState.Waypoints = path:GetWaypoints()
                                    MoveState.CurrentWaypointIndex = 2
                                else
                                    hum:MoveTo(targetPos)
                                end
                            end
                            if MoveState.Waypoints and MoveState.CurrentWaypointIndex <= #MoveState.Waypoints then
                                local wp = MoveState.Waypoints[MoveState.CurrentWaypointIndex]
                                if wp.Action == Enum.PathWaypointAction.Jump then PressJump() end
                                hum:MoveTo(wp.Position)
                                if (myPos - wp.Position).Magnitude < 4 then
                                    MoveState.CurrentWaypointIndex = MoveState.CurrentWaypointIndex + 1
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- // SKILL LOOP // --
task.spawn(function()
    while GlobalRunning do
        task.wait(0.2)
        if State.AutoSkillsActive then
            -- [[ RANGE CHECK: 50 STUDS ]] --
            local canCast = false
            if MoveState.ActiveTarget and LocalPlayer.Character then
                local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local d = (root.Position - MoveState.ActiveTarget.Position).Magnitude
                    if d <= 50 then canCast = true end
                end
            end

            if canCast then
                local AbilityGui = nil
                if LocalPlayer.PlayerGui:FindFirstChild("Ability Buttons") then
                    AbilityGui = LocalPlayer.PlayerGui["Ability Buttons"]
                else
                    for _, v in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
                        if v.Name == "Ability Buttons" then AbilityGui = v; break end
                    end
                end
                
                if AbilityGui then
                    local debugText = ""
                    for _, key in pairs(ButtonNames) do
                        local btn = AbilityGui:FindFirstChild(key)
                        if btn and btn.Visible then
                            local cdFrame = btn:FindFirstChild("Cooldown")
                            if cdFrame then
                                local scale = cdFrame.Size.X.Scale
                                if scale <= 0.05 then
                                    debugText = debugText .. key.." "
                                    if not SkillDebounce[key] or (tick() - SkillDebounce[key] > 1) then
                                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode[key], false, game)
                                        task.wait(0.05) 
                                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode[key], false, game)
                                        SkillDebounce[key] = tick()
                                    end
                                end
                            end
                        end
                    end
                    DebugLabel.Text = "CASTING: " .. debugText
                    DebugLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
                else
                    DebugLabel.Text = "ERR: GUI MISSING"
                    DebugLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                end
            else
                DebugLabel.Text = "TARGET TOO FAR"
                DebugLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
            end
        else
            DebugLabel.Text = "SKILLS: OFF"
            DebugLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
        end
    end
end)

-- // HITBOX // --
task.spawn(function()
    while GlobalRunning do
        task.wait()
        if State.HitboxActive and LocalPlayer.Character then
            local hb = LocalPlayer.Character:FindFirstChild("Hitbox")
            if hb then
                hb.Size = Vector3.new(State.HitboxSize, State.HitboxSize, State.HitboxSize)
                hb.CanCollide = false
                hb.Transparency = 0.6
            end
        end
    end
end)

-- // CLICKER // --
task.spawn(function()
    while GlobalRunning do
        task.wait(0.15)
        if (State.AutoPlayerActive or State.TerminatorActive) and MoveState.ActiveTarget then
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local dist = (root.Position - MoveState.ActiveTarget.Position).Magnitude
                if dist <= 30 then
                    local c = Camera.ViewportSize / 2
                    VirtualInputManager:SendMouseButtonEvent(c.X, c.Y, 0, true, game, 1)
                    VirtualInputManager:SendMouseButtonEvent(c.X, c.Y, 0, false, game, 1)
                end
            end
        end
    end
end)

-- // TIMEOUT KILL SWITCH // --
task.spawn(function()
    local LastCloseTime = tick()
    while GlobalRunning do
        task.wait(1) 
        if State.AutoPlayerActive or State.TerminatorActive then 
            local character = LocalPlayer.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            local hum = character and character:FindFirstChild("Humanoid")
            
            if root and hum and hum.Health > 0 then
                local isCloseToAnyone = false
                for _, v in pairs(Players:GetPlayers()) do
                    if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                        local enemyHum = v.Character:FindFirstChild("Humanoid")
                        if enemyHum and enemyHum.Health > 0 then
                            local dist = (root.Position - v.Character.HumanoidRootPart.Position).Magnitude
                            if dist <= 25 then
                                isCloseToAnyone = true
                                break 
                            end
                        end
                    end
                end
                
                if isCloseToAnyone then
                    LastCloseTime = tick() 
                else
                    local timeSince = tick() - LastCloseTime
                    if timeSince > 10 then
                        DebugLabel.Text = "RESET IN: " .. math.ceil(15 - timeSince)
                        DebugLabel.TextColor3 = Color3.fromRGB(255, 100, 0)
                    end
                    if timeSince >= 15 then
                        StatusLabel.Text = "STUCK: RESETTING..."
                        hum.Health = 0
                        LastCloseTime = tick() 
                    end
                end
            else
                LastCloseTime = tick()
            end
        else
            LastCloseTime = tick()
        end
    end
end)

-- // NAME TAG REMOVER // --
task.spawn(function()
    while GlobalRunning do
        task.wait(1)
        pcall(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") then
                local tag = LocalPlayer.Character.Head:FindFirstChild("Name Tag")
                if tag then tag:Destroy() end
            end
        end)
    end
end)
