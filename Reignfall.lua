-- ========================================================================
-- SOLARA ZOMBIE-ONLY RADAR (FIXED REFRESH LOOPS & RAYFIELD RE-THEME)
-- ========================================================================

-- 1. LOAD RAYFIELD UI LIBRARY
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🧟 Zombie Tracker Elite",
   LoadingTitle = "Solara Interface Suite",
   LoadingSubtitle = "Zombie Only Mode V3",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

-- Memperbarui sedikit tampilan UI Rayfield dengan ikon Lucide khusus zombie
local MainTab = Window:CreateTab("Live Target Logs", 4483362458)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local trackedNPCs = {}
local uiLabels = {}

-- 2. FUNGSI UNTUK CEK APAKAH ZOMBIE BENAR-BENAR SUDAH JADI MAYAT
local function isDead(model)
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health <= 0 then return true end
    
    local altHP = model:GetAttribute("Health") or model:GetAttribute("HP")
    if altHP and altHP <= 0 then return true end
    
    -- Jika organ tubuh utama dihancurkan atau dihapus oleh game
    if not model:FindFirstChild("Head") and not model:FindFirstChild("HumanoidRootPart") then
        return true
    end
    
    if humanoid and humanoid:GetState() == Enum.HumanoidStateType.Dead then
        return true
    end
    
    return false
end

-- 3. FUNGSI UNTUK MENDAPATKAN PERSENTASE HP SINKRON SECARA LIVE
local function getLiveHealthPercent(model)
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    
    -- Cek Custom Attributes bawaan game
    local customHP = model:GetAttribute("Health") or model:GetAttribute("HP")
    local customMax = model:GetAttribute("MaxHealth") or model:GetAttribute("MaxHP")
    if customHP and customMax and customMax > 0 then
        return math.clamp(math.floor((customHP / customMax) * 100), 0, 100)
    end
    
    -- Cek properti Humanoid bawaan Roblox
    if humanoid and humanoid.MaxHealth > 0 then
        return math.clamp(math.floor((humanoid.Health / humanoid.MaxHealth) * 100), 0, 100)
    end
    
    return 100
end

-- 4. INTI PELACAKAN SINKRON (ANTI-STUCK LOOPS)
local function trackZombie(model)
    if trackedNPCs[model] then return end
    trackedNPCs[model] = true
    
    local elementId = tostring(math.random(100000, 999999))
    local initialHP = getLiveHealthPercent(model)
    
    -- Membuat baris list baru di UI Hub
    uiLabels[elementId] = MainTab:CreateLabel("🧟 " .. model.Name .. "  |  ❤️ HP: " .. tostring(initialHP) .. "%  |  📍 Jarak: Menyinkronkan...")
    
    -- LOOP LIVE RE-FETCH (Mengambil data tubuh setiap siklus agar tidak stuck)
    task.spawn(function()
        while model and model:IsDescendantOf(workspace) and trackedNPCs[model] do
            if isDead(model) then break end
            
            -- Re-fetch part tubuh zombie & player secara berkala agar tidak macet di memory client Solara
            local hrp = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso")
            local myChar = LocalPlayer.Character
            local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
            
            if myHrp and hrp then
                local distance = math.floor((myHrp.Position - hrp.Position).Magnitude)
                local liveHP = getLiveHealthPercent(model)
                
                if liveHP <= 0 then break end
                
                -- Update teks menggunakan perintah :Set() bawaan Rayfield secara real-time
                if uiLabels[elementId] and uiLabels[elementId].Set then
                    uiLabels[elementId]:Set(
                        string.format("🧟 %s  |  ❤️ HP: %d%%  |  📍 Jarak: %d studs", model.Name, liveHP, distance)
                    )
                end
            end
            task.wait(0.15) -- Refresh rate tinggi (0.15s) untuk responsivitas darah & jarak studs
        end
        
        -- HAPUS INSTAN DARI UI BEGITU JADI MAYAT / MATI
        if uiLabels[elementId] then
            pcall(function()
                uiLabels[elementId]:Destroy()
            end)
            uiLabels[elementId] = nil
        end
        trackedNPCs[model] = nil
    end)
end

-- 5. VALIDATOR PINTAR: FOKUS ZOMBIE SAJA (MENGABAIKAN NPC/PLAYER LAIN)
local function validateEntity(object)
    if not object:IsA("Model") then return end
    
    -- Ambil teks nama objek (ubah ke huruf kecil semua agar akurat)
    local objectName = string.lower(object.Name)
    
    -- FILTER UTAMA: Hanya deteksi model yang mengandung kata "zombie"
    if string.find(objectName, "zombie") then
        task.wait(0.1) -- Jeda mikro replikasi engine
        
        -- Abaikan jika ternyata itu nama player atau sudah mati semenjak spawn
        if object.Name == LocalPlayer.Name then return end
        if Players:GetPlayerFromCharacter(object) then return end
        
        if not isDead(object) then
            trackZombie(object)
        end
    end
end

-- 6. STARTING RADAR MANAGEMENT SYSTEM
for _, desc in ipairs(workspace:GetDescendants()) do
    validateEntity(desc)
end
workspace.DescendantAdded:Connect(validateEntity)

Rayfield:Notify({
   Title = "Zombie Tracker Active",
   Content = "Fokus mode: Zombie Only berhasil dimuat!",
   Duration = 3,
   Image = 4483362458,
})
