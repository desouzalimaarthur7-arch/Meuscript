local Players = game:GetService("Players")
local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "Speed40X"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 200, 0, 60)
button.Position = UDim2.new(0.5, -100, 0.5, -30)
button.Text = "SPEED 40X: OFF"
button.TextScaled = true
button.Parent = gui

local enabled = false

button.MouseButton1Click:Connect(function()
    enabled = not enabled

    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")

    humanoid.WalkSpeed = enabled and 640 or 16
    button.Text = enabled and "SPEED 40X: ON" or "SPEED 40X: OFF"
end)
