# Quickshell bar refactor

This is the same bar split into multiple QML files.

## Layout

- `shell.qml` - root layout, screens, notification server, module placement
- `Style.qml` - global style singleton; edit colors, spacing, radius, fonts here
- `common/` - reusable UI primitives
- `modules/` - bar modules

## Launch from this directory

```bash
quickshell -p shell.qml
```

or, if your quickshell build expects a config directory:

```bash
quickshell -c "$PWD"
```

## Notes

- The old input and output modules are merged into `modules/SoundModule.qml`.
- `SoundModule { inputMode: true }` is microphone input.
- `SoundModule { inputMode: false }` is audio output.
- `Style.qml` is a singleton registered by `qmldir`; keep `qmldir` next to it.
- You still need external tools available if you use their buttons: `pavucontrol` and `blueman-manager`.
