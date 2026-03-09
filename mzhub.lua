-- MZHUB (persistência de arquivo + reset iniciado no momento da aceitação)
local KeyCliente  = "MZ-CLIENT-7Q2L9F-K4X8PA-T6Z3RM-91WV"
local KeyDono     = "cleude09"
local LinkKey     = "https://link-center.net/4011881/g1uHRMybfTo9"

local TempoKey     = 40 -- tempo que a key fica "ativa" (s) - não muda o Reset
local ResetDuration = 50 -- duração do cooldown global (s) - comecei em 50 conforme pediu

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

-- GUI
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

-- startGlobalReset: proteção com lock para evitar múltiplos inícios
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
        -- fim do reset: libera sistema limpando used keys
        salvarUsedTable({})
        getgenv().MZ_RESET_UNTIL = 0
        getgenv().MZ_RESET_ACTIVE = false
        getgenv().MZ_RESET_LOCK = false
        if cooldownLabel then cooldownLabel.Visible = false; cooldownLabel.Text = "" end
        print("[MZHUB] Reset concluído. Sistema liberado.")
    end)
end

local function aceitar(key, tipo)
    -- marcar key usada (persistir)
    marcarKeyUsada(key)
    -- iniciar reset IMEDIATAMENTE (a partir do momento da aceitação)
    startGlobalReset()
    status.Text = "Acesso "..tipo
    if tipo == "DONO" then status.TextColor3 = Color3.fromRGB(255,215,0) else status.TextColor3 = Color3.fromRGB(0,220,120) end
    task.wait(0.8)
    rodando = false; ledRunning = false
    pcall(function() musica:Stop() end)
    if gui and gui.Parent then gui:Destroy() end
    getgenv().MZHUB_LOADED = false
    print("ACESSO "..tipo)
end

-- Verificar: aceita 1x, depois inicia reset (já tratado em aceitar)
check.MouseButton1Click:Connect(function()
    local key = tostring(box.Text or ""):gsub("^%s*(.-)%s*$","%1")
    if key == "" then
        status.Text = "Key inválida"
        status.TextColor3 = Color3.fromRGB(255,80,80)
        return
    end

    -- se reset global ativo -> recusa e mostra contador
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
        -- se já está ativa (dentro do TempoKey) -> recusa, mostra restante
        local used = lerUsedTable()
        local exp = used[key] or 0
        local remaining = math.max(0, exp - os.time())
        status.Text = "Key inválida"
        status.TextColor3 = Color3.fromRGB(255,140,0)
        cooldownLabel.Text = tostring(remaining) .. "s"
        cooldownLabel.Visible = true
        return

    elseif st == "expired" then
        -- expirada -> recusar e iniciar reset (se ainda não iniciado)
        status.Text = "Key inválida"
        status.TextColor3 = Color3.fromRGB(255,90,90)
        if not getgenv().MZ_RESET_ACTIVE then
            startGlobalReset()
        end
        return

    else -- not_used => primeira vez: aceitar se for dono/cliente
        if key == KeyDono then aceitar(key,"DONO") return end
        if key == KeyCliente then aceitar(key,"CLIENTE") return end
        status.Text = "Key inválida"
        status.TextColor3 = Color3.fromRGB(255,80,80)
        return
    end
end)

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
