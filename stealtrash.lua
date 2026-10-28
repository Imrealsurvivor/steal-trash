-- Steal Trash: Smart/Priority Autosteal + Filter + Auto Sell/Compress + Combat + Place + Visual (ESP) + Predict + Settings
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local lp = Players.LocalPlayer
local TrashFolder = workspace:WaitForChild("SpawnedTrash")
local Plots = workspace:WaitForChild("Plots")
local PickupRemote = RS:WaitForChild("PickupTrashRequest")
local CompressRemote = RS:WaitForChild("TrashCompressorRemote")
local SellRemote = RS:WaitForChild("TrashSellAnimationComplete")
local SwingRemote = RS:WaitForChild("BaseballBatSwing")
local CanUseRemote = RS:WaitForChild("CanUseTool")
local PlaceRemote = RS:WaitForChild("PlacePlotObject")
local HitboxVisual = RS:WaitForChild("ToolHitboxVisual", 5)

local selected = nil
local busy = false
local stealing, acting = false, false -- locks so the features don't fight

---------------------------------------------------------------- UI
local gui = Instance.new("ScreenGui")
gui.Name = "StealTrashUI"
gui.ResetOnSpawn = false
gui.Parent = (gethui and gethui()) or game:GetService("CoreGui")

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(460, 260) -- landscape
main.Position = UDim2.new(0.5, -230, 0.5, -130)
main.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
main.BorderSizePixel = 0
main.Active = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 30)
top.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
top.BorderSizePixel = 0
top.Parent = main
Instance.new("UICorner", top).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.fromOffset(10, 0)
title.BackgroundTransparency = 1
title.Text = "Steal Trash"
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = Color3.new(1, 1, 1)
title.Parent = top

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.fromOffset(30, 30)
minBtn.Position = UDim2.new(1, -30, 0, 0)
minBtn.BackgroundTransparency = 1
minBtn.Text = "-"
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 20
minBtn.TextColor3 = Color3.new(1, 1, 1)
minBtn.Parent = top

-- Main page
local body = Instance.new("Frame")
body.Size = UDim2.new(1, 0, 1, -56)
body.Position = UDim2.fromOffset(0, 56)
body.BackgroundTransparency = 1
body.Parent = main

local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(0.55, -15, 1, -46)
list.Position = UDim2.fromOffset(10, 42)
list.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
list.BorderSizePixel = 0
list.ScrollBarThickness = 4
list.CanvasSize = UDim2.new()
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.Parent = body
local layout = Instance.new("UIListLayout", list)
layout.Padding = UDim.new(0, 2)

local right = Instance.new("Frame")
right.Size = UDim2.new(0.45, -15, 1, -20)
right.Position = UDim2.new(0.55, 5, 0, 10)
right.BackgroundTransparency = 1
right.Parent = body

local function label(y, h, text)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, 0, 0, h)
	l.Position = UDim2.fromOffset(0, y)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextWrapped = true
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextYAlignment = Enum.TextYAlignment.Top
	l.Font = Enum.Font.Gotham
	l.TextSize = 12
	l.TextColor3 = Color3.fromRGB(220, 220, 230)
	l.Parent = right
	return l
end

local selLabel = label(0, 28, "Selected: none")
local statusLabel = label(28, 30, "Status: idle")

local limitBox = Instance.new("TextBox")
limitBox.Size = UDim2.new(1, 0, 0, 24)
limitBox.Position = UDim2.fromOffset(0, 60)
limitBox.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
limitBox.Text = "1000"
limitBox.PlaceholderText = "Max kg"
limitBox.ClearTextOnFocus = false
limitBox.Font = Enum.Font.Gotham
limitBox.TextSize = 13
limitBox.TextColor3 = Color3.new(1, 1, 1)
limitBox.Parent = right
Instance.new("UICorner", limitBox).CornerRadius = UDim.new(0, 6)

local modeBtn = Instance.new("TextButton")
modeBtn.Size = UDim2.new(1, 0, 0, 24)
modeBtn.Position = UDim2.fromOffset(0, 88)
modeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
modeBtn.Text = "Mode: Priority (tap)"
modeBtn.Font = Enum.Font.GothamBold
modeBtn.TextSize = 12
modeBtn.TextColor3 = Color3.new(1, 1, 1)
modeBtn.Parent = right
Instance.new("UICorner", modeBtn).CornerRadius = UDim.new(0, 6)

local autoBtn = Instance.new("TextButton")
autoBtn.Size = UDim2.new(1, 0, 0, 28)
autoBtn.Position = UDim2.fromOffset(0, 116)
autoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
autoBtn.Text = "AUTOSTEAL: OFF"
autoBtn.Font = Enum.Font.GothamBold
autoBtn.TextSize = 13
autoBtn.TextColor3 = Color3.new(1, 1, 1)
autoBtn.Parent = right
Instance.new("UICorner", autoBtn).CornerRadius = UDim.new(0, 6)

local stealBtn = Instance.new("TextButton")
stealBtn.Size = UDim2.new(1, 0, 0, 36)
stealBtn.Position = UDim2.new(0, 0, 1, -36)
stealBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
stealBtn.Text = "STEAL"
stealBtn.Font = Enum.Font.GothamBold
stealBtn.TextSize = 16
stealBtn.TextColor3 = Color3.new(1, 1, 1)
stealBtn.Parent = right
Instance.new("UICorner", stealBtn).CornerRadius = UDim.new(0, 6)

local function setStatus(t)
	statusLabel.Text = "Status: " .. t
end

-- generic UI helpers
local function newText(parent, y, h, text, size, bold)
	local o = Instance.new("TextLabel")
	o.Size = UDim2.new(1, -16, 0, h)
	o.Position = UDim2.fromOffset(8, y)
	o.BackgroundTransparency = 1
	o.Text = text
	o.TextWrapped = true
	o.TextXAlignment = Enum.TextXAlignment.Left
	o.TextYAlignment = Enum.TextYAlignment.Top
	o.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
	o.TextSize = size or 12
	o.TextColor3 = Color3.fromRGB(220, 220, 230)
	o.Parent = parent
	return o
end

local function makeBox(parent, pos, size, default, placeholder)
	local box = Instance.new("TextBox")
	box.Position = pos
	box.Size = size
	box.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	box.Text = default
	box.PlaceholderText = placeholder
	box.ClearTextOnFocus = false
	box.Font = Enum.Font.Gotham
	box.TextSize = 13
	box.TextColor3 = Color3.new(1, 1, 1)
	box.Parent = parent
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
	return box
end

local function makeButton(parent, pos, size, text, color)
	local b = Instance.new("TextButton")
	b.Position = pos
	b.Size = size
	b.BackgroundColor3 = color or Color3.fromRGB(60, 60, 75)
	b.Text = text
	b.Font = Enum.Font.GothamBold
	b.TextSize = 13
	b.TextWrapped = true
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Parent = parent
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
	return b
end

-- a column with a title, a hint, some input boxes and one toggle button
local function makeSection(parent, xScale, xOff, titleText, hintText, boxDefs, yOff)
	local col = Instance.new("Frame")
	col.Size = UDim2.new(0.5, -15, 0, 150)
	col.Position = UDim2.new(xScale, xOff, 0, yOff or 10)
	col.BackgroundColor3 = Color3.fromRGB(35, 35, 43)
	col.BorderSizePixel = 0
	col.Parent = parent
	Instance.new("UICorner", col).CornerRadius = UDim.new(0, 6)

	newText(col, 8, 18, titleText, 14, true)
	newText(col, 26, 30, hintText, 11, false)

	local boxes = {}
	for i, d in ipairs(boxDefs) do
		boxes[i] = makeBox(col, UDim2.fromOffset(8, 58 + (i - 1) * 30), UDim2.new(1, -16, 0, 26), d[1], d[2])
	end
	local btn = makeButton(col, UDim2.fromOffset(8, 58 + #boxDefs * 30), UDim2.new(1, -16, 0, 30), "")
	return btn, boxes, col
end

local function pageStatus(parent, y)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, -20, 0, 36)
	l.Position = UDim2.fromOffset(10, y)
	l.BackgroundTransparency = 1
	l.Text = "Status: idle"
	l.TextWrapped = true
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextYAlignment = Enum.TextYAlignment.Top
	l.Font = Enum.Font.Gotham
	l.TextSize = 12
	l.TextColor3 = Color3.fromRGB(220, 220, 230)
	l.Parent = parent
	return l
end

-- top navigation bar
local navBar = Instance.new("Frame")
navBar.Size = UDim2.new(1, 0, 0, 26)
navBar.Position = UDim2.fromOffset(0, 30)
navBar.BackgroundColor3 = Color3.fromRGB(34, 34, 42)
navBar.BorderSizePixel = 0
navBar.Parent = main

local TABS = { "Main", "Auto", "Combat", "Place", "Teleport", "Visual", "Predict", "Settings" }
local tabButtons, pages = {}, { Main = body }
for i, name in ipairs(TABS) do
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1 / #TABS, 0, 1, 0)
	b.Position = UDim2.new((i - 1) / #TABS, 0, 0, 0)
	b.BorderSizePixel = 0
	b.Text = name
	b.Font = Enum.Font.GothamBold
	b.TextSize = 10
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Parent = navBar
	tabButtons[name] = b
end

local function newPage(name, scroll, canvasH)
	local f = Instance.new(scroll and "ScrollingFrame" or "Frame")
	f.Size = UDim2.new(1, 0, 1, -56)
	f.Position = UDim2.fromOffset(0, 56)
	f.BackgroundTransparency = 1
	f.Visible = false
	if scroll then
		f.BorderSizePixel = 0
		f.ScrollBarThickness = 4
		f.CanvasSize = UDim2.fromOffset(0, canvasH or 336)
	end
	f.Parent = main
	pages[name] = f
	return f
end

local currentTab = "Main"
local minimized = false
local ACTIVE, INACTIVE = Color3.fromRGB(70, 70, 95), Color3.fromRGB(34, 34, 42)

local function refreshUI()
	navBar.Visible = not minimized
	for name, page in pairs(pages) do
		page.Visible = (not minimized) and currentTab == name
	end
	for name, b in pairs(tabButtons) do
		b.BackgroundColor3 = currentTab == name and ACTIVE or INACTIVE
	end
	main.Size = minimized and UDim2.fromOffset(460, 30) or UDim2.fromOffset(460, 260)
	minBtn.Text = minimized and "+" or "-"
end
for name, b in pairs(tabButtons) do
	b.MouseButton1Click:Connect(function()
		currentTab = name
		refreshUI()
	end)
end
minBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	refreshUI()
end)

-- Auto page (sell + compress)
local autoPage = newPage("Auto")
local sellBtn, sellBoxes = makeSection(autoPage, 0, 10, "Auto Sell",
	"Sells held trash weighing this many kg or below.", { { "100", "Sell up to kg" } })
local sellBox = sellBoxes[1]
sellBtn.Text = "AUTO SELL: OFF"
local compressBtn, compressBoxes = makeSection(autoPage, 0.5, 5, "Auto Compress",
	"Compresses held trash this many kg or below, then claims it.",
	{ { "400", "Compress up to kg" }, { "30", "Claim after (seconds)" } })
local compressBox, claimBox = compressBoxes[1], compressBoxes[2]
compressBtn.Text = "AUTO COMPRESS: OFF"
local autoStatus = pageStatus(autoPage, 168)

-- Combat page (scrolls): Aura | Hit Grabbers, then Hitbox Reach | info
local combatPage = newPage("Combat", true)
local auraBtn, auraBoxes = makeSection(combatPage, 0, 10, "Aura",
	"Equips the bat and spams hits at players in range (max 100).",
	{ { "20", "Range (1-100)" }, { "0.15", "Swing delay (sec)" } })
local auraBox, auraDelayBox = auraBoxes[1], auraBoxes[2]
auraBtn.Text = "AURA: OFF"
local hitGrabBtn, hitGrabBoxes = makeSection(combatPage, 0.5, 5, "Hit Grabbers",
	"Teleports to players holding trash, hits them, takes the drop.", { { "2", "Hits per player" } })
local hitCountBox = hitGrabBoxes[1]
hitGrabBtn.Text = "HIT GRABBERS: OFF"
local smartBtn, smartBoxes = makeSection(combatPage, 0, 10, "Hitbox Reach",
	"Quick-teleports to far players, hits, returns. Uses the aura range.",
	{ { "0.3", "Stay at target (sec)" } }, 170)
local stayBox = smartBoxes[1]
smartBtn.Text = "HITBOX REACH: OFF"

local infoCol = Instance.new("Frame")
infoCol.Size = UDim2.new(0.5, -15, 0, 150)
infoCol.Position = UDim2.new(0.5, 5, 0, 170)
infoCol.BackgroundColor3 = Color3.fromRGB(35, 35, 43)
infoCol.BorderSizePixel = 0
infoCol.Parent = combatPage
Instance.new("UICorner", infoCol).CornerRadius = UDim.new(0, 6)
local combatStatus = newText(infoCol, 8, 60, "Status: idle", 12, false)
local hitboxStatus = newText(infoCol, 78, 66, "Real hitbox: ...", 12, false)

-- Place page
local placePage = newPage("Place")
local function rowBox(y, labelText, default, placeholder)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.fromOffset(60, 28)
	l.Position = UDim2.fromOffset(10, y)
	l.BackgroundTransparency = 1
	l.Text = labelText
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Font = Enum.Font.Gotham
	l.TextSize = 12
	l.TextColor3 = Color3.fromRGB(220, 220, 230)
	l.Parent = placePage
	return makeBox(placePage, UDim2.fromOffset(72, y), UDim2.new(0.5, -82, 0, 28), default, placeholder)
end
local placeX = rowBox(10, "X", "33.09", "X")
local placeZ = rowBox(44, "Z", "-20.12", "Z")
local placeRot = rowBox(78, "Rotation", "0", "Rotation")
local placeTool = rowBox(112, "Tool", "", "name (empty = any)")
local usePosBtn = makeButton(placePage, UDim2.new(0.5, 5, 0, 10), UDim2.new(0.5, -15, 0, 34), "USE MY POSITION", Color3.fromRGB(60, 60, 90))
local placeNowBtn = makeButton(placePage, UDim2.new(0.5, 5, 0, 54), UDim2.new(0.5, -15, 0, 34), "PLACE NOW", Color3.fromRGB(60, 60, 90))
local autoPlaceBtn = makeButton(placePage, UDim2.new(0.5, 5, 0, 98), UDim2.new(0.5, -15, 0, 34), "AUTO PLACE: OFF")
local placeStatus = pageStatus(placePage, 150)

-- Teleport page
local tpPage = newPage("Teleport")
local function tpButton(xScale, text)
	local b = makeButton(tpPage, UDim2.new(xScale, 10, 0, 10), UDim2.new(1 / 3, -16, 0, 90), text, Color3.fromRGB(60, 60, 90))
	b.TextSize = 14
	return b
end
local tpBase = tpButton(0, "BASE (PLOT)")
local tpSell = tpButton(1 / 3, "SELL")
local tpCompress = tpButton(2 / 3, "TRASH COMPRESSOR")
local tpStatus = pageStatus(tpPage, 112)

refreshUI()

-- drag
do
	local dragging, startPos, startInput
	top.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging, startPos, startInput = true, main.Position, i.Position
			i.Changed:Connect(function()
				if i.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local d = i.Position - startInput
			main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
end

---------------------------------------------------------------- Trash list + filter
local buttons = {}
local SORTS = { "Highest kg", "Lowest kg", "Rarity", "Value" }
local sortIndex = 1
local RARITY_RANK = {
	common = 1, uncommon = 2, rare = 3, epic = 4, legendary = 5,
	mythic = 6, mythical = 6, divine = 7, secret = 8, exotic = 8,
}

local filterBtn = Instance.new("TextButton")
filterBtn.Size = UDim2.new(0.55, -15, 0, 26)
filterBtn.Position = UDim2.fromOffset(10, 10)
filterBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
filterBtn.Font = Enum.Font.GothamBold
filterBtn.TextSize = 12
filterBtn.TextColor3 = Color3.new(1, 1, 1)
filterBtn.Parent = body
Instance.new("UICorner", filterBtn).CornerRadius = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder

local function trashKg(t)
	local w = t.Name:match("%(([%d%.]+)%s*kg%)")
	if not w then w = t:GetAttribute("Weight") end
	return tonumber(w) or 0
end

-- looks for an attribute or a Value object with any of these names
local function readField(t, names)
	for _, n in ipairs(names) do
		local a = t:GetAttribute(n)
		if a ~= nil then return a end
		local c = t:FindFirstChild(n, true)
		if c and c:IsA("ValueBase") then return c.Value end
	end
end

local function trashRarity(t)
	return readField(t, { "Rarity", "Tier", "Grade" })
end

local function rarityRank(r)
	if r == nil then return 0 end
	if type(r) == "number" then return r end
	return RARITY_RANK[tostring(r):lower()] or 0
end

local function trashValue(t)
	local v = readField(t, { "Value", "Price", "Worth", "SellPrice", "Cost", "Money" })
	if v == nil then return 0 end
	if type(v) == "number" then return v end
	return tonumber((tostring(v):gsub("[^%d%.]", ""))) or 0
end

local function trashLabel(t)
	local text = t.Name
	local r = trashRarity(t)
	local v = trashValue(t)
	if r ~= nil then text = text .. " | " .. tostring(r) end
	if v > 0 then text = text .. " | $" .. v end
	return text
end

local function keyFor(t)
	local mode = SORTS[sortIndex]
	if mode == "Rarity" then return rarityRank(trashRarity(t)) end
	if mode == "Value" then return trashValue(t) end
	return trashKg(t)
end

local function resort()
	local mode = SORTS[sortIndex]
	local items, keys = {}, {}
	for t in pairs(buttons) do
		items[#items + 1] = t
		keys[t] = keyFor(t)
	end
	table.sort(items, function(a, b)
		local ka, kb = keys[a], keys[b]
		if ka ~= kb then
			if mode == "Lowest kg" then return ka < kb end
			return ka > kb
		end
		return a.Name < b.Name
	end)
	local best = 0
	for i, t in ipairs(items) do
		buttons[t].LayoutOrder = i
		if keys[t] > best then best = keys[t] end
	end
	if (mode == "Rarity" or mode == "Value") and best == 0 then
		filterBtn.Text = "Filter: " .. mode .. " (no data found)"
	else
		filterBtn.Text = "Filter: " .. mode .. "  (tap)"
	end
end

local sortQueued = false
local function queueResort()
	if sortQueued then return end
	sortQueued = true
	task.defer(function()
		sortQueued = false
		resort()
	end)
end

filterBtn.MouseButton1Click:Connect(function()
	sortIndex = sortIndex % #SORTS + 1
	resort()
end)

local function addTrash(trash)
	if buttons[trash] then return end
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, -6, 0, 24)
	b.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
	b.Text = trashLabel(trash) -- e.g. "Tire Stack (12kg) | Rare | $120"
	b.Font = Enum.Font.Gotham
	b.TextSize = 12
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Parent = list
	buttons[trash] = b
	b.MouseButton1Click:Connect(function()
		selected = trash
		selLabel.Text = "Selected: " .. trash.Name
	end)
	queueResort()
end

for _, t in ipairs(TrashFolder:GetChildren()) do addTrash(t) end
TrashFolder.ChildAdded:Connect(addTrash)
TrashFolder.ChildRemoved:Connect(function(t)
	if buttons[t] then buttons[t]:Destroy() buttons[t] = nil end
	if selected == t then
		selected = nil
		selLabel.Text = "Selected: none"
	end
end)
resort()

---------------------------------------------------------------- Helpers
local function getHRP()
	local c = lp.Character
	return c and c:FindFirstChild("HumanoidRootPart")
end

local function trim(s)
	return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

-- Detect which plot belongs to the local player (checks common owner patterns)
local function ownsPlot(plot)
	for _, k in ipairs({ "Owner", "OwnerId", "OwnerUserId", "Player", "PlotOwner" }) do
		local a = plot:GetAttribute(k)
		if a ~= nil and (a == lp.Name or a == lp.UserId or tostring(a) == tostring(lp.UserId)) then
			return true
		end
		local v = plot:FindFirstChild(k)
		if v and v:IsA("ValueBase") then
			local val = v.Value
			if val == lp or val == lp.Name or val == lp.UserId or tostring(val) == tostring(lp.UserId) then
				return true
			end
		end
	end
	return false
end

local function getMyPlot()
	for _, plot in ipairs(Plots:GetChildren()) do
		if ownsPlot(plot) then return plot end
	end
end

local function isHeld(name)
	return lp.Character and lp.Character:FindFirstChild(name) ~= nil
end

-- the trash a character is holding (a child with a TrashHandle)
local function heldTrashOf(char)
	if not char then return nil end
	for _, ch in ipairs(char:GetChildren()) do
		if ch:FindFirstChild("TrashHandle") then return ch end
	end
end

local function getHeld()
	return heldTrashOf(lp.Character)
end

local function getWeight(trash)
	local w = trash.Name:match("%(([%d%.]+)%s*kg%)")
	if not w then w = trash:GetAttribute("Weight") end
	return tonumber(w) or 0
end

-- teleport to a Model / Part (or the first part inside a Folder)
local function teleportTo(inst, up)
	local hrp = getHRP()
	if not hrp or not inst then return false end
	if not inst:IsA("PVInstance") then
		inst = inst:FindFirstChildWhichIsA("BasePart", true)
		if not inst then return false end
	end
	hrp.CFrame = inst:GetPivot() + Vector3.new(0, up or 3, 0)
	return true
end

local function returnToBase()
	local plot = getMyPlot()
	if plot then teleportTo(plot, 5) end
end

-- fire every ProximityPrompt inside an object without holding / pressing E
local function triggerPrompts(inst)
	if not inst then return end
	for _, d in ipairs(inst:GetDescendants()) do
		if d:IsA("ProximityPrompt") then
			d.HoldDuration = 0
			d.RequiresLineOfSight = false
			if fireproximityprompt then pcall(fireproximityprompt, d) end
		end
	end
end

-- Grab: triggers the prompt without holding/pressing E, then fires the remote.
local function tryGrab(trash)
	local name = trash.Name
	local prompt = trash:FindFirstChildWhichIsA("ProximityPrompt", true)
	if prompt then
		prompt.HoldDuration = 0
		prompt.RequiresLineOfSight = false
		if fireproximityprompt then pcall(fireproximityprompt, prompt) end
	end
	task.wait(0.4)
	if getHeld() then return true end

	-- remote method (handle may live in the trash or already in the character)
	local holder = (lp.Character and lp.Character:FindFirstChild(name)) or trash
	local handle = holder and holder:FindFirstChild("TrashHandle", true)
	if handle then
		pcall(function() PickupRemote:FireServer(handle) end)
	end
	task.wait(0.4)
	return getHeld() ~= nil
end

local function grabWithRetry(trash)
	for i = 1, 5 do
		setStatus("grabbing (" .. i .. "/5)")
		if tryGrab(trash) then return true end
		task.wait(0.3)
	end
	return false
end

---------------------------------------------------------------- Steal flow
-- teleport -> 1s -> grab -> 1s -> teleport to plot
local function stealInner(trash)
	local hrp = getHRP()
	if not hrp then setStatus("no character") return false end
	local plot = getMyPlot()
	if not plot then setStatus("your plot not found") return false end
	if not trash.Parent then return false end

	-- still carrying the last trash? deliver it first
	if getHeld() then
		setStatus("delivering held trash")
		hrp.CFrame = plot:GetPivot() + Vector3.new(0, 5, 0)
		task.wait(1.5)
		hrp = getHRP()
		if not hrp then return false end
		if getHeld() then
			setStatus("still holding trash")
			return false
		end
	end

	setStatus("teleporting to trash")
	hrp.CFrame = trash:GetPivot() + Vector3.new(0, 3, 0)
	task.wait(1)

	if not grabWithRetry(trash) then
		setStatus("Failed grab")
		warn("Failed grab")
		return false
	end
	task.wait(1)

	hrp = getHRP()
	if not hrp then return false end
	setStatus("teleporting to plot")
	hrp.CFrame = plot:GetPivot() + Vector3.new(0, 5, 0)
	return true
end

local function stealOne(trash)
	while acting do task.wait(0.1) end -- wait if another feature is moving us
	stealing = true
	local ok, result = pcall(stealInner, trash)
	stealing = false
	return ok and result
end

-- manual steal
stealBtn.MouseButton1Click:Connect(function()
	if busy then return end
	if not selected or not selected.Parent then
		setStatus("select a trash first")
		return
	end
	busy = true
	if stealOne(selected) then setStatus("done") end
	busy = false
end)

-- autosteal: keeps stealing until the total reaches the kg limit
local autoOn = false

local function getLimit()
	return math.max(tonumber(limitBox.Text) or 1000, 1)
end

-- is there any trash that still fits in the remaining kg?
local function anyFits(remaining)
	for _, t in ipairs(TrashFolder:GetChildren()) do
		local w = getWeight(t)
		if w > 0 and w <= remaining then return true end
	end
	return false
end

-- AUTOSTEAL TARGET MODES
local SMART_MODES = { "Priority", "Priority only", "Smart", "Highest kg", "Closest", "Highest value", "Rarest" }
local modeIndex = 1
modeBtn.Text = "Mode: " .. SMART_MODES[modeIndex] .. " (tap)"

local function otherPlayerNear(pos, radius)
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= lp and p.Character then
			local h = p.Character:FindFirstChild("HumanoidRootPart")
			if h and (h.Position - pos).Magnitude <= radius then return true end
		end
	end
	return false
end

-- priority: Mythic first, then Secret, then Epic
local function priorityTier(t)
	local r = trashRarity(t)
	if r == nil then return 0 end
	local s = tostring(r):lower()
	if s:find("mythic", 1, true) then return 3 end
	if s:find("secret", 1, true) then return 2 end
	if s:find("epic", 1, true) then return 1 end
	return 0
end

local function scoreTrash(t, mode, hrp)
	local kg = getWeight(t)
	if mode == "Highest kg" then return kg end
	if mode == "Closest" then
		if not hrp then return 0 end
		return -(t:GetPivot().Position - hrp.Position).Magnitude
	end
	if mode == "Highest value" then return trashValue(t) + kg / 10000 end
	if mode == "Rarest" then return rarityRank(trashRarity(t)) * 10000 + kg end

	-- Smart / Priority: best value, else best rarity, else heaviest. Trash next to another player counts half.
	local v = trashValue(t)
	local rank = rarityRank(trashRarity(t))
	local base
	if v > 0 then
		base = v
	elseif rank > 0 then
		base = rank * 100 + kg / 100
	else
		base = kg
	end
	if otherPlayerNear(t:GetPivot().Position, 25) then base = base * 0.5 end
	if mode == "Priority" or mode == "Priority only" then
		base = base + priorityTier(t) * 1e9
	end
	return base
end

modeBtn.MouseButton1Click:Connect(function()
	modeIndex = modeIndex % #SMART_MODES + 1
	modeBtn.Text = "Mode: " .. SMART_MODES[modeIndex] .. " (tap)"
end)

-- best trash that still fits (skips ones on cooldown)
local function pickNext(remaining, cooldown)
	local mode = SMART_MODES[modeIndex]
	local hrp = getHRP()
	local best, bestW, bestScore
	for _, t in ipairs(TrashFolder:GetChildren()) do
		local w = getWeight(t)
		local cd = cooldown[t]
		if w > 0 and w <= remaining and not (cd and os.clock() < cd)
			and not (mode == "Priority only" and priorityTier(t) == 0) then
			local s = scoreTrash(t, mode, hrp)
			if not bestScore or s > bestScore then best, bestW, bestScore = t, w, s end
		end
	end
	return best, bestW
end

local function setAutoUI(on)
	autoBtn.Text = on and "AUTOSTEAL: ON" or "AUTOSTEAL: OFF"
	autoBtn.BackgroundColor3 = on and Color3.fromRGB(60, 160, 80) or Color3.fromRGB(60, 60, 75)
end

local function toggleAutoSteal()
	if autoOn then autoOn = false return end
	if busy then return end

	autoOn, busy = true, true
	setAutoUI(true)
	task.spawn(function()
		local limit, total = getLimit(), 0
		local cooldown, fails = {}, 0
		local reason = "stopped"
		while autoOn do
			if not getHRP() or not getMyPlot() then
				-- respawned / ragdolled / plot not loaded yet: wait instead of giving up
				setStatus("waiting for character / plot...")
				task.wait(1)
			else
				local remaining = limit - total
				local t, w = pickNext(remaining, cooldown)
				if not t then
					if SMART_MODES[modeIndex] == "Priority only" or anyFits(remaining) then
						setStatus("waiting for trash... " .. total .. "/" .. limit .. "kg")
						task.wait(1)
					else
						reason = "finished " .. total .. "/" .. limit .. "kg"
						break
					end
				else
					if stealOne(t) then
						total = total + w
						fails = 0
						cooldown[t] = os.clock() + 30
						setStatus("stolen " .. total .. "/" .. limit .. "kg")
					else
						cooldown[t] = os.clock() + 8
						fails = fails + 1
						if fails >= 8 then
							reason = "stopped: 8 steals failed in a row"
							break
						end
					end
					task.wait(0.5)
				end
			end
		end
		autoOn, busy = false, false
		setAutoUI(false)
		setStatus(reason)
	end)
end
autoBtn.MouseButton1Click:Connect(toggleAutoSteal)

---------------------------------------------------------------- Teleport tab
local function tpTo(inst, name, up)
	if not inst then
		tpStatus.Text = "Status: " .. name .. " not found"
	elseif teleportTo(inst, up) then
		tpStatus.Text = "Status: teleported to " .. name
	else
		tpStatus.Text = "Status: no character"
	end
end

tpBase.MouseButton1Click:Connect(function() tpTo(getMyPlot(), "your plot", 5) end)
tpSell.MouseButton1Click:Connect(function() tpTo(workspace:FindFirstChild("SellTeleport"), "SellTeleport", 3) end)
tpCompress.MouseButton1Click:Connect(function() tpTo(workspace:FindFirstChild("TrashCompressor"), "TrashCompressor", 3) end)

---------------------------------------------------------------- Sell ID finder
-- The sell remote needs an ID. We find it two ways:
--  1) catch the ID when the game's own script fires TrashSellAnimationComplete
--  2) catch a GUID the server sends to us through any RemoteEvent
local sellId = nil

local function isGuid(s)
	return type(s) == "string" and s:match("^%x+%-%x+%-%x+%-%x+%-%x+$") ~= nil
end

local function scanArgs(args)
	for _, a in ipairs(args) do
		if isGuid(a) then
			sellId = a
		elseif type(a) == "table" then
			for _, v in pairs(a) do
				if isGuid(v) then sellId = v end
			end
		end
	end
end

if hookmetamethod and getnamecallmethod then
	local old
	local function hook(self, ...)
		if self == SellRemote and getnamecallmethod() == "FireServer" then
			scanArgs({ ... })
		end
		return old(self, ...)
	end
	old = hookmetamethod(game, "__namecall", newcclosure and newcclosure(hook) or hook)
end

local function hookRemote(r)
	if r:IsA("RemoteEvent") and r ~= SellRemote and r ~= CompressRemote and r ~= PickupRemote
		and r ~= SwingRemote and r ~= PlaceRemote and r ~= HitboxVisual then
		r.OnClientEvent:Connect(function(...) scanArgs({ ... }) end)
	end
end
for _, r in ipairs(RS:GetDescendants()) do hookRemote(r) end
RS.DescendantAdded:Connect(hookRemote)

---------------------------------------------------------------- Auto sell / compress
local autoSellOn, autoCompressOn = false, false
local pendingClaim, claimAt = false, 0

local function setToggle(btn, on, text)
	btn.Text = text .. (on and ": ON" or ": OFF")
	btn.BackgroundColor3 = on and Color3.fromRGB(60, 160, 80) or Color3.fromRGB(60, 60, 75)
end

sellBtn.MouseButton1Click:Connect(function()
	autoSellOn = not autoSellOn
	setToggle(sellBtn, autoSellOn, "AUTO SELL")
end)
compressBtn.MouseButton1Click:Connect(function()
	autoCompressOn = not autoCompressOn
	setToggle(compressBtn, autoCompressOn, "AUTO COMPRESS")
end)

-- held trash -> teleport to the sell spot -> sell -> back to base
local function sellHeld(held)
	local name = held.Name
	local spot = workspace:FindFirstChild("SellTeleport")
	if not spot then autoStatus.Text = "Status: SellTeleport not found" return end

	autoStatus.Text = "Status: going to sell " .. name
	teleportTo(spot, 3)
	task.wait(1.5) -- the game may sell by itself when you arrive

	if isHeld(name) then
		triggerPrompts(spot)
		task.wait(0.3)
		if sellId then
			pcall(function() SellRemote:FireServer(sellId) end)
		end
		task.wait(1)
	end

	if isHeld(name) then
		autoStatus.Text = "Status: sell failed" .. (sellId and "" or " (no sell ID found yet)")
	else
		autoStatus.Text = "Status: sold " .. name
	end
	returnToBase()
end

-- held trash -> teleport to the compressor -> compress -> back to base
local function compressHeld(held)
	local name = held.Name
	local spot = workspace:FindFirstChild("TrashCompressor")
	if not spot then autoStatus.Text = "Status: TrashCompressor not found" return end

	autoStatus.Text = "Status: going to compress " .. name
	teleportTo(spot, 3)
	task.wait(1)

	triggerPrompts(spot)
	task.wait(0.3)
	pcall(function() CompressRemote:FireServer("Insert") end)
	task.wait(1)

	if isHeld(name) then
		autoStatus.Text = "Status: compress failed"
	else
		local secs = math.max(tonumber(claimBox.Text) or 30, 1)
		pendingClaim, claimAt = true, os.clock() + secs
		autoStatus.Text = "Status: compressing " .. name .. " (claim in " .. secs .. "s)"
	end
	returnToBase()
end

-- after the compressor timer ends: go back and claim
local function claimCompressed()
	local spot = workspace:FindFirstChild("TrashCompressor")
	if not spot then
		pendingClaim = false
		autoStatus.Text = "Status: TrashCompressor not found"
		return
	end

	autoStatus.Text = "Status: claiming compressed trash"
	teleportTo(spot, 3)
	task.wait(1)
	for _ = 1, 3 do
		triggerPrompts(spot)
		pcall(function() CompressRemote:FireServer("Claim") end)
		task.wait(0.5)
	end
	pendingClaim = false
	autoStatus.Text = "Status: claimed"
	returnToBase()
end

local function runLocked(fn, ...)
	acting = true
	local ok, err = pcall(fn, ...)
	acting = false
	if not ok then warn(err) end
end

local lastTry = setmetatable({}, { __mode = "k" })

task.spawn(function()
	while task.wait(0.5) do
		if not stealing and not acting then
			if pendingClaim and os.clock() >= claimAt then
				runLocked(claimCompressed)
			elseif autoSellOn or autoCompressOn then
				local held = getHeld()
				if held and (os.clock() - (lastTry[held] or 0)) >= 4 then
					local weight = getWeight(held)
					local compressLimit = tonumber(compressBox.Text)
					local sellLimit = tonumber(sellBox.Text)

					local wantCompress = autoCompressOn and compressLimit and weight > 0 and weight <= compressLimit
					if wantCompress then
						-- compressor is busy until the claim is done, so wait
						if not pendingClaim then
							lastTry[held] = os.clock()
							runLocked(compressHeld, held)
						end
					elseif autoSellOn and sellLimit and weight > 0 and weight <= sellLimit then
						lastTry[held] = os.clock()
						runLocked(sellHeld, held)
					end
				end
			end
		end
	end
end)

---------------------------------------------------------------- Tools / combat helpers
local function allTools()
	local out = {}
	for _, container in ipairs({ lp.Character or false, lp:FindFirstChildOfClass("Backpack") or false }) do
		if container then
			for _, ch in ipairs(container:GetChildren()) do
				if ch:IsA("Tool") then out[#out + 1] = ch end
			end
		end
	end
	return out
end

local function findBat()
	local tools = allTools()
	for _, t in ipairs(tools) do
		if t:FindFirstChild("ToolClient") then return t end
	end
	for _, t in ipairs(tools) do
		if t.Name:lower():find("bat", 1, true) then return t end
	end
end

local function equipTool(tool)
	if not tool or not tool.Parent then return false end
	local c = lp.Character
	local hum = c and c:FindFirstChildOfClass("Humanoid")
	if not hum then return false end
	if tool.Parent ~= c then
		hum:EquipTool(tool)
		task.wait(0.2)
	end
	return tool.Parent == c
end

-- CanUseTool permission (false = safe zone). Cached for 1 second so swings can be fast.
local permOk, permAt = false, 0
local function canUse()
	if os.clock() - permAt < 1 then return permOk end
	local ok, res = pcall(function() return CanUseRemote:InvokeServer() end)
	permOk = ok and res == true
	permAt = os.clock()
	return permOk
end

-- the game's REAL hitbox (set by the server, read from ToolHitboxVisual)
local function hitboxInfo()
	local size = HitboxVisual and HitboxVisual:GetAttribute("HitboxSize")
	local off = HitboxVisual and HitboxVisual:GetAttribute("HitboxOffset")
	if typeof(size) ~= "Vector3" then size = Vector3.new(6, 6, 7) end
	if typeof(off) ~= "Vector3" then off = Vector3.new(0, 0, 3.5) end
	return size, off
end

-- is the target inside the bat's real hitbox right now?
local function insideBox(hrp, thrp)
	local size, off = hitboxInfo()
	local boxCF = hrp.CFrame * CFrame.new(off.X, off.Y, -off.Z)
	local rel = boxCF:PointToObjectSpace(thrp.Position)
	return math.abs(rel.X) <= size.X / 2 + 1
		and math.abs(rel.Y) <= size.Y / 2 + 1
		and math.abs(rel.Z) <= size.Z / 2 + 1
end

-- count the hits the server really confirms (the game's own "Hit" event)
local hitsLanded = 0
if HitboxVisual then
	HitboxVisual.OnClientEvent:Connect(function(kind, player)
		if kind == "Hit" and player == lp then
			hitsLanded = hitsLanded + 1
		end
	end)
end

-- swing CFrame placed next to a far target (only used when Hitbox Reach is off)
local function aimCFrame(thrp, dir)
	local origin = thrp.Position - dir * 3
	return CFrame.lookAt(origin, origin + dir)
end

local smartOn = true
local lastActivate = 0

-- one swing at a target. Returns true, or false + the reason.
local function smartSwing(thrp)
	local bat = findBat()
	if not bat then return false, "no bat found" end
	if not equipTool(bat) then return false, "couldn't equip the bat" end
	if not canUse() then return false, "blocked (safe zone?)" end
	local hrp = getHRP()
	if not hrp or not thrp then return false, "no character / target" end

	local flat = Vector3.new(thrp.Position.X - hrp.Position.X, 0, thrp.Position.Z - hrp.Position.Z)
	local dir = flat.Magnitude > 0.1 and flat.Unit or hrp.CFrame.LookVector
	local saved = hrp.CFrame
	local moved = false

	-- face the target
	hrp.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + dir)

	if smartOn and not stealing and not insideBox(hrp, thrp) then
		-- hitbox reach: stand so the target is in the middle of the REAL hitbox
		local _, off = hitboxInfo()
		local stand = thrp.Position - dir * off.Z
		hrp.CFrame = CFrame.lookAt(stand, stand + dir)
		moved = true
		task.wait(0.08) -- let the server see the new position
	end

	local cf = hrp.CFrame
	if not moved and flat.Magnitude > 12 then
		cf = aimCFrame(thrp, dir) -- reach off: fake position next to the target
	end

	SwingRemote:FireServer(cf, workspace:GetServerTimeNow())

	-- also use the bat's own click (animation + its own swing) about once a second
	if os.clock() - lastActivate >= 1.05 then
		lastActivate = os.clock()
		pcall(function() bat:Activate() end)
	end

	if moved then
		-- the server's hitbox follows us for ~0.2s, so stay a moment, then go back
		task.wait(math.max(tonumber(stayBox.Text) or 0.3, 0.25))
		local h2 = getHRP()
		if h2 then h2.CFrame = saved end
	end
	return true
end

local function nearestTarget(radius)
	local hrp = getHRP()
	if not hrp then return nil end
	local best, bestD
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= lp and p.Character then
			local th = p.Character:FindFirstChild("HumanoidRootPart")
			local hum = p.Character:FindFirstChildOfClass("Humanoid")
			if th and hum and hum.Health > 0 then
				local d = (th.Position - hrp.Position).Magnitude
				if d <= radius and (not bestD or d < bestD) then best, bestD = th, d end
			end
		end
	end
	return best
end

---------------------------------------------------------------- Hitbox Reach toggle + info
setToggle(smartBtn, smartOn, "HITBOX REACH")
smartBtn.MouseButton1Click:Connect(function()
	smartOn = not smartOn
	setToggle(smartBtn, smartOn, "HITBOX REACH")
end)

task.spawn(function()
	while task.wait(0.5) do
		local size, off = hitboxInfo()
		hitboxStatus.Text = string.format("Real hitbox: %.0fx%.0fx%.0f, %.1f ahead\nHits landed: %d",
			size.X, size.Y, size.Z, off.Z, hitsLanded)
	end
end)

---------------------------------------------------------------- Aura
local auraOn, hitGrabOn = false, false
local auraEquipped, auraIdleSince = false, 0

local function toggleAura()
	auraOn = not auraOn
	setToggle(auraBtn, auraOn, "AURA")
end
auraBtn.MouseButton1Click:Connect(toggleAura)

task.spawn(function()
	local lastSwing = 0
	while task.wait(0.05) do
		if auraOn and not acting then
			local hrp = getHRP()
			local radius = math.clamp(tonumber(auraBox.Text) or 20, 1, 100)
			local delay = math.max(tonumber(auraDelayBox.Text) or 0.15, 0.05)
			local target = hrp and nearestTarget(radius)
			if target then
				auraIdleSince = 0
				if os.clock() - lastSwing >= delay then
					lastSwing = os.clock()
					acting = true -- block steal/sell moves while we reach the target
					local called, ok, why = pcall(smartSwing, target)
					acting = false
					if not called then ok, why = false, ok end
					if ok then
						auraEquipped = true
						combatStatus.Text = "Status: aura swinging at " .. target.Parent.Name
					else
						combatStatus.Text = "Status: aura failed - " .. tostring(why)
					end
				end
			elseif auraEquipped then
				-- nobody nearby for 3s: put the bat away again
				if auraIdleSince == 0 then auraIdleSince = os.clock() end
				if os.clock() - auraIdleSince >= 3 then
					local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
					if hum then hum:UnequipTools() end
					auraEquipped, auraIdleSince = false, 0
				end
			end
		end
	end
end)

---------------------------------------------------------------- Hit grabbers
hitGrabBtn.MouseButton1Click:Connect(function()
	hitGrabOn = not hitGrabOn
	setToggle(hitGrabBtn, hitGrabOn, "HIT GRABBERS")
end)

-- after a hit the trash drops into workspace.DroppedTrash: take the nearest one
local function grabDroppedNear(pos, radius)
	local folder = workspace:FindFirstChild("DroppedTrash")
	if not folder then return false end
	local best, bestD
	for _, t in ipairs(folder:GetChildren()) do
		if t:IsA("PVInstance") then
			local d = (t:GetPivot().Position - pos).Magnitude
			if d <= radius and (not bestD or d < bestD) then best, bestD = t, d end
		end
	end
	if not best then return false end

	teleportTo(best, 3)
	task.wait(1)
	if grabWithRetry(best) then
		task.wait(1)
		returnToBase()
		return true
	end
	return false
end

local function hitGrabber(p)
	local c = p.Character
	local thrp = c and c:FindFirstChild("HumanoidRootPart")
	local hrp = getHRP()
	if not thrp or not hrp then return end

	local saved = hrp.CFrame
	local dropPos = thrp.Position
	combatStatus.Text = "Status: hitting " .. p.Name
	setStatus("hitting " .. p.Name)

	for _ = 1, math.max(tonumber(hitCountBox.Text) or 2, 1) do
		if not heldTrashOf(p.Character) then break end -- already dropped it
		thrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
		hrp = getHRP()
		if not thrp or not hrp then break end

		local behind = (thrp.CFrame * CFrame.new(0, 0, 3)).Position
		hrp.CFrame = CFrame.lookAt(behind, thrp.Position)
		task.wait(0.2)
		local ok, why = smartSwing(thrp)
		if not ok then combatStatus.Text = "Status: hit failed - " .. tostring(why) end
		dropPos = thrp.Position
		task.wait(1.1)
	end

	task.wait(0.3)
	if grabDroppedNear(dropPos, 25) then
		combatStatus.Text = "Status: took " .. p.Name .. "'s trash"
	else
		combatStatus.Text = "Status: hit " .. p.Name
		local hrp2 = getHRP()
		if hrp2 then hrp2.CFrame = saved end
	end
end

local grabCooldown = {}

task.spawn(function()
	while task.wait(0.5) do
		if hitGrabOn and not stealing and not acting and getHRP() then
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= lp and heldTrashOf(p.Character) and os.clock() >= (grabCooldown[p] or 0) then
					grabCooldown[p] = os.clock() + 12
					runLocked(hitGrabber, p)
					break
				end
			end
		end
	end
end)

---------------------------------------------------------------- Auto place plot
local autoPlaceOn = false

local function getPlaceTool()
	local wanted = trim(placeTool.Text):lower()
	for _, t in ipairs(allTools()) do
		if not t:FindFirstChild("ToolClient") then -- skip the bat
			if wanted == "" or t.Name:lower():find(wanted, 1, true) then return t end
		end
	end
end

local function placeOnce()
	local tool = getPlaceTool()
	if not tool then placeStatus.Text = "Status: no tool to place" return false end
	local x, z = tonumber(placeX.Text), tonumber(placeZ.Text)
	local rot = tonumber(placeRot.Text) or 0
	if not x or not z then placeStatus.Text = "Status: X / Z must be numbers" return false end

	equipTool(tool)
	pcall(function() PlaceRemote:FireServer(tool, x, z, rot) end)
	placeStatus.Text = "Status: placed " .. tool.Name
	return true
end

usePosBtn.MouseButton1Click:Connect(function()
	local hrp = getHRP()
	if not hrp then placeStatus.Text = "Status: no character" return end
	placeX.Text = string.format("%.2f", hrp.Position.X)
	placeZ.Text = string.format("%.2f", hrp.Position.Z)
	placeStatus.Text = "Status: position copied"
end)

placeNowBtn.MouseButton1Click:Connect(function()
	task.spawn(placeOnce)
end)

autoPlaceBtn.MouseButton1Click:Connect(function()
	autoPlaceOn = not autoPlaceOn
	setToggle(autoPlaceBtn, autoPlaceOn, "AUTO PLACE")
end)

task.spawn(function()
	while task.wait(1.5) do
		if autoPlaceOn and not stealing and not acting then
			pcall(placeOnce)
		end
	end
end)

---------------------------------------------------------------- Visual tab: Trash ESP
-- (runs in its own protected function: keeps the main local-variable count low,
--  and an error here can't stop the rest of the menu)
xpcall(function()
	local visualPage = newPage("Visual")
	local espBtn, espBoxes = makeSection(visualPage, 0, 10, "Trash ESP",
		"Shows name, kg, rarity and value above trash in the world.", { { "300", "Max distance (studs)" } })
	local distBox = espBoxes[1]
	espBtn.Text = "TRASH ESP: OFF"
	local colorBtn, rangeBoxes = makeSection(visualPage, 0.5, 5, "ESP Filter",
		"Only show trash inside this kg range.", { { "0", "Min kg" }, { "", "Max kg (empty = any)" } })
	local minBox, maxBox = rangeBoxes[1], rangeBoxes[2]
	local colorsOn = true
	setToggle(colorBtn, colorsOn, "RARITY COLORS")
	local espStatus = pageStatus(visualPage, 168)

	local espOn = false
	local espObjs = {}
	local espFolder = Instance.new("Folder")
	espFolder.Name = "ESP"
	espFolder.Parent = gui

	local RARITY_COLORS = {
		Color3.fromRGB(255, 255, 255), Color3.fromRGB(80, 200, 90), Color3.fromRGB(70, 140, 255),
		Color3.fromRGB(170, 90, 255), Color3.fromRGB(255, 150, 40), Color3.fromRGB(255, 70, 70),
		Color3.fromRGB(255, 215, 60), Color3.fromRGB(255, 120, 200),
	}

	local function espPart(t)
		if t:IsA("BasePart") then return t end
		if t:IsA("Model") and t.PrimaryPart then return t.PrimaryPart end
		return t:FindFirstChildWhichIsA("BasePart", true)
	end

	local function makeESP(t)
		local part = espPart(t)
		if not part then return nil end
		local bb = Instance.new("BillboardGui")
		bb.Adornee = part
		bb.AlwaysOnTop = true
		bb.Size = UDim2.fromOffset(160, 36)
		bb.StudsOffset = Vector3.new(0, 3, 0)
		bb.Parent = espFolder
		local tl = Instance.new("TextLabel")
		tl.Size = UDim2.fromScale(1, 1)
		tl.BackgroundTransparency = 1
		tl.Font = Enum.Font.GothamBold
		tl.TextSize = 12
		tl.TextWrapped = true
		tl.TextStrokeTransparency = 0.3
		tl.Parent = bb
		return { bb = bb, tl = tl, part = part }
	end

	local function clearESP()
		for t, o in pairs(espObjs) do
			o.bb:Destroy()
			espObjs[t] = nil
		end
	end

	espBtn.MouseButton1Click:Connect(function()
		espOn = not espOn
		setToggle(espBtn, espOn, "TRASH ESP")
		if not espOn then
			clearESP()
			espStatus.Text = "Status: off"
		end
	end)
	colorBtn.MouseButton1Click:Connect(function()
		colorsOn = not colorsOn
		setToggle(colorBtn, colorsOn, "RARITY COLORS")
	end)

	task.spawn(function()
		while task.wait(0.5) do
			if espOn then
				local hrp = getHRP()
				local maxD = tonumber(distBox.Text) or 300
				local minKg = tonumber(minBox.Text) or 0
				local maxKg = tonumber(maxBox.Text) or math.huge
				local shown = 0

				for t, o in pairs(espObjs) do
					if not t.Parent then
						o.bb:Destroy()
						espObjs[t] = nil
					end
				end

				for _, t in ipairs(TrashFolder:GetChildren()) do
					local o = espObjs[t]
					local part = (o and o.part) or espPart(t)
					local kg = getWeight(t)
					local show = part and hrp and (part.Position - hrp.Position).Magnitude <= maxD
						and kg >= minKg and kg <= maxKg
					if show then
						if not o then
							o = makeESP(t)
							espObjs[t] = o
						end
						if o then
							local r = trashRarity(t)
							local v = trashValue(t)
							local text = t.Name
							if r ~= nil then text = text .. "\n" .. tostring(r) end
							if v > 0 then text = text .. (r ~= nil and " | $" or "\n$") .. v end
							o.tl.Text = text
							o.tl.TextColor3 = colorsOn and (RARITY_COLORS[rarityRank(r)] or RARITY_COLORS[1]) or RARITY_COLORS[1]
							o.bb.Enabled = true
							shown = shown + 1
						end
					elseif o then
						o.bb.Enabled = false
					end
				end
				espStatus.Text = "Status: showing " .. shown .. " trash"
			end
		end
	end)
end, function(e) warn("[Visual tab error] " .. tostring(e)) end)

---------------------------------------------------------------- Predict tab: real-time spawn clock + learning + last seen + copy
xpcall(function()
	local StarterGui = game:GetService("StarterGui")
	local predictPage = newPage("Predict", true, 900)

	-- on-screen banner (shows even if the game blocks normal notifications)
	local banner = Instance.new("TextLabel")
	banner.Size = UDim2.fromOffset(330, 46)
	banner.Position = UDim2.new(0.5, -165, 0, 12)
	banner.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	banner.BackgroundTransparency = 0.1
	banner.Font = Enum.Font.GothamBold
	banner.TextSize = 13
	banner.TextWrapped = true
	banner.TextColor3 = Color3.new(1, 1, 1)
	banner.Visible = false
	banner.ZIndex = 50
	banner.Parent = gui
	Instance.new("UICorner", banner).CornerRadius = UDim.new(0, 8)
	local bannerToken = 0

	local function notify(titleText, text, color)
		pcall(function()
			StarterGui:SetCore("SendNotification", { Title = titleText, Text = text, Duration = 5 })
		end)
		bannerToken = bannerToken + 1
		local mine = bannerToken
		banner.Text = titleText .. "\n" .. text
		banner.TextColor3 = color or Color3.new(1, 1, 1)
		banner.Visible = true
		task.delay(5, function()
			if bannerToken == mine then banner.Visible = false end
		end)
	end

	-- real time (server clock, seconds since 1970)
	local function nowSec()
		local ok, t = pcall(function() return workspace:GetServerTimeNow() end)
		if ok and type(t) == "number" then return t end
		return os.time()
	end
	local function fmt(s)
		s = math.max(math.floor(s), 0)
		return string.format("%02d:%02d", math.floor(s / 60), s % 60)
	end
	local function clockStr(t, pattern)
		local ok, s = pcall(os.date, pattern or "%I:%M %p", math.floor(t))
		return ok and s or "?"
	end

	-- big countdown panel
	local clockPanel = Instance.new("Frame")
	clockPanel.Size = UDim2.new(1, -20, 0, 62)
	clockPanel.Position = UDim2.fromOffset(10, 10)
	clockPanel.BackgroundColor3 = Color3.fromRGB(35, 35, 43)
	clockPanel.BorderSizePixel = 0
	clockPanel.Parent = predictPage
	Instance.new("UICorner", clockPanel).CornerRadius = UDim.new(0, 6)
	local clockLabel = newText(clockPanel, 6, 52, "...", 13, true)

	-- notify settings
	local spawnBtn, spawnBoxes = makeSection(predictPage, 0, 10, "Spawn Notify",
		"Warns before each 5-min spawn and when it happens.", { { "15", "Warn before (sec)" } }, 80)
	local warnBox = spawnBoxes[1]
	local mythicBtn, mythicBoxes = makeSection(predictPage, 0.5, 5, "Mythic Notify",
		"Warns before the hourly guaranteed mythic and when it spawns.", { { "60", "Warn before (sec)" } }, 80)
	local mWarnBox = mythicBoxes[1]
	local alertBtn, alertBoxes = makeSection(predictPage, 0, 10, "Item Alert",
		"Notifies for every new trash at or above this kg.", { { "0", "Alert min kg (0 = all)" } }, 240)
	local alertBox = alertBoxes[1]
	local resetBtn = makeSection(predictPage, 0.5, 5, "Learning",
		"Learns spawn chances from what it sees. Reset to start over.", {}, 240)
	resetBtn.Text = "RESET LEARNED DATA"

	local spawnNotifyOn, mythicNotifyOn, itemAlertOn = true, true, false
	setToggle(spawnBtn, spawnNotifyOn, "SPAWN NOTIFY")
	setToggle(mythicBtn, mythicNotifyOn, "MYTHIC NOTIFY")
	setToggle(alertBtn, itemAlertOn, "ITEM ALERT")
	spawnBtn.MouseButton1Click:Connect(function()
		spawnNotifyOn = not spawnNotifyOn
		setToggle(spawnBtn, spawnNotifyOn, "SPAWN NOTIFY")
	end)
	mythicBtn.MouseButton1Click:Connect(function()
		mythicNotifyOn = not mythicNotifyOn
		setToggle(mythicBtn, mythicNotifyOn, "MYTHIC NOTIFY")
	end)
	alertBtn.MouseButton1Click:Connect(function()
		itemAlertOn = not itemAlertOn
		setToggle(alertBtn, itemAlertOn, "ITEM ALERT")
	end)

	-- prediction panel
	local panel = Instance.new("Frame")
	panel.Size = UDim2.new(1, -20, 0, 284)
	panel.Position = UDim2.fromOffset(10, 400)
	panel.BackgroundColor3 = Color3.fromRGB(35, 35, 43)
	panel.BorderSizePixel = 0
	panel.Parent = predictPage
	Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 6)
	local infoLabel = newText(panel, 8, 200, "Learning...", 11, false)
	local goSpotBtn = makeButton(panel, UDim2.fromOffset(8, 214), UDim2.new(1, -16, 0, 28),
		"GO TO TOP SPAWN SPOT", Color3.fromRGB(60, 60, 90))
	local goMythicBtn = makeButton(panel, UDim2.fromOffset(8, 246), UDim2.new(1, -16, 0, 28),
		"GO TO MYTHIC SPOT", Color3.fromRGB(120, 90, 30))

	-- last seen panel
	local seenPanel = Instance.new("Frame")
	seenPanel.Size = UDim2.new(1, -20, 0, 140)
	seenPanel.Position = UDim2.fromOffset(10, 694)
	seenPanel.BackgroundColor3 = Color3.fromRGB(35, 35, 43)
	seenPanel.BorderSizePixel = 0
	seenPanel.Parent = predictPage
	Instance.new("UICorner", seenPanel).CornerRadius = UDim.new(0, 6)
	local seenLabel = newText(seenPanel, 8, 126, "Last seen: ...", 11, false)

	-- copy data button
	local copyBtn = makeButton(predictPage, UDim2.fromOffset(10, 844), UDim2.new(1, -20, 0, 30),
		"COPY PREDICTION DATA", Color3.fromRGB(60, 60, 90))

	---------------- learned data (all in one table so it can be reset)
	local L = {
		types = {}, info = {}, nW = {}, hW = {}, nTot = 0, hTot = 0,
		waves = {}, spots = {}, mSpots = {}, mythicTypes = {},
		lagSum = 0, lagN = 0, haveRarity = false, topSpot = nil, mSpot = nil,
		lastSeen = {}, -- rarity -> { time, label }
		log = {}, -- every new spawn: { time, label, rarity, hour }
	}

	local RARITY_ORDER = { "secret", "mythic", "legendary", "epic", "rare", "uncommon", "common" }
	local RARITY_SET = {}
	for _, r in ipairs(RARITY_ORDER) do RARITY_SET[r] = true end
	local function rarityKey(r)
		if type(r) ~= "string" then return nil end
		local k = r:lower()
		if k == "mythical" then k = "mythic" end
		if RARITY_SET[k] then return k end
		return nil
	end
	local function cap(s) return s:sub(1, 1):upper() .. s:sub(2) end

	local function partPos(t)
		if t:IsA("PVInstance") then return t:GetPivot().Position end
		local p = t:FindFirstChildWhichIsA("BasePart", true)
		return p and p.Position
	end

	local function addSpot(tbl, pos)
		local gx = math.floor(pos.X / 20 + 0.5) * 20
		local gz = math.floor(pos.Z / 20 + 0.5) * 20
		local k = gx .. "," .. gz
		local s = tbl[k]
		if not s then
			s = { x = gx, y = pos.Y, z = gz, n = 0 }
			tbl[k] = s
		end
		s.n = s.n + 1
		s.y = pos.Y
	end

	local function sortedSpots(tbl)
		local out = {}
		for _, s in pairs(tbl) do out[#out + 1] = s end
		table.sort(out, function(a, b) return a.n > b.n end)
		return out
	end

	local function describe(t)
		local text = t.Name
		local kg = getWeight(t)
		if kg > 0 and not text:find("kg%)") then text = text .. " (" .. kg .. "kg)" end
		local r, v = trashRarity(t), trashValue(t)
		if r ~= nil then text = text .. " | " .. tostring(r) end
		if v > 0 then text = text .. " | $" .. v end
		return text
	end

	local function isMythic(t)
		local r = trashRarity(t)
		if r == nil then return false end
		if type(r) == "string" then return r:lower():find("mythic", 1, true) ~= nil end
		return rarityRank(r) >= 6
	end

	local lastItemAlert = 0

	local function record(t, isNew)
		local key = t.Name
		local kg, v = getWeight(t), trashValue(t)
		local rawR = trashRarity(t)
		if rawR ~= nil then L.haveRarity = true end
		local myth = isMythic(t)
		local text = describe(t)
		L.info[key] = { label = text, kg = kg, value = v }
		L.types[key] = (L.types[key] or 0) + 1

		-- last seen by rarity (trash already on the map counts as "seen now")
		local rk = rarityKey(rawR)
		if rk then L.lastSeen[rk] = { time = nowSec(), label = text } end

		local pos = partPos(t)
		if pos then
			addSpot(L.spots, pos)
			if myth then addSpot(L.mSpots, pos) end
		end

		if not isNew then return end -- trash that was already there is data, not a new spawn

		local now = nowSec()
		local slot = math.floor(now / 300) -- which 5-minute slot of the real clock
		local hour = slot % 12 == 0 -- 12 slots = the top of the hour
		local lag = now % 300
		if lag <= 120 then
			L.lagSum = L.lagSum + lag
			L.lagN = L.lagN + 1
		end

		local w = L.waves[slot]
		if not w then
			w = { hour = hour, items = 0, kg = 0, bestScore = -1, bestKey = nil, mythic = false }
			L.waves[slot] = w
			L.waves[slot - 300] = nil
			-- older spawns count a little less each wave (so it follows changes)
			local tbl = hour and L.hW or L.nW
			for k, val in pairs(tbl) do tbl[k] = val * 0.97 end
			-- summary a few seconds after the wave starts
			task.delay(4, function()
				if spawnNotifyOn and w.items > 0 then
					local best = w.bestKey and L.info[w.bestKey]
					notify(hour and "Hour wave spawned" or "Spawn wave",
						w.items .. " new trash" .. (best and ("\nBest: " .. best.label) or ""))
				end
			end)
		end
		w.items = w.items + 1
		w.kg = w.kg + kg

		local tbl = hour and L.hW or L.nW
		tbl[key] = (tbl[key] or 0) + 1
		if hour then L.hTot = L.hTot + 1 else L.nTot = L.nTot + 1 end

		local score = v > 0 and v or kg
		if score > w.bestScore then
			w.bestScore = score
			w.bestKey = key
		end

		if myth then
			w.mythic = true
			L.mythicTypes[key] = (L.mythicTypes[key] or 0) + 1
			if mythicNotifyOn then
				local where = pos and string.format("\nat x %d, z %d", math.floor(pos.X), math.floor(pos.Z)) or ""
				notify("MYTHIC SPAWNED", text .. where, Color3.fromRGB(255, 215, 60))
			end
		end

		if itemAlertOn and kg >= (tonumber(alertBox.Text) or 0) and now - lastItemAlert >= 1 then
			lastItemAlert = now
			notify("New trash", text)
		end

		-- spawn log (used by the copy button)
		L.log[#L.log + 1] = {
			time = now, label = text, hour = hour,
			rarity = rk or (rawR ~= nil and tostring(rawR):lower()) or "unknown",
		}
		if #L.log > 600 then table.remove(L.log, 1) end
	end

	for _, t in ipairs(TrashFolder:GetChildren()) do record(t, false) end
	TrashFolder.ChildAdded:Connect(function(t)
		task.delay(0.25, function() -- let its rarity / value finish loading
			if t.Parent then record(t, true) end
		end)
	end)

	resetBtn.MouseButton1Click:Connect(function()
		L.types, L.info, L.nW, L.hW = {}, {}, {}, {}
		L.nTot, L.hTot, L.waves, L.spots, L.mSpots, L.mythicTypes = 0, 0, {}, {}, {}, {}
		L.lagSum, L.lagN, L.topSpot, L.mSpot = 0, 0, nil, nil
		L.lastSeen, L.log = {}, {}
		notify("Predict", "Learned data cleared")
	end)

	goSpotBtn.MouseButton1Click:Connect(function()
		local hrp, s = getHRP(), L.topSpot
		if hrp and s then hrp.CFrame = CFrame.new(s.x, s.y + 4, s.z) end
	end)
	goMythicBtn.MouseButton1Click:Connect(function()
		local hrp, s = getHRP(), L.mSpot or L.topSpot
		if hrp and s then hrp.CFrame = CFrame.new(s.x, s.y + 4, s.z) end
	end)

	---------------- countdown + notifications (runs even when this tab is closed)
	task.spawn(function()
		local warnedSpawn, warnedMythic = {}, {}
		local lastSlot = math.floor(nowSec() / 300)
		while task.wait(0.25) do
			local t = nowSec()
			local slot = math.floor(t / 300)
			local s5 = 300 - (t % 300)
			local sh = 3600 - (t % 3600)

			clockLabel.Text = string.format("Next spawn:  %s   (every 5 min, on the clock)\nGuaranteed mythic:  %s   (every hour, on the hour)\nClock now: %s",
				fmt(s5), fmt(sh), clockStr(t, "%I:%M:%S %p"))

			local hourSoon = math.floor(t / 3600) + 1
			local warnS = tonumber(warnBox.Text) or 15
			local warnM = tonumber(mWarnBox.Text) or 60

			if spawnNotifyOn and warnS > 0 and s5 <= warnS and not warnedSpawn[slot + 1] then
				warnedSpawn[slot + 1] = true
				notify("Spawn soon", "New trash spawns in " .. math.ceil(s5) .. "s")
			end
			if mythicNotifyOn and warnM > 0 and sh <= warnM and not warnedMythic[hourSoon] then
				warnedMythic[hourSoon] = true
				notify("Mythic soon", "Guaranteed mythic in " .. fmt(sh), Color3.fromRGB(255, 215, 60))
			end

			if slot ~= lastSlot then
				lastSlot = slot
				if slot % 12 == 0 and mythicNotifyOn then
					notify("MYTHIC HOUR", "Guaranteed mythic is spawning now!", Color3.fromRGB(255, 215, 60))
				elseif spawnNotifyOn then
					notify("Spawn now!", "New trash is spawning")
				end
			end
		end
	end)

	---------------- prediction text (what / where) + last seen panel
	task.spawn(function()
		while task.wait(1) do
			if predictPage.Visible then
				local lines = {}
				local t = nowSec()
				local nextHour = (math.floor(t / 300) + 1) % 12 == 0

				-- what will spawn next: chances learned from the same kind of wave
				local tbl, tot, src
				if nextHour then
					tbl, tot, src = L.hW, L.hTot, "hour waves"
				else
					tbl, tot, src = L.nW, L.nTot, "5-min waves"
				end
				if tot < 3 then tbl, src = L.types, "all spawns so far" end

				local sum = 0
				for _, wgt in pairs(tbl) do sum = sum + wgt end
				lines[#lines + 1] = (nextHour and "Next wave: HOUR wave" or "Next wave: normal wave") .. "  (learned from " .. src .. ")"
				if sum > 0 then
					local keys = {}
					for k in pairs(tbl) do keys[#keys + 1] = k end
					table.sort(keys, function(a, b)
						if tbl[a] ~= tbl[b] then return tbl[a] > tbl[b] end
						return a < b
					end)
					for i = 1, math.min(4, #keys) do
						local k = keys[i]
						local info = L.info[k]
						lines[#lines + 1] = string.format("%d. %s  %d%%", i, info and info.label or k,
							math.floor(tbl[k] / sum * 100 + 0.5))
					end
				else
					lines[#lines + 1] = "Learning... (no spawns seen yet)"
				end

				-- wave statistics
				local nw, ni, hw, hm = 0, 0, 0, 0
				local bestCount = {}
				for _, w in pairs(L.waves) do
					if w.hour then
						hw = hw + 1
						if w.mythic then hm = hm + 1 end
						if w.bestKey then bestCount[w.bestKey] = (bestCount[w.bestKey] or 0) + 1 end
					else
						nw = nw + 1
						ni = ni + w.items
					end
				end
				if nw > 0 then
					lines[#lines + 1] = string.format("Normal wave: ~%.1f items on average (%d seen)", ni / nw, nw)
				end

				-- mythic (guaranteed every hour)
				local mm
				if L.haveRarity then
					lines[#lines + 1] = string.format("Mythic seen in hour waves: %d / %d", hm, hw)
					if next(L.mythicTypes) then mm = L.mythicTypes end
				else
					lines[#lines + 1] = "No rarity data found: mythic guess = best item of the hour wave"
				end
				mm = mm or bestCount
				local mTot = 0
				for _, c in pairs(mm) do mTot = mTot + c end
				if mTot > 0 then
					local mk = {}
					for k in pairs(mm) do mk[#mk + 1] = k end
					table.sort(mk, function(a, b)
						if mm[a] ~= mm[b] then return mm[a] > mm[b] end
						return a < b
					end)
					for i = 1, math.min(2, #mk) do
						local info = L.info[mk[i]]
						lines[#lines + 1] = string.format("Likely mythic %d: %s  %d%%", i,
							info and info.label or mk[i], math.floor(mm[mk[i]] / mTot * 100 + 0.5))
					end
				end

				-- timing the game really uses
				if L.lagN > 0 then
					lines[#lines + 1] = string.format("Spawn lag after the mark: ~%.1fs (%d samples)", L.lagSum / L.lagN, L.lagN)
				end

				-- where
				local spots = sortedSpots(L.spots)
				L.topSpot = spots[1]
				for i = 1, math.min(2, #spots) do
					lines[#lines + 1] = string.format("Spot %d: x %d, z %d (%d spawns)", i, spots[i].x, spots[i].z, spots[i].n)
				end
				local mSpots = sortedSpots(L.mSpots)
				L.mSpot = mSpots[1]
				if mSpots[1] then
					lines[#lines + 1] = string.format("Mythic spot: x %d, z %d (%d seen)", mSpots[1].x, mSpots[1].z, mSpots[1].n)
				end

				infoLabel.Text = table.concat(lines, "\n")

				-- last seen by rarity
				local seen = {}
				for _, r in ipairs(RARITY_ORDER) do
					local e = L.lastSeen[r]
					if e then
						seen[#seen + 1] = cap(r) .. ": " .. e.label .. "  (" .. fmt(nowSec() - e.time) .. " ago)"
					else
						seen[#seen + 1] = cap(r) .. ": not seen yet"
					end
				end
				seenLabel.Text = table.concat(seen, "\n")
			end
		end
	end)

	---------------- copy data to clipboard (grouped by spawn time)
	local function buildCopyText()
		local out = {}
		local t = nowSec()
		out[#out + 1] = "=== Steal Trash: Predict data ==="
		out[#out + 1] = "Generated: " .. clockStr(t, "%I:%M:%S %p")
		out[#out + 1] = "Next spawn in " .. fmt(300 - t % 300) .. ", mythic hour in " .. fmt(3600 - t % 3600)
		out[#out + 1] = ""

		out[#out + 1] = "-- Last seen by rarity --"
		for _, r in ipairs(RARITY_ORDER) do
			local e = L.lastSeen[r]
			if e then
				out[#out + 1] = string.format("%s: %s (seen %s ago, at %s)", r:upper(), e.label,
					fmt(t - e.time), clockStr(e.time))
			else
				out[#out + 1] = r:upper() .. ": not seen yet"
			end
		end
		out[#out + 1] = ""

		-- group the log by 5-minute spawn slot
		out[#out + 1] = "-- Spawns by time (newest last) --"
		local groups, cur = {}, nil
		local startI = math.max(1, #L.log - 200)
		for i = startI, #L.log do
			local e = L.log[i]
			local slot = math.floor(e.time / 300)
			if not cur or cur.slot ~= slot then
				cur = { slot = slot, hour = e.hour, items = {}, counts = {} }
				groups[#groups + 1] = cur
			end
			cur.items[#cur.items + 1] = e
			cur.counts[e.rarity] = (cur.counts[e.rarity] or 0) + 1
		end
		if #groups == 0 then
			out[#out + 1] = "(no spawns recorded yet)"
		end
		for _, g in ipairs(groups) do
			out[#out + 1] = string.format("%s spawn%s:", clockStr(g.slot * 300), g.hour and " (HOUR wave)" or "")
			local parts = {}
			for _, r in ipairs(RARITY_ORDER) do
				if g.counts[r] then parts[#parts + 1] = cap(r) .. " x" .. g.counts[r] end
			end
			if g.counts["unknown"] then parts[#parts + 1] = "Unknown x" .. g.counts["unknown"] end
			out[#out + 1] = "  Rarities: " .. (#parts > 0 and table.concat(parts, ", ") or "-")
			for _, e in ipairs(g.items) do
				out[#out + 1] = "  - " .. e.label
			end
		end
		out[#out + 1] = ""
		out[#out + 1] = "-- Current prediction --"
		out[#out + 1] = infoLabel.Text
		return table.concat(out, "\n")
	end

	local function setClip(text)
		if setclipboard then return (pcall(setclipboard, text)) end
		if toclipboard then return (pcall(toclipboard, text)) end
		return false
	end

	copyBtn.MouseButton1Click:Connect(function()
		local text = buildCopyText()
		if setClip(text) then
			notify("Predict", "Data copied to clipboard")
		else
			notify("Predict", "Clipboard not supported, printed to console")
			print(text)
		end
	end)
end, function(e) warn("[Predict tab error] " .. tostring(e)) end)

---------------------------------------------------------------- Settings tab: Anti AFK, Server Hop, Hotkeys
xpcall(function()
	local settingsPage = newPage("Settings", true)

	-- Anti AFK
	local antiBtn = makeSection(settingsPage, 0, 10, "Anti AFK",
		"Stops the game from kicking you for being idle.", {})
	local antiOn = true
	setToggle(antiBtn, antiOn, "ANTI AFK")
	antiBtn.MouseButton1Click:Connect(function()
		antiOn = not antiOn
		setToggle(antiBtn, antiOn, "ANTI AFK")
	end)
	if getconnections then
		pcall(function()
			for _, c in ipairs(getconnections(lp.Idled)) do c:Disable() end
		end)
	end
	lp.Idled:Connect(function()
		if antiOn then
			local vu = game:GetService("VirtualUser")
			vu:CaptureController()
			vu:ClickButton2(Vector2.new())
		end
	end)

	-- Server hop
	local hopBtn, hopBoxes, hopCol = makeSection(settingsPage, 0.5, 5, "Server Hop",
		"Joins another public server. Max players is optional.", { { "", "Max players (optional)" } })
	local hopBox = hopBoxes[1]
	hopBtn.Text = "SERVER HOP"
	local hopStatus = newText(hopCol, 122, 24, "Status: idle", 11, false)

	local function httpGet(url)
		local ok, res = pcall(function() return game:HttpGet(url) end)
		if ok and type(res) == "string" and #res > 0 then return res end
		local req = (syn and syn.request) or request or http_request
		if req then
			local ok2, r = pcall(req, { Url = url, Method = "GET" })
			if ok2 and r and r.Body then return r.Body end
		end
	end

	local function serverHop()
		hopStatus.Text = "Status: finding a server..."
		local body = httpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
		if not body then hopStatus.Text = "Status: request failed" return end
		local ok, data = pcall(function() return game:GetService("HttpService"):JSONDecode(body) end)
		if not ok or type(data) ~= "table" or type(data.data) ~= "table" then
			hopStatus.Text = "Status: bad server list (rate limited?)"
			return
		end
		local maxP = tonumber(hopBox.Text)
		local choices = {}
		for _, s in ipairs(data.data) do
			if s.id ~= game.JobId and s.playing and s.maxPlayers and s.playing < s.maxPlayers - 1
				and (not maxP or s.playing <= maxP) then
				choices[#choices + 1] = s
			end
		end
		if #choices == 0 then hopStatus.Text = "Status: no matching server" return end
		local pick = choices[math.random(#choices)]
		hopStatus.Text = "Status: joining (" .. pick.playing .. "/" .. pick.maxPlayers .. ")"
		game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, pick.id, lp)
	end
	hopBtn.MouseButton1Click:Connect(function()
		task.spawn(serverHop)
	end)

	-- Hotkeys
	local panel = Instance.new("Frame")
	panel.Size = UDim2.new(1, -20, 0, 150)
	panel.Position = UDim2.fromOffset(10, 170)
	panel.BackgroundColor3 = Color3.fromRGB(35, 35, 43)
	panel.BorderSizePixel = 0
	panel.Parent = settingsPage
	Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 6)
	newText(panel, 8, 18, "Hotkeys (tap a key, then press a new one)", 12, true)

	local hotkeys = { UI = Enum.KeyCode.RightShift, Autosteal = Enum.KeyCode.J, Aura = Enum.KeyCode.K }
	local order = { { "UI", "Hide / show window" }, { "Autosteal", "Autosteal on / off" }, { "Aura", "Aura on / off" } }
	local actions = {
		UI = function() main.Visible = not main.Visible end,
		Autosteal = function() toggleAutoSteal() end,
		Aura = function() toggleAura() end,
	}
	local keyButtons, rebinding = {}, nil

	for i, o in ipairs(order) do
		local y = 34 + (i - 1) * 36
		local l = newText(panel, y + 5, 20, o[2], 13, false)
		l.Size = UDim2.new(0.6, 0, 0, 20)
		local b = makeButton(panel, UDim2.new(0.62, 0, 0, y), UDim2.new(0.34, 0, 0, 28),
			hotkeys[o[1]].Name, Color3.fromRGB(60, 60, 90))
		keyButtons[o[1]] = b
		b.MouseButton1Click:Connect(function()
			rebinding = o[1]
			b.Text = "press a key..."
		end)
	end

	UIS.InputBegan:Connect(function(input, processed)
		if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
		if rebinding then
			if input.KeyCode ~= Enum.KeyCode.Unknown then
				if input.KeyCode ~= Enum.KeyCode.Escape then
					hotkeys[rebinding] = input.KeyCode
				end
				keyButtons[rebinding].Text = hotkeys[rebinding].Name
				rebinding = nil
			end
			return
		end
		if processed then return end
		for name, key in pairs(hotkeys) do
			if input.KeyCode == key and actions[name] then actions[name]() end
		end
	end)

	-- small always-visible button so you can bring the window back (also works on mobile)
	local floatBtn = makeButton(gui, UDim2.new(0, 8, 0.5, -17), UDim2.fromOffset(34, 34), "ST", Color3.fromRGB(40, 40, 50))
	floatBtn.MouseButton1Click:Connect(function()
		main.Visible = not main.Visible
	end)
end, function(e) warn("[Settings tab error] " .. tostring(e)) end)

print("[Steal Trash] loaded")