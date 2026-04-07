local ViewportFrame = Instance.new("ViewportFrame")
ViewportFrame.Size = UDim2.new(1, 0, 1, 0)
ViewportFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
ViewportFrame.BackgroundTransparency = 1
ViewportFrame.BorderSizePixel = 0
ViewportFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

local WorldModel = Instance.new("WorldModel")
WorldModel.WorldPivot = CFrame.new(0, 2.5, 0)
WorldModel.Parent = ViewportFrame

local Camera = Instance.new("Camera")
Camera.FieldOfView = 20
Camera.CFrame = CFrame.new(0, 2.25, 20)
Camera.MaxAxisFieldOfView = 20
Camera.CoordinateFrame = CFrame.new(0, 2.25, 20)
Camera.DiagonalFieldOfView = 7.1164169
Camera.Parent = WorldModel

return ViewportFrame
