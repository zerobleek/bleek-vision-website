# bleekvision.com — Site Reorganization Design
**Date:** 2026-10-08  
**Scope:** index.html restructure + hero update + stats bar + technologies section + EstoppelBot card update  
**Approach:** B — Split with visible section labels

---

## 1. Hero

### Current
> H1: "An independent app and game studio."

### New
> H1: "An independent studio building apps, games, and tools."  
> Subhead: "One developer. The best AI tools. Shipping across iOS and web."

**Rationale:** Adds SaaS to the positioning ("tools"), signals AI-native development without anthropomorphizing AI, and makes the solo-founder scale legible upfront. Targets Anthropic startup program reviewers and investors landing cold.

---

## 2. Stats Bar

Sits between the hero and the Apps & Tools section. A single horizontal row — plain, no animation.

| Number | Label |
|--------|-------|
| 4 | iOS apps live on the App Store |
| 1 | Web platform live |
| 4 | Product categories |
| 1 | Developer |

**Visual treatment:** Number in accent color (`--accent: #89A1C3`), label in muted text (`--mute`). Muted vertical dividers between items. No counters, no motion. Collapses to 2×2 grid on mobile (≤560px).

---

## 3. Navigation

### Current
`Work · About`

### New
`Apps · Games · About`

- `Apps` anchors to `#apps` section
- `Games` anchors to `#games` section  
- `About` anchors to `#about` (founder section — unchanged)
- Hamburger menu behavior unchanged at 769px breakpoint

---

## 4. Page Structure & Card Ordering

Single flat `.work` section replaced by two discrete sections.

### Section 1: `#apps` — "APPS & TOOLS"

Cards in order (live first, coming soon last):

1. MadWeather — live, App Store
2. FOCUS//DECK — live, App Store
3. MomKnows! — live, App Store
4. Estoppel Bot — **live, EstoppelBot.com** (updated from IN DEVELOPMENT → LIVE; href → `https://estoppelbot.com`)
5. Cipher Protocol — coming Spring 2027

### Section 2: `#games` — "GAMES"

Cards in order:

1. UNCONTAINED — live, App Store
2. Go, Bobby, Go! Road Trip — coming soon

**Alternation rule:** Image-left / image-right alternation restarts independently at the top of each section. UNCONTAINED begins image-right (same as current).

### Section label treatment
All-caps, muted color (`--mute`), letter-spaced — matches existing card status badge style. Acts as a section marker, does not compete with product names.

---

## 5. Technologies Section

**Placement:** Between the Games section and the Founder (`#about`) section.

**Label:** `BUILT WITH` — same all-caps muted treatment as section labels.

**Content:** Four wordmark treatments in a horizontal row:

`Claude · Cursor · ChatGPT · Higgsfield`

- Styled as names only — no icons, no descriptions, no external links
- Muted text color, not accent — supporting context, not a CTA
- Equal weight and size across all four
- Mobile (≤560px): wraps to 2×2 grid

---

## 6. EstoppelBot Card Changes

| Field | Before | After |
|-------|--------|-------|
| `href` | `estoppelbot.html` | `https://estoppelbot.com` |
| Status badge | `IN DEVELOPMENT` | `LIVE` |
| Status dot | `dot--mute` | `dot--live` |

`estoppelbot.html` remains at its URL (not deleted, not linked from nav or cards).

---

## 7. Files Changed

| File | Change |
|------|--------|
| `index.html` | Hero copy, stats bar, section split, section labels, nav links, tech section, EstoppelBot card href + badge |
| `styles.css` | Stats bar styles, section label styles, tech section styles, `#apps` / `#games` anchor ids |
| `sitemap.xml` | No change (index.html remains the canonical URL) |

---

## 8. Out of Scope

- EstoppelBot.com landing page redesign (separate session)
- Banks' Cee-Lo, Bones Champion cards (not added to site yet)
- Go, Bobby, Go! Road Trip full card build (card already exists, no changes)
- Cipher Protocol card (no changes)
- Privacy / terms / support pages
- `estoppelbot.html` content changes
