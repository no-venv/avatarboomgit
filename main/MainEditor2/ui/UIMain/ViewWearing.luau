--!strict
local components = require("../components")
local singletons = require("../../singletons")
local utils = require("../../utils")
local shared = require("../../shared")
local asset_button = components.asset_button
local asset_button_header = components.asset_button_header
local lune = components.lune_ui
local empty_frame = lune.empty_frame
local scrolling_frame = lune.scrolling_frame
local styling = lune.styling
local event_bus = singletons.event_bus
local humanoid_editor = singletons.humanoid_description

return function(parent: Instance?)
	local container = empty_frame(parent)
	local current_view_wearing: ScrollingFrame? = nil
	local is_enabled = true
	local function update()
		if not humanoid_editor:is_init() then
			return
		end
		local view_wearing_instance = scrolling_frame(container, "Grid")
		styling.padding(view_wearing_instance).PaddingTop = UDim.new(0, 50)
		view_wearing_instance.Name = "ViewWearing"

		if current_view_wearing then
			current_view_wearing:Destroy()
		end
		current_view_wearing = view_wearing_instance

		local wearing_ids = singletons.humanoid_description:get_id_asset_info_list()
		components.buy_asset_button(view_wearing_instance, wearing_ids)
		for _, asset in wearing_ids do
			local button = asset_button({
				asset = asset,
				parent = view_wearing_instance,
				on_click = function()
					event_bus.avatar_item_selected.emit({
						asset_info = asset,
					})
				end,
			})
			asset_button_header(asset, { ["Favourite"] = true, ["Remove"] = true }, button)
		end
		return
	end
	singletons.event_bus.topbar_register_custom_button.emit({
		allowed_overlay = "Wearing",
		button_id = "wearing_upload_custom",
		tooltip = "Upload Local Shirts or Pants",
		image = shared.icons.upload,
		on_click = function(state)
			local function upload(image, clothing_type: "Shirt" | "Pants")
				local humanoid = humanoid_editor.Humanoid
				if not humanoid then
					return
				end
				local rig = humanoid.Parent
				if not rig then
					return
				end
				local clothing = rig:FindFirstChild(clothing_type)
				if not clothing then
					local new_clothing = Instance.new(clothing_type)
					new_clothing.Name = clothing_type
					new_clothing.Parent = rig
					clothing = new_clothing
				end


				if clothing_type == "Shirt" then
					(clothing :: Shirt).ShirtTemplate = image
				else
					(clothing :: Pants).PantsTemplate = image
				end
			end
			local window
			local upload_view = lune.empty_frame()
			local vbox = lune.styling.vbox(upload_view)
			vbox.HorizontalFlex = Enum.UIFlexAlignment.Fill
			lune.textlabel(
				"You can upload local pngs/jpgs as shirts or pants.\n\n⚠️ The shirts or pants will not work after closing Studio.",
				upload_view
			)
			lune.textbutton("Upload Shirts", upload_view, function(...)
				local image = utils.image_from_disk()
				if not image then
					return
				end
				upload(image, "Shirt")
			end)
			lune.textbutton("Upload Pants", upload_view, function(...)
				local image = utils.image_from_disk()
				if not image then
					return
				end
				upload(image, "Pants")
			end)
			lune.textbutton("Close", upload_view, function(...)
				window:Destroy()
			end)
			window = lune.window.base({
				title = "Upload Local Shirts or Pants",
				view = upload_view,
				-- prompt_text = ,
				-- options = { "Upload Shirts", "Upload Pants" },
				-- on_prompt_result = function(result) end,
				important = true,
			})
			return
		end,
	})
	singletons.event_bus.topbar_visibility_custom_button.emit({
		button_id = "wearing_upload_custom",
		show = true,
	})

	humanoid_editor.humanoid_changed.Event:Connect(update)
	humanoid_editor.id_added.Event:Connect(update)
	humanoid_editor.id_removed.Event:Connect(update)
	event_bus.catalog_show_overlay.connect(function(parm)
		is_enabled = parm.overlay == "Wearing"
		container.Visible = is_enabled
	end)
	-- tbh,just update in the background for more responsiveness
	container.Visible = false
	update()
	return container
end
