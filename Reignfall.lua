-- ========================================================================
-- SOLARA REIGN FALL EXCLUSIVE RADAR SUITE (HUSKS ONLY DETECTOR)
-- ========================================================================

-- 1. LOAD LIBRARY RESMI RAYFIELD
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🪦 Reign Fall: Husks Tracker",
   LoadingTitle = "Solara Interface Suite",
   LoadingSubtitle = "Kovrovka Apocalypse Mode V8",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

-- Membuat Tab Menu dengan Desain Clean Gelap Neon
local MainTab = Window:CreateTab("Live Husks Logs", nil)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local trackedNPCs = {}
local uiLabels = {}

-- Folder khusus penampung musuh yang di-generate engine Reign Fall
local EnemiesFolder = workspace:WaitForChild("Enemies", 5)

-- 2. REIGN FALL DEATH DETECTION (Mendeteksi penghapusan organ vital/despawn)
local function isHuskDead(model)
    if not model or not model:IsDescendantOf(workspace) then return true end
    
    -- Game Reign Fall langsung menghapus HRP atau mengubah nama model saat unit mati/ragdoll
    local hrp = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso")
    if not hrp then return true end
    
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health <= 0 then return true end
    
    return false
end

-- 3. CORE SINKRONISASI COORD LOGS (0.1s REFRESH)
local function trackHusk(model)
    if trackedNPCs[model] then return end
    trackedNPCs[model] = true
    
    local elementId = tostring(math.random(100000, 999999))
    
    -- Membuat satu baris log teks menggunakan komponen resmi Rayfield
    -- Catatan: HP ditampilkan "ACTIVE" karena status angka di Reign Fall terenkripsi penuh di server
    uiLabels[elementId] = MainTab:CreateLabel(
        string.format("💀 %s  |  ❤️ HP: ACTIVE  |  📍 Jarak: Menyinkronkan...", model.Name)
    )
    
    -- LOOP SINKRONISASI (REFRESH DATA SECARA RESPONSIF PER 0.1 DETIK)
    task.spawn(function()
        while model and model:IsDescendantOf(workspace) and trackedNPCs[model] do
            if isHuskDead(model) then break end
            
            local hrp = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso")
            local myChar = LocalPlayer.Character
            local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
            
            if myHrp and hrp then
                local distance = math.floor((myHrp.Position - hrp.Position).Magnitude)
                
                -- Update teks menggunakan method :Update() resmi bawaan Rayfield
                if uiLabels[elementId] and uiLabels[elementId].Update then
                    uiLabels[elementId]:Update(
                        string.format("💀 %s  |  ❤️ Status: ALIVE  |  📍 Jarak: %d studs", model.Name, distance)
                    )
                end
            end
            task.wait(0.1) -- Dipersingkat ke 0.1s agar pergerakan jarak saat kamu berlari sangat mulus
        end
        
        -- MENGHAPUS HUSK SECARA INSTAN BEGITU MATI / DESPAWN
        if uiLabels[elementId] then
            pcall(function()
                uiLabels[elementId]:Destroy()
            end)
            uiLabels[elementId] = nil
        end
        trackedNPCs[model] = nil
    end)
end

-- 4. VALIDATOR KHUSUS FAKSI ENEMIES REIGN FALL
local function validateHusk(object)
    if not object:IsA("Model") then return end
    task.wait(0.05) -- Jeda mikro render
    
    -- Karena berada di dalam folder Enemies, kita pastikan objek tersebut bukan Player yang tidak sengaja bug masuk folder
    if object.Name == LocalPlayer.Name then return end
    if Players:GetPlayerFromCharacter(object) then return end
    
    if not isHuskDead(object) then
        trackHusk(object)
    end
end

-- 5. INITIAL ENGINE BOOT UP
-- Jika folder Enemies ditemukan, langsung kunci pelacakan ke dalam folder tersebut (sangat hemat FPS)
if EnemiesFolder then
    for _, item in ipairs(EnemiesFolder:GetChildren()) do
        validateHusk(item)
    end
    EnemiesFolder.ChildAdded:Connect(validateHusk)
else
    -- Fallback jika tipe map memuat di direktori flat workspace utama
    for _, desc in ipairs(workspace:GetDescendants()) do
        if desc.Parent and desc.Parent.Name == "Enemies" then
            validateHusk(desc)
        end
    end
    workspace.DescendantAdded:Connect(validateHusk)
end

Rayfield:Notify({
   Title = "Reign Fall Radar Online",
   Content = "Target dikunci ke folder workspace.Enemies!",
   Duration = 3
})
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
