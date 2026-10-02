# Intent: Left-Sided Rail Signals (Transport Fever 3)

## What we are building

A Transport Fever 3 mod for **left-hand running** railways (Sweden, France, UK, Japan, …).
It moves the game's railway signals and waypoints from the default right side of the
track to the **left side** by mirroring them across the track centreline.

The mod is purely cosmetic: it changes where signals are drawn, never what they are or how
they behave. Removing it from a save must be safe; signals simply jump back to the right.

## Decisions

| #   | Topic                    | Decision |
| --- | ------------------------ | -------- |
| Q1  | Motivation               | Left-hand running. The whole signal setup is mirrored, not just moved sideways. |
| Q2  | Signals covered          | All built-in signals and waypoints (one-way, two-way, waypoints, every era). |
| Q3  | Replace vs. add          | **Replace**: existing and new signals move left. No duplicate signals in the build menu. |
| Q4  | Dev environment          | TF3 runs on this Mac (Steam, app id 3493540). Built and tested here. |
| Q5  | Distribution             | Local first, then **mod.io** through the in-game mod browser (TF3 has no Steam Workshop). |
| Q6  | Version control          | `git init` with a `.gitignore` for OS junk when building starts. |
| Q7  | Identity                 | Folder/ID `snidd_railsignals_leftsided`. Display name "Left-Sided Rail Signals" / "Vänstersidiga signaler". Author **Snidd**. Version goes in `revision` in `mod.json`. |
| Q8  | Save safety              | Removing the mod must be safe. Same model paths, no new signal types stored in saves. |
| Q10 | Languages                | English and Swedish (`strings.json`). |
| Q11 | Technique                | **Script patch** in `content/mod.script.tl`: edit signal models' position in `postRunFn` with `api.res.modelRep` (`getAsTable`/`setAsTable`). Fallback: override the vanilla `.mdl` files in the mod. |
| Q12 | Mirror vs. shift         | **Mirror** across the track centreline, so arms and brackets still reach toward the track. Check in-game for inside-out rendering. |
| Q9/Q13 | Scope of the patch    | **All models with a `signal` block**, vanilla and other mods' signals. Mod authors can opt out with `metadata.signal.dontmove = true`. |
| Q14 | Severity                 | `cosmetic: true`, lowest `severityAdd`/`severityRemove` (exact values to be checked). |
| Q15 | Build-menu icons         | Not mirrored in v1. |
| Q16 | Script language          | Teal (`.tl`). |
| Q17 | Testing                  | Manual in-game test checklist kept in the repo (see below). Snidd runs the game; Claude writes the checklist and fixes issues. |

### Confirmed after the download

| #   | Topic              | Decision |
| --- | ------------------ | -------- |
| Q18 | Repo layout        | The repo root holds `snidd_railsignals_leftsided/` (the shipped mod) plus repo-only files. `scripts/link.sh` symlinks the mod into the game's local mods folder. |
| Q19 | Teal tooling       | Install `tl` locally to type-check the script against the game's own Teal definitions (`api/tealdef`, `base/tealdef`, `vscode-template/tlconfig.lua`). |
| Q20 | Mod settings       | No in-game options in v1. |
| Q21 | License & docs     | MIT. README (what it does, install, `dontmove` opt-out), CHANGELOG matching `revision`. Snidd takes the in-game screenshot for `_metadata/0.png`. |

### Decided after inspecting the game files

| #   | Topic              | Decision |
| --- | ------------------ | -------- |
| Q22 | Hook mechanism     | **Wrapper script.** `postRunFn` redirects every `snapToTrack` construction's `updateScript` to `leftsided.script@updateFn`, passing `{ original, originalParams }` as closure params. The wrapper calls the original and flips Y in each `edgeModels[i].model.transf` when `result.signal` is present. Fallback: override the two vanilla `.script.lua` files. |
| Q23 | Opt-out            | Signal mods add `leftsidedIgnore = true` to their `updateScript.params`. |
| Q24 | Scope              | The two vanilla signals plus any mod signal. Tunnel portal signal decorations are out of scope. |
| Q25 | Severity           | `severityAdd` and `severityRemove` both `"None"`, `cosmetic: true`. |
| Q26 | Mirroring fallback | If mirroring renders wrong, shift to +Y without flipping and document it as a known limitation. |

## Planned layout (per Q18)

```
railsignals-leftsided/              # repo root
├── Intent.md
├── README.md
├── CHANGELOG.md
├── LICENSE
├── TESTING.md                      # manual test checklist
├── scripts/link.sh                 # symlink mod into the game's local mods folder
└── snidd_railsignals_leftsided/    # the shipped mod
    ├── mod.json
    ├── strings.json                # en + sv
    ├── _metadata/
    │   ├── modinfo.json
    │   ├── description.html
    │   └── 0.png
    └── content/
        └── mod.script.tl
```

## Background (research, not verified in game files yet)

- TF3 released 29 Sept 2026 (Windows, macOS, Linux, consoles). Mods are distributed through mod.io.
- Modding wiki: https://wiki.transportfever3.com/doku.php?id=modding
  - Mod definition: `modding:general:moddefinition`
  - Mod scripts: `modding:general:modscripts`. You can't add new 3D assets, only reuse existing `.mdl` files.
  - `.mdl` format: `modding:general:resourcetypes:mdl`. Still a Lua `data()` table with LOD nodes and a 16-value `transf`.
  - Signals: `modding:infrastructure:signals`.
- TF2 signal types: `WAYPOINT`, `PATH_SIGNAL` (two-way), `ONE_WAY_PATH_SIGNAL`. The direction a signal applies to comes from its type and how it was placed, not from the model.
- Prior art: TF2 "left-hand railway signal" (added copies; removed from the Workshop). TF2 "Signal Distance" moved all signals by script and had a `dontmove` opt-out.
- **Unknown:** whether the right-side offset is in the model (`transf` or mesh) or set by the engine.

## Findings from the installed game (2026-10-02)

Install: `~/Library/Application Support/Steam/steamapps/common/Transport Fever 3`. Base content is zipped (`base/content/**/*.zip`).

- **Only two vanilla signals**, in `base/content/infrastructure/signal.zip`:
  - `signal/signal_path_a` (era A, until 1950) and `signal/signal_path_c` (from 1950)
  - each is a `.con.lua` construction with `edgeObject = { snapToTrack = true }` and a `oneWay` param (default: two-way), plus a `.script.lua` whose `updateFn` returns `result.signal = { type = "PATH_SIGNAL" }` and `result.edgeModels = { { model = { id = resolve("signal_path_x.mdl"), transf = identity } } }`, plus the `.mdl`
- **No vanilla waypoints** (Q2 only covers the two signals). No other vanilla or DLC construction uses `snapToTrack`.
- **The right-side offset is baked into the model geometry**, not engine-controlled. The axes are X = along the track, Y = sideways, Z = up. Right side is **−Y**: path_a's bounding box is Y −4.08…−1.91, path_c's is Y −2.90…−2.10. The heads sit about 0.5 m closer to the track than the mast.
- **Mirroring means applying `diag(1, −1, 1)`** to the `edgeModels[i].model.transf` that `updateFn` returns. The model files aren't touched. Rotating 180° instead would make the signal face backwards. Shifting sideways would make the heads lean away from the track.
- **How to hook in:** `api.res.constructionRep` (`getAll`/`get`/`setAsTable`). The base game's own `postRunFn` swaps a construction's `updateScript` for an `api.type.ScriptRef` with a new `fileName` and `params`. `ScriptRef.params` get appended to the arguments the script is called with.
- The construction `metadata` record is typed (only `emissionConfig`), so a TF2-style `metadata.signal.dontmove` can't be used for opting out.
- `mod.json` severity values seen: `"None"`, `"Warning"`. The DLC uses `cosmetic: true`, `severityAdd: "None"`, `severityRemove: "Warning"`, and `autoActivate`.
- Teal definitions ship with the game. Scripts load other scripts with `ug_require "<path>" as <Type>`.
- Out of scope: the tunnel portal decoration models `tunnel/rail_blocking/tunnel_*_add_signal_lft.mdl` (part of the tunnel models, not placeable signals).

## Next steps once the download completes

1. **Inspect vanilla signals** in `~/Library/Application Support/Steam/steamapps/common/Transport Fever 3`:
   - where the signal/waypoint `.mdl` files live (expected under `infrastructure`)
   - whether the right-side offset is in the node `transf` or baked into the mesh
   - which axis is "sideways", and whether two-way signals sit differently from one-way signals
   - the TF3 metadata field names for signals
2. **Find the facts left open**: the allowed `mod.json` severity values, the exact `modinfo.json` / `strings.json` schema, the local mods folder path on macOS, and whether any Teal type definitions ship with the game.
3. **Re-check Q11/Q12** against these findings. If the offset is engine-controlled or can't be changed by script, return to these decisions before building.
4. Get confirmation on Q18–Q21, then `git init` and scaffold the layout above.
5. Write `mod.script.tl`: loop over models, select those with a `signal` block and no `dontmove`, and mirror the lateral axis of their transforms.
6. Symlink into the local mods folder and run the first in-game check: does it mirror, does it render correctly, do trains still obey the right signals?
7. Write `TESTING.md` and run the full checklist:
   - double track with one-way signals, two-way signals and waypoints, for every era, viewed from both directions
   - a save made with the mod, then loaded without it
   - a signal mod from mod.io, to confirm it gets mirrored, and that `dontmove` opts it out
8. Docs, preview image, then publish to mod.io.
