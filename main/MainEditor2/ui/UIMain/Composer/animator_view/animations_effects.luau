local lune = require("../../../components/lune_ui")
return function(parent : Instance?)
    local container = lune.empty_frame(parent)
    local select_clip_message = lune.textlabel("Select a clip to use an effect",container)
    select_clip_message.Visible = false
    local scrolling_container = lune.scrolling_frame(container,"Grid")
    return container
end
