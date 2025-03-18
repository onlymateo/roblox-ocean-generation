local planes = {}
for i = 1, 25 do
	table.insert(planes, workspace:WaitForChild("newplanes"):WaitForChild("Plane" .. i):WaitForChild("Plane"))
end
local parts = {}
local flotablesFolder = game.Workspace:FindFirstChild("flotables")

local function WaitForValidModels(folder)
	while true do
		local allValid = true
		if folder and folder:IsA("Folder") then
			for _, model in pairs(folder:GetChildren()) do
				if not (model:IsA("Model") and model.PrimaryPart) then
					allValid = false
					warn(model.Name .. " n'est pas un modèle valide ou n'a pas de PrimaryPart.")
					task.wait(0.1)
				end
			end
		else
			allValid = false
			warn("Le dossier 'flotables' n'existe pas ou n'est pas un Folder")
		end
		if allValid then
			break
		end
		task.wait(0.1)
	end
end
WaitForValidModels(flotablesFolder)

if flotablesFolder and flotablesFolder:IsA("Folder") then
	for _, model in pairs(flotablesFolder:GetChildren()) do
		if model:IsA("Model") and model.PrimaryPart then
			table.insert(parts, model)
		else
			warn(model.Name .. " n'est pas un modèle valide ou n'a pas de PrimaryPart.")
		end
	end
else
	warn("Le dossier 'flotables' n'existe pas ou n'est pas un Folder")
end

local zoneSize = 50
local boneCache = {
	bones = {},
	zones = {},
	lastUpdate = 0,
	updateInterval = 1/30,
	minBound = nil,
	maxBound = nil
}

local function GetZoneKey(position)
	local xIndex = math.floor(position.X / zoneSize)
	local zIndex = math.floor(position.Z / zoneSize)
	return tostring(xIndex) .. ":" .. tostring(zIndex)
end

local function UpdateBoneCache()
	local currentTime = tick()
	if currentTime - boneCache.lastUpdate < boneCache.updateInterval then
		return
	end

	boneCache.bones = {}
	boneCache.zones = {}
	boneCache.minBound = nil
	boneCache.maxBound = nil

	for _, plane in pairs(planes) do
		for _, bone in pairs(plane:GetDescendants()) do
			if bone:IsA("Bone") then
				local bonePosition = bone.TransformedWorldCFrame.Position
				table.insert(boneCache.bones, bone)

				local key = GetZoneKey(bonePosition)
				if not boneCache.zones[key] then
					boneCache.zones[key] = {}
				end
				table.insert(boneCache.zones[key], bone)

				boneCache.minBound = boneCache.minBound and Vector3.new(
					math.min(boneCache.minBound.X, bonePosition.X),
					math.min(boneCache.minBound.Y, bonePosition.Y),
					math.min(boneCache.minBound.Z, bonePosition.Z)
				) or bonePosition

				boneCache.maxBound = boneCache.maxBound and Vector3.new(
					math.max(boneCache.maxBound.X, bonePosition.X),
					math.max(boneCache.maxBound.Y, bonePosition.Y),
					math.max(boneCache.maxBound.Z, bonePosition.Z)
				) or bonePosition
			end
		end
	end

	boneCache.lastUpdate = currentTime
end

local function GetDynamicWaterLevel(PointPosition)
	UpdateBoneCache() -- Mettre à jour le cache si nécessaire

	local xIndex = math.floor(PointPosition.X / zoneSize)
	local zIndex = math.floor(PointPosition.Z / zoneSize)

	local nearbyBones = {}
	for dx = -1, 1 do
		for dz = -1, 1 do
			local key = tostring(xIndex + dx) .. ":" .. tostring(zIndex + dz)
			if boneCache.zones[key] then
				for _, bone in ipairs(boneCache.zones[key]) do
					local bonePosition = bone.TransformedWorldCFrame.Position
					local distance = (Vector2.new(bonePosition.X, bonePosition.Z) - Vector2.new(PointPosition.X, PointPosition.Z)).Magnitude
					table.insert(nearbyBones, {bone = bone, position = bonePosition, distance = distance})
				end
			end
		end
	end

	table.sort(nearbyBones, function(a, b) return a.distance < b.distance end)

	local closestBones = {}
	for i = 1, math.min(4, #nearbyBones) do
		table.insert(closestBones, nearbyBones[i])
	end

	while #closestBones < 4 do
		table.insert(closestBones, {position = boneCache.minBound or Vector3.zero, distance = math.huge})
	end

	local bone1, bone2, bone3, bone4 = 
		closestBones[1].position,
		closestBones[2].position,
		closestBones[3].position,
		closestBones[4].position

	local x1, x2 = math.min(bone1.X, bone2.X, bone3.X, bone4.X), math.max(bone1.X, bone2.X, bone3.X, bone4.X)
	local z1, z2 = math.min(bone1.Z, bone2.Z, bone3.Z, bone4.Z), math.max(bone1.Z, bone2.Z, bone3.Z, bone4.Z)

	local playerX = math.clamp(PointPosition.X, x1, x2)
	local playerZ = math.clamp(PointPosition.Z, z1, z2)

	local tx = (x2 - x1) ~= 0 and (playerX - x1) / (x2 - x1) or 0
	local tz = (z2 - z1) ~= 0 and (playerZ - z1) / (z2 - z1) or 0

	local interpY1 = bone1.Y * (1 - tx) + bone2.Y * tx
	local interpY2 = bone3.Y * (1 - tx) + bone4.Y * tx
	local surfaceY = interpY1 * (1 - tz) + interpY2 * tz

	return surfaceY
end

local function GetPartTopCorners(part)
	if not part.PrimaryPart then
		warn(part.Name .. " does not have a valid PrimaryPart.")
		return nil
	end

	local size = part.PrimaryPart.Size
	local cframe = part.PrimaryPart.CFrame * CFrame.new(0, size.Y / 2, 0)
	local halfX = size.X / 2
	local halfZ = size.Z / 2
	local corners = {
		TopLeft = cframe * Vector3.new(-halfX, 0, -halfZ),
		TopRight = cframe * Vector3.new(halfX, 0, -halfZ),
		BottomLeft = cframe * Vector3.new(-halfX, 0, halfZ),
		BottomRight = cframe * Vector3.new(halfX, 0, halfZ),
	}

	return corners
end

local POSITION_SMOOTHNESS = 0.01
local ROTATION_SMOOTHNESS = 0.15
local UPDATE_FREQUENCY = 1/60
local SPRING_DAMPING = 0.8
local SPRING_SPEED = 15

local SpringInterpolator = {}
SpringInterpolator.__index = SpringInterpolator

function SpringInterpolator.new(initialValue)
	return setmetatable({
		target = initialValue,
		current = initialValue,
		velocity = Vector3.new(),
		lastUpdate = tick()
	}, SpringInterpolator)
end

function SpringInterpolator:Update(target, deltaTime)
	local diff = target - self.current
	local springForce = diff * SPRING_SPEED

	self.velocity = self.velocity * (1 - SPRING_DAMPING) + springForce * deltaTime
	self.current = self.current + self.velocity

	return self.current
end

local function AdjustPartOrientation(part)
	local smoothnessValue = part:FindFirstChild("smoothness")
	local partSmoothness = smoothnessValue and smoothnessValue:IsA("NumberValue") and smoothnessValue.Value or POSITION_SMOOTHNESS

	local positionSpring = SpringInterpolator.new(part.PrimaryPart.Position)
	local rotationSpring = SpringInterpolator.new(Vector3.new())

	local heartbeatConnection
	heartbeatConnection = game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
		local corners = GetPartTopCorners(part)
		if not corners then
			return
		end

		local waterLevels = {
			TopLeft = GetDynamicWaterLevel(corners.TopLeft),
			TopRight = GetDynamicWaterLevel(corners.TopRight),
			BottomLeft = GetDynamicWaterLevel(corners.BottomLeft),
			BottomRight = GetDynamicWaterLevel(corners.BottomRight),
		}

		local averageY = (waterLevels.TopLeft + waterLevels.TopRight +
			waterLevels.BottomLeft + waterLevels.BottomRight) / 4

		local forwardTilt = (waterLevels.TopRight + waterLevels.BottomRight) / 2 -
			(waterLevels.TopLeft + waterLevels.BottomLeft) / 2

		local sideTilt = (waterLevels.TopRight + waterLevels.TopLeft) / 2 -
			(waterLevels.BottomRight + waterLevels.BottomLeft) / 2

		local targetPosition = Vector3.new(part.PrimaryPart.Position.X, averageY, part.PrimaryPart.Position.Z)
		local targetRotation = Vector3.new(math.rad(sideTilt), 0, math.rad(forwardTilt))

		local newPosition = positionSpring:Update(targetPosition, deltaTime)
		local newRotation = rotationSpring:Update(targetRotation, deltaTime)

		local newCFrame = CFrame.new(newPosition) *
			CFrame.fromEulerAnglesXYZ(newRotation.X, newRotation.Y, newRotation.Z)

		part:SetPrimaryPartCFrame(part:GetPrimaryPartCFrame():Lerp(newCFrame, partSmoothness))
	end)

	return function()
		if heartbeatConnection then
			heartbeatConnection:Disconnect()
		end
	end
end

local cleanups = {}
for _, part in ipairs(parts) do
	local cleanup = AdjustPartOrientation(part)
	table.insert(cleanups, cleanup)
end

local function CleanupAll()
	for _, cleanup in ipairs(cleanups) do
		cleanup()
	end
end