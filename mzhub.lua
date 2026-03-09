 -- ==================== SISTEMA DE KEY (MZHUB) ====================
local KeyCliente  = "MZ-CLIENT-7Q2L9F-K4X8PA-T6Z3RM-91WV"
local KeyDono     = "cleude09"
local LinkKey     = "https://link-center.net/4011881/g1uHRMybfTo9"

local TempoKey     = 40
local ResetDuration = 50

local UsedFile = "mzhub_used.dat"
local TweenService = game:GetService("TweenService")

-- helpers de arquivo (fallback em memória)
local function ensureFile()
    if writefile and isfile and not isfile(UsedFile) then
        pcall(function() writefile(UsedFile, "") end)
    end
end

local function salvarUsedTable(tbl)
    if writefile and type(tbl) == "table" then
        local lines = {}
        for k,exp in pairs(tbl) do
            table.insert(lines, k.."|"..tostring(exp))
        end
        pcall(function() writefile(UsedFile, table.concat(lines, "\n")) end)
        return true
    else
        getgenv().MZ_USED_KEYS = tbl
        return false
    end
end

local function lerUsedTable()
    if writefile and isfile and isfile(UsedFile) and readfile then
        local ok,content = pcall(readfile, UsedFile)
        if ok and content and #content > 0 then
            local t = {}
            for line in content:gmatch("[^\r\n]+") do
                local sep = line:find("|",1,true)
                if sep then
                    local k = line:sub(1,sep-1)
                    local e = tonumber(line:sub(sep+1)) or 0
                    t[k] = e
                end
            end
            return t
        end
        return {}
    else
        return getgenv().MZ_USED_KEYS or {}
    end
end

local function limparExpiradasEAtualizar()
    local used = lerUsedTable()
    local changed = false
    for k,exp in pairs(used) do
        if tonumber(exp) and os.time() >= exp then
            used[k] = nil
            changed = true
        end
    end
    if changed then salvarUsedTable(used) end
    return used
end

local function marcarKeyUsada(key)
    local used = lerUsedTable()
    used[key] = os.time() + TempoKey
    salvarUsedTable(used)
end

local function statusKey(key)
    local used = lerUsedTable()
    local exp = used[key]
    if not exp then return "not_used" end
    if os.time() < exp then return "active" end
    return "expired"
end

-- garante destruição GUI antiga
pcall(function()
    local old = game:GetService("CoreGui"):FindFirstChild("MZ_HUB")
    if old then old:Destroy() end
end)

ensureFile()
limparExpiradasEAtualizar()

-- flags globais
getgenv().MZHUB_LOADED = true
getgenv().MZ_RESET_ACTIVE = getgenv().MZ_RESET_ACTIVE or false
getgenv().MZ_RESET_UNTIL = getgenv().MZ_RESET_UNTIL or 0
getgenv().MZ_RESET_LOCK = getgenv().MZ_RESET_LOCK or false

-- GUI de key
local gui = Instance.new("ScreenGui")
gui.Name = "MZ_HUB"
gui.Parent = game:GetService("CoreGui") or (game.Players.LocalPlayer and game.Players.LocalPlayer:WaitForChild("PlayerGui"))

-- música
local musica = Instance.new("Sound")
musica.Parent = gui
musica.SoundId = "rbxassetid://113752526569388"
musica.Volume = 1
musica.Looped = true
pcall(function() musica:Play() end)

-- pre-circle animado (entrada)
local preCircle = Instance.new("ImageLabel")
preCircle.Parent = gui
preCircle.Size = UDim2.new(0,48,0,48)
preCircle.Position = UDim2.new(0.5,-24,0.35,-24)
preCircle.BackgroundTransparency = 1
preCircle.Image = "rbxassetid://6031091002"
local preAlive = true
spawn(function()
    while preAlive and preCircle.Parent do
        preCircle.Rotation = (preCircle.Rotation + 8) % 360
        preCircle.ImageColor3 = Color3.fromHSV((tick()%5)/5,1,1)
        task.wait(0.03)
    end
end)
task.delay(0.9, function()
    preAlive = false
    pcall(function()
        TweenService:Create(preCircle, TweenInfo.new(0.28, Enum.EasingStyle.Quad), {Size = UDim2.new(0,220,0,220), ImageTransparency = 1}):Play()
        task.wait(0.28)
        if preCircle and preCircle.Parent then preCircle:Destroy() end
    end)
end)

-- painel principal
local frame = Instance.new("Frame")
frame.Parent = gui
frame.Name = "Panel"
frame.Size = UDim2.new(0,420,0,220)
frame.Position = UDim2.new(0.5,-210,0,-400)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
local corner = Instance.new("UICorner", frame); corner.CornerRadius = UDim.new(0,8)

local bg = Instance.new("ImageLabel"); bg.Parent = frame; bg.Size = UDim2.new(1,0,1,0)
bg.Image = "rbxassetid://81545220272311"; bg.BackgroundTransparency = 1; bg.ImageTransparency = 0.18

local stroke = Instance.new("UIStroke", frame); stroke.Thickness = 3
local ledRunning = true
spawn(function()
    while ledRunning and frame.Parent do
        stroke.Color = Color3.fromHSV((tick()%5)/5,1,1)
        task.wait(0.04)
    end
end)

local title = Instance.new("TextLabel")
title.Parent = frame
title.Size = UDim2.new(1,0,0,36)
title.Position = UDim2.new(0,0,0,8)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "Key"
title.TextColor3 = Color3.fromRGB(240,240,240)
title.TextScaled = true

local box = Instance.new("TextBox")
box.Parent = frame
box.Size = UDim2.new(0.76,0,0,36)
box.Position = UDim2.new(0.12,0,0.35,0)
box.PlaceholderText = "Key"
box.BackgroundColor3 = Color3.fromRGB(40,40,40)
box.TextColor3 = Color3.fromRGB(255,255,255)
box.Font = Enum.Font.Gotham
box.TextScaled = true
local boxCorner = Instance.new("UICorner", box); boxCorner.CornerRadius = UDim.new(0,6)

local status = Instance.new("TextLabel")
status.Parent = frame
status.Size = UDim2.new(1,0,0,22)
status.Position = UDim2.new(0,0,0.55,0)
status.BackgroundTransparency = 1
status.Font = Enum.Font.GothamBold
status.Text = ""
status.TextColor3 = Color3.fromRGB(255,255,255)
status.TextScaled = true

-- label discreto do cooldown no cantinho
local cooldownLabel = Instance.new("TextLabel")
cooldownLabel.Parent = frame
cooldownLabel.Size = UDim2.new(0,56,0,16)
cooldownLabel.Position = UDim2.new(1, -66, 1, -22)
cooldownLabel.BackgroundTransparency = 1
cooldownLabel.Font = Enum.Font.Arial
cooldownLabel.TextSize = 12
cooldownLabel.TextColor3 = Color3.fromRGB(200,200,200)
cooldownLabel.Text = ""
cooldownLabel.Visible = false
cooldownLabel.TextTransparency = 0.25

local function makeButton(parent, posX, text, bgColor)
    local b = Instance.new("TextButton")
    b.Parent = parent
    b.Size = UDim2.new(0.34,0,0,36)
    b.Position = UDim2.new(posX,0,0.75,0)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextScaled = true
    b.BackgroundColor3 = bgColor or Color3.fromRGB(54,57,63)
    b.TextColor3 = Color3.fromRGB(255,255,255)
    local cc = Instance.new("UICorner", b); cc.CornerRadius = UDim.new(0,6)
    return b
end

local check = makeButton(frame, 0.08, "Verificar", Color3.fromRGB(54,57,63))
local getkey = makeButton(frame, 0.58, "Get Key", Color3.fromRGB(64,128,255))

local rodando = true
local function criarParticula()
    local p = Instance.new("ImageLabel")
    p.Parent = gui
    p.Size = UDim2.new(0,18,0,18)
    p.Image = "rbxassetid://6031091002"
    p.BackgroundTransparency = 1
    p.Position = UDim2.new(math.random(),0,0, -0.1 * math.random())
    spawn(function()
        while p.Parent and rodando do
            p.ImageColor3 = Color3.fromHSV((tick()%5)/5,1,1)
            task.wait(0.08)
        end
    end)
    local tween = TweenService:Create(p, TweenInfo.new(math.random(5,9)), {Position = UDim2.new(math.random(),0,1.2,0)})
    tween:Play()
    tween.Completed:Connect(function() p:Destroy() end)
end
spawn(function() while rodando do for i=1,3 do criarParticula() end task.wait(1) end end)

local ledCircle = Instance.new("ImageLabel")
ledCircle.Parent = frame
ledCircle.Size = UDim2.new(0,22,0,22)
ledCircle.Position = UDim2.new(-0.03,0,0.5,-11)
ledCircle.BackgroundTransparency = 1
ledCircle.Image = "rbxassetid://6031091002"
spawn(function()
    while ledCircle.Parent do
        ledCircle.Rotation = (ledCircle.Rotation + 8) % 360
        ledCircle.ImageColor3 = Color3.fromHSV((tick()%5)/5,1,1)
        task.wait(0.03)
    end
end)

TweenService:Create(frame, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.5,-210,0.5,-110)}):Play()

getkey.MouseButton1Click:Connect(function()
    pcall(function() setclipboard(LinkKey) end)
    status.Text = "Link copiado!"
    status.TextColor3 = Color3.fromRGB(0,255,0)
end)

-- startGlobalReset
local function startGlobalReset()
    if getgenv().MZ_RESET_ACTIVE then return end
    if getgenv().MZ_RESET_LOCK then return end
    getgenv().MZ_RESET_LOCK = true
    getgenv().MZ_RESET_ACTIVE = true
    getgenv().MZ_RESET_UNTIL = os.time() + ResetDuration

    spawn(function()
        print("[MZHUB] Reset iniciado. Duração = "..tostring(ResetDuration).."s")
        while getgenv().MZ_RESET_UNTIL and os.time() < getgenv().MZ_RESET_UNTIL do
            local remaining = getgenv().MZ_RESET_UNTIL - os.time()
            if cooldownLabel then
                cooldownLabel.Text = tostring(remaining) .. "s"
                cooldownLabel.Visible = true
            end
            task.wait(1)
        end
        salvarUsedTable({})
        getgenv().MZ_RESET_UNTIL = 0
        getgenv().MZ_RESET_ACTIVE = false
        getgenv().MZ_RESET_LOCK = false
        if cooldownLabel then cooldownLabel.Visible = false; cooldownLabel.Text = "" end
        print("[MZHUB] Reset concluído. Sistema liberado.")
    end)
end

-- ==================== FUNÇÃO QUE EXECUTA O SCRIPT PRINCIPAL APÓS KEY ACEITA ====================
local function executarScriptPrincipal()
    if getgenv().MZ_SCRIPT_PRINCIPAL_EXECUTADO then return end
    getgenv().MZ_SCRIPT_PRINCIPAL_EXECUTADO = true

    -- ========== SCRIPT PRINCIPAL (AIMBOT, ESP, GUI) ==========
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    local cfg = {
        ESP = false, AimbotMode = "None", FOV = false, 
        FOVSize = 100, FOVPos = 0, SafeTeam = false,
        LEDActive = false, LEDSpeed = 5,
        TargetPart = "Head",
        Transparency = 0.15, R = 255, G = 255, B = 255
    }

    -- --- BUSCA DE PARTES ---
    local function getPrecisePart(char, partName)
        if partName == "Head" then return char:FindFirstChild("Head") 
        elseif partName == "Torso" then return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
        elseif partName == "RightArm" then return char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm")
        elseif partName == "LeftArm" then return char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm")
        elseif partName == "Legs" then return char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Right Leg") end
        return nil
    end

    -- --- FUNÇÃO PARA CRIAR LINHAS ---
    local function createTracer()
        local line = Drawing.new("Line")
        line.Thickness = 1.5
        line.Transparency = 1
        line.Visible = false
        return line
    end

    local tracers = {}

    -- --- ARRASTAR ---
    local function makeDraggable(topbar, object)
        local dragging, dragInput, dragStart, startPos
        topbar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true; dragStart = input.Position; startPos = object.Position
                input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
            end
        end)
        topbar.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
        end)
        RunService.RenderStepped:Connect(function()
            if dragging and dragInput then
                local delta = dragInput.Position - dragStart
                object.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end

    local mainGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
    mainGui.Name = "MzHub_V48_FixEspaco"
    mainGui.ResetOnSpawn = false

    -- FOV
    local fovFrame = Instance.new("Frame", mainGui)
    fovFrame.BackgroundTransparency = 1; fovFrame.Visible = false
    local fovStroke = Instance.new("UIStroke", fovFrame); fovStroke.Thickness = 1.5
    local fovCorner = Instance.new("UICorner", fovFrame); fovCorner.CornerRadius = UDim.new(1, 0)

    -- BOLINHA FLUTUANTE
    local bubble = Instance.new("ImageButton", mainGui)
    bubble.Size = UDim2.new(0, 60, 0, 60); bubble.Position = UDim2.new(0.5, -30, 0.5, -30)
    bubble.BackgroundColor3 = Color3.fromRGB(20, 20, 20); bubble.Image = "rbxassetid://81545220272311"; bubble.ZIndex = 1000
    Instance.new("UICorner", bubble).CornerRadius = UDim.new(1, 0)
    local bStroke = Instance.new("UIStroke", bubble); bStroke.Thickness = 2
    makeDraggable(bubble, bubble)

    -- PAINEL PRINCIPAL
    local main = Instance.new("Frame", mainGui)
    main.Size = UDim2.new(0, 250, 0, 420); main.Position = UDim2.new(0.5, -125, 0.5, -210)
    main.BackgroundColor3 = Color3.fromRGB(12, 12, 12); main.Visible = false; main.ClipsDescendants = true
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)
    local mStroke = Instance.new("UIStroke", main); mStroke.Thickness = 2
    makeDraggable(main, main)

    -- CONFIRMAÇÃO
    local confirmFrame = Instance.new("Frame", mainGui)
    confirmFrame.Size = UDim2.new(0, 240, 0, 130); confirmFrame.Position = UDim2.new(0.5, -120, 0.5, -65)
    confirmFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); confirmFrame.Visible = false; confirmFrame.ZIndex = 10000
    Instance.new("UICorner", confirmFrame).CornerRadius = UDim.new(0, 8)
    local cStroke = Instance.new("UIStroke", confirmFrame); cStroke.Thickness = 2
    local cText = Instance.new("TextLabel", confirmFrame)
    cText.Size = UDim2.new(1, 0, 0, 50); cText.Position = UDim2.new(0, 0, 0, 10); cText.Text = "Você deseja fechar o painel?"; cText.TextColor3 = Color3.new(1,1,1); cText.BackgroundTransparency = 1; cText.Font = "SourceSansBold"; cText.TextSize = 17; cText.ZIndex = 10001
    local bSim = Instance.new("TextButton", confirmFrame); bSim.Size = UDim2.new(0, 95, 0, 45); bSim.Position = UDim2.new(0.08, 0, 0.52, 0); bSim.Text = "SIM"; bSim.BackgroundColor3 = Color3.fromRGB(0, 130, 0); bSim.TextColor3 = Color3.new(1,1,1); bSim.Font = "SourceSansBold"; bSim.TextSize = 18; bSim.ZIndex = 10001; Instance.new("UICorner", bSim).CornerRadius = UDim.new(0, 6)
    local bNao = Instance.new("TextButton", confirmFrame); bNao.Size = UDim2.new(0, 95, 0, 45); bNao.Position = UDim2.new(0.53, 0, 0.52, 0); bNao.Text = "NÃO"; bNao.BackgroundColor3 = Color3.fromRGB(150, 0, 0); bNao.TextColor3 = Color3.new(1,1,1); bNao.Font = "SourceSansBold"; bNao.TextSize = 18; bNao.ZIndex = 10001; Instance.new("UICorner", bNao).CornerRadius = UDim.new(0, 6)

    -- BARRA DE TOPO
    local top = Instance.new("Frame", main); top.Size = UDim2.new(1, 0, 0, 35); top.BackgroundTransparency = 1
    local title = Instance.new("TextLabel", top); title.Size = UDim2.new(1, -70, 1, 0); title.Position = UDim2.new(0, 10, 0, 0); title.Text = "Mz Hub 😈"; title.Font = "SourceSansBold"; title.TextSize = 19; title.BackgroundTransparency = 1; title.TextXAlignment = "Left"
    local btnMin = Instance.new("TextButton", top); btnMin.Size = UDim2.new(0, 25, 0, 25); btnMin.Position = UDim2.new(1, -60, 0.5, -12); btnMin.Text = "-"; btnMin.BackgroundColor3 = Color3.fromRGB(0, 0, 0); btnMin.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", btnMin).CornerRadius = UDim.new(0, 4)
    local btnClose = Instance.new("TextButton", top); btnClose.Size = UDim2.new(0, 25, 0, 25); btnClose.Position = UDim2.new(1, -30, 0.5, -12); btnClose.Text = "X"; btnClose.BackgroundColor3 = Color3.fromRGB(180, 0, 0); btnClose.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", btnClose).CornerRadius = UDim.new(0, 4)

    -- SISTEMA DE ABAS MÓVEIS
    local tabH = Instance.new("ScrollingFrame", main)
    tabH.Size = UDim2.new(1, 0, 0, 30); tabH.Position = UDim2.new(0, 0, 0, 35); tabH.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
    tabH.ScrollBarThickness = 0
    tabH.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabH.AutomaticCanvasSize = Enum.AutomaticSize.X

    local tabLayout = Instance.new("UIListLayout", tabH); tabLayout.FillDirection = Enum.FillDirection.Horizontal; tabLayout.SortOrder = Enum.SortOrder.LayoutOrder

    -- BOTÕES DAS ABAS
    local bT1 = Instance.new("TextButton", tabH); bT1.Size = UDim2.new(0, 95, 1, 0); bT1.Text = "FUNÇÕES"; bT1.BackgroundColor3 = Color3.fromRGB(22,22,22); bT1.TextColor3 = Color3.new(1,1,1); bT1.LayoutOrder = 1
    local bT2 = Instance.new("TextButton", tabH); bT2.Size = UDim2.new(0, 95, 1, 0); bT2.Text = "AJUSTES"; bT2.BackgroundColor3 = Color3.fromRGB(12,12,12); bT2.TextColor3 = Color3.new(0.6,0.6,0.6); bT2.LayoutOrder = 2
    local bT3 = Instance.new("TextButton", tabH); bT3.Size = UDim2.new(0, 95, 1, 0); bT3.Text = "CRÉDITOS"; bT3.BackgroundColor3 = Color3.fromRGB(12,12,12); bT3.TextColor3 = Color3.new(0.6,0.6,0.6); bT3.LayoutOrder = 3

    -- TELAS DE CONTEÚDO
    local cFun = Instance.new("ScrollingFrame", main); cFun.Size = UDim2.new(1, -10, 1, -85); cFun.Position = UDim2.new(0, 5, 0, 75); cFun.BackgroundTransparency = 1; cFun.ScrollBarThickness = 0
    cFun.CanvasSize = UDim2.new(0, 0, 0, 0); cFun.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local cAju = Instance.new("ScrollingFrame", main); cAju.Size = UDim2.new(1, -10, 1, -85); cAju.Position = UDim2.new(0, 5, 0, 75); cAju.BackgroundTransparency = 1; cAju.Visible = false; cAju.ScrollBarThickness = 0
    cAju.CanvasSize = UDim2.new(0, 0, 0, 0); cAju.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local cCre = Instance.new("ScrollingFrame", main); cCre.Size = UDim2.new(1, -10, 1, -85); cCre.Position = UDim2.new(0, 5, 0, 75); cCre.BackgroundTransparency = 1; cCre.Visible = false; cCre.ScrollBarThickness = 0
    cCre.CanvasSize = UDim2.new(0, 0, 0, 0); cCre.AutomaticCanvasSize = Enum.AutomaticSize.Y

    -- ORDEM FORÇADA
    Instance.new("UIListLayout", cFun).Padding = UDim.new(0, 8); cFun.UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    Instance.new("UIListLayout", cAju).Padding = UDim.new(0, 8); cAju.UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    Instance.new("UIListLayout", cCre).Padding = UDim.new(0, 8); cCre.UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local orderFun, orderAju, orderCre = 1, 1, 1

    -- LÓGICA DE TROCA DE ABAS
    bT1.MouseButton1Click:Connect(function() cFun.Visible = true; cAju.Visible = false; cCre.Visible = false; bT1.BackgroundColor3 = Color3.fromRGB(22,22,22); bT1.TextColor3 = Color3.new(1,1,1); bT2.BackgroundColor3 = Color3.fromRGB(12,12,12); bT2.TextColor3 = Color3.new(0.6,0.6,0.6); bT3.BackgroundColor3 = Color3.fromRGB(12,12,12); bT3.TextColor3 = Color3.new(0.6,0.6,0.6) end)
    bT2.MouseButton1Click:Connect(function() cFun.Visible = false; cAju.Visible = true; cCre.Visible = false; bT2.BackgroundColor3 = Color3.fromRGB(22,22,22); bT2.TextColor3 = Color3.new(1,1,1); bT1.BackgroundColor3 = Color3.fromRGB(12,12,12); bT1.TextColor3 = Color3.new(0.6,0.6,0.6); bT3.BackgroundColor3 = Color3.fromRGB(12,12,12); bT3.TextColor3 = Color3.new(0.6,0.6,0.6) end)
    bT3.MouseButton1Click:Connect(function() cFun.Visible = false; cAju.Visible = false; cCre.Visible = true; bT3.BackgroundColor3 = Color3.fromRGB(22,22,22); bT3.TextColor3 = Color3.new(1,1,1); bT1.BackgroundColor3 = Color3.fromRGB(12,12,12); bT1.TextColor3 = Color3.new(0.6,0.6,0.6); bT2.BackgroundColor3 = Color3.fromRGB(12,12,12); bT2.TextColor3 = Color3.new(0.6,0.6,0.6) end)

    local function addToggle(name, id, p)
        local b = Instance.new("TextButton", p); b.Size = UDim2.new(0.95, 0, 0, 38); b.BackgroundColor3 = Color3.fromRGB(22,22,22); b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        if p == cFun then b.LayoutOrder = orderFun; orderFun = orderFun + 1 end
        
        b.MouseButton1Click:Connect(function()
            if id == "AimbotForte" then cfg.AimbotMode = (cfg.AimbotMode == "Forte") and "None" or "Forte"
            elseif id == "AimbotFraco" then cfg.AimbotMode = (cfg.AimbotMode == "Fraco") and "None" or "Fraco"
            else cfg[id] = not cfg[id] end
        end)
        RunService.RenderStepped:Connect(function()
            local act = (id == "AimbotForte" and cfg.AimbotMode == "Forte") or (id == "AimbotFraco" and cfg.AimbotMode == "Fraco") or (cfg[id] == true)
            b.Text = name .. (act and ": ON" or ": OFF"); b.TextColor3 = act and Color3.new(0,1,0) or Color3.new(1,1,1)
        end)
    end

    local function addTargetBtn(name, part, p)
        local b = Instance.new("TextButton", p); b.Size = UDim2.new(0.95, 0, 0, 35); b.BackgroundColor3 = Color3.fromRGB(22,22,22); b.TextColor3 = Color3.new(1,1,1); b.Text = name; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        if p == cFun then b.LayoutOrder = orderFun; orderFun = orderFun + 1 end
        b.MouseButton1Click:Connect(function() cfg.TargetPart = part end)
        RunService.RenderStepped:Connect(function() b.TextColor3 = (cfg.TargetPart == part) and Color3.new(1,1,0) or Color3.new(1,1,1) end)
    end

    local function addStepper(name, key, min, max, p, step)
        local f = Instance.new("Frame", p); f.Size = UDim2.new(0.95, 0, 0, 45); f.BackgroundTransparency = 1
        if p == cAju then f.LayoutOrder = orderAju; orderAju = orderAju + 1 end
        local v = Instance.new("TextLabel", f); v.Size = UDim2.new(1, 0, 0, 25); v.Position = UDim2.new(0, 0, 0, 18); v.Text = tostring(cfg[key]); v.TextColor3 = Color3.new(1,1,1); v.BackgroundTransparency = 1
        local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0, 15); l.Text = name; l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1
        local m = Instance.new("TextButton", f); m.Size = UDim2.new(0, 35, 0, 25); m.Position = UDim2.new(0, 5, 0, 18); m.Text = "-"; m.BackgroundColor3 = Color3.fromRGB(0,0,0); m.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", m).CornerRadius = UDim.new(0, 4)
        local pl = Instance.new("TextButton", f); pl.Size = UDim2.new(0, 35, 0, 25); pl.Position = UDim2.new(1, -40, 0, 18); pl.Text = "+"; pl.BackgroundColor3 = Color3.fromRGB(0,0,0); pl.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", pl).CornerRadius = UDim.new(0, 4)
        m.MouseButton1Click:Connect(function() cfg[key] = math.max(min, cfg[key] - (step or 5)); v.Text = tostring(cfg[key]) end)
        pl.MouseButton1Click:Connect(function() cfg[key] = math.min(max, cfg[key] + (step or 5)); v.Text = tostring(cfg[key]) end)
    end

    local function addCreditText(text, p)
        local l = Instance.new("TextLabel", p); l.Size = UDim2.new(0.95, 0, 0, 30); l.BackgroundTransparency = 1; l.Text = text; l.TextColor3 = Color3.new(1,1,1); l.Font = "SourceSansBold"; l.TextSize = 16
        l.LayoutOrder = orderCre; orderCre = orderCre + 1
    end

    -- === ABA FUNÇÕES ===
    addToggle("ESP + LINHAS", "ESP", cFun)
    addToggle("AIMBOT FORTE", "AimbotForte", cFun)
    addToggle("AIMBOT FRACO", "AimbotFraco", cFun)
    addToggle("MOSTRAR FOV", "FOV", cFun)
    addToggle("IGNORAR TIME", "SafeTeam", cFun)
    addToggle("LED RGB", "LEDActive", cFun)

    -- INFORMAÇÃO FOCO DE MIRA
    local infoFrame = Instance.new("Frame", cFun)
    infoFrame.LayoutOrder = orderFun; orderFun = orderFun + 1
    infoFrame.Size = UDim2.new(0.95, 0, 0, 28); infoFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    local infoCorner = Instance.new("UICorner", infoFrame); infoCorner.CornerRadius = UDim.new(0, 8)
    local infoText = Instance.new("TextLabel", infoFrame)
    infoText.Size = UDim2.new(1, 0, 1, 0); infoText.Text = "(foco de mira)"; infoText.TextColor3 = Color3.new(0.7, 0.7, 0.7); infoText.BackgroundTransparency = 1; infoText.Font = "SourceSansItalic"; infoText.TextSize = 15

    addTargetBtn("CABEÇA", "Head", cFun)
    addTargetBtn("PEITO", "Torso", cFun)
    addTargetBtn("BRAÇO DIREITO", "RightArm", cFun)
    addTargetBtn("BRAÇO ESQUERDO", "LeftArm", cFun)
    addTargetBtn("PERNAS", "Legs", cFun)

    -- === ABA AJUSTES ===
    addStepper("TAMANHO FOV", "FOVSize", 10, 800, cAju, 10)
    addStepper("ALINHADOR FOV", "FOVPos", -300, 300, cAju, 5)
    addStepper("TRANSPARÊNCIA", "Transparency", 0, 0.9, cAju, 0.05)
    addStepper("VELO LED", "LEDSpeed", 1, 50, cAju, 1)
    addStepper("COR R", "R", 0, 255, cAju, 5)
    addStepper("COR G", "G", 0, 255, cAju, 5)
    addStepper("COR B", "B", 0, 255, cAju, 5)

    -- === ABA CRÉDITOS E DISCORD ===
    addCreditText("Executor: Delta", cCre)
    addCreditText("Versão do Hub: 4.5", cCre)
    addCreditText("Criadores: Mz Studio", cCre)
    addCreditText("Créditos: Mz mod", cCre)

    local btnDiscord = Instance.new("TextButton", cCre)
    btnDiscord.LayoutOrder = orderCre; orderCre = orderCre + 1
    btnDiscord.Size = UDim2.new(0.95, 0, 0, 45)
    btnDiscord.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    btnDiscord.TextColor3 = Color3.new(1, 1, 1)
    btnDiscord.Font = "SourceSansBold"; btnDiscord.TextSize = 16
    btnDiscord.Text = "COPIAR LINK DO DISCORD"
    Instance.new("UICorner", btnDiscord).CornerRadius = UDim.new(0, 8)

    btnDiscord.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard("https://discord.gg/q8gpA7CnF")
            btnDiscord.Text = "LINK COPIADO COM SUCESSO!"
            task.delay(2, function() btnDiscord.Text = "COPIAR LINK DO DISCORD" end)
        else
            btnDiscord.Text = "ERRO: EXECUTOR SEM SUPORTE"
            task.delay(2, function() btnDiscord.Text = "COPIAR LINK DO DISCORD" end)
        end
    end)

    -- --- LOOP PRINCIPAL (CORRIGIDO: VELOCIDADE DO LED AGORA FUNCIONA) ---
    RunService.RenderStepped:Connect(function()
        fovFrame.Visible = cfg.FOV
        fovFrame.Size = UDim2.new(0, cfg.FOVSize*2, 0, cfg.FOVSize*2)
        fovFrame.Position = UDim2.new(0.5, -cfg.FOVSize, 0.5, -cfg.FOVSize + cfg.FOVPos)

        -- CORREÇÃO APLICADA: a velocidade agora é controlada pelo cfg.LEDSpeed
        local hue = (tick() * (cfg.LEDSpeed / 10)) % 1
        local col = cfg.LEDActive and Color3.fromHSV(hue, 1, 1) or Color3.fromRGB(cfg.R, cfg.G, cfg.B)

        fovStroke.Color = col; mStroke.Color = col; bStroke.Color = col; cStroke.Color = col; title.TextColor3 = col
        main.BackgroundTransparency = cfg.Transparency; confirmFrame.BackgroundTransparency = cfg.Transparency

        local target = nil; local dist = cfg.FOVSize
        local center = Vector2.new(Camera.ViewportSize.X/2, (Camera.ViewportSize.Y/2) + cfg.FOVPos)

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local char = p.Character
                local isTeammate = (p.Team == LocalPlayer.Team)
                local line = tracers[p] or createTracer()
                tracers[p] = line
                
                if not cfg.ESP then line.Visible = false end

                if cfg.ESP and char and char:FindFirstChild("HumanoidRootPart") then
                    local root = char.HumanoidRootPart
                    local pos, vis = Camera:WorldToViewportPoint(root.Position)
                    local hl = char:FindFirstChild("MzHighlight")
                    
                    if not (cfg.SafeTeam and isTeammate) then
                        if not hl then hl = Instance.new("Highlight", char); hl.Name = "MzHighlight" end
                        hl.FillColor = isTeammate and Color3.new(0, 1, 0) or col
                        hl.Enabled = true
                        
                        if vis then
                            line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                            line.To = Vector2.new(pos.X, pos.Y)
                            line.Color = isTeammate and Color3.new(0, 1, 0) or col
                            line.Visible = true
                        else line.Visible = false end
                    else
                        if hl then hl:Destroy() end
                        line.Visible = false
                    end
                else
                    local hl = char and char:FindFirstChild("MzHighlight")
                    if hl then hl:Destroy() end
                    line.Visible = false
                end

                if cfg.AimbotMode ~= "None" and cfg.FOV == true and char and not (cfg.SafeTeam and isTeammate) then
                    local part = getPrecisePart(char, cfg.TargetPart)
                    if part then
                        local pos, vis = Camera:WorldToViewportPoint(part.Position)
                        if vis then
                            local mDist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                            if mDist <= cfg.FOVSize and mDist < dist then
                                dist = mDist; target = part
                            end
                        end
                    end
                end
            end
        end
        if target then Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), (cfg.AimbotMode == "Forte" and 1 or 0.15)) end
    end)

    btnClose.MouseButton1Click:Connect(function() confirmFrame.Visible = true end)
    bNao.MouseButton1Click:Connect(function() confirmFrame.Visible = false end)
    bSim.MouseButton1Click:Connect(function() for _, l in pairs(tracers) do l:Remove() end; mainGui:Destroy() end)

    bubble.MouseButton1Click:Connect(function() main.Visible = not main.Visible end)
    btnMin.MouseButton1Click:Connect(function() main.Size = (main.Size.Y.Offset == 420) and UDim2.new(0, 250, 0, 35) or UDim2.new(0, 250, 0, 420) end)
    -- ========== FIM DO SCRIPT PRINCIPAL ==========
end

-- ==================== FUNÇÃO ACEITAR ====================
local function aceitar(key, tipo)
    marcarKeyUsada(key)
    startGlobalReset()
    status.Text = "Acesso "..tipo
    if tipo == "DONO" then status.TextColor3 = Color3.fromRGB(255,215,0) else status.TextColor3 = Color3.fromRGB(0,220,120) end
    task.wait(0.8)
    rodando = false; ledRunning = false
    pcall(function() musica:Stop() end)
    
    -- Executa o script principal
    executarScriptPrincipal()

    if gui and gui.Parent then gui:Destroy() end
    getgenv().MZHUB_LOADED = false
    print("ACESSO "..tipo)
end

-- ==================== LÓGICA DE VERIFICAÇÃO DA KEY ====================
check.MouseButton1Click:Connect(function()
    local key = tostring(box.Text or ""):gsub("^%s*(.-)%s*$","%1")
    if key == "" then
        status.Text = "Key inválida"
        status.TextColor3 = Color3.fromRGB(255,80,80)
        return
    end

    if getgenv().MZ_RESET_ACTIVE and (getgenv().MZ_RESET_UNTIL and os.time() < getgenv().MZ_RESET_UNTIL) then
        local remaining = getgenv().MZ_RESET_UNTIL - os.time()
        status.Text = "Key inválida"
        status.TextColor3 = Color3.fromRGB(255,140,0)
        cooldownLabel.Text = tostring(remaining) .. "s"
        cooldownLabel.Visible = true
        return
    end

    local st = statusKey(key)
    if st == "active" then
        local used = lerUsedTable()
        local exp = used[key] or 0
        local remaining = math.max(0, exp - os.time())
        status.Text = "Key inválida"
        status.TextColor3 = Color3.fromRGB(255,140,0)
        cooldownLabel.Text = tostring(remaining) .. "s"
        cooldownLabel.Visible = true
        return

    elseif st == "expired" then
        status.Text = "Key inválida"
        status.TextColor3 = Color3.fromRGB(255,90,90)
        if not getgenv().MZ_RESET_ACTIVE then
            startGlobalReset()
        end
        return

    else -- not_used
        if key == KeyDono then aceitar(key,"DONO") return end
        if key == KeyCliente then aceitar(key,"CLIENTE") return end
        status.Text = "Key inválida"
        status.TextColor3 = Color3.fromRGB(255,80,80)
        return
    end
end)

-- Botão fechar da GUI de key
local closeBtn = Instance.new("TextButton")
closeBtn.Parent = frame
closeBtn.Size = UDim2.new(0,30,0,30)
closeBtn.Position = UDim2.new(1,-36,0,6)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextColor3 = Color3.fromRGB(255,80,80)
closeBtn.TextScaled = true
closeBtn.MouseButton1Click:Connect(function()
    rodando = false; ledRunning = false
    pcall(function() musica:Stop() end)
    if gui and gui.Parent then gui:Destroy() end
    getgenv().MZHUB_LOADED = false
end)

print("[MZHUB] carregado. TempoKey = "..TempoKey.."s | ResetDuration = "..ResetDuration.."s")
