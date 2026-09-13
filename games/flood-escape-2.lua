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
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local displayName = _G.ObbyHubDisplayName or "flood escape 2"
local title = string.upper(displayName)

local window = UI.createWindow({
    title = title,
    subtitle = displayName,
    width = 560,
    height = 440,
    toggleKey = Enum.KeyCode.J,
})

local right = window.createPanel("right")
local left = window.createPanel("left")

local fly = Utils.createFly({ speed = 100 })
local invincibility = Utils.createInvincibility()

local state = {
    perfectParkour = false,
    noFall = false,
    lastSafePos = nil,
    lastSafePlatform = nil,
    safeOffset = nil,
    safeCheckTime = 0,
    platform = nil,
    walkSpeed = 16,
    clickTP = false,
}

local tabs = UI.createTabs(right)

local moveTab = tabs.addTab("MOVE")
local assistTab = tabs.addTab("ASSIST")
local utilityTab = tabs.addTab("UTIL")

local flyBtn, flyStroke = UI.createButton(moveTab, "FLY: OFF", UDim2.new(1, 0, 0, 30))
flyBtn.MouseButton1Click:Connect(function()
    local on = fly:toggle()
    flyBtn.Text = on and "FLY: ON" or "FLY: OFF"
    UI.setButtonState(flyBtn, flyStroke, on)
end)

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, 0, 0, 12)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "FLY SPEED"
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.TextTransparency = 0.55
speedLabel.TextScaled = true
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = moveTab

local speedFrame = Instance.new("Frame")
speedFrame.Size = UDim2.new(1, 0, 0, 26)
speedFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
speedFrame.BorderSizePixel = 0
speedFrame.Parent = moveTab

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
walkLabel.BackgroundTransparency = 1
walkLabel.Text = "WALK SPEED"
walkLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
walkLabel.TextTransparency = 0.55
walkLabel.TextScaled = true
walkLabel.Font = Enum.Font.Gotham
walkLabel.TextXAlignment = Enum.TextXAlignment.Left
walkLabel.Parent = moveTab

local walkFrame = Instance.new("Frame")
walkFrame.Size = UDim2.new(1, 0, 0, 26)
walkFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
walkFrame.BorderSizePixel = 0
walkFrame.Parent = moveTab

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

local clickTPBtn, clickTPStroke = UI.createButton(moveTab, "CLICK TELEPORT: OFF", UDim2.new(1, 0, 0, 30))
clickTPBtn.MouseButton1Click:Connect(function()
    state.clickTP = not state.clickTP
    clickTPBtn.Text = state.clickTP and "CLICK TELEPORT: ON" or "CLICK TELEPORT: OFF"
    UI.setButtonState(clickTPBtn, clickTPStroke, state.clickTP)
end)

local perfectParkourBtn, perfectParkourStroke = UI.createButton(assistTab, "PERFECT PARKOUR: OFF", UDim2.new(1, 0, 0, 30))
local noFallBtn, noFallStroke = UI.createButton(assistTab, "NO FALL: OFF", UDim2.new(1, 0, 0, 30))
local invBtn, invStroke = UI.createButton(assistTab, "INVINCIBLE: OFF", UDim2.new(1, 0, 0, 30))

local grabBtn = UI.createButton(utilityTab, "GRAB PLAYER", UDim2.new(1, 0, 0, 30))
local passwordBtn = UI.createButton(utilityTab, "CODE KEYPAD", UDim2.new(1, 0, 0, 30))

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

local function getPlatformBelow()
    local root = Utils.getRoot()
    if not root then return nil, nil end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    local char = Utils.getChar()
    local ignore = {}
    if char then table.insert(ignore, char) end
    if state.platform then table.insert(ignore, state.platform) end
    params.FilterDescendantsInstances = ignore
    local result = Workspace:Raycast(root.Position, Vector3.new(0, -8, 0), params)
    if result and result.Instance then
        local offset = root.Position - result.Position
        return result.Instance, offset
    end
    return nil, nil
end

local function updatePerfectParkour()
    if not state.perfectParkour then return end
    local root = Utils.getRoot()
    local hum = Utils.getHum()
    if not root or not hum then return end
    if fly:isFlying() then return end

    local now = tick()
    if hum.FloorMaterial ~= Enum.Material.Air then
        if now - state.safeCheckTime > 0.2 then
            local platform, offset = getPlatformBelow()
            state.lastSafePos = root.CFrame
            state.lastSafePlatform = platform
            state.safeOffset = offset
            state.safeCheckTime = now
        end
    end

    if not state.lastSafePos then return end

    local fallDist = state.lastSafePos.Position.Y - root.Position.Y
    local horizDist = (Vector3.new(state.lastSafePos.X, 0, state.lastSafePos.Z) - Vector3.new(root.Position.X, 0, root.Position.Z)).Magnitude
    local vel = root.Velocity
    local falling = vel.Y < -18
    local launched = horizDist > 25 and vel.Y < 5 and hum.FloorMaterial == Enum.Material.Air
    local belowSafe = fallDist > 10

    if (belowSafe and falling) or (launched and fallDist > 5) then
        local target = state.lastSafePos
        if state.lastSafePlatform and state.lastSafePlatform.Parent and state.safeOffset then
            target = CFrame.new(state.lastSafePlatform.Position + state.safeOffset)
        end
        Utils.trueTeleport(target)
        window.notify("Saved from fall")
    end
end

perfectParkourBtn.MouseButton1Click:Connect(function()
    state.perfectParkour = not state.perfectParkour
    if state.perfectParkour then
        perfectParkourBtn.Text = "PERFECT PARKOUR: ON"
        state.lastSafePos = nil
        state.lastSafePlatform = nil
        state.safeOffset = nil
        state.safeCheckTime = 0
        window.notify("Perfect parkour ON")
    else
        perfectParkourBtn.Text = "PERFECT PARKOUR: OFF"
        state.lastSafePos = nil
        state.lastSafePlatform = nil
        state.safeOffset = nil
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

local function createOverlay(w, h)
    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(0, w, 0, h)
    overlay.Position = UDim2.new(0.5, -w / 2, 0.5, -h / 2)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 50
    overlay.Parent = window.gui

    local oc = Instance.new("UICorner")
    oc.CornerRadius = UDim.new(0, 12)
    oc.Parent = overlay

    local os = Instance.new("UIStroke")
    os.Color = Color3.fromRGB(255, 255, 255)
    os.Transparency = 0.4
    os.Thickness = 1
    os.Parent = overlay

    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 26, 0, 26)
    close.Position = UDim2.new(1, -32, 0, 6)
    close.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    close.BackgroundTransparency = 0.3
    close.Text = "X"
    close.TextColor3 = Color3.fromRGB(255, 255, 255)
    close.TextScaled = true
    close.Font = Enum.Font.GothamBold
    close.BorderSizePixel = 0
    close.AutoButtonColor = false
    close.ZIndex = 52
    close.Parent = overlay

    local cc = Instance.new("UICorner")
    cc.CornerRadius = UDim.new(0, 6)
    cc.Parent = close

    local cs = Instance.new("UIStroke")
    cs.Color = Color3.fromRGB(255, 255, 255)
    cs.Transparency = 0.5
    cs.Thickness = 1
    cs.Parent = close

    close.MouseButton1Click:Connect(function()
        overlay:Destroy()
    end)

    return overlay
end

local function openGrabPlayer()
    local overlay = createOverlay(340, 400)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -50, 0, 26)
    title.Position = UDim2.new(0, 14, 0, 8)
    title.BackgroundTransparency = 1
    title.Text = "GRAB PLAYER"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 52
    title.Parent = overlay

    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, -28, 0, 1)
    divider.Position = UDim2.new(0, 14, 0, 38)
    divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    divider.BackgroundTransparency = 0.6
    divider.BorderSizePixel = 0
    divider.ZIndex = 52
    divider.Parent = overlay

    local list = Instance.new("ScrollingFrame")
    list.Size = UDim2.new(1, -28, 1, -80)
    list.Position = UDim2.new(0, 14, 0, 46)
    list.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    list.BorderSizePixel = 0
    list.ScrollBarThickness = 3
    list.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
    list.CanvasSize = UDim2.new(0, 0, 0, 0)
    list.AutomaticCanvasSize = Enum.AutomaticSize.Y
    list.ZIndex = 52
    list.Parent = overlay

    local lc = Instance.new("UICorner")
    lc.CornerRadius = UDim.new(0, 8)
    lc.Parent = list

    local ls = Instance.new("UIStroke")
    ls.Color = Color3.fromRGB(255, 255, 255)
    ls.Transparency = 0.7
    ls.Thickness = 1
    ls.Parent = list

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = list

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 6)
    pad.PaddingBottom = UDim.new(0, 6)
    pad.PaddingLeft = UDim.new(0, 6)
    pad.PaddingRight = UDim.new(0, 6)
    pad.Parent = list

    local function refresh()
        for _, c in pairs(list:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        local order = 0
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= Players.LocalPlayer then
                order = order + 1
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, -6, 0, 40)
                btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                btn.BackgroundTransparency = 0.2
                btn.Text = ""
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                btn.TextScaled = true
                btn.Font = Enum.Font.GothamBold
                btn.BorderSizePixel = 0
                btn.AutoButtonColor = false
                btn.LayoutOrder = order
                btn.ZIndex = 53
                btn.Parent = list

                local bc = Instance.new("UICorner")
                bc.CornerRadius = UDim.new(0, 6)
                bc.Parent = btn

                local bs = Instance.new("UIStroke")
                bs.Color = Color3.fromRGB(255, 255, 255)
                bs.Transparency = 0.6
                bs.Thickness = 1
                bs.Parent = btn

                local displayNameLbl = Instance.new("TextLabel")
                displayNameLbl.Size = UDim2.new(1, -12, 0, 20)
                displayNameLbl.Position = UDim2.new(0, 6, 0, 2)
                displayNameLbl.BackgroundTransparency = 1
                displayNameLbl.Text = plr.DisplayName
                displayNameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
                displayNameLbl.TextScaled = true
                displayNameLbl.Font = Enum.Font.GothamBold
                displayNameLbl.TextXAlignment = Enum.TextXAlignment.Left
                displayNameLbl.ZIndex = 54
                displayNameLbl.Parent = btn

                local usernameLbl = Instance.new("TextLabel")
                usernameLbl.Size = UDim2.new(1, -12, 0, 14)
                usernameLbl.Position = UDim2.new(0, 6, 0, 22)
                usernameLbl.BackgroundTransparency = 1
                usernameLbl.Text = "@" .. plr.Name
                usernameLbl.TextColor3 = Color3.fromRGB(180, 180, 180)
                usernameLbl.TextScaled = true
                usernameLbl.Font = Enum.Font.Gotham
                usernameLbl.TextXAlignment = Enum.TextXAlignment.Left
                usernameLbl.ZIndex = 54
                usernameLbl.Parent = btn

                btn.MouseEnter:Connect(function()
                    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    displayNameLbl.TextColor3 = Color3.fromRGB(0, 0, 0)
                    usernameLbl.TextColor3 = Color3.fromRGB(60, 60, 60)
                end)
                btn.MouseLeave:Connect(function()
                    btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    displayNameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
                    usernameLbl.TextColor3 = Color3.fromRGB(180, 180, 180)
                end)

                btn.MouseButton1Click:Connect(function()
                    local localRoot = Utils.getRoot()
                    if not localRoot then return end
                    local targetChar = plr.Character
                    if not targetChar then
                        window.notify(plr.DisplayName .. " has no character")
                        return
                    end
                    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                    if not targetRoot then
                        window.notify(plr.DisplayName .. " has no root")
                        return
                    end
                    local targetHum = targetChar:FindFirstChild("Humanoid")
                    if targetHum then targetHum.PlatformStand = false end

                    local offset = localRoot.CFrame.LookVector * 3
                    local spawnPos = localRoot.Position + offset + Vector3.new(0, 3, 0)
                    targetRoot.CFrame = CFrame.new(spawnPos)
                    targetRoot.Velocity = Vector3.new(0, 0, 0)
                    targetRoot.RotVelocity = Vector3.new(0, 0, 0)
                    if targetRoot.AssemblyLinearVelocity then
                        targetRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    end
                    if targetRoot.AssemblyAngularVelocity then
                        targetRoot.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                    end

                    window.notify("Grabbed " .. plr.DisplayName)
                end)
            end
        end
    end

    refresh()
    Players.PlayerAdded:Connect(function()
        task.wait(0.3)
        refresh()
    end)
    Players.PlayerRemoving:Connect(function()
        task.wait(0.3)
        refresh()
    end)
end

local function openPassword()
    local overlay = createOverlay(300, 180)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -50, 0, 26)
    title.Position = UDim2.new(0, 14, 0, 8)
    title.BackgroundTransparency = 1
    title.Text = "CODE KEYPAD"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 52
    title.Parent = overlay

    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, -28, 0, 1)
    divider.Position = UDim2.new(0, 14, 0, 38)
    divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    divider.BackgroundTransparency = 0.6
    divider.BorderSizePixel = 0
    divider.ZIndex = 52
    divider.Parent = overlay

    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -28, 0, 32)
    input.Position = UDim2.new(0, 14, 0, 48)
    input.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    input.BorderSizePixel = 0
    input.Text = ""
    input.PlaceholderText = "4-digit code..."
    input.PlaceholderColor3 = Color3.fromRGB(140, 140, 140)
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.TextScaled = true
    input.Font = Enum.Font.Gotham
    input.ClearTextOnFocus = false
    input.ZIndex = 52
    input.Parent = overlay

    local ic = Instance.new("UICorner")
    ic.CornerRadius = UDim.new(0, 6)
    ic.Parent = input

    local is = Instance.new("UIStroke")
    is.Color = Color3.fromRGB(255, 255, 255)
    is.Transparency = 0.6
    is.Thickness = 1
    is.Parent = input

    local submit = Instance.new("TextButton")
    submit.Size = UDim2.new(0.48, 0, 0, 30)
    submit.Position = UDim2.new(0, 14, 0, 88)
    submit.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    submit.BackgroundTransparency = 0.2
    submit.Text = "SUBMIT"
    submit.TextColor3 = Color3.fromRGB(255, 255, 255)
    submit.TextScaled = true
    submit.Font = Enum.Font.GothamBold
    submit.BorderSizePixel = 0
    submit.AutoButtonColor = false
    submit.ZIndex = 52
    submit.Parent = overlay

    local sc = Instance.new("UICorner")
    sc.CornerRadius = UDim.new(0, 6)
    sc.Parent = submit

    local ss = Instance.new("UIStroke")
    ss.Color = Color3.fromRGB(255, 255, 255)
    ss.Transparency = 0.6
    ss.Thickness = 1
    ss.Parent = submit

    local autofill = Instance.new("TextButton")
    autofill.Size = UDim2.new(0.48, 0, 0, 30)
    autofill.Position = UDim2.new(0.52, 0, 0, 88)
    autofill.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    autofill.BackgroundTransparency = 0.2
    autofill.Text = "AUTOFILL"
    autofill.TextColor3 = Color3.fromRGB(255, 255, 255)
    autofill.TextScaled = true
    autofill.Font = Enum.Font.GothamBold
    autofill.BorderSizePixel = 0
    autofill.AutoButtonColor = false
    autofill.ZIndex = 52
    autofill.Parent = overlay

    local ac = Instance.new("UICorner")
    ac.CornerRadius = UDim.new(0, 6)
    ac.Parent = autofill

    local as = Instance.new("UIStroke")
    as.Color = Color3.fromRGB(255, 255, 255)
    as.Transparency = 0.6
    as.Thickness = 1
    as.Parent = autofill

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -28, 0, 40)
    status.Position = UDim2.new(0, 14, 0, 128)
    status.BackgroundTransparency = 1
    status.Text = "Stand near a keypad. SUBMIT to send code, AUTOFILL to read from keypad."
    status.TextColor3 = Color3.fromRGB(180, 180, 180)
    status.TextScaled = true
    status.Font = Enum.Font.Gotham
    status.TextWrapped = true
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.TextYAlignment = Enum.TextYAlignment.Top
    status.ZIndex = 52
    status.Parent = overlay

    submit.MouseEnter:Connect(function()
        submit.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        submit.TextColor3 = Color3.fromRGB(0, 0, 0)
    end)
    submit.MouseLeave:Connect(function()
        submit.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        submit.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    autofill.MouseEnter:Connect(function()
        autofill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        autofill.TextColor3 = Color3.fromRGB(0, 0, 0)
    end)
    autofill.MouseLeave:Connect(function()
        autofill.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        autofill.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)

    local function findKeypad()
        local root = Utils.getRoot()
        if not root then return nil end
        local origin = root.Position
        local best = nil
        local bestDist = 20
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") or v:IsA("Model") then
                local n = string.lower(v.Name)
                if n:find("keypad") or n:find("code") or n:find("door") or n:find("button") or n:find("key") then
                    local part = v:IsA("BasePart") and v or v.PrimaryPart
                    if part then
                        local dist = (part.Position - origin).Magnitude
                        if dist < bestDist then
                            bestDist = dist
                            best = v
                        end
                    end
                end
            end
        end
        return best
    end

    local function readCodeFromKeypad(keypad)
        if not keypad then return nil end
        for _, v in pairs(keypad:GetDescendants()) do
            if v:IsA("StringValue") or v:IsA("NumberValue") or v:IsA("IntValue") then
                local n = string.lower(v.Name)
                if n:find("code") or n:find("password") or n:find("pin") or n:find("key") then
                    return tostring(v.Value)
                end
            end
            if v:IsA("TextLabel") or v:IsA("TextButton") then
                local text = v.Text
                if text and text:match("^%d%d%d%d$") then
                    return text
                end
            end
        end
        return nil
    end

    local function fireKeypad(keypad, code)
        if not keypad then return false end
        local fired = false
        for _, v in pairs(keypad:GetDescendants()) do
            if v:IsA("RemoteEvent") then
                pcall(function()
                    v:FireServer(code)
                    fired = true
                end)
            elseif v:IsA("RemoteFunction") then
                pcall(function()
                    v:InvokeServer(code)
                    fired = true
                end)
            elseif v:IsA("ProximityPrompt") then
                pcall(function()
                    v:InputHoldBegin()
                    task.wait(0.1)
                    v:InputHoldEnd()
                    fired = true
                end)
            end
        end
        for _, v in pairs(ReplicatedStorage:GetDescendants()) do
            if v:IsA("RemoteEvent") then
                local n = string.lower(v.Name)
                if n:find("code") or n:find("keypad") or n:find("door") or n:find("enter") then
                    pcall(function()
                        v:FireServer(code)
                        fired = true
                    end)
                end
            end
        end
        return fired
    end

    submit.MouseButton1Click:Connect(function()
        local code = input.Text
        if code == "" then
            window.notify("Enter a code")
            return
        end
        local keypad = findKeypad()
        if not keypad then
            window.notify("No keypad nearby")
            return
        end
        if fireKeypad(keypad, code) then
            window.notify("Sent: " .. code)
        else
            window.notify("No remote found")
        end
    end)

    autofill.MouseButton1Click:Connect(function()
        local keypad = findKeypad()
        if not keypad then
            window.notify("No keypad nearby")
            return
        end
        local code = readCodeFromKeypad(keypad)
        if code then
            input.Text = code
            status.Text = "Read code: " .. code
            if fireKeypad(keypad, code) then
                window.notify("Auto-sent: " .. code)
            end
        else
            status.Text = "No code found in keypad model"
            window.notify("Code not readable")
        end
    end)
end

grabBtn.MouseButton1Click:Connect(openGrabPlayer)
passwordBtn.MouseButton1Click:Connect(openPassword)

local function setupDeathProtection()
    local char = Utils.getChar()
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end
    hum.Died:Connect(function()
        state.lastSafePos = nil
        state.lastSafePlatform = nil
        state.safeOffset = nil
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

setupDeathProtection()