type PluginSingleton = {
	plugin : Plugin?;
	widget : DockWidgetPluginGui?
}
local module : PluginSingleton = {
	plugin = nil;
	widget = nil;
}
return module
