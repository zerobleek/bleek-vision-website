# Jump Program — M0 prototype

Godot 4.4 project. Design docs live in [`../docs/jump-program/`](../docs/jump-program/) — `PLAN.md` (game plan) and `GREYBOX_BLOCK.md` (level spec; §1 is the movement contract these scripts implement).

## Run it

1. Get [Godot 4.4+](https://godotengine.org/download) (standard build, not .NET).
2. Open this folder as a project, press F5.

## Controls

| | Desktop | Touch |
|---|---|---|
| Move | WASD / left stick | drag left half (floating stick) |
| Jump | Space / gamepad A | tap right half (hold for full height) |
| Camera | drag right half with mouse | drag right half |
| Reset | R | fall off the world |

## What's in M0

- Kinematic controller (`scripts/player.gd`): authored jump arc (apex height + time-to-apex, 1.8× falling gravity), variable jump height, coyote time, jump buffering. **All feel numbers are exports — tune live while the game runs.**
- Floating virtual joystick + tap-jump touch layer (`touch_controls.gd`, autoload), mouse-emulated on desktop.
- Follow-orbit camera (`camera_rig.gd`), landing detection with tagged surfaces (`surface.gd`).
- Courtyard greybox from `GREYBOX_BLOCK.md`: planters → table → dumpster → van chain. Debug HUD shows speed, altitude, coyote/buffer state, last surface landed.

**M0 exit gate:** it runs on an iPhone and the dumpster→van jump (1.2 m rise at 92% of the base arc) feels *just barely* makeable.

## Not yet (on purpose)

Ledge grab (M1), charged jump (M1), XP (M2), the other buildings (M3), any art (M4).
