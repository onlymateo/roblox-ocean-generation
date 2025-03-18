local Wave = {}
Wave.__index = Wave

local newCFrame = CFrame.new
local IdentityCFrame = newCFrame()
local EmptyVector2 = Vector2.new()
local math_noise = math.noise
local random = math.random
local setseed = math.randomseed

local Stepped = game:GetService("RunService").RenderStepped
local Player = game:GetService("Players").LocalPlayer

local calmZones = {
	workspace:WaitForChild("Zones"):WaitForChild("calmzone"):WaitForChild("MeshPart")
}
local hardZones = {
	workspace:WaitForChild("Zones"):WaitForChild("hardzone"):WaitForChild("MeshPart")
}




local function Gerstner(Position: Vector3, Wavelength: number, Direction: Vector2, Steepness: number, Gravity: number, Time: number)
	local k = (2 * math.pi) / Wavelength
	local a = Steepness / k
	local d = Direction.Unit
	local c = math.sqrt(Gravity / k)
	local f = k * d:Dot(Vector2.new(Position.X, Position.Z)) - c * Time

	local cosF = math.cos(f)
	local sinF = math.sin(f)

	local dX = d.X * (a * cosF)
	local dY = a * sinF
	local dZ = d.Y * (a * cosF)

	return Vector3.new(dX, dY, dZ)

end

local function FFTWave(Position: Vector3, Amplitude: number, Wavelength: number, Direction: Vector2, Phase: number, Time: number, Speed: number)
	local k = (2 * math.pi) / Wavelength
	local d = Direction.Unit
	local f = k * (d:Dot(Vector2.new(Position.X, Position.Z))) + Phase - (Time * Speed)
	local displacement = Amplitude * math.sin(f)

	return Vector3.new(0, displacement, 0)
end










function Wave.new(instance: instance, waveSettings: table | nil, bones: table | nil)
	if bones == nil then
		bones = {}
		for _,v in pairs(instance:GetDescendants()) do
			if v:IsA("Bone") then
				table.insert(bones, v)
			end
		end
	end

	local Time = os.time()

	return setmetatable({
		_instance = instance,
		_bones = bones,
		_timeG = 0,
		_timeFFT = 0,
		_connections = {},
		_noise = {},
		_seeds = {random(0,Time),random(0,Time)},
		_settings = waveSettings
	},Wave)
end

local function AreBonesAtSamePosition(bone1, bone2)
	return bone1.WorldPosition == bone2.WorldPosition
end
function Wave:CheckBonesOverlap()
	for i, bone1 in ipairs(self._bones) do
		for j = i + 1, #self._bones do
			local bone2 = self._bones[j]
			if AreBonesAtSamePosition(bone1, bone2) then
				print("Bones overlap:", bone1.Name, bone2.Name)
			end
		end
	end
end








local calmOffset = -2

local function IsInZone(position: Vector3, zone: BasePart)
	local relativePos = zone.CFrame:PointToObjectSpace(position)
	local distance = math.sqrt(relativePos.X^2 + relativePos.Z^2)
	return distance <= zone.Size.X / 2 and math.abs(relativePos.Y) <= zone.Size.Y / 2
end


function Wave:Update()

	for _, v in pairs(self._bones) do
		local WorldPos = v.WorldPosition
		local Settings = self._settings

		local amplitudeMultiplier = 0.6
		local wavelengthMultiplier = 0.8
		local verticalOffset = 0





		for _, zone in ipairs(calmZones) do
			if IsInZone(WorldPos, zone) then
				amplitudeMultiplier = 0.3
				wavelengthMultiplier = 0.8
				verticalOffset = calmOffset
				break
			end
		end
		for _, zone in ipairs(hardZones) do
			if IsInZone(WorldPos, zone) then
				amplitudeMultiplier = 1.2
				wavelengthMultiplier = 1
				verticalOffset = 0
				break
			end
		end


		local totalWave = Vector3.new()
		for i = 1, Settings.NumWaves do
			local waveDirection = Settings.Directions[i]
			local wavedirthroughpoint = Vector2.new(WorldPos.X * waveDirection.x, WorldPos.Y * waveDirection.y)
			local wave = Gerstner(
				WorldPos,
				Settings.WaveLengths[i] * wavelengthMultiplier,
				wavedirthroughpoint,
				Settings.Steepnesses[i] * amplitudeMultiplier,
				Settings.Gravity,
				self._timeG
			)
			totalWave += wave
		end

		local fftWave = FFTWave(
			WorldPos,
			Settings.FFTAmplitude * amplitudeMultiplier,
			Settings.FFTWavelength * wavelengthMultiplier,
			Settings.FFTDirection,
			Settings.FFTPhase,
			self._timeFFT,
			Settings.FFTSpeed
		)

		totalWave += fftWave

		totalWave += Vector3.new(0, verticalOffset, 0)

		v.Transform = newCFrame(totalWave)
	end
end







function Wave:Refresh()
	for _,v in pairs(self._bones) do
		v.Transform = IdentityCFrame
	end
end

function Wave:ConnectRenderStepped()
	local Connection = Stepped:Connect(function()
		if not game:IsLoaded() then return end
		local Character = Player.Character
		local Settings = self._settings
		if not Character or (Character.PrimaryPart.Position-self._instance.Position).Magnitude < Settings.MaxDistance then
			local TimeG = (DateTime.now().UnixTimestampMillis/1000)/Settings.TimeModifier
			self._timeG = TimeG

			local TimeFFT = (DateTime.now().UnixTimestampMillis/1000)/Settings.FFTTimeModifier
			self._timeFFT = TimeFFT
			self:Update()
		else
			self:Refresh()
		end
	end)
	table.insert(self._connections,Connection)
	return Connection
end

function Wave:Destroy()
	self._instance = nil
	for _,v in pairs(self._connections) do
		pcall(function()
			v:Disconnect()
		end)
	end
	self._bones = {}
	self._settings = {}
	self = nil
end

return Wave