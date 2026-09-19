-- Mengamankan UI di Solara
local ParentContainer = nil
if gethui then
    ParentContainer = gethui()
elseif cloneref then
    ParentContainer = cloneref(game:GetService("CoreGui"))
else
    ParentContainer = game:GetService("CoreGui")
end

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local DPUILibrary = {}

function DPUILibrary:CreateWindow(hubName, subTitle)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "DPUI_" .. math.random(1000, 9999)
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = ParentContainer

    -- ====================================================
    -- JENDELA UTAMA (MAIN WINDOW)
    -- ====================================================
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 680, 0, 460) -- Ukuran pas untuk layout Sidebar + Content
    MainFrame.Position = UDim2.new(0.5, -340, 0.5, -230)
    MainFrame.BackgroundColor3 = Color3.fromRGB(13, 14, 22) -- Navy gelap sesuai gambar
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = MainFrame

    -- Efek Glow Border Sederhana (Menggunakan Frame Tipis)
    local GlowBorder = Instance.new("UIStroke")
    GlowBorder.Color = Color3.fromRGB(35, 40, 65)
    GlowBorder.Thickness = 1.5
    GlowBorder.Parent = MainFrame

    -- ====================================================
    -- SIDEBAR (BAGIAN KIRI - MENU NAVIGASI)
    -- ====================================================
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 180, 1, 0)
    Sidebar.BackgroundColor3 = Color3.fromRGB(18, 19, 31) -- Lebih terang sedikit dari background
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame

    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 10)
    SidebarCorner.Parent = Sidebar

    -- Logo & Nama Hub di Atas Sidebar
    local LogoLabel = Instance.new("TextLabel")
    LogoLabel.Size = UDim2.new(1, 0, 0, 50)
    LogoLabel.Position = UDim2.new(0, 15, 0, 10)
    LogoLabel.BackgroundTransparency = 1
    LogoLabel.Text = "ðŸ‘‘ " .. (hubName or "DP UI")
    LogoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    LogoLabel.TextSize = 18
    LogoLabel.Font = Enum.Font.GothamBold
    LogoLabel.TextXAlignment = Enum.TextXAlignment.Left
    LogoLabel.Parent = Sidebar

    -- Container khusus untuk tombol-tombol Tab
    local TabButtonContainer = Instance.new("ScrollingFrame")
    TabButtonContainer.Size = UDim2.new(1, -20, 1, -120)
    TabButtonContainer.Position = UDim2.new(0, 10, 0, 65)
    TabButtonContainer.BackgroundTransparency = 1
    TabButtonContainer.BorderSizePixel = 0
    TabButtonContainer.ScrollBarThickness = 0
    TabButtonContainer.Parent = Sidebar

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Padding = UDim.new(0, 6)
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Parent = TabButtonContainer

    -- Profile Player di Bagian Bawah Sidebar (Persis seperti gambar)
    local ProfileFrame = Instance.new("Frame")
    ProfileFrame.Size = UDim2.new(1, -20, 0, 45)
    ProfileFrame.Position = UDim2.new(0, 10, 1, -55)
    ProfileFrame.BackgroundColor3 = Color3.fromRGB(25, 27, 43)
    ProfileFrame.BorderSizePixel = 0
    ProfileFrame.Parent = Sidebar
    Instance.new("UICorner", ProfileFrame).CornerRadius = UDim.new(0, 6)

    local ProfileName = Instance.new("TextLabel")
    ProfileName.Size = UDim2.new(1, -10, 1, 0)
    ProfileName.Position = UDim2.new(0, 10, 0, 0)
    ProfileName.BackgroundTransparency = 1
    ProfileName.Text = game:GetService("Players").LocalPlayer.Name
    ProfileName.TextColor3 = Color3.fromRGB(255, 255, 255)
    ProfileName.TextSize = 12
    ProfileName.Font = Enum.Font.GothamBold
    ProfileName.TextXAlignment = Enum.TextXAlignment.Left
    ProfileName.Parent = ProfileFrame

    -- ====================================================
    -- TOP BAR & CONTENT CONTAINER (BAGIAN KANAN)
    -- ====================================================
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, -180, 0, 50)
    TopBar.Position = UDim2.new(0, 180, 0, 0)
    TopBar.BackgroundTransparency = 1
    TopBar.Parent = MainFrame

    -- Judul Sub-Kategori di Topbar
    local SubLabel = Instance.new("TextLabel")
    SubLabel.Size = UDim2.new(1, -20, 1, 0)
    SubLabel.Position = UDim2.new(0, 20, 0, 0)
    SubLabel.BackgroundTransparency = 1
    SubLabel.Text = subTitle or "Library v1.0"
    SubLabel.TextColor3 = Color3.fromRGB(140, 145, 170)
    SubLabel.TextSize = 13
    SubLabel.Font = Enum.Font.GothamMedium
    SubLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubLabel.Parent = TopBar

    -- Fitur Dragging Manual agar Window Bisa Digeser lewat TopBar
    local dragging, dragInput, dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = MainFrame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    TopBar.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Tempat Halaman Konten (Pages Container)
    local PagesContainer = Instance.new("Frame")
    PagesContainer.Name = "PagesContainer"
    PagesContainer.Size = UDim2.new(1, -200, 1, -70)
    PagesContainer.Position = UDim2.new(0, 195, 0, 55)
    PagesContainer.BackgroundTransparency = 1
    PagesContainer.Parent = MainFrame

    -- ====================================================
    -- LOGIKA SISTEM TAB & HALAMAN
    -- ====================================================
    local Tabs = {}
    local firstTab = true

    function Tabs:CreateTab(tabName)
        -- 1. Membuat Halaman Isi (ScrollingFrame)
        local Page = Instance.new("ScrollingFrame")
        Page.Name = tabName .. "_Page"
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Color3.fromRGB(40, 45, 70)
        Page.Visible = firstTab -- Halaman pertama langsung aktif otomatis
        Page.Parent = PagesContainer

        local PageListLayout = Instance.new("UIListLayout")
        PageListLayout.Padding = UDim.new(0, 8)
        PageListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageListLayout.Parent = Page

        PageListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageListLayout.AbsoluteContentSize.Y + 10)
        end)

        -- 2. Membuat Tombol Navigasi Tab di Sidebar
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(1, 0, 0, 36)
        TabButton.BackgroundColor3 = firstTab and Color3.fromRGB(45, 50, 240) or Color3.fromRGB(24, 25, 38) -- Biru jika aktif
        TabButton.Text = "      " .. tabName
        TabButton.TextColor3 = firstTab and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 155, 180)
        TabButton.TextSize = 13
        TabButton.Font = Enum.Font.GothamMedium
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.Parent = TabButtonContainer
        Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 6)

        if firstTab then firstTab = false end

        -- Logika klik ganti Tab
        TabButton.MouseButton1Click:Connect(function()
            for _, p in pairs(PagesContainer:GetChildren()) do
                p.Visible = false
            end
            for _, btn in pairs(TabButtonContainer:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.BackgroundColor3 = Color3.fromRGB(24, 25, 38)
                    btn.TextColor3 = Color3.fromRGB(150, 155, 180)
                end
            end
            Page.Visible = true
            TabButton.BackgroundColor3 = Color3.fromRGB(45, 50, 240) -- Warna ungu/biru terang saat aktif
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        end)

        -- ====================================================
        -- KOMPONEN DI DALAM HALAMAN (ELEMENTS)
        -- ====================================================
        local Elements = {}

        -- 1. FUNGSI: MEMBUAT BUTTON (TOMBOL)
        function Elements:CreateButton(text, callback)
            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(1, -10, 0, 38)
            Button.BackgroundColor3 = Color3.fromRGB(22, 24, 38)
            Button.Text = "   " .. text
            Button.TextColor3 = Color3.fromRGB(230, 235, 255)
            Button.TextSize = 13
            Button.Font = Enum.Font.GothamMedium
            Button.TextXAlignment = Enum.TextXAlignment.Left
            Button.Parent = Page
            
            local BCorner = Instance.new("UICorner")
            BCorner.CornerRadius = UDim.new(0, 6)
            BCorner.Parent = Button
            
            local BStroke = Instance.new("UIStroke")
            BStroke.Color = Color3.fromRGB(35, 38, 60)
            BStroke.Parent = Button

            Button.MouseEnter:Connect(function() Button.BackgroundColor3 = Color3.fromRGB(30, 34, 55) end)
            Button.MouseLeave:Connect(function() Button.BackgroundColor3 = Color3.fromRGB(22, 24, 38) end)
            Button.MouseButton1:Connect(function() task.spawn(callback) end)

        function Elements:CreateToggle(text, default, callback)
            local state = default or false
            
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Size = UDim2.new(1, -10, 0, 40)
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(22, 24, 38)
            ToggleFrame.Parent = Page
            Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 6)
            local TStroke = Instance.new("UIStroke")
            TStroke.Color = Color3.fromRGB(35, 38, 60)
            TStroke.Parent = ToggleFrame

            local ToggleLabel = Instance.new("TextLabel")
            ToggleLabel.Size = UDim2.new(1, -60, 1, 0)
            ToggleLabel.Position = UDim2.new(0, 12, 0, 0)
            ToggleLabel.BackgroundTransparency = 1
            ToggleLabel.Text = text
            ToggleLabel.TextColor3 = Color3.fromRGB(230, 235, 255)
            ToggleLabel.TextSize = 13
            ToggleLabel.Font = Enum.Font.GothamMedium
            ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            ToggleLabel.Parent = ToggleFrame

            local Switch = Instance.new("TextButton")
            Switch.Size = UDim2.new(0, 36, 0, 18)
            Switch.Position = UDim2.new(1, -48, 0.5, -9)
            Switch.BackgroundColor3 = state and Color3.fromRGB(45, 50, 240) or Color3.fromRGB(45, 48, 70)
            Switch.Text = ""
            Switch.Parent = ToggleFrame
            Instance.new("UICorner" Switch).CornerRadius = UDim.new(1, 0)

            local SliderDot = Instance.new("Frame")
            SliderDot.Size = UDim2.new(0, 12, 0, 12)
            SliderDot.Position = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
            SliderDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SliderDot.Parent = Switch
            Instance.new("UICorner", SliderDot).CornerRadius = UDim.new(1, 0)

            Switch.MouseButton1:Connect(function()
            state = not state
            local targetColor = state and Color3.fromRGB(45, 50, 240) or Color3.fromRGB(45, 48, 70)
            local targetPos = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0.3, 0.5, -6)

            TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
            TweenService:Create(SliderDot, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = targetPos}):Play()
            task.spawn(callback, state)
            end)
        end
        return Elements
    end
    return Tabs
end

-- HTU
-- local DPUI = DPUILibrary:CreateWindow("DP UI HUB", "v1.0.0")

-- create tabs
-- local HomeTab = DPUI:CreateTab("Home")

-- Elements
-- HomeTab:CreateButton("SpeedHack", function()
--      game:GetService("Players").LocalPlayer.Character.Humanoid.WalkSpeed = 100
-- end)

-- Etc
