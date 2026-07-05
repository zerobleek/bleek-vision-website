# Jump Program — Game Plan

A 3D character traverses a city by jumping on surfaces. Every jump earns experience. Experience unlocks higher jumps and acrobatics, tier by tier, until the player earns the power of flight. The name nods to the Matrix's jump program; nothing else does.

**Platform:** iOS native (App Store), touch-first with MFi controller support
**Art direction:** PS2-era aesthetic — low poly, small textures, vertex lighting, hard fog
**First milestone:** playable prototype (one city block, core jump + XP loop)

---

## 1. Design Pillars

1. **The jump is the game.** Not combat, not story, not collectibles — the arc of a body through air, and the landing. If 30 seconds of aimless jumping isn't fun, nothing else matters.
2. **Mastery is literal altitude.** Progression isn't numbers going up in a menu; it's the city opening upward. The rooftop you stared at in hour one is your floor in hour five.
3. **Every surface counts.** The city is not scenery. Dumpsters, awnings, railings, AC units, fire escapes, ledges — everything is a landing zone, and landing somewhere new is always worth something.
4. **Earned flight.** Flight is not a power-up you find. It's what jumping becomes when you've fully learned the city. By the time you fly, you should feel like you no longer need the ground — flight just makes it official.

## 2. Core Loop

```
LOOK  →  pick a surface you can reach (or almost can)
JUMP  →  aim, charge, commit; steer and trick mid-air
LAND  →  clean landing banks XP; botched landing breaks your chain
GROW  →  XP fills the current tier; new tier = new verticality opens
```

The loop is self-reinforcing: each unlock makes previously unreachable surfaces reachable, which exposes new "almost reachable" surfaces, which motivates the next tier.

## 3. Progression: The Six Tiers

XP gates each tier. Numbers below are starting points for tuning, not commitments.

| Tier | Name | Unlocks | Vertical reach |
|---|---|---|---|
| 0 | **Grounded** | Run, base jump (~1.2 m), grab low ledges | Street furniture, dumpsters |
| 1 | **Lift** | Charged jump (~3 m), mantle/climb-up | Awnings, van roofs, low walls |
| 2 | **Momentum** | Double jump, wall jump, roll landing (no landing lag) | Fire escapes, low rooftops |
| 3 | **Flow** | Wall run, air dash, flips & spins (style multipliers) | Mid-rise rooftops, gap crossings |
| 4 | **Apex** | Super jump (charged, ~15 m, building-scale), glide | Towers, skyline traversal |
| 5 | **Flight** | Free flight | Everything |

Design intent per tier:

- **Tiers 0–1** teach precision: small jumps onto small targets. The city feels huge and hostile-tall.
- **Tier 2** is the "it clicks" moment: double jump + wall jump means routes, not just hops. Roll landing removes punishment and speeds up the loop.
- **Tier 3** is style: acrobatics multiply XP but risk the chain. This is where skilled players separate from cautious ones.
- **Tier 4** changes scale: one super jump covers what used to be a whole climbing route. Glide converts height into distance.
- **Tier 5 (Flight)** is the graduation ceremony. Gate it on more than raw XP — e.g. require landing on N% of unique surfaces or touching every district's highest point — so flight feels *earned from the city itself*.

### XP sources

| Action | XP rule |
|---|---|
| Clean landing | Base XP × (airtime + horizontal distance) |
| Precision landing | Bonus for small surfaces (railings, poles, ledge edges) |
| **New surface** | First-ever landing on any tagged surface pays a fat one-time bonus — the exploration engine |
| Chain | Consecutive jumps without stopping (>~1.5 s grounded) build a multiplier: ×1.1, ×1.2 … capped |
| Tricks | Flips/spins mid-air raise the multiplier; a botched landing (under-rotated, missed surface) drops the chain to zero |
| Altitude record | One-time bonus each time the player sets a new personal max height |

Failure is soft: a big fall causes a knockdown animation and chain loss — no death, no reload. The punishment is losing your multiplier, not your time.

## 4. Controls (touch-first)

- **Left half of screen:** floating virtual stick — move/steer (also steers mid-air; air control scales with tier).
- **Right half:**
  - **Tap** = jump. **Hold + release** = charged jump (Tier 1+), with a visible charge arc projected onto the world so aiming is spatial, not abstract.
  - **Tap in air** = double jump / air dash (Tier 2/3).
  - **Swipe up/down in air** = front/back flip; **swipe left/right** = spin (Tier 3).
- **Drag right side (no jump intent)** = camera orbit; camera otherwise auto-follows behind the character.
- **MFi / DualSense controller support from day one** — tuning jump feel is far easier on physical buttons, and it's a cheap App Store differentiator.

Feel requirements (non-negotiable, standard platformer kit):

- **Coyote time** (~0.1 s of jump grace after leaving a ledge)
- **Jump buffering** (a jump pressed just before landing fires on landing)
- Variable jump height (release early = shorter hop)
- Distinct landing states: clean / heavy / roll (Tier 2+) / botched
- Camera that anticipates jumps (tilts up on charge, pulls back with speed)

## 5. The City

Prototype scope is **one city block**, but designed as a fractal of the whole game's idea: a verticality ladder.

```
street (0 m) → dumpster (1 m) → awning (2.5 m) → fire escape (4–8 m)
→ low rooftop (10 m) → rooftop machinery (12 m) → mid-rise ledge (18 m)
→ [visible but unreachable in prototype: the tower]
```

Rules for city geometry:

- Every rooftop is reachable by **at least two routes** at the intended tier, and one "sequence-break" route for players a tier below who are clever.
- Surfaces are tagged (`unique_id`, `precision`, `tier_intent`) so the XP system and analytics know what the player is doing.
- The skyline always shows something you can't reach yet. Desire lines drive progression.
- Full game (later): 4–5 districts with rising average height — Old Town (low, dense, precision-focused) → Midtown (wall-run canyons) → Financial (towers, super-jump scale) → the Spire (flight gate).

## 6. Art Direction: PS2 Aesthetic

The PS2 look is mostly **asset discipline**, not shaders — and it's a perfect fit for mobile performance:

- Buildings 500–2,000 tris; character ~3,000 tris with visible joints acceptable
- Textures 128–256 px, **nearest-neighbor filtering** (crunchy pixels, no smearing)
- Vertex-colored lighting baked into meshes; no real-time shadows (blob shadow under the character — also a crucial landing-aim aid)
- Hard distance fog hiding a short draw distance (era-authentic *and* a perf win)
- Optional: render at ~70% internal resolution and upscale for the soft CRT-adjacent blur
- Chunky UI: bitmap-style font, hard-edged HUD boxes, memory-card-style save iconography
- Sound: compressed-sounding SFX, a drum-and-bass / trip-hop loop fits both the era and the "program" vibe

## 7. Tech Stack — recommendation

Two credible paths for "iOS native." **Recommendation: Godot 4** for the prototype, with RealityKit as the all-Apple alternative.

**Godot 4 (recommended)**
- `CharacterBody3D` + mature 3D platformer tooling: animation state machines, tweens, in-editor tuning while the game runs — jump *feel* iteration is the entire prototype risk, and this is where Godot pays for itself.
- Free, no runtime fee, exports to iOS cleanly (Metal renderer); PS2-style rendering is a well-trodden path in the Godot community (fog, nearest-neighbor, vertex lighting are all built-in toggles).
- Cost: GDScript/C# instead of Swift; one more toolchain in the studio.

**RealityKit + Swift (alternative)**
- Pure Apple stack, matches the studio's identity; `CharacterControllerComponent` (iOS 18+) covers kinematic movement; ECS architecture is clean. SceneKit is not an option — Apple deprecated it in 2025.
- Cost: you hand-roll what Godot gives free — animation state machines, tuning UI, level-editing workflow. Estimate the prototype takes 1.5–2× longer.

Decision gate: build M0 (below) in Godot. If it feels wrong in the hand within a week, the graybox design transfers to RealityKit unchanged.

Either way: **kinematic character controller with hand-tuned gravity** (heavier falling gravity than rising — the classic platformer trick), not a raw physics-sim character. Physics engines make characters feel like soap; jump arcs must be authored.

## 8. Prototype Milestones

Target: **prototype in ~5 focused weeks** (solo, part-time-compatible). Each milestone ends in a build on a real phone.

- **M0 — Engine spike (2–4 days).** Graybox plane, capsule character, follow camera, run + base jump, touch controls, running on device. *Gate: engine choice confirmed.*
- **M1 — Jump feel (1 week).** Charged jump with world-projected arc, coyote time, jump buffering, variable height, air control, landing states, camera anticipation. Tuning happens on device, daily. *Gate: aimless jumping is fun for 30 seconds.*
- **M2 — XP loop (1 week).** XP from landings, chain multiplier, new-surface bonus, HUD (XP bar + chain counter), first unlock (Tier 0 → 1: charged jump + mantle), progression saved locally.
- **M3 — The block (1–1.5 weeks).** One graybox city block built to the verticality ladder above, surface tagging, Tier 2 unlock (double jump / wall jump / roll), a reachable "summit" with a deliberate payoff moment.
- **M4 — Skin & juice (1 week).** PS2-style character model + block textures, jump/land/whoosh SFX, landing particles, speed-line trail at Tier 2+, music loop, app icon. **TestFlight build to a handful of players.**

**Prototype success criteria**
1. Testers keep chaining jumps with no goal given (watch, don't ask).
2. At least one tester asks "how do I get up *there*?" — desire line confirmed.
3. Tier unlock produces a visible behavior change (players immediately re-attempt previously failed routes).

**Deliberately cut from prototype:** flight (designed, not built — prototype ends at Tier 2), missions/challenges, NPCs, traffic, story, monetization, Game Center. The prototype answers exactly one question: *is jumping on this city fun and does the XP loop make you hungry?*

## 9. Risks

| Risk | Mitigation |
|---|---|
| Touch controls for 3D platforming are historically rough | Charged-aim jump (spatial targeting) over twitch inputs; controller support as first-class; generous coyote/buffer windows |
| Jump feel takes longer to tune than expected | It's the *entire* M1 milestone with a hard fun-gate; everything after is contingent |
| Solo 3D art production | PS2 aesthetic slashes cost by design; graybox until M4; buy/CC0 kitbash props where possible |
| Scope creep toward the full city | The block is the contract. New ideas go in this doc's backlog, not the build |
| Engine regret | M0 is a disposable spike; design doc is engine-agnostic |

## 10. Backlog (post-prototype ideas, parked)

- Time-trial ghost routes; daily "line of the day" challenge
- Photo mode (PS2 filter selfies from the skyline)
- Altitude-based ambient audio (street noise fades to wind)
- Districts, weather, day/night
- A reason the city is empty (light narrative framing — "the program" — worth one page, later)
