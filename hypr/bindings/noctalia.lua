local network_panel_toggle = "noctalia-shell ipc call network togglePanel"
local notifications_toggle = "noctalia-shell ipc call notifications toggleHistory"
local notifications_clear = "noctalia-shell ipc call notifications clear"
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd(network_panel_toggle))
hl.bind(mainMod .. " + slash", hl.dsp.exec_cmd(notifications_toggle))
hl.bind(mainMod .. " + SHIFT + slash", hl.dsp.exec_cmd(notifications_clear))
