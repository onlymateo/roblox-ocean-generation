local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

while not character:FindFirstChild("HumanoidRootPart") do
	wait(0.1)
end

character.PrimaryPart = character:FindFirstChild("HumanoidRootPart")

local Plane1 = workspace:WaitForChild("newplanes"):WaitForChild("Plane1"):WaitForChild("Plane")
local planes = {}
for i = 1, 25 do
	table.insert(planes, workspace:WaitForChild("newplanes"):WaitForChild("Plane"..i):WaitForChild("Plane"))
end

local chunkSize = 342.419

while true do
	local characterPosition = character.PrimaryPart.Position

	for i, plane in ipairs(planes) do
		local offsetX = ((i-1) % 5 - 2) * chunkSize
		local offsetZ = (math.floor((i-1) / 5) - 2) * chunkSize

		local newPos = Vector3.new(
			math.floor(characterPosition.X / chunkSize + 0.5) * chunkSize + offsetX,
			plane.Position.Y,
			math.floor(characterPosition.Z / chunkSize + 0.5) * chunkSize + offsetZ
		)

		plane.Position = newPos
	end

	wait(0.1)
end
