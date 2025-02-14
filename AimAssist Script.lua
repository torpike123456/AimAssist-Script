local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local AimbotEnabled = true

local TeamCheck = true -- If set to true then the script would only lock your aim at enemy team members.
local AimParts = {"Head", "Head", "Head", "Head"} -- Where the aimbot script would lock at (first item - highest priority).
local Sensitivity = 0.0 -- How many seconds it takes for the aimbot script to officially lock onto the target's aimpart.

local CircleSides = 64 -- How many sides the FOV circle would have.
local CircleColor = Color3.fromRGB(255, 255, 255) -- (RGB) Color that the FOV circle would appear as.
local CircleTransparency = 0.25 -- Transparency of the circle.
local CircleRadius = 80 -- The radius of the circle / FOV.
local CircleFilled = false -- Determines whether or not the circle is filled.
local CircleVisible = false -- Determines whether or not the circle is visible.
local CircleThickness = 0 -- The thickness of the circle.
local ToggleAimbotKey = Enum.KeyCode.F15 -- The key that turns aimbot on/off
local ToggleTeamCheckKey = Enum.KeyCode.F14 -- The key that toggles the team chech condition

local FOVCircle = Drawing.new("Circle")
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
FOVCircle.Radius = CircleRadius
FOVCircle.Filled = CircleFilled
FOVCircle.Color = CircleColor
FOVCircle.Visible = CircleVisible
FOVCircle.Radius = CircleRadius
FOVCircle.Transparency = CircleTransparency
FOVCircle.NumSides = CircleSides
FOVCircle.Thickness = CircleThickness

local function CheckHealth(player)
    if player then
        if player.Character then
            if player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("Humanoid").Health then
                return player.Character:FindFirstChild("Humanoid").Health
            end
            if player.Character.Health then
                return player.Character.Health
            end
        end
    end

    return -1
end

local function FindAimPart(character)
    for _, v in ipairs(AimParts) do
        if character:FindFirstChild(v) ~= nil then
            return character[v]
        end
    end

    return nil
end

local function GetClosestPlayer()
    local MaximumDistance = CircleRadius
    local Target = nil
    local depth = math.huge

    for _, v in next, Players:GetPlayers() do
        if v.Name ~= LocalPlayer.Name then
            if TeamCheck == false or v.Team ~= LocalPlayer.Team then
                if v.Team ~= LocalPlayer.Team then
                    if v.Character ~= nil then
                        if CheckHealth(v) ~= 0 then
                            local aimPart = FindAimPart(v.Character)
                            if aimPart then
                                local vector3, onScreen = Camera:WorldToViewportPoint(aimPart.Position)
                                if vector3.Z >= 0 then
                                    local MousePoint = UserInputService:GetMouseLocation()
                                    local VectorDistance = math.sqrt(math.pow(vector3.X - MousePoint.X, 2) + math.pow(vector3.Y - MousePoint.Y, 2))

                                    if VectorDistance < MaximumDistance then
                                        if vector3.Z < depth then
                                            Target = aimPart
                                            depth = vector3.Z
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return Target
end

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == ToggleAimbotKey then
        AimbotEnabled = not AimbotEnabled
    end
    if input.KeyCode == ToggleTeamCheckKey then
        TeamCheck = not TeamCheck
    end
end)

local mousemoverel = (mousemoverel or (Input and Input.MouseMove)) or nil

local function updateMouse(target)
    if not target then return end
    local Mouse = game.Players.LocalPlayer:GetMouse()

    local posVector3 = Camera:WorldToScreenPoint(target.Position)
    local x, y = posVector3.X - Mouse.X, posVector3.Y - Mouse.Y

    if math.abs(x) > 4 then
        x = math.sign(x) * math.max(math.sqrt(math.abs(x)), 4)
    end
    if math.abs(y) > 4 then
        y = math.sign(y) * math.max(math.sqrt(math.abs(y)), 4)
    end

    if KRNL_LOADED then
        if x < 0 then
            x = x + 1 + 0xFFFFFFFF
        end
        if y < 0 then
            y = y + 1 + 0xFFFFFFFF
        end
    end

    mousemoverel(x, y)
end

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
    FOVCircle.Radius = CircleRadius
    FOVCircle.Filled = CircleFilled
    FOVCircle.Color = CircleColor
    FOVCircle.Visible = CircleVisible
    FOVCircle.Radius = CircleRadius
    FOVCircle.Transparency = CircleTransparency
    FOVCircle.NumSides = CircleSides
    FOVCircle.Thickness = CircleThickness

    if AimbotEnabled == true then
        target = GetClosestPlayer()
        if target ~= nil then
            if mousemoverel ~= nil then
                updateMouse(target)
            else
                TweenService:Create(Camera, TweenInfo.new(Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = CFrame.new(Camera.CFrame.Position, target.Position)}):Play()
            end
        end
    end
end)
