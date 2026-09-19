-- ========================================================================
-- SOLARA REIGN FALL OFFLINE HUB (RAYFIELD DARK NEON STYLE)
-- ========================================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Bersihkan UI lama jika ada
if CoreGui:FindFirstChild("ReignFallHuskHub") then
    CoreGui.ReignFallHuskHub:Destroy()
end

-- 1. MEMBUAT WINDOW HUB VISUAL (Desain Rayfield Lokal)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ReignFallHuskHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

local mainHub = Instance.new("Frame")
mainHub.Size = UDim2.new(0, 390, 0, 310)
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
titleLabel.Text = "  🪦 REIGN FALL: HUSKS TRACKER"
titleLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
titleLabel.TextSize = 13
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
container.Size = UDim2.new(1, -20, 1, -50)
container.Position = UDim2.new(0, 10, 0, 42)
container.BackgroundTransparency = 1
container.BorderSizePixel = 0
container.ScrollBarThickness = 2
container.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 150)
container.CanvasSize = UDim2.new(0, 0, 0, 0)
container.Parent = mainHub

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Padding = UDim.new(0, 5)
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Parent = container

uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    container.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y + 10)
end)

local trackedNPCs = {}
local EnemiesFolder = workspace:FindFirstChild("Enemies")

-- 2. FUNGSI CEK HUSK MATI
local function isHuskDead(model)
    if not model or not model:IsDescendantOf(workspace) then return true end
    local hrp = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso")
    if not hrp then return true end
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health <= 0 then return true end
    return false
end

-- 3. CORE SINKRONISASI JARAK HUSK (0.1s REFRESH)
local function trackHusk(model)
    if trackedNPCs[model] then return end
    trackedNPCs[model] = true

    local logFrame = Instance.new("Frame")
    logFrame.Size = UDim2.new(1, 0, 0, 30)
    logFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    logFrame.Parent = container

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 5)
    rowCorner.Parent = logFrame

    local rowStroke = Instance.new("UIStroke")
    rowStroke.Color = Color3.fromRGB(0, 255, 150)
    rowStroke.Thickness = 1
    rowStroke.Transparency = 0.6
    rowStroke.Parent = logFrame

    local logText = Instance.new("TextLabel")
    logText.Size = UDim2.new(1, -10, 1, 0)
    logText.Position = UDim2.new(0, 10, 0, 0)
    logText.BackgroundTransparency = 1
    logText.TextColor3 = Color3.fromRGB(230, 230, 230)
    logText.TextSize = 11
    logText.Font = Enum.Font.GothamBold
    logText.TextXAlignment = Enum.TextXAlignment.Left
    logText.Text = string.format("💀 %s | ❤️ ALIVE | 📍 Jarak: Calculating...", model.Name)
    logText.Parent = logFrame

    task.spawn(function()
        while model and model:IsDescendantOf(workspace) and trackedNPCs[model] do
            if isHuskDead(model) then break end
            
            local hrp = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso")
            local myChar = LocalPlayer.Character
            local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
            
            if myHrp and hrp then
                local distance = math.floor((myHrp.Position - hrp.Position).Magnitude)
                logText.Text = string.format("💀 %s  |  ❤️ Status: ALIVE  |  📍 Jarak: %d studs", model.Name, distance)
            end
            task.wait(0.1)
        end
        
        logFrame:Destroy()
        trackedNPCs[model] = nil
    end)
end

-- 4. VALIDASI FAKSI ENEMIES
local function validateHusk(object)
    if not object:IsA("Model") then return end
    if object.Name == LocalPlayer.Name then return end
    if Players:GetPlayerFromCharacter(object) then return end
    
    if not isHuskDead(object) then
        trackHusk(object)
    end
end

if EnemiesFolder then
    for _, item in ipairs(EnemiesFolder:GetChildren()) do
        validateHusk(item)
    end
    EnemiesFolder.ChildAdded:Connect(validateHusk)
else
    for _, desc in ipairs(workspace:GetDescendants()) do
        if desc.Parent and desc.Parent.Name == "Enemies" then
            validateHusk(desc)
        end
    end
    workspace.DescendantAdded:Connect(validateHusk)
end
