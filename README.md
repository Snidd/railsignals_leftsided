# Left-Sided Rail Signals

A Transport Fever 3 mod for left-hand running railways (Sweden, France, UK, Japan, …).
It moves railway signals from the default right side of the track to the **left** side.

- Covers both vanilla signals (era A and era C, one-way and two-way) and signals from other mods.
- Purely cosmetic: signal behaviour is unchanged. Signals are mirrored, so heads and arms still lean toward the track.
- Safe to add to or remove from an existing save. Signals simply switch sides.

## Install

**Players:** subscribe in the in-game mod browser (mod.io) and enable "Left-Sided Rail Signals" when starting or loading a game.

**Developers** (macOS):

```sh
scripts/link.sh          # symlink the mod into TF3's local mods folder
scripts/link.sh --copy   # or copy it instead
scripts/check.sh         # type-check the Teal scripts against the game's definitions
```

`link.sh` finds `~/Library/Application Support/Steam/userdata/<id>/3493540/local/mods`. Set `TF3_MODS_DIR` to override it.
`check.sh` needs Lua 5.4 and Teal: `brew install lua@5.4 luarocks && luarocks install --local tl`. Set `TF3_DIR` if the game isn't in the default Steam location.

## How it works

TF3 signals are constructions that snap to tracks. Their `updateFn` returns the signal model with a placement transform. The right-side offset is built into the model geometry (lateral axis Y, right side = −Y).

1. `content/mod.script.tl` (`postRunFn`) redirects the `updateScript` of every construction with `edgeObject.snapToTrack` to the wrapper. It passes along the original script reference and its params.
2. `content/leftsided.script.tl` calls the original `updateFn`. If the result contains `signal`, it mirrors every `edgeModels[i].model.transf` across the track centreline (`diag(1, −1, 1)`).

No vanilla files are copied or overridden.

## For signal mod authors

Your signals are mirrored automatically. To keep a signal on its original side, opt out in its `.con`:

```lua
updateScript = {
	fileName = "my_signal.script@updateFn",
	params = {
		leftsidedIgnore = true,
	},
},
```

Your `updateFn` is called with the same arguments as without this mod. Constructions that snap to tracks but return no `signal` are left untouched.

## Testing

See [TESTING.md](TESTING.md) for the manual in-game checklist. Game log: `…/3493540/local/crash_dump/stdout.txt`. This mod's lines are tagged `[leftsided]`.

## License

[MIT](LICENSE) © 2026 Snidd
