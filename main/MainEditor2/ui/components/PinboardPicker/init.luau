--!nonstrict
local lune = require("@self/../../components/lune_ui")
local pinboard_shared = require("../../shared/pinboard")
local pinboard_button = require("@self/pinboardbutton")

type Argument = {
	parent: Frame?,
	on_picked_pinboard: (picked: { name: string, data: pinboard_shared.Board }) -> any,
}
return function(arg: Argument)
	local parent = arg.parent
	local on_picked_pinboard = arg.on_picked_pinboard
	local container = lune.empty_frame()
	container.Name = "Save to Board"
	container.Parent = parent
	--
	local inner_container = lune.empty_frame(container)
	local vbox = lune.styling.vbox(inner_container)
	vbox.HorizontalAlignment = Enum.HorizontalAlignment.Center
	local scrolling_container
	local searchbox
	lune.textlabel("<font size='24'><b>Your saved boards 🌟</b></font>", inner_container)
	local function generate()
		if scrolling_container then
			scrolling_container:Destroy()
		end
		if searchbox then
			searchbox:Destroy()
		end
		-- searchbox = lune.textbox("Search", inner_container)
		-- searchbox.Size = UDim2.new(1, 0, 0, 32)

		scrolling_container = lune.scrolling_frame(inner_container, "Grid", {
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
		})

		lune.iconbutton({
			id = 104744952813054,
			theme_enabled = true,
			on_click = function()
				lune.window.prompt({
					title = "Create new Board",
					prompt_close_text = "Create",
					prompt_hint_text = "Board name",
					verify_prompt_failure_text = "That name already exists 💫",
					on_verify_prompt = function(result)
						return not pinboard_shared.pinboard_exists(result)
					end,
					on_prompt_result = function(result)
						pinboard_shared.new_pinboard(result)
						generate()
					end,
					custom_embed = container,
					important = true,
				})
			end,
			parent = scrolling_container,
		})

		for name, value in pinboard_shared.pinboard_data.data do
			local assets = {}
			for item_index = 1, 3 do
				local item = value[item_index]
				if not item then
					break
				end
				table.insert(assets, {
					asset_id = item.Id,
					asset_type = item.ItemType,
				})
			end
			pinboard_button({
				assets = assets,
				name = name,
				parent = scrolling_container,
				on_click = function()
					on_picked_pinboard({
						name = name,
						data = value,
					})
				end,
				on_remove = function()
					lune.window.option({
						title = "Delete confirmation",
						prompt_text = `Are you sure you want to delete {name}?`,
						options = { "Yes", "No" },
						on_prompt_result = function(result)
							if result == "Yes" then
								pinboard_shared.delete_pinboard(name)
								generate()
							end
						end,
						custom_embed = container,
						important = true,
					})
				end,
				on_rename = function()
					lune.window.prompt({
						title = `Rename board: {name}`,
						prompt_close_text = "Rename",
						prompt_hint_text = "New name for board",
						verify_prompt_failure_text = "That name already exists 💫",
						on_verify_prompt = function(result)
							return not pinboard_shared.pinboard_exists(result)
						end,
						on_prompt_result = function(result)
							pinboard_shared.rename_pinboard(name, result)
							generate()
						end,
						custom_embed = container,
						important = true,
					})
				end,
				on_share = function() end,
			})
		end
	end
	generate()
	return container
end
