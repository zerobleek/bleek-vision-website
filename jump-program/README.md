# Jump Program — prototype (M1)

Godot 4.4 project. Design docs live in [`../docs/jump-program/`](../docs/jump-program/) — `PLAN.md` (game plan) and `GREYBOX_BLOCK.md` (level spec; §1 is the movement contract these scripts implement).

## Run it

1. Get [Godot 4.4+](https://godotengine.org/download) (standard build, not .NET).
2. Open this folder as a project, press F5.

## Controls

| | Desktop | Touch |
|---|---|---|
| Move / aim | WASD / left stick | drag left half (floating stick) |
| Jump | Space / gamepad A | right half of screen |
| Camera | drag right half with mouse | drag right half |
| Reset | R | fall off the world |

**One jump input, continuous:** the jump fires on *release*. A quick tap is the base jump; holding past 0.15 s enters a charge stance (movement slows to aiming speed, a projected arc + landing ring appears in the world) and release launches up to the full charged jump. Tap, variable height, and charged jump are the same gesture at different durations.

## What's in so far

**M0 — feel foundation**
- Kinematic controller (`scripts/player.gd`): authored jump arc (apex height + time-to-apex, 1.8× falling gravity), coyote time, jump buffering. **All feel numbers are exports — tune live while the game runs.**
- Floating virtual joystick touch layer (`touch_controls.gd`, autoload), mouse-emulated on desktop.
- Follow-orbit camera (`camera_rig.gd`), landing detection with tagged surfaces (`surface.gd`).

**M1 — the T0/T1 kit**
- Charged jump (T1) with world-projected trajectory arc and landing ring (`jump_arc.gd`) — simulates the exact launch physics, so the preview never lies.
- Mid-air ledge grab + mantle: push the stick at a wall whose top is within reach and the character pulls up over it. One mechanic covers the contract's T0 low-ledge grab (tap apex 1.3 + 0.6 reach ≈ 1.9 m) and T1 mantle (charged apex 3.0 + 0.6 ≈ 3.6 m).
- Landing states: clean / heavy (≥4 m drop, brief stun) / knockdown (>12 m, long stun). Chain loss hooks into these in M2.
- Camera anticipation: FOV widens with speed, arm pulls back while charging.
- Geometry: Bodega + alley added per the greybox build order — the full T0 route (planters → table → dumpster → van → awning → **Bodega roof, the T0 summit**), bodega sign, alley dumpster, clothesline poles.
- `player_tier` export gates charging (tier ≥ 1); the XP system drives it from M2.

**M1 exit gate:** aimless jumping is fun for 30 seconds, and the courtyard→Bodega-roof climb teaches itself.

## Not yet (on purpose)

XP + chain multiplier + unlocks (M2), Depot/Walkup/Mid-rise/Tower (M3), any art or sound (M4).
