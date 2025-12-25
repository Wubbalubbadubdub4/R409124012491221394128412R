-- LocalScript in StarterPlayerScripts
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mouse = player:GetMouse()

-- Create main GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlyControlGUI_Fixed"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- OPEN BUTTON (Visible when menu is closed)
local openButton = Instance.new("TextButton")
openButton.Name = "OpenMenuButton"
openButton.Size = UDim2.new(0, 100, 0, 40)
openButton.Position = UDim2.new(0, 10, 0.5, 0)
openButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
openButton.Text = "OPEN MENU"
openButton.TextColor3 = Color3.fromRGB(255, 255, 255)
openButton.Font = Enum.Font.GothamBold
openButton.TextSize = 14
openButton.Visible = false
openButton.Parent = screenGui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(0, 8)
openCorner.Parent = openButton

-- Main container frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 350, 0, 780)
mainFrame.Position = UDim2.new(0.02, 0, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true

-- DRAGGABLE GUI LOGIC
local dragging
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Modern gradient effect
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 40))
})
gradient.Rotation = 45
gradient.Parent = mainFrame

-- Corner radius
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 15)
corner.Parent = mainFrame

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 15)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -50, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "MOVEMENT SYSTEM"
titleLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- CLOSE BUTTON
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0.5, -15)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 14
closeButton.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeButton

-- Content container
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -20, 1, -55)
contentFrame.Position = UDim2.new(0, 10, 0, 50)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Status indicator
local statusContainer = Instance.new("Frame")
statusContainer.Name = "StatusContainer"
statusContainer.Size = UDim2.new(1, 0, 0, 60)
statusContainer.Position = UDim2.new(0, 0, 0, 0)
statusContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
statusContainer.BorderSizePixel = 0

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 10)
statusCorner.Parent = statusContainer

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(0.5, -5, 0.5, 0)
statusLabel.Position = UDim2.new(0, 10, 0, 5)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "MOVEMENT STATUS:"
statusLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
statusLabel.TextSize = 14
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = statusContainer

local statusValue = Instance.new("TextLabel")
statusValue.Name = "StatusValue"
statusValue.Size = UDim2.new(0.5, -5, 0.5, 0)
statusValue.Position = UDim2.new(0.5, 0, 0, 5)
statusValue.BackgroundTransparency = 1
statusValue.Text = "INACTIVE"
statusValue.TextColor3 = Color3.fromRGB(255, 80, 80)
statusValue.TextSize = 14
statusValue.Font = Enum.Font.GothamBold
statusValue.TextXAlignment = Enum.TextXAlignment.Right
statusValue.Parent = statusContainer

local statusSubLabel = Instance.new("TextLabel")
statusSubLabel.Name = "StatusSubLabel"
statusSubLabel.Size = UDim2.new(1, -20, 0.5, 0)
statusSubLabel.Position = UDim2.new(0, 10, 0.5, 0)
statusSubLabel.BackgroundTransparency = 1
statusSubLabel.Text = "Active: Moving | Inactive: Idle | Dodge: Auto-Evading"
statusSubLabel.TextColor3 = Color3.fromRGB(120, 120, 140)
statusSubLabel.TextSize = 11
statusSubLabel.Font = Enum.Font.Gotham
statusSubLabel.TextXAlignment = Enum.TextXAlignment.Left
statusSubLabel.Parent = statusContainer

statusContainer.Parent = contentFrame

-- Speed control section
local speedContainer = Instance.new("Frame")
speedContainer.Name = "SpeedContainer"
speedContainer.Size = UDim2.new(1, 0, 0, 70)
speedContainer.Position = UDim2.new(0, 0, 0, 70)
speedContainer.BackgroundTransparency = 1
speedContainer.Parent = contentFrame

local speedHeader = Instance.new("TextLabel")
speedHeader.Name = "SpeedHeader"
speedHeader.Size = UDim2.new(1, 0, 0, 25)
speedHeader.Position = UDim2.new(0, 0, 0, 0)
speedHeader.BackgroundTransparency = 1
speedHeader.Text = "SPEED CONTROL"
speedHeader.TextColor3 = Color3.fromRGB(180, 180, 200)
speedHeader.TextSize = 14
speedHeader.Font = Enum.Font.GothamBold
speedHeader.TextXAlignment = Enum.TextXAlignment.Left
speedHeader.Parent = speedContainer

local speedInputBox = Instance.new("TextBox")
speedInputBox.Name = "SpeedInput"
speedInputBox.Size = UDim2.new(1, 0, 0, 35)
speedInputBox.Position = UDim2.new(0, 0, 0, 25)
speedInputBox.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
speedInputBox.Text = ""
speedInputBox.PlaceholderText = "Max speed: 100"
speedInputBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
speedInputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedInputBox.TextSize = 14
speedInputBox.Font = Enum.Font.Gotham
speedInputBox.Parent = speedContainer

local speedBoxCorner = Instance.new("UICorner")
speedBoxCorner.CornerRadius = UDim.new(0, 8)
speedBoxCorner.Parent = speedInputBox

-- Hotkey section
local hotkeyContainer = Instance.new("Frame")
hotkeyContainer.Name = "HotkeyContainer"
hotkeyContainer.Size = UDim2.new(1, 0, 0, 60)
hotkeyContainer.Position = UDim2.new(0, 0, 0, 150)
hotkeyContainer.BackgroundTransparency = 1
hotkeyContainer.Parent = contentFrame

local hotkeyHeader = Instance.new("TextLabel")
hotkeyHeader.Name = "HotkeyHeader"
hotkeyHeader.Size = UDim2.new(1, 0, 0, 25)
hotkeyHeader.Position = UDim2.new(0, 0, 0, 0)
hotkeyHeader.BackgroundTransparency = 1
hotkeyHeader.Text = "CONTROL HOTKEY"
hotkeyHeader.TextColor3 = Color3.fromRGB(180, 180, 200)
hotkeyHeader.TextSize = 14
hotkeyHeader.Font = Enum.Font.GothamBold
hotkeyHeader.TextXAlignment = Enum.TextXAlignment.Left
hotkeyHeader.Parent = hotkeyContainer

local hotkeyButtonContainer = Instance.new("Frame")
hotkeyButtonContainer.Name = "HotkeyButtonContainer"
hotkeyButtonContainer.Size = UDim2.new(1, 0, 0, 35)
hotkeyButtonContainer.Position = UDim2.new(0, 0, 0, 25)
hotkeyButtonContainer.BackgroundTransparency = 1

local hotkeyLabel = Instance.new("TextLabel")
hotkeyLabel.Name = "HotkeyLabel"
hotkeyLabel.Size = UDim2.new(0.5, -5, 1, 0)
hotkeyLabel.Position = UDim2.new(0, 0, 0, 0)
hotkeyLabel.BackgroundTransparency = 1
hotkeyLabel.Text = "Movement Hotkey:"
hotkeyLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
hotkeyLabel.TextSize = 13
hotkeyLabel.Font = Enum.Font.Gotham
hotkeyLabel.TextXAlignment = Enum.TextXAlignment.Left
hotkeyLabel.Parent = hotkeyButtonContainer

local hotkeyButton = Instance.new("TextButton")
hotkeyButton.Name = "HotkeyButton"
hotkeyButton.Size = UDim2.new(0.5, -5, 1, 0)
hotkeyButton.Position = UDim2.new(0.5, 0, 0, 0)
hotkeyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
hotkeyButton.Text = "E"
hotkeyButton.TextColor3 = Color3.fromRGB(220, 220, 255)
hotkeyButton.TextSize = 14
hotkeyButton.Font = Enum.Font.GothamBold

local hotkeyCorner = Instance.new("UICorner")
hotkeyCorner.CornerRadius = UDim.new(0, 8)
hotkeyCorner.Parent = hotkeyButton

hotkeyButton.Parent = hotkeyButtonContainer
hotkeyButtonContainer.Parent = hotkeyContainer

-- Auto-Track section
local trackContainer = Instance.new("Frame")
trackContainer.Name = "TrackContainer"
trackContainer.Size = UDim2.new(1, 0, 0, 90)
trackContainer.Position = UDim2.new(0, 0, 0, 220)
trackContainer.BackgroundTransparency = 1
trackContainer.Parent = contentFrame

local trackHeader = Instance.new("TextLabel")
trackHeader.Name = "TrackHeader"
trackHeader.Size = UDim2.new(1, 0, 0, 25)
trackHeader.Position = UDim2.new(0, 0, 0, 0)
trackHeader.BackgroundTransparency = 1
trackHeader.Text = "AUTO-TRACK SYSTEM"
trackHeader.TextColor3 = Color3.fromRGB(180, 180, 200)
trackHeader.TextSize = 14
trackHeader.Font = Enum.Font.GothamBold
trackHeader.TextXAlignment = Enum.TextXAlignment.Left
trackHeader.Parent = trackContainer

local trackStatusContainer = Instance.new("Frame")
trackStatusContainer.Name = "TrackStatusContainer"
trackStatusContainer.Size = UDim2.new(1, 0, 0, 25)
trackStatusContainer.Position = UDim2.new(0, 0, 0, 25)
trackStatusContainer.BackgroundTransparency = 1

local trackLabel = Instance.new("TextLabel")
trackLabel.Name = "TrackLabel"
trackLabel.Size = UDim2.new(0.5, -5, 1, 0)
trackLabel.Position = UDim2.new(0, 0, 0, 0)
trackLabel.BackgroundTransparency = 1
trackLabel.Text = "Auto-Track:"
trackLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
trackLabel.TextSize = 13
trackLabel.Font = Enum.Font.Gotham
trackLabel.TextXAlignment = Enum.TextXAlignment.Left
trackLabel.Parent = trackStatusContainer

local trackButton = Instance.new("TextButton")
trackButton.Name = "TrackButton"
trackButton.Size = UDim2.new(0.5, -5, 1, 0)
trackButton.Position = UDim2.new(0.5, 0, 0, 0)
trackButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
trackButton.Text = "OFF"
trackButton.TextColor3 = Color3.fromRGB(255, 200, 200)
trackButton.TextSize = 14
trackButton.Font = Enum.Font.GothamBold

local trackCorner = Instance.new("UICorner")
trackCorner.CornerRadius = UDim.new(0, 8)
trackCorner.Parent = trackButton

trackButton.Parent = trackStatusContainer
trackStatusContainer.Parent = trackContainer

local trackStatus = Instance.new("TextLabel")
trackStatus.Name = "TrackStatus"
trackStatus.Size = UDim2.new(1, 0, 0, 20)
trackStatus.Position = UDim2.new(0, 0, 0, 55)
trackStatus.BackgroundTransparency = 1
trackStatus.Text = "Cancels if target is >20 studs higher/lower than you"
trackStatus.TextColor3 = Color3.fromRGB(120, 120, 140)
trackStatus.TextSize = 11
trackStatus.Font = Enum.Font.Gotham
trackStatus.TextXAlignment = Enum.TextXAlignment.Left
trackStatus.Parent = trackContainer

-- ESP section
local espContainer = Instance.new("Frame")
espContainer.Name = "ESPContainer"
espContainer.Size = UDim2.new(1, 0, 0, 90)
espContainer.Position = UDim2.new(0, 0, 0, 320)
espContainer.BackgroundTransparency = 1
espContainer.Parent = contentFrame

local espHeader = Instance.new("TextLabel")
espHeader.Name = "ESPHeader"
espHeader.Size = UDim2.new(1, 0, 0, 25)
espHeader.Position = UDim2.new(0, 0, 0, 0)
espHeader.BackgroundTransparency = 1
espHeader.Text = "ESP SYSTEM (BOX + NAME)"
espHeader.TextColor3 = Color3.fromRGB(180, 180, 200)
espHeader.TextSize = 14
espHeader.Font = Enum.Font.GothamBold
espHeader.TextXAlignment = Enum.TextXAlignment.Left
espHeader.Parent = espContainer

local espStatusContainer = Instance.new("Frame")
espStatusContainer.Name = "ESPStatusContainer"
espStatusContainer.Size = UDim2.new(1, 0, 0, 25)
espStatusContainer.Position = UDim2.new(0, 0, 0, 25)
espStatusContainer.BackgroundTransparency = 1

local espLabel = Instance.new("TextLabel")
espLabel.Name = "ESPLabel"
espLabel.Size = UDim2.new(0.5, -5, 1, 0)
espLabel.Position = UDim2.new(0, 0, 0, 0)
espLabel.BackgroundTransparency = 1
espLabel.Text = "Player ESP:"
espLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
espLabel.TextSize = 13
espLabel.Font = Enum.Font.Gotham
espLabel.TextXAlignment = Enum.TextXAlignment.Left
espLabel.Parent = espStatusContainer

local espButton = Instance.new("TextButton")
espButton.Name = "ESPButton"
espButton.Size = UDim2.new(0.5, -5, 1, 0)
espButton.Position = UDim2.new(0.5, 0, 0, 0)
espButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
espButton.Text = "OFF"
espButton.TextColor3 = Color3.fromRGB(255, 200, 200)
espButton.TextSize = 14
espButton.Font = Enum.Font.GothamBold

local espCorner = Instance.new("UICorner")
espCorner.CornerRadius = UDim.new(0, 8)
espCorner.Parent = espButton

espButton.Parent = espStatusContainer
espStatusContainer.Parent = espContainer

local espStatus = Instance.new("TextLabel")
espStatus.Name = "ESPStatus"
espStatus.Size = UDim2.new(1, 0, 0, 20)
espStatus.Position = UDim2.new(0, 0, 0, 55)
espStatus.BackgroundTransparency = 1
espStatus.Text = "Shows red box and name above players"
espStatus.TextColor3 = Color3.fromRGB(120, 120, 140)
espStatus.TextSize = 11
espStatus.Font = Enum.Font.Gotham
espStatus.TextXAlignment = Enum.TextXAlignment.Left
espStatus.Parent = espContainer

-- MOBILE FLY section
local mobileContainer = Instance.new("Frame")
mobileContainer.Name = "MobileContainer"
mobileContainer.Size = UDim2.new(1, 0, 0, 90)
mobileContainer.Position = UDim2.new(0, 0, 0, 420)
mobileContainer.BackgroundTransparency = 1
mobileContainer.Parent = contentFrame

local mobileHeader = Instance.new("TextLabel")
mobileHeader.Name = "MobileHeader"
mobileHeader.Size = UDim2.new(1, 0, 0, 25)
mobileHeader.Position = UDim2.new(0, 0, 0, 0)
mobileHeader.BackgroundTransparency = 1
mobileHeader.Text = "MOBILE FLY"
mobileHeader.TextColor3 = Color3.fromRGB(180, 180, 200)
mobileHeader.TextSize = 14
mobileHeader.Font = Enum.Font.GothamBold
mobileHeader.TextXAlignment = Enum.TextXAlignment.Left
mobileHeader.Parent = mobileContainer

local mobileStatusContainer = Instance.new("Frame")
mobileStatusContainer.Name = "MobileStatusContainer"
mobileStatusContainer.Size = UDim2.new(1, 0, 0, 25)
mobileStatusContainer.Position = UDim2.new(0, 0, 0, 25)
mobileStatusContainer.BackgroundTransparency = 1

local mobileLabel = Instance.new("TextLabel")
mobileLabel.Name = "MobileLabel"
mobileLabel.Size = UDim2.new(0.5, -5, 1, 0)
mobileLabel.Position = UDim2.new(0, 0, 0, 0)
mobileLabel.BackgroundTransparency = 1
mobileLabel.Text = "Hold to Fly:"
mobileLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
mobileLabel.TextSize = 13
mobileLabel.Font = Enum.Font.Gotham
mobileLabel.TextXAlignment = Enum.TextXAlignment.Left
mobileLabel.Parent = mobileStatusContainer

local mobileButton = Instance.new("TextButton")
mobileButton.Name = "MobileButton"
mobileButton.Size = UDim2.new(0.5, -5, 1, 0)
mobileButton.Position = UDim2.new(0.5, 0, 0, 0)
mobileButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
mobileButton.Text = "OFF"
mobileButton.TextColor3 = Color3.fromRGB(255, 200, 200)
mobileButton.TextSize = 14
mobileButton.Font = Enum.Font.GothamBold

local mobileCorner = Instance.new("UICorner")
mobileCorner.CornerRadius = UDim.new(0, 8)
mobileCorner.Parent = mobileButton

mobileButton.Parent = mobileStatusContainer
mobileStatusContainer.Parent = mobileContainer

local mobileStatus = Instance.new("TextLabel")
mobileStatus.Name = "MobileStatus"
mobileStatus.Size = UDim2.new(1, 0, 0, 20)
mobileStatus.Position = UDim2.new(0, 0, 0, 55)
mobileStatus.BackgroundTransparency = 1
mobileStatus.Text = "Hold screen/mouse to fly forward with Camera"
mobileStatus.TextColor3 = Color3.fromRGB(120, 120, 140)
mobileStatus.TextSize = 11
mobileStatus.Font = Enum.Font.Gotham
mobileStatus.TextXAlignment = Enum.TextXAlignment.Left
mobileStatus.Parent = mobileContainer

-- VIP BYPASS SECTION
local vipContainer = Instance.new("Frame")
vipContainer.Name = "VipContainer"
vipContainer.Size = UDim2.new(1, 0, 0, 90)
vipContainer.Position = UDim2.new(0, 0, 0, 520)
vipContainer.BackgroundTransparency = 1
vipContainer.Parent = contentFrame

local vipHeader = Instance.new("TextLabel")
vipHeader.Name = "VipHeader"
vipHeader.Size = UDim2.new(1, 0, 0, 25)
vipHeader.Position = UDim2.new(0, 0, 0, 0)
vipHeader.BackgroundTransparency = 1
vipHeader.Text = "VIP BYPASS"
vipHeader.TextColor3 = Color3.fromRGB(255, 215, 0)
vipHeader.TextSize = 14
vipHeader.Font = Enum.Font.GothamBold
vipHeader.TextXAlignment = Enum.TextXAlignment.Left
vipHeader.Parent = vipContainer

local vipStatusContainer = Instance.new("Frame")
vipStatusContainer.Name = "VipStatusContainer"
vipStatusContainer.Size = UDim2.new(1, 0, 0, 25)
vipStatusContainer.Position = UDim2.new(0, 0, 0, 25)
vipStatusContainer.BackgroundTransparency = 1

local vipLabel = Instance.new("TextLabel")
vipLabel.Name = "VipLabel"
vipLabel.Size = UDim2.new(0.5, -5, 1, 0)
vipLabel.Position = UDim2.new(0, 0, 0, 0)
vipLabel.BackgroundTransparency = 1
vipLabel.Text = "Bypass Mode:"
vipLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
vipLabel.TextSize = 13
vipLabel.Font = Enum.Font.Gotham
vipLabel.TextXAlignment = Enum.TextXAlignment.Left
vipLabel.Parent = vipStatusContainer

local vipButton = Instance.new("TextButton")
vipButton.Name = "VipButton"
vipButton.Size = UDim2.new(0.5, -5, 1, 0)
vipButton.Position = UDim2.new(0.5, 0, 0, 0)
vipButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
vipButton.Text = "OFF"
vipButton.TextColor3 = Color3.fromRGB(255, 200, 200)
vipButton.TextSize = 14
vipButton.Font = Enum.Font.GothamBold

local vipCorner = Instance.new("UICorner")
vipCorner.CornerRadius = UDim.new(0, 8)
vipCorner.Parent = vipButton

vipButton.Parent = vipStatusContainer
vipStatusContainer.Parent = vipContainer

local vipStatus = Instance.new("TextLabel")
vipStatus.Name = "VipStatus"
vipStatus.Size = UDim2.new(1, 0, 0, 20)
vipStatus.Position = UDim2.new(0, 0, 0, 55)
vipStatus.BackgroundTransparency = 1
vipStatus.Text = "Glitches through walls using velocity spin"
vipStatus.TextColor3 = Color3.fromRGB(120, 120, 140)
vipStatus.TextSize = 11
vipStatus.Font = Enum.Font.Gotham
vipStatus.TextXAlignment = Enum.TextXAlignment.Left
vipStatus.Parent = vipContainer

-- AUTO DODGE SECTION
local dodgeContainer = Instance.new("Frame")
dodgeContainer.Name = "DodgeContainer"
dodgeContainer.Size = UDim2.new(1, 0, 0, 130) -- Increased size for sub-options
dodgeContainer.Position = UDim2.new(0, 0, 0, 620)
dodgeContainer.BackgroundTransparency = 1
dodgeContainer.Parent = contentFrame

local dodgeHeader = Instance.new("TextLabel")
dodgeHeader.Name = "DodgeHeader"
dodgeHeader.Size = UDim2.new(1, 0, 0, 25)
dodgeHeader.Position = UDim2.new(0, 0, 0, 0)
dodgeHeader.BackgroundTransparency = 1
dodgeHeader.Text = "AUTO DODGE"
dodgeHeader.TextColor3 = Color3.fromRGB(255, 140, 0) -- Orange color
dodgeHeader.TextSize = 14
dodgeHeader.Font = Enum.Font.GothamBold
dodgeHeader.TextXAlignment = Enum.TextXAlignment.Left
dodgeHeader.Parent = dodgeContainer

local dodgeStatusContainer = Instance.new("Frame")
dodgeStatusContainer.Name = "DodgeStatusContainer"
dodgeStatusContainer.Size = UDim2.new(1, 0, 0, 25)
dodgeStatusContainer.Position = UDim2.new(0, 0, 0, 25)
dodgeStatusContainer.BackgroundTransparency = 1

local dodgeLabel = Instance.new("TextLabel")
dodgeLabel.Name = "DodgeLabel"
dodgeLabel.Size = UDim2.new(0.5, -5, 1, 0)
dodgeLabel.Position = UDim2.new(0, 0, 0, 0)
dodgeLabel.BackgroundTransparency = 1
dodgeLabel.Text = "Enable Dodge:"
dodgeLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
dodgeLabel.TextSize = 13
dodgeLabel.Font = Enum.Font.Gotham
dodgeLabel.TextXAlignment = Enum.TextXAlignment.Left
dodgeLabel.Parent = dodgeStatusContainer

local dodgeButton = Instance.new("TextButton")
dodgeButton.Name = "DodgeButton"
dodgeButton.Size = UDim2.new(0.5, -5, 1, 0)
dodgeButton.Position = UDim2.new(0.5, 0, 0, 0)
dodgeButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
dodgeButton.Text = "OFF"
dodgeButton.TextColor3 = Color3.fromRGB(255, 200, 200)
dodgeButton.TextSize = 14
dodgeButton.Font = Enum.Font.GothamBold

local dodgeCorner = Instance.new("UICorner")
dodgeCorner.CornerRadius = UDim.new(0, 8)
dodgeCorner.Parent = dodgeButton

dodgeButton.Parent = dodgeStatusContainer
dodgeStatusContainer.Parent = dodgeContainer

-- DODGE SUB-OPTIONS CONTAINER
local dodgeOptionsFrame = Instance.new("Frame")
dodgeOptionsFrame.Name = "DodgeOptionsFrame"
dodgeOptionsFrame.Size = UDim2.new(1, 0, 0, 30)
dodgeOptionsFrame.Position = UDim2.new(0, 0, 0, 60)
dodgeOptionsFrame.BackgroundTransparency = 1
dodgeOptionsFrame.Visible = false -- Hidden by default
dodgeOptionsFrame.Parent = dodgeContainer

-- Player Toggle Button
local dodgePlayerButton = Instance.new("TextButton")
dodgePlayerButton.Name = "DodgePlayerToggle"
dodgePlayerButton.Size = UDim2.new(0.48, 0, 1, 0)
dodgePlayerButton.Position = UDim2.new(0, 0, 0, 0)
dodgePlayerButton.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
dodgePlayerButton.Text = "Players [ON]"
dodgePlayerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
dodgePlayerButton.Font = Enum.Font.GothamBold
dodgePlayerButton.TextSize = 11
dodgePlayerButton.Parent = dodgeOptionsFrame

local dpCorner = Instance.new("UICorner")
dpCorner.CornerRadius = UDim.new(0, 6)
dpCorner.Parent = dodgePlayerButton

-- Bullet Toggle Button
local dodgeBulletButton = Instance.new("TextButton")
dodgeBulletButton.Name = "DodgeBulletToggle"
dodgeBulletButton.Size = UDim2.new(0.48, 0, 1, 0)
dodgeBulletButton.Position = UDim2.new(0.52, 0, 0, 0)
dodgeBulletButton.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
dodgeBulletButton.Text = "Bullets [ON]"
dodgeBulletButton.TextColor3 = Color3.fromRGB(255, 255, 255)
dodgeBulletButton.Font = Enum.Font.GothamBold
dodgeBulletButton.TextSize = 11
dodgeBulletButton.Parent = dodgeOptionsFrame

local dbCorner = Instance.new("UICorner")
dbCorner.CornerRadius = UDim.new(0, 6)
dbCorner.Parent = dodgeBulletButton

local dodgeStatus = Instance.new("TextLabel")
dodgeStatus.Name = "DodgeStatus"
dodgeStatus.Size = UDim2.new(1, 0, 0, 20)
dodgeStatus.Position = UDim2.new(0, 0, 0, 95)
dodgeStatus.BackgroundTransparency = 1
dodgeStatus.Text = "Configure what to avoid above"
dodgeStatus.TextColor3 = Color3.fromRGB(120, 120, 140)
dodgeStatus.TextSize = 11
dodgeStatus.Font = Enum.Font.Gotham
dodgeStatus.TextXAlignment = Enum.TextXAlignment.Left
dodgeStatus.Parent = dodgeContainer

mainFrame.Parent = screenGui

-- Movement system variables
local character, humanoid, rootPart
local isMoving = false
local moveSpeed = 50
local currentHotkey = Enum.KeyCode.E

-- Auto-track variables
local autoTrackEnabled = false
local targetModel = nil
local timeAtTarget = 0
local reachedTarget = false
local TARGET_REACH_DISTANCE = 3
local TARGET_STAY_TIME = 2
local autoTrackConnection = nil
local currentPath = nil
local waypoints = {}
local currentWaypointIndex = 1
local autoTrackBodyVelocity = nil
local MAX_VERTICAL_TRACK_DIST = 20

-- ESP system variables
local espEnabled = false
local espConnections = {}
local espBoxes = {} 

-- Mobile fly variables
local mobileFlyEnabled = false
local mobileFlyConnection = nil
local bodyGyro = nil
local bodyVelocity = nil

-- VIP Bypass variables
local vipBypassEnabled = false
local vipConnection = nil
local vipPart1 = nil
local vipPart2 = nil
local vipTimer = 0
local vipStage = 0 
local vipBodyVelocity = nil
local vipBodyPosition = nil
local vipSpin = nil 
local noclipConnection = nil

-- Auto Dodge Variables
local dodgeEnabled = false
local dodgePlayersEnabled = true -- Default ON
local dodgeBulletsEnabled = true -- Default ON
local dodgeConnection = nil
local dodgeBodyVelocity = nil
local DODGE_RANGE = 20 -- UPDATED TO 20 STUDS
local DODGE_FORCE_POWER = 30 -- INCREASED FORCE FOR SNAPPY DODGE

-- CFrames provided by user
local VIP_CFRAME_1 = CFrame.new(-607.340271, 1.1017642, -46.8191528, -0.694649816, 0, 0.719348073, 0, 1, 0, -0.719348073, 0, -0.694649816)
local VIP_CFRAME_2 = CFrame.new(-625.340271, 1.1017642, -46.8191528, -0.694649816, 0, 0.719348073, 0, 1, 0, -0.719348073, 0, -0.694649816)
local VIP_SPEED = 44

-- Anti-teleport system
local lastValidPosition = nil
local movementHistory = {}
local MAX_HISTORY = 10

-- Function to update GUI status
local function updateGUI()
    if isMoving then
        statusValue.Text = "ACTIVE"
        statusValue.TextColor3 = Color3.fromRGB(80, 255, 80)
    else
        statusValue.Text = "INACTIVE"
        statusValue.TextColor3 = Color3.fromRGB(255, 80, 80)
    end
    
    -- Update track button
    if autoTrackEnabled then
        trackButton.Text = "ON"
        trackButton.TextColor3 = Color3.fromRGB(200, 255, 200)
        trackButton.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
    else
        trackButton.Text = "OFF"
        trackButton.TextColor3 = Color3.fromRGB(255, 200, 200)
        trackButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
    end
    
    -- Update ESP button
    if espEnabled then
        espButton.Text = "ON"
        espButton.TextColor3 = Color3.fromRGB(200, 255, 200)
        espButton.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
    else
        espButton.Text = "OFF"
        espButton.TextColor3 = Color3.fromRGB(255, 200, 200)
        espButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
    end
    
    -- Update mobile fly button
    if mobileFlyEnabled then
        mobileButton.Text = "ON"
        mobileButton.TextColor3 = Color3.fromRGB(200, 255, 200)
        mobileButton.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
    else
        mobileButton.Text = "OFF"
        mobileButton.TextColor3 = Color3.fromRGB(255, 200, 200)
        mobileButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
    end

    -- Update VIP button
    if vipBypassEnabled then
        vipButton.Text = "ON"
        vipButton.TextColor3 = Color3.fromRGB(200, 255, 200)
        vipButton.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
        if vipStage == 0 then vipStatus.Text = "Go to the marked Green Part..."
        elseif vipStage == 1 then vipStatus.Text = "Stay there..."
        elseif vipStage == 2 then vipStatus.Text = "SPINNING & MOVING..."
        elseif vipStage == 3 then vipStatus.Text = "HOLDING POSITION..."
        end
    else
        vipButton.Text = "OFF"
        vipButton.TextColor3 = Color3.fromRGB(255, 200, 200)
        vipButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
        vipStatus.Text = "Glitch through VIP walls"
    end

    -- Update Dodge Button
    if dodgeEnabled then
        dodgeButton.Text = "ON"
        dodgeButton.TextColor3 = Color3.fromRGB(200, 255, 200)
        dodgeButton.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
        dodgeOptionsFrame.Visible = true
    else
        dodgeButton.Text = "OFF"
        dodgeButton.TextColor3 = Color3.fromRGB(255, 200, 200)
        dodgeButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
        dodgeOptionsFrame.Visible = false
    end

    -- Update Dodge Sub-options
    if dodgePlayersEnabled then
        dodgePlayerButton.Text = "Players [ON]"
        dodgePlayerButton.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
    else
        dodgePlayerButton.Text = "Players [OFF]"
        dodgePlayerButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
    end

    if dodgeBulletsEnabled then
        dodgeBulletButton.Text = "Bullets [ON]"
        dodgeBulletButton.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
    else
        dodgeBulletButton.Text = "Bullets [OFF]"
        dodgeBulletButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
    end
end

-- --- BOX ESP FUNCTIONS (BoxHandleAdornment + Name Tag) ---
local function createBoxESP(playerCharacter)
    if not playerCharacter then return end
    
    if playerCharacter:FindFirstChild("ESP_Box") then
        playerCharacter.ESP_Box:Destroy()
    end
    if playerCharacter:FindFirstChild("ESP_NameTag") then
        playerCharacter.ESP_NameTag:Destroy()
    end
    
    local root = playerCharacter:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "ESP_Box"
    box.Adornee = root
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Size = Vector3.new(4, 5, 4) 
    box.Transparency = 0.5
    box.Color3 = Color3.fromRGB(255, 0, 0)
    box.Parent = playerCharacter
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_NameTag"
    billboard.Adornee = root
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 4.5, 0) 
    billboard.AlwaysOnTop = true
    billboard.Parent = playerCharacter
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = playerCharacter.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 13
    nameLabel.Parent = billboard
    
    espBoxes[playerCharacter] = box 
end

local function enableESPForPlayer(player)
    if player == Players.LocalPlayer then return end
    
    local function setupESP()
        if player.Character then
            createBoxESP(player.Character)
        end
        
        espConnections[player] = player.CharacterAdded:Connect(function(character)
            local start = tick()
            while tick() - start < 5 do
                if character:FindFirstChild("HumanoidRootPart") then
                    createBoxESP(character)
                    break
                end
                wait(0.5)
            end
        end)
    end
    
    setupESP()
end

local function disableESPForPlayer(player)
    if espConnections[player] then
        espConnections[player]:Disconnect()
        espConnections[player] = nil
    end
    
    if player.Character then
        local b = player.Character:FindFirstChild("ESP_Box")
        if b then b:Destroy() end
        local n = player.Character:FindFirstChild("ESP_NameTag")
        if n then n:Destroy() end
    end
end

local function toggleESP()
    espEnabled = not espEnabled
    
    if espEnabled then
        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            enableESPForPlayer(otherPlayer)
        end
        
        espConnections.playerAdded = Players.PlayerAdded:Connect(function(newPlayer)
            enableESPForPlayer(newPlayer)
        end)
    else
        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            disableESPForPlayer(otherPlayer)
        end
        
        if espConnections.playerAdded then
            espConnections.playerAdded:Disconnect()
            espConnections.playerAdded = nil
        end
    end
    
    updateGUI()
end

-- --- VIP BYPASS FUNCTIONS ---
local function startNoclip()
    if noclipConnection then noclipConnection:Disconnect() end
    noclipConnection = RunService.Stepped:Connect(function()
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function stopNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
end

local function createSpin()
    if not rootPart then return end
    local spin = Instance.new("BodyAngularVelocity")
    spin.Name = "VipSpin"
    spin.MaxTorque = Vector3.new(0, math.huge, 0)
    spin.AngularVelocity = Vector3.new(0, 1000, 0)
    spin.Parent = rootPart
    return spin
end

local function cleanupVip()
    if vipConnection then vipConnection:Disconnect() vipConnection = nil end
    if vipPart1 then vipPart1:Destroy() vipPart1 = nil end
    if vipPart2 then vipPart2:Destroy() vipPart2 = nil end
    if vipBodyVelocity then vipBodyVelocity:Destroy() vipBodyVelocity = nil end
    if vipBodyPosition then vipBodyPosition:Destroy() vipBodyPosition = nil end
    if vipSpin then vipSpin:Destroy() vipSpin = nil end
    
    stopNoclip()
    vipStage = 0
    vipTimer = 0
end

local function createVipPart(cframe, color, name)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.CanCollide = false
    p.CFrame = cframe
    p.Size = Vector3.new(2, 5, 2)
    p.Transparency = 0.5
    p.Color = color
    p.Material = Enum.Material.Neon
    p.Parent = Workspace
    
    local bb = Instance.new("BillboardGui")
    bb.Adornee = p
    bb.Size = UDim2.new(0, 100, 0, 50)
    bb.StudsOffset = Vector3.new(0, 4, 0)
    bb.AlwaysOnTop = true
    bb.Parent = p
    
    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.Text = name
    txt.TextColor3 = color
    txt.TextStrokeTransparency = 0
    txt.Font = Enum.Font.GothamBold
    txt.TextSize = 14
    txt.Parent = bb
    
    return p
end

local function startVipBypass()
    cleanupVip()
    vipBypassEnabled = true
    
    vipPart1 = createVipPart(VIP_CFRAME_1, Color3.fromRGB(0, 255, 0), "START HERE")
    vipStage = 0
    vipTimer = 0
    
    vipConnection = RunService.Heartbeat:Connect(function(dt)
        if not vipBypassEnabled or not rootPart then return end
        
        if vipStage == 0 or vipStage == 1 then
            local dist = (rootPart.Position - VIP_CFRAME_1.Position).Magnitude
            if dist < 5 then
                vipTimer = vipTimer + dt
                vipStage = 1
                if vipTimer > 3 then
                    vipStage = 2
                    vipTimer = 0
                    if humanoid then rootPart.Size = Vector3.new(1, 1, 1) end
                    vipPart2 = createVipPart(VIP_CFRAME_2, Color3.fromRGB(255, 0, 0), "END GOAL")
                    startNoclip()
                    vipSpin = createSpin()
                    vipBodyVelocity = Instance.new("BodyVelocity")
                    vipBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    vipBodyVelocity.Parent = rootPart
                end
            else
                if vipStage == 1 then
                    vipTimer = 0
                    vipStage = 0
                end
            end
            
        elseif vipStage == 2 then
            if not vipBodyVelocity then return end
            
            local currentPos = rootPart.Position
            local targetPos = VIP_CFRAME_2.Position
            local direction = (targetPos - currentPos)
            local dist = direction.Magnitude
            
            vipBodyVelocity.Velocity = direction.Unit * VIP_SPEED
            
            if dist < 3 then
                vipStage = 3
                vipTimer = 0
                if vipBodyVelocity then vipBodyVelocity:Destroy() vipBodyVelocity = nil end
                vipBodyPosition = Instance.new("BodyPosition")
                vipBodyPosition.Position = VIP_CFRAME_2.Position
                vipBodyPosition.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                vipBodyPosition.P = 10000
                vipBodyPosition.D = 100
                vipBodyPosition.Parent = rootPart
            end
            
        elseif vipStage == 3 then
             if vipBodyPosition then
                 vipBodyPosition.Position = VIP_CFRAME_2.Position
             end
             vipTimer = vipTimer + dt
             vipStatus.Text = "LOCKING: " .. string.format("%.1f", 7 - vipTimer) .. "s"
             if vipTimer >= 7 then
                 vipBypassEnabled = false
                 cleanupVip()
                 updateGUI()
                 print("VIP Bypass Complete")
             end
        end
        if math.floor(tick()) % 1 == 0 and vipStage ~= 3 then updateGUI() end
    end)
    updateGUI()
end

local function stopVipBypass()
    vipBypassEnabled = false
    cleanupVip()
    updateGUI()
end

local function toggleVipBypass()
    if vipBypassEnabled then stopVipBypass() else startVipBypass() end
end

-- --- AUTO DODGE SYSTEM ---

local function stopDodge()
    if dodgeConnection then dodgeConnection:Disconnect() dodgeConnection = nil end
    if dodgeBodyVelocity then dodgeBodyVelocity:Destroy() dodgeBodyVelocity = nil end
    dodgeEnabled = false
    updateGUI()
end

local function startDodge()
    stopDodge() -- Reset checks
    dodgeEnabled = true
    updateGUI()
    
    dodgeConnection = RunService.Heartbeat:Connect(function()
        if not rootPart then return end
        
        local threatFound = false
        local threatDirection = nil
        
        -- 1. Scan for Players (Distance Check only)
        if dodgePlayersEnabled then
            for _, otherPlayer in ipairs(Players:GetPlayers()) do
                if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local enemyRoot = otherPlayer.Character.HumanoidRootPart
                    local dist = (enemyRoot.Position - rootPart.Position).Magnitude
                    
                    if dist < DODGE_RANGE then
                        threatFound = true
                        threatDirection = (rootPart.Position - enemyRoot.Position).Unit
                        break 
                    end
                end
            end
        end
        
        -- 2. Scan for Projectiles (Balls/Triangles in ObjectCache)
        if not threatFound and dodgeBulletsEnabled then
            local debris = Workspace:FindFirstChild("Debris")
            if debris then
                for _, folder in ipairs(debris:GetChildren()) do
                    if folder.Name == "ObjectCache" then
                        for _, obj in ipairs(folder:GetChildren()) do
                             if (obj.Name == "Ball" or obj.Name == "Triangle") and obj:IsA("BasePart") then
                                 local dist = (obj.Position - rootPart.Position).Magnitude
                                 if dist < DODGE_RANGE then
                                     threatFound = true
                                     threatDirection = (rootPart.Position - obj.Position).Unit
                                     break
                                 end
                             end
                        end
                    end
                    if threatFound then break end
                end
            end
        end
        
        if threatFound then
            if not dodgeBodyVelocity or dodgeBodyVelocity.Parent ~= rootPart then
                dodgeBodyVelocity = Instance.new("BodyVelocity")
                dodgeBodyVelocity.Name = "DodgeForce"
                -- Only limit Y axis force to allow gravity if needed, or set max force to handle all
                dodgeBodyVelocity.MaxForce = Vector3.new(100000, 0, 100000) -- Strict horizontal
                dodgeBodyVelocity.P = 5000 
                dodgeBodyVelocity.Parent = rootPart
            end
            
            -- Shove sideways relative to the incoming threat direction (Pure Strafe)
            -- We take vector pointing AT player (ThreatDirection), cross with UP.
            local sideVector = threatDirection:Cross(Vector3.new(0, 1, 0)).Unit
            
            -- Multiply by speed
            dodgeBodyVelocity.Velocity = sideVector * DODGE_FORCE_POWER
            
            statusValue.Text = "DODGING!"
            statusValue.TextColor3 = Color3.fromRGB(255, 140, 0)
        else
            if dodgeBodyVelocity then 
                dodgeBodyVelocity:Destroy() 
                dodgeBodyVelocity = nil 
            end
            if isMoving then
                 statusValue.Text = "ACTIVE"
                 statusValue.TextColor3 = Color3.fromRGB(80, 255, 80)
            elseif not isMoving and dodgeEnabled then
                 statusValue.Text = "WATCHING"
                 statusValue.TextColor3 = Color3.fromRGB(200, 200, 255)
            end
        end
    end)
end

local function toggleDodge()
    if dodgeEnabled then stopDodge() else startDodge() end
end

-- --- MOVEMENT & TRACKING ---

local function getLiveModels()
    local models = {}
    local liveFolder = Workspace:FindFirstChild("Live")
    
    if liveFolder then
        for _, model in ipairs(liveFolder:GetChildren()) do
            if model == character then continue end
            if model:IsA("Model") and model:FindFirstChild("HumanoidRootPart") then
                table.insert(models, model)
            end
        end
    end
    return models
end

local function findClosestModel()
    if not rootPart then return nil end

    local closestModel = nil
    local closestDistance = math.huge
    local currentPos = rootPart.Position

    for _, model in ipairs(getLiveModels()) do
        if model == character then continue end

        local modelRoot = model:FindFirstChild("HumanoidRootPart")
        if modelRoot then
            local targetPos = modelRoot.Position
            local verticalDiff = math.abs(targetPos.Y - currentPos.Y)
            
            if verticalDiff <= MAX_VERTICAL_TRACK_DIST then
                local distance = (targetPos - currentPos).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestModel = model
                end
            end
        end
    end

    return closestModel
end

local function checkTargetReached()
    if not targetModel or not rootPart then return false end
    local targetRoot = targetModel:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return false end
    local distance = (targetRoot.Position - rootPart.Position).Magnitude
    return distance <= TARGET_REACH_DISTANCE
end

local function getTargetPosition()
    if not targetModel then return nil end
    local targetRoot = targetModel:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return nil end
    return targetRoot.Position + Vector3.new(0, 5, 0)
end

local function computePathToTarget()
    if not rootPart or not targetModel then return false end
    local targetPos = getTargetPosition()
    if not targetPos then return false end

    local path = PathfindingService:CreatePath()
    path:ComputeAsync(rootPart.Position, targetPos)

    if path.Status ~= Enum.PathStatus.Success then return false end

    waypoints = path:GetWaypoints()
    currentWaypointIndex = 1
    currentPath = path

    return true
end

local function storeValidPosition(position)
    table.insert(movementHistory, position)
    if #movementHistory > MAX_HISTORY then
        table.remove(movementHistory, 1)
    end
    lastValidPosition = position
end

local function isMovementValid(newPosition, currentPosition)
    if not currentPosition then return true end
    local distance = (newPosition - currentPosition).Magnitude
    return distance <= 60
end

local function handleAntiTeleport()
    if not rootPart then return end
    if vipBypassEnabled and (vipStage == 2 or vipStage == 3) then return end
    
    local currentPosition = rootPart.Position
    if lastValidPosition then
        local distanceMoved = (currentPosition - lastValidPosition).Magnitude
        if distanceMoved <= 60 then
            storeValidPosition(currentPosition)
        end
    else
        storeValidPosition(currentPosition)
    end
    
    for _, oldPos in ipairs(movementHistory) do
        local distanceToOld = (currentPosition - oldPos).Magnitude
        if distanceToOld < 5 and currentPosition ~= lastValidPosition then
            if lastValidPosition then
                rootPart.CFrame = CFrame.new(lastValidPosition) * rootPart.CFrame.Rotation
            end
            break
        end
    end
end

local function clampVerticalPosition(currentPos, targetPos)
    local maxUpward = currentPos.Y + 2
    local clampedY = math.clamp(targetPos.Y, currentPos.Y, maxUpward)
    return Vector3.new(targetPos.X, clampedY, targetPos.Z)
end

local function manualMove()
    if not rootPart then return end
    local mouseHit = mouse.Hit
    local targetPosition = Vector3.new(mouseHit.X, mouseHit.Y, mouseHit.Z)
    local currentPosition = rootPart.Position
    targetPosition = clampVerticalPosition(currentPosition, targetPosition)
    local direction = (targetPosition - currentPosition)
    if direction.Magnitude > 2 then
        local moveDistance = moveSpeed * RunService.Heartbeat:Wait()
        local moveStep = math.min(moveDistance, direction.Magnitude)
        if moveStep > 0 then
            local newPosition = currentPosition + (direction.Unit * moveStep)
            if isMovementValid(newPosition, currentPosition) then
                rootPart.CFrame = CFrame.new(newPosition) * rootPart.CFrame.Rotation
                storeValidPosition(newPosition)
            end
        end
    end
end

local function autoTrackMove()
    if not rootPart then return end
    handleAntiTeleport()
    if not autoTrackBodyVelocity or autoTrackBodyVelocity.Parent ~= rootPart then
        if autoTrackBodyVelocity then autoTrackBodyVelocity:Destroy() end
        autoTrackBodyVelocity = Instance.new("BodyVelocity")
        autoTrackBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        autoTrackBodyVelocity.Parent = rootPart
    end

    if not targetModel or not targetModel:FindFirstChild("HumanoidRootPart") then
        targetModel = findClosestModel()
        reachedTarget = false
        timeAtTarget = 0
        currentPath = nil
        waypoints = {}
        currentWaypointIndex = 1
        autoTrackBodyVelocity.Velocity = Vector3.new(0,0,0)
        updateGUI()
        return
    end

    if targetModel == character then
        targetModel = findClosestModel()
        return
    end
    
    local currentTargetRoot = targetModel:FindFirstChild("HumanoidRootPart")
    if currentTargetRoot then
        local yDiff = math.abs(currentTargetRoot.Position.Y - rootPart.Position.Y)
        if yDiff > MAX_VERTICAL_TRACK_DIST then
            targetModel = nil
            autoTrackBodyVelocity.Velocity = Vector3.new(0,0,0)
            updateGUI()
            return
        end
    end

    if checkTargetReached() then
        autoTrackBodyVelocity.Velocity = Vector3.new(0,0,0) 
        if not reachedTarget then
            reachedTarget = true
            timeAtTarget = 0
        else
            timeAtTarget = timeAtTarget + RunService.Heartbeat:Wait()
            if timeAtTarget >= TARGET_STAY_TIME then
                targetModel = findClosestModel()
                reachedTarget = false
                timeAtTarget = 0
                currentPath = nil
                waypoints = {}
                currentWaypointIndex = 1
                updateGUI()
            end
        end
    else
        reachedTarget = false
        timeAtTarget = 0
        if targetModel then
            if not currentPath or #waypoints == 0 or currentWaypointIndex > #waypoints then
                if not computePathToTarget() then
                    local targetPosition = getTargetPosition()
                    if targetPosition then
                        local currentPosition = rootPart.Position
                        local direction = (targetPosition - currentPosition)
                        if direction.Magnitude > 0 then
                            autoTrackBodyVelocity.Velocity = direction.Unit * moveSpeed
                            storeValidPosition(rootPart.Position)
                        end
                    end
                    return
                end
            end
            if currentWaypointIndex <= #waypoints then
                local waypoint = waypoints[currentWaypointIndex]
                local currentPosition = rootPart.Position
                local waypointTarget = waypoint.Position + Vector3.new(0, 0, 0)
                local direction = (waypointTarget - currentPosition)
                if direction.Magnitude > 0 then
                    autoTrackBodyVelocity.Velocity = direction.Unit * moveSpeed
                    storeValidPosition(rootPart.Position)
                    if (currentPosition - waypointTarget).Magnitude < 4 then
                        currentWaypointIndex = currentWaypointIndex + 1
                    end
                end
            else
                currentPath = nil
                waypoints = {}
                currentWaypointIndex = 1
            end
        end
    end
end

local function startMobileFly()
    if not rootPart then return end
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.P = 10000
    bodyGyro.D = 1000
    bodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
    bodyGyro.CFrame = Workspace.CurrentCamera.CFrame
    bodyGyro.Parent = rootPart
    
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000) * 10
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = rootPart
    
    mobileFlyConnection = RunService.Heartbeat:Connect(function()
        if not rootPart or not rootPart.Parent or not mobileFlyEnabled then
            if mobileFlyConnection then mobileFlyConnection:Disconnect() end
            return
        end
        if bodyGyro then bodyGyro.CFrame = Workspace.CurrentCamera.CFrame end
        local currentFlySpeed = moveSpeed * 0.84
        if bodyVelocity then bodyVelocity.Velocity = Workspace.CurrentCamera.CFrame.LookVector * currentFlySpeed end
        storeValidPosition(rootPart.Position)
    end)
end

local function stopMobileFly()
    if mobileFlyConnection then mobileFlyConnection:Disconnect() mobileFlyConnection = nil end
    if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
end

local function toggleMobileFly()
    mobileFlyEnabled = not mobileFlyEnabled
    if mobileFlyEnabled then startMobileFly() else stopMobileFly() end
    updateGUI()
end

local function setupMobileInput()
    local mobileFlyButton = Instance.new("TextButton")
    mobileFlyButton.Name = "MobileFlyButton"
    mobileFlyButton.Size = UDim2.new(0, 80, 0, 80)
    mobileFlyButton.Position = UDim2.new(1, -100, 1, -100)
    mobileFlyButton.BackgroundColor3 = Color3.fromRGB(80, 160, 255)
    mobileFlyButton.BackgroundTransparency = 0.3
    mobileFlyButton.Text = "FLY"
    mobileFlyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    mobileFlyButton.TextSize = 16
    mobileFlyButton.Font = Enum.Font.GothamBold
    mobileFlyButton.Visible = false
    
    local mobileCorner = Instance.new("UICorner")
    mobileCorner.CornerRadius = UDim.new(0, 40)
    mobileCorner.Parent = mobileFlyButton
    mobileFlyButton.Parent = screenGui
    
    if UserInputService.TouchEnabled then mobileFlyButton.Visible = true end
    
    mobileFlyButton.MouseButton1Down:Connect(function() if mobileFlyEnabled then startMobileFly() end end)
    mobileFlyButton.MouseButton1Up:Connect(function() stopMobileFly() end)
    mobileFlyButton.TouchLongPress:Connect(function() if mobileFlyEnabled then startMobileFly() end end)
end

local function startAutoTrack()
    if autoTrackConnection then autoTrackConnection:Disconnect() end
    autoTrackConnection = RunService.Heartbeat:Connect(function()
        if autoTrackEnabled and rootPart and rootPart.Parent then
            autoTrackMove()
        else
            if autoTrackConnection then autoTrackConnection:Disconnect() autoTrackConnection = nil end
            if autoTrackBodyVelocity then autoTrackBodyVelocity:Destroy() autoTrackBodyVelocity = nil end
        end
    end)
end

local function stopAutoTrack()
    if autoTrackConnection then autoTrackConnection:Disconnect() autoTrackConnection = nil end
    if autoTrackBodyVelocity then autoTrackBodyVelocity:Destroy() autoTrackBodyVelocity = nil end
    targetModel = nil
    reachedTarget = false
    timeAtTarget = 0
end

local function startMoving()
    if isMoving or not rootPart then return end
    isMoving = true
    updateGUI()
    storeValidPosition(rootPart.Position)
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not isMoving or not rootPart or not rootPart.Parent then connection:Disconnect() return end
        handleAntiTeleport()
        manualMove()
    end)
end

local function stopMoving() isMoving = false updateGUI() end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == currentHotkey then startMoving() end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.KeyCode == currentHotkey then stopMoving() end
end)

closeButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    openButton.Visible = true
end)

openButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    openButton.Visible = false
end)

speedInputBox.FocusLost:Connect(function(enterPressed)
    local num = tonumber(speedInputBox.Text)
    if num then
        moveSpeed = num
        speedInputBox.Text = tostring(num)
    else
        speedInputBox.Text = ""
    end
end)

local waitingForHotkey = false
hotkeyButton.MouseButton1Click:Connect(function()
    if not waitingForHotkey then
        waitingForHotkey = true
        hotkeyButton.Text = "..."
        hotkeyButton.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
        local connection
        connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                currentHotkey = input.KeyCode
                hotkeyButton.Text = input.KeyCode.Name
                hotkeyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
                waitingForHotkey = false
                connection:Disconnect()
                updateGUI()
            end
        end)
    end
end)

trackButton.MouseButton1Click:Connect(function()
    autoTrackEnabled = not autoTrackEnabled
    if autoTrackEnabled then startAutoTrack() else stopAutoTrack() end
    updateGUI()
end)

-- Connect Dodge Sub-Buttons
dodgePlayerButton.MouseButton1Click:Connect(function()
    dodgePlayersEnabled = not dodgePlayersEnabled
    updateGUI()
end)

dodgeBulletButton.MouseButton1Click:Connect(function()
    dodgeBulletsEnabled = not dodgeBulletsEnabled
    updateGUI()
end)

espButton.MouseButton1Click:Connect(function() toggleESP() end)
mobileButton.MouseButton1Click:Connect(function() toggleMobileFly() end)
vipButton.MouseButton1Click:Connect(function() toggleVipBypass() end)
dodgeButton.MouseButton1Click:Connect(function() toggleDodge() end)

local function setupCharacter(newCharacter)
    character = newCharacter
    local success = pcall(function()
        humanoid = character:WaitForChild("Humanoid")
        rootPart = character:WaitForChild("HumanoidRootPart")
    end)
    if not success then wait(0.5) humanoid = character:WaitForChild("Humanoid") rootPart = character:WaitForChild("HumanoidRootPart") end
    isMoving = false
    movementHistory = {}
    lastValidPosition = rootPart.Position
    storeValidPosition(rootPart.Position)
    updateGUI()
    if autoTrackEnabled then startAutoTrack() end
    if mobileFlyEnabled then startMobileFly() end
    if vipBypassEnabled then startVipBypass() end
    if dodgeEnabled then startDodge() end
end

if player.Character then setupCharacter(player.Character) end
player.CharacterAdded:Connect(setupCharacter)

player.CharacterRemoving:Connect(function()
    isMoving = false
    stopAutoTrack()
    stopMobileFly()
    stopVipBypass()
    stopDodge()
    updateGUI()
end)

RunService.Heartbeat:Connect(function()
    if rootPart and rootPart.Parent then handleAntiTeleport() end
end)

setupMobileInput()
updateGUI()
print("Dodge Logic Fixed & Updated")
