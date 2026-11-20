local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("NonsenseRemotes")
local actionRemote = remotes:WaitForChild("Action")
local stateRemote = remotes:WaitForChild("State")

local palette = {
	ink = Color3.fromRGB(28, 29, 52),
	panel = Color3.fromRGB(242, 240, 250),
	cream = Color3.fromRGB(255, 253, 248),
	muted = Color3.fromRGB(111, 111, 138),
	cyan = Color3.fromRGB(71, 197, 197),
	gold = Color3.fromRGB(245, 188, 76),
	pink = Color3.fromRGB(221, 100, 147),
	purple = Color3.fromRGB(125, 107, 199),
	green = Color3.fromRGB(65, 165, 117),
}

local rarityColors = {
	COMMON = Color3.fromRGB(109, 124, 134),
	UNCOMMON = Color3.fromRGB(63, 154, 98),
	RARE = Color3.fromRGB(68, 126, 202),
	EPIC = Color3.fromRGB(150, 88, 192),
	LEGENDARY = Color3.fromRGB(221, 139, 43),
	MYTHIC = Color3.fromRGB(208, 77, 116),
	CELESTIAL = Color3.fromRGB(93, 159, 211),
}

local function corner(instance, radius)
	local ui = Instance.new("UICorner")
	ui.CornerRadius = UDim.new(0, radius or 12)
	ui.Parent = instance
end

local function outline(instance, color, thickness, transparency)
	local ui = Instance.new("UIStroke")
	ui.Color = color or palette.ink
	ui.Thickness = thickness or 2
	ui.Transparency = transparency or 0
	ui.Parent = instance
end

local function textLabel(parent, text, size, position, font, color, textSize)
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = size
	label.Position = position
	label.Text = text
	label.TextColor3 = color or palette.ink
	label.Font = font or Enum.Font.GothamBold
	label.TextSize = textSize or 15
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextWrapped = true
	label.Parent = parent
	return label
end

local function makeButton(parent, text, size, position, color)
	local button = Instance.new("TextButton")
	button.Size = size
	button.Position = position
	button.BackgroundColor3 = color or palette.cyan
	button.Text = text
	button.TextColor3 = palette.cream
	button.Font = Enum.Font.GothamBlack
	button.TextSize = 14
	button.TextWrapped = true
	button.AutoButtonColor = true
	button.Parent = parent
	corner(button, 12)
	outline(button, Color3.fromRGB(37, 39, 67), 1.5, 0.1)
	return button
end

local gui = Instance.new("ScreenGui")
gui.Name = "NeonNonsenseHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 20

local uiScale = Instance.new("UIScale")
uiScale.Parent = gui

local function updateScale()
	local camera = Workspace.CurrentCamera
	if camera then
		local viewport = camera.ViewportSize
		uiScale.Scale = math.clamp(math.min(viewport.X / 1120, viewport.Y / 760), 0.68, 1)
	end
end

updateScale()
if Workspace.CurrentCamera then
	Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
end
Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(updateScale)

local panel = Instance.new("Frame")
panel.Name = "TycoonPanel"
panel.AnchorPoint = Vector2.new(0, 0.5)
panel.Position = UDim2.new(0, 18, 0.5, 0)
panel.Size = UDim2.new(0, 366, 0.9, 0)
panel.BackgroundColor3 = palette.panel
panel.Parent = gui
corner(panel, 22)
outline(panel, palette.ink, 3)

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 96)
header.BackgroundColor3 = palette.ink
header.Parent = panel
corner(header, 20)
local headerGradient = Instance.new("UIGradient")
headerGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(52, 48, 96)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 124, 136)),
})
headerGradient.Rotation = 18
headerGradient.Parent = header

local title = textLabel(header, "NEON\nNONSENSE", UDim2.new(0.65, 0, 0, 66), UDim2.new(0, 16, 0, 9), Enum.Font.GothamBlack, palette.cream, 25)
title.TextYAlignment = Enum.TextYAlignment.Center
local titleTag = textLabel(header, "ODDITY TYCOON", UDim2.new(0.65, 0, 0, 17), UDim2.new(0, 17, 0, 74), Enum.Font.GothamBold, Color3.fromRGB(156, 239, 230), 10)
local plotTag = textLabel(header, "PLOT --", UDim2.new(0.32, -8, 0, 42), UDim2.new(0.66, 0, 0, 26), Enum.Font.GothamBlack, Color3.fromRGB(255, 222, 130), 16)
plotTag.TextXAlignment = Enum.TextXAlignment.Right

local stats = Instance.new("Frame")
stats.Name = "Stats"
stats.BackgroundTransparency = 1
stats.Position = UDim2.new(0, 14, 0, 105)
stats.Size = UDim2.new(1, -28, 0, 62)
stats.Parent = panel

local cashCard = Instance.new("Frame")
cashCard.Size = UDim2.new(0.53, -4, 1, 0)
cashCard.BackgroundColor3 = palette.cream
cashCard.Parent = stats
corner(cashCard, 13)

local cashCaption = textLabel(cashCard, "WALLET", UDim2.new(1, -18, 0, 16), UDim2.new(0, 10, 0, 6), Enum.Font.GothamBlack, palette.muted, 10)
local cashLabel = textLabel(cashCard, "$0", UDim2.new(1, -18, 0, 33), UDim2.new(0, 10, 0, 23), Enum.Font.GothamBlack, palette.green, 22)

local incomeCard = Instance.new("Frame")
incomeCard.Position = UDim2.new(0.53, 4, 0, 0)
incomeCard.Size = UDim2.new(0.47, -4, 1, 0)
incomeCard.BackgroundColor3 = Color3.fromRGB(225, 246, 240)
incomeCard.Parent = stats
corner(incomeCard, 13)

local incomeCaption = textLabel(incomeCard, "PASSIVE FLOW", UDim2.new(1, -16, 0, 16), UDim2.new(0, 9, 0, 6), Enum.Font.GothamBlack, palette.muted, 10)
local incomeLabel = textLabel(incomeCard, "+$0 / SEC", UDim2.new(1, -16, 0, 33), UDim2.new(0, 9, 0, 23), Enum.Font.GothamBlack, palette.ink, 16)

local collectButton = makeButton(panel, "COLLECT ALL  •  $0", UDim2.new(1, -28, 0, 47), UDim2.new(0, 14, 0, 176), palette.green)
collectButton.TextSize = 16

local statusCard = Instance.new("Frame")
statusCard.Name = "Status"
statusCard.Position = UDim2.new(0, 14, 0, 231)
statusCard.Size = UDim2.new(1, -28, 0, 55)
statusCard.BackgroundColor3 = Color3.fromRGB(231, 231, 245)
statusCard.Parent = panel
corner(statusCard, 12)
local statusLabel = textLabel(statusCard, "Your oddities are earning. Protect your vault.", UDim2.new(1, -20, 1, -10), UDim2.new(0, 10, 0, 5), Enum.Font.GothamBold, palette.ink, 12)
statusLabel.TextYAlignment = Enum.TextYAlignment.Center

local shopTitle = textLabel(panel, "ODDITY EXCHANGE  /  RARITY LADDER", UDim2.new(1, -28, 0, 24), UDim2.new(0, 16, 0, 296), Enum.Font.GothamBlack, palette.ink, 12)

local shop = Instance.new("ScrollingFrame")
shop.Name = "RarityShop"
shop.Position = UDim2.new(0, 14, 0, 324)
shop.Size = UDim2.new(1, -28, 1, -453)
shop.BackgroundColor3 = palette.cream
shop.BorderSizePixel = 0
shop.ScrollBarThickness = 5
shop.ScrollBarImageColor3 = palette.purple
shop.AutomaticCanvasSize = Enum.AutomaticSize.Y
shop.CanvasSize = UDim2.new()
shop.Parent = panel
corner(shop, 14)

local shopLayout = Instance.new("UIListLayout")
shopLayout.Padding = UDim.new(0, 7)
shopLayout.SortOrder = Enum.SortOrder.LayoutOrder
shopLayout.Parent = shop

local shopPadding = Instance.new("UIPadding")
shopPadding.PaddingTop = UDim.new(0, 8)
shopPadding.PaddingBottom = UDim.new(0, 8)
shopPadding.PaddingLeft = UDim.new(0, 8)
shopPadding.PaddingRight = UDim.new(0, 8)
shopPadding.Parent = shop

local actions = Instance.new("Frame")
actions.Name = "TycoonActions"
actions.BackgroundTransparency = 1
actions.Position = UDim2.new(0, 14, 1, -116)
actions.Size = UDim2.new(1, -28, 0, 50)
actions.Parent = panel

local shieldButton = makeButton(actions, "LOCK VAULT", UDim2.new(0.333, -7, 1, 0), UDim2.new(0, 0, 0, 0), Color3.fromRGB(55, 159, 183))
local upgradeButton = makeButton(actions, "UPGRADE", UDim2.new(0.333, -7, 1, 0), UDim2.new(0.333, 4, 0, 0), palette.purple)
local rebirthButton = makeButton(actions, "REBIRTH", UDim2.new(0.333, -7, 1, 0), UDim2.new(0.666, 8, 0, 0), palette.pink)
shieldButton.TextSize = 11
upgradeButton.TextSize = 11
rebirthButton.TextSize = 11

local footer = textLabel(panel, "E COLLECTS OR SWIPES  •  LEAVE RIVALS ONE ODDITY", UDim2.new(1, -28, 0, 20), UDim2.new(0, 16, 1, -57), Enum.Font.GothamBold, palette.muted, 9)
footer.TextXAlignment = Enum.TextXAlignment.Center

local toast = Instance.new("TextLabel")
toast.Name = "FeedbackToast"
toast.AnchorPoint = Vector2.new(0.5, 0)
toast.Position = UDim2.new(0.5, 0, 0, 22)
toast.Size = UDim2.new(0, 500, 0, 50)
toast.BackgroundColor3 = palette.ink
toast.TextColor3 = palette.cream
toast.Font = Enum.Font.GothamBlack
toast.TextSize = 16
toast.TextWrapped = true
toast.Visible = false
toast.Parent = gui
corner(toast, 14)
outline(toast, palette.gold, 2)

local previousMessage = ""
local function showMessage(message)
	if message == "" or message == previousMessage then
		return
	end
	previousMessage = message
	toast.Text = message
	toast.Visible = true
	toast.TextTransparency = 0
	toast.BackgroundTransparency = 0.04
	task.delay(3, function()
		if not toast.Parent or toast.Text ~= message then
			return
		end
		local fade = TweenService:Create(toast, TweenInfo.new(0.3), { TextTransparency = 1, BackgroundTransparency = 1 })
		fade:Play()
		fade.Completed:Wait()
		if toast.Text == message then
			toast.Visible = false
		end
	end)
end

local shopRows = {}
local shopSignature = ""

local function buildShop(state)
	local signatureParts = {}
	for _, item in ipairs(state.catalog) do
		table.insert(signatureParts, item.id)
	end
	local signature = table.concat(signatureParts, ":")
	if signature == shopSignature then
		return
	end
	shopSignature = signature
	shopRows = {}
	for _, child in ipairs(shop:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	for index, item in ipairs(state.catalog) do
		local row = Instance.new("Frame")
		row.Name = item.id
		row.LayoutOrder = index
		row.Size = UDim2.new(1, -4, 0, 59)
		row.BackgroundColor3 = palette.panel
		row.Parent = shop
		corner(row, 10)

		local rarity = textLabel(row, item.rarity, UDim2.new(0, 94, 0, 15), UDim2.new(0, 9, 0, 3), Enum.Font.GothamBlack, rarityColors[item.rarity] or palette.ink, 9)
		local name = textLabel(row, item.name, UDim2.new(1, -133, 0, 21), UDim2.new(0, 9, 0, 17), Enum.Font.GothamBlack, palette.ink, 12)
		local rate = textLabel(row, "+$" .. item.income .. " / sec", UDim2.new(1, -133, 0, 17), UDim2.new(0, 9, 0, 38), Enum.Font.GothamBold, palette.green, 10)
		local buy = makeButton(row, "$" .. item.cost, UDim2.new(0, 104, 0, 40), UDim2.new(1, -112, 0, 9), rarityColors[item.rarity] or palette.purple)
		buy.TextSize = 11
		buy.Activated:Connect(function()
			actionRemote:FireServer({ action = "buy", item = item.id })
		end)
		shopRows[item.id] = { buy = buy, item = item }
	end
end

local function formatCash(value)
	local reversed = string.reverse(tostring(math.max(0, math.floor(value))))
	reversed = string.gsub(reversed, "(%d%d%d)", "%1,")
	return "$" .. string.reverse(string.gsub(reversed, "^,", ""))
end

local function render(state)
	cashLabel.Text = formatCash(state.cash)
	incomeLabel.Text = "+$" .. tostring(state.income) .. " / SEC"
	plotTag.Text = state.plot > 0 and ("PLOT " .. string.format("%02d", state.plot) .. "  •  REBIRTH " .. state.rebirths) or "NO PLOT"

	local banked = state.bank or 0
	local ownedCounts = {}
	for _, ownedItem in ipairs(state.owned) do
		banked += ownedItem.bank
		ownedCounts[ownedItem.id] = (ownedCounts[ownedItem.id] or 0) + 1
	end
	collectButton.Text = "COLLECT ALL  •  " .. formatCash(banked)

	if state.shieldRemaining > 0 then
		statusLabel.Text = "VAULT SHIELDED  •  " .. state.shieldRemaining .. "s safe  •  " .. #state.owned .. " / 8 oddities"
		statusCard.BackgroundColor3 = Color3.fromRGB(213, 244, 249)
	elseif state.shieldCooldown > 0 then
		statusLabel.Text = "VAULT OPEN  •  lock recharges in " .. state.shieldCooldown .. "s  •  " .. #state.owned .. " / 8 oddities"
		statusCard.BackgroundColor3 = Color3.fromRGB(240, 233, 244)
	else
		statusLabel.Text = "VAULT OPEN  •  rivals can swipe  •  " .. #state.owned .. " / 8 oddities"
		statusCard.BackgroundColor3 = Color3.fromRGB(231, 231, 245)
	end

	buildShop(state)
	for id, row in pairs(shopRows) do
		local count = ownedCounts[id] or 0
		local affordable = state.cash >= row.item.cost and #state.owned < 8
		if #state.owned >= 8 then
			row.buy.Text = "DISPLAY FULL"
		elseif count > 0 then
			row.buy.Text = "OWNED " .. count .. "\n" .. formatCash(row.item.cost)
		else
			row.buy.Text = formatCash(row.item.cost)
		end
		row.buy.Active = affordable
		row.buy.AutoButtonColor = affordable
		row.buy.BackgroundTransparency = affordable and 0 or 0.38
	end

	if state.shieldRemaining > 0 then
		shieldButton.Text = "SHIELDED\n" .. state.shieldRemaining .. "s"
	elseif state.shieldCooldown > 0 then
		shieldButton.Text = "RECHARGE\n" .. state.shieldCooldown .. "s"
	else
		shieldButton.Text = "LOCK VAULT\n18s SAFE"
	end
	shieldButton.Active = state.shieldRemaining == 0 and state.shieldCooldown == 0 and state.plot > 0
	shieldButton.AutoButtonColor = shieldButton.Active
	shieldButton.BackgroundTransparency = shieldButton.Active and 0 or 0.35

	local upgradeCost = 800 * (2 ^ state.upgrades)
	upgradeButton.Text = state.upgrades >= 5 and "LAB MAXED" or ("LAB +" .. (state.upgrades + 1) .. "\n" .. formatCash(upgradeCost))
	rebirthButton.Text = state.rebirths >= 6 and "MAX REBIRTH" or ("REBIRTH x2\n" .. formatCash(35000) .. " + 5")
	showMessage(state.message or "")
end

collectButton.Activated:Connect(function()
	actionRemote:FireServer({ action = "collect" })
end)
shieldButton.Activated:Connect(function()
	actionRemote:FireServer({ action = "shield" })
end)
upgradeButton.Activated:Connect(function()
	actionRemote:FireServer({ action = "upgrade" })
end)
rebirthButton.Activated:Connect(function()
	actionRemote:FireServer({ action = "rebirth" })
end)

stateRemote.OnClientEvent:Connect(render)
gui.Parent = player:WaitForChild("PlayerGui")
