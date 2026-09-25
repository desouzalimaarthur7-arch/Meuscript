local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--==================================================
-- GUI
--==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "DZIN7"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local rgbObjects = {}

local function addRGB(obj)
	table.insert(rgbObjects, obj)
end

RunService.RenderStepped:Connect(function()
	local c = Color3.fromHSV((tick() % 5) / 5, .9, 1)

	for i = #rgbObjects, 1, -1 do
		local obj = rgbObjects[i]

		if obj and obj.Parent then
			obj.Color = c
		else
			table.remove(rgbObjects, i)
		end
	end
end)

--==================================================
-- BOTÃO FLUTUANTE
--==================================================

local floating = Instance.new("TextButton")
floating.Size = UDim2.fromOffset(62,62)
floating.Position = UDim2.new(0,25,.5,-31)
floating.BackgroundColor3 = Color3.fromRGB(12,12,17)
floating.Text = "D7"
floating.TextColor3 = Color3.new(1,1,1)
floating.TextSize = 20
floating.Font = Enum.Font.GothamBold
floating.AutoButtonColor = false
floating.ZIndex = 100
floating.Parent = gui

local fcorner = Instance.new("UICorner")
fcorner.CornerRadius = UDim.new(1,0)
fcorner.Parent = floating

local fstroke = Instance.new("UIStroke")
fstroke.Thickness = 3
fstroke.Parent = floating
addRGB(fstroke)

--==================================================
-- PAINEL
--==================================================

local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(460,560)
panel.Position = UDim2.new(.5,-230,.5,-280)
panel.BackgroundColor3 = Color3.fromRGB(10,10,15)
panel.Visible = false
panel.Parent = gui

local pcorner = Instance.new("UICorner")
pcorner.CornerRadius = UDim.new(0,22)
pcorner.Parent = panel

local pstroke = Instance.new("UIStroke")
pstroke.Thickness = 2
pstroke.Parent = panel
addRGB(pstroke)

--==================================================
-- CABEÇALHO
--==================================================

local header = Instance.new("Frame")
header.Size = UDim2.new(1,-24,0,90)
header.Position = UDim2.fromOffset(12,12)
header.BackgroundColor3 = Color3.fromRGB(24,24,31)
header.Parent = panel

local hcorner = Instance.new("UICorner")
hcorner.CornerRadius = UDim.new(0,16)
hcorner.Parent = header

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(18,7)
title.Size = UDim2.new(1,-36,0,35)
title.Text = "DZIN7"
title.TextColor3 = Color3.new(1,1,1)
title.TextSize = 27
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local gameTitle = Instance.new("TextLabel")
gameTitle.BackgroundTransparency = 1
gameTitle.Position = UDim2.fromOffset(19,42)
gameTitle.Size = UDim2.new(1,-38,0,20)
gameTitle.Text = "ROUBE UM OVO"
gameTitle.TextColor3 = Color3.fromRGB(150,150,165)
gameTitle.TextSize = 13
gameTitle.Font = Enum.Font.GothamMedium
gameTitle.TextXAlignment = Enum.TextXAlignment.Left
gameTitle.Parent = header

local status = Instance.new("TextLabel")
status.BackgroundTransparency = 1
status.Position = UDim2.fromOffset(19,64)
status.Size = UDim2.new(1,-38,0,18)
status.Text = "Procurando ovos..."
status.TextColor3 = Color3.fromRGB(100,255,150)
status.TextSize = 11
status.Font = Enum.Font.Gotham
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = header

--==================================================
-- LISTA
--==================================================

local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1,-24,1,-185)
list.Position = UDim2.fromOffset(12,110)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 3
list.CanvasSize = UDim2.new()
list.Parent = panel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0,8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = list

--==================================================
-- FUNÇÕES PARA LER DADOS
--==================================================

local function texto(v)
	if v == nil then
		return nil
	end

	if typeof(v) == "string"
	or typeof(v) == "number" then
		return tostring(v)
	end

	return nil
end

local function procurarCampo(tbl, nomes)
	if type(tbl) ~= "table" then
		return nil
	end

	for _, nome in ipairs(nomes) do
		for chave, valor in pairs(tbl) do
			if string.lower(tostring(chave)) == string.lower(nome) then
				local t = texto(valor)

				if t then
					return t
				end
			end
		end
	end

	return nil
end

local function encontrarModulo()
	local atual = ReplicatedStorage

	local caminhos = {
		{"Client","EggState"},
		{"Shared","Modules","EggState"},
		{"Shared","EggState"},
		{"EggState"}
	}

	for _, caminho in ipairs(caminhos) do
		local obj = atual

		for _, nome in ipairs(caminho) do
			obj = obj:FindFirstChild(nome)

			if not obj then
				break
			end
		end

		if obj and obj:IsA("ModuleScript") then
			return obj
		end
	end

	return nil
end

local function lerEggState()
	local module = encontrarModulo()

	if not module then
		return nil
	end

	local ok, result = pcall(function()
		local m = require(module)

		if type(m.ReadFieldEggs) == "function" then
			return m.ReadFieldEggs()
		end

		return m
	end)

	if ok then
		return result
	end

	return nil
end

--==================================================
-- PROCURAR MODELOS NA WORKSPACE
--==================================================

local function nomePareceOvo(nome)
	nome = string.lower(nome)

	return string.find(nome,"egg")
		or string.find(nome,"ovo")
		or string.find(nome,"pet")
end

local function coletarWorkspace()

	local encontrados = {}

	for _, obj in ipairs(workspace:GetDescendants()) do

		if (obj:IsA("Model") or obj:IsA("BasePart"))
		and nomePareceOvo(obj.Name) then

			local pos

			if obj:IsA("Model") then
				local ok, cf = pcall(function()
					return obj:GetPivot()
				end)

				if ok then
					pos = cf.Position
				end
			else
				pos = obj.Position
			end

			if pos then
				table.insert(encontrados,{
					nome = obj.Name,
					pos = pos,
					raridade = "Unknown",
					valor = "?",
					multiplicador = "?"
				})
			end
		end
	end

	return encontrados
end

--==================================================
-- CONVERTER EGGSTATE
--==================================================

local function converterTabela(data)

	local encontrados = {}

	if type(data) ~= "table" then
		return encontrados
	end

	for chave, valor in pairs(data) do

		if type(valor) == "table" then

			local nome =
				procurarCampo(valor,{
					"DisplayName",
					"displayName",
					"Name",
					"name",
					"PetName",
					"EggName",
					"petName"
				})

			local raridade =
				procurarCampo(valor,{
					"Rarity",
					"rarity",
					"Tier"
				})

			local valorMoney =
				procurarCampo(valor,{
					"Income",
					"IncomePerSecond",
					"Money",
					"Value",
					"Earnings"
				})

			local mult =
				procurarCampo(valor,{
					"Multiplier",
					"multiplier",
					"Mutation"
				})

			if nome then

				table.insert(encontrados,{
					nome = nome,
					raridade = raridade or "Unknown",
					valor = valorMoney or "?",
					multiplicador = mult or "1x"
				})
			end
		end
	end

	return encontrados
end

--==================================================
-- CRIAR ITEM
--==================================================

local function criarItem(dados, ordem)

	local item = Instance.new("Frame")
	item.Size = UDim2.new(1,-6,0,76)
	item.BackgroundColor3 = Color3.fromRGB(27,27,34)
	item.LayoutOrder = ordem
	item.Parent = list

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0,14)
	corner.Parent = item

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(42,42,52)
	stroke.Thickness = 1
	stroke.Parent = item

	-- ÍCONE
	local iconBox = Instance.new("Frame")
	iconBox.Size = UDim2.fromOffset(58,58)
	iconBox.Position = UDim2.fromOffset(9,9)
	iconBox.BackgroundColor3 = Color3.fromRGB(13,13,18)
	iconBox.Parent = item

	local iconCorner = Instance.new("UICorner")
	iconCorner.CornerRadius = UDim.new(0,12)
	iconCorner.Parent = iconBox

	local icon = Instance.new("TextLabel")
	icon.Size = UDim2.fromScale(1,1)
	icon.BackgroundTransparency = 1
	icon.Text = "🥚"
	icon.TextSize = 28
	icon.Parent = iconBox

	-- NOME
	local name = Instance.new("TextLabel")
	name.BackgroundTransparency = 1
	name.Position = UDim2.fromOffset(77,8)
	name.Size = UDim2.new(1,-250,0,27)
	name.Text = tostring(dados.nome)
	name.TextColor3 = Color3.fromRGB(240,240,245)
	name.TextSize = 16
	name.Font = Enum.Font.GothamMedium
	name.TextXAlignment = Enum.TextXAlignment.Left
	name.TextTruncate = Enum.TextTruncate.AtEnd
	name.Parent = item

	-- RARIDADE
	local rarity = Instance.new("TextLabel")
	rarity.BackgroundTransparency = 1
	rarity.Position = UDim2.fromOffset(77,39)
	rarity.Size = UDim2.new(1,-250,0,20)
	rarity.Text = tostring(dados.raridade)
	rarity.TextColor3 = Color3.fromRGB(145,85,255)
	rarity.TextSize = 12
	rarity.Font = Enum.Font.Gotham
	rarity.TextXAlignment = Enum.TextXAlignment.Left
	rarity.Parent = item

	-- MULTIPLICADOR
	local mult = Instance.new("TextLabel")
	mult.BackgroundTransparency = 1
	mult.Position = UDim2.new(1,-150,0,12)
	mult.Size = UDim2.fromOffset(60,20)
	mult.Text = tostring(dados.multiplicador)
	mult.TextColor3 = Color3.fromRGB(90,165,255)
	mult.TextSize = 12
	mult.Font = Enum.Font.GothamMedium
	mult.Parent = item

	-- VALOR
	local money = Instance.new("TextLabel")
	money.BackgroundTransparency = 1
	money.Position = UDim2.new(1,-88,0,12)
	money.Size = UDim2.fromOffset(78,20)
	money.Text = tostring(dados.valor)
	money.TextColor3 = Color3.fromRGB(100,255,150)
	money.TextSize = 12
	money.Font = Enum.Font.GothamMedium
	money.TextXAlignment = Enum.TextXAlignment.Right
	money.Parent = item

	return item
end

--==================================================
-- ATUALIZAR LISTA
--==================================================

local ultimoResultado = ""

local function atualizar()

	local dados = lerEggState()
	local encontrados = {}

	if dados then
		encontrados = converterTabela(dados)
	end

	-- fallback
	if #encontrados == 0 then
		encontrados = coletarWorkspace()
	end

	local assinatura = ""

	for _, d in ipairs(encontrados) do
		assinatura = assinatura
			.. tostring(d.nome)
			.. tostring(d.raridade)
			.. tostring(d.valor)
	end

	if assinatura == ultimoResultado then
		return
	end

	ultimoResultado = assinatura

	for _, child in ipairs(list:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	for i, dadosItem in ipairs(encontrados) do
		criarItem(dadosItem,i)
	end

	task.wait()

	list.CanvasSize = UDim2.new(
		0,
		0,
		0,
		layout.AbsoluteContentSize.Y + 10
	)

	status.Text =
		#encontrados > 0
		and (#encontrados .. " encontrados na esteira")
		or "Nenhum ovo encontrado"
end

--==================================================
-- ATUALIZAÇÃO AUTOMÁTICA
--==================================================

task.spawn(function()

	while gui.Parent do

		pcall(atualizar)

		task.wait(1)
	end
end)

--==================================================
-- GO / STOP
--==================================================

local go = Instance.new("TextButton")
go.Size = UDim2.new(.5,-17,0,58)
go.Position = UDim2.new(0,12,1,-70)
go.BackgroundColor3 = Color3.fromRGB(255,45,55)
go.Text = "GO"
go.TextColor3 = Color3.new(1,1,1)
go.TextSize = 18
go.Font = Enum.Font.GothamBold
go.Parent = panel

local gc = Instance.new("UICorner")
gc.CornerRadius = UDim.new(0,15)
gc.Parent = go

local stop = Instance.new("TextButton")
stop.Size = UDim2.new(.5,-17,0,58)
stop.Position = UDim2.new(.5,5,1,-70)
stop.BackgroundColor3 = Color3.fromRGB(28,28,35)
stop.Text = "STOP"
stop.TextColor3 = Color3.fromRGB(255,100,110)
stop.TextSize = 18
stop.Font = Enum.Font.GothamBold
stop.Parent = panel

local sc = Instance.new("UICorner")
sc.CornerRadius = UDim.new(0,15)
sc.Parent = stop

local ativo = false

go.Activated:Connect(function()
	ativo = true
	go.Text = "ATIVO"
	go.BackgroundColor3 = Color3.fromRGB(35,190,95)
end)

stop.Activated:Connect(function()
	ativo = false
	go.Text = "GO"
	go.BackgroundColor3 = Color3.fromRGB(255,45,55)
end)

--==================================================
-- ARRASTAR BOTÃO
--==================================================

local dragging = false
local moved = false
local dragStart
local startPosition

floating.InputBegan:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then

		dragging = true
		moved = false
		dragStart = input.Position
		startPosition = floating.Position
	end
end)

UIS.InputChanged:Connect(function(input)

	if not dragging then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseMovement
	or input.UserInputType == Enum.UserInputType.Touch then

		local delta = input.Position - dragStart

		if math.abs(delta.X) > 7
		or math.abs(delta.Y) > 7 then
			moved = true
		end

		floating.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end
end)

UIS.InputEnded:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then

		if dragging then

			dragging = false

			if not moved then
				panel.Visible = not panel.Visible
			end
		end
	end
end)
