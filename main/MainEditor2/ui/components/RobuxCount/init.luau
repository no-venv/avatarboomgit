local lune = require("./lune_ui")
local humanoid_description = require("../../singletons/SimpleHumanoidDescription")
return function(parent: Instance?, robux: number?)
	local textlabel = lune.textbutton("", parent,function(...)  end)
	local function update_robux(robux: number)
		textlabel.Text = `{robux} {utf8.char(0xE002)}`
	end
	local function connect_event()
		textlabel:GetPropertyChangedSignal("Text"):Once(function(...)
			update_robux(textlabel.Text)
			connect_event()
		end)
	end
	if robux then
		update_robux(robux)
		connect_event()
	else
		local function update()
			local asset_info = humanoid_description:get_id_asset_info_list()
			local tally = 0
			for _, asset in asset_info do
				if asset.Price then
					tally += asset.Price
				end
			end
			update_robux(tally)
		end
		local hum_changed = humanoid_description.humanoid_changed.Event:Connect(update)
		local id_added = humanoid_description.id_added.Event:Connect(update)
		local id_removed = humanoid_description.id_removed.Event:Connect(update)
		textlabel.Destroying:Connect(function(...)
			hum_changed:Disconnect()
			id_added:Disconnect()
			id_removed:Disconnect()
		end)
	end
	return textlabel
end
