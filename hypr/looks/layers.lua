local blurLayerNamespaces = {
	"waybar",
	"gtk4-layer-shell",
	"swaync-control-center",
	"swaync-notification-window",
	"quickshell",
	"swayosd",
	"rofi",
	"walker",
}

local ignoreAlphaLayerNamespaces = {
	{ namespace = "swaync-control-center", alpha = 0.1 },
	{ namespace = "swaync-notification-window", alpha = 0.1 },
	{ namespace = "walker", alpha = 0.2 },
	{ namespace = "waybar", alpha = 0.1 },
	{ namespace = "quickshell", alpha = 0.1 },
	{ namespace = "swayosd", alpha = 0.1 },
}

for _, namespace in ipairs(blurLayerNamespaces) do
	hl.layer_rule({ match = { namespace = namespace }, blur = true })
end

for _, rule in ipairs(ignoreAlphaLayerNamespaces) do
	hl.layer_rule({ match = { namespace = rule.namespace }, ignore_alpha = rule.alpha })
end

hl.layer_rule({ match = { namespace = "quickshell" }, blur_popups = true })
hl.layer_rule({ match = { namespace = "walker" }, no_anim = true })
