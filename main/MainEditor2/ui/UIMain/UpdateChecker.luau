local MarketplaceService = game:GetService("MarketplaceService")
local Editor = script:FindFirstAncestor("MainEditor2")
local lune = require(Editor.ui.components.lune_ui)
local shared = require(Editor.shared)
local styling = lune.styling
local lune_window = lune.window
local empty_frame = lune.empty_frame
local textlabel = lune.textlabel
local textbutton = lune.textbutton
local textbox = lune.textbox
local scrolling = lune.scrolling_frame
local option_buttons = lune.option_buttons
return function()
	-- run on another thread to avoid blocking
	task.spawn(function()
		local ok,result = pcall(function(...) 
			return MarketplaceService:GetProductInfo(86431991825383)
		end)
		if not ok then
			return
		end
		local version_gsub = (result.Description::string):match("version (%d.+)")
		local version_num = tonumber(version_gsub) :: number
		if version_num == shared.version then
			return
		end
		local window
		local container = empty_frame()
		local popup_vbox = styling.vbox(container)
	
		popup_vbox.VerticalFlex = Enum.UIFlexAlignment.Fill
		popup_vbox.HorizontalFlex = Enum.UIFlexAlignment.Fill
		lune.property_scope({Parent = container},function() 
			textlabel(`Upgrade to Version {version_num} for new features!`)
			local update_avatar_boom_inst = Instance.new("ImageLabel")
			update_avatar_boom_inst.ImageContent = Content.fromAssetId(80908422962532)
			update_avatar_boom_inst.Parent = container
			update_avatar_boom_inst.Size = UDim2.new(1,0,0,0)
			styling.stroke(update_avatar_boom_inst)
			styling.corner(update_avatar_boom_inst)
			do
				local aspect = Instance.new("UIAspectRatioConstraint")
				aspect.AspectRatio = 4.09322034
				aspect.AspectType = Enum.AspectType.ScaleWithParentSize
				aspect.Parent = update_avatar_boom_inst
			end
			--textlabel(`You can update the plugin via the Toolbox or the plugins menu\n`)
			textlabel(`Copy and paste the link to your browser to learn more of the update and to report bugs to me!`)
			local devfourm_link = textbox("")
			devfourm_link.Text = "devforum.roblox.com/t/avatarboom-create-avatars-in-roblox-studio/4083842/"
			devfourm_link.ClearTextOnFocus = false
			local user_ack = textbutton("Ok",nil,function() 
				window:Destroy()
			end)
			styling.sizeconst(user_ack,Vector2.new(0,32),Vector2.new(math.huge,32))
		end)
	
		window = lune_window.base("avatarBoom has a update!",Vector2.new(320,360),container,true)
	end)
end
