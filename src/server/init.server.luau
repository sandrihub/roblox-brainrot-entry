local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local STORE = DataStoreService:GetDataStore("NeonNonsenseTycoon_v2")
local STARTING_CASH = 175
local PLOT_COUNT = 8
local MAX_BRAINROTS = 8
local MAX_REBIRTHS = 6
local SHIELD_DURATION = 18
local SHIELD_COOLDOWN = 42
local STEAL_COOLDOWN = 24

local CATALOG = {
	{ id = "capybara", name = "Moss Boss Capybara", rarity = "COMMON", cost = 30, income = 3, color = Color3.fromRGB(143, 166, 115), accent = Color3.fromRGB(243, 212, 137), shape = "round" },
	{ id = "goblin", name = "Espresso Goblino", rarity = "UNCOMMON", cost = 160, income = 12, color = Color3.fromRGB(112, 184, 112), accent = Color3.fromRGB(250, 116, 73), shape = "ears" },
	{ id = "pigeon", name = "Rizzler Pigeon", rarity = "RARE", cost = 650, income = 52, color = Color3.fromRGB(111, 157, 213), accent = Color3.fromRGB(255, 215, 83), shape = "wings" },
	{ id = "llama", name = "Tax Evader Llama", rarity = "EPIC", cost = 2800, income = 245, color = Color3.fromRGB(191, 131, 215), accent = Color3.fromRGB(255, 140, 113), shape = "ears" },
	{ id = "axolotl", name = "Microwave Axolotl", rarity = "LEGENDARY", cost = 12500, income = 1320, color = Color3.fromRGB(249, 133, 167), accent = Color3.fromRGB(88, 229, 224), shape = "gills" },
	{ id = "cheese", name = "CEO of Cheese", rarity = "MYTHIC", cost = 58000, income = 7800, color = Color3.fromRGB(255, 196, 60), accent = Color3.fromRGB(255, 247, 185), shape = "crown" },
	{ id = "frog", name = "Quantum Froggo", rarity = "CELESTIAL", cost = 265000, income = 48000, color = Color3.fromRGB(103, 226, 190), accent = Color3.fromRGB(169, 139, 255), shape = "halo" },
}

local itemById = {}
for _, item in ipairs(CATALOG) do
	itemById[item.id] = item
end

local remotes = Instance.new("Folder")
remotes.Name = "NonsenseRemotes"
remotes.Parent = ReplicatedStorage

local actionRemote = Instance.new("RemoteEvent")
actionRemote.Name = "Action"
actionRemote.Parent = remotes

local stateRemote = Instance.new("RemoteEvent")
stateRemote.Name = "State"
stateRemote.Parent = remotes

local world = Instance.new("Folder")
world.Name = "NeonNonsenseWorld"
world.Parent = Workspace

local plots = {}
local plotsByPlayer = {}
local playerData = {}
local lastAction = {}
local lastSteal = {}
local findItem
local recalculate
local buildState
local rebuildPlot
local sendState

local function makePart(parent, name, size, positionOrCFrame, color, material, shape)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = typeof(positionOrCFrame) == "CFrame" and positionOrCFrame or CFrame.new(positionOrCFrame)
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Shape = shape or Enum.PartType.Block
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function makeCorner(instance, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 10)
	corner.Parent = instance
end

local function makeBillboard(parent, text, color, width)
	local gui = Instance.new("BillboardGui")
	gui.Name = "NameTag"
	gui.Size = UDim2.fromOffset(width or 230, 60)
	gui.StudsOffset = Vector3.new(0, 3.1, 0)
	gui.AlwaysOnTop = true
	gui.MaxDistance = 150
	gui.Parent = parent

	local plate = Instance.new("Frame")
	plate.Size = UDim2.fromScale(1, 1)
	plate.BackgroundColor3 = Color3.fromRGB(23, 25, 45)
	plate.BackgroundTransparency = 0.08
	plate.Parent = gui
	makeCorner(plate, 12)

	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = 2
	stroke.Transparency = 0.12
	stroke.Parent = plate

	local label = Instance.new("TextLabel")
	label.Name = "Text"
	label.Size = UDim2.new(1, -12, 1, -8)
	label.Position = UDim2.fromOffset(6, 4)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = color
	label.TextStrokeTransparency = 0.72
	label.Font = Enum.Font.GothamBlack
	label.TextSize = 14
	label.TextWrapped = true
	label.Parent = plate
	return label
end

local function createCreature(item, position, owner, record)
	local model = Instance.new("Model")
	model.Name = item.name

	local body = makePart(model, "Body", Vector3.new(3.2, 2.45, 2.5), position + Vector3.new(0, 1.95, 0), item.color, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
	model.PrimaryPart = body
	makePart(model, "Muzzle", Vector3.new(1.55, 1.05, 0.62), position + Vector3.new(0, 1.75, -1.08), item.accent, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
	makePart(model, "LeftEye", Vector3.new(0.31, 0.39, 0.2), position + Vector3.new(-0.43, 2.22, -1.47), Color3.fromRGB(25, 25, 42), Enum.Material.Neon, Enum.PartType.Ball)
	makePart(model, "RightEye", Vector3.new(0.31, 0.39, 0.2), position + Vector3.new(0.43, 2.22, -1.47), Color3.fromRGB(25, 25, 42), Enum.Material.Neon, Enum.PartType.Ball)
	makePart(model, "LeftFoot", Vector3.new(0.86, 0.42, 0.9), position + Vector3.new(-0.83, 0.67, -0.05), item.accent, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
	makePart(model, "RightFoot", Vector3.new(0.86, 0.42, 0.9), position + Vector3.new(0.83, 0.67, -0.05), item.accent, Enum.Material.SmoothPlastic, Enum.PartType.Ball)

	if item.shape == "wings" then
		makePart(model, "LeftWing", Vector3.new(0.42, 1.55, 1.65), position + Vector3.new(-1.68, 1.92, 0.12), item.accent, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
		makePart(model, "RightWing", Vector3.new(0.42, 1.55, 1.65), position + Vector3.new(1.68, 1.92, 0.12), item.accent, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
	elseif item.shape == "ears" then
		makePart(model, "LeftEar", Vector3.new(0.54, 1.38, 0.54), position + Vector3.new(-0.94, 3.0, -0.7), item.accent, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
		makePart(model, "RightEar", Vector3.new(0.54, 1.38, 0.54), position + Vector3.new(0.94, 3.0, -0.7), item.accent, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
	elseif item.shape == "gills" then
		for side = -1, 1, 2 do
			for index = 1, 3 do
				makePart(model, "Gills" .. side .. "_" .. index, Vector3.new(0.25, 0.42, 0.32), position + Vector3.new(side * 1.72, 1.95 + index * 0.38, -0.28), item.accent, Enum.Material.Neon, Enum.PartType.Ball)
			end
		end
	elseif item.shape == "crown" then
		makePart(model, "CheeseCrown", Vector3.new(2.1, 0.62, 1.55), position + Vector3.new(0, 3.1, 0), item.accent, Enum.Material.Neon, Enum.PartType.Cylinder)
	elseif item.shape == "halo" then
		local halo = makePart(model, "QuantumHalo", Vector3.new(2.3, 0.28, 2.3), position + Vector3.new(0, 3.35, 0), item.accent, Enum.Material.Neon, Enum.PartType.Cylinder)
		halo.Orientation = Vector3.new(0, 0, 90)
	else
		makePart(model, "SignatureHat", Vector3.new(2.2, 0.42, 1.8), position + Vector3.new(0, 3.0, 0), item.accent, Enum.Material.Neon, Enum.PartType.Cylinder)
	end

	local label = makeBillboard(body, item.name .. "\n" .. item.rarity .. "  |  +$" .. item.income .. "/SEC", item.accent, 240)
	label.Name = "CreatureLabel"

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "CreaturePrompt"
	prompt.ActionText = "Collect / Swipe"
	prompt.ObjectText = item.name
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.HoldDuration = 0.45
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.Parent = body
	prompt.Triggered:Connect(function(player)
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if not root or (root.Position - body.Position).Magnitude > prompt.MaxActivationDistance + 2 then
			return
		end

		local ownerData = playerData[owner]
		if not ownerData or not ownerData.loaded then
			return
		end
		if player == owner then
			local payout = math.floor(record.bank)
			if payout > 0 then
				record.bank = 0
				ownerData.cash += payout
				ownerData.message = "Collected $" .. payout .. " from " .. item.name .. "."
				sendState(owner)
			end
			return
		end

		local thiefData = playerData[player]
		if not thiefData or not thiefData.loaded then
			return
		end
		local ownerPlot = plotsByPlayer[owner]
		local now = os.clock()
		if ownerPlot and ownerData.shieldUntil > now then
			thiefData.message = owner.DisplayName .. "'s vault is shielded. Try again when it drops."
			sendState(player)
			return
		end
		if #ownerData.owned <= 1 then
			thiefData.message = "Leave the rival one brainrot to keep their plot alive."
			sendState(player)
			return
		end
		if #thiefData.owned >= MAX_BRAINROTS then
			thiefData.message = "Your display is full. Rebirth to make room."
			sendState(player)
			return
		end
		if now - (lastSteal[player] or -STEAL_COOLDOWN) < STEAL_COOLDOWN then
			thiefData.message = "Sticky fingers recharge in " .. math.ceil(STEAL_COOLDOWN - (now - (lastSteal[player] or 0))) .. "s."
			sendState(player)
			return
		end

		local ownedIndex
		for index, ownedRecord in ipairs(ownerData.owned) do
			if ownedRecord == record then
				ownedIndex = index
				break
			end
		end
		if not ownedIndex then
			return
		end

		lastSteal[player] = now
		table.remove(ownerData.owned, ownedIndex)
		table.insert(thiefData.owned, { item = record.item, bank = 0 })
		ownerData.message = player.DisplayName .. " swiped your " .. item.name .. "!"
		thiefData.message = "Yoink! " .. item.name .. " is now yours."
		recalculate(ownerData)
		recalculate(thiefData)
		rebuildPlot(owner)
		rebuildPlot(player)
		sendState(owner)
		sendState(player)
	end)

	model.Parent = world
	return model
end

local function point(plot, offset)
	return plot.cframe:PointToWorldSpace(offset)
end

local function refreshPlot(plot)
	local owner = plot.owner
	local data = owner and playerData[owner]
	local active = data and data.shieldUntil > os.clock() or false
	plot.folder:SetAttribute("Shielded", active)
	plot.shieldField.Transparency = active and 0.84 or 1
	plot.shieldField.Color = Color3.fromRGB(78, 221, 255)
	local label = plot.signLabel
	if not label then
		return
	end
	if not owner then
		label.Text = string.format("VACANT PLOT %02d\nCLAIM YOUR CHAOS", plot.index)
		label.TextColor3 = Color3.fromRGB(245, 249, 255)
	elseif active then
		label.Text = string.upper(owner.DisplayName) .. "'S VAULT\nSHIELDED"
		label.TextColor3 = Color3.fromRGB(125, 237, 255)
	else
		label.Text = string.upper(owner.DisplayName) .. "'S PLOT\n" .. tostring(data and #data.owned or 0) .. " / " .. MAX_BRAINROTS .. " BRAINROTS"
		label.TextColor3 = Color3.fromRGB(255, 224, 137)
	end
end

local function createPlot(index)
	local angle = (index - 1) * (math.pi * 2 / PLOT_COUNT)
	local center = Vector3.new(math.cos(angle) * 102, 0, math.sin(angle) * 102)
	local yaw = math.pi / 2 - angle
	local plot = {
		index = index,
		center = center,
		cframe = CFrame.new(center) * CFrame.Angles(0, yaw, 0),
		owner = nil,
		models = {},
	}
	plots[index] = plot

	local folder = Instance.new("Folder")
	folder.Name = string.format("Plot%02d", index)
	folder:SetAttribute("PlotIndex", index)
	folder.Parent = world
	plot.folder = folder

	makePart(folder, "Foundation", Vector3.new(62, 1.2, 48), plot.cframe * CFrame.new(0, 0, 0), Color3.fromRGB(44, 56, 83), Enum.Material.Slate)
	makePart(folder, "InnerFloor", Vector3.new(58, 0.25, 44), plot.cframe * CFrame.new(0, 0.72, 0), Color3.fromRGB(94, 126, 126), Enum.Material.SmoothPlastic)
	makePart(folder, "BackWall", Vector3.new(60, 9, 1.4), plot.cframe * CFrame.new(0, 5, 22.8), Color3.fromRGB(50, 64, 95), Enum.Material.Slate)
	makePart(folder, "LeftWall", Vector3.new(1.4, 9, 47), plot.cframe * CFrame.new(-29.5, 5, 0), Color3.fromRGB(50, 64, 95), Enum.Material.Slate)
	makePart(folder, "RightWall", Vector3.new(1.4, 9, 47), plot.cframe * CFrame.new(29.5, 5, 0), Color3.fromRGB(50, 64, 95), Enum.Material.Slate)
	makePart(folder, "FrontTrim", Vector3.new(60, 0.55, 1.2), plot.cframe * CFrame.new(0, 1.35, -22.7), Color3.fromRGB(69, 218, 210), Enum.Material.Neon)
	local sign = makePart(folder, "PlotSign", Vector3.new(14, 4.8, 0.9), plot.cframe * CFrame.new(0, 7.4, -23.2), Color3.fromRGB(40, 35, 78), Enum.Material.Neon)
	plot.signLabel = makeBillboard(sign, "VACANT PLOT", Color3.fromRGB(245, 249, 255), 270)

	local shield = makePart(folder, "ShieldField", Vector3.new(58, 34, 46), plot.cframe * CFrame.new(0, 7, 0), Color3.fromRGB(78, 221, 255), Enum.Material.ForceField, Enum.PartType.Ball)
	shield.CanCollide = false
	shield.CastShadow = false
	shield.Transparency = 1
	plot.shieldField = shield

	local slotOffsets = {
		Vector3.new(-18, 0.915, -12), Vector3.new(-6, 0.915, -12), Vector3.new(6, 0.915, -12), Vector3.new(18, 0.915, -12),
		Vector3.new(-18, 0.915, 8), Vector3.new(-6, 0.915, 8), Vector3.new(6, 0.915, 8), Vector3.new(18, 0.915, 8),
	}
	plot.slotPositions = {}
	for slotIndex, offset in ipairs(slotOffsets) do
		local slotPosition = point(plot, offset)
		plot.slotPositions[slotIndex] = slotPosition
		local pad = makePart(folder, "BrainrotPad" .. slotIndex, Vector3.new(9.4, 0.45, 9.4), CFrame.new(slotPosition + Vector3.new(0, 0.235, 0)), Color3.fromRGB(97, 90, 129), Enum.Material.Neon)
		pad.Transparency = 0.1
	end

	plot.folder:SetAttribute("OwnerUserId", 0)
	return plot
end

local function buildWorld()
	Lighting.ClockTime = 17.2
	Lighting.Brightness = 2.2
	Lighting.Ambient = Color3.fromRGB(116, 117, 153)
	Lighting.OutdoorAmbient = Color3.fromRGB(150, 151, 185)
	Lighting.EnvironmentDiffuseScale = 0.55
	Lighting.EnvironmentSpecularScale = 0.55

	local atmosphere = Instance.new("Atmosphere")
	atmosphere.Name = "NeonDusk"
	atmosphere.Density = 0.24
	atmosphere.Offset = 0.12
	atmosphere.Color = Color3.fromRGB(188, 195, 255)
	atmosphere.Decay = Color3.fromRGB(102, 74, 160)
	atmosphere.Glare = 0.18
	atmosphere.Haze = 1.1
	atmosphere.Parent = Lighting

	makePart(world, "FloatingIsland", Vector3.new(360, 12, 360), Vector3.new(0, -6.5, 0), Color3.fromRGB(49, 92, 117), Enum.Material.Grass)
	makePart(world, "IslandTop", Vector3.new(348, 1, 348), Vector3.new(0, -0.25, 0), Color3.fromRGB(70, 127, 120), Enum.Material.Grass)
	makePart(world, "BazaarPlaza", Vector3.new(68, 1.3, 68), Vector3.new(0, 0.65, 0), Color3.fromRGB(53, 49, 92), Enum.Material.Slate)

	local centerDisc = makePart(world, "MarketNeonRing", Vector3.new(76, 0.35, 76), Vector3.new(0, 1.45, 0), Color3.fromRGB(61, 216, 217), Enum.Material.Neon, Enum.PartType.Cylinder)
	centerDisc.Orientation = Vector3.new(0, 0, 90)
	makePart(world, "MarketStage", Vector3.new(44, 1.1, 44), Vector3.new(0, 1.75, 0), Color3.fromRGB(79, 70, 125), Enum.Material.SmoothPlastic)
	local kiosk = makePart(world, "RarityKiosk", Vector3.new(20, 7, 9), Vector3.new(0, 5.2, -15), Color3.fromRGB(36, 41, 75), Enum.Material.SmoothPlastic)
	makePart(world, "KioskRoof", Vector3.new(24, 1, 12), Vector3.new(0, 9.2, -15), Color3.fromRGB(255, 125, 91), Enum.Material.Neon)
	makeBillboard(kiosk, "THE ODDITY EXCHANGE\n7 RARITIES • 1 VERY BAD IDEA", Color3.fromRGB(255, 227, 151), 340)
	local billboard = makePart(world, "WorldTitle", Vector3.new(26, 10, 1.4), Vector3.new(0, 12.5, 21), Color3.fromRGB(38, 37, 75), Enum.Material.Neon)
	makeBillboard(billboard, "NEON NONSENSE\nTYCOON", Color3.fromRGB(128, 239, 230), 360)

	for index = 1, PLOT_COUNT do
		createPlot(index)
	end

	for index = 1, 20 do
		local angle = index * math.pi / 10
		local radius = 30
		local position = Vector3.new(math.cos(angle) * radius, 2.15, math.sin(angle) * radius)
		local orb = makePart(world, "PlazaPrism" .. index, Vector3.new(1.6, 2.2, 1.6), position, Color3.fromHSV(index / 20, 0.65, 1), Enum.Material.Neon, Enum.PartType.Ball)
		orb.CanCollide = false
		local light = Instance.new("PointLight")
		light.Color = orb.Color
		light.Range = 9
		light.Brightness = 0.6
		light.Parent = orb
	end

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "PlazaSpawn"
	spawn.Size = Vector3.new(12, 1, 12)
	spawn.Position = Vector3.new(0, 1.45, 6)
	spawn.Color = Color3.fromRGB(255, 206, 93)
	spawn.Material = Enum.Material.Neon
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Parent = world

	for index = 1, 8 do
		local angle = index * math.pi / 4
		local position = Vector3.new(math.cos(angle) * 166, 4, math.sin(angle) * 166)
		local rock = makePart(world, "FloatingRock" .. index, Vector3.new(15, 8, 13), position, Color3.fromRGB(61, 76, 107), Enum.Material.Slate, Enum.PartType.Ball)
		rock.CanCollide = false
	end
end

local function getPlot(player)
	for _, plot in ipairs(plots) do
		if plot.owner == player then
			return plot
		end
	end
	return nil
end

findItem = function(itemId)
	return itemById[itemId]
end

recalculate = function(data)
	local baseIncome = 0
	for _, record in ipairs(data.owned) do
		local item = findItem(record.item)
		if item then
			baseIncome += item.income
		end
	end
	data.income = math.floor(baseIncome * (1 + data.upgrades * 0.35) * (2 ^ data.rebirths))
end

rebuildPlot = function(player)
	local plot = getPlot(player)
	local data = playerData[player]
	if not plot or not data then
		return
	end
	for _, model in ipairs(plot.models) do
		model:Destroy()
	end
	table.clear(plot.models)

	for index, record in ipairs(data.owned) do
		local item = findItem(record.item)
		local position = plot.slotPositions[index]
		if item and position then
			table.insert(plot.models, createCreature(item, position, player, record))
		end
	end
	plot.folder:SetAttribute("OwnerUserId", player.UserId)
	refreshPlot(plot)
end

buildState = function(player)
	local data = playerData[player]
	if not data then
		return nil
	end
	local owned = {}
	for _, record in ipairs(data.owned) do
		local item = findItem(record.item)
		if item then
			table.insert(owned, { id = item.id, name = item.name, rarity = item.rarity, bank = math.floor(record.bank), income = item.income })
		end
	end
	local now = os.clock()
	return {
		cash = math.floor(data.cash),
		bank = math.floor(data.bank),
		owned = owned,
		upgrades = data.upgrades,
		rebirths = data.rebirths,
		income = data.income,
		plot = getPlot(player) and getPlot(player).index or 0,
		message = data.message or "",
		catalog = CATALOG,
		shieldRemaining = math.max(0, math.ceil(data.shieldUntil - now)),
		shieldCooldown = math.max(0, math.ceil(data.shieldReadyAt - now)),
		stealCooldown = math.max(0, math.ceil(STEAL_COOLDOWN - (now - (lastSteal[player] or -STEAL_COOLDOWN)))),
	}
end

sendState = function(player)
	local state = buildState(player)
	if state and player.Parent then
		stateRemote:FireClient(player, state)
	end
end

local function savePlayer(player)
	local data = playerData[player]
	if not data or not data.loaded or not data.canSave then
		return
	end
	local owned = {}
	for _, record in ipairs(data.owned) do
		table.insert(owned, { item = record.item, bank = math.floor(record.bank) })
	end
	local payload = {
		cash = math.floor(data.cash),
		bank = math.floor(data.bank),
		owned = owned,
		upgrades = data.upgrades,
		rebirths = data.rebirths,
	}
	local success, err = pcall(function()
		STORE:SetAsync("player_" .. player.UserId, payload)
	end)
	if not success then
		warn("Could not save Neon Nonsense progress for " .. player.Name .. ": " .. tostring(err))
	end
end

local function loadPlayer(player, data)
	local success, saved = pcall(function()
		return STORE:GetAsync("player_" .. player.UserId)
	end)
	if success and type(saved) == "table" then
		data.cash = math.max(0, math.floor(tonumber(saved.cash) or STARTING_CASH))
		data.bank = math.max(0, math.floor(tonumber(saved.bank) or 0))
		data.upgrades = math.clamp(math.floor(tonumber(saved.upgrades) or 0), 0, 5)
		data.rebirths = math.clamp(math.floor(tonumber(saved.rebirths) or 0), 0, MAX_REBIRTHS)
		if type(saved.owned) == "table" then
			for _, entry in ipairs(saved.owned) do
				if #data.owned >= MAX_BRAINROTS then
					break
				end
				if type(entry) == "table" and type(entry.item) == "string" and itemById[entry.item] then
					table.insert(data.owned, {
						item = entry.item,
						bank = math.max(0, math.floor(tonumber(entry.bank) or 0)),
					})
				end
			end
		end
		if #data.owned == 0 then
			table.insert(data.owned, { item = "capybara", bank = 0 })
		end
		data.canSave = true
		data.message = "Welcome back. Your oddities have been busy."
	elseif success then
		table.insert(data.owned, { item = "capybara", bank = 0 })
		data.canSave = true
		data.message = "Your Moss Boss is ready. Head to the Oddity Exchange."
	else
		data.canSave = false
		data.message = "Progress storage is offline; this session will not overwrite your save."
		warn("Could not load Neon Nonsense progress for " .. player.Name .. ": " .. tostring(saved))
	end
	recalculate(data)
	data.loaded = true
	rebuildPlot(player)
	sendState(player)
end

local function addBrainrot(player, item)
	local data = playerData[player]
	if not data or #data.owned >= MAX_BRAINROTS then
		return false
	end
	table.insert(data.owned, { item = item.id, bank = 0 })
	recalculate(data)
	rebuildPlot(player)
	return true
end

local function processAction(player, payload)
	local data = playerData[player]
	if not data or not data.loaded or type(payload) ~= "table" or type(payload.action) ~= "string" then
		return
	end
	if not getPlot(player) then
		data.message = "This server is full. Find a server with an open plot."
		sendState(player)
		return
	end
	local now = os.clock()
	if now - (lastAction[player] or -1) < 0.18 then
		return
	end
	lastAction[player] = now

	if payload.action == "buy" then
		local item = type(payload.item) == "string" and findItem(payload.item) or nil
		if not item then
			return
		end
		if #data.owned >= MAX_BRAINROTS then
			data.message = "All eight display pads are full."
		elseif data.cash < item.cost then
			data.message = "You need $" .. item.cost .. " for " .. item.name .. "."
		else
			data.cash -= item.cost
			addBrainrot(player, item)
			data.message = "New oddity acquired: " .. item.name .. "."
		end
	elseif payload.action == "collect" then
		local total = data.bank
		data.bank = 0
		for _, record in ipairs(data.owned) do
			total += math.floor(record.bank)
			record.bank = 0
		end
		data.cash += total
		data.message = total > 0 and ("Collected $" .. total .. ". Put it straight back to work.") or "Your oddities are still cooking up cash."
	elseif payload.action == "upgrade" then
		local cost = 800 * (2 ^ data.upgrades)
		if data.upgrades >= 5 then
			data.message = "The research lab is fully tuned."
		elseif data.cash < cost then
			data.message = "Lab calibration costs $" .. cost .. "."
		else
			data.cash -= cost
			data.upgrades += 1
			recalculate(data)
			data.message = "Research lab upgraded. Every oddity earns 35% more."
		end
	elseif payload.action == "rebirth" then
		if data.rebirths >= MAX_REBIRTHS then
			data.message = "You have reached the final rebirth."
		elseif data.cash < 35000 or #data.owned < 5 then
			data.message = "Rebirth requires $35,000 and five oddities."
		else
			data.cash = 300
			data.bank = 0
			data.owned = {}
			data.upgrades = 0
			data.rebirths += 1
			data.shieldUntil = 0
			data.shieldReadyAt = 0
			table.insert(data.owned, { item = "capybara", bank = 0 })
			recalculate(data)
			rebuildPlot(player)
			data.message = "REBIRTH! A Moss Boss returns; all future income is doubled."
		end
	elseif payload.action == "shield" then
		if data.shieldUntil > now then
			data.message = "Your vault is already shielded."
		elseif data.shieldReadyAt > now then
			data.message = "Shield recharges in " .. math.ceil(data.shieldReadyAt - now) .. "s."
		else
			data.shieldUntil = now + SHIELD_DURATION
			data.shieldReadyAt = now + SHIELD_COOLDOWN
			data.message = "VAULT LOCKED for 18 seconds. Get home before it drops."
			local plot = getPlot(player)
			if plot then
				refreshPlot(plot)
			end
		end
	end
	sendState(player)
end

buildWorld()

for _, plot in ipairs(plots) do
	plot.folder:SetAttribute("PlotIndex", plot.index)
end

Players.PlayerAdded:Connect(function(player)
	local plot
	for _, candidate in ipairs(plots) do
		if not candidate.owner then
			plot = candidate
			candidate.owner = player
			break
		end
	end
	local data = {
		cash = STARTING_CASH,
		bank = 0,
		owned = {},
		upgrades = 0,
		rebirths = 0,
		income = 0,
		loaded = false,
		canSave = false,
		shieldUntil = 0,
		shieldReadyAt = 0,
		message = plot and "Welcome to Neon Nonsense. Your first oddity is waiting." or "Server plots are full. Try another server.",
	}
	playerData[player] = data
	if plot then
		plot.folder:SetAttribute("OwnerUserId", player.UserId)
		plotsByPlayer[player] = plot
		refreshPlot(plot)
		local function placeCharacter(character)
			task.wait(0.15)
			if plot.owner == player and character.Parent then
				local arrival = point(plot, Vector3.new(0, 5, -17))
				character:PivotTo(CFrame.lookAt(arrival, point(plot, Vector3.new(0, 3, 0))))
			end
		end
		if player.Character then
			task.spawn(placeCharacter, player.Character)
		end
		player.CharacterAdded:Connect(placeCharacter)
	end
	task.spawn(loadPlayer, player, data)
end)

Players.PlayerRemoving:Connect(function(player)
	savePlayer(player)
	local plot = getPlot(player)
	if plot then
		plot.owner = nil
		plotsByPlayer[player] = nil
		for _, model in ipairs(plot.models) do
			model:Destroy()
		end
		table.clear(plot.models)
		plot.folder:SetAttribute("OwnerUserId", 0)
		refreshPlot(plot)
	end
	playerData[player] = nil
	lastAction[player] = nil
	lastSteal[player] = nil
end)

actionRemote.OnServerEvent:Connect(processAction)

task.spawn(function()
	while true do
		task.wait(1)
		for player, data in pairs(playerData) do
			if data.loaded and player.Parent then
				for _, record in ipairs(data.owned) do
					local item = findItem(record.item)
					if item then
						record.bank += item.income * (1 + data.upgrades * 0.35) * (2 ^ data.rebirths)
					end
				end
				local plot = getPlot(player)
				if plot then
					refreshPlot(plot)
				end
				sendState(player)
			end
		end
	end
end)

task.spawn(function()
	while true do
		task.wait(90)
		for player, data in pairs(playerData) do
			if data.loaded and player.Parent then
				savePlayer(player)
			end
		end
	end
end)

game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		savePlayer(player)
	end
end)
