local MaterialService = game:GetService("MaterialService")
local ContentProvider = game:GetService("ContentProvider")

repeat task.wait() until game:IsLoaded()

local Plane1 = script.Parent
local WaterMaterial = MaterialService:FindFirstChild("AWave1")
local WaterFrames = {}

for Index, _ in ipairs(MaterialService:GetDescendants()) do
	local variant = "AWave" .. Index
	local materialVariant = MaterialService:FindFirstChild(variant)
	table.insert(WaterFrames, variant)
	if Index == 14 then
		break
	end

end


ContentProvider:PreloadAsync(WaterFrames)

local function animateMaterials()
	while true do
		for Index, WaterFrame in ipairs(WaterFrames) do
			Plane1.MaterialVariant = WaterFrame
			task.wait(0.02)
		end
	end
end

animateMaterials()