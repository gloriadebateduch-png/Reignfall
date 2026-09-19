-- ========================================================================
-- SOLARA ZOMBIE RADAR - PURE SMART NPC DETECTION (NO KEYWORDS)
-- ========================================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu'))()

local Window = Rayfield:CreateWindow({
   Name = "🧟 Pure Smart Tracker",
   LoadingTitle = "Solara Interface Suite",
   LoadingSubtitle = "Smart Detection Mode V6",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

local MainTab = Window:CreateTab("Live Targets", nil)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local trackedNPCs = {}
local uiLabels = {}

-- 1. UTILITY: CEK APAKAH ENTITAS SUDAH MENJADI MAYAT
local function isDead(model)
    if not model or not model:IsDescendantOf(workspace) then return true end
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health <= 0 then return true end
    
    local altHP = model:GetAttribute("Health") or model:GetAttribute("HP")
    if altHP and altHP <= 0 then return true end
    
    -- Jaga-jaga jika bagian tubuh utama hancur lebur / dihapus game saat mati (Ragdoll)
    if not model:FindFirstChild("Head") and not model:FindFirstChild("HumanoidRootPart") then
        return true
    end
    return false
end

-- 2. UTILITY: SINKRONISASI HITUNGAN PERSENTASE HP REAL-TIME
local function getLiveHealthPercent(model)
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    local customHP = model:GetAttribute("Health") or model:GetAttribute("HP")
    local customMax = model:GetAttribute("MaxHealth") or model:GetAttribute("MaxHP")
    
    if customHP and customMax and customMax > 0 then
        return math.clamp(math.floor((customHP / customMax) * 100), 0, 100)
    end
    if humanoid and humanoid.MaxHealth > 0 then
        return math.clamp(math.floor((humanoid.Health / humanoid.MaxHealth) * 100), 0, 100)
    end
    return 100
end

-- 3. UTILITY: POLA PELACAKAN LIVE SINKRONISASI (JARAK STUDS & PERSEN HP)
local function trackZombie(model)
    if trackedNPCs[model] then return end
    trackedNPCs[model] = true
    
    local elementId = tostring(math.random(100000, 999999))
    local initialHP = getLiveHealthPercent(model)
    
    uiLabels[elementId] = MainTab:CreateLabel(
        string.format("🧟 %s  |  ❤️ HP: %d%%  |  📍 Jarak: Menyinkronkan...", model.Name, initialHP)
    )
    
    task.spawn(function()
        while model and model:IsDescendantOf(workspace) and trackedNPCs[model] do
            if isDead(model) then break end
            
            -- Ambil ulang posisi tubuh setiap kali berputar agar jarak studs tidak stuck/macet
            local hrp = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso")
            local myChar = LocalPlayer.Character
            local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
            
            if myHrp and hrp then
                local distance = math.floor((myHrp.Position - hrp.Position).Magnitude)
                local liveHP = getLiveHealthPercent(model)
                
                if liveHP <= 0 then break end
                
                if uiLabels[elementId] and uiLabels[elementId].Update then
                    uiLabels[elementId]:Update(
                        string.format("🧟 %s  |  ❤️ HP: %d%%  |  📍 Jarak: %d studs", model.Name, liveHP, distance)
                    )
                end
            end
            task.wait(0.15)
        end
        
        -- MEMBERSIHKAN SECARA INSTAN KETIKA MENJADI MAYAT / DESPAWN
        if uiLabels[elementId] then
            pcall(function()
                uiLabels[elementId]:Destroy()
            end)
            uiLabels[elementId] = nil
        end
        trackedNPCs[model] = nil
    end)
end

-- 4. SMART RADAR DETECTOR ENGINE (SISTEM FILTRASI ANATOMI FISIK)
local function validateEntity(object)
    if not object:IsA("Model") then return end
    
    -- Jeda mikro agar Solara selesai menerima sinkronisasi data dari server Roblox
    task.wait(0.1)
    
    local humanoid = object:FindFirstChildOfClass("Humanoid")
    if humanoid then
        -- FILTRASI PINTAR MURNI:
        if object == LocalPlayer.Character then return end -- Singkirkan karaktermu sendiri
        if Players:GetPlayerFromCharacter(object) then return end -- Singkirkan player asli lain di server
        
        -- Jika lolos seleksi di atas, artinya entitas ini adalah valid NPC/Musuh/Zombie yang aktif!
        if not isDead(object) then
            trackZombie(object)
        end
    end
end

-- 5. INITIALIZATION RUN
for _, desc in ipairs(workspace:GetDescendants()) do
    validateEntity(desc)
end
workspace.DescendantAdded:Connect(validateEntity)

Rayfield:Notify({
   Title = "Smart Radar Suite",
   Content = "Metode deteksi pintar non-keyword berhasil aktif!",
   Duration = 3
})
