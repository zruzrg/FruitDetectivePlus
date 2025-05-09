-- Fruit Detective+ for Blox Fruits
-- Created by [Your GitHub Username]
-- Loadstring compatible, professional, and smooth UI with advanced features

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local Workspace = game:GetService("Workspace")

-- UI Library (Kavo UI for smooth and professional look)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Fruit Detective+", "DarkTheme")

-- Settings
local Settings = {
    NotifierEnabled = true,
    TeleportEnabled = true,
    ESPEnabled = true,
    ESPColor = Color3.fromRGB(255, 0, 0),
}

-- Draggable Icon
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

local IconFrame = Instance.new("Frame")
IconFrame.Size = UDim2.new(0, 50, 0, 50)
IconFrame.Position = UDim2.new(0, 10, 0.5, -25)
IconFrame.BackgroundTransparency = 1
IconFrame.Parent = ScreenGui
IconFrame.Draggable = true

local IconImage = Instance.new("ImageLabel")
IconImage.Size = UDim2.new(1, 0, 1, 0)
IconImage.BackgroundTransparency = 1
IconImage.Image = "https://www.mignatis.com/image/cache/catalog/Metal-Tablo/kalp-ve-mustafa-kemal-ataturk-sari-zemin-metal-tablo-beyaz-renk-tasarimi-400x400.jpg"
IconImage.Parent = IconFrame
Instance.new("UICorner", IconImage).CornerRadius = UDim.new(0, 10)

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(1, 0, 1, 0)
ToggleButton.BackgroundTransparency = 1
ToggleButton.Text = ""
ToggleButton.Parent = IconFrame
ToggleButton.MouseButton1Click:Connect(function()
    Library:ToggleUI()
end)

-- Fruit Detection and ESP
local Fruits = {}
local ESPObjects = {}

local function CreateESP(Fruit)
    local Billboard = Instance.new("BillboardGui")
    Billboard.Size = UDim2.new(0, 100, 0, 50)
    Billboard.AlwaysOnTop = true
    Billboard.Adornee = Fruit
    Billboard.Parent = Fruit

    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = Fruit.Name or "??? Meyvesi"
    NameLabel.TextColor3 = Settings.ESPColor
    NameLabel.TextScaled = true
    NameLabel.Parent = Billboard

    local DistanceLabel = Instance.new("TextLabel")
    DistanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
    DistanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
    DistanceLabel.BackgroundTransparency = 1
    DistanceLabel.TextColor3 = Settings.ESPColor
    DistanceLabel.TextScaled = true
    DistanceLabel.Parent = Billboard

    local Highlight = Instance.new("Highlight")
    Highlight.FillColor = Settings.ESPColor
    Highlight.OutlineColor = Settings.ESPColor
    Highlight.Adornee = Fruit
    Highlight.Parent = Fruit

    ESPObjects[Fruit] = {Billboard = Billboard, Highlight = Highlight, DistanceLabel = DistanceLabel}
end

local function UpdateESP()
    for Fruit, ESP in pairs(ESPObjects) do
        if Fruit.Parent and Settings.ESPEnabled then
            ESP.Billboard.Enabled = true
            ESP.Highlight.Enabled = true
            local Distance = (LocalPlayer.Character.HumanoidRootPart.Position - Fruit.Position).Magnitude
            ESP.DistanceLabel.Text = math.floor(Distance) .. "m"
        else
            ESP.Billboard.Enabled = false
            ESP.Highlight.Enabled = false
        end
    end
end

local function NotifyFruit(Fruit)
    if Settings.NotifierEnabled then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Fruit Detective+",
            Text = (Fruit.Name or "??? Meyvesi") .. " Spawn Oldu!",
            Duration = 5
        })
    end
end

local function TeleportToFruit(Fruit)
    if Settings.TeleportEnabled and LocalPlayer.Character then
        local TweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear)
        local Tween = TweenService:Create(LocalPlayer.Character.HumanoidRootPart, TweenInfo, {CFrame = Fruit.CFrame})
        Tween:Play()
    end
end

-- Fruit Detection
Workspace.ChildAdded:Connect(function(Child)
    if Child:IsA("Model") and Child:FindFirstChild("Fruit") then
        Fruits[Child] = true
        CreateESP(Child)
        NotifyFruit(Child)
    end
end)

Workspace.ChildRemoved:Connect(function(Child)
    if Fruits[Child] then
        Fruits[Child] = nil
        if ESPObjects[Child] then
            ESPObjects[Child].Billboard:Destroy()
            ESPObjects[Child].Highlight:Destroy()
            ESPObjects[Child] = nil
        end
    end
end)

-- Update ESP
RunService.RenderStepped:Connect(UpdateESP)

-- UI Setup
local MainTab = Window:NewTab("Fruit Notifier+")
local MainSection = MainTab:NewSection("Settings")

MainSection:NewToggle("Spawn Bildirimi", "Enable/Disable spawn notifications", function(state)
    Settings.NotifierEnabled = state
end)

MainSection:NewToggle("Fruit TP", "Enable/Disable fruit teleport", function(state)
    Settings.TeleportEnabled = state
end)

MainSection:NewToggle("ESP", "Enable/Disable fruit ESP", function(state)
    Settings.ESPEnabled = state
end)

MainSection:NewColorPicker("ESP Rengi", "Change ESP color", Settings.ESPColor, function(color)
    Settings.ESPColor = color
    for _, ESP in pairs(ESPObjects) do
        ESP.Billboard.TextLabel.TextColor3 = color
        ESP.Billboard.DistanceLabel.TextColor3 = color
        ESP.Highlight.FillColor = color
        ESP.Highlight.OutlineColor = color
    end
end)

-- Teleport Button
MainSection:NewButton("Teleport to Nearest Fruit", "Teleports to the closest fruit", function()
    local ClosestFruit, ClosestDistance = nil, math.huge
    for Fruit in pairs(Fruits) do
        local Distance = (LocalPlayer.Character.HumanoidRootPart.Position - Fruit.Position).Magnitude
        if Distance < ClosestDistance then
            ClosestFruit = Fruit
            ClosestDistance = Distance
        end
    end
    if ClosestFruit then
        TeleportToFruit(ClosestFruit)
    end
end)

-- Cleanup on Script End
game:BindToClose(function()
    ScreenGui:Destroy()
    for _, ESP in pairs(ESPObjects) do
        ESP.Billboard:Destroy()
        ESP.Highlight:Destroy()
    end
end)
