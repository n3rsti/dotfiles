for workspace = 1, 10 do
	local key = workspace % 10
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = workspace }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace }))
end

hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))

hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.resize({ x = 10, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.resize({ x = -10, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.resize({ x = 0, y = -10, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.resize({ x = 0, y = 10, relative = true }), { repeating = true })

hl.bind(mainMod .. " + CTRL + right", hl.dsp.workspace.swap_monitors({ monitor1 = 1, monitor2 = 0 }))
hl.bind(mainMod .. " + CTRL + left", hl.dsp.workspace.swap_monitors({ monitor1 = 0, monitor2 = 1 }))
hl.bind(mainMod .. " + CTRL + down", hl.dsp.window.swap({ direction = "d" }))
hl.bind(mainMod .. " + CTRL + up", hl.dsp.window.swap({ direction = "u" }))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
