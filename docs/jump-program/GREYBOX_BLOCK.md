# Jump Program — Greybox Block Layout

The prototype's single city block, specified to the meter. Every gap and rise below is derived from the movement contract in §1 — if controller tuning changes those numbers, this geometry must be re-checked against them. The contract is the source of truth; the block is built from it.

Engine: **Godot 4**. Milestone: **M3** (built greybox-first from M0 onward — M0's spike uses the courtyard slab of this layout).

---

## 1. Movement Contract (controller ↔ geometry)

Character: capsule 1.8 m tall, 0.5 m radius. Run speed 6 m/s. Falling gravity ~1.8× rising gravity (authored arcs, kinematic `CharacterBody3D`, not physics-sim).

| Ability (tier) | Max rise, land on top | Max rise, grab & pull up | Max flat gap |
|---|---|---|---|
| Base jump (T0) | 1.0 m | 1.8 m (low-ledge grab) | 3.5 m |
| Charged jump (T1) | 2.6 m | 3.6 m (mantle) | 6.0 m |
| Double jump (T2) | 3.6 m | 4.6 m | 8.5 m |
| Wall jump (T2) | +2.0 m per wall contact; shaft width 2–4 m | — | — |

Combined rise + gap trades off: at max gap, usable rise drops to ~40% of max. Both max-rise routes below stay under 6 m of horizontal travel.

**Design rules**
- **Intended routes use ≤85% of the ability's max.** Forgiving by construction.
- **Sequence breaks use 95–100%.** Possible one tier early, only with perfect execution.
- Drops: roll landing (T2) negates lag on drops ≤8 m; any drop >12 m = knockdown + chain loss.
- All greybox geometry snaps to a **0.5 m grid**.

## 2. Plan View

Map axes: **x = east (0–56 m), z = north (0–36 m)**, origin at the block's SW interior corner, y = 0 at street level. Streets 8 m wide surround the block. (In Godot, north = −Z; build the block as authored and don't sweat the sign in greybox.)

```
                    N — across the street: THE TOWER (~40 m, out of bounds, lit)
   ┌────────────────────────────┬───┬──────────────────────────────────┐ z=36
   │                            │ A │   MID-RISE  roof 18 m            │
   │   WALKUP  roof 10 m        │ I │     ◦ antenna 22 m (precision)   │
   │                            │ R │   ▪ W ledge 15 m (shaft top)     │
   │   fire escape on S face:   │ S │   ▪ S AC shelf 15.5 m            │
   │   3.5 / 5.5 / 7.5 / 9.5 m  │ H │   ▪ S balcony 13 m               │
   │   AC units on S face:      │ A │                                  │
   │   3.2 / 5.8 / 8.4 m (seq.) │ F │                                  │
   │                            │ T │                                  │
   ├────────────────────────────┴───┴──────────────────────────────────┤ z=20
   │  ALLEY (6 m wide) — dumpster 1 m · clothesline poles 3 m (precision)
   ├──────────────┬──────────────────┬─────────────────────────────────┤ z=14
   │  BODEGA      │   COURTYARD      │   DEPOT  roof 7 m               │
   │  roof 4 m    │  planter 0.5     │   ▪ machinery 9 m (NE of roof)  │
   │  ▪ E awning  │  table 0.75      │   ▪ billboard catwalk 11 m      │
   │    2.5 m     │  dumpster 1.0    │     (on N edge, faces alley)    │
   │              │  van 2.2         │   ▪ W loading dock: crate 1.5 / │
   │              │  crates → dock   │     stack 3.5 / canopy 5 m      │
   └──────────────┴──────────────────┴─────────────────────────────────┘ z=0
   x=0           x=14              x=26                               x=56
                    S — player spawns on the south street
```

Footprints: Bodega x 0–14 / z 0–14 · Courtyard x 14–26 / z 0–14 · Depot x 26–56 / z 0–14 · Walkup x 0–24 / z 20–36 · Airshaft x 24–27 (3 m wide) · Mid-rise x 27–56 / z 20–36.

**Sightline rule:** from spawn, the player sees the Bodega awning (first idea), the Walkup fire escape above it (first desire line), and the Tower over everything (the long promise). The Mid-rise antenna should read against the sky from the courtyard.

## 3. Tier Summits

| Tier | Summit | Height | The moment |
|---|---|---|---|
| T0 | Bodega roof | 4 m | First rooftop. Courtyard learned as a chain playground. |
| T1 | Walkup roof | 10 m | First real altitude; whole block visible; Mid-rise routes now legible. |
| T2 | Mid-rise roof | 18 m | **Prototype summit.** Antenna tip precision landing, altitude-record fanfare, unobstructed stare at the Tower. |
| — | The Tower | ~40 m | Never reachable. That's the point. |

## 4. Routes (with step math)

Every step lists rise → required ability → % of that ability's max. Intended steps stay ≤85%.

### T0 — Courtyard line → Bodega roof (4 m)
1. Street → planter 0.5 → picnic table 0.75 → dumpster 1.0 — trivial hops, chain tutorial
2. Dumpster 1.0 → van roof 2.2 — rise 1.2, low-ledge grab (67%)
3. Van 2.2 → bodega E awning 2.5 — rise 0.3, hop (gap 2 m)
4. Awning 2.5 → bodega roof 4.0 — rise 1.5, low-ledge grab (83%)

### T1a — Fire escape → Walkup roof (10 m) *(intended)*
1. Alley dumpster 1.0 → platform 3.5 — rise 2.5, charged mantle (69%)
2. 3.5 → 5.5 → 7.5 → 9.5 — rises 2.0, charged jump (77%) each
3. 9.5 → roof 10.0 — step up

### T1b — Loading dock → Depot roof (7 m) *(intended)*
1. Courtyard crate 1.5 → crate stack 3.5 — rise 2.0, charged (77%)
2. Stack 3.5 → dock canopy 5.0 — rise 1.5, charged (58%)
3. Canopy 5.0 → depot roof 7.0 — rise 2.0, charged (77%)
4. Bonus: roof 7.0 → machinery 9.0 — rise 2.0, charged (77%)

### T2a — "The Catwalk Line" → Mid-rise roof (18 m) *(east route)*
1. Depot machinery 9.0 → billboard catwalk 11.0 — rise 2.0, charged (77%)
2. Catwalk 11.0 → Mid-rise S balcony 13.0 — **rise 2.0 + alley gap 6.0 m**, double jump (the route's signature leap)
3. Balcony 13.0 → S AC shelf 15.5 — rise 2.5, double (69%)
4. Shelf 15.5 → roof 18.0 — rise 2.5, double (69%)

### T2b — "The Shaft" → Mid-rise roof (18 m) *(west route)*
1. Walkup roof 10.0 → enter airshaft (3 m wide, walls to 15 m)
2. Wall jump 10 → 12 → 14 (two contacts, 2.0 m each) → grab W ledge 15.0
3. Ledge 15.0 → roof 18.0 — rise 3.0, double jump (83%)

### Sequence breaks *(95–100%, one tier early)*
- **Walkup S-face AC units:** van 2.2 → AC 3.2 → 5.8 → 8.4 → roof 10 — rises 2.6 = **100% of charged jump**. A perfect T1 player reaches the T1 summit without the fire escape, and a perfect T1 player who then chains AC 8.4 → fire-escape top can *see* no shortcut to Mid-rise — T2 stays gated.
- **Clothesline poles (3 m, precision):** a T0 player who chains dumpster → pole tips can touch the first fire-escape platform (3.5 from pole 3.0 = 1.7 rise, 94% of grab). One platform of the T1 route as a taste, no further.

**Gating audit:** Mid-rise requires either a 6 m gap **plus** 2 m rise (double jump only) or wall jumps (T2 only). No T1 combination reaches balcony 13, shelf, or ledge 15. The airshaft is capped at Walkup-roof height on the west wall so charged jumps can't cheese it.

## 5. Surface Inventory

Naming: `srf_<area>_<name>[_n]`. Every surface pays the one-time new-surface XP bonus; `precision` surfaces pay the precision bonus every clean landing; `tier` = intended tier (drives greybox color).

| id | y (m) | tier | precision | notes |
|---|---|---|---|---|
| srf_street_s / _n / _e / _w | 0 | 0 | | spawn on south |
| srf_court_planter_1/_2 | 0.5 | 0 | ✓ | 0.5 × 2 m rim |
| srf_court_table | 0.75 | 0 | | |
| srf_court_dumpster | 1.0 | 0 | | closed lid |
| srf_court_van | 2.2 | 0 | | 2 × 5 m roof |
| srf_bodega_awning_e | 2.5 | 0 | | slight bounce later? backlog |
| srf_bodega_roof | 4.0 | 0 | | T0 summit; parapet 0.5 |
| srf_bodega_sign | 5.0 | 1 | ✓ | above roof, street face |
| srf_court_crate | 1.5 | 1 | | |
| srf_court_cratestack | 3.5 | 1 | | |
| srf_depot_canopy | 5.0 | 1 | | loading dock, W face |
| srf_depot_roof | 7.0 | 1 | | biggest roof — chain playground |
| srf_depot_machinery_1/_2/_3 | 9.0 | 1 | | AC cluster, NE |
| srf_depot_catwalk | 11.0 | 2 | | billboard walkway, N edge |
| srf_depot_billboard_top | 13.0 | 2 | ✓ | 0.5 m wide lip |
| srf_alley_dumpster | 1.0 | 0 | | below fire escape |
| srf_alley_pole_1/_2/_3 | 3.0 | 1 | ✓ | clothesline poles, 0.3 m caps |
| srf_walkup_fe_1…_4 | 3.5–9.5 | 1 | | fire escape platforms |
| srf_walkup_fe_rail_1…_4 | +1.0 | 1 | ✓ | railings on each platform |
| srf_walkup_ac_1/_2/_3 | 3.2/5.8/8.4 | 2* | ✓ | *seq-break: T1 at 100% |
| srf_walkup_roof | 10.0 | 1 | | T1 summit; parapet 0.5 |
| srf_walkup_stairbox | 11.5 | 1 | | roof access hut |
| srf_mid_balcony_s | 13.0 | 2 | | catwalk leap target, 2 m deep |
| srf_mid_shelf_s | 15.5 | 2 | | AC shelf, 1.5 m deep |
| srf_mid_ledge_w | 15.0 | 2 | | shaft exit, 1 m deep |
| srf_mid_roof | 18.0 | 2 | | **prototype summit** |
| srf_mid_antenna_base | 19.0 | 2 | | |
| srf_mid_antenna_tip | 22.0 | 2 | ✓ | 0.3 m cap — the flex landing |

~40 unique surfaces with railing/pole variants — enough that "land on everything" is a real prototype goal (it seeds the Tier-5 flight gate mechanic without building it).

## 6. Godot Build Notes

- **One reusable `Surface` scene:** `StaticBody3D` → `MeshInstance3D` (BoxMesh) + `CollisionShape3D`, exported vars `surface_id: StringName`, `precision: bool`, `tier: int`, in group `landable`. Every entry in §5 is an instance. Uniform tagging beats ad-hoc CSG.
- **Landing detection:** on `is_on_floor()` becoming true, short downward raycast → collider → if in `landable`, hand `surface_id` etc. to the XP system. Walls for wall-jump/wall-run go in group `wallable` (Mid-rise shaft faces, Walkup S face).
- **Greybox materials by tier:** T0 gray, T1 blue, T2 orange, out-of-bounds red, precision surfaces get a white top face. Readability during playtests; art replaces it in M4.
- **Collision layers:** 1 = world, 2 = player. Kill-plane / soft-catch volume (`Area3D`) at street level around the block exterior to reset wanderers.
- **Scene structure:** `block.tscn` → one `Node3D` per structure (`Bodega`, `Depot`, `Walkup`, `MidRise`, `Courtyard`, `Alley`, `Tower`), surfaces as children. Tower is mesh-only, no collision on upper mass, red material.
- **Playtest telemetry (M3):** append every landing as JSON lines to `user://landings.jsonl` — `{surface_id, y, chain, tier, t}`. One session file per run. A landing heatmap over this map is the M3 exit review: dead surfaces get moved or deleted, hot accidental routes get promoted to intended ones.

## 7. Build Order

1. **M0:** courtyard slab + planter/table/dumpster/van only. Enough for the engine spike.
2. **M1:** add Bodega + alley. Tuning the T0/T1 contract happens against real targets, and §1's table gets corrected from the build.
3. **M3:** Depot, Walkup, Mid-rise, Tower, full tagging, telemetry. Re-audit every route's % against the final contract before calling the milestone done.
