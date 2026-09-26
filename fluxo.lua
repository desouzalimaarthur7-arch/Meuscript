-- AIM ASSIST - ROBLOX STUDIO
-- Coloque este LocalScript em StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- CONFIGURAÇÕES
local AIM_ENABLED = false
local FOV = 180
local AIM_STRENGTH = 0.18

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "AimAssistGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- BOTÃO FLUTUANTE
local openButton = Instance.new("TextButton")
openButton.Size = UDim2.fromOffset(55, 55)
openButton.Position = UDim2.new(0, 20, 0.5, -27)
openButton.Text = "🎯"
openButton.TextSize = 25
openButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
openButton.TextColor3 = Color3.new(1, 1, 1)
openButton.BorderSizePixel = 0
openButton.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = openButton

-- PAINEL
local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(230, 190)
panel.Position = UDim2.new(0, 85, 0.5, -95)
panel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = gui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 12)
panelCorner.Parent = panel

-- TÍTULO
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "🎯 AIM ASSIST"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.Parent = panel

-- BOTÃO AIM
local aimButton = Instance.new("TextButton")
aimButton.Size = UDim2.new(1, -20, 0, 45)
aimButton.Position = UDim2.fromOffset(10, 50)
aimButton.Text = "AIM ASSIST: OFF"
aimButton.TextSize = 16
aimButton.Font = Enum.Font.GothamBold
aimButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
aimButton.TextColor3 = Color3.new(1, 1, 1)
aimButton.BorderSizePixel = 0
aimButton.Parent = panel

local aimCorner = Instance.new("UICorner")
aimCorner.CornerRadius = UDim.new(0, 8)
aimCorner.Parent = aimButton

-- FOV
local fovLabel = Instance.new("TextLabel")
fovLabel.Size = UDim2.new(1, -20, 0, 30)
fovLabel.Position = UDim2.fromOffset(10, 105)
fovLabel.BackgroundTransparency = 1
fovLabel.Text = "FOV: 180"
fovLabel.TextColor3 = Color3.new(1, 1, 1)
fovLabel.TextSize = 15
fovLabel.Font = Enum.Font.Gotham
fovLabel.Parent = panel

local fovMinus = Instance.new("TextButton")
fovMinus.Size = UDim2.fromOffset(45, 35)
fovMinus.Position = UDim2.fromOffset(10, 140)
fovMinus.Text = "-"
fovMinus.TextSize = 22
fovMinus.Parent = panel

local fovPlus = Instance.new("TextButton")
fovPlus.Size = UDim2.fromOffset(45, 35)
fovPlus.Position = UDim2.fromOffset(175, 140)
fovPlus.Text = "+"
fovPlus.TextSize = 22
fovPlus.Parent = panel

-- ABRIR/FECHAR
openButton.MouseButton1Click:Connect(function()
	panel.Visible = not panel.Visible
end)

-- AIM ON/OFF
aimButton.MouseButton1Click:Connect(function()
	AIM_ENABLED = not AIM_ENABLED

	if AIM_ENABLED then
		aimButton.Text = "AIM ASSIST: ON"
		aimButton.BackgroundColor3 = Color3.fromRGB(35, 150, 70)
	else
		aimButton.Text = "AIM ASSIST: OFF"
		aimButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	end
end)

-- FOV
fovMinus.MouseButton1Click:Connect(function()
	FOV = math.max(50, FOV - 25)
	fovLabel.Text = "FOV: " .. FOV
end)

fovPlus.MouseButton1Click:Connect(function()
	FOV = math.min(500, FOV + 25)
	fovLabel.Text = "FOV: " .. FOV
end)

-- ENCONTRA O ALVO MAIS PRÓXIMO DO CENTRO
local function getClosestTarget()
	local character = player.Character
	if not character then return nil end

	local center = camera.ViewportSize / 2
	local closest = nil
	local closestDistance = FOV

	for _, targetPlayer in ipairs(Players:GetPlayers()) do
		if targetPlayer ~= player then

			local targetCharacter = targetPlayer.Character
			if targetCharacter then

				local humanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
				local head = targetCharacter:FindFirstChild("Head")

				if humanoid and head and humanoid.Health > 0 then

					local screenPosition, visible =
						camera:WorldToViewportPoint(head.Position)

					if visible then
						local distance = (
							Vector2.new(screenPosition.X, screenPosition.Y)
							- center
						).Magnitude

						if distance < closestDistance then
							closestDistance = distance
							closest = head
						end
					end
				end
			end
		end
	end

	return closest
end

-- AIM ASSIST
RunService.RenderStepped:Connect(function()
	if not AIM_ENABLED then
		return
	end

	local target = getClosestTarget()

	if target then
		local cameraPosition = camera.CFrame.Position
		local targetCFrame = CFrame.lookAt(
			cameraPosition,
			target.Position
		)

		camera.CFrame = camera.CFrame:Lerp(
			targetCFrame,
			AIM_STRENGTH
		)
	end
end)

-- ARRASTAR BOTÃO FLUTUANTE
local dragging = false
local dragStart
local startPosition

openButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1 then

		dragging = true
		dragStart = input.Position
		startPosition = openButton.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not dragging then return end

	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseMovement then

		local delta = input.Position - dragStart

		openButton.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1 then

		dragging = false
	end
end)
