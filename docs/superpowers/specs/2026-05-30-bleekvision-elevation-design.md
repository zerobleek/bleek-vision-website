<!--
  2026-05-30-bleekvision-elevation-design.md
  Bleek Vision Website
  Created by Shabaka Malik Banks on 5/30/26.
  Copyright © 2026 Bleek Vision LLC. All rights reserved.
-->

# Bleek Vision — Elevation Pass Design Spec

**Date:** 2026-05-30
**Branch:** `elevation-pass-2026-05` (baseline commit `a8e3976`; `main` frozen — no auto-deploy until merge)
**Author:** Shabaka Malik Banks (with Claude)
**Type:** Refinement of an existing, live static site — NOT a redesign.

---

## 1. Goal

Raise the craft of the existing `bleekvision.com` from "Good (16/20)" toward "18+" by resolving a small number of specific tensions and folding in the outstanding accessibility items from the prior impeccable audit. The site is already strong; this pass refines, it does not reinvent.

Success criteria:

- Hero reads with a single clear focal point.
- Product cards animate on scroll and respond to hover with the same level of life the hero already has.
- All P1 audit items resolved; re-run audit scores ≥ 18/20.
- Zero regressions to structure, copy, brand rules, or per-product color worlds.

## 2. Context

- **Stack:** Static site, two source files (`index.html` + `styles.css`), no build step, no framework, no package.json. Legal pages (`privacy.html`, `terms.html`) share a `.legal-*` system and are out of scope.
- **Hosting:** Cloudflare Pages, auto-deploys on push to `main`. Therefore all work happens on `elevation-pass-2026-05`; merge to `main` is gated on user approval.
- **Design source of truth:** `DESIGN.md` (token/visual capture) and `PRODUCT.md` (register, personality, anti-references, WCAG 2.1 AA target).
- **Prior audit:** impeccable scored 16/20 with open P1/P2 items (see §6).

## 3. Locked constraints (must not change)

From the project brand rules and `PRODUCT.md`:

- **Brand tokens:** navy ground `#121418`, silver ink `#C8CDD7`/`#D6DBE3`, single periwinkle accent `#89A1C3`. No new accent colors in the studio shell.
- **Per-product color worlds** stay exactly as authored (the card surface IS the app's color).
- **Structure & order:** nav → hero → work (5 cards) → founder → footer. No section added, removed, or reordered.
- **Copy:** unchanged. No new marketing language. Honest claims only (e.g. MadWeather has ads — do not claim otherwise).
- **Brand prohibitions:** never put location (Englewood NJ / coords), D-U-N-S, or EIN on the site. Legal name "Bleek Vision LLC" only in footer copyright + `<title>`.
- **Anti-references** to avoid: generic-SaaS template look, corporate gloss, loud/hype marketing.
- **Existing accessibility scaffolding** stays: `:focus-visible` rings, `prefers-reduced-motion` fallback, semantic landmarks, descriptive alt text.

## 4. In scope — the four moves

### Move 1A — Hero hierarchy: sentence leads

**Problem:** the hero stacks a ~148px animated wordmark (`.hero__wordmark`) AND a `clamp(52px,7.2vw,104px)` headline (`.hero h1`). Two competing focal points.

**Change:** demote the wordmark to a quiet, small centered brand-mark; promote the headline to the single hero focal point.

- `.hero__wm-bleek`: reduce from `clamp(72px,10vw,148px)` to roughly `clamp(20px,2.4vw,28px)`.
- `.hero__wm-vision`: scale proportionally (small tracked label beneath/beside).
- Keep the letter-by-letter reveal animation, just at the smaller size; keep `prefers-reduced-motion` behavior.
- Rebalance hero vertical spacing (`.hero__wordmark { margin-bottom }`, gap to `h1`) so the headline sits as the clear lead.
- `.hero h1` stays the dominant element; no copy change ("An independent development studio with **a point of view.**").

**Acceptance:** at desktop and mobile widths, the headline is unambiguously the largest/first thing the eye lands on; the wordmark reads as a brand signature, not a second hero.

### Move 2 — Card rhythm + scroll reveals

**Problem:** the hero animates on load, but the five product cards simply appear; all are locked at `min-height:620px` with strict alternation, reading slightly uniform.

**Change:**

- **Scroll reveal:** cards start at `opacity:0; transform:translateY(20px)` and transition to visible (`.is-in`) when scrolled into view, staggered.
- **Hover refinement:** on `.card:hover`, lift `.card__frame` (e.g. `translateY(-6px)` + subtle scale) and intensify `.card__glow` (raise opacity / blur bloom). Current hover is a flat `-2px` card lift.
- **Rhythm:** introduce light variation so the five cards don't feel mechanically identical (subtle min-height / emphasis variation — within the existing grid, no structural change).

**Acceptance:** scrolling the page reveals cards with a staggered fade-up; hovering a card produces a clear, smooth lift + accent bloom; reduced-motion users see all cards immediately with no movement.

### Move 3 — Motion & micro-interaction pass (woven through 1 & 2)

**Change:**

- Add easing tokens to `:root`:
  - `--ease-out: cubic-bezier(0.23, 1, 0.32, 1);`
  - `--ease-drawer: cubic-bezier(0.32, 0.72, 0, 1);`
- Apply `--ease-out` to the new reveal/hover transitions (Move 2) and hero transitions where relevant (Move 1).
- Add press feedback: `transform: scale(0.97)` on `:active` for `.btn` and `.card__cta` (and any other pressable), with a short `transform` transition (~140–160ms).
- Prefer transitions over keyframes for anything interruptible (already the pattern); only animate `transform`/`opacity`.

**Acceptance:** buttons visibly compress on press; motion uses the custom curves, not default CSS easings; no layout-affecting properties are animated.

### Move 4 — Accessibility / audit fixes (folded in, non-negotiable)

Resolve the outstanding impeccable items:

- **P1 — contrast:** raise `--w-muted` on the affected worlds to meet WCAG AA 4.5:1 for body text:
  - **MomKnows!** (`.card--momknows`): current `--w-muted: rgba(42,26,18,0.7)` on `#F5EDE3` ≈ 4.25:1 → darken to reach ≥ 4.5:1 (target ~`rgba(42,26,18,0.82)` or an equivalent solid; verify computed ratio).
  - **FOCUS//DECK** (`.card--focusdeck`): current `--w-muted: rgba(232,199,114,0.66)` on `#0A0907` ≈ 4.23:1 → raise opacity/lightness to ≥ 4.5:1 (verify).
- **P1 — mobile nav focus:** confirm closed `.nav__links` leave the keyboard tab order (the code already uses `visibility:hidden` + `pointer-events:none`; verify by tabbing on a narrow viewport). Fix if any link is still focusable when closed.
- **P2 — touch targets:** ensure interactive elements are ≥44×44px (the nav toggle already is; verify CTAs and card CTAs).
- **P2 — CLS:** confirm every product `<img>` has explicit `width`/`height` (most already do); add any missing.
- **P2 — justified text:** verify body copy is not justified (the cards/founder/legal use `text-wrap: pretty`, not `justify` — confirm none reintroduce justification).

**Acceptance:** all P1 items resolved with verified contrast numbers; keyboard pass clean; re-run audit ≥ 18/20.

## 5. Files & components touched

| File | Change |
|---|---|
| `styles.css` | Easing tokens; hero wordmark/h1 resize + spacing (Move 1A); card reveal start/end states + hover refinement + rhythm (Move 2); `:active` scale on pressables (Move 3); `--w-muted` contrast bumps + touch-target checks (Move 4). |
| `index.html` | ~15-line `IntersectionObserver` to toggle `.is-in` on cards, guarded by `prefers-reduced-motion` (Move 2); verify/add `width`/`height` on any product `<img>` missing them (Move 4). Existing nav-toggle JS unchanged. |
| `DESIGN.md` | Update after implementation to reflect new hero hierarchy, card motion, and corrected contrast tokens. |

No new files, dependencies, or build tooling. `privacy.html` / `terms.html` untouched.

## 6. Prior audit items (tracked)

| Item | Severity | Move |
|---|---|---|
| MomKnows `--w-muted` 4.25:1 fails AA | P1 | 4 |
| FOCUS//DECK `--w-muted` 4.23:1 fails AA | P1 | 4 |
| Mobile nav links keyboard-focusable when closed | P1 | 4 (verify) |
| Touch targets < 44px | P2 | 4 |
| Images missing lazy/dimensions (CLS) | P2 | 4 (verify) |
| Justified body text | P2 | 4 (verify) |

## 7. Verification plan

Static site → observational verification, no test framework:

1. **Contrast:** compute new `--w-muted` ratios; record before/after numbers; confirm ≥ 4.5:1.
2. **Reduced motion:** enable OS reduced-motion (or emulate in DevTools) → cards appear instantly, hero reveal quiets, no transform-based motion.
3. **Keyboard:** Tab through full page at desktop and narrow widths; closed mobile nav links must be unreachable; focus rings visible on every interactive element.
4. **Visual:** local preview via `python3 -m http.server` (port 4317); check hero focal point, card reveals on scroll, hover lift/bloom at ≥3 widths (≤560, ~768, ≥1180).
5. **CLS:** confirm no layout shift from images (dimensions present).
6. **Audit:** re-run impeccable; target ≥ 18/20.

## 8. Out of scope

- Any structural/section change, copy rewrite, or new section.
- Changes to per-product color worlds (beyond the two `--w-muted` contrast fixes).
- Legal pages, SEO/meta, structured data, hosting/deploy config.
- New fonts, libraries, or a build step.

## 9. Risks & mitigations

- **Risk:** shrinking the wordmark weakens brand presence. **Mitigation:** keep the letter-reveal + periwinkle "VISION" tracking so it still reads as a signature; validate visually before merge.
- **Risk:** scroll reveals feel sluggish or janky. **Mitigation:** animate only `transform`/`opacity`, custom `--ease-out`, short stagger (~80–120ms); reduced-motion guard.
- **Risk:** contrast bump muddies a product world's mood. **Mitigation:** smallest change that clears 4.5:1; verify the world still reads as intended.
- **Risk:** accidental deploy. **Mitigation:** all work on the branch; merge to `main` only on explicit user approval.

## 10. Deployment

Work stays on `elevation-pass-2026-05`. After verification and user sign-off, merge to `main`, which triggers the Cloudflare Pages auto-deploy (and the existing GitHub Action: CF cache purge + Google/Bing/IndexNow ping). User approves the merge.
