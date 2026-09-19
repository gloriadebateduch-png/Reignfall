-- ========================================================================
-- SOLARA ZOMBIE ONLY RADAR - OFFICIAL RAYFIELD INTERFACE SUITE
-- ========================================================================

-- 1. LOAD LIBRARY RESMI RAYFIELD
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🧟 Zombie Tracker Elite",
   LoadingTitle = "Solara Interface Suite",
   LoadingSubtitle = "Zombie Only Mode V4",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

-- Membuat Tab Menu dengan Desain Clean Gelap Neon
local MainTab = Window:CreateTab("Live Targets", nil)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local trackedNPCs = {}
local uiLabels = {}

-- 2. FUNGSI DETEKSI INSTAN ZOMBIE TELAH MENJADI MAYAT
local function isDead(model)
    if not model or not model:IsDescendantOf(workspace) then return true end
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health <= 0 then return true end
    
    local altHP = model:GetAttribute("Health") or model:GetAttribute("HP")
    if altHP and altHP <= 0 then return true end
    
    -- Jaga-jaga jika sendi tubuh utama/HRP langsung dihancurkan game (Despawn)
    if not model:FindFirstChild("Head") and not model:FindFirstChild("HumanoidRootPart") then
        return true
    end
    return false
end

-- 3. MENGHITUNG PERSENTASE HP SINKRON SECARA REAL-TIME
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

-- 4. REAL-TIME PELACAKAN SINKRONISASI JARAK & UPDATE RADAR
local function trackZombie(model)
    if trackedNPCs[model] then return end
    trackedNPCs[model] = true
    
    local elementId = tostring(math.random(100000, 999999))
    local initialHP = getLiveHealthPercent(model)
    
    -- Membuat satu baris log teks menggunakan komponen resmi Rayfield
    uiLabels[elementId] = MainTab:CreateLabel(
        string.format("🧟 %s  |  ❤️ HP: %d%%  |  📍 Jarak: Menyinkronkan...", model.Name, initialHP)
    )
    
    -- LOOP SINKRONISASI (REFRESH DATA SECARA RESPONSIF PER 0.15 DETIK)
    task.spawn(function()
        while model and model:IsDescendantOf(workspace) and trackedNPCs[model] do
            if isDead(model) then break end
            
            -- Ambil paksa posisi koordinat part tubuh zombie & player saat ini
            local hrp = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso")
            local myChar = LocalPlayer.Character
            local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
            
            if myHrp and hrp then
                local distance = math.floor((myHrp.Position - hrp.Position).Magnitude)
                local liveHP = getLiveHealthPercent(model)
                
                if liveHP <= 0 then break end
                
                -- UPDATE TEKS: Menggunakan method :Update() resmi bawaan Rayfield
                if uiLabels[elementId] and uiLabels[elementId].Update then
                    uiLabels[elementId]:Update(
                        string.format("🧟 %s  |  ❤️ HP: %d%%  |  📍 Jarak: %d studs", model.Name, liveHP, distance)
                    )
                end
            end
            task.wait(0.15)
        end
        
        -- MENGHAPUS MAYAT SECARA INSTAN TANPA MENUMPUK DI MENU HUB
        if uiLabels[elementId] then
            pcall(function()
                uiLabels[elementId]:Destroy()
            end)
            uiLabels[elementId] = nil
        end
        trackedNPCs[model] = nil
    end)
end

-- 5. VALIDATOR: MENYARING HANYA ZOMBIE MURNI (MENGABAIKAN PLAYER/NPC LAIN)
local function validateEntity(object)
    if not object:IsA("Model") then return end
    
    -- Mengubah string nama objek ke huruf kecil semua agar filter akurat
    local objectName = string.lower(object.Name)
    
    -- FILTER UTAMA: Hanya jalankan jika nama objek/nama foldernya mengandung kata zombie/monster
    if string.find(objectName, "zombie") or string.find(objectName, "monster") or object.Parent.Name:lower():find("zombie") then
        task.wait(0.15) -- Jeda mikro agar client selesai merender komponen tubuh dari server
        
        if object.Name == LocalPlayer.Name then return end
        if Players:GetPlayerFromCharacter(object) then return end
        
        if not isDead(object) then
            trackZombie(object)
        end
    end
end

-- 6. BOOT RADAR SYSTEM
for _, desc in ipairs(workspace:GetDescendants()) do
    validateEntity(desc)
end
workspace.DescendantAdded:Connect(validateEntity)

Rayfield:Notify({
   Title = "Zombie Tracker Active",
   Content = "Berhasil memuat log dengan Rayfield UI!",
   Duration = 3
})
