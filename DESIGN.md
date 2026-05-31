# Design

Visual system for the Bleek Vision marketing site, captured from `styles.css` and `index.html`. Studio shell is a restrained dark theme; each product card opens its own color world.

## Theme

Dark, near-black navy ground with cool silver ink and a single periwinkle accent. Calm, engineered, nocturnal — a quiet gallery wall on which the apps' own colors light up. Ambient motion (drifting aurora blobs, a pulsing live dot, a letter-by-letter wordmark reveal) adds life without noise, and fully quiets under `prefers-reduced-motion`.

## Color

Studio palette (CSS custom properties, hex as authored):

| Token | Value | Role |
|---|---|---|
| `--bg` | `#121418` | Page ground (navy-black) |
| `--bg-soft` | `#161922` | Slightly lifted ground |
| `--panel` | `#171A20` | Panel surface |
| `--panel-hi` | `#1C2028` | Raised panel |
| `--ink` | `#D6DBE3` | Primary body text |
| `--silver` | `#C8CDD7` | Headings / wordmark |
| `--mute` | `#7A8493` | Muted text, meta, eyebrows |
| `--mute-deep` | `#4E5A6B` | Faint labels |
| `--rule` | `rgba(214,219,227,0.08)` | Hairline borders |
| `--rule-hi` | `rgba(214,219,227,0.14)` | Stronger borders |
| `--accent` | `#89A1C3` | Periwinkle — the one studio accent |
| `--accent-deep` | `#5C7090` | Accent shade |
| `--accent-soft` | `rgba(137,161,195,0.18)` | Accent halos / glows |
| `--live` | `#7EC8A0` | "Live on the App Store" status |

**Per-product worlds** (scoped vars on each `.card--*`: `--w-bg`, `--w-surface`, `--w-text`, `--w-muted`, `--w-accent`, `--w-mount`, `--w-cta-bg`, `--w-cta-text`):

- **MadWeather** — deep blue `#0F1B2D`, amber accent `#FFB142`, white text.
- **FOCUS//DECK** — near-black `#0A0907`, gold text/accent `#E8C772`/`#F2D27A` (mono title). Muted body `--w-muted: rgba(232,199,114,0.66)` ≈ 5.65:1 on the near-black bg (passes WCAG AA).
- **UNCONTAINED** — black-brown `#0B0805`, hot orange `#FF7A1A`, white text.
- **MomKnows!** — warm light world `#F5EDE3` bg, terracotta `#C5532A`, dark ink `#2A1A12`. (The one light card.) Muted body `--w-muted: rgba(42,26,18,0.7)` ≈ 5.78:1 on cream (passes WCAG AA).
- **Cipher Protocol** — black-green `#04100A`, neon green `#36F07A`/`#5BF08C`.

Strategy: **restrained** studio shell (one accent ≤10% of surface) wrapping **drenched** product cards (the card surface IS the app's color).

## Typography

- **Display:** `Outfit` (Google Fonts, weights 300 + 800) — the BLEEK / VISION wordmark and brand marks. Heavy 800 for "BLEEK", light 300 wide-tracked for "VISION".
- **Body / headings:** system sans stack (`-apple-system, BlinkMacSystemFont, "SF Pro Display/Text"…`). Tight tracking (-0.01 to -0.045em) at large sizes.
- **Mono:** system mono (`ui-monospace, "SF Mono", "JetBrains Mono"…`) for eyebrows, status chips, meta, footer column heads, legal labels.
- **Serif:** system serif, used only for the italic founder signature.
- Scale: fluid `clamp()` throughout. Hero wordmark up to 148px; hero h1 `clamp(52px, 7.2vw, 104px)`; section h2 to 56px; card titles to 60px.

## Components

- **Nav** — sticky, blurred translucent navy bar; stacked BLEEK/VISION wordmark logo; links collapse behind an animated hamburger under 769px (max-width transition).
- **Hero** — centered, **headline-led**: a small muted `BLEEK / VISION` signature (the letter-by-letter wordmark reveal retained at signature scale, ~`clamp(20px, 2.4vw, 28px)`, periwinkle VISION still pulsing) sits above the fade-up h1 with periwinkle accent span, which is the focal point. Sub, two pill buttons (`.btn--solid` silver, `.btn--ghost` outline), bouncing scroll cue, masked grid + aurora background.
- **Product card** (`.card`) — large rounded 24px panel, 2-col grid (copy | device mount), alternating `--img-left` (which also breathe at a slightly shorter 580px min-height vs the 620px base, for rhythm), drenched in the product's world color; status chip with pulsing dot, title, subtitle, description (`text-wrap: pretty`, not justified), mono meta line, pill CTA (solid or ghost for unreleased; `min-height: 44px` touch target). Faint accent dot-grid texture + radial glow behind the device frame. **Reveal:** cards fade + rise in on scroll, staggered, via `IntersectionObserver` — JS-gated (`html.js`) so no-JS users always see them, and forced fully visible under reduced motion. **Hover:** the device frame lifts (`translateY(-6px) scale(1.012)`) and the glow blooms (`opacity 1, scale(1.08)`) on `--ease-out`. Collapses to single column ≤920px (copy above image).
- **Status dots** — pulsing green `--live`, solid accent "work", muted "in development".
- **Founder** — 2-col (portrait | prose) with periwinkle glow, masked portrait, italic serif signature.
- **Footer** — 4-col link grid (wordmark / The Work / Studio / Legal), hairline rules, mono column heads, copyright bar.
- **Legal pages** — shared `.legal-*` system (header, narrow prose body ≤760px, app tags, labeled dividers).

## Layout

- Container `--max-width: 1180px`, 32px side padding (24px ≤560px).
- Generous vertical rhythm: hero ~140–150px, work/founder ~120–140px section padding.
- Breakpoints: `769px` (nav), `920px` (cards/founder/footer to fewer columns), `560px` (phone padding + single-column footer).
- Pill radius `980px` for all buttons/chips; card radius 24px; device frame 28px.

## Motion

- Entrance: `v5-fadeup` (opacity + 14px rise, ease `cubic-bezier(.2,.7,.2,1)`) with staggered delays d1–d4; letter-by-letter wordmark reveal with blur.
- Ambient: three blurred aurora blobs drifting on 26–34s loops; pulsing live dot + expanding ring; founder glow drift; hero scroll-cue bounce.
- Hover: `translateY(-1px)` on CTAs, `-2px` lift on cards, plus device-frame lift + glow bloom on card hover.
- Press: `scale(0.97)` on `:active` for pressables (`.cta`).
- Custom easing tokens: `--ease-out: cubic-bezier(0.23, 1, 0.32, 1)` and `--ease-drawer: cubic-bezier(0.32, 0.72, 0, 1)` — used for reveals, card hover, and press feedback.
- **Reduced motion:** global rule collapses all animation/transition durations to ~0 under `prefers-reduced-motion: reduce`; card reveals are additionally forced fully visible.

## Accessibility notes

- `:focus-visible` rings (2px periwinkle, 3px offset) on all interactive elements.
- Resolved (elevation pass, 2026-05-31): MomKnows (~5.78:1) and FOCUS//DECK (~5.65:1) muted body text verified ≥ 4.5:1; founder portrait carries explicit `760×1007` dimensions + `decoding="async"` (no CLS); card CTAs are ≥ 44px touch targets; closed mobile nav links carry `visibility: hidden` (out of the keyboard tab order); body text uses `text-wrap: pretty`, never justified.
- Watch: `--mute` (`#7A8493`) body text on navy for AA on smaller/secondary text.
