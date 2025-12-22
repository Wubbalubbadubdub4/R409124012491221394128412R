--[[
    ROBLOX GAMING HUB - KEY LOADER
    Phase 1: Security Check
--]]

local GITHUB_USER = "Wubbalubbadubdub4" -- CHANGE THIS
local REPO_NAME = "MainHub"   -- CHANGE THIS
local BRANCH = "main"

local KeyURL = "https://raw.githubusercontent.com/"..GITHUB_USER.."/"..REPO_NAME.."/"..BRANCH.."/key.txt"
local HubURL = "https://raw.githubusercontent.com/"..GITHUB_USER.."/"..REPO_NAME.."/"..BRANCH.."/HubUI.lua"

-- 1. Check Key
local function CheckKey(inputKey)
    local onlineKey = game:HttpGet(KeyURL):gsub("\n", ""):gsub(" ", "")
    if inputKey == onlineKey then return true else return false end
end

-- 2. Create Login GUI
local ScreenGui = Instance.new("ScreenGui")
if gethui then ScreenGui.Parent = gethui() else ScreenGui.Parent = game.CoreGui end

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 150)
Frame.Position = UDim2.new(0.5, -150, 0.5, -75)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local TextBox = Instance.new("TextBox")
TextBox.Size = UDim2.new(0.8, 0, 0, 40)
TextBox.Position = UDim2.new(0.1, 0, 0.2, 0)
TextBox.PlaceholderText = "Enter Key Here"
TextBox.Parent = Frame

local Button = Instance.new("TextButton")
Button.Size = UDim2.new(0.8, 0, 0, 40)
Button.Position = UDim2.new(0.1, 0, 0.6, 0)
Button.Text = "Login"
Button.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
Button.Parent = Frame

-- 3. Login Logic
Button.MouseButton1Click:Connect(function()
    Button.Text = "Checking..."
    if CheckKey(TextBox.Text) then
        Button.Text = "Success!"
        wait(1)
        ScreenGui:Destroy()
        -- LOAD THE REAL HUB
        loadstring(game:HttpGet(HubURL))()
    else
        Button.Text = "Wrong Key!"
        wait(1)
        Button.Text = "Login"
    end
end)
