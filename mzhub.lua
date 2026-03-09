--[[
  SISTEMA DE KEY + MZ HUB (TUDO EM UM)
  Keys válidas: "MZ-CLIENT-7Q2L9F-K4X8PA-T6Z3RM-91WV" e "cleude09"
  Após key correta, carrega o MZ Hub.
]]

local KEY_CLIENTE = "MZ-CLIENT-7Q2L9F-K4X8PA-T6Z3RM-91WV"
local KEY_DONO = "cleude09"
local LINK_KEY = "https://link-center.net/4011881/g1uHRMybfTo9"

-- Variável para controle de liberação (em memória)
getgenv().MZ_LIBERADO = getgenv().MZ_LIBERADO or false

-- Se já estiver liberado, carrega direto o MZ Hub
if getgenv().MZ_LIBERADO then
    loadstring([[
        -- ========== CÓDIGO DO MZ HUB ==========
        local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local cfg = {
    ESP = false, 
    AimbotMode = nil, 
    FOV = false, 
    FOVSize = 100,
    FOVPos = 0,
    LEDActive = false,
    LEDSpeed = 5,
    MenuScale = 1,
    MenuWidth = 220,
    InfJump = false,
    WalkSpeed = 16,
    NoGravity = false
}

local ledStrokes = {}
local btnUpdates = {}
local ESPs = {} -- Tabela do seu script de ESP otimizado

-- --- SISTEMA VISUAL DO FOV ---
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1
fovCircle.Transparency = 0.7
fovCircle.Color = Color3.new(1, 1, 1)
fovCircle.Filled = false

-- --- LÓGICA DO AIMBOT ---
local function getClosestPlayer()
    local target = nil
    local shortestDistance = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                if onScreen then
                    local mousePos = UserInputService:GetMouseLocation()
                    local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                    if distance < shortestDistance and distance <= cfg.FOVSize then
                        shortestDistance = distance
                        target = player
                    end
                end
            end
        end
    end
    return target
end

-- --- LÓGICA DO ESP OTIMIZADO (INTEGRADA) ---
local function CriarESP(player)
    if player == LocalPlayer then return end

    local function Aplicar(character)
        if not character then return end
        local hrp = character:WaitForChild("HumanoidRootPart", 5)
        local head = character:WaitForChild("Head", 5)
        local humanoid = character:WaitForChild("Humanoid", 5)
        if not hrp or not head or not humanoid then return end

        local highlight = Instance.new("Highlight")
        highlight.FillTransparency = 1
        highlight.Parent = character

        local billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2.new(0, 160, 0, 30)
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = head

        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1, 0, 1, 0)
        text.BackgroundTransparency = 1
        text.TextSize = 14
        text.Font = Enum.Font.GothamBold
        text.TextColor3 = Color3.new(1, 1, 1)
        text.Parent = billboard

        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local att0 = myHRP and Instance.new("Attachment", myHRP) or nil
        local att1 = Instance.new("Attachment", hrp)
        local beam = Instance.new("Beam")
        beam.Width0, beam.Width1 = 0.05, 0.05
        if att0 then beam.Attachment0 = att0 end
        beam.Attachment1 = att1
        beam.Parent = (myHRP or hrp)

        ESPs[player] = {
            Character = character,
            Humanoid = humanoid,
            HRP = hrp,
            Text = text,
            Highlight = highlight,
            Beam = beam,
            Billboard = billboard,
            Att0 = att0
        }
    end

    player.CharacterAdded:Connect(Aplicar)
    if player.Character then Aplicar(player.Character) end
end

for _, p in pairs(Players:GetPlayers()) do CriarESP(p) end
Players.PlayerAdded:Connect(CriarESP)

-- --- UI PRINCIPAL ---
local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.Name = "MzHub_V8_Final"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, cfg.MenuWidth, 0, 480)
main.Position = UDim2.new(0.75, 0, 0.5, -240) 
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
main.Visible = false
Instance.new("UICorner", main)

local uiScale = Instance.new("UIScale", main)
local mainLED = Instance.new("UIStroke", main)
mainLED.Thickness = 3
mainLED.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
mainLED.Color = Color3.fromRGB(50, 50, 50)
table.insert(ledStrokes, mainLED)

local headerFrame = Instance.new("Frame", main)
headerFrame.Size = UDim2.new(1, 0, 0, 40)
headerFrame.BackgroundTransparency = 1

local title = Instance.new("TextLabel", headerFrame)
title.Size = UDim2.new(0.7, 0, 1, 0)
title.Position = UDim2.new(0.05, 0, 0, 0)
title.Text = "Mz Hub V8 😈👻"
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left

local btnMinimize = Instance.new("TextButton", headerFrame)
btnMinimize.Size = UDim2.new(0, 30, 0, 30)
btnMinimize.Position = UDim2.new(1, -70, 0.5, -15)
btnMinimize.Text = "-"
btnMinimize.TextColor3 = Color3.new(1, 1, 1)
btnMinimize.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
btnMinimize.Font = Enum.Font.GothamBold
btnMinimize.TextSize = 20
Instance.new("UICorner", btnMinimize)

local btnClose = Instance.new("TextButton", headerFrame)
btnClose.Size = UDim2.new(0, 30, 0, 30)
btnClose.Position = UDim2.new(1, -35, 0.5, -15)
btnClose.Text = "X"
btnClose.TextColor3 = Color3.fromRGB(255, 50, 50)
btnClose.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
btnClose.Font = Enum.Font.GothamBold
btnClose.TextSize = 18
Instance.new("UICorner", btnClose)

btnMinimize.MouseButton1Click:Connect(function() main.Visible = false end)
btnClose.MouseButton1Click:Connect(function() gui:Destroy() end)

-- NAVEGAÇÃO
local tabContainer = Instance.new("Frame", main); tabContainer.Size = UDim2.new(1, 0, 0, 35); tabContainer.Position = UDim2.new(0, 0, 0, 45); tabContainer.BackgroundTransparency = 1
local bF = Instance.new("TextButton", tabContainer); bF.Size = UDim2.new(0.5, 0, 1, 0); bF.Text = "FUNÇÕES"; bF.TextColor3 = Color3.new(1, 1, 1); bF.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
local bC = Instance.new("TextButton", tabContainer); bC.Size = UDim2.new(0.5, 0, 1, 0); bC.Position = UDim2.new(0.5, 0, 0, 0); bC.Text = "CRÉDITOS"; bC.TextColor3 = Color3.new(1, 1, 1); bC.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local funcoesPage = Instance.new("ScrollingFrame", main); funcoesPage.Size = UDim2.new(1, 0, 1, -95); funcoesPage.Position = UDim2.new(0, 0, 0, 85); funcoesPage.BackgroundTransparency = 1; funcoesPage.CanvasSize = UDim2.new(0, 0, 2.2, 0); funcoesPage.ScrollBarThickness = 0
local creditosPage = Instance.new("ScrollingFrame", main); creditosPage.Size = UDim2.new(1, 0, 1, -95); creditosPage.Position = UDim2.new(0, 0, 0, 85); creditosPage.BackgroundTransparency = 1; creditosPage.Visible = false; creditosPage.ScrollBarThickness = 0; creditosPage.CanvasSize = UDim2.new(0,0,1.8,0)

bF.MouseButton1Click:Connect(function() funcoesPage.Visible = true; creditosPage.Visible = false; bF.BackgroundColor3 = Color3.fromRGB(60, 60, 60); bC.BackgroundColor3 = Color3.fromRGB(30, 30, 30) end)
bC.MouseButton1Click:Connect(function() funcoesPage.Visible = false; creditosPage.Visible = true; bC.BackgroundColor3 = Color3.fromRGB(60, 60, 60); bF.BackgroundColor3 = Color3.fromRGB(30, 30, 30) end)

local function addControl(parent, txt, y, valType)
    local container = Instance.new("Frame", parent); container.Size = UDim2.new(0.9, 0, 0, 75); container.Position = UDim2.new(0.05, 0, 0, y); container.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", container)
    local led = Instance.new("UIStroke", container); led.Thickness = 2; led.Color = Color3.fromRGB(50, 50, 50); table.insert(ledStrokes, led)
    local lbl = Instance.new("TextLabel", container); lbl.Size = UDim2.new(1, 0, 0, 30); lbl.TextColor3 = Color3.new(1, 1, 1); lbl.BackgroundTransparency = 1; lbl.TextSize = 12
    local b1 = Instance.new("TextButton", container); b1.Size = UDim2.new(0.4, 0, 0, 30); b1.Position = UDim2.new(0.05, 0, 0, 35); b1.Text = (valType == "Width" and "- X" or "-"); b1.BackgroundColor3 = Color3.fromRGB(45, 45, 45); b1.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", b1)
    local b2 = Instance.new("TextButton", container); b2.Size = UDim2.new(0.4, 0, 0, 30); b2.Position = UDim2.new(0.55, 0, 0, 35); b2.Text = (valType == "Width" and "+ X" or "+"); b2.BackgroundColor3 = Color3.fromRGB(45, 45, 45); b2.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", b2)
    local function updateLbl() local v = (valType == "Y" and cfg.FOVPos) or (valType == "Size" and cfg.FOVSize) or (valType == "Scale" and string.format("%.1f", cfg.MenuScale)) or (valType == "Width" and cfg.MenuWidth) or (valType == "Speed" and cfg.WalkSpeed) or cfg.LEDSpeed; lbl.Text = txt..": "..v end
    b1.MouseButton1Click:Connect(function() if valType == "Y" then cfg.FOVPos -= 5 elseif valType == "Size" then cfg.FOVSize = math.max(10, cfg.FOVSize - 10) elseif valType == "Scale" then cfg.MenuScale = math.max(0.5, cfg.MenuScale - 0.1); uiScale.Scale = cfg.MenuScale elseif valType == "Width" then cfg.MenuWidth = math.max(180, cfg.MenuWidth - 10); main.Size = UDim2.new(0, cfg.MenuWidth, 0, 480) elseif valType == "Speed" then cfg.WalkSpeed = math.max(16, cfg.WalkSpeed - 5) else cfg.LEDSpeed = math.max(1, cfg.LEDSpeed - 1) end; updateLbl() end)
    b2.MouseButton1Click:Connect(function() if valType == "Y" then cfg.FOVPos += 5 elseif valType == "Size" then cfg.FOVSize = math.min(500, cfg.FOVSize + 10) elseif valType == "Scale" then cfg.MenuScale = math.min(1.5, cfg.MenuScale + 0.1); uiScale.Scale = cfg.MenuScale elseif valType == "Width" then cfg.MenuWidth = math.min(400, cfg.MenuWidth + 10); main.Size = UDim2.new(0, cfg.MenuWidth, 0, 480) elseif valType == "Speed" then cfg.WalkSpeed = math.min(250, cfg.WalkSpeed + 5) else cfg.LEDSpeed = math.min(10, cfg.LEDSpeed + 1) end; updateLbl() end); updateLbl()
end

local function createBtn(name, y, id)
    local btnContainer = Instance.new("Frame", funcoesPage); btnContainer.Size = UDim2.new(0, 180, 0, 40); btnContainer.Position = UDim2.new(0.5, -90, 0, y); btnContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", btnContainer); local btnLED = Instance.new("UIStroke", btnContainer); btnLED.Thickness = 2; btnLED.Color = Color3.fromRGB(50, 50, 50); table.insert(ledStrokes, btnLED); local btn = Instance.new("TextButton", btnContainer); btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Font = Enum.Font.SourceSansBold; btn.TextSize = 14; local function updateVisual() local isON = (id == "ESP" and cfg.ESP) or (id == "FOV" and cfg.FOV) or (cfg.AimbotMode == id); btn.Text = name .. (isON and " [ON]" or " [OFF]"); btn.TextColor3 = isON and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 80, 80) end; btn.MouseButton1Click:Connect(function() if id == "ESP" then cfg.ESP = not cfg.ESP elseif id == "FOV" then cfg.FOV = not cfg.FOV else cfg.AimbotMode = (cfg.AimbotMode == id) and nil or id end; for _, f in pairs(btnUpdates) do f() end end); btnUpdates[id] = updateVisual; updateVisual()
end
createBtn("ESP OTIMIZADO", 10, "ESP"); createBtn("AIMBOT FORTE", 60, "Forte"); createBtn("AIMBOT FRACO", 110, "Fraco"); createBtn("MOSTRAR FOV", 160, "FOV"); addControl(funcoesPage, "ALTURA FOV (Y)", 210, "Y"); addControl(funcoesPage, "TAMANHO DO FOV", 295, "Size")

local bubble = Instance.new("ImageButton", gui); bubble.Size = UDim2.new(0, 60, 0, 60); bubble.Position = UDim2.new(0.1, 0, 0.5, 0); bubble.Image = "rbxassetid://81545220272311"; bubble.BackgroundTransparency = 1; Instance.new("UICorner", bubble).CornerRadius = UDim.new(1, 0); local bS = Instance.new("UIStroke", bubble); bS.Thickness = 3; bS.Color = Color3.fromRGB(50, 50, 50); table.insert(ledStrokes, bS)

-- --- LOOP ÚNICO (OTIMIZADO) ---
RunService.RenderStepped:Connect(function()
    local rainbow = Color3.fromHSV((tick() * (cfg.LEDSpeed/5) % 1), 1, 1)
    title.TextColor3 = rainbow
    
    if cfg.LEDActive then 
        for _, stroke in pairs(ledStrokes) do stroke.Color = rainbow end 
    else 
        for _, stroke in pairs(ledStrokes) do stroke.Color = Color3.fromRGB(50, 50, 50) end 
    end

    -- FOV Visual
    fovCircle.Visible = cfg.FOV
    fovCircle.Radius = cfg.FOVSize
    fovCircle.Position = UserInputService:GetMouseLocation()

    -- Aimbot
    if cfg.AimbotMode and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getClosestPlayer()
        if target and target.Character then
            local part = target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("HumanoidRootPart")
            if part then
                local smooth = (cfg.AimbotMode == "Forte") and 0.15 or 0.4
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, part.Position), smooth)
            end
        end
    end

    -- ESP Loop (Sua lógica otimizada)
    for player, data in pairs(ESPs) do
        if data.Character and data.Character.Parent and cfg.ESP then
            data.Highlight.Enabled = true
            data.Billboard.Enabled = true
            data.Beam.Enabled = true
            
            local distance = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - data.HRP.Position).Magnitude)
            local hp = math.floor(data.Humanoid.Health)

            data.Text.Text = player.Name.." | "..distance.."m | HP:"..hp
            data.Highlight.OutlineColor = rainbow
            data.Beam.Color = ColorSequence.new(rainbow)
            
            -- Auto-fix do Beam se você morrer
            if data.Beam.Attachment0 == nil and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                data.Beam.Attachment0 = Instance.new("Attachment", LocalPlayer.Character.HumanoidRootPart)
            end
        else
            data.Highlight.Enabled = false
            data.Billboard.Enabled = false
            data.Beam.Enabled = false
        end
    end

    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = cfg.WalkSpeed
    end
end)

local function makeDraggable(obj)
    local dragging, dragStart, startPos
    obj.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; dragStart = input.Position; startPos = obj.Position end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then local delta = input.Position - dragStart; obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
    obj.InputEnded:Connect(function(input) dragging = false end)
end
makeDraggable(main); makeDraggable(bubble)
bubble.MouseButton1Click:Connect(function() main.Visible = not main.Visible end)
    ]])()
    return
end

-- ========== INTERFACE DE KEY ==========
local TweenService = game:GetService("TweenService")
local gui = Instance.new("ScreenGui")
gui.Name = "MZ_Key_System"
gui.Parent = game:GetService("CoreGui") or (game.Players.LocalPlayer and game.Players.LocalPlayer:WaitForChild("PlayerGui"))
gui.ResetOnSpawn = false

-- música (opcional, pode remover se não funcionar)
local musica = Instance.new("Sound")
musica.Parent = gui
musica.SoundId = "rbxassetid://113752526569388"
musica.Volume = 0.5
musica.Looped = true
pcall(function() musica:Play() end)

-- fundo escuro semi-transparente
local background = Instance.new("Frame", gui)
background.Size = UDim2.new(1, 0, 1, 0)
background.BackgroundColor3 = Color3.new(0, 0, 0)
background.BackgroundTransparency = 0.5
background.ZIndex = 0

-- painel principal
local frame = Instance.new("Frame")
frame.Parent = gui
frame.Size = UDim2.new(0, 400, 0, 250)
frame.Position = UDim2.new(0.5, -200, 0.5, -125)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.ZIndex = 1
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 10)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "🔐 SISTEMA DE KEY"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 20

local box = Instance.new("TextBox", frame)
box.Size = UDim2.new(0.8, 0, 0, 40)
box.Position = UDim2.new(0.1, 0, 0.35, 0)
box.PlaceholderText = "Digite sua key"
box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
box.TextColor3 = Color3.fromRGB(255, 255, 255)
box.Font = Enum.Font.Gotham
box.TextSize = 16
Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)

local btnVerificar = Instance.new("TextButton", frame)
btnVerificar.Size = UDim2.new(0.35, 0, 0, 40)
btnVerificar.Position = UDim2.new(0.1, 0, 0.65, 0)
btnVerificar.Text = "VERIFICAR"
btnVerificar.BackgroundColor3 = Color3.fromRGB(54, 57, 63)
btnVerificar.TextColor3 = Color3.fromRGB(255, 255, 255)
btnVerificar.Font = Enum.Font.GothamBold
btnVerificar.TextSize = 16
Instance.new("UICorner", btnVerificar).CornerRadius = UDim.new(0, 6)

local btnGetKey = Instance.new("TextButton", frame)
btnGetKey.Size = UDim2.new(0.35, 0, 0, 40)
btnGetKey.Position = UDim2.new(0.55, 0, 0.65, 0)
btnGetKey.Text = "OBTER KEY"
btnGetKey.BackgroundColor3 = Color3.fromRGB(64, 128, 255)
btnGetKey.TextColor3 = Color3.fromRGB(255, 255, 255)
btnGetKey.Font = Enum.Font.GothamBold
btnGetKey.TextSize = 16
Instance.new("UICorner", btnGetKey).CornerRadius = UDim.new(0, 6)

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1, 0, 0, 30)
status.Position = UDim2.new(0, 0, 0.85, 0)
status.BackgroundTransparency = 1
status.Font = Enum.Font.Gotham
status.Text = ""
status.TextColor3 = Color3.fromRGB(255, 255, 255)
status.TextSize = 14

-- Animação de entrada
frame.Position = UDim2.new(0.5, -200, 0.5, -300)
TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Position = UDim2.new(0.5, -200, 0.5, -125)}):Play()

-- Função para liberar acesso
local function liberarAcesso()
    getgenv().MZ_LIBERADO = true
    status.Text = "✅ ACESSO LIBERADO!"
    status.TextColor3 = Color3.fromRGB(0, 255, 0)
    task.wait(1)
    -- Fecha a GUI
    gui:Destroy()
    -- Carrega o MZ Hub
    loadstring([[
        -- ========== CÓDIGO DO MZ HUB ==========
        local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local cfg = {
    ESP = false, 
    AimbotMode = nil, 
    FOV = false, 
    FOVSize = 100,
    FOVPos = 0,
    LEDActive = false,
    LEDSpeed = 5,
    MenuScale = 1,
    MenuWidth = 220,
    InfJump = false,
    WalkSpeed = 16,
    NoGravity = false
}

local ledStrokes = {}
local btnUpdates = {}
local ESPs = {} -- Tabela do seu script de ESP otimizado

-- --- SISTEMA VISUAL DO FOV ---
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1
fovCircle.Transparency = 0.7
fovCircle.Color = Color3.new(1, 1, 1)
fovCircle.Filled = false

-- --- LÓGICA DO AIMBOT ---
local function getClosestPlayer()
    local target = nil
    local shortestDistance = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                if onScreen then
                    local mousePos = UserInputService:GetMouseLocation()
                    local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                    if distance < shortestDistance and distance <= cfg.FOVSize then
                        shortestDistance = distance
                        target = player
                    end
                end
            end
        end
    end
    return target
end

-- --- LÓGICA DO ESP OTIMIZADO (INTEGRADA) ---
local function CriarESP(player)
    if player == LocalPlayer then return end

    local function Aplicar(character)
        if not character then return end
        local hrp = character:WaitForChild("HumanoidRootPart", 5)
        local head = character:WaitForChild("Head", 5)
        local humanoid = character:WaitForChild("Humanoid", 5)
        if not hrp or not head or not humanoid then return end

        local highlight = Instance.new("Highlight")
        highlight.FillTransparency = 1
        highlight.Parent = character

        local billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2.new(0, 160, 0, 30)
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = head

        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1, 0, 1, 0)
        text.BackgroundTransparency = 1
        text.TextSize = 14
        text.Font = Enum.Font.GothamBold
        text.TextColor3 = Color3.new(1, 1, 1)
        text.Parent = billboard

        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local att0 = myHRP and Instance.new("Attachment", myHRP) or nil
        local att1 = Instance.new("Attachment", hrp)
        local beam = Instance.new("Beam")
        beam.Width0, beam.Width1 = 0.05, 0.05
        if att0 then beam.Attachment0 = att0 end
        beam.Attachment1 = att1
        beam.Parent = (myHRP or hrp)

        ESPs[player] = {
            Character = character,
            Humanoid = humanoid,
            HRP = hrp,
            Text = text,
            Highlight = highlight,
            Beam = beam,
            Billboard = billboard,
            Att0 = att0
        }
    end

    player.CharacterAdded:Connect(Aplicar)
    if player.Character then Aplicar(player.Character) end
end

for _, p in pairs(Players:GetPlayers()) do CriarESP(p) end
Players.PlayerAdded:Connect(CriarESP)

-- --- UI PRINCIPAL ---
local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.Name = "MzHub_V8_Final"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, cfg.MenuWidth, 0, 480)
main.Position = UDim2.new(0.75, 0, 0.5, -240) 
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
main.Visible = false
Instance.new("UICorner", main)

local uiScale = Instance.new("UIScale", main)
local mainLED = Instance.new("UIStroke", main)
mainLED.Thickness = 3
mainLED.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
mainLED.Color = Color3.fromRGB(50, 50, 50)
table.insert(ledStrokes, mainLED)

local headerFrame = Instance.new("Frame", main)
headerFrame.Size = UDim2.new(1, 0, 0, 40)
headerFrame.BackgroundTransparency = 1

local title = Instance.new("TextLabel", headerFrame)
title.Size = UDim2.new(0.7, 0, 1, 0)
title.Position = UDim2.new(0.05, 0, 0, 0)
title.Text = "Mz Hub V8 😈👻"
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left

local btnMinimize = Instance.new("TextButton", headerFrame)
btnMinimize.Size = UDim2.new(0, 30, 0, 30)
btnMinimize.Position = UDim2.new(1, -70, 0.5, -15)
btnMinimize.Text = "-"
btnMinimize.TextColor3 = Color3.new(1, 1, 1)
btnMinimize.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
btnMinimize.Font = Enum.Font.GothamBold
btnMinimize.TextSize = 20
Instance.new("UICorner", btnMinimize)

local btnClose = Instance.new("TextButton", headerFrame)
btnClose.Size = UDim2.new(0, 30, 0, 30)
btnClose.Position = UDim2.new(1, -35, 0.5, -15)
btnClose.Text = "X"
btnClose.TextColor3 = Color3.fromRGB(255, 50, 50)
btnClose.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
btnClose.Font = Enum.Font.GothamBold
btnClose.TextSize = 18
Instance.new("UICorner", btnClose)

btnMinimize.MouseButton1Click:Connect(function() main.Visible = false end)
btnClose.MouseButton1Click:Connect(function() gui:Destroy() end)

-- NAVEGAÇÃO
local tabContainer = Instance.new("Frame", main); tabContainer.Size = UDim2.new(1, 0, 0, 35); tabContainer.Position = UDim2.new(0, 0, 0, 45); tabContainer.BackgroundTransparency = 1
local bF = Instance.new("TextButton", tabContainer); bF.Size = UDim2.new(0.5, 0, 1, 0); bF.Text = "FUNÇÕES"; bF.TextColor3 = Color3.new(1, 1, 1); bF.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
local bC = Instance.new("TextButton", tabContainer); bC.Size = UDim2.new(0.5, 0, 1, 0); bC.Position = UDim2.new(0.5, 0, 0, 0); bC.Text = "CRÉDITOS"; bC.TextColor3 = Color3.new(1, 1, 1); bC.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local funcoesPage = Instance.new("ScrollingFrame", main); funcoesPage.Size = UDim2.new(1, 0, 1, -95); funcoesPage.Position = UDim2.new(0, 0, 0, 85); funcoesPage.BackgroundTransparency = 1; funcoesPage.CanvasSize = UDim2.new(0, 0, 2.2, 0); funcoesPage.ScrollBarThickness = 0
local creditosPage = Instance.new("ScrollingFrame", main); creditosPage.Size = UDim2.new(1, 0, 1, -95); creditosPage.Position = UDim2.new(0, 0, 0, 85); creditosPage.BackgroundTransparency = 1; creditosPage.Visible = false; creditosPage.ScrollBarThickness = 0; creditosPage.CanvasSize = UDim2.new(0,0,1.8,0)

bF.MouseButton1Click:Connect(function() funcoesPage.Visible = true; creditosPage.Visible = false; bF.BackgroundColor3 = Color3.fromRGB(60, 60, 60); bC.BackgroundColor3 = Color3.fromRGB(30, 30, 30) end)
bC.MouseButton1Click:Connect(function() funcoesPage.Visible = false; creditosPage.Visible = true; bC.BackgroundColor3 = Color3.fromRGB(60, 60, 60); bF.BackgroundColor3 = Color3.fromRGB(30, 30, 30) end)

local function addControl(parent, txt, y, valType)
    local container = Instance.new("Frame", parent); container.Size = UDim2.new(0.9, 0, 0, 75); container.Position = UDim2.new(0.05, 0, 0, y); container.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", container)
    local led = Instance.new("UIStroke", container); led.Thickness = 2; led.Color = Color3.fromRGB(50, 50, 50); table.insert(ledStrokes, led)
    local lbl = Instance.new("TextLabel", container); lbl.Size = UDim2.new(1, 0, 0, 30); lbl.TextColor3 = Color3.new(1, 1, 1); lbl.BackgroundTransparency = 1; lbl.TextSize = 12
    local b1 = Instance.new("TextButton", container); b1.Size = UDim2.new(0.4, 0, 0, 30); b1.Position = UDim2.new(0.05, 0, 0, 35); b1.Text = (valType == "Width" and "- X" or "-"); b1.BackgroundColor3 = Color3.fromRGB(45, 45, 45); b1.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", b1)
    local b2 = Instance.new("TextButton", container); b2.Size = UDim2.new(0.4, 0, 0, 30); b2.Position = UDim2.new(0.55, 0, 0, 35); b2.Text = (valType == "Width" and "+ X" or "+"); b2.BackgroundColor3 = Color3.fromRGB(45, 45, 45); b2.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", b2)
    local function updateLbl() local v = (valType == "Y" and cfg.FOVPos) or (valType == "Size" and cfg.FOVSize) or (valType == "Scale" and string.format("%.1f", cfg.MenuScale)) or (valType == "Width" and cfg.MenuWidth) or (valType == "Speed" and cfg.WalkSpeed) or cfg.LEDSpeed; lbl.Text = txt..": "..v end
    b1.MouseButton1Click:Connect(function() if valType == "Y" then cfg.FOVPos -= 5 elseif valType == "Size" then cfg.FOVSize = math.max(10, cfg.FOVSize - 10) elseif valType == "Scale" then cfg.MenuScale = math.max(0.5, cfg.MenuScale - 0.1); uiScale.Scale = cfg.MenuScale elseif valType == "Width" then cfg.MenuWidth = math.max(180, cfg.MenuWidth - 10); main.Size = UDim2.new(0, cfg.MenuWidth, 0, 480) elseif valType == "Speed" then cfg.WalkSpeed = math.max(16, cfg.WalkSpeed - 5) else cfg.LEDSpeed = math.max(1, cfg.LEDSpeed - 1) end; updateLbl() end)
    b2.MouseButton1Click:Connect(function() if valType == "Y" then cfg.FOVPos += 5 elseif valType == "Size" then cfg.FOVSize = math.min(500, cfg.FOVSize + 10) elseif valType == "Scale" then cfg.MenuScale = math.min(1.5, cfg.MenuScale + 0.1); uiScale.Scale = cfg.MenuScale elseif valType == "Width" then cfg.MenuWidth = math.min(400, cfg.MenuWidth + 10); main.Size = UDim2.new(0, cfg.MenuWidth, 0, 480) elseif valType == "Speed" then cfg.WalkSpeed = math.min(250, cfg.WalkSpeed + 5) else cfg.LEDSpeed = math.min(10, cfg.LEDSpeed + 1) end; updateLbl() end); updateLbl()
end

local function createBtn(name, y, id)
    local btnContainer = Instance.new("Frame", funcoesPage); btnContainer.Size = UDim2.new(0, 180, 0, 40); btnContainer.Position = UDim2.new(0.5, -90, 0, y); btnContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", btnContainer); local btnLED = Instance.new("UIStroke", btnContainer); btnLED.Thickness = 2; btnLED.Color = Color3.fromRGB(50, 50, 50); table.insert(ledStrokes, btnLED); local btn = Instance.new("TextButton", btnContainer); btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Font = Enum.Font.SourceSansBold; btn.TextSize = 14; local function updateVisual() local isON = (id == "ESP" and cfg.ESP) or (id == "FOV" and cfg.FOV) or (cfg.AimbotMode == id); btn.Text = name .. (isON and " [ON]" or " [OFF]"); btn.TextColor3 = isON and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 80, 80) end; btn.MouseButton1Click:Connect(function() if id == "ESP" then cfg.ESP = not cfg.ESP elseif id == "FOV" then cfg.FOV = not cfg.FOV else cfg.AimbotMode = (cfg.AimbotMode == id) and nil or id end; for _, f in pairs(btnUpdates) do f() end end); btnUpdates[id] = updateVisual; updateVisual()
end
createBtn("ESP OTIMIZADO", 10, "ESP"); createBtn("AIMBOT FORTE", 60, "Forte"); createBtn("AIMBOT FRACO", 110, "Fraco"); createBtn("MOSTRAR FOV", 160, "FOV"); addControl(funcoesPage, "ALTURA FOV (Y)", 210, "Y"); addControl(funcoesPage, "TAMANHO DO FOV", 295, "Size")

local bubble = Instance.new("ImageButton", gui); bubble.Size = UDim2.new(0, 60, 0, 60); bubble.Position = UDim2.new(0.1, 0, 0.5, 0); bubble.Image = "rbxassetid://81545220272311"; bubble.BackgroundTransparency = 1; Instance.new("UICorner", bubble).CornerRadius = UDim.new(1, 0); local bS = Instance.new("UIStroke", bubble); bS.Thickness = 3; bS.Color = Color3.fromRGB(50, 50, 50); table.insert(ledStrokes, bS)

-- --- LOOP ÚNICO (OTIMIZADO) ---
RunService.RenderStepped:Connect(function()
    local rainbow = Color3.fromHSV((tick() * (cfg.LEDSpeed/5) % 1), 1, 1)
    title.TextColor3 = rainbow
    
    if cfg.LEDActive then 
        for _, stroke in pairs(ledStrokes) do stroke.Color = rainbow end 
    else 
        for _, stroke in pairs(ledStrokes) do stroke.Color = Color3.fromRGB(50, 50, 50) end 
    end

    -- FOV Visual
    fovCircle.Visible = cfg.FOV
    fovCircle.Radius = cfg.FOVSize
    fovCircle.Position = UserInputService:GetMouseLocation()

    -- Aimbot
    if cfg.AimbotMode and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getClosestPlayer()
        if target and target.Character then
            local part = target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("HumanoidRootPart")
            if part then
                local smooth = (cfg.AimbotMode == "Forte") and 0.15 or 0.4
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, part.Position), smooth)
            end
        end
    end

    -- ESP Loop (Sua lógica otimizada)
    for player, data in pairs(ESPs) do
        if data.Character and data.Character.Parent and cfg.ESP then
            data.Highlight.Enabled = true
            data.Billboard.Enabled = true
            data.Beam.Enabled = true
            
            local distance = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - data.HRP.Position).Magnitude)
            local hp = math.floor(data.Humanoid.Health)

            data.Text.Text = player.Name.." | "..distance.."m | HP:"..hp
            data.Highlight.OutlineColor = rainbow
            data.Beam.Color = ColorSequence.new(rainbow)
            
            -- Auto-fix do Beam se você morrer
            if data.Beam.Attachment0 == nil and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                data.Beam.Attachment0 = Instance.new("Attachment", LocalPlayer.Character.HumanoidRootPart)
            end
        else
            data.Highlight.Enabled = false
            data.Billboard.Enabled = false
            data.Beam.Enabled = false
        end
    end

    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = cfg.WalkSpeed
    end
end)

local function makeDraggable(obj)
    local dragging, dragStart, startPos
    obj.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; dragStart = input.Position; startPos = obj.Position end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then local delta = input.Position - dragStart; obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
    obj.InputEnded:Connect(function(input) dragging = false end)
end
makeDraggable(main); makeDraggable(bubble)
bubble.MouseButton1Click:Connect(function() main.Visible = not main.Visible end)
