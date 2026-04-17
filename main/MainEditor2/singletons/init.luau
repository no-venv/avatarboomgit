return {
	crash_sender = require("@self/crash_sender"),
	catalog_fetcher = require("@self/CatalogFetcher"),
	humanoid_description = require("@self/SimpleHumanoidDescription"),
	event_bus = require("@self/event_bus"),
	plugin_fs = require("@self/PluginFS"),
	migrate_favourites = require("@self/migrate_favourites"),
	data_recovery = require("@self/data_recovery"),
	bug_collect_notice = require("@self/bug_collect_notice")
}
