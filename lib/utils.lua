local Utils = {}

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local function getChar()
    local char = Players.LocalPlayer.Character
    if not char or not char.Parent then
        char = Players.LocalPlayer.CharacterAdded:Wait()
    end
    return char
end

local function getRoot()
    local char = getChar()
    if char then
        return char:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

local function getHum()
    local char = getChar()
    if char then
        return char:FindFirstChild("Humanoid")
    end
    return nil
end

local function clearBodyMovers(root)
    if not root then return end
    for _, v in pairs(root:GetChildren()) do
        if v:IsA("BodyVelocity") or v:IsA("BodyGyro") or v:IsA("BodyPosition") or v:IsA("BodyForce") or v:IsA("BodyThrust") then
            v:Destroy()
        end
    end
    root.Velocity = Vector3.new(0, 0, 0)
    root.RotVelocity = Vector3.new(0, 0, 0)
    if root.AssemblyLinearVelocity then
        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end
    if root.AssemblyAngularVelocity then
        root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    end
end

function Utils.getRoot() return getRoot() end
function Utils.getHum() return getHum() end
function Utils.getChar() return getChar() end

function Utils.trueTeleport(cframe)
    local root = getRoot()
    local hum = getHum()
    if not root then return false end

    clearBodyMovers(root)
    if hum then hum.PlatformStand = false end
    task.wait(0.05)
    root.CFrame = cframe
    clearBodyMovers(root)
    task.wait(0.05)
    return true
end

function Utils.createFly(config)
    config = config or {}
    local state = {
        flying = false,
        speed = config.speed or 100,
        acceleration = config.acceleration or 0.2,
        bodyVel = nil,
        bodyGyro = nil,
        conn = nil,
        velocity = Vector3.new(0, 0, 0),
        onChange = config.onChange or function() end,
    }

    local function start()
        if state.flying then return end
        local root = getRoot()
        local hum = getHum()
        if not root or not hum then return end

        state.flying = true
        hum.PlatformStand = true

        state.bodyVel = Instance.new("BodyVelocity")
        state.bodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        state.bodyVel.Velocity = Vector3.new(0, 0, 0)
        state.bodyVel.P = 1250
        state.bodyVel.Parent = root

        state.bodyGyro = Instance.new("BodyGyro")
        state.bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        state.bodyGyro.P = 1250
        state.bodyGyro.CFrame = root.CFrame
        state.bodyGyro.Parent = root

        state.conn = RunService.Heartbeat:Connect(function()
            if not state.flying then return end
            local r = getRoot()
            if not r or not state.bodyVel or not state.bodyGyro then return end

            local cam = Workspace.CurrentCamera
            if not cam then return end

            local move = Vector3.new(0, 0, 0)
            local fwd = cam.CFrame.LookVector
            local right = cam.CFrame.RightVector

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + fwd end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - fwd end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - right end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + right end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move * 2 end

            if move.Magnitude > 0 then
                move = move.Unit * state.speed
            end

            state.velocity = state.velocity:Lerp(move, state.acceleration)
            state.bodyVel.Velocity = state.velocity
            state.bodyGyro.CFrame = CFrame.new(r.Position, r.Position + cam.CFrame.LookVector)
        end)

        state.onChange(true)
    end

    local function stop()
        if not state.flying then return end
        state.flying = false
        state.velocity = Vector3.new(0, 0, 0)
        if state.conn then state.conn:Disconnect() state.conn = nil end
        if state.bodyVel then state.bodyVel:Destroy() state.bodyVel = nil end
        if state.bodyGyro then state.bodyGyro:Destroy() state.bodyGyro = nil end
        local hum = getHum()
        if hum then hum.PlatformStand = false end
        state.onChange(false)
    end

    function state:start() start() end
    function state:stop() stop() end
    function state:toggle()
        if self.flying then stop() else start() end
        return self.flying
    end
    function state:setSpeed(v) self.speed = v end
    function state:isFlying() return self.flying end

    return state
end

function Utils.createCheckpointManager(config)
    config = config or {}
    local state = {
        positions = {},
        max = config.max or 15,
        onChange = config.onChange or function() end,
    }

    function state:save()
        local root = getRoot()
        if not root then return false end
        if #self.positions >= self.max then
            table.remove(self.positions, 1)
        end
        table.insert(self.positions, {
            cframe = root.CFrame,
            name = "CP " .. tostring(#self.positions + 1),
            time = os.time(),
        })
        self.onChange()
        return true
    end

    function state:teleport(index)
        if #self.positions == 0 then return false end
        local idx = index or #self.positions
        local cp = self.positions[idx]
        if not cp then return false end
        Utils.trueTeleport(cp.cframe)
        return true
    end

    function state:delete(index)
        if not self.positions[index] then return false end
        table.remove(self.positions, index)
        for i, cp in pairs(self.positions) do
            cp.name = "CP " .. tostring(i)
        end
        self.onChange()
        return true
    end

    function state:clear()
        self.positions = {}
        self.onChange()
    end

    function state:count()
        return #self.positions
    end

    function state:getList()
        return self.positions
    end

    return state
end

function Utils.createInvincibility()
    local state = { enabled = false, conn = nil }

    local function apply()
        local hum = getHum()
        if hum then
            if hum.Health < 100 then hum.Health = 100 end
            if hum.MaxHealth < 100 then hum.MaxHealth = 100 end
            hum.BreakJointsOnDeath = false
        end
        local char = getChar()
        if char and not char:FindFirstChild("ForceField") then
            local ff = Instance.new("ForceField")
            ff.Parent = char
            task.delay(0.1, function()
                if ff and ff.Parent then ff:Destroy() end
            end)
        end
    end

    function state:enable()
        if self.enabled then return end
        self.enabled = true
        self.conn = RunService.Heartbeat:Connect(apply)
    end

    function state:disable()
        self.enabled = false
        if self.conn then self.conn:Disconnect() self.conn = nil end
    end

    function state:toggle()
        if self.enabled then self:disable() else self:enable() end
        return self.enabled
    end

    return state
end

function Utils.isInModelNamed(part, names, depth)
    depth = depth or 5
    local current = part
    for _ = 1, depth do
        if not current then break end
        local n = string.lower(current.Name)
        for _, target in ipairs(names) do
            if n:find(target) then return true end
        end
        current = current.Parent
    end
    return false
end

function Utils.isKillbrick(part)
    if not part then return false end
    local n = string.lower(part.Name)
    if n:find("kill") or n:find("lava") or n:find("fire") or n:find("spike") or n:find("damage") or n:find("void") then
        return true
    end
    if part.BrickColor then
        local bc = string.lower(part.BrickColor.Name)
        if bc == "really red" or bc == "bright red" or bc == "crimson" then
            return true
        end
    end
    return false
end

function Utils.findTopPlatform()
    local highest = -math.huge
    local top = nil
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Anchored and v.CanCollide then
            if not Utils.isInModelNamed(v, {"gate", "finish", "end", "win", "portal"}) then
                if not Utils.isKillbrick(v) then
                    if v.Size.Y <= 5 and v.Size.X >= 3 and v.Size.Z >= 3 then
                        if v.Position.Y > highest then
                            highest = v.Position.Y
                            top = v
                        end
                    end
                end
            end
        end
    end
    return top
end

function Utils.autoToTop()
    local top = Utils.findTopPlatform()
    if not top then return false end
    local above = top.Position + Vector3.new(0, top.Size.Y / 2 + 5, 0)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    local char = getChar()
    params.FilterDescendantsInstances = char and {char} or {}
    local hit = Workspace:Raycast(above + Vector3.new(0, 20, 0), Vector3.new(0, -60, 0), params)
    local pos = hit and (hit.Position + Vector3.new(0, 4, 0)) or above
    Utils.trueTeleport(CFrame.new(pos))
    return true
end

return Utils
