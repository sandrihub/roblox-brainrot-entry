local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("NeonNonsense")
local stateEvent = remotes:WaitForChild("State")
local actionEvent = remotes:WaitForChild("Action")
local palette = {
	ink = Color3.fromRGB(15, 13, 30),
	panel = Color3.fromRGB(27, 23, 51),
	white = Color3.fromRGB(246, 242, 255),
	muted = Color3.fromRGB(180, 171, 206),
	cyan = Color3.fromRGB(0, 245, 255),
	pink = Color3.fromRGB(255, 54, 206),
	lime = Color3.fromRGB(173, 255, 47),
	gold = Color3.fromRGB(255, 193, 54),
}

local screen = Instance.new("ScreenGui")
screen.Name = "NeonNonsenseHUD"
screen.IgnoreGuiInset = true
screen.ResetOnSpawn = false
screen.DisplayOrder = 20
screen.Parent = player:WaitForChild("PlayerGui")

local function corner(instance, radius)
	local shape = Instance.new("UICorner")
	shape.CornerRadius = UDim.new(0, radius or 14)
	shape.Parent = instance
end

local function outline(instance, color, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = thickness or 1.5
	stroke.Transparency = 0.18
	stroke.Parent = instance
	return stroke
end

local function label(parent, text, size, font, color)
	local element = Instance.new("TextLabel")
	element.BackgroundTransparency = 1
	element.Size = size
	element.Font = font or Enum.Font.GothamBold
	element.Text = text
	element.TextColor3 = color or palette.white
	element.TextSize = 16
	element.TextWrapped = true
	element.TextXAlignment = Enum.TextXAlignment.Left
	element.Parent = parent
	return element
end

local function panel(parent, name, size, position, color)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.Size = size
	frame.Position = position
	frame.BackgroundColor3 = color or palette.panel
	frame.BackgroundTransparency = 0.08
	frame.Parent = parent
	corner(frame)
	outline(frame, palette.cyan, 1.4)
	return frame
end

local function makeButton(parent, text, color, position, callback)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, 0, 0, 48)
	button.Position = position
	button.BackgroundColor3 = Color3.fromRGB(38, 32, 68)
	button.AutoButtonColor = false
	button.Font = Enum.Font.GothamBlack
	button.Text = text
	button.TextColor3 = color
	button.TextSize = 15
	button.TextWrapped = true
	button.Parent = parent
	corner(button, 10)
	outline(button, color, 1.5)
	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(57, 43, 86) }):Play()
	end)
	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(38, 32, 68) }):Play()
	end)
	button.Activated:Connect(callback)
	return button
end

local header = panel(screen, "Header", UDim2.new(0, 378, 0, 80), UDim2.new(0, 22, 0, 20))
local title = label(header, "NEON NONSENSE", UDim2.new(1, -24, 0, 36), Enum.Font.GothamBlack, palette.cyan)
title.Position = UDim2.fromOffset(14, 9)
title.TextSize = 24
local tagline = label(header, "YOUR BRAINROT. YOUR EMPIRE.", UDim2.new(1, -24, 0, 21), Enum.Font.GothamBold, palette.muted)
tagline.Position = UDim2.fromOffset(16, 48)
tagline.TextSize = 12

local stats = panel(screen, "Stats", UDim2.new(0, 250, 0, 226), UDim2.new(0, 22, 0, 112))
local statsTitle = label(stats, "TYCOON TELEMETRY", UDim2.new(1, -24, 0, 25), Enum.Font.GothamBlack, palette.pink)
statsTitle.Position = UDim2.fromOffset(14, 12)
statsTitle.TextSize = 14
local cashLabel = label(stats, "$250", UDim2.new(1, -26, 0, 39), Enum.Font.GothamBlack, palette.gold)
cashLabel.Position = UDim2.fromOffset(14, 44)
cashLabel.TextSize = 28
local incomeLabel = label(stats, "$0 / sec", UDim2.new(1, -26, 0, 27), Enum.Font.GothamBold, palette.lime)
incomeLabel.Position = UDim2.fromOffset(14, 87)
incomeLabel.TextSize = 17
local collectionLabel = label(stats, "Brainrots  0 / 8", UDim2.new(1, -26, 0, 24), Enum.Font.GothamBold, palette.white)
collectionLabel.Position = UDim2.fromOffset(14, 126)
collectionLabel.TextSize = 14
local rebirthLabel = label(stats, "Rebirths  0   |   Multiplier x1.00", UDim2.new(1, -26, 0, 43), Enum.Font.GothamBold, palette.muted)
rebirthLabel.Position = UDim2.fromOffset(14, 163)
rebirthLabel.TextSize = 13

local shop = panel(screen, "Shop", UDim2.new(0, 250, 0, 204), UDim2.new(1, -272, 0, 22))
local shopTitle = label(shop, "ROTTEN INVESTMENTS", UDim2.new(1, -24, 0, 26), Enum.Font.GothamBlack, palette.cyan)
shopTitle.Position = UDim2.fromOffset(14, 10)
shopTitle.TextSize = 14
local incomeButton = makeButton(shop, "INCOME LAB   ·   $350", palette.lime, UDim2.fromOffset(12, 45), function()
	actionEvent:FireServer("upgrade", "income")
end)
local speedButton = makeButton(shop, "SPEED SHOP   ·   $250", palette.pink, UDim2.fromOffset(12, 103), function()
	actionEvent:FireServer("upgrade", "speed")
end)
local hint = label(shop, "Collect in the plaza. Hold E to swipe rivals.", UDim2.new(1, -26, 0, 32), Enum.Font.GothamMedium, palette.muted)
hint.Position = UDim2.fromOffset(14, 164)
hint.TextSize = 11

local rebirthPanel = panel(screen, "Rebirth", UDim2.new(0, 250, 0, 102), UDim2.new(1, -272, 0, 240))
local rebirthButton = makeButton(rebirthPanel, "REBIRTH   ·   $15,000", palette.gold, UDim2.fromOffset(12, 11), function()
	actionEvent:FireServer("rebirth")
end)
rebirthButton.Size = UDim2.new(1, -24, 0, 48)
local rebirthHint = label(rebirthPanel, "Reset your plot. Keep a permanent multiplier.", UDim2.new(1, -24, 0, 28), Enum.Font.GothamMedium, palette.muted)
rebirthHint.Position = UDim2.fromOffset(12, 66)
rebirthHint.TextSize = 10
rebirthHint.TextXAlignment = Enum.TextXAlignment.Center

local controls = panel(screen, "Controls", UDim2.new(0, 340, 0, 47), UDim2.new(0.5, -170, 1, -68), palette.ink)
controls.BackgroundTransparency = 0.12
local controlsText = label(controls, "WASD MOVE    ·    E COLLECT / SWIPE    ·    BUILD YOUR ROT", UDim2.new(1, -20, 1, -8), Enum.Font.GothamBold, palette.white)
controlsText.Position = UDim2.fromOffset(10, 4)
controlsText.TextSize = 11
controlsText.TextXAlignment = Enum.TextXAlignment.Center

local toast = Instance.new("TextLabel")
toast.Name = "Toast"
toast.AnchorPoint = Vector2.new(0.5, 0)
toast.Position = UDim2.new(0.5, 0, 0, 22)
toast.Size = UDim2.new(0, 490, 0, 54)
toast.BackgroundColor3 = palette.ink
toast.BackgroundTransparency = 1
toast.Font = Enum.Font.GothamBlack
toast.TextColor3 = palette.white
toast.TextSize = 17
toast.TextWrapped = true
toast.TextTransparency = 1
toast.Visible = false
toast.Parent = screen
corner(toast)
local toastStroke = outline(toast, palette.pink, 2)

local function money(amount)
	if amount >= 1000000 then
		return string.format("$%.1fM", amount / 1000000)
	elseif amount >= 1000 then
		return string.format("$%.1fK", amount / 1000)
	end
	return "$" .. tostring(amount)
end

stateEvent.OnClientEvent:Connect(function(kind, payload)
	if kind == "snapshot" then
		cashLabel.Text = money(payload.cash)
		incomeLabel.Text = money(payload.income) .. " / sec"
		collectionLabel.Text = "Brainrots  " .. payload.brainrots .. " / " .. payload.slots
		rebirthLabel.Text = "Rebirths  " .. payload.rebirths .. "   |   Multiplier x" .. string.format("%.2f", payload.multiplier)
		incomeButton.Text = "INCOME LAB   ·   " .. money(payload.incomePrice)
		speedButton.Text = "SPEED SHOP   ·   " .. money(payload.speedPrice)
		rebirthButton.Text = "REBIRTH   ·   " .. money(payload.rebirthPrice)
		if typeof(payload.plotColor) == "Color3" then
			outline(stats, payload.plotColor, 1.4)
		end
	elseif kind == "toast" then
		toast.Text = tostring(payload)
		toastStroke.Color = string.find(toast.Text, "STORM", 1, true) and palette.gold or palette.pink
		toast.Visible = true
		TweenService:Create(toast, TweenInfo.new(0.2), { BackgroundTransparency = 0.08, TextTransparency = 0 }):Play()
		task.delay(3.4, function()
			if toast.Parent then
				TweenService:Create(toast, TweenInfo.new(0.35), { BackgroundTransparency = 1, TextTransparency = 1 }):Play()
				task.delay(0.4, function()
					if toast.Parent then
						toast.Visible = false
					end
				end)
			end
		end)
	end
end)

actionEvent:FireServer("request")
