--!strict
local components = require("../../components")
local lune = require("../../components/lune_ui")
local tab = require("../../components/lune_ui/tab")
local humanoid_editor = require("../../../singletons/SimpleHumanoidDescription")
local on_modification = require("./on_modification")
return function(tab: tab.TabImpl)
	local current_id = 0
	local is_clothing = false
	local clothing_type = ""
	--
	local colour_edit = lune.empty_frame()
	colour_edit.Name = "Colour"
	do
		local vbox = lune.styling.vbox(colour_edit)
		vbox.VerticalAlignment = Enum.VerticalAlignment.Center
		vbox.HorizontalAlignment = Enum.HorizontalAlignment.Center
		vbox.VerticalFlex = Enum.UIFlexAlignment.Fill
	end
	local colour_wheel = components.colour_wheel(colour_edit)
	local min_size = Instance.new("UISizeConstraint")
	min_size.MinSize = Vector2.new(0, 32)
	local hex_colour = lune.textbox("Hex Colour", colour_edit)
	local reset_colour = lune.textbutton("Reset", colour_edit, function(): nil
		colour_wheel.set_colour(Color3.new(1, 1, 1))
		return
	end)
	hex_colour.FocusLost:Connect(function(enterPressed: boolean, inputThatCausedFocusLoss: InputObject)
		if not enterPressed then
			return
		end
		colour_wheel.set_colour(Color3.fromHex(hex_colour.Text))
	end)
	colour_wheel.on_colour = function(colour)
		if is_clothing then
			humanoid_editor:set_clothing_colour(clothing_type, colour)
		else
			humanoid_editor:set_id_colour(current_id, colour)
		end
		hex_colour.Text = colour:ToHex()
	end

	min_size:Clone().Parent = reset_colour
	min_size:Clone().Parent = hex_colour

	on_modification.connect(function(parm)
		if parm.event_type == "disable" then
			tab.hide_tab_bar_button("Colour", true)
			return
		end
		if parm.event_type == "selected_id" then
			current_id = parm.id
		end
		-- hide tab button, we are not ready yet
		tab.hide_tab_bar_button("Colour", true)
		if not humanoid_editor:id_equipped(parm.id) then
			return
		end
		if parm.is_accessory or parm.is_clothing then
			is_clothing = parm.is_clothing
			clothing_type = parm.clothing_type
			current_id = parm.id
			local saved_colour = is_clothing and humanoid_editor:get_clothing_colour(clothing_type)
				or humanoid_editor:get_id_colour(current_id)
			if saved_colour then
				colour_wheel.set_colour(saved_colour)
			end
			tab.hide_tab_bar_button("Colour", false)
			tab.toggle("Colour", true)
		end
	end)

	return colour_edit
end
