local player = game.Players.LocalPlayer
local workspace = game.Workspace
local runService = game.RunService
local tweenService = game.TweenService

local fruitESPColor = Color3.new(1, 0, 0) -- Varsayılan renk: Kırmızı
local notificationEnabled = true
local teleportEnabled = false
local espEnabled = true

local activeFruits = {}

-- Hub GUI Oluşturma
local screenGui = Instance.new("ScreenGui", player.PlayerGui)
screenGui.Name = "FruitDetectorHub"

-- İkon Oluşturma
local iconFrame = Instance.new("Frame", screenGui)
iconFrame.Size = UDim2.new(0, 50, 0, 50)
iconFrame.Position = UDim2.new(0, 10, 0.5, -25)
iconFrame.BackgroundColor3 = Color3.new(0, 0, 1) -- Mavi ikon (logo yerine geçici)
local corner = Instance.new("UICorner", iconFrame)
corner.CornerRadius = UDim.new(0.5) -- Yuvarlak köşeler
local clickDetector = Instance.new("TextButton", iconFrame)
clickDetector.Size = UDim2.new(1, 0, 1, 0)
clickDetector.BackgroundTransparency = 1
clickDetector.Text = ""

-- Hub Frame Oluşturma
local hubFrame = Instance.new("Frame", screenGui)
hubFrame.Size = UDim2.new(0, 200, 0, 300)
hubFrame.Position = UDim2.new(-0.5, 0, 0.5, -150) -- Başlangıçta ekran dışında
hubFrame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2) -- Koyu gri arka plan
hubFrame.Visible = true
local closedPos = UDim2.new(-0.5, 0, 0.5, -150)
local openPos = UDim2.new(0, 60, 0.5, -150)

-- Hub Başlığı
local hubTitle = Instance.new("TextLabel", hubFrame)
hubTitle.Size = UDim2.new(0, 180, 0, 30)
hubTitle.Position = UDim2.new(0, 10, 0, 10)
hubTitle.BackgroundTransparency = 1
hubTitle.Text = "Fruit Notifier+"
hubTitle.TextColor3 = Color3.new(1, 1, 1)
hubTitle.TextSize = 20

-- Toggle Butonları
local notifyToggle = Instance.new("TextButton", hubFrame)
notifyToggle.Size = UDim2.new(0, 180, 0, 30)
notifyToggle.Position = UDim2.new(0, 10, 0, 50)
notifyToggle.Text = "Spawn Bildirimi: AÇIK"
notifyToggle.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
notifyToggle.TextColor3 = Color3.new(1, 1, 1)
notifyToggle.MouseButton1Click:Connect(function()
    notificationEnabled = not notificationEnabled
    notifyToggle.Text = "Spawn Bildirimi: " .. (notificationEnabled and "AÇIK" or "KAPALI")
end)

local teleportToggle = Instance.new("TextButton", hubFrame)
teleportToggle.Size = UDim2.new(0, 180, 0, 30)
teleportToggle.Position = UDim2.new(0, 10, 0, 90)
teleportToggle.Text = "Teleport: KAPALI"
teleportToggle.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
teleportToggle.TextColor3 = Color3.new(1, 1, 1)
teleportToggle.MouseButton1Click:Connect(function()
    teleportEnabled = not teleportEnabled
    teleportToggle.Text = "Teleport: " .. (teleportEnabled and "AÇIK" or "KAPALI")
end)

local espToggle = Instance.new("TextButton", hubFrame)
espToggle.Size = UDim2.new(0, 180, 0, 30)
espToggle.Position = UDim2.new(0, 10, 0, 130)
espToggle.Text = "ESP: AÇIK"
espToggle.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
espToggle.TextColor3 = Color3.new(1, 1, 1)
espToggle.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espToggle.Text = "ESP: " .. (espEnabled and "AÇIK" or "KAPALI")
    if espEnabled then
        for fruit in pairs(activeFruits) do
            createESP(fruit)
        end
    else
        for fruit in pairs(activeFruits) do
            removeESP(fruit)
        end
    end
end)

-- ESP Renk Seçimi
local colors = {Color3.new(1, 0, 0), Color3.new(0, 1, 0), Color3.new(0, 0, 1)} -- Kırmızı, Yeşil, Mavi
for i, color in ipairs(colors) do
    local btn = Instance.new("TextButton", hubFrame)
    btn.Size = UDim2.new(0, 50, 0, 30)
    btn.Position = UDim2.new(0, 10 + (i - 1) * 60, 0, 170)
    btn.BackgroundColor3 = color
    btn.Text = ""
    btn.MouseButton1Click:Connect(function()
        fruitESPColor = color
        -- Mevcut ESP'leri güncelle
        for fruit in pairs(activeFruits) do
            local selection = fruit:FindFirstChild("ESPSelection")
            if selection then
                selection.Color3 = color
            end
        end
    end)
end

-- İkonu Sürükleme
local dragging
local dragStart
local startPos
iconFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = iconFrame.Position
    end
end)
iconFrame.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        iconFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
iconFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Hub Açma/Kapama Animasyonu
clickDetector.MouseButton1Click:Connect(function()
    if hubFrame.Position == closedPos then
        local tween = tweenService:Create(hubFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = openPos})
        tween:Play()
    else
        local tween = tweenService:Create(hubFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = closedPos})
        tween:Play()
    end
end)

-- Bildirim GUI
local notifyGui = Instance.new("ScreenGui", player.PlayerGui)
notifyGui.Name = "FruitNotification"
local notifyLabel = Instance.new("TextLabel", notifyGui)
notifyLabel.Size = UDim2.new(1, 0, 0, 50)
notifyLabel.Position = UDim2.new(0, 0, 0, 0)
notifyLabel.BackgroundTransparency = 1
notifyLabel.TextColor3 = Color3.new(1, 1, 1)
notifyLabel.TextSize = 20
notifyLabel.Visible = false

local function showNotification(text)
    notifyLabel.Text = text
    notifyLabel.Visible = true
    wait(5)
    notifyLabel.Visible = false
end

-- Fruit Tespiti
workspace.DescendantAdded:Connect(function(descendant)
    if descendant.Name:find("Fruit") then -- Fruit isimlendirmesi oyuna göre ayarlanmalı
        local fruit = descendant
        if not activeFruits[fruit] then
            activeFruits[fruit] = true
            if notificationEnabled then
                showNotification(fruit.Name .. " Adlı Fruit Spawn Oldu")
            end
            if espEnabled then
                createESP(fruit)
            end
            if teleportEnabled then
                teleportToFruit(fruit)
            end
            -- Fruit kaybolduğunda ESP'yi kaldır
            fruit.AncestryChanged:Connect(function()
                if not fruit:IsDescendantOf(workspace) then
                    removeESP(fruit)
                    activeFruits[fruit] = nil
                end
            end)
        end
    end
end)

-- ESP Oluşturma
function createESP(fruit)
    local selectionBox = Instance.new("SelectionBox", fruit)
    selectionBox.Name = "ESPSelection"
    selectionBox.Adornee = fruit
    selectionBox.LineThickness = 0.05
    selectionBox.Color3 = fruitESPColor

    local bbGui = Instance.new("BillboardGui", fruit)
    bbGui.Name = "ESPBillboard"
    bbGui.AlwaysOnTop = true
    bbGui.Size = UDim2.new(0, 200, 0, 50)
    bbGui.StudsOffset = Vector3.new(0, 3, 0) -- Fruitin üstünde

    local nameLabel = Instance.new("TextLabel", bbGui)
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.Text = fruit.Name -- Bilinmeyen meyve için ??? eklenebilir

    local distanceLabel = Instance.new("TextLabel", bbGui)
    distanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
    distanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.TextColor3 = Color3.new(1, 1, 1)

    -- Mesafe Güncelleme
    local function updateDistance()
        local playerChar = player.Character
        if playerChar and playerChar:FindFirstChild("HumanoidRootPart") then
            local hrp = playerChar.HumanoidRootPart
            local distance = (fruit.Position - hrp.Position).Magnitude
            distanceLabel.Text = tostring(math.floor(distance)) .. " m"
        end
    end
    runService.Heartbeat:Connect(updateDistance)
end

-- ESP Kaldırma
function removeESP(fruit)
    local selection = fruit:FindFirstChild("ESPSelection")
    if selection then selection:Destroy() end
    local bbGui = fruit:FindFirstChild("ESPBillboard")
    if bbGui then bbGui:Destroy() end
end

-- Fruit'e Teleport
function teleportToFruit(fruit)
    local playerChar = player.Character
    if playerChar and playerChar:FindFirstChild("HumanoidRootPart") then
        local hrp = playerChar.HumanoidRootPart
        local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear)
        local tween = tweenService:Create(hrp, tweenInfo, {CFrame = fruit.CFrame})
        tween:Play()
    end
end