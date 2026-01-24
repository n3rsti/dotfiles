import Astal from "gi://Astal?version=4.0";
import AstalIO from "gi://AstalIO";
import GLib from "gi://GLib";
import Gtk from "gi://Gtk?version=4.0";
import GObject from "gi://GObject?version=2.0";
import AstalBattery from "gi://AstalBattery";
import AstalWp from "gi://AstalWp";
import AstalNetwork from "gi://AstalNetwork";
import AstalMpris from "gi://AstalMpris";
import AstalPowerProfiles from "gi://AstalPowerProfiles";
import AstalTray from "gi://AstalTray";
import AstalBluetooth from "gi://AstalBluetooth";
import Hyprland from "gi://AstalHyprland";

import { string, number, boolean } from "./props";

const { TOP, LEFT, RIGHT } = Astal.WindowAnchor;
const SYNC = GObject.BindingFlags.SYNC_CREATE;

export default class Bar extends Astal.Window {
    static {
        GObject.registerClass(
            {
                GTypeName: "Bar",
                Template: "resource:///ui/Bar.ui",
                InternalChildren: [
                    "popover",
                    "calendar",
                    "traybox",
                    "workspaces",
                ],
                Properties: {
                    ...string("clock"),
                    ...string("volume-icon"),
                    ...string("mic-volume-icon"),
                    ...boolean("battery-visible"),
                    ...string("battery-label"),
                    ...string("battery-icon"),
                    ...number("volume", 0, 1.5),
                    ...number("mic-volume", 0, 1.5),
                    ...string("network-icon"),
                    ...boolean("mpris_available"),
                    ...string("mpris-label"),
                    ...string("mpris-title"),
                    ...string("mpris-icon"),
                    ...string("mpris-art"),
                    ...string("power-profile-icon"),
                    ...string("ssid"),
                    ...string("bluetooth_label"),
                    ...boolean("bluetooth-visible"),
                },
            },
            this,
        );
    }

    declare clock: string;
    declare battery_label: string;
    declare mpris_label: string;
    declare mpris_available: boolean;
    declare bluetooth_visible: string;
    declare bluetooth_label: string;
    declare ssid: string;
    declare mpris_icon: string;

    declare _popover: Gtk.Popover;
    declare _calendar: Gtk.Calendar;
    declare _traybox: Gtk.Box;
    declare _workspaces: Gtk.Box;

    constructor() {
        super({
            visible: true,
            exclusivity: Astal.Exclusivity.EXCLUSIVE,
            anchor: TOP | LEFT | RIGHT,
            cssClasses: ["Bar"],
        });

        this.setupClock();
        this.setupCalendar();
        this.setupNetwork();
        this.setupBattery();
        this.setupAudio();
        this.setupMpris();
        this.setupPowerProfiles();
        this.setupWorkspaces();
        this.setupTray();
        this.setupBluetooth();
    }

    private setupClock() {
        const timer = AstalIO.Time.interval(1000, () => {
            this.clock = GLib.DateTime.new_now_local().format("%e %b %H:%M")!;
        });
        this.connect("destroy", () => timer.cancel());
    }

    private setupCalendar() {
        this._popover.connect("notify::visible", ({ visible }) => {
            if (visible) {
                this._calendar.select_day(GLib.DateTime.new_now_local());
            }
        });
    }

    private setupNetwork() {
        const nw = AstalNetwork.get_default();
        this.ssid = nw.get_wifi()?.ssid || "Ethernet";

        nw.connect("notify::state", (network) => {
            const wifi = network.get_wifi();
            this.ssid = wifi?.ssid || "Ethernet";
        });

        let networkBinding: GObject.Binding;

        nw.bind_property_full(
            "primary",
            this,
            "network-icon",
            SYNC,
            (_, primary: AstalNetwork.Primary) => {
                networkBinding?.unbind();

                switch (primary) {
                    case AstalNetwork.Primary.WIRED:
                        networkBinding = nw.wired.bind_property(
                            "icon-name",
                            this,
                            "network-icon",
                            SYNC,
                        );
                        return [false, ""];
                    case AstalNetwork.Primary.WIFI:
                        networkBinding = nw.wifi.bind_property(
                            "icon-name",
                            this,
                            "network-icon",
                            SYNC,
                        );
                        return [false, ""];
                    default:
                        return [true, "network-idle-symbolic"];
                }
            },
            null,
        );
    }

    private setupBattery() {
        const bat = AstalBattery.get_default();

        bat.bind_property("is-present", this, "battery-visible", SYNC);
        bat.bind_property("icon-name", this, "battery-icon", SYNC);

        this.battery_label = `${Math.floor(bat.percentage * 100)}%`;
        const batteryId = bat.connect("notify::percentage", () => {
            this.battery_label = `${Math.floor(bat.percentage * 100)}%`;
        });
        this.connect("destroy", () => bat.disconnect(batteryId));
    }

    private setupAudio() {
        const speaker = AstalWp.get_default()!.defaultSpeaker;
        speaker.bind_property("volume-icon", this, "volume-icon", SYNC);
        speaker.bind_property("volume", this, "volume", SYNC);

        const mic = AstalWp.get_default()!.default_microphone;
        mic.bind_property("volume-icon", this, "mic-volume-icon", SYNC);
        mic.bind_property("volume", this, "mic-volume", SYNC);
    }

    private setupMpris() {
        const mpris = AstalMpris.get_default();
        let currentPlayer: AstalMpris.Player | undefined;

        interface PlayerConnection {
            player: AstalMpris.Player;
            connection: number;
        }

        const players = new Map<string, PlayerConnection>();

        mpris.connect("player-added", (source, player) => {
            if (!currentPlayer && player.get_available()) {
                this.mpris_available = true;

                currentPlayer = player;
                currentPlayer.bind_property("title", this, "mpris-title", SYNC);
                this.mpris_icon = this.getPlayerIcon(currentPlayer);
            }
            const connection = player.connect(
                "notify::playback-status",
                (player) => {
                    if (
                        player.get_playback_status() ===
                        AstalMpris.PlaybackStatus.PLAYING
                    ) {
                        currentPlayer = player;
                        currentPlayer.bind_property(
                            "title",
                            this,
                            "mpris-title",
                            SYNC,
                        );
                        this.mpris_icon = this.getPlayerIcon(currentPlayer);
                    } else {
                        for (const p of players.values()) {
                            if (
                                p.player.get_playback_status() ===
                                AstalMpris.PlaybackStatus.PLAYING
                            ) {
                                currentPlayer = p.player;
                                currentPlayer.bind_property(
                                    "title",
                                    this,
                                    "mpris-title",
                                    SYNC,
                                );

                                this.mpris_icon =
                                    this.getPlayerIcon(currentPlayer);

                                break;
                            }
                        }
                    }
                },
            );
            players.set(player.get_bus_name(), { player, connection });
        });

        mpris.connect("player-closed", (_, player) => {
            const connection = players.get(player.get_bus_name())?.connection;
            if (connection) {
                player.disconnect(connection);
            }
            players.delete(player.get_bus_name());
        });
    }

    private getPlayerIcon(player: AstalMpris.Player) {
        const name = player.get_bus_name();
        if (name.includes("playerctld") && this.mpris_icon != "")
            return this.mpris_icon;
        if (name.includes("spotify")) return "";
        if (name.includes("firefox")) return "󰈹";

        return "";
    }

    private setupPowerProfiles() {
        const powerprofile = AstalPowerProfiles.get_default();
        powerprofile.bind_property(
            "icon-name",
            this,
            "power-profile-icon",
            SYNC,
        );
    }

    private setupWorkspaces() {
        const hyprland = Hyprland.get_default();
        const workspaceItems = new Map<number, Gtk.MenuButton>();

        const workspaces = hyprland.get_workspaces();
        for (const workspace of workspaces.sort(
            (a, b) => a.get_id() - b.get_id(),
        )) {
            const label = new Gtk.Label({ label: workspace.get_name() });
            const button = new Gtk.MenuButton({ child: label });
            workspaceItems.set(workspace.get_id(), button);
            this._workspaces.append(button);
        }

        const workspaceId1 = hyprland.connect(
            "workspace-added",
            (_, workspace) => {
                const label = new Gtk.Label({ label: workspace.get_name() });
                const newButton = new Gtk.MenuButton({ child: label });
                workspaceItems.set(workspace.get_id(), newButton);

                for (let i = workspace.get_id() - 1; i > 0; i--) {
                    const w = workspaceItems.get(i);
                    if (w) {
                        this._workspaces.insert_child_after(newButton, w);
                        return;
                    }
                }
                this._workspaces.prepend(newButton);
            },
        );

        const workspaceId2 = hyprland.connect(
            "workspace-removed",
            (_, workspace) => {
                const button = workspaceItems.get(workspace);
                if (button) {
                    this._workspaces.remove(button);
                    button.run_dispose();
                    workspaceItems.delete(workspace);
                }
            },
        );

        this.connect("destroy", () => {
            hyprland.disconnect(workspaceId1);
            hyprland.disconnect(workspaceId2);
        });
    }

    private setupTray() {
        const tray = AstalTray.get_default();
        const trayItems = new Map<string, Gtk.MenuButton>();

        const trayId1 = tray.connect("item-added", (_, id) => {
            const item = tray.get_item(id);
            const popover = Gtk.PopoverMenu.new_from_model(item.menu_model);
            const icon = new Gtk.Image();
            const button = new Gtk.MenuButton({ popover, child: icon });

            item.bind_property("gicon", icon, "gicon", SYNC);
            popover.insert_action_group("dbusmenu", item.action_group);
            item.connect("notify::action-group", () => {
                popover.insert_action_group("dbusmenu", item.action_group);
            });

            trayItems.set(id, button);
            this._traybox.append(button);
        });

        const trayId2 = tray.connect("item-removed", (_, id) => {
            const button = trayItems.get(id);
            if (button) {
                this._traybox.remove(button);
                button.run_dispose();
                trayItems.delete(id);
            }
        });

        this.connect("destroy", () => {
            tray.disconnect(trayId1);
            tray.disconnect(trayId2);
        });
    }

    private setupBluetooth() {
        const bt = AstalBluetooth.get_default();
        bt.bind_property("is-connected", this, "bluetooth-visible", SYNC);

        this.bluetooth_label = this.getBluetoothName(bt);

        bt.connect("device-added", (source) => {
            this.bluetooth_label = this.getBluetoothName(source);
        });

        bt.connect("notify::is-connected", (source) => {
            this.bluetooth_label = this.getBluetoothName(source);
        });

        bt.connect("device-removed", (source) => {
            this.bluetooth_label = this.getBluetoothName(source);
        });
    }

    private getBluetoothName(source: AstalBluetooth.Bluetooth): string {
        for (const dev of source.get_devices()) {
            if (dev.get_connected()) {
                return dev.get_alias();
            }
        }
        return "Disconnected";
    }

    change_volume(_scale: Gtk.Scale, _type: Gtk.ScrollType, value: number) {
        AstalWp.get_default()?.defaultSpeaker.set_volume(value);
    }

    change_mic_volume(_scale: Gtk.Scale, _type: Gtk.ScrollType, value: number) {
        AstalWp.get_default()?.defaultMicrophone.set_volume(value);
    }

    open_volume_settings() {
        GLib.spawn_command_line_async(
            "ghostty --class=Wiremix --title=Wiremix -e wiremix --tab output",
        );
    }

    open_network_settings() {
        GLib.spawn_command_line_async("nmgui");
    }

    open_bluetooth_settings() {
        GLib.spawn_command_line_async("blueberry");
    }

    open_notifications() {
        GLib.spawn_command_line_async("swaync-client -t -sw");
    }
}
