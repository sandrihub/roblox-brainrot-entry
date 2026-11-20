local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("BrainrotRemotes")
local actionRemote = remotes:WaitForChild("Action")
local stateRemote = remotes:WaitForChild("State")

local colors = {
	ink = Color3.fromRGB(41, 31, 57),
	panel = Color3.fromRGB(255, 247, 224),
	orange = Color3.fromRGB(255, 139, 62),
	green = Color3.fromRGB(63, 180, 118),
	cream = Color3.fromRGB(255, 253, 245),
	muted = Color3.fromRGB(122, 105, 121),
}

local function corner(instance, radius)
	local ui = Instance.new("UICorner")
	ui.CornerRadius = UDim.new(0, radius or 12)
	ui.Parent = instance
end

local function stroke(instance, color, thickness)
	local ui = Instance.new("UIStroke")
	ui.Color = color or colors.ink
	ui.Thickness = thickness or 2
	ui.Parent = instance
end

local function label(parent, text, size, position, font, color)
	local control = Instance.new("TextLabel")
	control.BackgroundTransparency = 1
	control.Size = size
	control.Position = position
	control.Text = text
	control.TextColor3 = color or colors.ink
	control.Font = font or Enum.Font.GothamBold
	control.TextSize = 16
	control.TextXAlignment = Enum.TextXAlignment.Left
	control.TextWrapped = true
	control.Parent = parent
	return control
end

local function button(parent, text, size, position, background)
	local control = Instance.new("TextButton")
	control.Size = size
	control.Position = position
	control.BackgroundColor3 = background or colors.orange
	control.Text = text
	control.TextColor3 = colors.cream
	control.Font = Enum.Font.GothamBlack
	control.TextSize = 15
	control.TextWrapped = true
	control.AutoButtonColor = true
	control.Parent = parent
	corner(control, 12)
	return control
end

local gui = Instance.new("ScreenGui")
gui.Name = "BrainrotBazaarUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 20

local panel = Instance.new("Frame")
panel.Name = "MainPanel"
panel.AnchorPoint = Vector2.new(0, 0.5)
panel.Position = UDim2.new(0, 18, 0.5, 0)
panel.Size = UDim2.new(0, 360, 0.86, 0)
panel.BackgroundColor3 = colors.panel
panel.Parent = gui
corner(panel, 22)
stroke(panel, colors.ink, 3)

local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 94)
top.BackgroundColor3 = colors.orange
top.Parent = panel
corner(top, 20)

local title = label(top, "BRAINROT\nBAZAAR", UDim2.new(0.65, 0, 0, 62), UDim2.new(0, 16, 0, 8), Enum.Font.GothamBlack, colors.cream)
title.TextSize = 24
local plotLabel = label(top, "PLOT --", UDim2.new(0.32, -8, 0, 40), UDim2.new(0.66, 0, 0, 27), Enum.Font.GothamBlack, Color3.fromRGB(255, 240, 156))
plotLabel.TextSize = 17
plotLabel.TextXAlignment = Enum.TextXAlignment.Right

local cash = label(panel, "$0", UDim2.new(0.52, -18, 0, 38), UDim2.new(0, 16, 0, 104), Enum.Font.GothamBlack, colors.green)
cash.TextSize = 28
local income = label(panel, "+$0 / sec", UDim2.new(0.44, -12, 0, 36), UDim2.new(0.54, 0, 0, 106), Enum.Font.GothamBlack, colors.ink)
income.TextSize = 16
income.TextXAlignment = Enum.TextXAlignment.Right

local collectButton = button(panel, "COLLECT ALL", UDim2.new(1, -28, 0, 48), UDim2.new(0, 14, 0, 150), colors.green)
collectButton.TextSize = 18
local hint = label(panel, "Your goobers cook up cash. Walk up and press E to collect or swipe!", UDim2.new(1, -30, 0, 42), UDim2.new(0, 16, 0, 204), Enum.Font.GothamMedium, colors.muted)
hint.TextSize = 13
hint.TextYAlignment = Enum.TextYAlignment.Top

local shopTitle = label(panel, "THE SUS SHOP  /  BRAINROT RARITIES", UDim2.new(1, -28, 0, 24), UDim2.new(0, 16, 0, 249), Enum.Font.GothamBlack, colors.ink)
shopTitle.TextSize = 13

local shop = Instance.new("ScrollingFrame")
shop.Name = "ShopItems"
shop.Position = UDim2.new(0, 14, 0, 278)
shop.Size = UDim2.new(1, -28, 1, -416)
shop.BackgroundColor3 = colors.cream
shop.BorderSizePixel = 0
shop.ScrollBarThickness = 6
shop.CanvasSize = UDim2.new()
shop.AutomaticCanvasSize = Enum.AutomaticSize.Y
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

local upgradeButton = button(panel, "UPGRADE LAB", UDim2.new(0.48, -12, 0, 48), UDim2.new(0, 14, 1, -112), Color3.fromRGB(111, 103, 202))
local rebirthButton = button(panel, "REBIRTH x2", UDim2.new(0.48, -12, 0, 48), UDim2.new(0.52, -2, 1, -112), Color3.fromRGB(199, 80, 146))
local bottomLine = label(panel, "Upgrade boosts income  |  Rebirth doubles it", UDim2.new(1, -28, 0, 24), UDim2.new(0, 16, 1, -56), Enum.Font.GothamBold, colors.muted)
bottomLine.TextSize = 12

local toast = Instance.new("TextLabel")
toast.Name = "Toast"
toast.AnchorPoint = Vector2.new(0.5, 0)
toast.Position = UDim2.new(0.5, 0, 0, 24)
toast.Size = UDim2.new(0, 480, 0, 52)
toast.BackgroundColor3 = colors.ink
toast.BackgroundTransparency = 0.05
toast.TextColor3 = colors.cream
toast.Font = Enum.Font.GothamBlack
toast.TextSize = 17
toast.TextWrapped = true
toast.Visible = false
toast.Parent = gui
corner(toast, 14)
stroke(toast, colors.orange, 2)

local previousMessage = ""
local function showMessage(message)
	if message == "" or message == previousMessage then
		return
	end
	previousMessage = message
	toast.Text = message
	toast.Visible = true
	toast.TextTransparency = 0
	toast.BackgroundTransparency = 0.05
	task.delay(3.2, function()
		if toast.Parent and toast.Text == message then
			local fade = TweenService:Create(toast, TweenInfo.new(0.35), { TextTransparency = 1, BackgroundTransparency = 1 })
			fade:Play()
			fade.Completed:Wait()
			if toast.Text == message then
				toast.Visible = false
			end
		end
	end)
end

local rarityColors = {
	COMMON = Color3.fromRGB(95, 116, 121),
	UNCOMMON = Color3.fromRGB(49, 157, 83),
	RARE = Color3.fromRGB(65, 126, 213),
	EPIC = Color3.fromRGB(160, 84, 191),
	LEGENDARY = Color3.fromRGB(223, 134, 31),
	MYTHIC = Color3.fromRGB(209, 69, 104),
}

local lastShopSignature = ""

local function makeShopRow(item, index, state)
	local row = Instance.new("Frame")
	row.Name = item.id
	row.LayoutOrder = index
	row.Size = UDim2.new(1, -4, 0, 56)
	row.BackgroundColor3 = colors.panel
	row.Parent = shop
	corner(row, 10)

	local rarity = label(row, item.rarity, UDim2.new(0, 78, 0, 16), UDim2.new(0, 8, 0, 3), Enum.Font.GothamBlack, rarityColors[item.rarity] or colors.ink)
	rarity.TextSize = 10
	local name = label(row, item.name, UDim2.new(0.62, -6, 0, 23), UDim2.new(0, 8, 0, 19), Enum.Font.GothamBlack, colors.ink)
	name.TextSize = 13
	local rate = label(row, "+$" .. item.income .. "/s", UDim2.new(0, 72, 0, 18), UDim2.new(0, 8, 0, 37), Enum.Font.GothamBold, colors.green)
	rate.TextSize = 11

	local ownedCount = 0
	for _, ownedItem in ipairs(state.owned) do
		if ownedItem.id == item.id then
			ownedCount += 1
		end
	end
	local buttonText = "$" .. item.cost
	if #state.owned >= 8 then
		buttonText = "PLOT FULL"
	elseif state.cash < item.cost then
		buttonText = "$" .. item.cost
	end
	local buy = button(row, buttonText, UDim2.new(0, 104, 0, 38), UDim2.new(1, -112, 0, 9), rarityColors[item.rarity])
	buy.TextSize = 13
	if ownedCount > 0 then
		buy.Text = buttonText .. "\nOWNED " .. ownedCount
		buy.TextSize = 10
	end
	buy.Activated:Connect(function()
		actionRemote:FireServer({ action = "buy", item = item.id })
	end)
end

local function render(state)
	cash.Text = "$" .. tostring(state.cash)
	income.Text = "+$" .. tostring(state.income) .. " / sec"
	plotLabel.Text = state.plot > 0 and ("PLOT " .. state.plot .. "  |  REBIRTH " .. state.rebirths) or "NO PLOT"

	local signatureParts = { tostring(state.cash), tostring(#state.owned) }
	for _, ownedItem in ipairs(state.owned) do
		table.insert(signatureParts, ownedItem.id)
	end
	local shopSignature = table.concat(signatureParts, ":")
	if shopSignature ~= lastShopSignature then
		lastShopSignature = shopSignature
		for _, child in ipairs(shop:GetChildren()) do
			if child:IsA("Frame") then
				child:Destroy()
			end
		end
		for index, item in ipairs(state.catalog) do
			makeShopRow(item, index, state)
		end
	end

	local upgradeCost = 600 * (2 ^ state.upgrades)
	upgradeButton.Text = state.upgrades >= 5 and "LAB MAXED" or ("UPGRADE LAB\n$" .. upgradeCost .. "  |  LV " .. state.upgrades)
	rebirthButton.Text = state.rebirths >= 6 and "REBIRTH MAXED" or ("REBIRTH x2\n$25K + 5 GOOBERS  |  " .. state.rebirths .. "/6")
	showMessage(state.message or "")
end

collectButton.Activated:Connect(function()
	actionRemote:FireServer({ action = "collect" })
end)
upgradeButton.Activated:Connect(function()
	actionRemote:FireServer({ action = "upgrade" })
end)
rebirthButton.Activated:Connect(function()
	actionRemote:FireServer({ action = "rebirth" })
end)

stateRemote.OnClientEvent:Connect(render)
gui.Parent = player:WaitForChild("PlayerGui")
