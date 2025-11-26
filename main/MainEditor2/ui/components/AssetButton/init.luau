type arg = {
	price : number;
	asset_id : number;
	asset_type : "Asset" | "Bundle";
	parent : Instance?;
	on_click : (() -> nil)?
}
local TweenService = game:GetService("TweenService")
local lune = require("@self/../lune_ui")
local iconbutton = lune.iconbutton
local empty_frame = lune.empty_frame
local styling = lune.styling
local shadow = Instance.new("ImageLabel")
local zero_udim = UDim.new(0,0)
local container_udim = UDim2.new(0,135,0,135)
local tween_data = TweenInfo.new(.2,Enum.EasingStyle.Quart,Enum.EasingDirection.In,0,true)
shadow.Size = UDim2.new(1,0,1,18)
shadow.ImageContent = Content.fromAssetId(186491278)
shadow.ImageTransparency = 0.36
shadow.BackgroundTransparency = 1
shadow.BorderSizePixel = 0
shadow.ZIndex = -2
return function(arg : arg) : TextButton
	local price = arg.price
	local asset_id = arg.asset_id
	local asset_type = arg.asset_type
	local parent = arg.parent
	local on_click = arg.on_click
	local container = empty_frame()
	container.Size = container_udim
	local padding = styling.padding(container)
	padding.PaddingTop = zero_udim
	padding.PaddingBottom = zero_udim
	padding.PaddingLeft = zero_udim
	padding.PaddingRight = zero_udim
	local shadow_clone = shadow:Clone()
	if asset_type == "Bundle" then
		asset_type = "BundleThumbnail"
	end
	local tweens 
	local asset_button = iconbutton {
		parent = container;
		id = `rbxthumb://type={asset_type}&id={asset_id}&w=420&h=420`;
		theme_enabled = false;
		on_click = function()
			for _,t in tweens do
				t:Play()
			end
			if on_click then
				on_click()
			end
		end,
	}
	tweens = {
		TweenService:Create(padding,tween_data,{PaddingTop = UDim.new(0,16)}),
		TweenService:Create(padding,tween_data,{PaddingBottom = UDim.new(0,16)}),
		TweenService:Create(padding,tween_data,{PaddingLeft = UDim.new(0,16)}),
		TweenService:Create(padding,tween_data,{PaddingRight = UDim.new(0,16)})
	}
	asset_button.Size = UDim2.new(1,0,1,0)
	shadow_clone.Parent = container
	container.Parent = parent
	asset_button.Destroying:Connect(function() 
		container:Destroy()	
	end)
	return container
end
