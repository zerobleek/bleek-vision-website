# Jump Program — prototype (M4)

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

**M2 — the XP loop**
- `xp_system.gd`: airtime + distance pay base XP, first-ever landing on any tagged surface pays the exploration bonus (+25), precision surfaces pay every clean landing (+15), altitude records pay per meter. Consecutive jumps (taking off within 1.5 s of landing) build a chain multiplier up to ×2; heavy landings break the chain, knockdowns forfeit the jump's XP entirely. A mantle counts as landing on the grabbed surface.
- Tiers: **you start at Tier 0 — charging is locked.** 150 XP unlocks Tier 1 (charged jump), 500 XP announces Tier 2 (abilities land in M3). Progress persists in `user://save.json`; delete it to replay the progression.
- `xp_hud.gd`: XP bar toward next tier, chain counter, per-landing "+N ×mult" popups, tier-up banner. Debug HUD stays separate and dev-only.

**M2 exit gate:** the Tier 1 unlock visibly changes behavior — you immediately retry the fire-escape-height stuff you failed before.

**M3 — Tier 2 and the whole block**
- Double jump (tap in air; redirects toward the stick, +1 m apex), wall jump (tap while against a wall, +2 m per contact), roll landing (4–8 m drops no longer stun at T2). All gated on Tier 2 (500 XP).
- Full block geometry per `GREYBOX_BLOCK.md`: Depot (loading dock → roof → machinery → billboard catwalk), Walkup (fire escape + railings, AC-unit sequence break, roof, stairbox), the wall-jump airshaft, Mid-rise (balcony → shelf → **roof, 18 m, the prototype summit** → antenna tip at 22 m), and the unreachable Tower watching over everything. Both intended T2 routes are in: the Catwalk Line (signature double-jump gap across the alley) and the Shaft (wall-jump chimney).
- Landing telemetry: every landing appends a JSON line (surface, kind, drop, airtime, chain, tier, xp) to `user://landings_<datetime>.jsonl`, one file per session — playtest heatmap fuel.

**M3 exit gate:** both routes to the Mid-rise roof are completable, the Tier-1 sequence breaks work at high execution, and nothing lets a tier climb early (see the as-built audit in the greybox doc).

**M4 — the PS2 skin**
- **Textures** (`assets/textures/`): six procedurally generated 128 px tiles — brick, concrete, asphalt, metal, wood, and dusk office windows — applied by `surface.gd` via surface-id rules, world-triplanar mapped with **nearest-neighbor filtering**. A faint tier tint stays on top so routes remain legible; the Tower stays hard red.
- **Character** (`character_body.gd`): blocky low-poly figure built and animated in code — run cycle, charge crouch, air tuck, a full flip on the double jump, landing squash scaled by impact. Navy suit, periwinkle visor (studio colors).
- **Audio** (`assets/audio/`, `audio_director.gd`): synthesized placeholder SFX for every jump/land/grab flavor, a chain blip that rises in pitch with the multiplier, a tier-up chime, and a 9.6 s lo-fi break loop at 100 BPM. All generated WAVs — real sound design replaces the *files*, the wiring stays.
- **FX** (`fx.gd`): hard little cube particles — landing dust scaled by impact, speed lines past 8 m/s. No soft alpha sprites; the era demands cubes.
- **Render**: 75% internal 3D resolution upscaled, anisotropic filtering off, denser warm dusk fog, warm key light.

**M4 exit gate:** a TestFlight build in testers' hands (requires a Mac — see iOS export below).

## iOS / TestFlight export (needs your Mac)

1. In Godot: Editor → Manage Export Templates → download for 4.4.x.
2. Project → Export → Add → iOS. Set your Apple Team ID, bundle id (e.g. `com.bleekvision.jumpprogram`), and app icons (source: `icon.svg`).
3. Export the Xcode project, open it, sign with your distribution cert, archive, upload to App Store Connect, add to a TestFlight group.
4. `export_presets.cfg` is gitignored on purpose — it will contain your team identifiers.

## Design-only for now

Tiers 3–5 (flips as input tricks, super jump, glide, flight), districts beyond the block.
