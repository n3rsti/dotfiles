return {
	settings = {
		["nil"] = {
			formatting = {
				command = { "nixfmt" }, -- or "nixfmt" or "alejandra"
			},
			nix = {
				flake = {
					autoArchive = true,
				},
			},
		},
	},
}
