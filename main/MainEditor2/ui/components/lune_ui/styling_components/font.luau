local arimo = Font.new("rbxasset://fonts/families/BuilderSans.json",Enum.FontWeight.Regular)
return function(text_object : TextLabel?): Font
	if text_object then
		text_object.FontFace = arimo
	end
	return arimo
end
