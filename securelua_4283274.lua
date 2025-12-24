-- [[ SERVICES ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- [[ SETTINGS ]] --
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Character, Humanoid

-- Feature States
local Settings = {
    NoClip = false,
    HitboxActive = false,
    Bypass = false,
    Speed = 16,
    HitboxSize = Vector3.new(20, 20, 20)
}

-- Dragging Variables
local isMenuDragging = false
local dragStartPos, startPosOffset

-- [[ GUI CREATION ]] --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ScriptHubUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- 1. MOBILE TOGGLE BUTTON (Small & clean)
local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 15, 0.45, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleBtn.Text = "🛡️"
ToggleBtn.TextSize = 24
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
local ToggleStroke = Instance.new("UIStroke", ToggleBtn)
ToggleStroke.Color = Color3.fromRGB(100, 100, 255)
ToggleStroke.Thickness = 2.5

-- 2. MAIN PANEL
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 340, 0, 450) -- Perfect mobile width
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 15)

-- Neon Border
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(40, 40, 60)
MainStroke.Thickness = 2

-- Title Bar
local TitleBar = Instance.new("TextLabel", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundTransparency = 1
TitleBar.Text = "Cut Trees Bypassed"
TitleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleBar.Font = Enum.Font.GothamBold
TitleBar.TextSize = 20

local Divider = Instance.new("Frame", MainFrame)
Divider.Size = UDim2.new(0.9, 0, 0, 1)
Divider.Position = UDim2.new(0.05, 0, 0, 50)
Divider.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
Divider.BorderSizePixel = 0

--- --- --- --- --- --- --- --- ---
-- HELPER: UI ELEMENTS
--- --- --- --- --- --- --- --- ---
local function CreateSection(text, yPos)
    local Label = Instance.new("TextLabel", MainFrame)
    Label.Text = text
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.Position = UDim2.new(0, 0, 0, yPos)
    Label.TextColor3 = Color3.fromRGB(150, 150, 170)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 11
    Label.BackgroundTransparency = 1
    return Label
end

local function CreateButton(text, yPos, color, callback)
    local Btn = Instance.new("TextButton", MainFrame)
    Btn.Size = UDim2.new(0.9, 0, 0, 40)
    Btn.Position = UDim2.new(0.05, 0, 0, yPos)
    Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 14
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    
    -- Gradient for shine
    local Gradient = Instance.new("UIGradient", Btn)
    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200))
    }

    local active = false
    Btn.MouseButton1Click:Connect(function()
        active = not active
        if active then
            Btn.Text = text .. ": ON"
            TweenService:Create(Btn, TweenInfo.new(0.3), {BackgroundColor3 = color}):Play()
        else
            Btn.Text = text
            TweenService:Create(Btn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(30, 30, 40)}):Play()
        end
        callback(active)
    end)
    return Btn
end

local function CreateInput(placeholder, yPos, callback)
    local Box = Instance.new("TextBox", MainFrame)
    Box.Size = UDim2.new(0.9, 0, 0, 40)
    Box.Position = UDim2.new(0.05, 0, 0, yPos)
    Box.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Box.PlaceholderText = placeholder
    Box.Text = ""
    Box.TextColor3 = Color3.fromRGB(255, 255, 255)
    Box.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
    Box.Font = Enum.Font.Gotham
    Box.TextSize = 14
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", Box).Color = Color3.fromRGB(50, 50, 60)
    
    Box.FocusLost:Connect(function()
        callback(Box.Text)
    end)
end

--- --- --- --- --- --- --- --- ---
-- BUILDING THE MENU
--- --- --- --- --- --- --- --- ---

-- Section: Movement
CreateSection("PLAYER MOVEMENT", 60)
CreateButton("NO CLIP", 85, Color3.fromRGB(0, 200, 100), function(s) Settings.NoClip = s end)
CreateInput("Walk Speed (e.g. 25)", 135, function(text)
    local num = tonumber(text)
    if num then Settings.Speed = num end
end)

-- Section: Combat
CreateSection("COMBAT ADVANTAGE", 190)
CreateInput("Hitbox Size (X,Y,Z) - e.g. 20,20,20", 215, function(text)
    local coords = {}
    for v in string.gmatch(text, "[^,]+") do table.insert(coords, tonumber(v)) end
    if #coords == 3 then
        Settings.HitboxSize = Vector3.new(coords[1], coords[2], coords[3])
    end
end)
CreateButton("ACTIVATE HITBOX", 265, Color3.fromRGB(255, 100, 50), function(s) Settings.HitboxActive = s end)

-- Section: Misc
CreateSection("MISC", 320)
CreateButton("BYPASS GAMEPASSES", 345, Color3.fromRGB(100, 100, 255), function(s)
    Settings.Bypass = s
    local Folder = LocalPlayer:FindFirstChild("GamepassFolder")
    if Folder then
        for _, v in pairs(Folder:GetChildren()) do
            if v:IsA("BoolValue") then v.Value = s end
        end
    end
end)

--- --- --- --- --- --- --- --- ---
-- LOGIC & DRAGGING
--- --- --- --- --- --- --- --- ---

-- Toggle Menu
ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Dragging Logic (Touch Compatible)
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isMenuDragging = true
        dragStartPos = input.Position
        startPosOffset = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isMenuDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStartPos
        MainFrame.Position = UDim2.new(
            startPosOffset.X.Scale, startPosOffset.X.Offset + delta.X,
            startPosOffset.Y.Scale, startPosOffset.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isMenuDragging = false
    end
end)

-- MAIN LOOP
RunService.Stepped:Connect(function()
    Character = LocalPlayer.Character
    if Character then
        Humanoid = Character:FindFirstChild("Humanoid")
        if Humanoid then Humanoid.WalkSpeed = Settings.Speed end

        -- NoClip
        if Settings.NoClip then
            for _, v in pairs(Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end

        -- Hitbox Resizer
        if Settings.HitboxActive then
            local tool = Character:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("Handle") then
                tool.Handle.Size = Settings.HitboxSize
                tool.Handle.Transparency = 0.5
                tool.Handle.CanCollide = false
                tool.Handle.Massless = true -- Prevents character from tipping over
            end
        end
    end
end)

print("Cut Trees Script Loaded")
