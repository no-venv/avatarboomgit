-- migrates to the new pin system
local shared = require("../shared")
if not shared.pinboard.pinboard_exists("Favourties") then
	shared.pinboard.new_pinboard("Favourties")
	shared.pinboard.insert_pin("Favourties", shared.favourites.favourites)
end
return nil
