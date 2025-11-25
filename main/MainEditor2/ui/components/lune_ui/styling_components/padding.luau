local ui_padding = Instance.new("UIPadding")
local padding_udim = UDim.new(0,8)
ui_padding.PaddingLeft = padding_udim
ui_padding.PaddingTop = padding_udim
ui_padding.PaddingRight = padding_udim
ui_padding.PaddingBottom = padding_udim
return function(parent : Instance?)
	local clone = ui_padding:Clone()
	clone.Parent = parent
	return clone
end