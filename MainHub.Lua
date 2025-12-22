--[[
    ROBLOX GAMING HUB - ULTIMATE DASHBOARD v3.0
    Geliştirici: RobloxGaming6969n
--]]

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-------------------------------------------------------------------------
-- ⚙️ SETTINGS (Github information)
-------------------------------------------------------------------------
local GITHUB_USER = "SeninKullaniciAdin"
local REPO_NAME = "SeninRepoAdin"
local BRANCH = "main"

local function RunScript(path)
    local url = "https://raw.githubusercontent.com/"..GITHUB_USER.."/"..REPO_NAME.."/"..BRANCH.."/"..path
    loadstring(game:HttpGet(url))()
end

-------------------------------------------------------------------------
-- 🎨 UI OLUŞTURMA (Modern & Dark)
-------------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NexusDashboard"
if syn and syn.protect_gui then syn.protect_gui(ScreenGui) ScreenGui.Parent = CoreGui elseif gethui then ScreenGui.Parent = gethui() else ScreenGui.Parent = CoreGui end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 550, 0, 350)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Sol Panel (Menü)
local SideBar = Instance.new("Frame")
SideBar.Size = UDim2.new(0, 140, 1, 0)
SideBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SideBar.Parent = MainFrame

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 10)
SideCorner.Parent = SideBar

local FixPatch = Instance.new("Frame") -- Görünüm düzeltme
FixPatch.Size = UDim2.new(0, 10, 1, 0)
FixPatch.Position = UDim2.new(1, -10, 0, 0)
FixPatch.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
FixPatch.BorderSizePixel = 0
FixPatch.Parent = SideBar

-- Profil Kısmı (Sol Üst)
local Avatar = Instance.new("ImageLabel")
Avatar.Size = UDim2.new(0, 60, 0, 60)
Avatar.Position = UDim2.new(0.5, -30, 0, 20)
Avatar.BackgroundTransparency = 1
-- Oyuncunun resmini çeker
Avatar.Image = Players:GetUserThumbnailAsync(Players.LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
Avatar.Parent = SideBar

local UserLabel = Instance.new("TextLabel")
UserLabel.Text = Players.LocalPlayer.Name
UserLabel.Size = UDim2.new(1, 0, 0, 20)
UserLabel.Position = UDim2.new(0, 0, 0, 85)
UserLabel.BackgroundTransparency = 1
UserLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
UserLabel.Font = Enum.Font.GothamBold
UserLabel.TextSize = 14
UserLabel.Parent = SideBar

-- Kapat Butonu (Sol Alt)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "KAPAT"
CloseBtn.Size = UDim2.new(0.8, 0, 0, 30)
CloseBtn.Position = UDim2.new(0.1, 0, 0.9, -10)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.Parent = SideBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-------------------------------------------------------------------------
-- 📊 BİLGİ PANELİ (Üst Kısım)
-------------------------------------------------------------------------
local InfoPanel = Instance.new("Frame")
InfoPanel.Size = UDim2.new(1, -150, 0, 80)
InfoPanel.Position = UDim2.new(0, 150, 0, 10)
InfoPanel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
InfoPanel.Parent = MainFrame
Instance.new("UICorner", InfoPanel).CornerRadius = UDim.new(0, 8)

-- Oyun Bilgilerini Çekme
local GameName = "Bilinmiyor"
local success, info = pcall(function()
    return MarketplaceService:GetProductInfo(game.PlaceId)
end)
if success then GameName = info.Name end

-- Oyun Adı Göstergesi
local GameTitle = Instance.new("TextLabel")
GameTitle.Text = "🎮 " .. GameName
GameTitle.Size = UDim2.new(1, -10, 0, 30)
GameTitle.Position = UDim2.new(0, 10, 0, 5)
GameTitle.BackgroundTransparency = 1
GameTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
GameTitle.Font = Enum.Font.GothamBlack
GameTitle.TextSize = 16
GameTitle.TextXAlignment = Enum.TextXAlignment.Left
GameTitle.Parent = InfoPanel

-- Oyun ID Göstergesi
local GameIDLabel = Instance.new("TextLabel")
GameIDLabel.Text = "🆔 ID: " .. game.PlaceId
GameIDLabel.Size = UDim2.new(1, -10, 0, 20)
GameIDLabel.Position = UDim2.new(0, 10, 0, 35)
GameIDLabel.BackgroundTransparency = 1
GameIDLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
GameIDLabel.Font = Enum.Font.Gotham
GameIDLabel.TextSize = 12
GameIDLabel.TextXAlignment = Enum.TextXAlignment.Left
GameIDLabel.Parent = InfoPanel

-- Durum (Supported/Unsupported)
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Text = "Durum: Kontrol ediliyor..."
StatusLabel.Size = UDim2.new(0, 150, 0, 20)
StatusLabel.Position = UDim2.new(0, 10, 0, 55)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 12
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = InfoPanel

-------------------------------------------------------------------------
-- 📜 SCRİPT LİSTESİ (Scrolling Frame)
-------------------------------------------------------------------------
local ScrollContainer = Instance.new("ScrollingFrame")
ScrollContainer.Size = UDim2.new(1, -160, 1, -110)
ScrollContainer.Position = UDim2.new(0, 150, 0, 100)
ScrollContainer.BackgroundTransparency = 1
ScrollContainer.ScrollBarThickness = 4
ScrollContainer.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 8)
UIList.Parent = ScrollContainer

-------------------------------------------------------------------------
-- FONKSİYON: Buton Ekleme
-------------------------------------------------------------------------
local function AddScriptButton(btnText, scriptFile, isHighlight)
    local Btn = Instance.new("TextButton")
    Btn.Text = btnText
    Btn.Size = UDim2.new(1, -10, 0, 40)
    Btn.BackgroundColor3 = isHighlight and Color3.fromRGB(0, 120, 215) or Color3.fromRGB(45, 45, 45)
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamSemibold
    Btn.TextSize = 14
    Btn.Parent = ScrollContainer
    
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    
    Btn.MouseButton1Click:Connect(function()
        Btn.Text = "Yükleniyor..."
        RunScript(scriptFile)
        wait(1)
        Btn.Text = "✅ Çalıştırıldı!"
        wait(1)
        Btn.Text = btnText
    end)
end

-------------------------------------------------------------------------
-- 🚀 OYUN ALGILAMA VE BUTONLARI EKLEME
-------------------------------------------------------------------------
local currentId = game.PlaceId
local foundGame = false

-- 1. BLOX FRUITS
if currentId == 2753915549 or currentId == 4442272183 or currentId == 7449423635 then
    foundGame = true
    StatusLabel.Text = "✅ HUB AKTİF (Blox Fruits)"
    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    
    -- En üste özel butonu koyuyoruz (Mavi renkli)
    AddScriptButton("⚔️ Blox Fruits Auto-Farm", "Games/BloxFruits.lua", true) 
end

-- 2. BROOKHAVEN
if currentId == 4924922222 then
    foundGame = true
    StatusLabel.Text = "✅ HUB AKTİF (Brookhaven)"
    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    AddScriptButton("🏡 Brookhaven Troll GUI", "Games/Brookhaven.lua", true)
end

-- 3. PRISON LIFE
if currentId == 155615604 then
    foundGame = true
    StatusLabel.Text = "✅ HUB AKTİF (Prison Life)"
    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    AddScriptButton("🚓 Prison Life Admin", "Games/PrisonLife.lua", true)
end

-- EĞER OYUN BULUNAMAZSA
if not foundGame then
    StatusLabel.Text = "⚠️ ÖZEL SCRİPT YOK"
    StatusLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
end

-- HER ZAMAN GÖRÜNECEK GENEL SCRİPTLER (Listenin altına eklenir)
AddScriptButton("🚀 Universal (Fly/Speed)", "Games/Universal.lua", false)
AddScriptButton("👻 Infinite Yield", "Games/IY.lua", false)
AddScriptButton("⚙️ FPS Booster", "Games/FPS.lua", false)
