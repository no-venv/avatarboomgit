local ViewportFrame = Instance.new("ViewportFrame")
ViewportFrame.Size = UDim2.new(1, 0, 1, 0)
ViewportFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
ViewportFrame.BackgroundTransparency = 1
ViewportFrame.BorderSizePixel = 0
ViewportFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

local WorldModel = Instance.new("WorldModel")
WorldModel.WorldPivot = CFrame.new(0, 2.5, 0)
WorldModel.Parent = ViewportFrame

local Rig = Instance.new("Model")
Rig.Name = "Rig"
Rig.Parent = WorldModel

local Humanoid = Instance.new("Humanoid")
Humanoid.Parent = Rig

local Animator = Instance.new("Animator")
Animator.Parent = Humanoid

local HumanoidDescription = Instance.new("HumanoidDescription")
HumanoidDescription.ProportionScale = 0
HumanoidDescription.TorsoColor = Color3.fromRGB(128, 128, 128)
HumanoidDescription.RightLegColor = Color3.fromRGB(128, 128, 128)
HumanoidDescription.LeftLegColor = Color3.fromRGB(128, 128, 128)
HumanoidDescription.BodyTypeScale = 0
HumanoidDescription.LeftArmColor = Color3.fromRGB(128, 128, 128)
HumanoidDescription.HeadColor = Color3.fromRGB(128, 128, 128)
HumanoidDescription.RightArmColor = Color3.fromRGB(128, 128, 128)
HumanoidDescription.Parent = Humanoid

local BodyPartDescription = Instance.new("BodyPartDescription")
BodyPartDescription.Color = Color3.fromRGB(128, 128, 128)
BodyPartDescription.Parent = HumanoidDescription

local BodyPartDescription1 = Instance.new("BodyPartDescription")
BodyPartDescription1.Color = Color3.fromRGB(128, 128, 128)
BodyPartDescription1.BodyPart = Enum.BodyPart.LeftArm
BodyPartDescription1.Parent = HumanoidDescription

local BodyPartDescription2 = Instance.new("BodyPartDescription")
BodyPartDescription2.Color = Color3.fromRGB(128, 128, 128)
BodyPartDescription2.BodyPart = Enum.BodyPart.LeftLeg
BodyPartDescription2.Parent = HumanoidDescription

local BodyPartDescription3 = Instance.new("BodyPartDescription")
BodyPartDescription3.Color = Color3.fromRGB(128, 128, 128)
BodyPartDescription3.BodyPart = Enum.BodyPart.RightArm
BodyPartDescription3.Parent = HumanoidDescription

local BodyPartDescription4 = Instance.new("BodyPartDescription")
BodyPartDescription4.Color = Color3.fromRGB(128, 128, 128)
BodyPartDescription4.BodyPart = Enum.BodyPart.RightLeg
BodyPartDescription4.Parent = HumanoidDescription

local BodyPartDescription5 = Instance.new("BodyPartDescription")
BodyPartDescription5.Color = Color3.fromRGB(128, 128, 128)
BodyPartDescription5.BodyPart = Enum.BodyPart.Torso
BodyPartDescription5.Parent = HumanoidDescription

local BodyColors = Instance.new("BodyColors")
BodyColors.LeftArmColor3 = Color3.fromRGB(127, 127, 127)
BodyColors.HeadColor3 = Color3.fromRGB(127, 127, 127)
BodyColors.TorsoColor3 = Color3.fromRGB(128, 128, 128)
BodyColors.LeftLegColor3 = Color3.fromRGB(127, 127, 127)
BodyColors.RightLegColor3 = Color3.fromRGB(128, 128, 128)
BodyColors.RightArmColor3 = Color3.fromRGB(128, 128, 128)
BodyColors.Parent = Rig

local HumanoidRootPart = Instance.new("Part")
HumanoidRootPart.Name = "HumanoidRootPart"
HumanoidRootPart.RightParamB = 0
HumanoidRootPart.CFrame = CFrame.new(0, 3, 0)
HumanoidRootPart.BottomSurface = Enum.SurfaceType.Smooth
HumanoidRootPart.CanCollide = false
HumanoidRootPart.Transparency = 1
HumanoidRootPart.TopSurface = Enum.SurfaceType.Smooth
HumanoidRootPart.RightParamA = 0
HumanoidRootPart.CanQuery = false
HumanoidRootPart.Size = Vector3.new(2, 2, 1)
HumanoidRootPart.LeftParamB = 0
HumanoidRootPart.LeftParamA = 0
HumanoidRootPart.formFactor = Enum.FormFactor.Symmetric
HumanoidRootPart.Parent = Rig

local RootAttachment = Instance.new("Attachment")
RootAttachment.Name = "RootAttachment"
RootAttachment.WorldPosition = Vector3.new(0, 3, 0)
RootAttachment.WorldCFrame = CFrame.new(0, 3, 0)
RootAttachment.Parent = HumanoidRootPart

local RootJoint = Instance.new("Motor6D")
RootJoint.Name = "RootJoint"
RootJoint.C1 = CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0)
RootJoint.C0 = CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0)
RootJoint.MaxVelocity = 0.1
RootJoint.Parent = HumanoidRootPart

local RightLeg = Instance.new("Part")
RightLeg.Name = "Right Leg"
RightLeg.CFrame = CFrame.new(0.5, 1, 0)
RightLeg.BottomSurface = Enum.SurfaceType.Smooth
RightLeg.CanCollide = false
RightLeg.Color = Color3.fromRGB(127, 127, 127)
RightLeg.Size = Vector3.new(1, 2, 1)
RightLeg.formFactor = Enum.FormFactor.Symmetric
RightLeg.Parent = Rig

local RightFootAttachment = Instance.new("Attachment")
RightFootAttachment.Name = "RightFootAttachment"
RightFootAttachment.CFrame = CFrame.new(0, -1, 0)
RightFootAttachment.WorldPosition = Vector3.new(0.5, 0, 0)
RightFootAttachment.WorldCFrame = CFrame.new(0.5, 0, 0)
RightFootAttachment.Position = Vector3.new(0, -1, 0)
RightFootAttachment.Parent = RightLeg

local LeftLeg = Instance.new("Part")
LeftLeg.Name = "Left Leg"
LeftLeg.CFrame = CFrame.new(-0.5, 1, 0)
LeftLeg.BottomSurface = Enum.SurfaceType.Smooth
LeftLeg.CanCollide = false
LeftLeg.Color = Color3.fromRGB(127, 127, 127)
LeftLeg.Size = Vector3.new(1, 2, 1)
LeftLeg.formFactor = Enum.FormFactor.Symmetric
LeftLeg.Parent = Rig

local LeftFootAttachment = Instance.new("Attachment")
LeftFootAttachment.Name = "LeftFootAttachment"
LeftFootAttachment.CFrame = CFrame.new(0, -1, 0)
LeftFootAttachment.WorldPosition = Vector3.new(-0.5, 0, 0)
LeftFootAttachment.WorldCFrame = CFrame.new(-0.5, 0, 0)
LeftFootAttachment.Position = Vector3.new(0, -1, 0)
LeftFootAttachment.Parent = LeftLeg

local RightArm = Instance.new("Part")
RightArm.Name = "Right Arm"
RightArm.CFrame = CFrame.new(1.5, 3, 0)
RightArm.CanCollide = false
RightArm.Color = Color3.fromRGB(127, 127, 127)
RightArm.Size = Vector3.new(1, 2, 1)
RightArm.formFactor = Enum.FormFactor.Symmetric
RightArm.Parent = Rig

local RightShoulderAttachment = Instance.new("Attachment")
RightShoulderAttachment.Name = "RightShoulderAttachment"
RightShoulderAttachment.CFrame = CFrame.new(0, 1, 0)
RightShoulderAttachment.WorldPosition = Vector3.new(1.5, 4, 0)
RightShoulderAttachment.WorldCFrame = CFrame.new(1.5, 4, 0)
RightShoulderAttachment.Position = Vector3.new(0, 1, 0)
RightShoulderAttachment.Parent = RightArm

local RightGripAttachment = Instance.new("Attachment")
RightGripAttachment.Name = "RightGripAttachment"
RightGripAttachment.CFrame = CFrame.new(0, -1, 0)
RightGripAttachment.WorldPosition = Vector3.new(1.5, 2, 0)
RightGripAttachment.WorldCFrame = CFrame.new(1.5, 2, 0)
RightGripAttachment.Position = Vector3.new(0, -1, 0)
RightGripAttachment.Parent = RightArm

local LeftArm = Instance.new("Part")
LeftArm.Name = "Left Arm"
LeftArm.CFrame = CFrame.new(-1.5, 3, 0)
LeftArm.CanCollide = false
LeftArm.Color = Color3.fromRGB(127, 127, 127)
LeftArm.Size = Vector3.new(1, 2, 1)
LeftArm.formFactor = Enum.FormFactor.Symmetric
LeftArm.Parent = Rig

local LeftShoulderAttachment = Instance.new("Attachment")
LeftShoulderAttachment.Name = "LeftShoulderAttachment"
LeftShoulderAttachment.CFrame = CFrame.new(0, 1, 0)
LeftShoulderAttachment.WorldPosition = Vector3.new(-1.5, 4, 0)
LeftShoulderAttachment.WorldCFrame = CFrame.new(-1.5, 4, 0)
LeftShoulderAttachment.Position = Vector3.new(0, 1, 0)
LeftShoulderAttachment.Parent = LeftArm

local LeftGripAttachment = Instance.new("Attachment")
LeftGripAttachment.Name = "LeftGripAttachment"
LeftGripAttachment.CFrame = CFrame.new(0, -1, 0)
LeftGripAttachment.WorldPosition = Vector3.new(-1.5, 2, 0)
LeftGripAttachment.WorldCFrame = CFrame.new(-1.5, 2, 0)
LeftGripAttachment.Position = Vector3.new(0, -1, 0)
LeftGripAttachment.Parent = LeftArm

local Torso = Instance.new("Part")
Torso.Name = "Torso"
Torso.RightParamB = 0
Torso.CFrame = CFrame.new(0, 3, 0)
Torso.RightParamA = 0
Torso.Color = Color3.fromRGB(127, 127, 127)
Torso.RightSurface = Enum.SurfaceType.Weld
Torso.Size = Vector3.new(2, 2, 1)
Torso.LeftSurface = Enum.SurfaceType.Weld
Torso.LeftParamB = 0
Torso.LeftParamA = 0
Torso.formFactor = Enum.FormFactor.Symmetric
Torso.Parent = Rig

local roblox = Instance.new("Decal")
roblox.Name = "roblox"
roblox.Parent = Torso

local NeckAttachment = Instance.new("Attachment")
NeckAttachment.Name = "NeckAttachment"
NeckAttachment.CFrame = CFrame.new(0, 1, 0)
NeckAttachment.WorldPosition = Vector3.new(0, 4, 0)
NeckAttachment.WorldCFrame = CFrame.new(0, 4, 0)
NeckAttachment.Position = Vector3.new(0, 1, 0)
NeckAttachment.Parent = Torso

local BodyFrontAttachment = Instance.new("Attachment")
BodyFrontAttachment.Name = "BodyFrontAttachment"
BodyFrontAttachment.CFrame = CFrame.new(0, 0, -0.5)
BodyFrontAttachment.WorldPosition = Vector3.new(0, 3, -0.5)
BodyFrontAttachment.WorldCFrame = CFrame.new(0, 3, -0.5)
BodyFrontAttachment.Position = Vector3.new(0, 0, -0.5)
BodyFrontAttachment.Parent = Torso

local BodyBackAttachment = Instance.new("Attachment")
BodyBackAttachment.Name = "BodyBackAttachment"
BodyBackAttachment.CFrame = CFrame.new(0, 0, 0.5)
BodyBackAttachment.WorldPosition = Vector3.new(0, 3, 0.5)
BodyBackAttachment.WorldCFrame = CFrame.new(0, 3, 0.5)
BodyBackAttachment.Position = Vector3.new(0, 0, 0.5)
BodyBackAttachment.Parent = Torso

local LeftCollarAttachment = Instance.new("Attachment")
LeftCollarAttachment.Name = "LeftCollarAttachment"
LeftCollarAttachment.CFrame = CFrame.new(-1, 1, 0)
LeftCollarAttachment.WorldPosition = Vector3.new(-1, 4, 0)
LeftCollarAttachment.WorldCFrame = CFrame.new(-1, 4, 0)
LeftCollarAttachment.Position = Vector3.new(-1, 1, 0)
LeftCollarAttachment.Parent = Torso

local RightCollarAttachment = Instance.new("Attachment")
RightCollarAttachment.Name = "RightCollarAttachment"
RightCollarAttachment.CFrame = CFrame.new(1, 1, 0)
RightCollarAttachment.WorldPosition = Vector3.new(1, 4, 0)
RightCollarAttachment.WorldCFrame = CFrame.new(1, 4, 0)
RightCollarAttachment.Position = Vector3.new(1, 1, 0)
RightCollarAttachment.Parent = Torso

local WaistFrontAttachment = Instance.new("Attachment")
WaistFrontAttachment.Name = "WaistFrontAttachment"
WaistFrontAttachment.CFrame = CFrame.new(0, -1, -0.5)
WaistFrontAttachment.WorldPosition = Vector3.new(0, 2, -0.5)
WaistFrontAttachment.WorldCFrame = CFrame.new(0, 2, -0.5)
WaistFrontAttachment.Position = Vector3.new(0, -1, -0.5)
WaistFrontAttachment.Parent = Torso

local WaistCenterAttachment = Instance.new("Attachment")
WaistCenterAttachment.Name = "WaistCenterAttachment"
WaistCenterAttachment.CFrame = CFrame.new(0, -1, 0)
WaistCenterAttachment.WorldPosition = Vector3.new(0, 2, 0)
WaistCenterAttachment.WorldCFrame = CFrame.new(0, 2, 0)
WaistCenterAttachment.Position = Vector3.new(0, -1, 0)
WaistCenterAttachment.Parent = Torso

local WaistBackAttachment = Instance.new("Attachment")
WaistBackAttachment.Name = "WaistBackAttachment"
WaistBackAttachment.CFrame = CFrame.new(0, -1, 0.5)
WaistBackAttachment.WorldPosition = Vector3.new(0, 2, 0.5)
WaistBackAttachment.WorldCFrame = CFrame.new(0, 2, 0.5)
WaistBackAttachment.Position = Vector3.new(0, -1, 0.5)
WaistBackAttachment.Parent = Torso

local RightShoulder = Instance.new("Motor6D")
RightShoulder.Name = "Right Shoulder"
RightShoulder.C1 = CFrame.new(-0.5, 0.5, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0)
RightShoulder.C0 = CFrame.new(1, 0.5, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0)
RightShoulder.MaxVelocity = 0.1
RightShoulder.Parent = Torso

local LeftShoulder = Instance.new("Motor6D")
LeftShoulder.Name = "Left Shoulder"
LeftShoulder.C1 = CFrame.new(0.5, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
LeftShoulder.C0 = CFrame.new(-1, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
LeftShoulder.MaxVelocity = 0.1
LeftShoulder.Parent = Torso

local RightHip = Instance.new("Motor6D")
RightHip.Name = "Right Hip"
RightHip.C1 = CFrame.new(0.5, 1, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0)
RightHip.C0 = CFrame.new(1, -1, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0)
RightHip.MaxVelocity = 0.1
RightHip.Parent = Torso

local LeftHip = Instance.new("Motor6D")
LeftHip.Name = "Left Hip"
LeftHip.C1 = CFrame.new(-0.5, 1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
LeftHip.C0 = CFrame.new(-1, -1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
LeftHip.MaxVelocity = 0.1
LeftHip.Parent = Torso

local Neck = Instance.new("Motor6D")
Neck.Name = "Neck"
Neck.C1 = CFrame.new(0, -0.5, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0)
Neck.C0 = CFrame.new(0, 1, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0)
Neck.MaxVelocity = 0.1
Neck.Parent = Torso

local Head = Instance.new("Part")
Head.Name = "Head"
Head.CFrame = CFrame.new(0, 4.5, 0)
Head.TopSurface = Enum.SurfaceType.Smooth
Head.Color = Color3.fromRGB(127, 127, 127)
Head.Material = Enum.Material.Neon
Head.Size = Vector3.new(2, 1, 1)
Head.formFactor = Enum.FormFactor.Symmetric
Head.Parent = Rig

local Mesh = Instance.new("SpecialMesh")
Mesh.Scale = Vector3.new(1.25, 1.25, 1.25)
Mesh.Parent = Head

local face = Instance.new("Decal")
face.Name = "face"
face.Texture = "rbxasset://textures/face.png"
face.ColorMap = "rbxasset://textures/face.png"
face.Parent = Head

local HairAttachment = Instance.new("Attachment")
HairAttachment.Name = "HairAttachment"
HairAttachment.CFrame = CFrame.new(0, 0.6000000238418579, 0)
HairAttachment.WorldPosition = Vector3.new(0, 5.099999904632568, 0)
HairAttachment.WorldCFrame = CFrame.new(0, 5.099999904632568, 0)
HairAttachment.Position = Vector3.new(0, 0.6000000238418579, 0)
HairAttachment.Parent = Head

local HatAttachment = Instance.new("Attachment")
HatAttachment.Name = "HatAttachment"
HatAttachment.CFrame = CFrame.new(0, 0.6000000238418579, 0)
HatAttachment.WorldPosition = Vector3.new(0, 5.099999904632568, 0)
HatAttachment.WorldCFrame = CFrame.new(0, 5.099999904632568, 0)
HatAttachment.Position = Vector3.new(0, 0.6000000238418579, 0)
HatAttachment.Parent = Head

local FaceFrontAttachment = Instance.new("Attachment")
FaceFrontAttachment.Name = "FaceFrontAttachment"
FaceFrontAttachment.CFrame = CFrame.new(0, 0, -0.6000000238418579)
FaceFrontAttachment.WorldPosition = Vector3.new(0, 4.5, -0.6000000238418579)
FaceFrontAttachment.WorldCFrame = CFrame.new(0, 4.5, -0.6000000238418579)
FaceFrontAttachment.Position = Vector3.new(0, 0, -0.6000000238418579)
FaceFrontAttachment.Parent = Head

local FaceCenterAttachment = Instance.new("Attachment")
FaceCenterAttachment.Name = "FaceCenterAttachment"
FaceCenterAttachment.WorldPosition = Vector3.new(0, 4.5, 0)
FaceCenterAttachment.WorldCFrame = CFrame.new(0, 4.5, 0)
FaceCenterAttachment.Parent = Head

local Camera = Instance.new("Camera")
Camera.FieldOfView = 20
Camera.CFrame = CFrame.new(0, 2.25, 20)
Camera.MaxAxisFieldOfView = 20
Camera.CoordinateFrame = CFrame.new(0, 2.25, 20)
Camera.DiagonalFieldOfView = 7.1164169
Camera.Parent = WorldModel

Rig.PrimaryPart = Head

Humanoid.Torso = HumanoidRootPart
Humanoid.RightLeg = RightLeg
Humanoid.LeftLeg = LeftLeg

RootJoint.Part1 = Torso
RootJoint.Part0 = HumanoidRootPart

RightShoulder.Part1 = RightArm
RightShoulder.Part0 = Torso

LeftShoulder.Part1 = LeftArm
LeftShoulder.Part0 = Torso

RightHip.Part1 = RightLeg
RightHip.Part0 = Torso

LeftHip.Part1 = LeftLeg
LeftHip.Part0 = Torso

Neck.Part1 = Head
Neck.Part0 = Torso

return ViewportFrame
