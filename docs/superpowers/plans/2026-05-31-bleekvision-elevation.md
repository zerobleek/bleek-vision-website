<!--
  2026-05-31-bleekvision-elevation.md
  Bleek Vision Website
  Created by Shabaka Malik Banks on 5/31/26.
  Copyright © 2026 Bleek Vision LLC. All rights reserved.
-->

# Bleek Vision — Elevation Pass Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refine the live `bleekvision.com` (static HTML/CSS) — hero hierarchy, card scroll reveals + hover, motion polish, and the outstanding impeccable P1/P2 accessibility fixes — without changing structure, copy, or brand.

**Architecture:** Two-file static site (`index.html` + `styles.css`), no build step, no framework. All changes are CSS plus ~15 lines of vanilla JS (an `IntersectionObserver` for card reveals). Work happens on branch `elevation-pass-2026-05`; `main` is frozen (it auto-deploys to Cloudflare Pages), so merge is user-gated.

**Tech Stack:** HTML5, CSS3 (custom properties, `clamp()`, transitions, `@media (prefers-reduced-motion)`), vanilla JS (`IntersectionObserver`). Local preview: `python3 -m http.server 4317`.

---

## Verification model (read first)

This is a static site with **no test framework**. The standard TDD red/green loop does not apply. Instead, every task pairs an exact edit with an **explicit observational check** done before committing:

- **Contrast:** computed with the Python snippet in Task 6 (must print ratio ≥ 4.5).
- **Keyboard:** Tab through the served page; note what is/ isn't focusable.
- **Reduced motion:** DevTools → Rendering → "Emulate CSS prefers-reduced-motion: reduce" (or macOS System Settings → Accessibility → Display → Reduce motion).
- **Visual:** load `http://localhost:4317` and check at three widths — narrow ≤560px, ~768px, wide ≥1180px (DevTools device toolbar).

Keep one terminal running the preview server for the whole session:

```bash
cd /Users/malikbanks/bleek-vision-website && python3 -m http.server 4317
```

All `git` commands assume CWD `/Users/malikbanks/bleek-vision-website` and branch `elevation-pass-2026-05`.

---

## File structure

| File | Responsibility | This plan |
|---|---|---|
| `styles.css` | All styling + tokens + motion + responsive | Modified (Tasks 1–6, 7) |
| `index.html` | Markup + nav-toggle JS | Modified: add reveal JS + `.js` class + founder img dims (Tasks 4, 7) |
| `DESIGN.md` | Visual system capture | Updated to match (Task 8) |

No new files. No dependencies. `privacy.html` / `terms.html` untouched.

---

### Task 1: Add custom easing tokens

**Files:**
- Modify: `styles.css` (`:root`, around lines 10–31)

- [ ] **Step 1: Add easing tokens to `:root`**

In `styles.css`, find the `:root` block. After the `--accent`-family lines and before `--live` (or anywhere inside `:root`), add the two easing variables. Locate this existing line:

```css
  --live: #7EC8A0;
```

Insert immediately **after** it (still inside `:root`):

```css

  /* Custom easing — stronger than built-in CSS curves */
  --ease-out: cubic-bezier(0.23, 1, 0.32, 1);
  --ease-drawer: cubic-bezier(0.32, 0.72, 0, 1);
```

- [ ] **Step 2: Verify it parses**

Run: `python3 -m http.server 4317` is already running — reload `http://localhost:4317`. Expected: page looks identical (tokens are unused so far), no console errors. Confirm the file has no stray brace by viewing the `:root` block.

- [ ] **Step 3: Commit**

```bash
git add styles.css
git commit -m "Add custom easing tokens (--ease-out, --ease-drawer)"
```

---

### Task 2: Press feedback — scale(0.97) on pressables (Move 3)

**Files:**
- Modify: `styles.css` (`.cta` block ~lines 109–112; `.card__cta` ~lines 434–445)

The site has a shared `.cta` class on buttons/links (`transition: ... transform .2s;` then `.cta:hover { transform: translateY(-1px); }`). We add an `:active` compress using the new easing.

- [ ] **Step 1: Add `:active` press to `.cta`**

Find this existing block:

```css
.cta {
  transition: background .25s, color .25s, border-color .25s, transform .2s;
}
.cta:hover { transform: translateY(-1px); }
```

Replace it with (adds the active state + retunes the transform timing to `--ease-out`):

```css
.cta {
  transition: background .25s, color .25s, border-color .25s, transform .16s var(--ease-out);
}
.cta:hover { transform: translateY(-1px); }
.cta:active { transform: scale(0.97); }
```

- [ ] **Step 2: Ensure `.card__cta` also presses**

The card CTAs already carry the `cta` class in the markup, so Step 1 covers them. Confirm in `index.html` that every `card__cta` element also has `cta` (grep below). If any lacks it, that is handled by the shared rule once present.

Run: `grep -nE 'card__cta' index.html`
Expected: each `card__cta` line also contains `cta` (it does in the current markup).

- [ ] **Step 3: Verify visually**

Reload `http://localhost:4317`. Press-and-hold the "See the work" hero button and a card "View on App Store" link. Expected: each visibly compresses to ~97% while held, springs back on release. No layout shift (only `transform` animates).

- [ ] **Step 4: Commit**

```bash
git add styles.css
git commit -m "Add scale(0.97) :active press feedback to pressables"
```

---

### Task 3: Hero hierarchy — sentence leads (Move 1A)

**Files:**
- Modify: `styles.css` — `.hero__wordmark` (~216–218), `.hero__wm-bleek` (~219–228), `.hero__wm-vision` (~239–251), `.hero__sub` (~287–295)

Demote the animated wordmark from a 148px hero element to a small brand signature; the `h1` (unchanged at `clamp(52px,7.2vw,104px)`) becomes the sole focal point. The letter-by-letter reveal stays, just smaller.

- [ ] **Step 1: Shrink `.hero__wordmark` margin**

Find:

```css
.hero__wordmark {
  margin-bottom: 40px;
}
```

Replace with:

```css
.hero__wordmark {
  margin-bottom: 22px;
}
```

- [ ] **Step 2: Shrink the BLEEK wordmark**

Find:

```css
.hero__wm-bleek {
  font-family: 'Outfit', var(--font);
  font-weight: 800;
  font-size: clamp(72px, 10vw, 148px);
  color: var(--silver);
  letter-spacing: 0.1em;
  line-height: 1;
  display: flex;
  justify-content: center;
}
```

Replace the `font-size` line only:

```css
  font-size: clamp(20px, 2.4vw, 28px);
```

(so the block becomes the same with `font-size: clamp(20px, 2.4vw, 28px);`). Also change `color: var(--silver);` to `color: var(--mute);` so the mark reads as a quiet signature rather than competing with the headline. The block is now:

```css
.hero__wm-bleek {
  font-family: 'Outfit', var(--font);
  font-weight: 800;
  font-size: clamp(20px, 2.4vw, 28px);
  color: var(--mute);
  letter-spacing: 0.1em;
  line-height: 1;
  display: flex;
  justify-content: center;
}
```

- [ ] **Step 3: Shrink the VISION sub-label**

Find:

```css
.hero__wm-vision {
  font-family: 'Outfit', var(--font);
  font-weight: 300;
  font-size: clamp(16px, 2.2vw, 34px);
  color: var(--accent);
  letter-spacing: 0.52em;
  text-indent: 0.52em; /* offset trailing letter-spacing so it appears visually centred */
  text-align: center;
  margin-top: 8px;
  animation:
    wm-vision-in 0.9s cubic-bezier(.2,.7,.2,1) 0.38s both,
    wm-vision-pulse 3.5s ease-in-out 1.4s infinite;
}
```

Replace the `font-size` and `margin-top` lines:

```css
  font-size: clamp(8px, 1vw, 10px);
```
```css
  margin-top: 4px;
```

(Keep the periwinkle color, the tracking, and both animations — that is what preserves the "signature" feel.)

- [ ] **Step 4: Verify hero hierarchy at three widths**

Reload `http://localhost:4317`. At ≤560px, ~768px, ≥1180px confirm: the headline ("An independent development studio with **a point of view.**") is unmistakably the largest, first thing the eye lands on; "BLEEK / VISION" reads as a small muted signature above it with the periwinkle VISION still tracking/pulsing; the letter-reveal still plays on load. No overlap or awkward gap between mark and headline.

- [ ] **Step 5: Verify reduced-motion still quiets the hero**

DevTools → Rendering → Emulate `prefers-reduced-motion: reduce`. Reload. Expected: wordmark + headline appear instantly, no letter animation, no pulse.

- [ ] **Step 6: Commit**

```bash
git add styles.css
git commit -m "Hero 1A: demote wordmark to signature, headline leads"
```

---

### Task 4: Card scroll reveals (Move 2 — entrance)

**Files:**
- Modify: `index.html` — add `.js` class bootstrap + `IntersectionObserver` (script block ~lines 318–337)
- Modify: `styles.css` — reveal start/end states; reduced-motion guard (~lines 74–80)

Cards (`.card`, five of them) fade + rise in on scroll, staggered. The hidden start-state is **only** applied when JS is active (`html.js`), so no-JS users always see cards; reduced-motion users see them instantly.

- [ ] **Step 1: Bootstrap a `.js` flag as early as possible**

In `index.html`, find the opening `<body>`:

```html
<body>
<div class="shell">
```

Insert a tiny inline script immediately after `<body>` (before `.shell`) so the flag is set before paint:

```html
<body>
<script>document.documentElement.classList.add('js');</script>
<div class="shell">
```

- [ ] **Step 2: Add reveal CSS (gated on `.js`)**

In `styles.css`, at the end of the `WORK / SLATE` section — directly after the `.slate { ... }` rule (~line 351) — add:

```css

/* Move 2 — card scroll reveal (JS-gated so no-JS users always see cards) */
.js .card {
  opacity: 0;
  transform: translateY(20px);
  transition: opacity .7s var(--ease-out), transform .7s var(--ease-out);
  will-change: opacity, transform;
}
.js .card.is-in {
  opacity: 1;
  transform: none;
}
```

- [ ] **Step 3: Make reduced-motion show cards instantly**

Find the existing reduced-motion block:

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: .001ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: .001ms !important;
  }
}
```

Add a rule inside it (before the closing `}`):

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: .001ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: .001ms !important;
  }
  .js .card { opacity: 1 !important; transform: none !important; }
}
```

- [ ] **Step 4: Add the IntersectionObserver**

In `index.html`, find the closing of the existing nav-toggle IIFE and the `</script>` after it (~line 337):

```html
    });
  })();
</script>
```

Replace with (keeps the existing IIFE intact; appends the observer):

```html
    });
  })();

  // Move 2 — reveal cards on scroll, staggered. Reduced-motion users get them
  // immediately (CSS forces .is-in styling regardless), so we still add the class.
  (function () {
    var cards = document.querySelectorAll('.card');
    if (!('IntersectionObserver' in window)) {
      cards.forEach(function (c) { c.classList.add('is-in'); });
      return;
    }
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (!entry.isIntersecting) return;
        var el = entry.target;
        var i = Array.prototype.indexOf.call(cards, el);
        el.style.transitionDelay = (Math.min(i, 4) * 90) + 'ms';
        el.classList.add('is-in');
        io.unobserve(el);
      });
    }, { threshold: 0.18, rootMargin: '0px 0px -8% 0px' });
    cards.forEach(function (c) { io.observe(c); });
  })();
</script>
```

- [ ] **Step 5: Verify reveal on scroll**

Reload `http://localhost:4317` and scroll slowly from the hero down through the work section. Expected: each card fades up (opacity 0→1, 20px rise) as it enters, with a slight stagger; once revealed it stays. Scroll back up and down — no flicker (cards are unobserved after first reveal).

- [ ] **Step 6: Verify no-JS + reduced-motion fallbacks**

DevTools → Rendering → Emulate `prefers-reduced-motion: reduce`, reload: all cards visible immediately, no movement. Then DevTools → Settings → Debugger → "Disable JavaScript", reload: all cards visible (no `.js` class → no hidden start-state). Re-enable JS and reduced-motion after.

- [ ] **Step 7: Commit**

```bash
git add index.html styles.css
git commit -m "Move 2: staggered scroll reveal for product cards (JS + a11y guards)"
```

---

### Task 5: Card hover refinement + rhythm (Move 2 — interaction)

**Files:**
- Modify: `styles.css` — `.card:hover` (~line 368), `.card__frame` (~462–470), `.card__glow` (~453–461)

Today hover is a flat `translateY(-2px)` on the whole card. Refine so the **device frame lifts** and the **glow blooms**, using `--ease-out`. Add light rhythm variation.

- [ ] **Step 1: Add transition to the frame and glow**

Find:

```css
.card__glow {
  position: absolute;
  width: 360px;
  height: 480px;
  border-radius: 50%;
  background: radial-gradient(ellipse, color-mix(in srgb, var(--w-accent) 15%, transparent), transparent 70%);
  filter: blur(60px);
  pointer-events: none;
}
```

Add a transition + a hover-target opacity baseline by replacing it with:

```css
.card__glow {
  position: absolute;
  width: 360px;
  height: 480px;
  border-radius: 50%;
  background: radial-gradient(ellipse, color-mix(in srgb, var(--w-accent) 15%, transparent), transparent 70%);
  filter: blur(60px);
  pointer-events: none;
  opacity: 0.8;
  transition: opacity .4s var(--ease-out), transform .4s var(--ease-out);
}
```

Find:

```css
.card__frame {
  position: relative;
  height: 560px;
  border-radius: 28px;
  background: var(--w-mount);
  padding: 10px;
  box-shadow: 0 30px 60px -20px rgba(0, 0, 0, 0.55), 0 0 0 1px rgba(255, 255, 255, 0.06);
  display: inline-block;
}
```

Add a transition line (before the closing `}`):

```css
  transition: transform .4s var(--ease-out), box-shadow .4s var(--ease-out);
```

- [ ] **Step 2: Refine the hover rule**

Find:

```css
.card:hover { transform: translateY(-2px); }
```

Replace with:

```css
.card:hover { transform: translateY(-2px); }
.card:hover .card__frame {
  transform: translateY(-6px) scale(1.012);
  box-shadow: 0 44px 80px -28px rgba(0, 0, 0, 0.6), 0 0 0 1px rgba(255, 255, 255, 0.08);
}
.card:hover .card__glow { opacity: 1; transform: scale(1.08); }
```

- [ ] **Step 3: Add light rhythm variation**

To break the uniform 620px cadence, give the two `--img-left` cards (FOCUS//DECK, MomKnows) a slightly different min-height. After the `.card--img-left { ... }` rule (~line 369), add:

```css

/* Move 2 — subtle rhythm: alternating cards breathe a little differently */
.card--img-left { min-height: 580px; }
```

(The base `.card` keeps `min-height: 620px`; this only nudges the alternates. No structural/grid change.)

- [ ] **Step 4: Verify hover + rhythm**

Reload `http://localhost:4317`. Hover each card. Expected: the device frame lifts ~6px and scales almost imperceptibly while its glow brightens and expands; motion is smooth (only `transform`/`opacity`/`box-shadow`). The five cards no longer feel mechanically identical in height. On touch (DevTools device mode) there is no stuck hover state.

- [ ] **Step 5: Verify reduced-motion**

Emulate `prefers-reduced-motion: reduce`, reload, hover: the global rule zeroes durations, so the frame/glow change is instant, not animated. Acceptable.

- [ ] **Step 6: Commit**

```bash
git add styles.css
git commit -m "Move 2: refine card hover (frame lift + glow bloom) and rhythm"
```

---

### Task 6: Contrast fixes — MomKnows + FOCUS//DECK (Move 4, P1)

**Files:**
- Modify: `styles.css` — `.card--focusdeck` (~484–487), `.card--momknows` (~492–495)

Both worlds' `--w-muted` body text fails WCAG AA. Raise each until the computed ratio is ≥ 4.5 (target ≥ 4.6 for margin). Use the helper below to measure — do not eyeball.

- [ ] **Step 1: Save the contrast helper**

Create a throwaway file `/tmp/contrast.py`:

```python
def _lin(c):
    c = c / 255.0
    return c / 12.92 if c <= 0.03928 else ((c + 0.055) / 1.055) ** 2.4

def lum(r, g, b):
    return 0.2126 * _lin(r) + 0.7152 * _lin(g) + 0.0722 * _lin(b)

def over(fg, bg, a):
    return tuple(round(fg[i] * a + bg[i] * (1 - a)) for i in range(3))

def ratio(fg, bg):
    L1, L2 = sorted([lum(*fg), lum(*bg)], reverse=True)
    return (L1 + 0.05) / (L2 + 0.05)

# MomKnows: ink #2A1A12 over cream #F5EDE3
ink, cream = (42, 26, 18), (245, 237, 227)
for a in (0.70, 0.78, 0.82, 0.86, 0.90):
    print("MomKnows alpha", a, "->", round(ratio(over(ink, cream, a), cream), 2))

# FOCUS//DECK: gold #E8C772 over near-black #0A0907
gold, black = (232, 199, 114), (10, 9, 7)
for a in (0.66, 0.74, 0.80, 0.86, 0.92):
    print("FOCUS//DECK alpha", a, "->", round(ratio(over(gold, black, a), black), 2))
```

- [ ] **Step 2: Run the helper and pick the lowest passing alpha**

Run: `python3 /tmp/contrast.py`
Expected: a table of ratios. Choose, for each world, the **lowest alpha whose ratio ≥ 4.6**. (Higher alpha = more opaque text = higher contrast in both worlds, since MomKnows text is dark-on-light and FOCUS//DECK text is light-on-dark.) Record the two chosen alphas.

- [ ] **Step 3: Apply MomKnows fix**

Find:

```css
.card--momknows {
  --w-bg: #F5EDE3; --w-surface: #FFF8EF; --w-text: #2A1A12; --w-muted: rgba(42,26,18,0.7);
  --w-accent: #C5532A; --w-accent-deep: #7A2E14; --w-mount: #E8DDD0; --w-cta-bg: #C5532A; --w-cta-text: #FFFFFF;
}
```

Change the `--w-muted` alpha to the value chosen in Step 2 (example shown with `0.82` — use your measured value):

```css
  --w-bg: #F5EDE3; --w-surface: #FFF8EF; --w-text: #2A1A12; --w-muted: rgba(42,26,18,0.82);
```

- [ ] **Step 4: Apply FOCUS//DECK fix**

Find:

```css
.card--focusdeck {
  --w-bg: #0A0907; --w-surface: #15120C; --w-text: #E8C772; --w-muted: rgba(232,199,114,0.66);
  --w-accent: #F2D27A; --w-accent-deep: #A88A3E; --w-mount: #050402; --w-cta-bg: #E8C772; --w-cta-text: #0A0907;
}
```

Change the `--w-muted` alpha to the value chosen in Step 2 (example shown with `0.80` — use your measured value):

```css
  --w-bg: #0A0907; --w-surface: #15120C; --w-text: #E8C772; --w-muted: rgba(232,199,114,0.80);
```

- [ ] **Step 5: Re-verify the final ratios**

Edit `/tmp/contrast.py` if needed so the printed alphas include your two chosen values, then run `python3 /tmp/contrast.py` again. Expected: both chosen rows print ≥ 4.6. Record both final numbers (they go in the commit message and DESIGN.md).

- [ ] **Step 6: Visual sanity**

Reload `http://localhost:4317`. The MomKnows card description and the FOCUS//DECK card description/meta should read clearly without looking heavy or breaking each world's mood.

- [ ] **Step 7: Commit**

```bash
git add styles.css
git commit -m "a11y(P1): raise MomKnows + FOCUS//DECK muted text to WCAG AA (>=4.6:1)"
```

---

### Task 7: Remaining a11y items — nav focus, touch targets, founder CLS, justified text (Move 4, P1/P2)

**Files:**
- Modify: `index.html` — founder portrait `<img>` (~line 264)
- Modify: `styles.css` — `.card__cta` min size if needed (~434–445)
- Verify only: nav focus, justified text

- [ ] **Step 1: Verify closed mobile nav links are not focusable (P1)**

Reload `http://localhost:4317`, shrink to ≤768px so the hamburger shows (menu closed). Tab from the top. Expected: focus goes logo → hamburger toggle → skips straight into hero/page content; the three nav links (`The Work`, `About`, `Contact`) are **never** focused while the menu is closed. (CSS already sets `visibility:hidden` on closed `.nav__links` — confirm it holds.) If a link does receive focus, report it; the fix is to confirm `.nav__links { visibility: hidden; }` is present in the closed state and not overridden. Open the menu (click hamburger) and Tab again: links should now be focusable in order.

- [ ] **Step 2: Add founder portrait dimensions (P2 — CLS)**

The five product images already have `width`/`height`; the founder portrait does not. Find in `index.html`:

```html
          <picture>
            <source srcset="assets/founder-portrait.webp" type="image/webp" />
            <img src="assets/founder-portrait.png" alt="Shabaka Malik Banks, founder and CEO of Bleek Vision" loading="lazy" />
          </picture>
```

Determine the intrinsic pixel size of the asset:

Run: `cd /Users/malikbanks/bleek-vision-website && python3 -c "import struct,sys
p='assets/founder-portrait.png'
d=open(p,'rb').read(33)
w,h=struct.unpack('>II', d[16:24])
print(w,h)"`
Expected: prints two integers, e.g. `1024 1280`. Use those exact values below.

Replace the `<img>` line, substituting the printed width/height (example uses `1024`×`1280`):

```html
            <img src="assets/founder-portrait.png" alt="Shabaka Malik Banks, founder and CEO of Bleek Vision" width="1024" height="1280" loading="lazy" decoding="async" />
```

(`.founder__portrait img { width:100%; height:auto; }` already governs rendered size, so the attributes only reserve aspect-ratio space and prevent shift.)

- [ ] **Step 3: Verify touch targets ≥ 44px (P2)**

Reload at mobile width, DevTools → inspect each interactive element's box: hamburger toggle (already `width:44px; min-height:44px` — confirm), hero buttons `.btn` (padding `14px 28px` → height ≈ 46px, OK), card CTAs `.card__cta` (padding `13px 24px` → height ≈ 44px, confirm ≥ 44). If `.card__cta` measures < 44px tall, find:

```css
.card__cta {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 13px 24px;
  border-radius: 980px;
  background: var(--w-cta-bg);
  color: var(--w-cta-text);
  font-size: 14.5px;
  font-weight: 600;
  text-decoration: none;
}
```

and add before the closing `}`:

```css
  min-height: 44px;
```

If it already measures ≥ 44px, make no change and note it.

- [ ] **Step 4: Verify no justified body text (P2)**

Run: `grep -nE 'text-align:\s*justify' styles.css index.html`
Expected: no matches (body copy uses `text-wrap: pretty`, not `justify`). If any match exists, change that `justify` to `left`. Report the result either way.

- [ ] **Step 5: Commit**

```bash
git add index.html styles.css
git commit -m "a11y(P1/P2): verify nav focus + touch targets, fix founder-image CLS, confirm no justified text"
```

---

### Task 8: Update DESIGN.md to match

**Files:**
- Modify: `DESIGN.md`

Keep the design capture truthful to the shipped code.

- [ ] **Step 1: Update the relevant sections**

In `DESIGN.md`, make these edits:

1. **Color table** — update the MomKnows and FOCUS//DECK `--w-muted` descriptions to the new values/ratios chosen in Task 6 (cite the measured ≥4.6:1).
2. **Components → Hero** — change the description from a large animated wordmark hero to: "small muted BLEEK / VISION signature above a headline-led hero; the `h1` is the focal point; letter-reveal retained at signature scale."
3. **Components → Product card** — add that cards reveal on scroll (staggered, JS-gated, reduced-motion-safe) and that hover lifts the device frame and blooms the glow.
4. **Motion** — add the `--ease-out` / `--ease-drawer` tokens and the `scale(0.97)` press feedback.
5. **Accessibility notes** — change the "Watch:" line to record that the muted-contrast items are now resolved (≥4.6:1) and founder image has explicit dimensions.

- [ ] **Step 2: Commit**

```bash
git add DESIGN.md
git commit -m "docs: update DESIGN.md to match elevation pass"
```

---

### Task 9: Final verification + re-audit + merge handoff

**Files:** none (verification + reporting)

- [ ] **Step 1: Full visual pass**

With `http://localhost:4317` open, walk the whole page at ≤560px, ~768px, ≥1180px. Confirm: hero headline leads with quiet signature; cards reveal on scroll and lift on hover; MomKnows + FOCUS//DECK text reads clearly; nothing else regressed (aurora, founder, footer intact).

- [ ] **Step 2: Reduced-motion + keyboard pass**

Emulate `prefers-reduced-motion: reduce`: hero static, cards instantly visible, no hover animation. Reset. Then keyboard-only: Tab through entire page; visible focus rings everywhere; closed mobile nav links unreachable.

- [ ] **Step 3: Re-run the impeccable audit**

Re-run the project's impeccable audit against the branch. Expected: score ≥ 18/20; the three P1 items resolved. Record the new score and any remaining items.

- [ ] **Step 4: Review the full diff**

Run: `git log --oneline main..elevation-pass-2026-05` and `git diff main..elevation-pass-2026-05 -- index.html styles.css`
Expected: only the intended Move 1A/2/3/4 changes; no copy, structure, or brand-rule changes; no location/DUNS/EIN introduced.

- [ ] **Step 5: Hand off for merge (do NOT merge unprompted)**

Report the audit score and diff summary to the user. **Merging `elevation-pass-2026-05` → `main` triggers the live Cloudflare Pages deploy**, so wait for explicit user approval. On approval:

```bash
git checkout main
git merge --no-ff elevation-pass-2026-05 -m "Elevation pass: hero 1A, card reveals/hover, motion polish, a11y fixes"
git push origin main
```

Then confirm the deploy and (optionally) verify the live URL.

---

## Self-review (completed by plan author)

**Spec coverage:**
- Move 1A (hero) → Task 3 ✓
- Move 2 (reveals + hover + rhythm) → Tasks 4, 5 ✓
- Move 3 (easing tokens + press feedback) → Tasks 1, 2 ✓
- Move 4 P1 contrast → Task 6 ✓; P1 nav focus → Task 7 Step 1 ✓; P2 touch targets → Task 7 Step 3 ✓; P2 CLS → Task 7 Step 2 ✓; P2 justified text → Task 7 Step 4 ✓
- DESIGN.md update → Task 8 ✓
- Verification plan + re-audit + user-gated deploy → Task 9 ✓

**Placeholder scan:** No TBD/TODO/"handle edge cases"; contrast values are measured via a provided script with example fallbacks; founder image dimensions are read from the asset at execution.

**Type/name consistency:** `.js` flag, `.card.is-in`, `--ease-out`, `--ease-drawer`, `--w-muted` used consistently across tasks; class/token names match the existing codebase exactly.
