local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local random = Random.new()
local palette = {
	Color3.fromRGB(0, 245, 255),
	Color3.fromRGB(255, 54, 206),
	Color3.fromRGB(173, 255, 47),
	Color3.fromRGB(255, 193, 54),
	Color3.fromRGB(150, 93, 255),
}
local tiers = {
	{ name = "Common", color = Color3.fromRGB(182, 198, 211), rate = 3, weight = 42 },
	{ name = "Uncommon", color = Color3.fromRGB(71, 255, 151), rate = 8, weight = 27 },
	{ name = "Rare", color = Color3.fromRGB(66, 177, 255), rate = 18, weight = 16 },
	{ name = "Epic", color = Color3.fromRGB(190, 103, 255), rate = 42, weight = 8 },
	{ name = "Legendary", color = Color3.fromRGB(255, 187, 56), rate = 110, weight = 4 },
	{ name = "Mythic", color = Color3.fromRGB(255, 75, 120), rate = 300, weight = 1.8 },
	{ name = "Glitched", color = Color3.fromRGB(0, 255, 233), rate = 850, weight = 0.7 },
	{ name = "Brainrot God", color = Color3.fromRGB(255, 245, 117), rate = 2500, weight = 0.2 },
}
local creatures = {
	"Spaghetti Yeti", "Bingus Prime", "Rizz Wizard", "Mango Mongoose",
	"Toaster Roaster", "Yapcapybara", "Skibidi Seagull", "Tung Tung Tortoise",
	"Quantum Hamster", "Waffle Werewolf", "Goblin Mode Goose", "Meowtain Dew",
	"Certified Goober", "Lasagna Llama", "Feral Ferret", "Pigeon CEO",
}
local plots = {}
local playerData = {}
local activePickups = {}
local brainrotRecords = {}
local pickupPositions = {
	Vector3.new(-38, 2, -18), Vector3.new(-22, 2, -38), Vector3.new(0, 2, -42),
	Vector3.new(24, 2, -34), Vector3.new(40, 2, -12), Vector3.new(38, 2, 18),
	Vector3.new(20, 2, 38), Vector3.new(-8, 2, 42), Vector3.new(-34, 2, 28),
	Vector3.new(0, 2, 0), Vector3.new(0, 2, 22), Vector3.new(18, 2, 0),
}

Lighting.FogColor = Color3.fromRGB(22, 14, 52)
Lighting.FogStart = 280
Lighting.FogEnd = 700

local atmosphere = Lighting:FindFirstChild("NeonAtmosphere") or Instance.new("Atmosphere")
atmosphere.Name = "NeonAtmosphere"
atmosphere.Color = Color3.fromRGB(153, 113, 255)
atmosphere.Decay = Color3.fromRGB(52, 29, 100)
atmosphere.Density = 0.28
atmosphere.Glare = 0.25
atmosphere.Haze = 1.2
atmosphere.Parent = Lighting

local oldWorld = Workspace:FindFirstChild("NeonNonsenseWorld")
if oldWorld then
	oldWorld:Destroy()
end
local world = Instance.new("Folder")
world.Name = "NeonNonsenseWorld"
world.Parent = Workspace

local remotes = ReplicatedStorage:FindFirstChild("NeonNonsense")
if remotes then
	remotes:Destroy()
end
remotes = Instance.new("Folder")
remotes.Name = "NeonNonsense"
remotes.Parent = ReplicatedStorage

local stateEvent = Instance.new("RemoteEvent")
stateEvent.Name = "State"
stateEvent.Parent = remotes
local actionEvent = Instance.new("RemoteEvent")
actionEvent.Name = "Action"
actionEvent.Parent = remotes

local function makePart(parent, name, size, cframe, color, material, shape)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	if shape then
		part.Shape = shape
	end
	part.Parent = parent
	return part
end

local function addGlow(part, color, range)
	local light = Instance.new("PointLight")
	light.Color = color
	light.Brightness = 1.1
	light.Range = range or 13
	light.Parent = part
end

local function addLabel(adornee, title, subtitle, color, offset)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "NeonLabel"
	billboard.Adornee = adornee
	billboard.Size = UDim2.fromOffset(240, 66)
	billboard.StudsOffset = offset or Vector3.new(0, 4, 0)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 150
	billboard.Parent = adornee

	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = Color3.fromRGB(15, 13, 30)
	frame.BackgroundTransparency = 0.18
	frame.Parent = billboard
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = frame
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = 2
	stroke.Transparency = 0.15
	stroke.Parent = frame

	local heading = Instance.new("TextLabel")
	heading.Name = "Heading"
	heading.BackgroundTransparency = 1
	heading.Position = UDim2.fromOffset(8, 3)
	heading.Size = UDim2.new(1, -16, 0, 31)
	heading.Font = Enum.Font.GothamBlack
	heading.Text = title
	heading.TextColor3 = color
	heading.TextScaled = true
	heading.Parent = frame
	local detail = Instance.new("TextLabel")
	detail.Name = "Detail"
	detail.BackgroundTransparency = 1
	detail.Position = UDim2.fromOffset(8, 34)
	detail.Size = UDim2.new(1, -16, 0, 24)
	detail.Font = Enum.Font.GothamBold
	detail.Text = subtitle
	detail.TextColor3 = Color3.fromRGB(237, 232, 255)
	detail.TextScaled = true
	detail.Parent = frame
end

local function makeSign(parent, name, position, size, title, detail, color)
	local base = makePart(parent, name, size, CFrame.new(position), Color3.fromRGB(22, 18, 45), Enum.Material.Metal)
	base.CanCollide = false
	addGlow(base, color, 18)
	addLabel(base, title, detail, color, Vector3.new(0, size.Y * 0.65 + 1, 0))
	return base
end

local ground = makePart(world, "MidnightGlass", Vector3.new(560, 2, 560), CFrame.new(0, -2, 0), Color3.fromRGB(17, 15, 36), Enum.Material.Slate)
ground.Material = Enum.Material.Asphalt

local plaza = makePart(world, "MarketDisk", Vector3.new(112, 3, 112), CFrame.new(0, -0.5, 0), Color3.fromRGB(34, 22, 70), Enum.Material.Metal, Enum.PartType.Cylinder)
plaza.Orientation = Vector3.new(0, 0, 90)
addGlow(plaza, palette[1], 48)
for index = 1, 4 do
	local angle = math.rad(index * 45)
	local beam = makePart(
		world,
		"MarketCircuit" .. index,
		Vector3.new(2, 0.24, 100),
		CFrame.new(0, 1.08, 0) * CFrame.Angles(0, angle, 0),
		palette[index + 1],
		Enum.Material.Neon
	)
	beam.CanCollide = false
end

makeSign(world, "MarketMarquee", Vector3.new(0, 13, -57), Vector3.new(30, 2, 3), "GLITCH MARKET", "GRAB A GREMLIN. GET PAID.", palette[1])
makeSign(world, "InstructionTotem", Vector3.new(0, 5, 58), Vector3.new(18, 2, 3), "BUILD YOUR ROT", "COLLECT  /  EARN  /  REBIRTH", palette[3])

for index = 1, 28 do
	local angle = index * math.pi * 2 / 28
	local radius = 72 + (index % 3) * 5
	local color = palette[(index - 1) % #palette + 1]
	local pylon = makePart(world, "PulsePylon" .. index, Vector3.new(2.4, 10 + (index % 4) * 2, 2.4), CFrame.new(math.cos(angle) * radius, 4, math.sin(angle) * radius), color, Enum.Material.Neon)
	pylon.CanCollide = false
	addGlow(pylon, color, 12)
	local cap = makePart(world, "PylonCap" .. index, Vector3.new(4, 0.5, 4), pylon.CFrame * CFrame.new(0, pylon.Size.Y / 2, 0), Color3.fromRGB(29, 24, 50), Enum.Material.Metal)
	cap.CanCollide = false
end

local plotCount = 8
local plotRadius = 178
for index = 1, plotCount do
	local angle = math.rad((index - 1) * 360 / plotCount - 90)
	local center = Vector3.new(math.cos(angle) * plotRadius, 0, math.sin(angle) * plotRadius)
	local color = palette[(index - 1) % #palette + 1]
	local model = Instance.new("Model")
	model.Name = "Plot" .. index
	model.Parent = world

	local floor = makePart(model, "PlotDeck", Vector3.new(78, 2, 68), CFrame.new(center), Color3.fromRGB(27, 24, 49), Enum.Material.Metal)
	addGlow(floor, color, 20)
	local trim = makePart(model, "PlotBorder", Vector3.new(82, 0.6, 72), CFrame.new(center + Vector3.new(0, -0.7, 0)), color, Enum.Material.Neon)
	trim.CanCollide = false

	local sign = makePart(model, "OwnerSign", Vector3.new(22, 2, 2), CFrame.new(center + Vector3.new(0, 5, -31)), Color3.fromRGB(17, 14, 33), Enum.Material.Metal)
	sign.CanCollide = false
	addLabel(sign, "OPEN PLOT", "Claimed when you join", color, Vector3.new(0, 2.4, 0))
	local spawn = makePart(model, "PlotSpawn", Vector3.new(9, 1, 9), CFrame.new(center + Vector3.new(0, 0.9, 26)), color, Enum.Material.Neon)
	spawn.Transparency = 0.28
	spawn.CanCollide = false

	local slots = {}
	for slotIndex = 1, 8 do
		local column = (slotIndex - 1) % 4
		local row = math.floor((slotIndex - 1) / 4)
		local localPosition = Vector3.new((column - 1.5) * 16, 1.4, row * 20 - 10)
		local pedestal = makePart(model, "Display" .. slotIndex, Vector3.new(10, 1, 10), CFrame.new(center + localPosition), Color3.fromRGB(44, 37, 68), Enum.Material.Metal)
		local ring = makePart(model, "DisplayRing" .. slotIndex, Vector3.new(10.5, 0.35, 10.5), pedestal.CFrame * CFrame.new(0, -0.62, 0), color, Enum.Material.Neon)
		ring.CanCollide = false
		local prompt = Instance.new("ProximityPrompt")
		prompt.Name = "SwipePrompt"
		prompt.ActionText = "Swipe!"
		prompt.ObjectText = "Someone's brainrot"
		prompt.HoldDuration = 1.8
		prompt.MaxActivationDistance = 10
		prompt.RequiresLineOfSight = false
		prompt.Enabled = false
		prompt.Parent = pedestal
		table.insert(slots, { pedestal = pedestal, prompt = prompt, brain = nil })
	end
	table.insert(plots, {
		model = model,
		center = center,
		color = color,
		sign = sign,
		spawn = spawn,
		slots = slots,
		owner = nil,
	})
end

local function playerPlot(player)
	local data = playerData[player]
	return data and data.plot or nil
end

local function notify(player, message)
	if player and player.Parent == Players then
		stateEvent:FireClient(player, "toast", message)
	end
end

local function snapshot(player)
	local data = playerData[player]
	if not data then
		return
	end
	local count = 0
	local rate = 0
	for _, slot in ipairs(data.plot.slots) do
		if slot.brain then
			count += 1
			rate += slot.brain.rate
		end
	end
	stateEvent:FireClient(player, "snapshot", {
		cash = math.floor(data.cash),
		income = math.floor(rate * data.multiplier),
		brainrots = count,
		slots = #data.plot.slots,
		rebirths = data.rebirths,
		multiplier = data.multiplier,
		incomeLevel = data.incomeLevel,
		speedLevel = data.speedLevel,
		rebirthPrice = data.rebirthPrice,
		incomePrice = data.incomePrice,
		speedPrice = data.speedPrice,
		plotColor = data.plot.color,
	})
end

local function plotLabel(plot, title, detail)
	local gui = plot.sign:FindFirstChild("NeonLabel")
	if not gui then
		return
	end
	local frame = gui:FindFirstChildOfClass("Frame")
	if not frame then
		return
	end
	local heading = frame:FindFirstChild("Heading")
	local subtitle = frame:FindFirstChild("Detail")
	if heading then
		heading.Text = title
	end
	if subtitle then
		subtitle.Text = detail
	end
end

local function attachSwipePrompt(plot, slot)
	local prompt = slot.prompt
	if slot.swipeConnection then
		slot.swipeConnection:Disconnect()
		slot.swipeConnection = nil
	end
	prompt.Enabled = slot.brain ~= nil
	if not slot.brain then
		return
	end
	prompt.ObjectText = slot.brain.name
	slot.swipeConnection = prompt.Triggered:Connect(function(thief)
		local record = slot.brain
		local thiefData = playerData[thief]
		if not record or not thiefData or record.owner == thief then
			return
		end
		if record.lockedUntil and os.clock() < record.lockedUntil then
			notify(thief, "That display is protected for a moment.")
			return
		end
		local destination
		for _, candidate in ipairs(thiefData.plot.slots) do
			if not candidate.brain then
				destination = candidate
				break
			end
		end
		if not destination then
			notify(thief, "Your plot is full. Upgrade your empire first!")
			return
		end
		local owner = playerData[record.owner]
		if owner then
			owner.cash = math.max(0, owner.cash - math.max(25, math.floor(record.rate * 3)))
			notify(record.owner, thief.DisplayName .. " swiped " .. record.name .. "!")
			snapshot(record.owner)
		end
		slot.brain = nil
		record.owner = thief
		record.lockedUntil = os.clock() + 10
		destination.brain = record
		record.model:PivotTo(destination.pedestal.CFrame * CFrame.new(0, 3.2, 0))
		local promptOnModel = record.model:FindFirstChild("CollectPrompt", true)
		if promptOnModel then
			promptOnModel.Enabled = false
		end
		attachSwipePrompt(thiefData.plot, destination)
		attachSwipePrompt(plot, slot)
		notify(thief, "Swipe secured: " .. record.name .. " is yours for 10 seconds!")
		snapshot(thief)
	end)
end

local function chooseTier()
	local total = 0
	for _, tier in ipairs(tiers) do
		total += tier.weight
	end
	local roll = random:NextNumber(0, total)
	for _, tier in ipairs(tiers) do
		roll -= tier.weight
		if roll <= 0 then
			return tier
		end
	end
	return tiers[1]
end

local function spawnBrainrot()
	if #activePickups >= 10 then
		return
	end
	local position = pickupPositions[random:NextInteger(1, #pickupPositions)]
	for _, item in ipairs(activePickups) do
		if (item.position - position).Magnitude < 12 then
			return
		end
	end
	local tier = chooseTier()
	local name = creatures[random:NextInteger(1, #creatures)]
	local model = Instance.new("Model")
	model.Name = name:gsub("%W", "") .. "Brainrot"
	model.Parent = world

	local body = makePart(model, "Body", Vector3.new(3.2, 3.2, 2.7), CFrame.new(position), tier.color, Enum.Material.Neon, Enum.PartType.Ball)
	body.Anchored = true
	body.CanCollide = false
	addGlow(body, tier.color, 16)
	local belly = makePart(model, "Belly", Vector3.new(1.7, 1.3, 0.5), body.CFrame * CFrame.new(0, -0.55, -1.14), Color3.fromRGB(255, 255, 255), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
	belly.CanCollide = false
	for eyeIndex = 1, 2 do
		local eye = makePart(model, "Eye" .. eyeIndex, Vector3.new(0.55, 0.55, 0.25), body.CFrame * CFrame.new(eyeIndex == 1 and -0.65 or 0.65, 0.42, -1.22), Color3.fromRGB(255, 255, 255), Enum.Material.Neon, Enum.PartType.Ball)
		eye.CanCollide = false
		local pupil = makePart(model, "Pupil" .. eyeIndex, Vector3.new(0.22, 0.25, 0.12), eye.CFrame * CFrame.new(0, 0, -0.15), Color3.fromRGB(18, 13, 34), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
		pupil.CanCollide = false
	end
	local antenna = makePart(model, "Antenna", Vector3.new(0.3, 1.2, 0.3), body.CFrame * CFrame.new(0, 1.8, 0), tier.color, Enum.Material.Neon)
	antenna.CanCollide = false
	local orb = makePart(model, "AntennaOrb", Vector3.new(0.7, 0.7, 0.7), antenna.CFrame * CFrame.new(0, 0.7, 0), Color3.fromRGB(255, 255, 255), Enum.Material.Neon, Enum.PartType.Ball)
	orb.CanCollide = false
	addGlow(orb, tier.color, 11)
	model.PrimaryPart = body
	addLabel(body, name, tier.name .. "  |  +" .. tier.rate .. " / sec", tier.color, Vector3.new(0, 3.2, 0))

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "CollectPrompt"
	prompt.ActionText = "Collect"
	prompt.ObjectText = name .. "  [" .. tier.name .. "]"
	prompt.HoldDuration = 0.25
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = body

	local pickup = { model = model, position = position, prompt = prompt }
	table.insert(activePickups, pickup)
	prompt.Triggered:Connect(function(player)
		if not model.Parent then
			return
		end
		local data = playerData[player]
		if not data then
			return
		end
		local emptySlot
		for _, slot in ipairs(data.plot.slots) do
			if not slot.brain then
				emptySlot = slot
				break
			end
		end
		if not emptySlot then
			notify(player, "Your plot is full! Swipe a rival or rebirth.")
			return
		end
		for index, active in ipairs(activePickups) do
			if active == pickup then
				table.remove(activePickups, index)
				break
			end
		end
		prompt.Enabled = false
		local record = {
			name = name,
			rarity = tier.name,
			rate = tier.rate,
			color = tier.color,
			model = model,
			owner = player,
		}
		brainrotRecords[model] = record
		emptySlot.brain = record
		model:PivotTo(emptySlot.pedestal.CFrame * CFrame.new(0, 3.2, 0))
		attachSwipePrompt(data.plot, emptySlot)
		notify(player, tier.name .. " pull! " .. name .. " earns +" .. tier.rate .. "/sec.")
		snapshot(player)
	end)
end

local function assignPlot(player)
	for _, plot in ipairs(plots) do
		if not plot.owner then
			plot.owner = player
			plotLabel(plot, player.DisplayName .. "'S PLOT", "BRAINTROTS: 0 / 8")
			playerData[player] = {
				cash = 250,
				rebirths = 0,
				multiplier = 1,
				incomeLevel = 0,
				speedLevel = 0,
				rebirthPrice = 15000,
				incomePrice = 350,
				speedPrice = 250,
				plot = plot,
			}
			player:SetAttribute("NeonPlot", plot.model.Name)
			player.CharacterAdded:Connect(function(character)
				local root = character:WaitForChild("HumanoidRootPart", 10)
				if root and playerData[player] then
					task.wait(0.15)
					character:PivotTo(plot.spawn.CFrame * CFrame.new(0, 4, 0))
					local humanoid = character:FindFirstChildOfClass("Humanoid")
					if humanoid then
						humanoid.WalkSpeed = 16 + playerData[player].speedLevel * 2
					end
				end
			end)
			if player.Character then
				task.defer(function()
					if player.Character and playerData[player] then
						player.Character:PivotTo(plot.spawn.CFrame * CFrame.new(0, 4, 0))
					end
				end)
			end
			snapshot(player)
			return
		end
	end
	notify(player, "All plots are full. Try another server!")
end

local function clearCollection(data)
	for _, slot in ipairs(data.plot.slots) do
		if slot.brain then
			local record = slot.brain
			brainrotRecords[record.model] = nil
			if record.model and record.model.Parent then
				record.model:Destroy()
			end
			slot.brain = nil
		end
		slot.prompt.Enabled = false
	end
end

local function performUpgrade(player, kind)
	local data = playerData[player]
	if not data then
		return
	end
	if kind == "income" then
		if data.cash < data.incomePrice then
			notify(player, "Need $" .. data.incomePrice .. " for the next income rig.")
			return
		end
		data.cash -= data.incomePrice
		data.incomeLevel += 1
		data.multiplier += 0.25
		data.incomePrice = math.floor(data.incomePrice * 1.65 + 100)
		notify(player, "Income rig online. All brainrots now print more!")
	elseif kind == "speed" then
		if data.cash < data.speedPrice then
			notify(player, "Need $" .. data.speedPrice .. " for the next speed coil.")
			return
		end
		data.cash -= data.speedPrice
		data.speedLevel += 1
		data.speedPrice = math.floor(data.speedPrice * 1.7 + 80)
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = math.min(32, 16 + data.speedLevel * 2)
		end
		notify(player, "Speed coil turbocharged! Go grab that next pull.")
	else
		return
	end
	snapshot(player)
end

local function performRebirth(player)
	local data = playerData[player]
	if not data then
		return
	end
	if data.cash < data.rebirthPrice then
		notify(player, "Rebirth needs $" .. data.rebirthPrice .. ". Keep that rot running!")
		return
	end
	clearCollection(data)
	data.rebirths += 1
	data.cash = 500
	data.multiplier += 0.75
	data.incomeLevel = 0
	data.speedLevel = 0
	data.incomePrice = 350
	data.speedPrice = 250
	data.rebirthPrice = math.floor(data.rebirthPrice * 2.4)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = 16
	end
	notify(player, "REBIRTH! Permanent x" .. string.format("%.2f", data.multiplier) .. " income multiplier unlocked.")
	snapshot(player)
end

local function buildKiosk(position, color, title, detail, action, priceLabel)
	local kiosk = makePart(world, title:gsub("%W", "") .. "Kiosk", Vector3.new(9, 7, 9), CFrame.new(position), Color3.fromRGB(29, 23, 54), Enum.Material.Metal)
	addGlow(kiosk, color, 22)
	local top = makePart(world, title:gsub("%W", "") .. "KioskTop", Vector3.new(10, 0.7, 10), kiosk.CFrame * CFrame.new(0, 3.8, 0), color, Enum.Material.Neon)
	top.CanCollide = false
	addLabel(kiosk, title, detail, color, Vector3.new(0, 5.3, 0))
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = action
	prompt.ObjectText = priceLabel
	prompt.HoldDuration = 0.3
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = kiosk
	prompt.Triggered:Connect(function(player)
		performUpgrade(player, action == "Buy income" and "income" or "speed")
	end)
end

buildKiosk(Vector3.new(-20, 3, 68), palette[2], "INCOME LAB", "MORE CASH / SEC", "Buy income", "Income rig")
buildKiosk(Vector3.new(20, 3, 68), palette[3], "SPEED SHOP", "ZOOM THROUGH THE ROT", "Buy speed", "Speed coil")

Players.PlayerAdded:Connect(assignPlot)
for _, player in ipairs(Players:GetPlayers()) do
	assignPlot(player)
end

Players.PlayerRemoving:Connect(function(player)
	local data = playerData[player]
	if data then
		clearCollection(data)
		data.plot.owner = nil
		plotLabel(data.plot, "OPEN PLOT", "Claimed when you join")
		playerData[player] = nil
	end
end)

actionEvent.OnServerEvent:Connect(function(player, action, value)
	if action == "upgrade" then
		performUpgrade(player, value)
	elseif action == "rebirth" then
		performRebirth(player)
	elseif action == "request" then
		snapshot(player)
	end
end)

task.spawn(function()
	while true do
		task.wait(6)
		spawnBrainrot()
	end
end)

task.spawn(function()
	while true do
		task.wait(1)
		for player, data in pairs(playerData) do
			local income = 0
			for _, slot in ipairs(data.plot.slots) do
				if slot.brain then
					income += slot.brain.rate
				end
			end
			if income > 0 then
				data.cash += income * data.multiplier
			end
			snapshot(player)
		end
	end
end)

task.spawn(function()
	while true do
		task.wait(48)
		stateEvent:FireAllClients("toast", "GLITCH STORM INBOUND! Swipe smart and protect your plot!")
		task.wait(7)
		for _, player in ipairs(Players:GetPlayers()) do
			local character = player.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			local data = playerData[player]
			if root and data and (root.Position - data.plot.center).Magnitude > 100 then
				local lost = math.min(data.cash, 175)
				data.cash -= lost
				notify(player, "The storm clipped $" .. math.floor(lost) .. " off your loose cash!")
				snapshot(player)
			end
		end
		task.wait(3)
	end
end)

task.spawn(function()
	while true do
		task.wait(22)
		for _, plot in ipairs(plots) do
			local owner = plot.owner
			if owner and playerData[owner] then
				local count = 0
				for _, slot in ipairs(plot.slots) do
					if slot.brain then
						count += 1
					end
				end
				plotLabel(plot, owner.DisplayName .. "'S PLOT", "BRAINTROTS: " .. count .. " / 8")
			end
		end
	end
end)

print("Neon Nonsense is live: eight plots, a glitch market, and a suspicious amount of spaghetti.")
