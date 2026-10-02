# Manual test checklist

TF3 has no automated test harness, so every release runs through this list in-game.
Install the dev build with `scripts/link.sh`. Check the log afterwards for `[leftsided]` lines and `- ERROR`:
`~/Library/Application Support/Steam/userdata/<id>/3493540/local/crash_dump/stdout.txt`

## Setup

- [ ] Mod list shows "Left-Sided Rail Signals" (and "Vänstersidiga signaler" with the game in Swedish)
- [ ] Log shows `[leftsided] wrapped …signal_path_a.con` and `…signal_path_c.con`, with no `- ERROR` lines from `leftsided`

## Placement and looks

Run this for both signals: era A (`signal_path_a`, before 1950) and era C (`signal_path_c`, 1950 on).

- [ ] The placement preview shows the signal, and clicking the track places it
- [ ] The signal stands on the **left** of the track, as seen by a driver approaching it
- [ ] Heads and arms lean toward the track, not away from it
- [ ] No inside-out or see-through faces, at close range and when zoomed out (LOD switches at ~87 m and ~260 m)
- [ ] The lights' red and green glow shows at night and points toward approaching trains
- [ ] Two-way and one-way (the "One-Way" param) both place and look correct
- [ ] On double track, the signal doesn't clip into the neighbouring track or its catenary

## Behaviour

Build a double-track line with two stations and at least two trains per direction.

- [ ] Trains stop at red and proceed on green, on the track the signal was placed on
- [ ] A one-way signal blocks trains running against it
- [ ] Two-way signals work in both directions on single track
- [ ] Bulldozing a signal and replacing it (and switching it between one-way and two-way) works

## Saves

- [ ] Save a game with the mod and signals placed, disable the mod, and load it: signals are back on the right, trains still run, no errors
- [ ] Enable the mod again and reload: signals are back on the left

## Other mods (Q13 / Q23)

- [ ] Subscribe to a signal mod from mod.io: its signals are mirrored too (log shows `wrapped`)
- [ ] A construction with `leftsidedIgnore = true` in its `updateScript.params` stays on the right (log shows `skipped`)
