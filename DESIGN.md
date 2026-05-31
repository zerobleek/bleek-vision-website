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
- **FOCUS//DECK** — near-black `#0A0907`, gold text/accent `#E8C772`/`#F2D27A` (mono title).
- **UNCONTAINED** — black-brown `#0B0805`, hot orange `#FF7A1A`, white text.
- **MomKnows!** — warm light world `#F5EDE3` bg, terracotta `#C5532A`, dark ink `#2A1A12`. (The one light card — contrast watch.)
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
- **Hero** — centered; animated wordmark, fade-up h1 with periwinkle accent span, sub, two pill buttons (`.btn--solid` silver, `.btn--ghost` outline), bouncing scroll cue, masked grid + aurora background.
- **Product card** (`.card`) — large rounded 24px panel, 2-col grid (copy | device mount), alternating `--img-left`, drenched in the product's world color; status chip with pulsing dot, title, subtitle, justified description, mono meta line, pill CTA (solid or ghost for unreleased). Faint accent dot-grid texture + radial glow behind the device frame. Collapses to single column ≤920px (copy above image).
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
- Hover: `translateY(-1px)` on CTAs, `-2px` lift on cards.
- **Reduced motion:** global rule collapses all animation/transition durations to ~0 under `prefers-reduced-motion: reduce`.

## Accessibility notes

- `:focus-visible` rings (2px periwinkle, 3px offset) on all interactive elements.
- Watch: `--mute` (`#7A8493`) body text on navy and muted text inside the light MomKnows world for AA 4.5:1; justified body text can open large word gaps. Flagged for the audit.
