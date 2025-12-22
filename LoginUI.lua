--[[
    ROBLOX GAMING HUB - ULTIMATE LOGIN UI
    Design: Cyberpunk / Pro Scripter Style
    Author: Wubbalubbadubdub4
--]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

--------------------------------------------------------------------------------
-- ⚙️ CONFIGURATION (EDIT THIS SECTION!)
--------------------------------------------------------------------------------
local GITHUB_USER = "Wubbalubbadubdub4"
local REPO_NAME = "Roblox-Gaming-Hub" 
local BRANCH = "main"

-- PASTE YOUR LINKVERTISE LINK HERE (The link that leads to the key)
local LINKVERTISE_LINK = "https://linkvertise.com/YOUR_LINK_HERE" 

local KEY_URL = "https://raw.githubusercontent.com/"..GITHUB_USER.."/"..REPO_NAME.."/"..BRANCH.."/key.txt"
local HUB_URL = "https://raw.githubusercontent.com/"..GITHUB_USER.."/"..REPO_NAME.."/"..BRANCH.."/MainHub.lua"

--------------------------------------------------------------------------------
-- 🎨 UI CONSTRUCTION
--------------------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NexusProLogin"
if gethui then ScreenGui.Parent = gethui() else ScreenGui.Parent = CoreGui end

-- Main Container
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 0, 0, 0) -- Starts invisible
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = false
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 15)
MainCorner.Parent = MainFrame

-- Neon Border
local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 3
UIStroke.Parent = MainFrame

local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))
}
UIGradient.Rotation = 45
UIGradient.Parent = UIStroke

spawn(function()
    while true do
        local tween = TweenService:Create(UIGradient, TweenInfo.new(2, Enum.EasingStyle.Linear), {Rotation = UIGradient.Rotation + 360})
        tween:Play()
        tween.Completed:Wait()
    end
end)

-- Title
local Title = Instance.new("TextLabel")
Title.Text = "ROBLOX GAMING HUB"
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Position = UDim2.new(0, 0, 0, 10)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 24
Title.Parent = MainFrame

local SubTitle = Instance.new("TextLabel")
SubTitle.Text = "AUTHENTICATION SYSTEM"
SubTitle.Size = UDim2.new(1, 0, 0, 20)
SubTitle.Position = UDim2.new(0, 0, 0, 40)
SubTitle.BackgroundTransparency = 1
SubTitle.TextColor3 = Color3.fromRGB(150, 150, 150)
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextSize = 12
SubTitle.Parent = MainFrame

-- Input Box
local InputContainer = Instance.new("Frame")
InputContainer.Size = UDim2.new(0.8, 0, 0, 45)
InputContainer.Position = UDim2.new(0.1, 0, 0.35, 0)
InputContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
InputContainer.Parent = MainFrame
Instance.new("UICorner", InputContainer).CornerRadius = UDim.new(0, 8)

local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(1, -20, 1, 0)
KeyBox.Position = UDim2.new(0, 10, 0, 0)
KeyBox.BackgroundTransparency = 1
KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyBox.PlaceholderText = "Paste Key Here..."
KeyBox.Text = ""
KeyBox.Font = Enum.Font.GothamBold
KeyBox.TextSize = 14
KeyBox.ClearTextOnFocus = false 
KeyBox.Parent = InputContainer

-- Button Function
local function CreateButton(text, pos, color, callback)
    local Btn = Instance.new("TextButton")
    Btn.Text = text
    Btn.Size = UDim2.new(0.38, 0, 0, 40)
    Btn.Position = pos
    Btn.BackgroundColor3 = color
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 12
    Btn.Parent = MainFrame
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Btn
    
    Btn.MouseEnter:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.2), {Size = UDim2.new(0.4, 0, 0, 42)}):Play()
    end)
    Btn.MouseLeave:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.2), {Size = UDim2.new(0.38, 0, 0, 40)}):Play()
    end)
    
    Btn.MouseButton1Click:Connect(callback)
    return Btn
end

--------------------------------------------------------------------------------
-- 🔗 BUTTON LOGIC (Linkvertise Integration)
--------------------------------------------------------------------------------
local GetKeyBtn = CreateButton("GET KEY", UDim2.new(0.1, 0, 0.6, 0), Color3.fromRGB(255, 150, 0), function()
    -- Copy the Linkvertise link to clipboard
    setclipboard(LINKVERTISE_LINK) 
    
    game.StarterGui:SetCore("SendNotification", {
        Title = "Link Copied!";
        Text = "Complete the link to get the NEW Key.";
        Duration = 5;
    })
end)

local LoginBtn = CreateButton("LOGIN", UDim2.new(0.52, 0, 0.6, 0), Color3.fromRGB(0, 180, 255), function()
   -- Logic handled below
end)

-- Sliding Text
local ClipFrame = Instance.new("Frame")
ClipFrame.Size = UDim2.new(1, -20, 0, 30)
ClipFrame.Position = UDim2.new(0, 10, 0.85, 0)
ClipFrame.BackgroundTransparency = 1
ClipFrame.ClipsDescendants = true
ClipFrame.Parent = MainFrame

local SlidingText = Instance.new("TextLabel")
SlidingText.Text = "✅ STATUS: UNDETECTED | 🛡️ NEXUS PROTECTOR | 🔑 KEY CHANGES DAILY - GET NEW KEY IF LOGIN FAILS"
SlidingText.Size = UDim2.new(0, 600, 1, 0)
SlidingText.Position = UDim2.new(1, 0, 0, 0)
SlidingText.BackgroundTransparency = 1
SlidingText.TextColor3 = Color3.fromRGB(0, 255, 150)
SlidingText.Font = Enum.Font.Code
SlidingText.TextSize = 14
SlidingText.Parent = ClipFrame

spawn(function()
    while true do
        SlidingText.Position = UDim2.new(1, 0, 0, 0)
        local tween = TweenService:Create(SlidingText, TweenInfo.new(8, Enum.EasingStyle.Linear), {Position = UDim2.new(-1.5, 0, 0, 0)})
        tween:Play()
        tween.Completed:Wait()
    end
end)

--------------------------------------------------------------------------------
-- 🔐 CHECK KEY LOGIC
--------------------------------------------------------------------------------
MainFrame.Size = UDim2.new(0, 0, 0, 0)
TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back), {Size = UDim2.new(0, 450, 0, 280)}):Play()
TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back), {Position = UDim2.new(0.5, -225, 0.5, -140)}):Play()

LoginBtn.MouseButton1Click:Connect(function()
    LoginBtn.Text = "Checking..."
    
    local success, result = pcall(function()
        -- Fetch key from GitHub, remove spaces and newlines
        local onlineKey = game:HttpGet(KEY_URL):gsub("\n", ""):gsub(" ", "")
        -- Check if input matches
        return KeyBox.Text == onlineKey
    end)
    
    if success and result == true then
        LoginBtn.Text = "ACCESS GRANTED"
        LoginBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        UIStroke.Color = Color3.fromRGB(0, 255, 0)
        
        local sound = Instance.new("Sound", workspace)
        sound.SoundId = "rbxassetid://6895079853"
        sound:Play()
        
        wait(1)
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
        wait(0.5)
        ScreenGui:Destroy()
        
        loadstring(game:HttpGet(HUB_URL))()
    else
        LoginBtn.Text = "INVALID KEY"
        LoginBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        for i = 1, 5 do
            MainFrame.Position = MainFrame.Position + UDim2.new(0, 5, 0, 0)
            wait(0.05)
            MainFrame.Position = MainFrame.Position - UDim2.new(0, 5, 0, 0)
            wait(0.05)
        end
        wait(1)
        LoginBtn.Text = "LOGIN"
        LoginBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
    end
end)
