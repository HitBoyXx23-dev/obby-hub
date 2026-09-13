local UI = _G.ObbyHubUI
local Utils = _G.ObbyHubUtils

if not UI or not Utils then
    warn("[Obby Menu] Libraries not available")
    return
end

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local displayName = _G.ObbyHubDisplayName or "eternal towers of hell"
local title = string.upper(displayName)

local window = UI.createWindow({
    title = title,
    subtitle = displayName,
    width = 560,
    height = 440,
})

local left = window.createPanel("left")
local right = window.createPanel("right")

local checkpoints = Utils.createCheckpointManager({ max = 20 })
local fly = Utils.createFly({ speed = 100 })
local invincibility = Utils.createInvincibility()

local state = {
    perfectParkour = false,
    noFall = false,
    lastSafePos = nil,
    safeCheckTime = 0,
    platform = nil,
    walkSpeed = 16,
    clickTP = false,
}

local cpLabel = Instance.new("TextLabel")
cpLabel.Size = UDim2.new(1, 0, 0, 20)
cpLabel.BackgroundTransparency = 1
cpLabel.Text = "CHECKPOINTS  0/20"
cpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
cpLabel.TextTransparency = 0.3
cpLabel.TextScaled = true
cpLabel.Font = Enum.Font.GothamBold
cpLabel.TextXAlignment = Enum.TextXAlignment.Left
cpLabel.Parent = left

local cpList = UI.createScrollList(left, UDim2.new(1, 0, 1, -28), UDim2.new(0, 0, 0, 28))

local function updateCheckpointUI()
    for _, c in pairs(cpList:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
    cpLabel.Text = "CHECKPOINTS  " .. tostring(checkpoints:count()) .. "/20"
    for i, cp in pairs(checkpoints:getList()) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -8, 0, 28)
        row.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        row.BorderSizePixel = 0
        row.LayoutOrder = i
        row.Parent = cpList

        local rc = Instance.new("UICorner")
        rc.CornerRadius = UDim.new(0, 6)
        rc.Parent = row

        local rs = Instance.new("UIStroke")
        rs.Color = Color3.fromRGB(255, 255, 255)
        rs.Transparency = 0.6
        rs.Thickness = 1
        rs.Parent = row

        local nameBtn = Instance.new("TextButton")
        nameBtn.Size = UDim2.new(1, -30, 1, 0)
        nameBtn.BackgroundTransparency = 1
        nameBtn.Text = "  " .. cp.name
        nameBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameBtn.TextScaled = true
        nameBtn.Font = Enum.Font.Gotham
        nameBtn.TextXAlignment = Enum.TextXAlignment.Left
        nameBtn.AutoButtonColor = false
        nameBtn.Parent = row
        nameBtn.MouseButton1Click:Connect(function()
            checkpoints:teleport(i)
            window.notify("Teleported to " .. cp.name)
        end)

        local delBtn = Instance.new("TextButton")
        delBtn.Size = UDim2.new(0, 22, 0, 22)
        delBtn.Position = UDim2.new(1, -26, 0, 3)
        delBtn.BackgroundTransparency = 1
        delBtn.Text = "X"
        delBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        delBtn.TextTransparency = 0.5
        delBtn.TextScaled = true
        delBtn.Font = Enum.Font.GothamBold
        delBtn.AutoButtonColor = false
        delBtn.Parent = row
        delBtn.MouseButton1Click:Connect(function()
            checkpoints:delete(i)
            updateCheckpointUI()
        end)
        delBtn.MouseEnter:Connect(function() delBtn.TextTransparency = 0 end)
        delBtn.MouseLeave:Connect(function() delBtn.TextTransparency = 0.5 end)
    end
end

UI.createSectionLabel(right, "ACTIONS", 0)

local saveBtn = UI.createButton(right, "SAVE CHECKPOINT", UDim2.new(1, 0, 0, 26), UDim2.new(0, 0, 0, 16))
saveBtn.MouseButton1Click:Connect(function()
    if checkpoints:save() then
        updateCheckpointUI()
        window.notify("Checkpoint saved")
    end
end)

local tpBtn = UI.createButton(right, "TELEPORT TO LAST", UDim2.new(1, 0, 0, 26), UDim2.new(0, 0, 0, 46))
tpBtn.MouseButton1Click:Connect(function()
    if checkpoints:teleport() then
        window.notify("Teleported")
    else
        window.notify("No checkpoints")
    end
end)

local autoTopBtn = UI.createButton(right, "AUTO TO TOP", UDim2.new(1, 0, 0, 26), UDim2.new(0, 0, 0, 76))
autoTopBtn.MouseButton1Click:Connect(function()
    if Utils.autoToTop() then
        window.notify("Teleported to top")
    else
        window.notify("Top not found")
    end
end)

local clearBtn = UI.createButton(right, "CLEAR ALL", UDim2.new(1, 0, 0, 22), UDim2.new(0, 0, 0, 106))
clearBtn.MouseButton1Click:Connect(function()
    checkpoints:clear()
    updateCheckpointUI()
    window.notify("Cleared")
end)

UI.createSectionLabel(right, "MOVEMENT", 138)

local flyBtn, flyStroke = UI.createButton(right, "FLY: OFF", UDim2.new(1, 0, 0, 26), UDim2.new(0, 0, 0, 154))
flyBtn.MouseButton1Click:Connect(function()
    local on = fly:toggle()
    flyBtn.Text = on and "FLY: ON" or "FLY: OFF"
    UI.setButtonState(flyBtn, flyStroke, on)
end)

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, 0, 0, 12)
speedLabel.Position = UDim2.new(0, 0, 0, 184)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "FLY SPEED"
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.TextTransparency = 0.6
speedLabel.TextScaled = true
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = right

local speedFrame = Instance.new("Frame")
speedFrame.Size = UDim2.new(1, 0, 0, 26)
speedFrame.Position = UDim2.new(0, 0, 0, 198)
speedFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
speedFrame.BorderSizePixel = 0
speedFrame.Parent = right

local sfc = Instance.new("UICorner")
sfc.CornerRadius = UDim.new(0, 8)
sfc.Parent = speedFrame

local sfs = Instance.new("UIStroke")
sfs.Color = Color3.fromRGB(255, 255, 255)
sfs.Transparency = 0.7
sfs.Thickness = 1
sfs.Parent = speedFrame

local speedDown = Instance.new("TextButton")
speedDown.Size = UDim2.new(0, 28, 1, 0)
speedDown.Position = UDim2.new(0, 0, 0, 0)
speedDown.BackgroundTransparency = 1
speedDown.Text = "-"
speedDown.TextColor3 = Color3.fromRGB(255, 255, 255)
speedDown.TextScaled = true
speedDown.Font = Enum.Font.GothamBold
speedDown.AutoButtonColor = false
speedDown.Parent = speedFrame

local speedUp = Instance.new("TextButton")
speedUp.Size = UDim2.new(0, 28, 1, 0)
speedUp.Position = UDim2.new(1, -28, 0, 0)
speedUp.BackgroundTransparency = 1
speedUp.Text = "+"
speedUp.TextColor3 = Color3.fromRGB(255, 255, 255)
speedUp.TextScaled = true
speedUp.Font = Enum.Font.GothamBold
speedUp.AutoButtonColor = false
speedUp.Parent = speedFrame

local speedValue = Instance.new("TextLabel")
speedValue.Size = UDim2.new(1, -56, 1, 0)
speedValue.Position = UDim2.new(0, 28, 0, 0)
speedValue.BackgroundTransparency = 1
speedValue.Text = "100"
speedValue.TextColor3 = Color3.fromRGB(255, 255, 255)
speedValue.TextScaled = true
speedValue.Font = Enum.Font.GothamBold
speedValue.Parent = speedFrame

speedUp.MouseButton1Click:Connect(function()
    fly:setSpeed(math.clamp(fly.speed + 10, 10, 500))
    speedValue.Text = tostring(fly.speed)
end)

speedDown.MouseButton1Click:Connect(function()
    fly:setSpeed(math.clamp(fly.speed - 10, 10, 500))
    speedValue.Text = tostring(fly.speed)
end)

local walkLabel = Instance.new("TextLabel")
walkLabel.Size = UDim2.new(1, 0, 0, 12)
walkLabel.Position = UDim2.new(0, 0, 0, 230)
walkLabel.BackgroundTransparency = 1
walkLabel.Text = "WALK SPEED"
walkLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
walkLabel.TextTransparency = 0.6
walkLabel.TextScaled = true
walkLabel.Font = Enum.Font.Gotham
walkLabel.TextXAlignment = Enum.TextXAlignment.Left
walkLabel.Parent = right

local walkFrame = Instance.new("Frame")
walkFrame.Size = UDim2.new(1, 0, 0, 26)
walkFrame.Position = UDim2.new(0, 0, 0, 244)
walkFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
walkFrame.BorderSizePixel = 0
walkFrame.Parent = right

local wfc = Instance.new("UICorner")
wfc.CornerRadius = UDim.new(0, 8)
wfc.Parent = walkFrame

local wfs = Instance.new("UIStroke")
wfs.Color = Color3.fromRGB(255, 255, 255)
wfs.Transparency = 0.7
wfs.Thickness = 1
wfs.Parent = walkFrame

local walkDown = Instance.new("TextButton")
walkDown.Size = UDim2.new(0, 28, 1, 0)
walkDown.Position = UDim2.new(0, 0, 0, 0)
walkDown.BackgroundTransparency = 1
walkDown.Text = "-"
walkDown.TextColor3 = Color3.fromRGB(255, 255, 255)
walkDown.TextScaled = true
walkDown.Font = Enum.Font.GothamBold
walkDown.AutoButtonColor = false
walkDown.Parent = walkFrame

local walkUp = Instance.new("TextButton")
walkUp.Size = UDim2.new(0, 28, 1, 0)
walkUp.Position = UDim2.new(1, -28, 0, 0)
walkUp.BackgroundTransparency = 1
walkUp.Text = "+"
walkUp.TextColor3 = Color3.fromRGB(255, 255, 255)
walkUp.TextScaled = true
walkUp.Font = Enum.Font.GothamBold
walkUp.AutoButtonColor = false
walkUp.Parent = walkFrame

local walkValue = Instance.new("TextLabel")
walkValue.Size = UDim2.new(1, -56, 1, 0)
walkValue.Position = UDim2.new(0, 28, 0, 0)
walkValue.BackgroundTransparency = 1
walkValue.Text = "16"
walkValue.TextColor3 = Color3.fromRGB(255, 255, 255)
walkValue.TextScaled = true
walkValue.Font = Enum.Font.GothamBold
walkValue.Parent = walkFrame

walkUp.MouseButton1Click:Connect(function()
    state.walkSpeed = math.clamp(state.walkSpeed + 5, 16, 200)
    walkValue.Text = tostring(state.walkSpeed)
    local hum = Utils.getHum()
    if hum then hum.WalkSpeed = state.walkSpeed end
end)

walkDown.MouseButton1Click:Connect(function()
    state.walkSpeed = math.clamp(state.walkSpeed - 5, 16, 200)
    walkValue.Text = tostring(state.walkSpeed)
    local hum = Utils.getHum()
    if hum then hum.WalkSpeed = state.walkSpeed end
end)

local clickTPBtn, clickTPStroke = UI.createButton(right, "CLICK TELEPORT: OFF", UDim2.new(1, 0, 0, 26), UDim2.new(0, 0, 0, 278))
clickTPBtn.MouseButton1Click:Connect(function()
    state.clickTP = not state.clickTP
    clickTPBtn.Text = state.clickTP and "CLICK TELEPORT: ON" or "CLICK TELEPORT: OFF"
    UI.setButtonState(clickTPBtn, clickTPStroke, state.clickTP)
end)

UI.createSectionLabel(right, "AUTO-ASSIST", 314)

local perfectParkourBtn, perfectParkourStroke = UI.createButton(right, "PERFECT PARKOUR: OFF", UDim2.new(1, 0, 0, 24), UDim2.new(0, 0, 0, 330))
local noFallBtn, noFallStroke = UI.createButton(right, "NO FALL: OFF", UDim2.new(1, 0, 0, 24), UDim2.new(0, 0, 0, 358))
local invBtn, invStroke = UI.createButton(right, "INVINCIBLE: OFF", UDim2.new(1, 0, 0, 24), UDim2.new(0, 0, 0, 386))

local function createPlatform()
    if state.platform and state.platform.Parent then state.platform:Destroy() end
    local p = Instance.new("Part")
    p.Name = "NoFallPlatform"
    p.Size = Vector3.new(20, 1, 20)
    p.Anchored = true
    p.CanCollide = true
    p.Transparency = 0.6
    p.BrickColor = BrickColor.new("Institutional white")
    p.Material = Enum.Material.SmoothPlastic
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = Workspace
    state.platform = p
end

local function removePlatform()
    if state.platform then
        state.platform:Destroy()
        state.platform = nil
    end
end

local function updatePlatform()
    if not state.noFall then
        if state.platform then removePlatform() end
        return
    end
    if fly:isFlying() then
        if state.platform then removePlatform() end
        return
    end
    local root = Utils.getRoot()
    if not root then
        if state.platform then removePlatform() end
        return
    end
    if not state.platform or not state.platform.Parent then createPlatform() end
    if state.platform then
        state.platform.CFrame = CFrame.new(root.Position.X, root.Position.Y - 3.5, root.Position.Z)
    end
end

local function updatePerfectParkour()
    if not state.perfectParkour then return end
    local root = Utils.getRoot()
    local hum = Utils.getHum()
    if not root or not hum then return end
    if fly:isFlying() then return end

    local now = tick()
    if hum.FloorMaterial ~= Enum.Material.Air then
        if now - state.safeCheckTime > 0.3 then
            state.lastSafePos = root.CFrame
            state.safeCheckTime = now
        end
    end

    if state.lastSafePos then
        local fallDist = state.lastSafePos.Position.Y - root.Position.Y
        if fallDist > 15 then
            if root.Velocity.Y < -30 then
                Utils.trueTeleport(state.lastSafePos)
                window.notify("Saved from fall")
            end
        end
    end
end

perfectParkourBtn.MouseButton1Click:Connect(function()
    state.perfectParkour = not state.perfectParkour
    if state.perfectParkour then
        perfectParkourBtn.Text = "PERFECT PARKOUR: ON"
        state.lastSafePos = nil
        state.safeCheckTime = 0
        window.notify("Perfect parkour ON")
    else
        perfectParkourBtn.Text = "PERFECT PARKOUR: OFF"
        state.lastSafePos = nil
        window.notify("Perfect parkour off")
    end
    UI.setButtonState(perfectParkourBtn, perfectParkourStroke, state.perfectParkour)
end)

noFallBtn.MouseButton1Click:Connect(function()
    state.noFall = not state.noFall
    if state.noFall then
        noFallBtn.Text = "NO FALL: ON"
        createPlatform()
    else
        noFallBtn.Text = "NO FALL: OFF"
        removePlatform()
    end
    UI.setButtonState(noFallBtn, noFallStroke, state.noFall)
end)

invBtn.MouseButton1Click:Connect(function()
    local on = invincibility:toggle()
    invBtn.Text = on and "INVINCIBLE: ON" or "INVINCIBLE: OFF"
    UI.setButtonState(invBtn, invStroke, on)
end)

local function isOverGui(mouseX, mouseY)
    local frame = window.frame
    if not frame or not frame.Visible then return false end
    local pos = frame.AbsolutePosition
    local size = frame.AbsoluteSize
    return mouseX >= pos.X and mouseX <= pos.X + size.X and mouseY >= pos.Y and mouseY <= pos.Y + size.Y
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    if not state.clickTP then return end
    local mouseLoc = UserInputService:GetMouseLocation()
    if isOverGui(mouseLoc.X, mouseLoc.Y) then return end
    local camera = Workspace.CurrentCamera
    if not camera then return end
    local unitRay = camera:ViewportPointToRay(mouseLoc.X, mouseLoc.Y)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    local char = Utils.getChar()
    params.FilterDescendantsInstances = char and {char} or {}
    local result = Workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, params)
    if result then
        Utils.trueTeleport(CFrame.new(result.Position + Vector3.new(0, 3, 0)))
        window.notify("Teleported")
    end
end)

local function setupDeathProtection()
    local char = Utils.getChar()
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end
    hum.Died:Connect(function()
        if fly:isFlying() then
            fly:stop()
            flyBtn.Text = "FLY: OFF"
            UI.setButtonState(flyBtn, flyStroke, false)
        end
    end)
end

Players.LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    setupDeathProtection()
end)

RunService.Heartbeat:Connect(function()
    if state.perfectParkour then updatePerfectParkour() end
    if state.noFall then updatePlatform() end
    if state.walkSpeed ~= 16 then
        local hum = Utils.getHum()
        if hum and hum.WalkSpeed ~= state.walkSpeed then
            hum.WalkSpeed = state.walkSpeed
        end
    end
end)

updateCheckpointUI()
setupDeathProtection()
