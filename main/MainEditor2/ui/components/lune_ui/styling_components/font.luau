local arimo = Font.new("rbxasset://fonts/families/BuilderSans.json",Enum.FontWeight.Regular)
return function(text_object : TextLabel)
	text_object.FontFace = arimo
	return 
end
