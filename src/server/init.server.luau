local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local STARTING_CASH = 175
local MAX_CASH = 1000000000000
local SLOT_COUNT = 5
local REBIRTH_LIMIT = 20
local REBIRTH_BASE_COST = 50000
local DATA_STORE = DataStoreService:GetDataStore("NeonNonsense_v1")

local CATALOG = {
	{ id = "capybara", name = "Moss Boss Capybara", rarity = "COMMON", cost = 45, income = 4, body = Color3.fromRGB(144, 164, 119), accent = Color3.fromRGB(245, 206, 119), shape = "cap" },
	{ id = "goblin", name = "Espresso Goblino", rarity = "UNCOMMON", cost = 180, income = 15, body = Color3.fromRGB(115, 188, 125), accent = Color3.fromRGB(248, 116, 79), shape = "ears" },
	{ id = "pigeon", name = "Rizzler Pigeon", rarity = "RARE", cost = 700, income = 58, body = Color3.fromRGB(109, 153, 212), accent = Color3.fromRGB(255, 215, 83), shape = "wings" },
	{ id = "llama", name = "Tax Evader Llama", rarity = "EPIC", cost = 3200, income = 280, body = Color3.fromRGB(189, 133, 214), accent = Color3.fromRGB(255, 135, 117), shape = "ears" },
	{ id = "axolotl", name = "Microwave Axolotl", rarity = "LEGENDARY", cost = 15000, income = 1550, body = Color3.fromRGB(246, 132, 168), accent = Color3.fromRGB(85, 228, 224), shape = "gills" },
	{ id = "cheese", name = "CEO of Cheese", rarity = "MYTHIC", cost = 72000, income = 9400, body = Color3.fromRGB(255, 194, 58), accent = Color3.fromRGB(255, 244, 180), shape = "crown" },
	{ id = "frog", name = "Quantum Froggo", rarity = "CELESTIAL", cost = 350000, income = 64000, body = Color3.fromRGB(99, 224, 184), accent = Color3.fromRGB(176, 142, 255), shape = "halo" },
}

local ITEMS = {}
for _, item in ipairs(CATALOG) do
	ITEMS[item.id] = item
end

local oldRemotes = ReplicatedStorage:FindFirstChild("NonsenseRemotes")
if oldRemotes then
	oldRemotes:Destroy()
end

local remotes = Instance.new("Folder")
remotes.Name = "NonsenseRemotes"
remotes.Parent = ReplicatedStorage

local actionRemote = Instance.new("RemoteEvent")
actionRemote.Name = "Action"
actionRemote.Parent = remotes

local notifyRemote = Instance.new("RemoteEvent")
notifyRemote.Name = "Notify"
notifyRemote.Parent = remotes

local oldWorld = Workspace:FindFirstChild("NeonNonsenseWorld")
if oldWorld then
	oldWorld:Destroy()
end

local world = Instance.new("Folder")
world.Name = "NeonNonsenseWorld"
world.Parent = Workspace

local plotRecords = {}
local playerRecords = {}
local actionTimes = {}
local hazardTimes = {}

local function makePart(parent, name, size, position, color, material, shape, canCollide)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Shape = shape or Enum.PartType.Block
	part.Anchored = true
	part.CanCollide = canCollide ~= false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function addCorner(instance, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 10)
	corner.Parent = instance
end

local function addBillboard(parent, text, color, width)
	local gui = Instance.new("BillboardGui")
	gui.Name = "Nameplate"
	gui.Size = UDim2.fromOffset(width or 210, 54)
	gui.StudsOffset = Vector3.new(0, 3.2, 0)
	gui.AlwaysOnTop = true
	gui.MaxDistance = 150
	gui.Parent = parent

	local plate = Instance.new("Frame")
	plate.Size = UDim2.fromScale(1, 1)
	plate.BackgroundColor3 = Color3.fromRGB(27, 24, 48)
	plate.BackgroundTransparency = 0.08
	plate.Parent = gui
	addCorner(plate, 12)

	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = 2
	stroke.Parent = plate

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -12, 1, -8)
	label.Position = UDim2.fromOffset(6, 4)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = color
	label.Font = Enum.Font.GothamBlack
	label.TextSize = 13
	label.TextWrapped = true
	label.Parent = plate
	return label
end

local function addCreature(parent, item, position)
	local model = Instance.new("Model")
	model.Name = item.name

	local body = makePart(model, "Body", Vector3.new(3, 2.3, 2.3), position + Vector3.new(0, 1.65, 0), item.body, Enum.Material.SmoothPlastic, Enum.PartType.Ball, false)
	model.PrimaryPart = body
	makePart(model, "Muzzle", Vector3.new(1.45, 0.9, 0.7), position + Vector3.new(0, 1.43, -1.02), item.accent, Enum.Material.SmoothPlastic, Enum.PartType.Ball, false)
	makePart(model, "LeftEye", Vector3.new(0.28, 0.34, 0.16), position + Vector3.new(-0.4, 1.93, -1.36), Color3.fromRGB(29, 25, 45), Enum.Material.Neon, Enum.PartType.Ball, false)
	makePart(model, "RightEye", Vector3.new(0.28, 0.34, 0.16), position + Vector3.new(0.4, 1.93, -1.36), Color3.fromRGB(29, 25, 45), Enum.Material.Neon, Enum.PartType.Ball, false)
	makePart(model, "LeftFoot", Vector3.new(0.75, 0.38, 0.72), position + Vector3.new(-0.72, 0.52, -0.02), item.accent, Enum.Material.SmoothPlastic, Enum.PartType.Ball, false)
	makePart(model, "RightFoot", Vector3.new(0.75, 0.38, 0.72), position + Vector3.new(0.72, 0.52, -0.02), item.accent, Enum.Material.SmoothPlastic, Enum.PartType.Ball, false)

	if item.shape == "wings" then
		makePart(model, "LeftWing", Vector3.new(0.35, 1.2, 1.4), position + Vector3.new(-1.48, 1.62, 0.08), item.accent, Enum.Material.SmoothPlastic, Enum.PartType.Ball, false)
		makePart(model, "RightWing", Vector3.new(0.35, 1.2, 1.4), position + Vector3.new(1.48, 1.62, 0.08), item.accent, Enum.Material.SmoothPlastic, Enum.PartType.Ball, false)
	elseif item.shape == "ears" then
		makePart(model, "LeftEar", Vector3.new(0.48, 1.15, 0.48), position + Vector3.new(-0.8, 2.7, -0.42), item.accent, Enum.Material.SmoothPlastic, Enum.PartType.Ball, false)
		makePart(model, "RightEar", Vector3.new(0.48, 1.15, 0.48), position + Vector3.new(0.8, 2.7, -0.42), item.accent, Enum.Material.SmoothPlastic, Enum.PartType.Ball, false)
	elseif item.shape == "gills" then
		for side = -1, 1, 2 do
			for index = 1, 3 do
				makePart(model, "Gill" .. side .. "_" .. index, Vector3.new(0.2, 0.34, 0.28), position + Vector3.new(side * 1.55, 1.45 + index * 0.3, -0.16), item.accent, Enum.Material.Neon, Enum.PartType.Ball, false)
			end
		end
	elseif item.shape == "crown" then
		makePart(model, "CheeseCrown", Vector3.new(1.8, 0.44, 1.35), position + Vector3.new(0, 2.8, 0), item.accent, Enum.Material.Neon, Enum.PartType.Cylinder, false)
	elseif item.shape == "halo" then
		local halo = makePart(model, "QuantumHalo", Vector3.new(2, 0.24, 2), position + Vector3.new(0, 3.03, 0), item.accent, Enum.Material.Neon, Enum.PartType.Cylinder, false)
		halo.Orientation = Vector3.new(0, 0, 90)
	else
		makePart(model, "MossyBeret", Vector3.new(1.9, 0.38, 1.5), position + Vector3.new(0, 2.72, 0), item.accent, Enum.Material.Neon, Enum.PartType.Cylinder, false)
	end

	addBillboard(body, item.name .. "\n" .. item.rarity .. "  |  +$" .. item.income .. "/SEC", item.accent, 240)
	model.Parent = parent
	return model
end

local function addLight(part, color, brightness, range)
	local light = Instance.new("PointLight")
	light.Color = color
	light.Brightness = brightness
	light.Range = range
	light.Parent = part
end

local function setupLighting()
	Lighting.ClockTime = 19
	Lighting.Brightness = 2.2
	Lighting.Ambient = Color3.fromRGB(69, 61, 102)
	Lighting.OutdoorAmbient = Color3.fromRGB(87, 79, 126)
	Lighting.FogColor = Color3.fromRGB(43, 35, 79)
	Lighting.FogEnd = 420

	local atmosphere = Instance.new("Atmosphere")
	atmosphere.Name = "NeonDuskAtmosphere"
	atmosphere.Color = Color3.fromRGB(196, 173, 255)
	atmosphere.Decay = Color3.fromRGB(81, 64, 151)
	atmosphere.Density = 0.2
	atmosphere.Glare = 0.2
	atmosphere.Haze = 1.2
	atmosphere.Parent = Lighting

	local bloom = Instance.new("BloomEffect")
	bloom.Name = "NeonBloom"
	bloom.Intensity = 0.35
	bloom.Size = 24
	bloom.Threshold = 1.4
	bloom.Parent = Lighting
end

local function makePlot(index, center, northSide)
	local model = Instance.new("Model")
	model.Name = "Plot" .. index
	model:SetAttribute("OwnerUserId", 0)
	model.Parent = world

	local base = makePart(model, "PlotBase", Vector3.new(38, 1.5, 34), center + Vector3.new(0, 0.25, 0), Color3.fromRGB(45, 44, 77), Enum.Material.SmoothPlastic)
	makePart(model, "FrontTrim", Vector3.new(38, 0.35, 0.6), center + Vector3.new(0, 1.1, northSide and 17 or -17), Color3.fromRGB(91, 233, 221), Enum.Material.Neon, nil, false)
	makePart(model, "BackTrim", Vector3.new(38, 0.35, 0.6), center + Vector3.new(0, 1.1, northSide and -17 or 17), Color3.fromRGB(166, 112, 250), Enum.Material.Neon, nil, false)

	local sign = makePart(model, "PlotSign", Vector3.new(1.3, 5.5, 1.3), center + Vector3.new(0, 3.5, northSide and -13 or 13), Color3.fromRGB(60, 53, 96), Enum.Material.Metal, Enum.PartType.Cylinder)
	sign.Orientation = Vector3.new(0, 0, 90)
	addBillboard(sign, "OPEN PLOT " .. index, Color3.fromRGB(108, 244, 226), 220)

	local slotFolder = Instance.new("Folder")
	slotFolder.Name = "DisplayPads"
	slotFolder.Parent = model
	local creatureFolder = Instance.new("Folder")
	creatureFolder.Name = "Collectibles"
	creatureFolder.Parent = model
	local slots = {}
	local innerZ = center.Z + (northSide and 4 or -4)
	for slotIndex = 1, SLOT_COUNT do
		local xOffset = (slotIndex - 3) * 6.2
		local pad = makePart(slotFolder, "DisplayPad" .. slotIndex, Vector3.new(5.2, 0.65, 5.2), Vector3.new(center.X + xOffset, 1.5, innerZ), Color3.fromRGB(54, 185, 183), Enum.Material.Neon)
		pad.Transparency = 0.16
		local top = makePart(slotFolder, "PadTop" .. slotIndex, Vector3.new(4.5, 0.22, 4.5), pad.Position + Vector3.new(0, 0.42, 0), Color3.fromRGB(73, 72, 111), Enum.Material.SmoothPlastic, nil, false)
		top.CanTouch = false
		table.insert(slots, pad.Position + Vector3.new(0, 0.75, 0))
	end

	local spawn = center + Vector3.new(0, 4, northSide and -11 or 11)
	local plot = {
		model = model,
		base = base,
		slots = slots,
		creatures = creatureFolder,
		spawn = spawn,
		owner = nil,
		northSide = northSide,
	}
	table.insert(plotRecords, plot)
end

local function buildWorld()
	setupLighting()
	makePart(world, "Skyboard", Vector3.new(236, 2, 170), Vector3.new(0, -1.1, 0), Color3.fromRGB(33, 31, 58), Enum.Material.Slate)
	makePart(world, "CentralWalkway", Vector3.new(48, 0.35, 34), Vector3.new(0, 0.1, 0), Color3.fromRGB(63, 54, 103), Enum.Material.SmoothPlastic)
	local market = makePart(world, "OddityExchange", Vector3.new(5, 10, 5), Vector3.new(0, 5, 0), Color3.fromRGB(83, 59, 140), Enum.Material.Neon, Enum.PartType.Cylinder, false)
	market.Orientation = Vector3.new(0, 0, 90)
	addLight(market, Color3.fromRGB(184, 114, 255), 2.5, 25)
	addBillboard(market, "ODDITY EXCHANGE\nSHOP IN YOUR HUD", Color3.fromRGB(255, 226, 130), 260)

	local hazard = makePart(world, "GloopHazard", Vector3.new(23, 0.7, 17), Vector3.new(0, 0.45, 0), Color3.fromRGB(255, 56, 184), Enum.Material.Neon)
	hazard.Transparency = 0.1
	hazard:SetAttribute("Hazard", true)
	addLight(hazard, Color3.fromRGB(255, 46, 187), 2, 28)

	local northX = { -72, -24, 24, 72 }
	for index, x in ipairs(northX) do
		makePlot(index, Vector3.new(x, 0, -57), true)
		makePlot(index + 4, Vector3.new(x, 0, 57), false)
	end

	local crystalColors = {
		Color3.fromRGB(91, 222, 229),
		Color3.fromRGB(190, 113, 255),
		Color3.fromRGB(255, 130, 180),
		Color3.fromRGB(255, 203, 101),
	}
	for index = 1, 12 do
		local angle = math.pi * 2 * index / 12
		local radius = 23
		local position = Vector3.new(math.cos(angle) * radius, 2, math.sin(angle) * radius)
		local crystal = makePart(world, "GlowCrystal" .. index, Vector3.new(2, 5 + index % 3, 2), position, crystalColors[(index - 1) % #crystalColors + 1], Enum.Material.Neon, Enum.PartType.Block, false)
		crystal.Orientation = Vector3.new(0, index * 31, 0)
		addLight(crystal, crystal.Color, 0.8, 14)
	end

	for index = 1, 8 do
		local x = (index - 4.5) * 28
		local cloud = makePart(world, "CloudDeck" .. index, Vector3.new(18, 7, 13), Vector3.new(x, -8, index % 2 == 0 and -88 or 88), Color3.fromRGB(126, 112, 170), Enum.Material.SmoothPlastic, Enum.PartType.Ball, false)
		cloud.Transparency = 0.18
	end

	hazard.Touched:Connect(function(hit)
		local character = hit.Parent
		if not character then
			return
		end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid then
			return
		end
		local player = Players:GetPlayerFromCharacter(character)
		if not player or not playerRecords[player] then
			return
		end
		local now = os.clock()
		if (hazardTimes[player] or 0) > now then
			return
		end
		hazardTimes[player] = now + 5
		local cash = playerRecords[player].stats.Cash
		local lost = math.floor(cash.Value * 0.2)
		cash.Value = math.max(0, cash.Value - lost)
		notifyRemote:FireClient(player, lost > 0 and ("GLOOP! You dropped $" .. lost .. ".") or "GLOOP! Watch your step!")
	end)
end

local function notify(player, message)
	if player.Parent == Players then
		notifyRemote:FireClient(player, message)
	end
end

local function incomeMultiplier(rebirths)
	return 1 + rebirths * 0.5
end

local function updateStats(record)
	local total = 0
	for _, id in ipairs(record.owned) do
		local item = ITEMS[id]
		if item then
			total += item.income
		end
	end
	record.stats.Income.Value = math.floor(total * incomeMultiplier(record.stats.Rebirths.Value))
	record.stats.Oddities.Value = #record.owned
end

local function addOwnedItem(record, item)
	if #record.owned >= SLOT_COUNT then
		return false
	end
	table.insert(record.owned, item.id)
	local index = #record.owned
	addCreature(record.plot.creatures, item, record.plot.slots[index])
	updateStats(record)
	return true
end

local function loadProfile(player)
	local profile = { cash = STARTING_CASH, rebirths = 0, owned = {}, canSave = true }
	local ok, saved = pcall(function()
		return DATA_STORE:GetAsync("Player_" .. player.UserId)
	end)
	if not ok then
		warn("Neon Nonsense could not load " .. player.Name .. "'s profile: " .. tostring(saved))
		profile.canSave = false
		return profile
	end
	if type(saved) ~= "table" then
		return profile
	end
	if type(saved.cash) == "number" and saved.cash == saved.cash then
		profile.cash = math.clamp(math.floor(saved.cash), 0, MAX_CASH)
	end
	if type(saved.rebirths) == "number" and saved.rebirths == saved.rebirths then
		profile.rebirths = math.clamp(math.floor(saved.rebirths), 0, REBIRTH_LIMIT)
	end
	if type(saved.owned) == "table" then
		for _, id in ipairs(saved.owned) do
			if #profile.owned >= SLOT_COUNT then
				break
			end
			if type(id) == "string" and ITEMS[id] then
				table.insert(profile.owned, id)
			end
		end
	end
	return profile
end

local function saveProfile(player)
	local record = playerRecords[player]
	if not record then
		return
	end
	local profile = {
		cash = math.clamp(math.floor(record.stats.Cash.Value), 0, MAX_CASH),
		rebirths = math.clamp(record.stats.Rebirths.Value, 0, REBIRTH_LIMIT),
		owned = table.clone(record.owned),
	}
	if not record.canSave then
		return
	end
	local ok, problem = pcall(function()
		DATA_STORE:UpdateAsync("Player_" .. player.UserId, function()
			return profile
		end)
	end)
	if not ok then
		warn("Neon Nonsense could not save " .. player.Name .. "'s profile: " .. tostring(problem))
	end
end

local function createStats(player, profile)
	local folder = Instance.new("Folder")
	folder.Name = "leaderstats"
	folder.Parent = player

	local cash = Instance.new("NumberValue")
	cash.Name = "Cash"
	cash.Value = profile.cash
	cash.Parent = folder

	local income = Instance.new("NumberValue")
	income.Name = "Income"
	income.Value = 0
	income.Parent = folder

	local rebirths = Instance.new("IntValue")
	rebirths.Name = "Rebirths"
	rebirths.Value = profile.rebirths
	rebirths.Parent = folder

	local oddities = Instance.new("IntValue")
	oddities.Name = "Oddities"
	oddities.Value = 0
	oddities.Parent = folder

	return { Cash = cash, Income = income, Rebirths = rebirths, Oddities = oddities }
end

local function assignPlot(player)
	for _, plot in ipairs(plotRecords) do
		if plot.owner == nil then
			plot.owner = player
			plot.model:SetAttribute("OwnerUserId", player.UserId)
			plot.model.Name = player.Name .. "Plot"
			local label = plot.model:FindFirstChild("PlotSign")
			if label then
				local gui = label:FindFirstChildOfClass("BillboardGui")
				local text = gui and gui:FindFirstChildOfClass("Frame")
				local title = text and text:FindFirstChildOfClass("TextLabel")
				if title then
					title.Text = player.DisplayName .. "'S PLOT\n" .. player.Name
				end
			end
			return plot
		end
	end
	return nil
end

local function onCharacter(player, character)
	local record = playerRecords[player]
	if not record then
		return
	end
	local root = character:WaitForChild("HumanoidRootPart", 10)
	if root and player.Parent == Players then
		character:PivotTo(CFrame.new(record.plot.spawn))
	end
end

local function onPlayerAdded(player)
	local plot = assignPlot(player)
	if not plot then
		player:Kick("This server's eight plots are full. Please join another server.")
		return
	end

	local profile = loadProfile(player)
	if player.Parent ~= Players then
		plot.owner = nil
		plot.model:SetAttribute("OwnerUserId", 0)
		return
	end

	local stats = createStats(player, profile)
	local record = { plot = plot, stats = stats, owned = {}, canSave = profile.canSave }
	playerRecords[player] = record
	for _, id in ipairs(profile.owned) do
		local item = ITEMS[id]
		if item then
			addOwnedItem(record, item)
		end
	end

	player.CharacterAdded:Connect(function(character)
		onCharacter(player, character)
	end)
	if player.Character then
		task.defer(onCharacter, player, player.Character)
	end
	notify(player, "Your plot is ready. Start with the Moss Boss Capybara.")
end

local function handleAction(player, action, itemId)
	local record = playerRecords[player]
	if not record then
		return
	end
	local now = os.clock()
	if (actionTimes[player] or 0) > now then
		return
	end
	actionTimes[player] = now + 0.25

	if action == "Buy" then
		if type(itemId) ~= "string" then
			return
		end
		local item = ITEMS[itemId]
		if not item then
			notify(player, "That collectible is not in the catalog.")
			return
		end
		if #record.owned >= SLOT_COUNT then
			notify(player, "Your display is full. Rebirth to start a fresh collection.")
			return
		end
		if record.stats.Cash.Value < item.cost then
			notify(player, "You need $" .. item.cost .. " for " .. item.name .. ".")
			return
		end
		record.stats.Cash.Value -= item.cost
		addOwnedItem(record, item)
		notify(player, item.name .. " joined your display! +" .. item.income .. " cash/sec.")
	elseif action == "Rebirth" then
		local rebirths = record.stats.Rebirths.Value
		if rebirths >= REBIRTH_LIMIT then
			notify(player, "You have reached the rebirth limit.")
			return
		end
		local cost = REBIRTH_BASE_COST * (rebirths + 1)
		if record.stats.Cash.Value < cost then
			notify(player, "Next rebirth costs $" .. cost .. ".")
			return
		end
		record.stats.Cash.Value = 350
		record.stats.Rebirths.Value += 1
		record.owned = {}
		record.plot.creatures:ClearAllChildren()
		updateStats(record)
		notify(player, "Rebirth " .. record.stats.Rebirths.Value .. "! Permanent income multiplier increased.")
	end
end

buildWorld()
actionRemote.OnServerEvent:Connect(handleAction)

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(function(player)
	saveProfile(player)
	local record = playerRecords[player]
	if record then
		record.plot.owner = nil
		record.plot.model:SetAttribute("OwnerUserId", 0)
		record.plot.model.Name = "Plot" .. tostring(table.find(plotRecords, record.plot))
		local sign = record.plot.model:FindFirstChild("PlotSign")
		local gui = sign and sign:FindFirstChildOfClass("BillboardGui")
		local frame = gui and gui:FindFirstChildOfClass("Frame")
		local title = frame and frame:FindFirstChildOfClass("TextLabel")
		if title then
			title.Text = "OPEN PLOT"
		end
		record.plot.creatures:ClearAllChildren()
		playerRecords[player] = nil
	end
	actionTimes[player] = nil
	hazardTimes[player] = nil
end)

for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, player)
end

task.spawn(function()
	while true do
		task.wait(1)
		for player, record in pairs(playerRecords) do
			if player.Parent == Players then
				local income = record.stats.Income.Value
				if income > 0 then
					record.stats.Cash.Value = math.min(MAX_CASH, record.stats.Cash.Value + income)
				end
			end
		end
	end
end)

task.spawn(function()
	while true do
		task.wait(60)
		for player in pairs(playerRecords) do
			task.spawn(saveProfile, player)
		end
	end
end)

game:BindToClose(function()
	local waiting = 0
	for player in pairs(playerRecords) do
		waiting += 1
		task.spawn(function()
			saveProfile(player)
			waiting -= 1
		end)
	end
	local deadline = os.clock() + 25
	while waiting > 0 and os.clock() < deadline do
		task.wait(0.1)
	end
end)
