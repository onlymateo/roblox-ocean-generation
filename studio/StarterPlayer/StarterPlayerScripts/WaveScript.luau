local Wave = require(script.Wave)


local planes = {}
for i = 1, 25 do
	table.insert(planes, workspace:WaitForChild("newplanes"):WaitForChild("Plane" .. i):WaitForChild("Plane"))
end

local default = {
	NumWaves = 5,

	-- FFT
	FFTAmplitude = 3.0,
	FFTWavelength = 100,
	FFTDirection = Vector2.new(-1, 0.2),
	FFTPhase = 0,
	FFTSpeed = 0.5,
	FFTTimeModifier = 1,

	-- GERSTNER
	WaveLengths = {250, 120, 200, 60, 240, 130, 170, 325, 145, 155},
	Steepnesses = {0.1, 0.15, 0.1, 0.15, 0.2, 0.13, 0.18, 0.06, 0.01, 0.12},
	Directions = {
		Vector2.new(1.5, 1.5),
		Vector2.new(0.5, 0.5),
		Vector2.new(-1.5, -1.5),
		Vector2.new(-0.5, -0.5),
		Vector2.new(0.5, -0.5),
		Vector2.new(-0.5, 0.5),
		Vector2.new(-1.2, -1.2),
		Vector2.new(-0.2, 0.5),
		Vector2.new(-0.5, 0.2),
		Vector2.new(-0.5, 1.5),
	},
	Gravity = 9.5,
	TimeModifier = 20,
	MaxDistance = 1000,
}



for i, plane in ipairs(planes) do
	local TestWave = Wave.new(plane, default)
	TestWave:ConnectRenderStepped()
end