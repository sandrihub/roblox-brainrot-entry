--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("RotRushRemotes")
local actionRemote = remotes:WaitForChild("GameAction") :: RemoteEvent
local stateRemote = remotes:WaitForChild("GameState") :: RemoteEvent
local noticeRemote = remotes:WaitForChild("GameNotice") :: RemoteEvent

local PALETTE = {
	panel = Color3.fromRGB(20, 23, 43),
	panelLight = Color3.fromRGB(32, 38, 67),
	text = Color3.fromRGB(249, 246, 255),
	muted = Color3.fromRGB(176, 183, 212),
	pink = Color3.fromRGB(255, 105, 196),
	cyan = Color3.fromRGB(93, 232, 255),
	gold = Color3.fromRGB(255, 218, 111),
	green = Color3.fromRGB(113, 242, 171),
	red = Color3.fromRGB(255, 105, 128),
}

local function round(parent: Instance, radius: number)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = parent
end

local function outline(parent: Instance, color: Color3, thickness: number, transparency: number?)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = thickness
	stroke.Transparency = transparency or 0
	stroke.Parent = parent
end

local function addText(
	parent: Instance,
	text: string,
	size: number,
	color: Color3,
	font: Enum.Font,
	position: UDim2,
	dimensions: UDim2
): TextLabel
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = position
	label.Size = dimensions
	label.Font = font
	label.Text = text
	label.TextColor3 = color
	label.TextSize = size
	label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.Parent = parent
	return label
end

local function addButton(
	parent: Instance,
	text: string,
	size: UDim2,
	position: UDim2,
	color: Color3
): TextButton
	local button = Instance.new("TextButton")
	button.AutoButtonColor = true
	button.BackgroundColor3 = color
	button.Position = position
	button.Size = size
	button.Font = Enum.Font.GothamBlack
	button.Text = text
	button.TextColor3 = PALETTE.panel
	button.TextSize = 14
	button.TextWrapped = true
	button.Parent = parent
	round(button, 12)
	return button
end

local gui = Instance.new("ScreenGui")
gui.Name = "RotRushHUD"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 20
gui.Parent = playerGui

local uiScale = Instance.new("UIScale")
uiScale.Parent = gui

local function updateScale()
	local camera = workspace.CurrentCamera
	if camera then
		uiScale.Scale = math.clamp(camera.ViewportSize.X / 1280, 0.72, 1)
	end
end

updateScale()
if workspace.CurrentCamera then
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
end

local header = Instance.new("Frame")
header.Name = "Header"
header.BackgroundColor3 = PALETTE.panel
header.BackgroundTransparency = 0.08
header.Position = UDim2.new(0, 18, 0, 16)
header.Size = UDim2.new(1, -36, 0, 78)
header.Parent = gui
round(header, 18)
outline(header, Color3.fromRGB(89, 99, 153), 1.5, 0.22)

local title = addText(
	header,
	"ROT RUSH",
	25,
	PALETTE.pink,
	Enum.Font.GothamBlack,
	UDim2.new(0, 20, 0, 8),
	UDim2.new(0, 240, 0, 30)
)
title.TextXAlignment = Enum.TextXAlignment.Left

local subtitle = addText(
	header,
	"NEON SNACKLANDS  •  BUILD YOUR ROT EMPIRE",
	10,
	PALETTE.muted,
	Enum.Font.GothamBold,
	UDim2.new(0, 21, 0, 39),
	UDim2.new(0, 310, 0, 20)
)
subtitle.TextXAlignment = Enum.TextXAlignment.Left

local cashLabel = addText(header, "$350", 23, PALETTE.gold, Enum.Font.GothamBlack, UDim2.new(0.43, 0, 0, 8), UDim2.new(0, 170, 0, 31))
cashLabel.TextXAlignment = Enum.TextXAlignment.Center
local cashCaption = addText(header, "WALLET", 10, PALETTE.muted, Enum.Font.GothamBold, UDim2.new(0.43, 0, 0, 42), UDim2.new(0, 170, 0, 16))
cashCaption.TextXAlignment = Enum.TextXAlignment.Center

local bankLabel = addText(header, "$0", 22, PALETTE.green, Enum.Font.GothamBlack, UDim2.new(0.61, 0, 0, 8), UDim2.new(0, 170, 0, 31))
bankLabel.TextXAlignment = Enum.TextXAlignment.Center
local bankCaption = addText(header, "UNBANKED", 10, PALETTE.muted, Enum.Font.GothamBold, UDim2.new(0.61, 0, 0, 42), UDim2.new(0, 170, 0, 16))
bankCaption.TextXAlignment = Enum.TextXAlignment.Center

local incomeLabel = addText(header, "$0/s", 20, PALETTE.cyan, Enum.Font.GothamBlack, UDim2.new(0.8, 0, 0, 8), UDim2.new(0, 145, 0, 31))
incomeLabel.TextXAlignment = Enum.TextXAlignment.Center
local incomeCaption = addText(header, "COLLECTION RATE", 9, PALETTE.muted, Enum.Font.GothamBold, UDim2.new(0.8, 0, 0, 42), UDim2.new(0, 145, 0, 16))
incomeCaption.TextXAlignment = Enum.TextXAlignment.Center

local shop = Instance.new("Frame")
shop.Name = "MarketPanel"
shop.BackgroundColor3 = PALETTE.panel
shop.BackgroundTransparency = 0.06
shop.Position = UDim2.new(1, -340, 0, 110)
shop.Size = UDim2.new(0, 322, 0, 374)
shop.Parent = gui
round(shop, 18)
outline(shop, Color3.fromRGB(111, 95, 171), 1.5, 0.15)

local shopTitle = addText(shop, "NIGHT MARKET", 19, PALETTE.cyan, Enum.Font.GothamBlack, UDim2.new(0, 17, 0, 12), UDim2.new(1, -34, 0, 25))
local restockLabel = addText(shop, "RESTOCK IN 01:15", 10, PALETTE.muted, Enum.Font.GothamBold, UDim2.new(0, 18, 0, 39), UDim2.new(1, -36, 0, 18))
local offerButtons: { TextButton } = {}

for index = 1, 3 do
	local button = addButton(
		shop,
		"Loading market stock...",
		UDim2.new(1, -28, 0, 65),
		UDim2.new(0, 14, 0, 66 + (index - 1) * 71),
		index == 1 and Color3.fromRGB(255, 206, 106) or (index == 2 and Color3.fromRGB(105, 232, 196) or Color3.fromRGB(143, 152, 255))
	)
	button.TextXAlignment = Enum.TextXAlignment.Left
	button.TextSize = 12
	button.Activated:Connect(function()
		local offerId = button:GetAttribute("OfferId")
		if typeof(offerId) == "string" then
			actionRemote:FireServer("buy", offerId)
		end
	end)
	table.insert(offerButtons, button)
end

local upgradeButton = addButton(shop, "UPGRADE INCOME", UDim2.new(0.49, -10, 0, 43), UDim2.new(0, 14, 1, -54), PALETTE.gold)
upgradeButton.Activated:Connect(function()
	actionRemote:FireServer("upgrade")
end)

local rebirthButton = addButton(shop, "REBIRTH", UDim2.new(0.49, -10, 0, 43), UDim2.new(0.51, 0, 1, -54), PALETTE.pink)
rebirthButton.Activated:Connect(function()
	actionRemote:FireServer("rebirth")
end)

local collection = Instance.new("Frame")
collection.Name = "CollectionPanel"
collection.BackgroundColor3 = PALETTE.panel
collection.BackgroundTransparency = 0.08
collection.Position = UDim2.new(0, 18, 1, -159)
collection.Size = UDim2.new(0, 385, 0, 140)
collection.Parent = gui
round(collection, 18)
outline(collection, Color3.fromRGB(89, 99, 153), 1.5, 0.22)

local collectionTitle = addText(collection, "YOUR COLLECTION", 14, PALETTE.text, Enum.Font.GothamBlack, UDim2.new(0, 15, 0, 9), UDim2.new(0.62, 0, 0, 23))
local inventoryLabel = addText(collection, "INVENTORY  0", 10, PALETTE.muted, Enum.Font.GothamBold, UDim2.new(0.63, 0, 0, 10), UDim2.new(0.34, -8, 0, 20))
inventoryLabel.TextXAlignment = Enum.TextXAlignment.Right

local slotLabels: { TextLabel } = {}
for index = 1, 4 do
	local slot = Instance.new("Frame")
	slot.Name = "Slot" .. tostring(index)
	slot.BackgroundColor3 = PALETTE.panelLight
	slot.Position = UDim2.new(0, 12 + (index - 1) * 91, 0, 39)
	slot.Size = UDim2.new(0, 84, 0, 57)
	slot.Parent = collection
	round(slot, 11)
	outline(slot, Color3.fromRGB(92, 105, 157), 1, 0.35)

	local label = addText(slot, "PAD " .. tostring(index) .. "\nEMPTY", 10, PALETTE.muted, Enum.Font.GothamBold, UDim2.new(0, 4, 0, 4), UDim2.new(1, -8, 1, -8))
	label.TextXAlignment = Enum.TextXAlignment.Center
	slotLabels[index] = label
end

local collectButton = addButton(collection, "COLLECT ALL", UDim2.new(1, -24, 0, 28), UDim2.new(0, 12, 1, -35), PALETTE.green)
collectButton.TextSize = 12
collectButton.Activated:Connect(function()
	actionRemote:FireServer("collect")
end)

local rebirthLabel = addText(gui, "REBIRTHS  0", 12, PALETTE.gold, Enum.Font.GothamBlack, UDim2.new(0, 20, 1, -194), UDim2.new(0, 190, 0, 25))

local toast = Instance.new("TextLabel")
toast.Name = "Toast"
toast.AnchorPoint = Vector2.new(0.5, 0)
toast.BackgroundColor3 = PALETTE.panel
toast.BackgroundTransparency = 1
toast.Position = UDim2.new(0.5, 0, 0, 106)
toast.Size = UDim2.new(0, 500, 0, 42)
toast.Font = Enum.Font.GothamBold
toast.Text = ""
toast.TextColor3 = PALETTE.text
toast.TextSize = 14
toast.TextTransparency = 1
toast.Visible = false
toast.Parent = gui
round(toast, 14)

local toastStroke = Instance.new("UIStroke")
toastStroke.Color = PALETTE.cyan
toastStroke.Thickness = 1.5
toastStroke.Parent = toast

local toastId = 0
local function showNotice(message: string, tone: string)
	toastId += 1
	local currentId = toastId
	toast.Text = message
	toast.TextColor3 = tone == "warn" and PALETTE.gold or (tone == "good" and PALETTE.green or PALETTE.text)
	toastStroke.Color = tone == "warn" and PALETTE.red or (tone == "good" and PALETTE.green or PALETTE.cyan)
	toast.Visible = true
	toast.BackgroundTransparency = 0.08
	toast.TextTransparency = 0
	TweenService:Create(toast, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, 0, 0, 98),
	}):Play()

	task.delay(3, function()
		if toastId ~= currentId then
			return
		end
		local fade = TweenService:Create(toast, TweenInfo.new(0.35), {
			BackgroundTransparency = 1,
			TextTransparency = 1,
		})
		fade:Play()
		fade.Completed:Wait()
		if toastId == currentId then
			toast.Visible = false
		end
	end)
end

local function updateState(state: { [string]: any })
	cashLabel.Text = "$" .. tostring(state.cash or 0)
	bankLabel.Text = "$" .. tostring(state.pending or 0)
	incomeLabel.Text = "$" .. tostring(state.income or 0) .. "/s"
	inventoryLabel.Text = "INVENTORY  " .. tostring(state.inventoryCount or 0)
	rebirthLabel.Text = "REBIRTHS  " .. tostring(state.rebirths or 0)

	local level = state.incomeLevel or 1
	local upgradeCost = state.upgradeCost or 0
	upgradeButton.Text = upgradeCost > 0
		and ("UPGRADE  •  LV " .. tostring(level) .. "  •  $" .. tostring(upgradeCost))
		or "INCOME MAXED"
	upgradeButton.BackgroundColor3 = upgradeCost > 0 and PALETTE.gold or PALETTE.muted

	local rebirthCost = state.rebirthCost or 0
	rebirthButton.Text = rebirthCost > 0
		and ("REBIRTH  •  $" .. tostring(rebirthCost))
		or "REBIRTH MAXED"
	rebirthButton.BackgroundColor3 = rebirthCost > 0 and PALETTE.pink or PALETTE.muted

	for index, button in ipairs(offerButtons) do
		local offer = state.offers and state.offers[index]
		if offer then
			button:SetAttribute("OfferId", offer.id)
			button.Text = offer.rarity .. "  •  " .. offer.name
				.. "\n$" .. tostring(offer.price) .. " buy   |   earns $" .. tostring(offer.income) .. "/s"
			button.TextColor3 = PALETTE.text
		else
			button:SetAttribute("OfferId", nil)
			button.Text = "Restocking..."
		end
	end

	for index = 1, 4 do
		local slot = state.slots and state.slots[index]
		if slot and slot.name ~= "" then
			slotLabels[index].Text = slot.rarity:upper() .. "\n" .. slot.name .. "\n+$" .. tostring(slot.pending)
			slotLabels[index].TextColor3 = PALETTE.green
		else
			slotLabels[index].Text = "PAD " .. tostring(index) .. "\nEMPTY"
			slotLabels[index].TextColor3 = PALETTE.muted
		end
	end

	local restock = state.restockIn or 0
	restockLabel.Text = string.format("RESTOCK IN %02d:%02d", math.floor(restock / 60), restock % 60)
end

stateRemote.OnClientEvent:Connect(updateState)
noticeRemote.OnClientEvent:Connect(showNotice)
actionRemote:FireServer("sync")

task.spawn(function()
	while gui.Parent do
		task.wait(1)
		local text = restockLabel.Text
		local minutes, seconds = string.match(text, "RESTOCK IN (%d+):(%d+)")
		if minutes and seconds then
			local remaining = math.max(0, tonumber(minutes) * 60 + tonumber(seconds) - 1)
			restockLabel.Text = string.format("RESTOCK IN %02d:%02d", math.floor(remaining / 60), remaining % 60)
		end
	end
end)
