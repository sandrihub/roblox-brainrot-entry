local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("NonsenseRemotes")
local actionRemote = remotes:WaitForChild("Action")
local notifyRemote = remotes:WaitForChild("Notify")

local CATALOG = {
	{ id = "capybara", name = "Moss Boss Capybara", rarity = "COMMON", cost = 45, income = 4, color = Color3.fromRGB(131, 147, 108) },
	{ id = "goblin", name = "Espresso Goblino", rarity = "UNCOMMON", cost = 180, income = 15, color = Color3.fromRGB(82, 155, 106) },
	{ id = "pigeon", name = "Rizzler Pigeon", rarity = "RARE", cost = 700, income = 58, color = Color3.fromRGB(73, 122, 197) },
	{ id = "llama", name = "Tax Evader Llama", rarity = "EPIC", cost = 3200, income = 280, color = Color3.fromRGB(151, 92, 192) },
	{ id = "axolotl", name = "Microwave Axolotl", rarity = "LEGENDARY", cost = 15000, income = 1550, color = Color3.fromRGB(216, 112, 148) },
	{ id = "cheese", name = "CEO of Cheese", rarity = "MYTHIC", cost = 72000, income = 9400, color = Color3.fromRGB(218, 157, 41) },
	{ id = "frog", name = "Quantum Froggo", rarity = "CELESTIAL", cost = 350000, income = 64000, color = Color3.fromRGB(80, 175, 147) },
}

local palette = {
	ink = Color3.fromRGB(29, 25, 49),
	panel = Color3.fromRGB(40, 35, 65),
	panelLight = Color3.fromRGB(55, 49, 84),
	cream = Color3.fromRGB(255, 250, 239),
	muted = Color3.fromRGB(183, 176, 208),
	mint = Color3.fromRGB(95, 231, 211),
	gold = Color3.fromRGB(255, 208, 112),
	pink = Color3.fromRGB(255, 112, 172),
	purple = Color3.fromRGB(173, 132, 255),
}

local function round(instance, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 14)
	corner.Parent = instance
end

local function stroke(instance, color, thickness, transparency)
	local outline = Instance.new("UIStroke")
	outline.Color = color
	outline.Thickness = thickness or 1.5
	outline.Transparency = transparency or 0
	outline.Parent = instance
	return outline
end

local function label(parent, text, size, position, font, color, textSize, alignment)
	local item = Instance.new("TextLabel")
	item.BackgroundTransparency = 1
	item.Size = size
	item.Position = position
	item.Text = text
	item.TextColor3 = color or palette.cream
	item.Font = font or Enum.Font.GothamBold
	item.TextSize = textSize or 15
	item.TextXAlignment = alignment or Enum.TextXAlignment.Left
	item.TextWrapped = true
	item.Parent = parent
	return item
end

local function button(parent, text, size, position, color)
	local item = Instance.new("TextButton")
	item.Size = size
	item.Position = position
	item.BackgroundColor3 = color or palette.mint
	item.Text = text
	item.TextColor3 = palette.ink
	item.Font = Enum.Font.GothamBlack
	item.TextSize = 14
	item.TextWrapped = true
	item.AutoButtonColor = true
	item.Parent = parent
	round(item, 12)
	stroke(item, Color3.fromRGB(255, 255, 255), 1, 0.72)
	return item
end

local function shortNumber(number)
	if number >= 1000000000 then
		return string.format("%.1fB", number / 1000000000)
	elseif number >= 1000000 then
		return string.format("%.1fM", number / 1000000)
	elseif number >= 1000 then
		return string.format("%.1fK", number / 1000)
	end
	return tostring(math.floor(number))
end

local gui = Instance.new("ScreenGui")
gui.Name = "NeonNonsenseHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 20
gui.Parent = player:WaitForChild("PlayerGui")

local scale = Instance.new("UIScale")
scale.Parent = gui
local dashboard
local shop
local hazardHint

local function updateScale()
	local camera = Workspace.CurrentCamera
	if camera then
		local viewport = camera.ViewportSize
		scale.Scale = math.clamp(math.min(viewport.X / 1180, viewport.Y / 760), 0.62, 1)
		if viewport.X < 800 then
			if dashboard then
				dashboard.Position = UDim2.new(0, 22, 0, 96)
			end
			if shop then
				shop.Position = UDim2.new(1, -386, 1, -520)
			end
			if hazardHint then
				hazardHint.Visible = false
			end
		else
			if dashboard then
				dashboard.Position = UDim2.new(0, 22, 0.5, -105)
			end
			if shop then
				shop.Position = UDim2.new(1, -386, 0.5, -210)
			end
			if hazardHint then
				hazardHint.Visible = true
			end
		end
	end
end

updateScale()
if Workspace.CurrentCamera then
	Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
end
Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(updateScale)

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.fromOffset(490, 66)
header.Position = UDim2.new(0.5, -245, 0, 20)
header.BackgroundColor3 = palette.ink
header.BackgroundTransparency = 0.05
header.Parent = gui
round(header, 20)
stroke(header, palette.purple, 2, 0.16)

local headerGradient = Instance.new("UIGradient")
headerGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(58, 43, 92)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(36, 49, 81)),
})
headerGradient.Rotation = 0
headerGradient.Parent = header

label(header, "NEON NONSENSE", UDim2.new(1, -30, 0, 34), UDim2.fromOffset(18, 8), Enum.Font.GothamBlack, palette.cream, 25, Enum.TextXAlignment.Center)
label(header, "COLLECT THE ODD. BUILD THE BIG.", UDim2.new(1, -30, 0, 18), UDim2.fromOffset(18, 42), Enum.Font.GothamBold, palette.mint, 11, Enum.TextXAlignment.Center)

dashboard = Instance.new("Frame")
dashboard.Name = "Wallet"
dashboard.Size = UDim2.fromOffset(285, 230)
dashboard.Position = UDim2.new(0, 22, 0.5, -105)
dashboard.BackgroundColor3 = palette.panel
dashboard.Parent = gui
round(dashboard, 20)
stroke(dashboard, palette.mint, 2, 0.15)

label(dashboard, "YOUR PLOT", UDim2.new(1, -32, 0, 22), UDim2.fromOffset(18, 14), Enum.Font.GothamBlack, palette.mint, 13)
local cashLabel = label(dashboard, "$175", UDim2.new(1, -32, 0, 48), UDim2.fromOffset(18, 38), Enum.Font.GothamBlack, palette.cream, 35)
local incomeLabel = label(dashboard, "+$0 / SEC", UDim2.new(1, -32, 0, 24), UDim2.fromOffset(18, 88), Enum.Font.GothamBold, palette.gold, 17)
local statsLabel = label(dashboard, "REBIRTHS 0     ODDITIES 0 / 5", UDim2.new(1, -32, 0, 20), UDim2.fromOffset(18, 118), Enum.Font.GothamBold, palette.muted, 12)

local rebirthButton = button(dashboard, "REBIRTH  ·  $50K", UDim2.new(1, -36, 0, 42), UDim2.fromOffset(18, 151), palette.gold)
local hintLabel = label(dashboard, "Collectibles earn cash automatically.", UDim2.new(1, -32, 0, 22), UDim2.fromOffset(18, 198), Enum.Font.GothamMedium, palette.muted, 11)
hintLabel.TextWrapped = false
rebirthButton.Activated:Connect(function()
	actionRemote:FireServer("Rebirth")
end)

shop = Instance.new("Frame")
shop.Name = "OddityShop"
shop.Size = UDim2.fromOffset(365, 470)
shop.Position = UDim2.new(1, -386, 0.5, -210)
shop.BackgroundColor3 = palette.panel
shop.Parent = gui
round(shop, 20)
stroke(shop, palette.purple, 2, 0.14)

label(shop, "ODDITY EXCHANGE", UDim2.new(1, -32, 0, 26), UDim2.fromOffset(18, 13), Enum.Font.GothamBlack, palette.cream, 19)
label(shop, "Choose a weirdo. Fill one of five display pads.", UDim2.new(1, -32, 0, 18), UDim2.fromOffset(18, 40), Enum.Font.GothamMedium, palette.muted, 11)

local list = Instance.new("ScrollingFrame")
list.Name = "CollectibleCatalog"
list.Size = UDim2.new(1, -24, 1, -78)
list.Position = UDim2.fromOffset(12, 66)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 4
list.ScrollBarImageColor3 = palette.mint
list.CanvasSize = UDim2.new(0, 0, 0, #CATALOG * 64)
list.Parent = shop

local cards = {}
for index, item in ipairs(CATALOG) do
	local row = Instance.new("Frame")
	row.Name = item.id
	row.Size = UDim2.new(1, -8, 0, 56)
	row.Position = UDim2.fromOffset(4, (index - 1) * 62)
	row.BackgroundColor3 = palette.panelLight
	row.Parent = list
	round(row, 12)

	local pip = Instance.new("Frame")
	pip.Size = UDim2.fromOffset(6, 38)
	pip.Position = UDim2.fromOffset(8, 9)
	pip.BackgroundColor3 = item.color
	pip.Parent = row
	round(pip, 4)

	label(row, item.name, UDim2.new(1, -132, 0, 22), UDim2.fromOffset(22, 6), Enum.Font.GothamBold, palette.cream, 12)
	label(row, item.rarity .. "  ·  +$" .. shortNumber(item.income) .. "/SEC", UDim2.new(1, -132, 0, 18), UDim2.fromOffset(22, 30), Enum.Font.GothamBold, item.color, 10)
	local buyButton = button(row, "$" .. shortNumber(item.cost), UDim2.fromOffset(94, 38), UDim2.new(1, -104, 0.5, -19), item.color)
	buyButton.TextSize = 13
	buyButton.Activated:Connect(function()
		actionRemote:FireServer("Buy", item.id)
	end)
	cards[item.id] = buyButton
end

local toast = Instance.new("TextLabel")
toast.Name = "Toast"
toast.Size = UDim2.fromOffset(420, 42)
toast.Position = UDim2.new(0.5, -210, 1, -78)
toast.BackgroundColor3 = palette.ink
toast.BackgroundTransparency = 1
toast.TextTransparency = 1
toast.TextColor3 = palette.cream
toast.Font = Enum.Font.GothamBold
toast.TextSize = 14
toast.TextWrapped = true
toast.Parent = gui
round(toast, 14)
stroke(toast, palette.gold, 1.5, 0.2)

local toastVersion = 0
local function showToast(message)
	toastVersion += 1
	local version = toastVersion
	toast.Text = message
	TweenService:Create(toast, TweenInfo.new(0.18), { BackgroundTransparency = 0.08, TextTransparency = 0 }):Play()
	task.delay(2.6, function()
		if toastVersion == version then
			TweenService:Create(toast, TweenInfo.new(0.25), { BackgroundTransparency = 1, TextTransparency = 1 }):Play()
		end
	end)
end

notifyRemote.OnClientEvent:Connect(showToast)

local function updateHud()
	local stats = player:FindFirstChild("leaderstats")
	if not stats then
		return
	end
	local cash = stats:FindFirstChild("Cash")
	local income = stats:FindFirstChild("Income")
	local rebirths = stats:FindFirstChild("Rebirths")
	local oddities = stats:FindFirstChild("Oddities")
	if not (cash and income and rebirths and oddities) then
		return
	end

	cashLabel.Text = "$" .. shortNumber(cash.Value)
	incomeLabel.Text = "+$" .. shortNumber(income.Value) .. " / SEC"
	statsLabel.Text = "REBIRTHS " .. rebirths.Value .. "     ODDITIES " .. oddities.Value .. " / 5"

	local rebirthCost = 50000 * (rebirths.Value + 1)
	if rebirths.Value >= 20 then
		rebirthButton.Text = "REBIRTH LIMIT REACHED"
		rebirthButton.BackgroundColor3 = palette.panelLight
	elseif cash.Value >= rebirthCost then
		rebirthButton.Text = "REBIRTH  ·  $" .. shortNumber(rebirthCost)
		rebirthButton.BackgroundColor3 = palette.gold
	else
		rebirthButton.Text = "NEXT REBIRTH  ·  $" .. shortNumber(rebirthCost)
		rebirthButton.BackgroundColor3 = Color3.fromRGB(112, 99, 80)
	end

	for _, item in ipairs(CATALOG) do
		local buyButton = cards[item.id]
		if oddities.Value >= 5 then
			buyButton.Text = "FULL"
			buyButton.BackgroundColor3 = Color3.fromRGB(104, 96, 118)
		elseif cash.Value >= item.cost then
			buyButton.Text = "$" .. shortNumber(item.cost)
			buyButton.BackgroundColor3 = item.color
		else
			buyButton.Text = "$" .. shortNumber(item.cost)
			buyButton.BackgroundColor3 = Color3.fromRGB(94, 87, 112)
		end
	end
end

local function bindStats()
	local stats = player:WaitForChild("leaderstats")
	for _, name in ipairs({ "Cash", "Income", "Rebirths", "Oddities" }) do
		local value = stats:WaitForChild(name)
		value:GetPropertyChangedSignal("Value"):Connect(updateHud)
	end
	updateHud()
end

task.spawn(bindStats)

hazardHint = label(gui, "MAGENTA GLOOP COSTS 20% OF YOUR CASH", UDim2.fromOffset(350, 20), UDim2.new(0.5, -175, 1, -32), Enum.Font.GothamBlack, palette.pink, 11, Enum.TextXAlignment.Center)
hazardHint.TextTransparency = 0.08
updateScale()
