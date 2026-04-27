local lune = require("./lune_ui")
local utils = require("../../utils")
local humanoid_editor = require("../../singletons/SimpleHumanoidDescription")
return function()
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
end
