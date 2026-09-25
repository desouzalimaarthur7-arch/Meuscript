-- FIRE DASH - LOCAL SCRIPT ÚNICO
-- GUI + DASH + TRAIL + PARTÍCULAS + FOV + SHAKE

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- =========================
-- CONFIG
-- =========================

local HOLD_TIME = 1.5
local DASH_SPEED = 600
local DASH_DISTANCE = 120
local COOLDOWN = 4
local FOV_BOOST = 15
local SHAKE_TIME = 0.4
local SHAKE_INTENSITY = 0.6

local carregando = false
local emCooldown = false
local inicioHold = 0

-- =========================
-- GUI
-- =========================

local gui = Instance.new("ScreenGui")
gui.Name = "FireDashGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local botao = Instance.new("TextButton")
botao.Name = "DashButton"
botao.Size = UDim2.new(0, 170, 0, 60)
botao.Position = UDim2.new(0.5, -85, 1, -130)
botao.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
botao.BackgroundTransparency = 0.1
botao.TextColor3 = Color3.fromRGB(255, 140, 0)
botao.Text = "🔥 SEGURE"
botao.TextSize = 20
botao.Font = Enum.Font.GothamBold
botao.AutoButtonColor = false
botao.Parent = gui

local canto = Instance.new("UICorner")
canto.CornerRadius = UDim.new(0, 15)
canto.Parent = botao

local borda = Instance.new("UIStroke")
borda.Thickness = 2
borda.Color = Color3.fromRGB(255, 120, 0)
borda.Parent = botao

local barraFundo = Instance.new("Frame")
barraFundo.Size = UDim2.new(0, 220, 0, 10)
barraFundo.Position = UDim2.new(0.5, -110, 1, -65)
barraFundo.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
barraFundo.Visible = false
barraFundo.Parent = gui

local barraCanto = Instance.new("UICorner")
barraCanto.CornerRadius = UDim.new(1, 0)
barraCanto.Parent = barraFundo

local barra = Instance.new("Frame")
barra.Size = UDim2.new(0, 0, 1, 0)
barra.BackgroundColor3 = Color3.fromRGB(255, 120, 0)
barra.Parent = barraFundo

local barraCanto2 = Instance.new("UICorner")
barraCanto2.CornerRadius = UDim.new(1, 0)
barraCanto2.Parent = barra

local status = Instance.new("TextLabel")
status.Size = UDim2.new(0, 280, 0, 35)
status.Position = UDim2.new(0.5, -140, 1, -185)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.fromRGB(255, 140, 0)
status.TextSize = 18
status.Font = Enum.Font.GothamBold
status.Text = ""
status.Visible = false
status.Parent = gui

-- =========================
-- PERSONAGEM
-- =========================

local function pegarPersonagem()
	local char = player.Character
	if not char then return end

	local humanoid = char:FindFirstChildOfClass("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart")

	if not humanoid or not hrp then
		return
	end

	return char, humanoid, hrp
end

-- =========================
-- TRAIL
-- =========================

local function criarTrail(char)
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local antigo = hrp:FindFirstChild("FireDashTrail")
	if antigo then
		antigo:Destroy()
	end

	local a0 = Instance.new("Attachment")
	a0.Name = "FireDashA0"
	a0.Position = Vector3.new(0, 2, 0)
	a0.Parent = hrp

	local a1 = Instance.new("Attachment")
	a1.Name = "FireDashA1"
	a1.Position = Vector3.new(0, -2, 0)
	a1.Parent = hrp

	local trail = Instance.new("Trail")
	trail.Name = "FireDashTrail"
	trail.Attachment0 = a0
	trail.Attachment1 = a1
	trail.Lifetime = 0.35
	trail.Color = ColorSequence.new(
		Color3.fromRGB(255, 180, 0),
		Color3.fromRGB(255, 40, 0)
	)
	trail.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.1),
		NumberSequenceKeypoint.new(1, 1)
	})
	trail.LightEmission = 1
	trail.Enabled = false
	trail.Parent = hrp
end

local function ativarTrail(char, ativo)
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local trail = hrp:FindFirstChild("FireDashTrail")

	if trail then
		trail.Enabled = ativo
	end

	local attachment = hrp:FindFirstChild("FireDashA0")
	if not attachment then return end

	local particle = attachment:FindFirstChild("FireParticles")

	if ativo then
		if not particle then
			particle = Instance.new("ParticleEmitter")
			particle.Name = "FireParticles"

			particle.Texture = "rbxassetid://243098098"
			particle.Color = ColorSequence.new(
				Color3.fromRGB(255, 180, 0),
				Color3.fromRGB(255, 40, 0)
			)

			particle.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1.2),
				NumberSequenceKeypoint.new(1, 0)
			})

			particle.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.2),
				NumberSequenceKeypoint.new(1, 1)
			})

			particle.Lifetime = NumberRange.new(0.3, 0.6)
			particle.Rate = 120
			particle.Speed = NumberRange.new(2, 6)
			particle.SpreadAngle = Vector2.new(180, 180)
			particle.LightEmission = 1

			particle.Parent = attachment
		end

		particle.Enabled = true

	elseif particle then
		particle.Enabled = false
	end
end

-- =========================
-- CAMERA
-- =========================

local shakeConnection

local function shakeCamera()
	local camera = workspace.CurrentCamera
	if not camera then return end

	local inicio = tick()

	if shakeConnection then
		shakeConnection:Disconnect()
	end

	shakeConnection = RunService.RenderStepped:Connect(function()
		local tempo = tick() - inicio

		if tempo >= SHAKE_TIME then
			shakeConnection:Disconnect()
			shakeConnection = nil
			return
		end

		local intensidade =
			1 - (tempo / SHAKE_TIME)

		camera.CFrame =
			camera.CFrame *
			CFrame.new(
				(math.random() - 0.5) *
					SHAKE_INTENSITY *
					intensidade,

				(math.random() - 0.5) *
					SHAKE_INTENSITY *
					intensidade,

				0
			)
	end)
end

local function mudarFOV(ativo)
	local camera = workspace.CurrentCamera
	if not camera then return end

	local alvo = ativo and (70 + FOV_BOOST) or 70

	local tween = TweenService:Create(
		camera,
		TweenInfo.new(
			ativo and 0.15 or 0.35,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		),
		{
			FieldOfView = alvo
		}
	)

	tween:Play()
end

-- =========================
-- DASH
-- =========================

local function executarDash()
	if emCooldown then return end

	local char, humanoid, hrp = pegarPersonagem()
	if not char or not humanoid or not hrp then return end

	emCooldown = true

	status.Visible = true
	status.Text = "🚀 DASH!"

	ativarTrail(char, true)
	mudarFOV(true)
	shakeCamera()

	local velocidadeAntiga = hrp.AssemblyLinearVelocity
	local autoRotateAntigo = humanoid.AutoRotate

	humanoid.AutoRotate = false

	local camera = workspace.CurrentCamera

	local direcao = camera.CFrame.LookVector

	-- Mantém o dash na horizontal
	direcao = Vector3.new(
		direcao.X,
		0,
		direcao.Z
	)

	if direcao.Magnitude < 0.01 then
		direcao = hrp.CFrame.LookVector
	end

	direcao = direcao.Unit

	local inicio = hrp.Position
	local destino = inicio + direcao * DASH_DISTANCE

	local distancia = (destino - inicio).Magnitude
	local tempo = distancia / DASH_SPEED

	hrp.AssemblyLinearVelocity =
		direcao * DASH_SPEED

	task.wait(tempo)

	if hrp and hrp.Parent then
		hrp.AssemblyLinearVelocity = Vector3.zero

		humanoid.AutoRotate = autoRotateAntigo

		ativarTrail(char, false)
		mudarFOV(false)

		status.Text = "⏳ COOLDOWN"

		for i = COOLDOWN, 0, -0.1 do
			if not status.Parent then break end

			status.Text =
				("⏳ Cooldown: %.1fs"):format(i)

			task.wait(0.1)
		end

		status.Visible = false

		-- restaura apenas se ainda estiver parado
		if hrp.Parent then
			hrp.AssemblyLinearVelocity =
				velocidadeAntiga
		end
	end

	emCooldown = false
end

-- =========================
-- CARREGAMENTO
-- =========================

local function iniciarCarregamento()
	if carregando or emCooldown then
		return
	end

	carregando = true
	inicioHold = tick()

	barraFundo.Visible = true
	status.Visible = true

	status.Text = "🔥 CARREGANDO..."

	while carregando do
		local progresso =
			math.clamp(
				(tick() - inicioHold) / HOLD_TIME,
				0,
				1
			)

		barra.Size =
			UDim2.new(
				progresso,
				0,
				1,
				0
			)

		if progresso >= 1 then
			status.Text =
				"🔥 PRONTO! SOLTE!"
		end

		RunService.RenderStepped:Wait()
	end
end

local function finalizarCarregamento()
	if not carregando then
		return
	end

	carregando = false

	local tempo =
		tick() - inicioHold

	barraFundo.Visible = false
	barra.Size =
		UDim2.new(0, 0, 1, 0)

	if tempo < HOLD_TIME then
		status.Visible = false
		return
	end

	executarDash()
end

-- =========================
-- BOTÃO TOUCH / MOUSE
-- =========================

botao.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		task.spawn(iniciarCarregamento)
	end
end)

botao.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		finalizarCarregamento()
	end
end)

-- =========================
-- TECLA F
-- =========================

UserInputService.InputBegan:Connect(function(input, processado)
	if processado then return end

	if input.KeyCode == Enum.KeyCode.F then
		task.spawn(iniciarCarregamento)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.F then
		finalizarCarregamento()
	end
end)

-- =========================
-- SPAWN
-- =========================

local function prepararPersonagem(char)
	local hrp = char:WaitForChild(
		"HumanoidRootPart",
		5
	)

	if hrp then
		criarTrail(char)
	end
end

if player.Character then
	task.spawn(
		prepararPersonagem,
		player.Character
	)
end

player.CharacterAdded:Connect(
	prepararPersonagem
)

print("🔥 Fire Dash carregado!")
