-- ========================================================================
-- REIGNFALL SMART RADAR - PURE PHYSICAL DETECTION (NO KEYWORDS / NO FOLDERS)
-- ========================================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- Bersihkan UI lama jika Anda mengeksekusi ulang skrip
if CoreGui:FindFirstChild("ReignfallSmartHubUI") then
    CoreGui.ReignfallSmartHubUI:Destroy()
end

-- 1. MEMBUAT WINDOW HUB OFFLINE (Anti Error Line 1 / Anti Time Out)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ReignfallSmartHubUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui 

local mainHub = Instance.new("Frame")
mainHub.Size = UDim2.new(0, 390, 0, 320)
mainHub.Position = UDim2.new(0.05, 0, 0.2, 0)
mainHub.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
mainHub.BackgroundTransparency = 0.05
mainHub.Active = true
mainHub.Draggable = true
mainHub.Parent = screenGui

local hubCorner = Instance.new("UICorner")
hubCorner.CornerRadius = UDim.new(0, 8)
hubCorner.Parent = mainHub

local hubStroke = Instance.new("UIStroke")
hubStroke.Color = Color3.fromRGB(0, 255, 150)
hubStroke.Thickness = 1.5
hubStroke.Transparency = 0.4
hubStroke.Parent = mainHub

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 35)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "  🧟 SMART RADAR: LIVE TARGETS (NO KEYWORDS)"
titleLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
titleLabel.TextSize = 12
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = mainHub

local line = Instance.new("Frame")
line.Size = UDim2.new(1, -20, 0, 1)
line.Position = UDim2.new(0, 10, 0, 35)
line.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
line.BorderSizePixel = 0
line.Parent = mainHub

local container = Instance.new("ScrollingFrame")
container.Name = "LogContainer"
container.Size = UDim2.new(1, -20, 1, -55)
container.Position = UDim2.new(0, 10, 0, 45)
container.BackgroundTransparency = 1
container.BorderSizePixel = 0
container.ScrollBarThickness = 2
container.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 150)
container.CanvasSize = UDim2.new(0, 0, 0, 0)
container.Parent = mainHub

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Padding = UDim.new(0, 6)
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Parent = container

uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    container.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y + 10)
end)

local trackedNPCs = {}

-- 2. DETEKSI STATUS MATI/DESPAWN AGRESIF (SINKRON DENGAN REIGNFALL)
local function isTargetDead(model)
    if not model or not model:IsDescendantOf(workspace) then return true end
    
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health <= 0 then return true end
    
    -- Cek jika organ vital hilang karena mutilasi/ragdoll khas Reignfall
    if not model:FindFirstChild("HumanoidRootPart") and not model:FindFirstChild("Torso") then
        return true
    end
    
    return false
end

-- 3. INTERFACES & REAL-TIME TRACKING LOOP (0.1s REFRESH)
local function startTracking(model)
    if trackedNPCs[model] then return end
    trackedNPCs[model] = true

    local logFrame = Instance.new("Frame")
    logFrame.Size = UDim2.new(1, 0, 0, 32)
    logFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    logFrame.Parent = container

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 5)
    rowCorner.Parent = logFrame

    local rowStroke = Instance.new("UIStroke")
    rowStroke.Color = Color3.fromRGB(0, 255, 150)
    rowStroke.Thickness = 1
    rowStroke.Transparency = 0.7
    rowStroke.Parent = logFrame

    local logText = Instance.new("TextLabel")
    logText.Size = UDim2.new(1, -10, 1, 0)
    logText.Position = UDim2.new(0, 10, 0, 0)
    logText.BackgroundTransparency = 1
    logText.TextColor3 = Color3.fromRGB(235, 235, 235)
    logText.TextSize = 11
    logText.Font = Enum.Font.GothamBold
    logText.TextXAlignment = Enum.TextXAlignment.Left
    logText.Text = string.format("⚔️ %s | 📍 Jarak: Menghitung...", model.Name)
    logText.Parent = logFrame

    task.spawn(function()
        while model and model:IsDescendantOf(workspace) and trackedNPCs[model] do
            if isTargetDead(model) then break end
            
            -- FORCED REAL-TIME RE-FETCH: Membaca posisi secara agresif di mana pun zombie berada
            local hrp = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso")
            local myChar = LocalPlayer.Character
            local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
            
            if myHrp and hrp then
                local distance = math.floor((myHrp.Position - hrp.Position).Magnitude)
                logText.Text = string.format("🧟 %s  |  ❤️ Status: ACTIVE  |  📍 Jarak: %d studs", model.Name, distance)
            end
            task.wait(0.1) -- Refresh rate tinggi 0.1 detik agar studs jarak bergerak mulus saat bertarung
        end

        -- HAPUS INSTAN JIKA MATI / HANCUR / DESPAWN (Mencegah Mayat Menumpuk)
        local fadeOut = TweenService:Create(logFrame, TweenInfo.new(0.1), {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0)})
        TweenService:Create(rowStroke, TweenInfo.new(0.1), {Transparency = 1}):Play()
        TweenService:Create(logText, TweenInfo.new(0.1), {TextTransparency = 1}):Play()
        fadeOut:Play()
        fadeOut.Completed:Connect(function()
            logFrame:Destroy()
        end)
        trackedNPCs[model] = nil
    end)
end

-- 4. SMART PURE DETECTOR ENGINE (Saringan Fisik Tanpa Nama / Tanpa Folder)
local function validateEntity(object)
    if not object:IsA("Model") then return end
    
    -- Jeda mikro untuk memastikan seluruh komponen sendi objek direplikasi sempurna oleh Solara
    task.wait(0.1)
    
    local humanoid = object:FindFirstChildOfClass("Humanoid")
    if humanoid then
        -- SELEKSI PINTAR MURNI:
        if object == LocalPlayer.Character then return end -- Abaikan Karakter Anda sendiri
        if Players:GetPlayerFromCharacter(object) then return end -- Abaikan Player Asli lain yang ada di room

        -- Jika lolos seleksi di atas, berarti objek ini dipastikan adalah Zombie/Musuh yang sedang aktif!
        if not isTargetDead(object) then
            startTracking(object)
        end
    end
end

-- 5. RUNNING SCANNER (Menyisir Seluruh Penjuru Workspace Secara Agresif)
for _, desc in ipairs(workspace:GetDescendants()) do
    validateEntity(desc)
end
workspace.DescendantAdded:Connect(validateEntity)
