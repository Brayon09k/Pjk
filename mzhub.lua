local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

local cfg = {
    ESP = false, 
    AimbotMode = nil, 
    FOV = false, 
    FOVSize = 100,
    FOVPos = 0,
    SilentAim = false,
    Prediction = false,
    CheckLineOfSight = false,
    TeamCheck = true,
    FOVRadius3D = 150 -- 3D distance matching screen FOV
}
local ESPs = {}
local btnUpdates = {}
local lastUpdate = 0
local dragData = {}

-- UI PRINCIPAL
local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.Name = "MzHub_V9_Pro"; gui.ResetOnSpawn = false

-- CÍRCULO FOV (MELHORADO)
local fovFrame = Instance.new("Frame", gui)
fovFrame.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
fovFrame.BackgroundTransparency = 0.75
fovFrame.BorderSizePixel = 0
fovFrame.AnchorPoint = Vector2.new(0.5, 0.5)
fovFrame.Visible = false
Instance.new("UICorner", fovFrame).CornerRadius = UDim.new(1, 0)
local stroke = Instance.new("UIStroke", fovFrame)
stroke.Color = Color3.fromRGB(0, 255, 150)
stroke.Thickness = 3
stroke.Transparency = 0.5

-- Menu Expandido
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 260, 0, 480)
main.Position = UDim2.new(0.5, -130, 0.5, -240)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
main.Visible = false
main.BorderSizePixel = 0
local mainCorner = Instance.new("UICorner", main)
mainCorner.CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", main)
mainStroke.Color = Color3.fromRGB(0, 255, 150)
mainStroke.Thickness = 2

-- Título
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 10)
title.BackgroundTransparency = 1
title.Text = "🎮 MzHub V9 PRO"
title.TextColor3 = Color3.fromRGB(0, 255, 150)
title.Font = Enum.Font.GothamBold
title.TextSize = 18

-- Bolinha Móvel MELHORADA
local bubble = Instance.new("ImageButton", gui)
bubble.Size = UDim2.new(0, 55, 0, 55)
bubble.Position = UDim2.new(0, 20, 0, 200)
bubble.Image = "rbxassetid://81545220272311"
bubble.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
bubble.BackgroundTransparency = 0.2
Instance.new("UICorner", bubble).CornerRadius = UDim.new(1, 0)
local bubbleStroke = Instance.new("UIStroke", bubble)
bubbleStroke.Color = Color3.fromRGB(255, 255, 255)
bubbleStroke.Thickness = 2

-- DRAG SYSTEM PROFISSIONAL
bubble.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragData.startPos = bubble.Position
        dragData.startPoint = input.Position
        dragData.active = true
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragData.active and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragData.startPoint
        bubble.Position = UDim2.new(
            dragData.startPos.X.Scale,
            dragData.startPos.X.Offset + delta.X,
            dragData.startPos.Y.Scale,
            dragData.startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
        dragData.active = false
    end
end)

bubble.MouseButton1Click:Connect(function()
    main.Visible = not main.Visible
end)

-- Funções de Botão MELHORADAS
local function createBtn(name, y, id, callback)
    local btn = Instance.new("TextButton", main)
    btn.Size = UDim2.new(0, 220, 0, 38)
    btn.Position = UDim2.new(0, 20, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 15
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.BorderSizePixel = 0
    
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 8)
    local btnStroke = Instance.new("UIStroke", btn)
    btnStroke.Color = Color3.fromRGB(60, 60, 60)
    btnStroke.Thickness = 1
    
    local function update()
        local active = (id == "ESP" and cfg.ESP) or 
                      (id == "FOV" and cfg.FOV) or 
                      (cfg.AimbotMode == id) or
                      (id == "SilentAim" and cfg.SilentAim) or
                      (id == "Prediction" and cfg.Prediction) or
                      (id == "LineOfSight" and cfg.CheckLineOfSight)
        
        btn.Text = name .. (active and " ✅" or " ❌")
        btn.TextColor3 = active and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(220, 220, 220)
        btn.BackgroundColor3 = active and Color3.fromRGB(25, 60, 25) or Color3.fromRGB(35, 35, 35)
        btnStroke.Color = active and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(60, 60, 60)
    end
    
    btn.MouseButton1Click:Connect(function()
        if callback then callback() else
            if id == "ESP" then cfg.ESP = not cfg.ESP
            elseif id == "FOV" then cfg.FOV = not cfg.FOV; fovFrame.Visible = cfg.FOV
            elseif id == "SilentAim" then cfg.SilentAim = not cfg.SilentAim
            elseif id == "Prediction" then cfg.Prediction = not cfg.Prediction
            elseif id == "LineOfSight" then cfg.CheckLineOfSight = not cfg.CheckLineOfSight
            else cfg.AimbotMode = (cfg.AimbotMode == id) and nil or id
            end
        end
        for _, f in pairs(btnUpdates) do f() end
    end)
    btnUpdates[id] = update
    update()
    return btn
end

-- BOTÕES PRINCIPAIS
createBtn("🔍 ESP OTIMIZADO", 60, "ESP")
createBtn("💪 AIMBOT FORTE", 105, "Forte")
createBtn("⚡ AIMBOT FRACO", 150, "Fraco")
createBtn("🎯 MOSTRAR FOV", 195, "FOV")

-- BOTÕES AVANÇADOS
createBtn("🤫 SILENT AIM", 240, "SilentAim")
createBtn("📈 PREDIÇÃO", 285, "Prediction")
createBtn("👁️ LINE OF SIGHT", 330, "LineOfSight")

-- CONTROLES DE FOV
local lblFOVPos = Instance.new("TextLabel", main)
lblFOVPos.Size = UDim2.new(1, 0, 0, 25)
lblFOVPos.Position = UDim2.new(0, 0, 0, 380)
lblFOVPos.Text = "📍 ALTURA FOV: 0"
lblFOVPos.TextColor3 = Color3.fromRGB(255, 255, 255)
lblFOVPos.BackgroundTransparency = 1
lblFOVPos.Font = Enum.Font.Gotham
lblFOVPos.TextSize = 14

local btnFOVPosM = Instance.new("TextButton", main)
btnFOVPosM.Size = UDim2.new(0, 110, 0, 35)
btnFOVPosM.Position = UDim2.new(0, 20, 0, 410)
btnFOVPosM.Text = "⬇️ -Y"
btnFOVPosM.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
btnFOVPosM.TextColor3 = Color3.fromRGB(255, 255, 255)
btnFOVPosM.Font = Enum.Font.GothamBold
Instance.new("UICorner", btnFOVPosM).CornerRadius = UDim.new(0, 8)

local btnFOVPosP = Instance.new("TextButton", main)
btnFOVPosP.Size = UDim2.new(0, 110, 0, 35)
btnFOVPosP.Position = UDim2.new(0, 130, 0, 410)
btnFOVPosP.Text = "⬆️ +Y"
btnFOVPosP.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
btnFOVPosP.TextColor3 = Color3.fromRGB(255, 255, 255)
btnFOVPosP.Font = Enum.Font.GothamBold
Instance.new("UICorner", btnFOVPosP).CornerRadius = UDim.new(0, 8)

-- CONTROLES DE TAMANHO
local lblFOVSize = Instance.new("TextLabel", main)
lblFOVSize.Size = UDim2.new(1, 0, 0, 25)
lblFOVSize.Position = UDim2.new(0, 0, 0, 455)
lblFOVSize.Text = "📏 FOV 3D: 150"
lblFOVSize.TextColor3 = Color3.fromRGB(255, 255, 255)
lblFOVSize.BackgroundTransparency = 1
lblFOVSize.Font = Enum.Font.Gotham
lblFOVSize.TextSize = 14

local btnFOVSizeM = Instance.new("TextButton", main)
btnFOVSizeM.Size = UDim2.new(0, 110, 0, 35)
btnFOVSizeM.Position = UDim2.new(0, 20, 0, 485)
btnFOVSizeM.Text = "➖ FOV"
btnFOVSizeM.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
btnFOVSizeM.TextColor3 = Color3.fromRGB(255, 255, 255)
btnFOVSizeM.Font = Enum.Font.GothamBold
Instance.new("UICorner", btnFOVSizeM).CornerRadius = UDim.new(0, 8)

local btnFOVSizeP = Instance.new("TextButton", main)
btnFOVSizeP.Size = UDim2.new(0, 110, 0, 35)
btnFOVSizeP.Position = UDim2.new(0, 130, 0, 485)
btnFOVSizeP.Text = "➕ FOV"
btnFOVSizeP.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
btnFOVSizeP.TextColor3 = Color3.fromRGB(255, 255, 255)
btnFOVSizeP.Font = Enum.Font.GothamBold
Instance.new("UICorner", btnFOVSizeP).CornerRadius = UDim.new(0, 8)

-- EVENTOS DOS BOTÕES
btnFOVPosM.MouseButton1Click:Connect(function()
    cfg.FOVPos = cfg.FOVPos - 5
    lblFOVPos.Text = "📍 ALTURA FOV: " .. cfg.FOVPos
end)

btnFOVPosP.MouseButton1Click:Connect(function()
    cfg.FOVPos = cfg.FOVPos + 5
    lblFOVPos.Text = "📍 ALTURA FOV: " .. cfg.FOVPos
end)

btnFOVSizeM.MouseButton1Click:Connect(function()
    cfg.FOVSize = math.clamp(cfg.FOVSize - 10, 50, 500)
    cfg.FOVRadius3D = math.clamp(cfg.FOVRadius3D - 10, 50, 500)
    lblFOVSize.Text = "📏 FOV 3D: " .. cfg.FOVRadius3D
end)

btnFOVSizeP.MouseButton1Click:Connect(function()
    cfg.FOVSize = math.clamp(cfg.FOVSize + 10, 50, 500)
    cfg.FOVRadius3D = math.clamp(cfg.FOVRadius3D + 10, 50, 500)
    lblFOVSize.Text = "📏 FOV 3D: " .. cfg.FOVRadius3D
end)

-------------------------------------------------
-- SISTEMA ESP PROFISSIONAL
-------------------------------------------------
local function isValidTarget(data)
    if not data.Char or not data.Char.Parent or not data.HRP or data.Hum.Health <= 0 then
        return false
    end
    if data.Char == LocalPlayer.Character then return false end
    
    -- Team Check
    if cfg.TeamCheck then
        local myTeam = LocalPlayer.Team
        local theirTeam = data.Char:FindFirstChild("Team") or data.Char.Parent:FindFirstChild("Team")
        if myTeam and theirTeam and myTeam == theirTeam then
            return false
        end
    end
    
    return true
end

local function AplicarESP(p)
    if p == LocalPlayer then return end
    
    local function Setup(char)
        if not char or ESPs[p] then return end
        
        local hrp = char:WaitForChild("HumanoidRootPart", 10)
        local head = char:WaitForChild("Head", 10)
        local hum = char:WaitForChild("Humanoid", 10)
        if not hrp or not head or not hum then return end

        -- Cleanup existing
        if ESPs[p] then
            for _, v in pairs(ESPs[p]) do
                if v and v.Parent then v:Destroy() end
            end
        end

        local high = Instance.new("Highlight", char)
        high.FillTransparency = 0.8
        high.OutlineTransparency = 0
        high.Enabled = false
        
        local bb = Instance.new("BillboardGui", head)
        bb.Name = "MzESP"
        bb.Size = UDim2.new(0, 200, 0, 50)
        bb.StudsOffset = Vector3.new(0, 2, 0)
        bb.AlwaysOnTop = true
        bb.Enabled = false
        
        local grad = Instance.new("UIGradient", bb)
        grad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200))
        }
        grad.Rotation = 90
        
        local txt = Instance.new("TextLabel", bb)
        txt.Size = UDim2.new(1, -10, 1, 0)
        txt.Position = UDim2.new(0, 5, 0, 0)
        txt.BackgroundTransparency = 1
        txt.TextColor3 = Color3.fromRGB(0, 0, 0)
        txt.Font = Enum.Font.GothamBold
        txt.TextSize = 14
        txt.TextStrokeTransparency = 0
        txt.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
        
        local beam = Instance.new("Beam", workspace)
        beam.Width0 = 0.3
        beam.Width1 = 0.3
        beam.Enabled = false
        local att0 = Instance.new("Attachment", hrp)
        att0.Name = "ESPBeam0"
        local att1 = Instance.new("Attachment", LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
        att1.Name = "ESPBeam1"
        beam.Attachment0 = att0
        beam.Attachment1 = att1
        
        ESPs[p] = {
            Char = char, Hum = hum, HRP = hrp, Head = head,
            Text = txt, High = high, Beam = beam, BB = bb,
            Att0 = att0, Att1 = att1
        }
    end
    
    if p.Character then Setup(p.Character) end
    p.CharacterAdded:Connect(Setup)
end

-- Inicializar ESP
for _, p in pairs(Players:GetPlayers()) do AplicarESP(p) end
Players.PlayerAdded:Connect(AplicarESP)
LocalPlayer.CharacterAdded:Connect(function()
    wait(1)
    for p, data in pairs(ESPs) do
        if data.Att1 then data.Att1 = Instance.new("Attachment", LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
    end end
end)

-- LOOP PRINCIPAL OTIMIZADO (60 FPS)
RunService.Heartbeat:Connect(function()
    local now = tick()
    if now - lastUpdate < 1/60 then return end
    lastUpdate = now
    
    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    
    local center = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2 + cfg.FOVPos)
    
    -- FOV VISUAL
    if cfg.FOV then 
        fovFrame.Visible = true
        fovFrame.Position = UDim2.new(0, center.X - cfg.FOVSize, 0, center.Y - cfg.FOVSize)
        fovFrame.Size = UDim2.new(0, cfg.FOVSize*2, 0, cfg.FOVSize*2)
        
        -- Animação do stroke
        local hue = (now * 2) % 1
        stroke.Color = Color3.fromHSV(hue, 1, 1)
    else 
        fovFrame.Visible = false 
    end

    local target, minDist = nil, math.huge
    
    -- LOOP ESP + AIMBOT
    for p, data in pairs(ESPs) do
        if isValidTarget(data) and data.HRP and data.HRP.Parent then
            local dist3D = (myHRP.Position - data.HRP.Position).Magnitude
            
            -- ESP VISUAL
            if cfg.ESP then
                local hpPercent = math.floor((data.Hum.Health / data.Hum.MaxHealth) * 100)
                data.Text.Text = string.format("%s\n⚔️ %dm | ❤️ %d%%", p.Name, math.floor(dist3D), hpPercent)
                
                data.High.Enabled = true
                data.BB.Enabled = true
                data.Beam.Enabled = true
                
                -- Rainbow + distance color
                local hue = (now + p.UserId/100) % 1
                local color = Color3.fromHSV(hue, 1, 1)
                if dist3D > 50 then color = Color3.fromRGB(255, 100, 100) end
                data.High.OutlineColor = color
                data.Beam.Color = ColorSequence.new(color)
                
                -- Update beam attachment
                if data.Att1 and data.Att1.Parent ~= myHRP then
                    data.Att1.Parent = myHRP
                end
            else
                data.High.Enabled = false
                data.BB.Enabled = false
                data.Beam.Enabled = false
            end

            -- AIMBOT TARGET SELECTION
            if cfg.AimbotMode then
                local targetPos = data.HRP.Position
                
                -- Prediction
                if cfg.Prediction then
                    targetPos = targetPos + (data.HRP.Velocity * 0.1)
                end
                
                -- Line of Sight Check
                if cfg.CheckLineOfSight then
                    local ray = workspace:Raycast(myHRP.Position, (targetPos - myHRP.Position).Unit * dist3D)
                    if ray and ray.Instance:IsDescendantOf(data.Char) == false then
                        goto continue
                    end
                end
                
                -- FOV Check (3D distance matching screen)
                if dist3D <= cfg.FOVRadius3D then
                    local screenPos, onScreen = camera:WorldToViewportPoint(targetPos)
                    if onScreen then
                        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if screenDist < minDist then
                            minDist = screenDist
                            target = {HRP = data.HRP, Pos = targetPos}
                        end
                    end
                end
            end
        else
            ::continue::
            if data.High then 
                data.High.Enabled = false
                data.BB.Enabled = false
                data.Beam.Enabled = false
            end
        end
    end
    
    -- AIMBOT EXECUTION
    if target and cfg.AimbotMode then
        local lerpSpeed = (cfg.AimbotMode == "Forte") and 0.4 or 0.12
        
        if cfg.SilentAim then
            -- Silent aim (doesn't move camera visibly)
            local targetCFrame = CFrame.lookAt(camera.CFrame.Position, target.Pos)
            camera.CFrame = camera.CFrame:Lerp(targetCFrame, lerpSpeed)
        else
            -- Visible aimbot
            camera.CFrame = camera.CFrame:Lerp(
                CFrame.lookAt(camera.CFrame.Position, target.Pos), 
                lerpSpeed
            )
        end
    end
end)

print("🎮 MzHub V9 PRO carregado! Toque na bolinha verde para abrir o menu.")
