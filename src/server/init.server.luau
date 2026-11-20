--!strict

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local STARTING_CASH = 350
local SLOT_COUNT = 4
local PLOT_COUNT = 12
local RESTOCK_SECONDS = 75
local UPGRADE_LIMIT = 9
local REBIRTH_LIMIT = 10
local DATA_STORE_NAME = "RotRush_Player_v1"

type Brainrot = {
	id: string,
	name: string,
	rarity: string,
	price: number,
	income: number,
	color: Color3,
	accent: Color3,
}

type PlayerState = {
	cash: number,
	rebirths: number,
	incomeLevel: number,
	inventory: { string },
	placed: { [number]: string },
	pending: { [number]: number },
}

type Plot = {
	cframe: CFrame,
	spawn: SpawnLocation,
	sign: TextLabel,
	slots: { BasePart },
	ownerId: number?,
}

local CATALOG: { [string]: Brainrot } = {
	bloopi = {
		id = "bloopi",
		name = "Bloopi Bananini",
		rarity = "Common",
		price = 50,
		income = 4,
		color = Color3.fromRGB(255, 222, 92),
		accent = Color3.fromRGB(255, 135, 55),
	},
	taco = {
		id = "taco",
		name = "Taco Tornado",
		rarity = "Uncommon",
		price = 180,
		income = 12,
		color = Color3.fromRGB(99, 245, 174),
		accent = Color3.fromRGB(30, 180, 202),
	},
	orbit = {
		id = "orbit",
		name = "Orbit Goblini",
		rarity = "Rare",
		price = 520,
		income = 34,
		color = Color3.fromRGB(95, 190, 255),
		accent = Color3.fromRGB(122, 102, 255),
	},
	wifi = {
		id = "wifi",
		name = "WiFi Wizardini",
		rarity = "Epic",
		price = 1450,
		income = 95,
		color = Color3.fromRGB(193, 110, 255),
		accent = Color3.fromRGB(255, 95, 201),
	},
	comet = {
		id = "comet",
		name = "Comet Cappuccini",
		rarity = "Legendary",
		price = 3900,
		income = 270,
		color = Color3.fromRGB(255, 151, 92),
		accent = Color3.fromRGB(255, 218, 112),
	},
	dumpling = {
		id = "dumpling",
		name = "Disco Dumpling",
		rarity = "Mythic",
		price = 9000,
		income = 760,
		color = Color3.fromRGB(255, 103, 158),
		accent = Color3.fromRGB(123, 242, 255),
	},
}

local SHOP_ROTATIONS: { { string } } = {
	{ "bloopi", "taco", "orbit" },
	{ "taco", "orbit", "wifi" },
	{ "orbit", "wifi", "comet" },
	{ "wifi", "comet", "dumpling" },
}

local PLOT_COLORS = {
	Color3.fromRGB(255, 113, 207),
	Color3.fromRGB(73, 226, 255),
	Color3.fromRGB(255, 185, 87),
	Color3.fromRGB(163, 126, 255),
	Color3.fromRGB(109, 245, 167),
	Color3.fromRGB(255, 115, 113),
	Color3.fromRGB(110, 173, 255),
	Color3.fromRGB(255, 224, 96),
	Color3.fromRGB(77, 233, 202),
	Color3.fromRGB(206, 117, 255),
	Color3.fromRGB(255, 145, 84),
	Color3.fromRGB(143, 235, 255),
}

local dataStore = DataStoreService:GetDataStore(DATA_STORE_NAME)
local world = Instance.new("Folder")
world.Name = "RotRushWorld"
world.Parent = Workspace

local remotes = Instance.new("Folder")
remotes.Name = "RotRushRemotes"
remotes.Parent = ReplicatedStorage

local actionRemote = Instance.new("RemoteEvent")
actionRemote.Name = "GameAction"
actionRemote.Parent = remotes

local stateRemote = Instance.new("RemoteEvent")
stateRemote.Name = "GameState"
stateRemote.Parent = remotes

local noticeRemote = Instance.new("RemoteEvent")
noticeRemote.Name = "GameNotice"
noticeRemote.Parent = remotes

local states: { [number]: PlayerState } = {}
local dataReady: { [number]: boolean } = {}
local plots: { Plot } = {}
local plotByUser: { [number]: number } = {}
local slotModels: { [number]: { [number]: Model } } = {}
local slotPrompts: { [number]: { [number]: ProximityPrompt } } = {}
local shopStands: { [number]: { base: Part, prompt: ProximityPrompt, label: TextLabel, model: Model? } } = {}
local hazardDebounce: { [Humanoid]: number } = {}
local rotationIndex = 1
local lastRestock = os.clock()

local function makePart(
	name: string,
	size: Vector3,
	cframe: CFrame,
	color: Color3,
	material: Enum.Material,
	parent: Instance,
	shape: Enum.PartType?
): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = material
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.CastShadow = true
	if shape then
		part.Shape = shape
	end
	part.Parent = parent
	return part
end

local function addBillboard(
	adornee: BasePart,
	text: string,
	color: Color3,
	width: number?,
	height: number?
): TextLabel
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "WorldLabel"
	billboard.Adornee = adornee
	billboard.Size = UDim2.fromOffset(width or 280, height or 54)
	billboard.StudsOffset = Vector3.new(0, 4, 0)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 150
	billboard.Parent = adornee

	local label = Instance.new("TextLabel")
	label.Name = "Text"
	label.BackgroundColor3 = Color3.fromRGB(13, 16, 31)
	label.BackgroundTransparency = 0.12
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.GothamBlack
	label.Text = text
	label.TextColor3 = color
	label.TextScaled = true
	label.TextStrokeTransparency = 0.55
	label.Parent = billboard

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = label

	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = 2
	stroke.Transparency = 0.2
	stroke.Parent = label
	return label
end

local function addPrompt(
	parent: BasePart,
	actionText: string,
	objectText: string,
	holdDuration: number
): ProximityPrompt
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = actionText
	prompt.ObjectText = objectText
	prompt.HoldDuration = holdDuration
	prompt.MaxActivationDistance = 11
	prompt.RequiresLineOfSight = false
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
	prompt.Parent = parent
	return prompt
end

local function createBrainrotModel(item: Brainrot, position: Vector3, parent: Instance): Model
	local model = Instance.new("Model")
	model.Name = item.name

	local body = makePart(
		"Body",
		Vector3.new(3.2, 2.7, 2.7),
		CFrame.new(position + Vector3.new(0, 1.9, 0)),
		item.color,
		Enum.Material.SmoothPlastic,
		model,
		Enum.PartType.Ball
	)
	body.CanCollide = false
	body.CanTouch = false
	body.CanQuery = false

	local belly = makePart(
		"Belly",
		Vector3.new(1.7, 1.15, 0.34),
		CFrame.new(position + Vector3.new(0, 1.6, -1.24)),
		item.accent,
		Enum.Material.Neon,
		model,
		Enum.PartType.Ball
	)
	belly.CanCollide = false
	belly.CanTouch = false
	belly.CanQuery = false

	for _, eyeX in ipairs({ -0.62, 0.62 }) do
		local eye = makePart(
			"Eye",
			Vector3.new(0.55, 0.65, 0.25),
			CFrame.new(position + Vector3.new(eyeX, 2.15, -1.2)),
			Color3.fromRGB(255, 255, 255),
			Enum.Material.SmoothPlastic,
			model,
			Enum.PartType.Ball
		)
		eye.CanCollide = false
		eye.CanTouch = false
		eye.CanQuery = false

		local pupil = makePart(
			"Pupil",
			Vector3.new(0.2, 0.27, 0.13),
			CFrame.new(position + Vector3.new(eyeX, 2.13, -1.36)),
			Color3.fromRGB(22, 19, 39),
			Enum.Material.SmoothPlastic,
			model,
			Enum.PartType.Ball
		)
		pupil.CanCollide = false
		pupil.CanTouch = false
		pupil.CanQuery = false
	end

	local crest = makePart(
		"SnackCrest",
		Vector3.new(1.25, 0.65, 1.25),
		CFrame.new(position + Vector3.new(0, 3.35, 0)),
		item.accent,
		Enum.Material.Neon,
		model,
		Enum.PartType.Ball
	)
	crest.CanCollide = false
	crest.CanTouch = false
	crest.CanQuery = false

	model.PrimaryPart = body
	addBillboard(body, item.rarity .. "  •  " .. item.name, item.accent, 245, 46)
	model.Parent = parent
	return model
end

local function defaultState(): PlayerState
	return {
		cash = STARTING_CASH,
		rebirths = 0,
		incomeLevel = 1,
		inventory = {},
		placed = {},
		pending = {},
	}
end

local function safeInteger(value: any, fallback: number, lower: number, upper: number): number
	if typeof(value) ~= "number" or value ~= value then
		return fallback
	end
	return math.clamp(math.floor(value), lower, upper)
end

local function loadState(player: Player): (PlayerState, boolean)
	local state = defaultState()
	local ok, saved = pcall(function()
		return dataStore:GetAsync("player_" .. tostring(player.UserId))
	end)

	if not ok then
		warn("Rot Rush could not load data for " .. player.Name .. ": " .. tostring(saved))
		return state, false
	end
	if typeof(saved) ~= "table" then
		return state, true
	end

	state.cash = safeInteger(saved.cash, STARTING_CASH, 0, 1_000_000_000)
	state.rebirths = safeInteger(saved.rebirths, 0, 0, REBIRTH_LIMIT)
	state.incomeLevel = safeInteger(saved.incomeLevel, 1, 1, UPGRADE_LIMIT)

	if typeof(saved.inventory) == "table" then
		for _, id in ipairs(saved.inventory) do
			if typeof(id) == "string" and CATALOG[id] and #state.inventory < 20 then
				table.insert(state.inventory, id)
			end
		end
	end

	if typeof(saved.placed) == "table" then
		for slotIndex = 1, SLOT_COUNT do
			local id = saved.placed[tostring(slotIndex)]
			if typeof(id) == "string" and CATALOG[id] then
				state.placed[slotIndex] = id
				state.pending[slotIndex] = 0
			end
		end
	end
	return state, true
end

local function saveState(player: Player)
	local state = states[player.UserId]
	if not state or not dataReady[player.UserId] then
		return
	end

	local placed: { [string]: string } = {}
	for slotIndex = 1, SLOT_COUNT do
		local itemId = state.placed[slotIndex]
		if itemId then
			placed[tostring(slotIndex)] = itemId
		end
	end

	local payload = {
		cash = math.floor(state.cash),
		rebirths = state.rebirths,
		incomeLevel = state.incomeLevel,
		inventory = table.clone(state.inventory),
		placed = placed,
	}

	local ok, err = pcall(function()
		dataStore:UpdateAsync("player_" .. tostring(player.UserId), function()
			return payload
		end)
	end)
	if not ok then
		warn("Rot Rush could not save data for " .. player.Name .. ": " .. tostring(err))
	end
end

local function currentOffers(): { Brainrot }
	local ids = SHOP_ROTATIONS[rotationIndex]
	local offers: { Brainrot } = {}
	for _, id in ipairs(ids) do
		table.insert(offers, CATALOG[id])
	end
	return offers
end

local function getIncome(state: PlayerState): number
	local baseIncome = 0
	for slotIndex = 1, SLOT_COUNT do
		local itemId = state.placed[slotIndex]
		if itemId then
			baseIncome += CATALOG[itemId].income
		end
	end
	local upgradeMultiplier = 1 + (state.incomeLevel - 1) * 0.3
	local rebirthMultiplier = 1 + state.rebirths * 0.4
	return baseIncome * upgradeMultiplier * rebirthMultiplier
end

local function getPending(state: PlayerState): number
	local total = 0
	for slotIndex = 1, SLOT_COUNT do
		total += state.pending[slotIndex] or 0
	end
	return total
end

local function getUpgradeCost(state: PlayerState): number
	if state.incomeLevel >= UPGRADE_LIMIT then
		return 0
	end
	return 300 * (2 ^ (state.incomeLevel - 1))
end

local function getRebirthCost(state: PlayerState): number
	if state.rebirths >= REBIRTH_LIMIT then
		return 0
	end
	return 8000 * (state.rebirths + 1)
end

local function sendNotice(player: Player, message: string, tone: string?)
	noticeRemote:FireClient(player, message, tone or "info")
end

local function updateSlotPrompt(player: Player, slotIndex: number)
	local plotIndex = plotByUser[player.UserId]
	local state = states[player.UserId]
	local prompt = plotIndex and slotPrompts[plotIndex] and slotPrompts[plotIndex][slotIndex]
	if not prompt then
		return
	end

	if not state then
		prompt.ActionText = "Loading"
	elseif state.placed[slotIndex] then
		prompt.ActionText = "Collect $" .. tostring(math.floor(state.pending[slotIndex] or 0))
	else
		prompt.ActionText = #state.inventory > 0 and "Place " .. CATALOG[state.inventory[1]].name or "Empty pad"
	end
end

local function updateAllPrompts(player: Player)
	for slotIndex = 1, SLOT_COUNT do
		updateSlotPrompt(player, slotIndex)
	end
end

local function sendState(player: Player)
	local state = states[player.UserId]
	if not state then
		return
	end

	local slotInfo = {}
	for slotIndex = 1, SLOT_COUNT do
		local itemId = state.placed[slotIndex]
		local item = itemId and CATALOG[itemId] or nil
		slotInfo[slotIndex] = {
			name = item and item.name or "",
			rarity = item and item.rarity or "",
			pending = math.floor(state.pending[slotIndex] or 0),
			income = item and item.income or 0,
		}
	end

	local offers = {}
	for _, item in ipairs(currentOffers()) do
		table.insert(offers, {
			id = item.id,
			name = item.name,
			rarity = item.rarity,
			price = item.price,
			income = item.income,
		})
	end

	stateRemote:FireClient(player, {
		cash = math.floor(state.cash),
		pending = math.floor(getPending(state)),
		income = math.floor(getIncome(state)),
		rebirths = state.rebirths,
		incomeLevel = state.incomeLevel,
		upgradeCost = getUpgradeCost(state),
		rebirthCost = getRebirthCost(state),
		inventoryCount = #state.inventory,
		slots = slotInfo,
		offers = offers,
		restockIn = math.max(0, math.ceil(RESTOCK_SECONDS - (os.clock() - lastRestock))),
	})
	updateAllPrompts(player)
end

local function findOpenSlot(state: PlayerState): number?
	for slotIndex = 1, SLOT_COUNT do
		if not state.placed[slotIndex] then
			return slotIndex
		end
	end
	return nil
end

local function drawSlot(player: Player, slotIndex: number)
	local plotIndex = plotByUser[player.UserId]
	local state = states[player.UserId]
	local plot = plotIndex and plots[plotIndex]
	local itemId = state and state.placed[slotIndex]
	local slot = plot and plot.slots[slotIndex]
	if not slot then
		return
	end

	local existing = slotModels[player.UserId] and slotModels[player.UserId][slotIndex]
	if existing then
		existing:Destroy()
		slotModels[player.UserId][slotIndex] = nil
	end
	if itemId and state then
		local model = createBrainrotModel(CATALOG[itemId], slot.Position + Vector3.new(0, 0.4, 0), world)
		slotModels[player.UserId] = slotModels[player.UserId] or {}
		slotModels[player.UserId][slotIndex] = model
	end
end

local function placeInventoryItem(player: Player, slotIndex: number): boolean
	local state = states[player.UserId]
	if not state or state.placed[slotIndex] or #state.inventory == 0 then
		return false
	end

	local itemId = table.remove(state.inventory, 1)
	state.placed[slotIndex] = itemId
	state.pending[slotIndex] = 0
	drawSlot(player, slotIndex)
	sendNotice(player, CATALOG[itemId].name .. " joined your collection!", "good")
	sendState(player)
	return true
end

local function collectSlot(player: Player, slotIndex: number)
	local state = states[player.UserId]
	if not state then
		return
	end
	local amount = math.floor(state.pending[slotIndex] or 0)
	if amount <= 0 then
		sendNotice(player, "This pad is ready to earn. Come back in a moment.", "info")
		return
	end

	state.cash += amount
	state.pending[slotIndex] = 0
	sendNotice(player, "Banked $" .. tostring(amount) .. " from this pad.", "good")
	sendState(player)
end

local function collectAll(player: Player)
	local state = states[player.UserId]
	if not state then
		return
	end
	local amount = math.floor(getPending(state))
	if amount <= 0 then
		sendNotice(player, "Your collection is saving up its first dollars.", "info")
		return
	end

	for slotIndex = 1, SLOT_COUNT do
		state.pending[slotIndex] = 0
	end
	state.cash += amount
	sendNotice(player, "Collection banked $" .. tostring(amount) .. "!", "good")
	sendState(player)
end

local function purchaseBrainrot(player: Player, itemId: string)
	local state = states[player.UserId]
	if not state then
		return
	end

	local item = CATALOG[itemId]
	local isAvailable = false
	for _, offer in ipairs(currentOffers()) do
		if offer.id == itemId then
			isAvailable = true
			break
		end
	end
	if not item or not isAvailable then
		sendNotice(player, "That market offer has rotated. Check the new stock.", "warn")
		sendState(player)
		return
	end
	if state.cash < item.price then
		sendNotice(player, "You need $" .. tostring(item.price - state.cash) .. " more for " .. item.name .. ".", "warn")
		return
	end
	if #state.inventory >= 20 and not findOpenSlot(state) then
		sendNotice(player, "Your inventory is full. Make room on a collection pad.", "warn")
		return
	end

	state.cash -= item.price
	local openSlot = findOpenSlot(state)
	if openSlot then
		state.placed[openSlot] = itemId
		state.pending[openSlot] = 0
		drawSlot(player, openSlot)
		sendNotice(player, "Bought " .. item.name .. " and placed it on your plot!", "good")
	else
		table.insert(state.inventory, itemId)
		sendNotice(player, "Bought " .. item.name .. ". It is waiting in your inventory.", "good")
	end
	sendState(player)
end

local function buyUpgrade(player: Player)
	local state = states[player.UserId]
	if not state then
		return
	end
	local cost = getUpgradeCost(state)
	if cost == 0 then
		sendNotice(player, "Your income multiplier is already maxed.", "info")
	elseif state.cash < cost then
		sendNotice(player, "The next upgrade costs $" .. tostring(cost) .. ".", "warn")
	else
		state.cash -= cost
		state.incomeLevel += 1
		sendNotice(player, "Income multiplier upgraded to " .. tostring(state.incomeLevel) .. "!", "good")
	end
	sendState(player)
end

local function clearCollection(player: Player, state: PlayerState)
	for slotIndex = 1, SLOT_COUNT do
		state.placed[slotIndex] = nil
		state.pending[slotIndex] = 0
		drawSlot(player, slotIndex)
	end
	table.clear(state.inventory)
end

local function rebirth(player: Player)
	local state = states[player.UserId]
	if not state then
		return
	end
	local cost = getRebirthCost(state)
	if cost == 0 then
		sendNotice(player, "Your rebirth track is complete. Keep building your collection!", "info")
	elseif state.cash < cost then
		sendNotice(player, "Rebirth needs $" .. tostring(cost) .. " in your wallet.", "warn")
	else
		clearCollection(player, state)
		state.rebirths += 1
		state.incomeLevel = 1
		state.cash = STARTING_CASH
		sendNotice(player, "Rebirth " .. tostring(state.rebirths) .. "! Your collection earns more next run.", "good")
	end
	sendState(player)
end

local function makePlot(index: number): Plot
	local angle = ((index - 1) / PLOT_COUNT) * math.pi * 2
	local center = Vector3.new(math.cos(angle) * 99, 0, math.sin(angle) * 99)
	local cframe = CFrame.lookAt(center, Vector3.new(0, 0, 0))
	local color = PLOT_COLORS[index]

	makePart(
		"PlotGlow",
		Vector3.new(39, 1.2, 39),
		cframe * CFrame.new(0, -0.35, 0),
		color,
		Enum.Material.Neon,
		world,
		nil
	)
	makePart(
		"PlotFloor",
		Vector3.new(36, 1, 36),
		cframe * CFrame.new(0, 0.35, 0),
		Color3.fromRGB(23, 28, 48),
		Enum.Material.Slate,
		world,
		nil
	)

	local signPart = makePart(
		"PlotSign",
		Vector3.new(13, 5, 0.8),
		cframe * CFrame.new(0, 4.2, -15.5),
		Color3.fromRGB(16, 18, 35),
		Enum.Material.Metal,
		world,
		nil
	)
	local sign = addBillboard(signPart, "OPEN PLOT  •  " .. tostring(index), color, 290, 58)
	sign.Name = "OwnerSign"

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "PlotSpawn_" .. tostring(index)
	spawn.Size = Vector3.new(8, 1, 6)
	spawn.CFrame = cframe * CFrame.new(0, 1.4, 11.5)
	spawn.Color = color
	spawn.Material = Enum.Material.Neon
	spawn.Transparency = 0.18
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Parent = world

	local slotParts: { BasePart } = {}
	local slotPositions = {
		Vector3.new(-8, 1.2, -7),
		Vector3.new(8, 1.2, -7),
		Vector3.new(-8, 1.2, 3),
		Vector3.new(8, 1.2, 3),
	}
	for slotIndex, offset in ipairs(slotPositions) do
		local pad = makePart(
			"CollectionPad_" .. tostring(index) .. "_" .. tostring(slotIndex),
			Vector3.new(7, 0.7, 7),
			cframe * CFrame.new(offset),
			color:Lerp(Color3.fromRGB(31, 37, 60), 0.38),
			Enum.Material.Neon,
			world,
			nil
		)
		pad.CanTouch = false
		table.insert(slotParts, pad)

		local prompt = addPrompt(pad, "Empty pad", "Collection slot " .. tostring(slotIndex), 0.25)
		prompt.Triggered:Connect(function(player)
			if plotByUser[player.UserId] ~= index then
				sendNotice(player, "That plot belongs to another collector.", "warn")
				return
			end
			local state = states[player.UserId]
			if not state then
				return
			end
			if state.placed[slotIndex] then
				collectSlot(player, slotIndex)
			elseif not placeInventoryItem(player, slotIndex) then
				sendNotice(player, "Buy a brainrot from the market first.", "info")
			end
		end)

		slotPrompts[index] = slotPrompts[index] or {}
		slotPrompts[index][slotIndex] = prompt
	end

	return {
		cframe = cframe,
		spawn = spawn,
		sign = sign,
		slots = slotParts,
		ownerId = nil,
	}
end

local function makeShopStand(index: number, position: Vector3)
	local angle = (index - 2) * math.rad(23)
	local base = makePart(
		"MarketStand_" .. tostring(index),
		Vector3.new(9, 1.2, 8),
		CFrame.new(position) * CFrame.Angles(0, angle, 0),
		Color3.fromRGB(31, 36, 65),
		Enum.Material.Metal,
		world,
		nil
	)
	local trim = makePart(
		"MarketTrim_" .. tostring(index),
		Vector3.new(9.4, 0.35, 8.4),
		base.CFrame * CFrame.new(0, 0.7, 0),
		PLOT_COLORS[index + 1],
		Enum.Material.Neon,
		world,
		nil
	)
	trim.CanCollide = false
	local label = addBillboard(base, "Restocking...", PLOT_COLORS[index + 1], 300, 58)
	local prompt = addPrompt(base, "Buy", "Market offer", 0.4)
	table.insert(shopStands, {
		base = base,
		prompt = prompt,
		label = label,
		model = nil,
	})

	prompt.Triggered:Connect(function(player)
		local offer = currentOffers()[index]
		if offer then
			purchaseBrainrot(player, offer.id)
		end
	end)
end

local function refreshShop()
	local offers = currentOffers()
	for index, stand in ipairs(shopStands) do
		local item = offers[index]
		if item then
			stand.label.Text = item.rarity .. "  •  " .. item.name .. "\n$" .. tostring(item.price) .. "  |  $" .. tostring(item.income) .. "/s"
			stand.label.TextColor3 = item.accent
			stand.prompt.ObjectText = item.name
			stand.prompt.ActionText = "Buy $" .. tostring(item.price)
			if stand.model then
				stand.model:Destroy()
			end
			stand.model = createBrainrotModel(item, stand.base.Position + Vector3.new(0, 1, 0), world)
		end
	end
	for _, player in ipairs(Players:GetPlayers()) do
		sendState(player)
	end
end

local function buildWorld()
	Lighting.ClockTime = 0.25
	Lighting.Brightness = 2.1
	Lighting.Ambient = Color3.fromRGB(61, 69, 108)
	Lighting.OutdoorAmbient = Color3.fromRGB(39, 45, 80)
	Lighting.ColorShift_Top = Color3.fromRGB(115, 92, 176)
	Lighting.EnvironmentDiffuseScale = 0.35
	Lighting.EnvironmentSpecularScale = 0.8
	Workspace.FallenPartsDestroyHeight = -50

	local atmosphere = Instance.new("Atmosphere")
	atmosphere.Color = Color3.fromRGB(156, 161, 255)
	atmosphere.Decay = Color3.fromRGB(50, 37, 101)
	atmosphere.Density = 0.27
	atmosphere.Glare = 0.18
	atmosphere.Haze = 1.15
	atmosphere.Parent = Lighting

	makePart(
		"NeonSnacklands",
		Vector3.new(280, 2, 280),
		CFrame.new(0, -1.6, 0),
		Color3.fromRGB(15, 19, 37),
		Enum.Material.Slate,
		world,
		nil
	)

	local central = makePart(
		"MarketIsland",
		Vector3.new(50, 1.5, 50),
		CFrame.new(0, -0.1, 0),
		Color3.fromRGB(25, 31, 55),
		Enum.Material.Metal,
		world,
		nil
	)
	makePart(
		"MarketHalo",
		Vector3.new(56, 0.55, 56),
		CFrame.new(0, -0.45, 0),
		Color3.fromRGB(105, 75, 255),
		Enum.Material.Neon,
		world,
		nil
	)

	local marketSign = makePart(
		"MarketSign",
		Vector3.new(29, 6, 1),
		CFrame.new(0, 10, -20),
		Color3.fromRGB(17, 18, 39),
		Enum.Material.Metal,
		world,
		nil
	)
	addBillboard(marketSign, "NEON SNACK MARKET", Color3.fromRGB(93, 239, 255), 390, 68)

	local statueBody = makePart(
		"MarketMascot",
		Vector3.new(6, 7, 6),
		CFrame.new(0, 4.4, 13),
		Color3.fromRGB(255, 130, 195),
		Enum.Material.Neon,
		world,
		Enum.PartType.Ball
	)
	statueBody.CanCollide = false
	statueBody.CanTouch = false
	makePart(
		"MascotCrown",
		Vector3.new(4, 1.5, 4),
		CFrame.new(0, 8.2, 13),
		Color3.fromRGB(255, 225, 110),
		Enum.Material.Neon,
		world,
		Enum.PartType.Ball
	).CanCollide = false
	addBillboard(statueBody, "THE ROT ORACLE", Color3.fromRGB(255, 224, 119), 270, 48)

	for index = 1, 3 do
		makeShopStand(index, Vector3.new((index - 2) * 13, 1.5, 2))
	end

	local hazardCenter = Vector3.new(0, 0.25, 0)
	for index = 1, 24 do
		local angle = (index / 24) * math.pi * 2
		local position = hazardCenter + Vector3.new(math.cos(angle) * 43, 0, math.sin(angle) * 43)
		local segment = makePart(
			"GlitchRingSegment_" .. tostring(index),
			Vector3.new(12, 0.8, 7),
			CFrame.new(position) * CFrame.Angles(0, -angle, 0),
			if index % 2 == 0 then Color3.fromRGB(255, 74, 128) else Color3.fromRGB(166, 61, 255),
			Enum.Material.Neon,
			world,
			nil
		)
		segment.Touched:Connect(function(hit)
			local character = hit:FindFirstAncestorOfClass("Model")
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if not humanoid or humanoid.Health <= 0 then
				return
			end
			local now = os.clock()
			if now - (hazardDebounce[humanoid] or 0) < 1.4 then
				return
			end
			hazardDebounce[humanoid] = now
			humanoid:TakeDamage(18)
			local player = Players:GetPlayerFromCharacter(character)
			if player then
				sendNotice(player, "GLITCH RING! Get across before it zaps again.", "warn")
			end
		end)
	end

	local ringLabel = makePart(
		"HazardSign",
		Vector3.new(24, 3.5, 0.8),
		CFrame.new(0, 3.1, -35),
		Color3.fromRGB(37, 18, 53),
		Enum.Material.Metal,
		world,
		nil
	)
	addBillboard(ringLabel, "GLITCH RING  •  KEEP MOVING", Color3.fromRGB(255, 102, 142), 350, 50)

	for index = 1, PLOT_COUNT do
		plots[index] = makePlot(index)
	end
	refreshShop()
end

local function assignPlot(player: Player): number?
	for index, plot in ipairs(plots) do
		if plot.ownerId == nil then
			plot.ownerId = player.UserId
			plotByUser[player.UserId] = index
			plot.sign.Text = player.DisplayName .. "'S PLOT"
			player.RespawnLocation = plot.spawn
			return index
		end
	end
	return nil
end

local function restorePlot(player: Player)
	local state = states[player.UserId]
	local plotIndex = plotByUser[player.UserId]
	if not state or not plotIndex then
		return
	end
	for slotIndex = 1, SLOT_COUNT do
		if state.placed[slotIndex] then
			drawSlot(player, slotIndex)
		end
	end
	updateAllPrompts(player)
end

local function releasePlot(player: Player)
	local plotIndex = plotByUser[player.UserId]
	local plot = plotIndex and plots[plotIndex]
	if plot then
		plot.ownerId = nil
		plot.sign.Text = "OPEN PLOT  •  " .. tostring(plotIndex)
		player.RespawnLocation = nil
	end

	local ownedModels = slotModels[player.UserId]
	if ownedModels then
		for _, model in pairs(ownedModels) do
			model:Destroy()
		end
	end
	slotModels[player.UserId] = nil
	plotByUser[player.UserId] = nil
end

local function onCharacterAdded(player: Player, character: Model)
	local root = character:WaitForChild("HumanoidRootPart", 10)
	local plotIndex = plotByUser[player.UserId]
	local plot = plotIndex and plots[plotIndex]
	if root and plot and player.Parent then
		character:PivotTo(plot.spawn.CFrame * CFrame.new(0, 4, -2))
	end
end

buildWorld()

local function onPlayerAdded(player: Player)
	local plotIndex = assignPlot(player)
	if not plotIndex then
		player:Kick("All twelve Rot Rush plots are busy. Please join a quieter server.")
		return
	end

	local state, canSave = loadState(player)
	if not player.Parent then
		return
	end
	states[player.UserId] = state
	dataReady[player.UserId] = canSave

	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(player, character)
	end)
	if player.Character then
		task.spawn(onCharacterAdded, player, player.Character)
	end

	restorePlot(player)
	sendState(player)
	sendNotice(player, "Welcome to Rot Rush. Buy a brainrot and start your snack empire!", "good")
end

actionRemote.OnServerEvent:Connect(function(player, action, argument)
	if typeof(action) ~= "string" then
		return
	end
	if action == "sync" then
		sendState(player)
	elseif action == "buy" and typeof(argument) == "string" then
		purchaseBrainrot(player, argument)
	elseif action == "collect" then
		collectAll(player)
	elseif action == "upgrade" then
		buyUpgrade(player)
	elseif action == "rebirth" then
		rebirth(player)
	end
end)

Players.PlayerAdded:Connect(function(player)
	task.spawn(onPlayerAdded, player)
end)

Players.PlayerRemoving:Connect(function(player)
	saveState(player)
	releasePlot(player)
	dataReady[player.UserId] = nil
	states[player.UserId] = nil
end)

for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, player)
end

task.spawn(function()
	while true do
		task.wait(1)
		if os.clock() - lastRestock >= RESTOCK_SECONDS then
			rotationIndex = (rotationIndex % #SHOP_ROTATIONS) + 1
			lastRestock = os.clock()
			refreshShop()
		end

		for _, player in ipairs(Players:GetPlayers()) do
			local state = states[player.UserId]
			if state then
				local multiplier = (1 + (state.incomeLevel - 1) * 0.3) * (1 + state.rebirths * 0.4)
				for slotIndex = 1, SLOT_COUNT do
					local itemId = state.placed[slotIndex]
					if itemId then
						state.pending[slotIndex] = (state.pending[slotIndex] or 0) + CATALOG[itemId].income * multiplier
					end
				end
				sendState(player)
			end
		end
	end
end)

game:BindToClose(function()
	local remaining = #Players:GetPlayers()
	if remaining == 0 then
		return
	end

	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(function()
			saveState(player)
			remaining -= 1
		end)
	end

	local deadline = os.clock() + 25
	while remaining > 0 and os.clock() < deadline do
		task.wait(0.1)
	end
end)
