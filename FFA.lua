-- Script para Roblox Mobile – Olympus ESP + Aimbot by ChatGPT
if game:GetService("CoreGui"):FindFirstChild("OLYMPUS_UI") then game:GetService("CoreGui"):FindFirstChild("OLYMPUS_UI"):Destroy() end

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Configurações
local ESP_COLOR = Color3.new(1, 1, 1)
local FOV_RADIUS = 100
local AIMBOT_ENABLED = true
local ESP_ENABLED = true

-- GUI
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.Name = "OLYMPUS_UI"
ScreenGui.ResetOnSpawn = false

-- Botão externo
local toggleButton = Instance.new("TextButton", ScreenGui)
toggleButton.Size = UDim2.new(0, 60, 0, 60)
toggleButton.Position = UDim2.new(0, 20, 0.5, -30)
toggleButton.Text = "≡"
toggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.TextScaled = true
toggleButton.ZIndex = 10
toggleButton.AutoButtonColor = false
toggleButton.BorderSizePixel = 0
toggleButton.Visible = true

-- Painel
local mainFrame = Instance.new("Frame", ScreenGui)
mainFrame.Size = UDim2.new(0, 250, 0, 320)
mainFrame.Position = UDim2.new(0, 90, 0.5, -160)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = true
mainFrame.Active = true
mainFrame.Draggable = true

-- Nome
local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "🥇OLYMPUS👑"
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.TextScaled = true
title.Font = Enum.Font.GothamBlack

-- Botões
local function createToggle(name, yPos, callback)
	local button = Instance.new("TextButton", mainFrame)
	button.Size = UDim2.new(0.9, 0, 0, 35)
	button.Position = UDim2.new(0.05, 0, 0, yPos)
	button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Text = name
	button.TextScaled = true
	button.BorderSizePixel = 0
	local state = true
	button.MouseButton1Click:Connect(function()
		state = not state
		button.Text = name .. ": " .. (state and "ON" or "OFF")
		callback(state)
	end)
	button.Text = name .. ": ON"
end

createToggle("Aimbot", 50, function(v) AIMBOT_ENABLED = v end)
createToggle("ESP", 90, function(v) ESP_ENABLED = v end)
createToggle("Mostrar FOV", 130, function(v) fovCircle.Visible = v end)

-- FOV Desenho
local fovCircle = Drawing.new("Circle")
fovCircle.Color = Color3.new(1, 1, 1)
fovCircle.Thickness = 1
fovCircle.Transparency = 0.5
fovCircle.Radius = FOV_RADIUS
fovCircle.Filled = false
fovCircle.Visible = true

-- Toggle Minimizar
local minimized = false
toggleButton.MouseButton1Click:Connect(function()
	minimized = not minimized
	mainFrame.Visible = not minimized
end)

-- ESP e Aimbot Funções
local function getClosest()
	local closest = nil
	local shortest = math.huge
	for _, v in pairs(Players:GetPlayers()) do
		if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") then
			if v.Character.Humanoid.Health > 0 then
				local pos, onScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
				if onScreen then
					local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
					if dist < shortest and dist <= FOV_RADIUS then
						closest = v
						shortest = dist
					end
				end
			end
		end
	end
	return closest
end

-- ESP Drawing
local espCache = {}

RunService.RenderStepped:Connect(function()
	fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

	-- ESP
	for _, v in pairs(Players:GetPlayers()) do
		if v ~= LocalPlayer then
			local char = v.Character
			if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
				local hrp = char.HumanoidRootPart
				local head = char:FindFirstChild("Head")
				local hp = char.Humanoid.Health
				local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

				if ESP_ENABLED and onScreen and hp > 0 then
					if not espCache[v] then
						espCache[v] = {
							box = Drawing.new("Square"),
							text = Drawing.new("Text")
						}
					end
					local box = espCache[v].box
					local text = espCache[v].text

					box.Size = Vector2.new(50, 100)
					box.Position = Vector2.new(pos.X - 25, pos.Y - 50)
					box.Color = ESP_COLOR
					box.Visible = true
					box.Thickness = 2
					box.Filled = false

					text.Position = Vector2.new(pos.X - 30, pos.Y - 60)
					text.Text = "HP: " .. math.floor(hp)
					text.Size = 16
					text.Color = Color3.new(1, 1, 1)
					text.Visible = true
				elseif espCache[v] then
					espCache[v].box.Visible = false
					espCache[v].text.Visible = false
				end
			elseif espCache[v] then
				espCache[v].box.Visible = false
				espCache[v].text.Visible = false
			end
		end
	end

	-- Aimbot
	if AIMBOT_ENABLED then
		local target = getClosest()
		if target and target.Character and target.Character:FindFirstChild("Head") then
			local head = target.Character.Head
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
		end
	end
end)
