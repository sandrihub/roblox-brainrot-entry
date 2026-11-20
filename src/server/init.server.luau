local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local Workspace = game:GetService("Workspace")

local STORE = DataStoreService:GetDataStore("BrainrotBazaar_v1")
local STARTING_CASH = 150
local PLOT_COUNT = 8
local MAX_BRAINROTS = 8
local MAX_REBIRTHS = 6
local STEAL_COOLDOWN = 25

local CATALOG = {
	{ id = "capybara", name = "Soggy Capybara", rarity = "COMMON", cost = 25, income = 2, color = Color3.fromRGB(176, 128, 83), accent = Color3.fromRGB(255, 224, 142) },
	{ id = "goblin", name = "Espresso Goblino", rarity = "UNCOMMON", cost = 125, income = 10, color = Color3.fromRGB(92, 176, 106), accent = Color3.fromRGB(255, 91, 47) },
	{ id = "pigeon", name = "Rizzler Pigeon", rarity = "RARE", cost = 550, income = 44, color = Color3.fromRGB(103, 167, 224), accent = Color3.fromRGB(255, 216, 73) },
	{ id = "llama", name = "Tax Fraud Llama", rarity = "EPIC", cost = 2400, income = 210, color = Color3.fromRGB(204, 132, 224), accent = Color3.fromRGB(255, 114, 110) },
	{ id = "axolotl", name = "Microwave Axolotl", rarity = "LEGENDARY", cost = 11000, income = 1150, color = Color3.fromRGB(255, 127, 166), accent = Color3.fromRGB(90, 234, 229) },
	{ id = "cheese", name = "CEO of Cheese", rarity = "MYTHIC", cost = 50000, income = 6500, color = Color3.fromRGB(255, 203, 54), accent = Color3.fromRGB(255, 247, 185) },
}

local catalogById = {}
for _, item in ipairs(CATALOG) do
	catalogById[item.id] = item
end

local remotes = Instance.new("Folder")
remotes.Name = "BrainrotRemotes"
remotes.Parent = ReplicatedStorage

local actionRemote = Instance.new("RemoteEvent")
actionRemote.Name = "Action"
actionRemote.Parent = remotes

local stateRemote = Instance.new("RemoteEvent")
stateRemote.Name = "State"
stateRemote.Parent = remotes

local world = Instance.new("Folder")
world.Name = "BrainrotBazaar"
world.Parent = Workspace

local plots = {}
local playerData = {}
local lastAction = {}
local lastSteal = {}
local buildState
local rebuildPlot
local sendState

local function makePart(parent, name, size, position, color, material, shape)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Shape = shape or Enum.PartType.Block
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function makeBillboard(parent, text, color, size)
	local gui = Instance.new("BillboardGui")
	gui.Name = "NameTag"
	gui.Size = UDim2.fromOffset(size or 220, 58)
	gui.StudsOffset = Vector3.new(0, 3.2, 0)
	gui.AlwaysOnTop = true
	gui.Parent = parent

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundColor3 = Color3.fromRGB(32, 24, 42)
	label.BackgroundTransparency = 0.1
	label.TextColor3 = color
	label.TextStrokeTransparency = 0.55
	label.Font = Enum.Font.GothamBlack
	label.TextScaled = true
	label.TextWrapped = true
	label.Text = text
	label.Parent = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = label
	return label
end

local function createCreature(item, position, owner, record)
	local model = Instance.new("Model")
	model.Name = item.name

	local torso = makePart(model, "Body", Vector3.new(3.2, 2.4, 2.5), position + Vector3.new(0, 2, 0), item.color, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
	model.PrimaryPart = torso
	makePart(model, "Face", Vector3.new(1.7, 1.4, 0.6), position + Vector3.new(0, 2.05, -1.08), item.accent, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
	makePart(model, "LeftEye", Vector3.new(0.35, 0.42, 0.22), position + Vector3.new(-0.42, 2.45, -1.48), Color3.fromRGB(28, 22, 38), Enum.Material.Neon, Enum.PartType.Ball)
	makePart(model, "RightEye", Vector3.new(0.35, 0.42, 0.22), position + Vector3.new(0.42, 2.45, -1.48), Color3.fromRGB(28, 22, 38), Enum.Material.Neon, Enum.PartType.Ball)
	makePart(model, "LeftFoot", Vector3.new(0.75, 0.42, 0.9), position + Vector3.new(-0.85, 0.72, -0.05), item.accent, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
	makePart(model, "RightFoot", Vector3.new(0.75, 0.42, 0.9), position + Vector3.new(0.85, 0.72, -0.05), item.accent, Enum.Material.SmoothPlastic, Enum.PartType.Ball)

	if item.id == "pigeon" or item.id == "axolotl" then
		makePart(model, "LeftWing", Vector3.new(0.45, 1.55, 1.6), position + Vector3.new(-1.68, 2.1, 0.15), item.accent, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
		makePart(model, "RightWing", Vector3.new(0.45, 1.55, 1.6), position + Vector3.new(1.68, 2.1, 0.15), item.accent, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
	elseif item.id == "llama" or item.id == "goblin" then
		makePart(model, "LeftEar", Vector3.new(0.55, 1.35, 0.55), position + Vector3.new(-0.95, 3.15, -0.75), item.accent, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
		makePart(model, "RightEar", Vector3.new(0.55, 1.35, 0.55), position + Vector3.new(0.95, 3.15, -0.75), item.accent, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
	else
		makePart(model, "Hat", Vector3.new(2.3, 0.45, 1.8), position + Vector3.new(0, 3.25, 0), item.accent, Enum.Material.Neon, Enum.PartType.Cylinder)
	end

	local label = makeBillboard(torso, item.name .. "\n+" .. item.income .. " / sec", item.accent, 210)
	label.Name = "CreatureLabel"
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "CreaturePrompt"
	prompt.ActionText = "Collect / Swipe"
	prompt.ObjectText = item.name
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.HoldDuration = 0.5
	prompt.MaxActivationDistance = 11
	prompt.RequiresLineOfSight = false
	prompt.Parent = torso
	prompt.Triggered:Connect(function(player)
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if not root or (root.Position - torso.Position).Magnitude > prompt.MaxActivationDistance + 2 then
			return
		end
		local ownerData = playerData[owner]
		if not ownerData then
			return
		end
		if player == owner then
			local payout = math.floor(record.bank)
			if payout > 0 then
				record.bank = 0
				ownerData.cash += payout
				ownerData.message = "Collected $" .. payout .. " from " .. item.name .. "!"
				sendState(owner)
			end
			return
		end
		local thiefData = playerData[player]
		if not thiefData then
			return
		end
		if #ownerData.owned <= 1 then
			thiefData.message = "That plot needs to keep at least one brainrot!"
			stateRemote:FireClient(player, buildState(player))
			return
		end
		if #thiefData.owned >= MAX_BRAINROTS then
			thiefData.message = "Your plot is full. Upgrade your empire first!"
			stateRemote:FireClient(player, buildState(player))
			return
		end
		if os.clock() - (lastSteal[player] or -STEAL_COOLDOWN) < STEAL_COOLDOWN then
			thiefData.message = "Your sticky fingers need a breather!"
			stateRemote:FireClient(player, buildState(player))
			return
		end

		local index
		for i, ownedRecord in ipairs(ownerData.owned) do
			if ownedRecord == record then
				index = i
				break
			end
		end
		if not index then
			return
		end

		lastSteal[player] = os.clock()
		table.remove(ownerData.owned, index)
		table.insert(thiefData.owned, { id = record.id, item = record.item, bank = 0 })
		ownerData.message = player.DisplayName .. " swiped your " .. item.name .. "!"
		thiefData.message = "Yoink! You stole " .. item.name .. "! (25 sec cooldown)"
		rebuildPlot(owner)
		rebuildPlot(player)
		sendState(owner)
		sendState(player)
	end)

	model.Parent = world
	return model
end

local function createPlot(index)
	local angle = (index - 1) * (math.pi * 2 / PLOT_COUNT)
	local center = Vector3.new(math.cos(angle) * 92, 0, math.sin(angle) * 92)
	local plot = { index = index, center = center, owner = nil, models = {} }
	plots[index] = plot

	local base = Instance.new("Folder")
	base.Name = "Plot" .. index
	base.Parent = world
	plot.folder = base

	local floor = makePart(base, "CandyPlot", Vector3.new(58, 1, 48), center + Vector3.new(0, 0, 0), Color3.fromRGB(90, 197, 149), Enum.Material.Grass)
	makePart(base, "BackWall", Vector3.new(58, 10, 2), center + Vector3.new(0, 5, 23), Color3.fromRGB(47, 76, 80), Enum.Material.Slate)
	makePart(base, "LeftWall", Vector3.new(2, 10, 48), center + Vector3.new(-28, 5, 0), Color3.fromRGB(47, 76, 80), Enum.Material.Slate)
	makePart(base, "RightWall", Vector3.new(2, 10, 48), center + Vector3.new(28, 5, 0), Color3.fromRGB(47, 76, 80), Enum.Material.Slate)
	local sign = makePart(base, "PlotSign", Vector3.new(13, 5, 1), center + Vector3.new(0, 7, -24), Color3.fromRGB(255, 183, 63), Enum.Material.Neon)
	makeBillboard(sign, "UNCLAIMED PLOT", Color3.fromRGB(255, 255, 255), 270)
	plot.floor = floor

	local slotOffsets = {
		Vector3.new(-17, 0.5, -12), Vector3.new(-6, 0.5, -12), Vector3.new(6, 0.5, -12), Vector3.new(17, 0.5, -12),
		Vector3.new(-17, 0.5, 7), Vector3.new(-6, 0.5, 7), Vector3.new(6, 0.5, 7), Vector3.new(17, 0.5, 7),
	}
	plot.slotPositions = {}
	for i, offset in ipairs(slotOffsets) do
		plot.slotPositions[i] = center + offset
		makePart(base, "DisplayPad" .. i, Vector3.new(8, 0.5, 8), plot.slotPositions[i], Color3.fromRGB(255, 218, 112), Enum.Material.SmoothPlastic)
	end
	return plot
end

local function buildWorld()
	makePart(world, "Island", Vector3.new(340, 8, 340), Vector3.new(0, -5, 0), Color3.fromRGB(76, 184, 144), Enum.Material.Grass)
	makePart(world, "BazaarFloor", Vector3.new(65, 1, 65), Vector3.new(0, 0, 0), Color3.fromRGB(100, 84, 150), Enum.Material.Slate)
	local sign = makePart(world, "BazaarSign", Vector3.new(22, 9, 2), Vector3.new(0, 12, -20), Color3.fromRGB(255, 128, 46), Enum.Material.Neon)
	makeBillboard(sign, "BRAINROT BAZAAR\nBUY. COLLECT. GOOBER.", Color3.fromRGB(255, 246, 147), 350)

	for i = 1, PLOT_COUNT do
		createPlot(i)
	end

	for i = 1, 16 do
		local angle = i * math.pi / 8
		local position = Vector3.new(math.cos(angle) * 33, 1.2, math.sin(angle) * 33)
		local orb = makePart(world, "BazaarOrb" .. i, Vector3.new(2, 2, 2), position, Color3.fromHSV(i / 16, 0.8, 1), Enum.Material.Neon, Enum.PartType.Ball)
		orb.CanCollide = false
	end

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "BazaarSpawn"
	spawn.Size = Vector3.new(12, 1, 12)
	spawn.Position = Vector3.new(0, 1, 0)
	spawn.Color = Color3.fromRGB(255, 208, 77)
	spawn.Material = Enum.Material.Neon
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Parent = world
end

local function getPlot(player)
	for _, plot in ipairs(plots) do
		if plot.owner == player then
			return plot
		end
	end
	return nil
end

local function findItem(itemId)
	return catalogById[itemId]
end

rebuildPlot = function(player)
	local plot = getPlot(player)
	if not plot then
		return
	end
	for _, model in ipairs(plot.models) do
		model:Destroy()
	end
	table.clear(plot.models)

	local data = playerData[player]
	if not data then
		return
	end
	for index, record in ipairs(data.owned) do
		local item = findItem(record.item)
		local position = plot.slotPositions[index]
		if item and position then
			table.insert(plot.models, createCreature(item, position, player, record))
		end
	end
	local sign = plot.folder:FindFirstChild("PlotSign")
	if sign then
		local gui = sign:FindFirstChild("NameTag")
		local label = gui and gui:FindFirstChildOfClass("TextLabel")
		if label then
			label.Text = player.DisplayName .. "'S GOOZILLA ZONE"
			label.TextColor3 = Color3.fromRGB(220, 255, 175)
		end
	end
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
			table.insert(owned, { id = item.id, name = item.name, bank = math.floor(record.bank), income = item.income })
		end
	end
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
		stealCooldown = math.max(0, math.ceil(STEAL_COOLDOWN - (os.clock() - (lastSteal[player] or -STEAL_COOLDOWN)))),
	}
end

sendState = function(player)
	local state = buildState(player)
	if state and player.Parent then
		stateRemote:FireClient(player, state)
	end
end

local function recalculate(data)
	local base = 0
	for _, record in ipairs(data.owned) do
		local item = findItem(record.item)
		if item then
			base += item.income
		end
	end
	data.income = math.floor(base * (1 + data.upgrades * 0.35) * (2 ^ data.rebirths))
end

local function savePlayer(player)
	local data = playerData[player]
	if not data or not data.loaded then
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
		warn("Could not save brainrot data for " .. player.Name .. ": " .. tostring(err))
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
				if type(entry) == "table" and catalogById[entry.item] then
					table.insert(data.owned, {
						id = #data.owned + 1,
						item = entry.item,
						bank = math.max(0, math.floor(tonumber(entry.bank) or 0)),
					})
				end
			end
		end
	elseif success then
		table.insert(data.owned, { id = 1, item = "capybara", bank = 0 })
		data.message = "A free Soggy Capybara is yours! It earns $2/sec."
	else
		warn("Could not load brainrot data for " .. player.Name .. ": " .. tostring(saved))
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
	table.insert(data.owned, { id = math.floor(os.clock() * 1000), item = item.id, bank = 0 })
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
		data.message = "This server is full. Join another server to claim a plot!"
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
			data.message = "Your plot is full! (8 brainrots max)"
		elseif data.cash < item.cost then
			data.message = "Not enough cash for " .. item.name .. "!"
		else
			data.cash -= item.cost
			addBrainrot(player, item)
			data.message = "New brainrot acquired: " .. item.name .. "!"
		end
	elseif payload.action == "collect" then
		local total = data.bank
		data.bank = 0
		for _, record in ipairs(data.owned) do
			total += math.floor(record.bank)
			record.bank = 0
		end
		data.cash += total
		data.message = total > 0 and ("Ka-ching! Collected $" .. total .. ".") or "Your brainrots are still cooking up cash!"
	elseif payload.action == "upgrade" then
		local cost = 600 * (2 ^ data.upgrades)
		if data.upgrades >= 5 then
			data.message = "Your goober lab is fully upgraded!"
		elseif data.cash < cost then
			data.message = "Upgrade costs $" .. cost .. "!"
		else
			data.cash -= cost
			data.upgrades += 1
			recalculate(data)
			data.message = "Goober lab upgraded! +35% income."
		end
	elseif payload.action == "rebirth" then
		local minimumOwned = 5
		if data.rebirths >= MAX_REBIRTHS then
			data.message = "Maximum rebirth reached. You are too powerful."
		elseif data.cash < 25000 or #data.owned < minimumOwned then
			data.message = "Rebirth needs $25,000 and 5 brainrots. It doubles income!"
		else
			data.cash = 250
			data.bank = 0
			data.owned = {}
			data.upgrades = 0
			data.rebirths += 1
			recalculate(data)
			rebuildPlot(player)
			data.message = "REBIRTH! Cash reset, income doubled forever!"
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
	playerData[player] = {
		cash = STARTING_CASH,
		bank = 0,
		owned = {},
		upgrades = 0,
		rebirths = 0,
		income = 0,
		loaded = false,
		message = plot and "Welcome to the Bazaar! Your first brainrot is only $25." or "Server plots are full. Try another server!",
	}
	if plot then
		task.spawn(function()
			local character = player.Character or player.CharacterAdded:Wait()
			if character and character.Parent then
				character:PivotTo(CFrame.lookAt(plot.center + Vector3.new(0, 5, -17), Vector3.new(0, 5, 0)))
			end
		end)
		player.CharacterAdded:Connect(function(character)
			task.wait(0.15)
			if plot.owner == player and character.Parent then
				character:PivotTo(CFrame.lookAt(plot.center + Vector3.new(0, 5, -17), Vector3.new(0, 5, 0)))
			end
		end)
	end
	task.spawn(loadPlayer, player, playerData[player])
end)

Players.PlayerRemoving:Connect(function(player)
	savePlayer(player)
	local plot = getPlot(player)
	if plot then
		plot.owner = nil
		for _, model in ipairs(plot.models) do
			model:Destroy()
		end
		table.clear(plot.models)
		local sign = plot.folder:FindFirstChild("PlotSign")
		local gui = sign and sign:FindFirstChild("NameTag")
		local label = gui and gui:FindFirstChildOfClass("TextLabel")
		if label then
			label.Text = "UNCLAIMED PLOT"
			label.TextColor3 = Color3.fromRGB(255, 255, 255)
		end
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
