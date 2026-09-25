--// EGG / PET ESP - LOCAL SCRIPT
--// GUI + NOME + RARIDADE + $/S + DISTÂNCIA + ÍCONE
--// Atualização automática + ordenação por rendimento

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--==================================================
-- CONFIG
--==================================================

local UPDATE_TIME = 0.25
local MAX_DISTANCE = 1000
local ESP_ATIVO = true

--==================================================
-- TENTA ENCONTRAR MÓDULOS DO JOGO
--==================================================

local function procurar(parent, nome)
    local obj = parent:FindFirstChild(nome, true)
    return obj
end

local EggStateModule = procurar(ReplicatedStorage, "EggState")
local AssetsModule = procurar(ReplicatedStorage, "Assets")
local MutationsModule = procurar(ReplicatedStorage, "Mutations")
local EggRecordsModule = procurar(ReplicatedStorage, "EggRecords")

local EggState
local Assets
local Mutations
local EggRecords

pcall(function()
    if EggStateModule and EggStateModule:IsA("ModuleScript") then
        EggState = require(EggStateModule)
    end
end)

pcall(function()
    if AssetsModule and AssetsModule:IsA("ModuleScript") then
        Assets = require(AssetsModule)
    end
end)

pcall(function()
    if MutationsModule and MutationsModule:IsA("ModuleScript") then
        Mutations = require(MutationsModule)
    end
end)

pcall(function()
    if EggRecordsModule and EggRecordsModule:IsA("ModuleScript") then
        EggRecords = require(EggRecordsModule)
    end
end)

--==================================================
-- GUI PRINCIPAL
--==================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "EggPetESP"
Gui.ResetOnSpawn = false
Gui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 360, 0, 420)
Main.Position = UDim2.new(0.5, -180, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(18,18,22)
Main.BorderSizePixel = 0
Main.Parent = Gui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0,14)
Corner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(90,90,100)
Stroke.Thickness = 1
Stroke.Parent = Main

--==================================================
-- TÍTULO
--==================================================

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 45)
Title.Position = UDim2.new(0,10,0,5)
Title.BackgroundTransparency = 1
Title.Text = "🥚 EGG / PET ESP"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.Parent = Main

--==================================================
-- BOTÃO ESP
--==================================================

local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.new(1,-20,0,42)
Toggle.Position = UDim2.new(0,10,0,55)
Toggle.BackgroundColor3 = Color3.fromRGB(35,35,42)
Toggle.TextColor3 = Color3.fromRGB(80,255,120)
Toggle.Font = Enum.Font.GothamBold
Toggle.TextSize = 16
Toggle.Text = "ESP: ON"
Toggle.Parent = Main

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0,10)
ToggleCorner.Parent = Toggle

Toggle.MouseButton1Click:Connect(function()
    ESP_ATIVO = not ESP_ATIVO

    Toggle.Text = ESP_ATIVO and "ESP: ON" or "ESP: OFF"

    if not ESP_ATIVO then
        for _,v in pairs(Main.List:GetChildren()) do
            if v:IsA("Frame") then
                v:Destroy()
            end
        end
    end
end)

--==================================================
-- LISTA
--==================================================

local List = Instance.new("ScrollingFrame")
List.Name = "List"
List.Size = UDim2.new(1,-20,1,-110)
List.Position = UDim2.new(0,10,0,105)
List.BackgroundColor3 = Color3.fromRGB(12,12,15)
List.BorderSizePixel = 0
List.ScrollBarThickness = 5
List.CanvasSize = UDim2.new(0,0,0,0)
List.Parent = Main

local ListCorner = Instance.new("UICorner")
ListCorner.CornerRadius = UDim.new(0,10)
ListCorner.Parent = List

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0,6)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = List

--==================================================
-- CORES DAS RARIDADES
--==================================================

local RarityColors = {
    Common = Color3.fromRGB(190,190,190),
    Uncommon = Color3.fromRGB(80,220,100),
    Rare = Color3.fromRGB(70,150,255),
    Epic = Color3.fromRGB(180,80,255),
    Legendary = Color3.fromRGB(255,190,50),
    Mythic = Color3.fromRGB(255,70,70),
    Secret = Color3.fromRGB(255,70,200),
}

local function getRarityColor(rarity)
    return RarityColors[rarity] or Color3.fromRGB(255,255,255)
end

--==================================================
-- POSIÇÃO
--==================================================

local function getPosition(obj)
    if not obj then return nil end

    if obj:IsA("BasePart") then
        return obj.Position
    end

    if obj:IsA("Model") then
        local primary = obj.PrimaryPart

        if primary then
            return primary.Position
        end

        local part = obj:FindFirstChildWhichIsA(
            "BasePart",
            true
        )

        if part then
            return part.Position
        end
    end

    return nil
end

--==================================================
-- NOME
--==================================================

local function getDisplayName(obj)
    if not obj then
        return "Unknown"
    end

    local atributos = {
        "DisplayName",
        "Name",
        "EggName",
        "PetName",
    }

    for _,nome in ipairs(atributos) do
        local valor = obj:GetAttribute(nome)

        if valor ~= nil then
            return tostring(valor)
        end
    end

    return obj.Name
end

--==================================================
-- RARIDADE
--==================================================

local function getRarity(obj)
    if not obj then
        return "Common"
    end

    local nomes = {
        "Rarity",
        "Raridade",
        "Tier",
    }

    for _,nome in ipairs(nomes) do
        local valor = obj:GetAttribute(nome)

        if valor ~= nil then
            return tostring(valor)
        end
    end

    return "Common"
end

--==================================================
-- INCOME
--==================================================

local function getIncome(obj)
    if not obj then
        return 0
    end

    local nomes = {
        "Income",
        "IncomePerSecond",
        "Earnings",
        "MoneyPerSecond",
        "CashPerSecond",
    }

    for _,nome in ipairs(nomes) do
        local valor = obj:GetAttribute(nome)

        if typeof(valor) == "number" then
            return valor
        end
    end

    return 0
end

--==================================================
-- ÍCONE
--==================================================

local function getIcon(obj)
    if not obj then
        return nil
    end

    local nomes = {
        "Icon",
        "IconId",
        "Image",
        "ImageId",
    }

    for _,nome in ipairs(nomes) do
        local valor = obj:GetAttribute(nome)

        if valor then
            local texto = tostring(valor)

            if string.find(texto,"rbxassetid://") then
                return texto
            end

            if tonumber(texto) then
                return "rbxassetid://" .. texto
            end
        end
    end

    return nil
end

--==================================================
-- PROCURA OVOS / PETS
--==================================================

local function procurarOvos()
    local encontrados = {}

    -- Primeiro tenta EggState
    if EggState then
        pcall(function()
            if typeof(EggState.ReadFieldEggs) == "function" then
                local registros = EggState.ReadFieldEggs()

                if typeof(registros) == "table" then
                    for _,registro in pairs(registros) do
                        table.insert(encontrados,registro)
                    end
                end
            end
        end)
    end

    -- Fallback: procura objetos no Workspace
    if #encontrados == 0 then
        for _,obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") or obj:IsA("BasePart") then

                local nome = string.lower(obj.Name)

                if string.find(nome,"egg")
                    or string.find(nome,"ovo")
                    or string.find(nome,"pet") then

                    table.insert(encontrados,obj)
                end
            end
        end
    end

    return encontrados
end

--==================================================
-- CRIA LINHA
--==================================================

local function createRow(dados,index)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1,-10,0,70)
    Row.BackgroundColor3 = Color3.fromRGB(25,25,30)
    Row.BorderSizePixel = 0
    Row.LayoutOrder = index
    Row.Parent = List

    local RowCorner = Instance.new("UICorner")
    RowCorner.CornerRadius = UDim.new(0,8)
    RowCorner.Parent = Row

    -- Ícone
    local Icon = Instance.new("ImageLabel")
    Icon.Size = UDim2.new(0,55,0,55)
    Icon.Position = UDim2.new(0,7,0,7)
    Icon.BackgroundTransparency = 1

    if dados.Icon then
        Icon.Image = dados.Icon
    end

    Icon.Parent = Row

    -- Nome
    local Name = Instance.new("TextLabel")
    Name.Size = UDim2.new(1,-75,0,22)
    Name.Position = UDim2.new(0,70,0,5)
    Name.BackgroundTransparency = 1
    Name.TextXAlignment = Enum.TextXAlignment.Left
    Name.Text = dados.Name
    Name.TextColor3 = Color3.fromRGB(255,255,255)
    Name.Font = Enum.Font.GothamBold
    Name.TextSize = 15
    Name.Parent = Row

    -- Raridade
    local Rarity = Instance.new("TextLabel")
    Rarity.Size = UDim2.new(0.5,-35,0,18)
    Rarity.Position = UDim2.new(0,70,0,28)
    Rarity.BackgroundTransparency = 1
    Rarity.TextXAlignment = Enum.TextXAlignment.Left
    Rarity.Text = "⭐ "..dados.Rarity
    Rarity.TextColor3 = getRarityColor(dados.Rarity)
    Rarity.Font = Enum.Font.Gotham
    Rarity.TextSize = 12
    Rarity.Parent = Row

    -- Income
    local Income = Instance.new("TextLabel")
    Income.Size = UDim2.new(0.5,-35,0,18)
    Income.Position = UDim2.new(0,70,0,47)
    Income.BackgroundTransparency = 1
    Income.TextXAlignment = Enum.TextXAlignment.Left
    Income.Text = "💰 $"..tostring(dados.Income).."/s"
    Income.TextColor3 = Color3.fromRGB(80,255,120)
    Income.Font = Enum.Font.Gotham
    Income.TextSize = 12
    Income.Parent = Row

    -- Distância
    local Distance = Instance.new("TextLabel")
    Distance.Size = UDim2.new(0,90,0,20)
    Distance.Position = UDim2.new(1,-100,0,25)
    Distance.BackgroundTransparency = 1
    Distance.Text = string.format(
        "📏 %.0fm",
        dados.Distance
    )
    Distance.TextColor3 = Color3.fromRGB(200,200,200)
    Distance.Font = Enum.Font.Gotham
    Distance.TextSize = 12
    Distance.Parent = Row
end

--==================================================
-- ATUALIZA ESP
--==================================================

local function updateESP()
    if not ESP_ATIVO then
        return
    end

    for _,obj in ipairs(List:GetChildren()) do
        if obj:IsA("Frame") then
            obj:Destroy()
        end
    end

    local char = Player.Character
    local hrp = char and char:FindFirstChild(
        "HumanoidRootPart"
    )

    if not hrp then
        return
    end

    local objetos = procurarOvos()
    local dados = {}

    for _,obj in ipairs(objetos) do
        local pos = getPosition(obj)

        if pos then
            local distancia =
                (hrp.Position - pos).Magnitude

            if distancia <= MAX_DISTANCE then
                table.insert(dados,{
                    Object = obj,
                    Name = getDisplayName(obj),
                    Rarity = getRarity(obj),
                    Income = getIncome(obj),
                    Icon = getIcon(obj),
                    Distance = distancia
                })
            end
        end
    end

    -- Mais dinheiro primeiro
    table.sort(dados,function(a,b)
        return a.Income > b.Income
    end)

    for i,dado in ipairs(dados) do
        createRow(dado,i)
    end

    List.CanvasSize =
        UDim2.new(
            0,
            0,
            0,
            Layout.AbsoluteContentSize.Y + 10
        )
end

--==================================================
-- LOOP
--==================================================

task.spawn(function()
    while task.wait(UPDATE_TIME) do
        pcall(updateESP)
    end
end)

print("🥚 Egg/Pet ESP carregado!")
