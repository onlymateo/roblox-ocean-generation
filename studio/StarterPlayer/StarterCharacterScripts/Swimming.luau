
local WaterLevel = workspace:WaitForChild("newplanes"):WaitForChild("Plane1"):WaitForChild("Plane").Position.Y 
local runService = game:GetService("RunService")
local lighting = game:GetService("Lighting")
local Atmosphere = game:GetService("Lighting"):WaitForChild("Atmosphere")
local userInputService = game:GetService("UserInputService")
local plr = game:GetService("Players").LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local cam = workspace.CurrentCamera

local hum = char:FindFirstChildOfClass("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")

local swimmingAnimation
local swimmingTrack

local isMovingUp = false


local blurEffect = lighting:GetChildren("DepthOfField")
blurEffect.InFocusRadius = 50
blurEffect.FarIntensity = 1000
blurEffect.NearIntensity = 0.5
blurEffect.Enabled = false
blurEffect.Parent = lighting

local colorCorrection = Instance.new("ColorCorrectionEffect")
colorCorrection.TintColor = Color3.fromRGB(100, 150, 255)
colorCorrection.Brightness = -0.1
colorCorrection.Saturation = 0
colorCorrection.Enabled = false
colorCorrection.Parent = lighting


local planes = {}
for i = 1, 25 do
	table.insert(planes, workspace:WaitForChild("newplanes"):WaitForChild("Plane" .. i):WaitForChild("Plane"))
end


local function GetDynamicWaterLevel(playerPosition)
	local closestBones = {}

	for _, plane in pairs(planes) do
		for _, bone in pairs(plane:GetDescendants()) do
			if bone:IsA("Bone") then
				local bonePosition = bone.TransformedWorldCFrame.Position
				local distance = (Vector2.new(bonePosition.X, bonePosition.Z) - Vector2.new(playerPosition.X, playerPosition.Z)).Magnitude

				table.insert(closestBones, {bone = bone, distance = distance})
			end
		end
	end
	
	table.sort(closestBones, function(a, b)
		return a.distance < b.distance
	end)

	local bone1 = closestBones[1].bone.TransformedWorldCFrame.Position
	local bone2 = closestBones[2].bone.TransformedWorldCFrame.Position
	local bone3 = closestBones[3].bone.TransformedWorldCFrame.Position
	local bone4 = closestBones[4].bone.TransformedWorldCFrame.Position

	local x1, x2 = math.min(bone1.X, bone2.X, bone3.X, bone4.X), math.max(bone1.X, bone2.X, bone3.X, bone4.X)
	local z1, z2 = math.min(bone1.Z, bone2.Z, bone3.Z, bone4.Z), math.max(bone1.Z, bone2.Z, bone3.Z, bone4.Z)

	local playerX = math.clamp(playerPosition.X, x1, x2)
	local playerZ = math.clamp(playerPosition.Z, z1, z2)

	local tx = (playerX - x1) / (x2 - x1)
	local tz = (playerZ - z1) / (z2 - z1)

	local interpY1 = bone1.Y * (1 - tx) + bone2.Y * tx
	local interpY2 = bone3.Y * (1 - tx) + bone4.Y * tx
	local surfaceY = interpY1 * (1 - tz) + interpY2 * tz

	return surfaceY
end




local function LoadSwimAnimation()
	swimmingAnimation = Instance.new("Animation")
	swimmingAnimation.AnimationId = "rbxassetid://913376220"
	swimmingTrack = hum:LoadAnimation(swimmingAnimation)
end

local function EnableUnderwaterEffects()
	blurEffect.Enabled = true
	lighting:WaitForChild("DepthOfField").FarIntensity = 200
	Atmosphere.Haze = 5
	Atmosphere.Glare = 0
	Atmosphere.Density= 0.6
	Atmosphere.Color = Color3.fromRGB(94, 140, 199)
	--plane.Transparency = 0.2
	--colorCorrection.Enabled = true
end

local function DisableUnderwaterEffects()
	blurEffect.Enabled = false
	lighting:WaitForChild("DepthOfField").FarIntensity = 0.2
	Atmosphere.Haze = 0.32
	Atmosphere.Glare = 0.39
	Atmosphere.Density = 0.4
	Atmosphere.Offset = 0
	--plane.Transparency = 0
	--colorCorrection.Enabled = false
end


userInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.Space then
		isMovingUp = true
	end
end)
userInputService.InputEnded:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.Space then
		isMovingUp = false
	end
end)





local lastWaterLevelCheck = 0
local dynamicWaterLevel = nil
local islasthigher = false
local waterCheckInterval = 0.001

local function CheckSwimming(swimModule, deltaTime)
	local playerPosition = hrp.Position

	if tick() - lastWaterLevelCheck >= waterCheckInterval then
		dynamicWaterLevel = GetDynamicWaterLevel(playerPosition)
		lastWaterLevelCheck = tick()
	end

	if cam.CFrame.Position.Y < dynamicWaterLevel then
		EnableUnderwaterEffects()
	else
		DisableUnderwaterEffects()
	end

	if playerPosition.Y < dynamicWaterLevel then
		if not swimmingTrack.IsPlaying then
			swimmingTrack:Play()
		end

		swimModule:Start()
		if isMovingUp then
			hrp.AssemblyLinearVelocity = Vector3.new(0, 10, 0)
		elseif hum.MoveDirection.Magnitude == 0 then
			local dif = dynamicWaterLevel - playerPosition.Y
			if dif > 5 then
				hrp.AssemblyLinearVelocity = Vector3.new(0, 5, 0)
			else 
				hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
			end
		end
	elseif playerPosition.Y > dynamicWaterLevel then
		local dif = dynamicWaterLevel - playerPosition.Y
		--print(dif)
		if dif < 0 and dif > -5 and math.abs(hrp.AssemblyLinearVelocity.Y) < 15 then
			hrp.AssemblyLinearVelocity = Vector3.new(0, -10, 0)
		elseif swimmingTrack.IsPlaying then
			swimmingTrack:Stop()
		else
			swimModule:Stop()
		end
	end
end




-- Swim module
local swimModule = {}; swimModule.__index = swimModule

local function humStates(activate, toSet)
	hum:SetStateEnabled(Enum.HumanoidStateType.Running, activate)
	hum:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, activate)
	hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, activate)
	hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, activate)
	hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, activate)
	hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, activate)

	hum:ChangeState(toSet)
end

-- Create or Destroy gravity
local atts = {}; local forces = {}
local function antiGrav(on)
	if on then
		if #atts > 0 or #forces > 0 then return end

		local mass = hrp.AssemblyMass
		local att = Instance.new("Attachment")
		att.WorldPosition = hrp.Position
		att.Parent = hrp
		table.insert(atts, att)

		local force = Instance.new("VectorForce")
		force.RelativeTo = Enum.ActuatorRelativeTo.World
		force.Force = Vector3.new(0, workspace.Gravity * mass, 0)
		force.Attachment0 = att
		force.ApplyAtCenterOfMass = true
		force.Parent = hrp
		table.insert(forces, force)

		return att, force
	else
		for _, v in pairs(atts) do
			v:Destroy()
		end
		for _, v in pairs(forces) do
			v:Destroy()
		end
		table.clear(atts)
		table.clear(forces)
	end
end

function swimModule:Start()
	if self.Enabled then return end
	humStates(false, Enum.HumanoidStateType.Swimming)
	antiGrav(true)
	self.Enabled = true
	self.RSConnection = runService.Heartbeat:Connect(function()
		if hum.MoveDirection.Magnitude > 0 then return end
		hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
	end)
end

function swimModule:Stop()
	if not self.Enabled then return end
	self.Enabled = false
	humStates(true, Enum.HumanoidStateType.Freefall)
	antiGrav(false)
	if self.RSConnection then
		self.RSConnection:Disconnect()
	end
end



LoadSwimAnimation()

runService.RenderStepped:Connect(function()
	CheckSwimming(swimModule)
end)

return setmetatable({Enabled = false}, swimModule)
