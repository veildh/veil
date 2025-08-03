-- Script created by khal! 🌸 Please do not re-upload or redistribute without credit. 🌸

-- SETTINGS
local fov = 120
local lockPart = "HumanoidRootPart"
local aimbotEnabled = false
local espEnabled = true
local headAimEnabled = false -- replaced by aimPart selection below
local triggerbotEnabled = false
-- Bullet TP, Auto Reload, No Recoil removed as requested
local speedHackEnabled = false
local currentTarget = nil
local currentTargetDistance = "N/A"
local currentAimPartIndex = 1
local aimPartsOptions = {"Head", "HumanoidRootPart", "LeftFoot"} -- Legs replaced by LeftFoot (Da Hood name may vary)
local themeColors = {
    Color3.fromRGB(255, 182, 193), -- pastel pink
    Color3.fromRGB(255, 165, 0),   -- orange
    Color3.fromRGB(0, 191, 255),   -- deep sky blue
}
local currentThemeIndex = 1
local themeColor = themeColors[currentThemeIndex]
local guiFont = Enum.Font.GothamBold -- Added from previous version for consistent font
local customIconAssetId = "rbxassetid://9061592305" -- Placeholder icon ID (e.g., a star or checkmark). REPLACE THIS!

-- PREDICTION SETTINGS (Added back)
local predictionOptions = {0.05, 0.1, 0.15, 0.2} -- Different prediction amounts (seconds)
local currentPredictionIndex = 1
local currentPredictionAmount = predictionOptions[currentPredictionIndex]

-- SPEED HACK SETTINGS
local normalWalkSpeed = 16
local speedHackWalkSpeed = 40

-- UTILITY SETTINGS
local flyEnabled = false
local flySpeed = 50

local fakeAnimationsEnabled = false
local defaultAnimationIds = {}

local zombieAnimationSet = {
    idle1 = "http://www.roblox.com/asset/?id=616158929",
    idle2 = "http://www.roblox.com/asset/?id=616160636",
    walk = "http://www.roblox.com/asset/?id=616168032",
    run = "http://www.roblox.com/asset/?id=616163682",
    jump = "http://www.roblox.com/asset/?id=616161997",
    climb = "http://www.roblox.com/asset/?id=616156119",
    fall = "http://www.roblox.com/asset/?id=616157476",
    swimidle = "http://www.roblox.com/asset/?id=0",
    swim = "http://www.roblox.com/asset/?id=0",
}

local customAnimationSet = {
    idle1 = "http://www.roblox.com/asset/?id=2510196951",
    idle2 = "http://www.roblox.com/asset/?id=2510197257",
    walk = "http://www.roblox.com/asset/?id=2510202577",
    run = "http://www.roblox.com/asset/?id=616163682",
    jump = "http://www.roblox.com/asset/?id=656117878",
    climb = "http://www.roblox.com/asset/?id=2510192778",
    fall = "http://www.roblox.com/asset/?id=707829716",
    swimidle = "http://www.roblox.com/asset/?id=0",
    swim = "http://www.roblox.com/asset/?id=0",
}


-- SERVICES
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService") -- Added for Rejoin functionality

-- ESP DATA
local espData = {}
local highlightData = {}
local nameTags = {}
local connections = {}

-- DRAW SKELETON
local function drawLine()
    local line = Drawing.new("Line")
    line.Thickness = 1.5
    line.Color = themeColor
    line.Transparency = 1
    line.ZIndex = 2
    return line
end

local function createSkeleton(player)
    if player == Players.LocalPlayer then return end

    local data = {}
    for _, bone in pairs({
        "Head", "HumanoidRootPart", "LeftUpperLeg", "RightUpperLeg", "LeftUpperArm", "RightUpperArm", "LeftFoot", "RightFoot"
    }) do
        data[bone] = drawLine()
    end
    espData[player] = data
end

local function removeSkeleton(player)
    if espData[player] then
        for _, line in pairs(espData[player]) do
            if line then line:Remove() end
        end
        espData[player] = nil
    end
end

local function updateSkeleton(player)
    local char = player.Character
    local lines = espData[player]
    if not char or not lines then return end

    local parts = {
        Head = char:FindFirstChild("Head"),
        HumanoidRootPart = char:FindFirstChild("HumanoidRootPart"),
        LeftUpperLeg = char:FindFirstChild("LeftUpperLeg"),
        RightUpperLeg = char:FindFirstChild("RightUpperLeg"),
        LeftFoot = char:FindFirstChild("LeftFoot"),
        RightFoot = char:FindFirstChild("RightFoot"),
        LeftUpperArm = char:FindFirstChild("LeftUpperArm"),
        RightUpperArm = char:FindFirstChild("RightUpperArm"),
        LeftLowerArm = char:FindFirstChild("LeftLowerArm"),
        RightLowerArm = char:FindFirstChild("RightLowerArm"),
        LeftLowerLeg = char:FindFirstChild("LeftLowerLeg"),
        RightLowerLeg = char:FindFirstChild("RightLowerLeg"),
    }

    local function draw(p1, p2, name)
        if parts[p1] and parts[p2] and lines[name] then
            local pos1, vis1 = Camera:WorldToViewportPoint(parts[p1].Position)
            local pos2, vis2 = Camera:WorldToViewportPoint(parts[p2].Position)
            if vis1 and vis2 then
                lines[name].From = Vector2.new(pos1.X, pos1.Y)
                lines[name].To = Vector2.new(pos2.X, pos2.Y)
                lines[name].Visible = true
                lines[name].Color = themeColor
            else
                lines[name].Visible = false
            end
        end
    end

    draw("Head", "HumanoidRootPart", "Head")
    draw("HumanoidRootPart", "LeftUpperLeg", "LeftUpperLeg")
    draw("HumanoidRootPart", "RightUpperLeg", "RightUpperLeg")
    draw("LeftUpperLeg", "LeftFoot", "LeftFoot")
    draw("RightUpperLeg", "RightFoot", "RightFoot")
    draw("HumanoidRootPart", "LeftUpperArm", "LeftUpperArm")
    draw("HumanoidRootPart", "RightUpperArm", "RightUpperArm")
    draw("LeftUpperArm", "LeftLowerArm", "LeftLowerArm")
    draw("RightUpperArm", "RightLowerArm", "RightLowerArm")
    draw("LeftUpperLeg", "LeftLowerLeg", "LeftLowerLeg")
    draw("RightUpperLeg", "RightLowerLeg", "RightLowerLeg")
end

-- Highlight ESP
local function createHighlight(player)
    if highlightData[player] then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESPHighlight"
    highlight.FillColor = themeColor
    highlight.OutlineColor = themeColor
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Parent = player.Character or player
    highlightData[player] = highlight
end

local function removeHighlight(player)
    if highlightData[player] then
        highlightData[player]:Destroy()
        highlightData[player] = nil
    end
end

-- Name Tags
local function createNameTag(player)
    if nameTags[player] then return end
    local char = player.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESPNameTag"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 100, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = head

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = player.Name
    label.TextColor3 = themeColor
    label.TextStrokeTransparency = 0.5
    label.Font = guiFont
    label.TextSize = 14
    label.Parent = billboard

    nameTags[player] = billboard
end

local function removeNameTag(player)
    if nameTags[player] then
        nameTags[player]:Destroy()
        nameTags[player] = nil
    end
end

-- Reset all ESP
local function resetAllESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            removeSkeleton(player)
            removeHighlight(player)
            removeNameTag(player)
            if espEnabled then
                createSkeleton(player)
                createHighlight(player)
                createNameTag(player)
            end
        end
    end
end

-- ESP SETUP
local function setupESP(player)
    if player == Players.LocalPlayer then return end
    createSkeleton(player)
    createHighlight(player)
    createNameTag(player)
    table.insert(connections, player.CharacterAdded:Connect(function()
        task.wait(0.2)
        removeSkeleton(player)
        removeHighlight(player)
        removeNameTag(player)
        if espEnabled then
            createSkeleton(player)
            createHighlight(player)
            createNameTag(player)
        end
    end))
    table.insert(connections, player.CharacterRemoving:Connect(function()
        removeSkeleton(player)
        removeHighlight(player)
        removeNameTag(player)
    end))
end

for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= Players.LocalPlayer then
        setupESP(plr)
    end
end

table.insert(connections, Players.PlayerAdded:Connect(function(plr)
    if plr ~= Players.LocalPlayer then
        setupESP(plr)
    end
end))

table.insert(connections, RunService.RenderStepped:Connect(function()
    if espEnabled then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= Players.LocalPlayer and plr.Character then
                if not espData[plr] then
                    createSkeleton(plr)
                end
                updateSkeleton(plr)
                if not highlightData[plr] then createHighlight(plr) end
                if not nameTags[plr] then createNameTag(plr) end
            end
        end
    else
        for _, skeleton in pairs(espData) do
            for _, line in pairs(skeleton) do
                if line then line.Visible = false end
            end
        end
        for _, highlight in pairs(highlightData) do
            if highlight then highlight.Enabled = false end
        end
        for _, tag in pairs(nameTags) do
            if tag then tag.Enabled = false end
        end
    end
end))

-- Helper to check if a player is a valid target based on visibility and FOV
local function isValidTarget(player)
    if not player or not player.Character then return false end
    local targetPart = player.Character:FindFirstChild(aimPartsOptions[currentAimPartIndex])
    local humanoid = player.Character:FindFirstChild("Humanoid")
    local localHRP = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

    if not targetPart or not humanoid or humanoid.Health <= 0 or not localHRP then return false end

    local screenPos, visible = Camera:WorldToViewportPoint(targetPart.Position)
    local screenCenter = Camera.ViewportSize / 2
    local distToCenter = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude

    if not visible or distToCenter > fov then return false end

    -- Raycast to check for obstructions (walls, etc.)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {Players.LocalPlayer.Character}
    local rayResult = Workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * (targetPart.Position - Camera.CFrame.Position).Magnitude, rayParams)

    if rayResult and rayResult.Instance and not rayResult.Instance:IsDescendantOf(player.Character) and not rayResult.Instance.Parent:IsDescendantOf(player.Character) then
        return false -- Target is behind an obstruction
    end
    return true -- Target is visible and not obstructed
end


-- AIMBOT TARGETING (uses currentAimPartIndex)
local function findNewClosestTarget()
    local bestCandidate = nil
    local shortestDistanceToCenter = math.huge
    local screenCenter = Camera.ViewportSize / 2
    local localHRP = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not localHRP then return nil end

    local aimPartName = aimPartsOptions[currentAimPartIndex]

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer and player.Character then
            local targetPart = player.Character:FindFirstChild(aimPartName)
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if targetPart and humanoid and humanoid.Health > 0 then
                local screenPos, visible = Camera:WorldToViewportPoint(targetPart.Position)
                local distToCenter = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude

                if visible and distToCenter < shortestDistanceToCenter and distToCenter <= fov then
                    -- Check if target is behind a wall
                    local rayParams = RaycastParams.new()
                    rayParams.FilterType = Enum.RaycastFilterType.Exclude
                    rayParams.FilterDescendantsInstances = {Players.LocalPlayer.Character}
                    local rayResult = Workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * (targetPart.Position - Camera.CFrame.Position).Magnitude, rayParams)

                    if not rayResult or (rayResult.Instance and (rayResult.Instance:IsDescendantOf(player.Character) or rayResult.Instance.Parent:IsDescendantOf(player.Character))) then
                        shortestDistanceToCenter = distToCenter
                        bestCandidate = player
                    end
                end
            end
        end
    end
    return bestCandidate
end

-- CAM LOCK
local function camLock()
    if currentTarget and currentTarget.Character then
        local aimPartName = aimPartsOptions[currentAimPartIndex]
        local targetPart = currentTarget.Character:FindFirstChild(aimPartName)
        if targetPart then
            local velocity = targetPart.Velocity or Vector3.new()
            local localHRP = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local dist = localHRP and (localHRP.Position - targetPart.Position).Magnitude or 0
            
            -- Use the selected prediction amount
            local futurePos = targetPart.Position + velocity * currentPredictionAmount
            
            -- Smooth camera interpolation using Lerp
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, futurePos), 0.25)
        end
    end
end

-- Speed Hack (adjust walk speed)
table.insert(connections, RunService.RenderStepped:Connect(function()
    local plr = Players.LocalPlayer
    local char = plr.Character
    if char and char:FindFirstChild("Humanoid") then
        if speedHackEnabled then
            char.Humanoid.WalkSpeed = speedHackWalkSpeed
        else
            char.Humanoid.WalkSpeed = normalWalkSpeed
        end
    end
end))

-- Fly Functionality
local currentFlyConnection = nil

local function toggleFly()
    local plr = Players.LocalPlayer
    local char = plr.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not hrp then return end
    
    flyEnabled = not flyEnabled

    if flyEnabled then
        humanoid.PlatformStand = true
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
        
        if currentFlyConnection then
            currentFlyConnection:Disconnect()
            currentFlyConnection = nil
        end

        currentFlyConnection = RunService.RenderStepped:Connect(function()
            if not flyEnabled or not char or not hrp then
                if currentFlyConnection then currentFlyConnection:Disconnect() end
                currentFlyConnection = nil
                return
            end
            
            local moveVector = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector += Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector -= Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector -= Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector += Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVector += Camera.CFrame.UpVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveVector -= Camera.CFrame.UpVector end

            local moveDirection = Camera.CFrame.RightVector * moveVector.X + Camera.CFrame.LookVector * moveVector.Z + Camera.CFrame.UpVector * moveVector.Y
            moveDirection = moveDirection.Unit * flySpeed * RunService.Heartbeat:Wait()

            hrp.CFrame += moveDirection
        end)

    else
        humanoid.PlatformStand = false
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
        
        if currentFlyConnection then
            currentFlyConnection:Disconnect()
            currentFlyConnection = nil
        end
    end
end

-- Helper function to apply an animation set
local function applyAnimationSet(animSet)
    local plr = Players.LocalPlayer
    local char = plr.Character
    if not char then return end
    local Animate = char:FindFirstChild("Animate")
    if not Animate then return end

    if animSet.idle1 then Animate.idle.Animation1.AnimationId = animSet.idle1 end
    if animSet.idle2 then Animate.idle.Animation2.AnimationId = animSet.idle2 end
    if animSet.walk then Animate.walk.WalkAnim.AnimationId = animSet.walk end
    if animSet.run then Animate.run.RunAnim.AnimationId = animSet.run end
    if animSet.jump then Animate.jump.JumpAnim.AnimationId = animSet.jump end
    if animSet.climb then Animate.climb.ClimbAnim.AnimationId = animSet.climb end
    if animSet.fall then Animate.fall.FallAnim.AnimationId = animSet.fall end
    if Animate.swimidle and animSet.swimidle then Animate.swimidle.SwimIdle.AnimationId = animSet.swimidle end
    if Animate.swim and animSet.swim then Animate.swim.Swim.AnimationId = animSet.swim end

    char.Humanoid.Jump = true
end

-- Function to apply the Custom Mix
local function applyCustomMix()
    fakeAnimationsEnabled = true
    applyAnimationSet(customAnimationSet)
end

-- Function to reset to default animations
local function resetToDefaultAnimations()
    fakeAnimationsEnabled = false
    applyAnimationSet(defaultAnimationIds)
end


-- AIMBOT + TRIGGERBOT
table.insert(connections, RunService.RenderStepped:Connect(function()
    local isRightClickPressed = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)

    -- Primary logic for target acquisition and retention
    if aimbotEnabled and isRightClickPressed then
        -- If currentTarget is invalid or not viable, find a new one
        if not currentTarget or not isValidTarget(currentTarget) then
            currentTarget = findNewClosestTarget()
        end

        -- If a valid target is found, perform aimlock
        if currentTarget and isValidTarget(currentTarget) then
            camLock()
        end
    else
        -- When aimbot is off or right-click is released, clear target
        currentTarget = nil
    end

    -- Update distance label
    if currentTarget and currentTarget.Character and Players.LocalPlayer.Character then
        local localHRP = Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local aimPartName = aimPartsOptions[currentAimPartIndex]
        local targetPart = currentTarget.Character:FindFirstChild(aimPartName)
        if localHRP and targetPart then
            currentTargetDistance = math.floor((localHRP.Position - targetPart.Position).Magnitude)
        else
            currentTargetDistance = "N/A"
        end
    else
        currentTargetDistance = "N/A"
    end

    if triggerbotEnabled then
        if currentTarget and isValidTarget(currentTarget) then
            -- Fire mouse click events for triggerbot
            if pcall(function() return mouse1click end) then
                mouse1click()
            elseif pcall(function() return mouse1press end) then
                mouse1press()
                task.wait(0.02)
                mouse1release()
            end
        end
    end
end))

-- CHAT SPY (unchanged)
table.insert(connections, Players.PlayerAdded:Connect(function(plr)
    table.insert(connections, plr.Chatted:Connect(function(msg)
        print("[ChatSpy] " .. plr.Name .. ": " .. msg)
    end))
end))
for _, plr in ipairs(Players:GetPlayers()) do
    table.insert(connections, plr.Chatted:Connect(function(msg)
        print("[ChatSpy] " .. plr.Name .. ": " .. msg)
    end))
end

-- GUI SETUP
local guiVisible = true
local toggleKey = Enum.KeyCode.Insert
local unloadKey = Enum.KeyCode.F7
local waitingForKeyBind = false
local rebindButton
local aimPartPopoutFrame
local utilityPopoutFrame

local function unloadScript()
    for _, conn in ipairs(connections) do
        if conn and typeof(conn) == "RBXScriptConnection" then
            conn:Disconnect()
        end
    end
    
    local gui = game.CoreGui:FindFirstChild("Aimlock_GUI")
    if gui then
        gui:Destroy()
    end
    
    for _, skeleton in pairs(espData) do
        for _, line in pairs(skeleton) do
            if line then line:Remove() end
        end
    end
    for _, highlight in pairs(highlightData) do
        if highlight then highlight:Destroy() end
    end
    for _, tag in pairs(nameTags) do
        if tag then tag:Destroy() end
    end

    local plr = Players.LocalPlayer
    local char = plr.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = normalWalkSpeed
        char.Humanoid.PlatformStand = false
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
    
    if currentFlyConnection then
        currentFlyConnection:Disconnect()
        currentFlyConnection = nil
    end
    
    print("Script unloaded. All functionality disabled.")
end


table.insert(connections, UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if waitingForKeyBind and input.UserInputType == Enum.UserInputType.Keyboard then
        toggleKey = input.KeyCode
        waitingForKeyBind = false
        if rebindButton then
            rebindButton.Text = "Menu Key: " .. toggleKey.Name
        end
        return
    end

    if input.KeyCode == toggleKey and not waitingForKeyBind then
        guiVisible = not guiVisible
        local gui = game.CoreGui:FindFirstChild("Aimlock_GUI")
        if gui then
            gui.Enabled = guiVisible
        end
    end

    if input.KeyCode == unloadKey then
        unloadScript()
    end

    -- Hide pop-out if clicked outside
    if aimPartPopoutFrame and aimPartPopoutFrame.Visible then
        local mousePos = UserInputService:GetMouseLocation()
        local absolutePosition = aimPartPopoutFrame.AbsolutePosition
        local absoluteSize = aimPartPopoutFrame.AbsoluteSize
        local mouseInFrame = mousePos.X >= absolutePosition.X and mousePos.X <= (absolutePosition.X + absoluteSize.X) and
                             mousePos.Y >= absolutePosition.Y and mousePos.Y <= (absolutePosition.Y + absoluteSize.Y)
        if not mouseInFrame then
            aimPartPopoutFrame.Visible = false
        end
    end

    if utilityPopoutFrame and utilityPopoutFrame.Visible then
        local mousePos = UserInputService:GetMouseLocation()
        local absolutePosition = utilityPopoutFrame.AbsolutePosition
        local absoluteSize = utilityPopoutFrame.AbsoluteSize
        local mouseInFrame = mousePos.X >= absolutePosition.X and mousePos.X <= (absolutePosition.X + absoluteSize.X) and
                             mousePos.Y >= absolutePosition.Y and mousePos.Y <= (absolutePosition.Y + absoluteSize.Y)
        if not mouseInFrame then
            utilityPopoutFrame.Visible = false
        end
    end
end))

local function createButton(name, posY, text, callback)
    local Frame = game.CoreGui:FindFirstChild("Aimlock_GUI"):FindFirstChildOfClass("Frame")
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(0, 180, 0, 22)
    button.Position = UDim2.new(0, 10, 0, posY)
    button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    button.BorderSizePixel = 2
    button.BorderColor3 = themeColor
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextScaled = true
    button.Font = guiFont
    button.Parent = Frame

    table.insert(connections, button.MouseButton1Click:Connect(function()
        callback(button)
    end))

    return button
end

local function createPopoutButton(parentFrame, name, text, callback)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(1, 0, 0, 22)
    button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    button.BorderSizePixel = 2
    button.BorderColor3 = themeColor
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextScaled = true
    button.Font = guiFont
    button.Parent = parentFrame

    table.insert(connections, button.MouseButton1Click:Connect(function()
        callback(button)
    end))

    return button
end

local function createGUI()
    if game.CoreGui:FindFirstChild("Aimlock_GUI") then
        game.CoreGui.Aimlock_GUI:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Aimlock_GUI"
    ScreenGui.Parent = game.CoreGui
    ScreenGui.DisplayOrder = 999

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 200, 0, 320)
    Frame.Position = UDim2.new(1, -220, 0, 50)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Frame.BorderSizePixel = 2
    Frame.BorderColor3 = themeColor
    Frame.Active = true
    Frame.Draggable = true
    Frame.Parent = ScreenGui

    local uiGradient = Instance.new("UIGradient")
    uiGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
    }
    uiGradient.Rotation = 90
    uiGradient.Parent = Frame

    local welcomeFrame = Instance.new("Frame")
    welcomeFrame.Name = "WelcomeFrame"
    welcomeFrame.Size = UDim2.new(0, 180, 0, 20)
    welcomeFrame.Position = UDim2.new(0, 10, 0, 0)
    welcomeFrame.BackgroundTransparency = 1
    welcomeFrame.Parent = Frame

    local horizontalListLayout = Instance.new("UIListLayout")
    horizontalListLayout.FillDirection = Enum.FillDirection.Horizontal
    horizontalListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    horizontalListLayout.Padding = UDim.new(0, 5)
    horizontalListLayout.Parent = welcomeFrame

    local iconImage = Instance.new("ImageLabel")
    iconImage.Size = UDim2.new(0, 18, 0, 18)
    iconImage.Image = customIconAssetId
    iconImage.BackgroundTransparency = 1
    iconImage.Parent = welcomeFrame

    local welcomeTextLabel = Instance.new("TextLabel")
    welcomeTextLabel.Size = UDim2.new(1, -23, 1, 0)
    welcomeTextLabel.Text = "Welcome " .. Players.LocalPlayer.Name
    welcomeTextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    welcomeTextLabel.TextScaled = true
    welcomeTextLabel.BackgroundTransparency = 1
    welcomeTextLabel.TextXAlignment = Enum.TextXAlignment.Left
    welcomeTextLabel.Font = guiFont
    welcomeTextLabel.Parent = welcomeFrame

    local aimlockButton = createButton("AimlockToggle", 30, "Aimlock: OFF", function(button)
        aimbotEnabled = not aimbotEnabled
        button.Text = aimbotEnabled and "Aimlock: ON" or "Aimlock: OFF"
    end)
    
    table.insert(connections, aimlockButton.MouseButton2Click:Connect(function()
        if aimPartPopoutFrame then
            aimPartPopoutFrame.Visible = not aimPartPopoutFrame.Visible
            if aimPartPopoutFrame.Visible then
                local absX, absY = aimlockButton.AbsolutePosition.X, aimlockButton.AbsolutePosition.Y
                local sizeX, sizeY = aimlockButton.AbsoluteSize.X, aimlockButton.AbsoluteSize.Y
                
                aimPartPopoutFrame.Position = UDim2.new(0, absX - aimPartPopoutFrame.AbsoluteSize.X - 30, 0, absY) 
                
                if utilityPopoutFrame then utilityPopoutFrame.Visible = false end
            end
        end
    end))

    createButton("TriggerbotToggle", 60, "Triggerbot: OFF", function(button)
        triggerbotEnabled = not triggerbotEnabled
        button.Text = triggerbotEnabled and "Triggerbot: ON" or "Triggerbot: OFF"
    end)

    -- NEW: Prediction Toggle (added back)
    local predictionButton = createButton("PredictionToggle", 90, "Prediction: " .. currentPredictionAmount .. "s", function(button)
        currentPredictionIndex = currentPredictionIndex + 1
        if currentPredictionIndex > #predictionOptions then currentPredictionIndex = 1 end
        currentPredictionAmount = predictionOptions[currentPredictionIndex]
        button.Text = "Prediction: " .. currentPredictionAmount .. "s"
    end)

    createButton("SpeedHackToggle", 120, "Speed Hack: OFF", function(button)
        speedHackEnabled = not speedHackEnabled
        button.Text = speedHackEnabled and "Speed Hack: ON" or "Speed Hack: OFF"
    end)

    createButton("ESPToggle", 150, "ESP: ON", function(button)
        espEnabled = not espEnabled
        button.Text = espEnabled and "ESP: ON" or "ESP: OFF"
        resetAllESP()
    end)

    createButton("ThemeToggle", 180, "Change ESP Color", function(button)
        currentThemeIndex = currentThemeIndex + 1
        if currentThemeIndex > #themeColors then currentThemeIndex = 1 end
        themeColor = themeColors[currentThemeIndex]
        resetAllESP()
    end)
    
    local utilityButton = createButton("UtilityToggle", 210, "Utility", function(button)
        if utilityPopoutFrame then
            utilityPopoutFrame.Visible = not utilityPopoutFrame.Visible
            if utilityPopoutFrame.Visible then
                local absX, absY = button.AbsolutePosition.X, button.AbsolutePosition.Y
                local sizeX, sizeY = button.AbsoluteSize.X, button.AbsoluteSize.Y
                utilityPopoutFrame.Position = UDim2.new(0, absX - utilityPopoutFrame.AbsoluteSize.X - 30, 0, absY)

                if aimPartPopoutFrame then aimPartPopoutFrame.Visible = false end
            end
        end
    end)

    rebindButton = createButton("RebindKey", 240, "Menu Key: " .. toggleKey.Name, function(button)
        waitingForKeyBind = true
        button.Text = "Press new key..."
    end)

    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Size = UDim2.new(0, 180, 0, 20)
    distanceLabel.Position = UDim2.new(0, 10, 0, 270)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    distanceLabel.TextSize = 14
    distanceLabel.Text = "Distance: N/A"
    distanceLabel.Font = guiFont
    distanceLabel.Parent = Frame

    table.insert(connections, RunService.RenderStepped:Connect(function()
        distanceLabel.Text = "Distance: " .. tostring(currentTargetDistance) .. "m"
    end))

    Frame.Size = UDim2.new(0, 200, 0, 300) -- Adjusted frame height to fit new button layout


    --- AIM PART POP-OUT FRAME ---
    aimPartPopoutFrame = Instance.new("Frame")
    aimPartPopoutFrame.Name = "AimPartPopout"
    aimPartPopoutFrame.Size = UDim2.new(0, 120, 0, 22 * #aimPartsOptions + (2 * (#aimPartsOptions -1)) + 4)
    aimPartPopoutFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    aimPartPopoutFrame.BorderSizePixel = 2
    aimPartPopoutFrame.BorderColor3 = themeColor
    aimPartPopoutFrame.Active = true
    aimPartPopoutFrame.Draggable = false
    aimPartPopoutFrame.Visible = false
    aimPartPopoutFrame.Parent = ScreenGui

    local popoutUIGradient = Instance.new("UIGradient")
    popoutUIGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
    }
    popoutUIGradient.Rotation = 90
    popoutUIGradient.Parent = aimPartPopoutFrame

    local listLayout = Instance.new("UIListLayout")
    listLayout.FillDirection = Enum.FillDirection.Vertical
    listLayout.Padding = UDim.new(0, 4)
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.Parent = aimPartPopoutFrame

    for i, partName in ipairs(aimPartsOptions) do
        createPopoutButton(aimPartPopoutFrame, partName .. "Button", partName, function()
            currentAimPartIndex = i
            lockPart = aimPartsOptions[currentAimPartIndex]
            aimlockButton.Text = (aimbotEnabled and "Aimlock: ON" or "Aimlock: OFF") .. " (" .. aimPartsOptions[currentAimPartIndex] .. ")"
            aimPartPopoutFrame.Visible = false
        end)
    end

    --- UTILITY POP-OUT FRAME ---
    utilityPopoutFrame = Instance.new("Frame")
    utilityPopoutFrame.Name = "UtilityPopout"
    utilityPopoutFrame.Size = UDim2.new(0, 150, 0, 22 * 4 + (2 * 3) + 4)
    utilityPopoutFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    utilityPopoutFrame.BorderSizePixel = 2
    utilityPopoutFrame.BorderColor3 = themeColor
    utilityPopoutFrame.Active = true
    utilityPopoutFrame.Draggable = false
    utilityPopoutFrame.Visible = false
    utilityPopoutFrame.Parent = ScreenGui

    local utilityPopoutUIGradient = Instance.new("UIGradient")
    utilityPopoutUIGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
    }
    utilityPopoutUIGradient.Rotation = 90
    utilityPopoutUIGradient.Parent = utilityPopoutFrame

    local utilityListLayout = Instance.new("UIListLayout")
    utilityListLayout.FillDirection = Enum.FillDirection.Vertical
    utilityListLayout.Padding = UDim.new(0, 4)
    utilityListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    utilityListLayout.Parent = utilityPopoutFrame

    -- UTILITY POP-OUT BUTTONS
    local function createUtilityPopoutButton(name, text, callback)
        local button = Instance.new("TextButton")
        button.Name = name
        button.Size = UDim2.new(1, 0, 0, 22)
        button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        button.BorderSizePixel = 2
        button.BorderColor3 = themeColor
        button.Text = text
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextScaled = true
        button.Font = guiFont
        button.Parent = utilityPopoutFrame
        table.insert(connections, button.MouseButton1Click:Connect(function()
            callback(button)
        end))
    end

    createUtilityPopoutButton("FlyToggle", "Fly: OFF", function(button)
        toggleFly()
        button.Text = flyEnabled and "Fly: ON" or "Fly: OFF"
    end)
    
    createUtilityPopoutButton("CustomMix", "Custom Mix", function()
        applyCustomMix()
    end)
    
    createUtilityPopoutButton("FacesEtc", "Faces, etc.", function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/RobloxHackerProLuaStuff/avatar-editor-thing/main/headless.lua"))()
    end)

    createUtilityPopoutButton("ResetAnims", "Reset Animations", function()
        resetToDefaultAnimations()
    end)
    
    createUtilityPopoutButton("Rejoin", "Rejoin Server", function()
        TeleportService:Teleport(game.PlaceId)
    end)
    
    -- Final Frame sizing based on content
    utilityPopoutFrame.Size = UDim2.new(0, 150, 0, 22 * utilityListLayout.Parent:GetChildrenCount() + (2 * (utilityListLayout.Parent:GetChildrenCount() - 1)) + 4)
    
    Frame.Size = UDim2.new(0, 200, 0, 298 + 30) -- Added some space for the new button
end

createGUI()
