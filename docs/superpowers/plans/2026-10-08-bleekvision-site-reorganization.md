# bleekvision.com Site Reorganization — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reorganize bleekvision.com into Apps and Games sections with a stats bar, technologies badge row, updated hero copy, and live EstoppelBot.com link.

**Architecture:** Pure HTML/CSS edits — no build step, no framework. Two files change: `index.html` (structure + content) and `styles.css` (new component styles appended). Dev server is `python3 -m http.server 4317` from the project root.

**Tech Stack:** Vanilla HTML5, CSS custom properties, no JS for new components.

---

## File Map

| File | What changes |
|------|-------------|
| `index.html` | Hero H1 + subhead, hero CTA href, nav links, stats bar HTML, work section split into #apps + #games, section labels, card reorder + alternation fixes, EstoppelBot card href + badge + class, technologies section HTML, footer EstoppelBot link |
| `styles.css` | `.stats`, `.section-label`, `.built-with` component styles appended |

---

## Task 1: Hero copy + CTA

**Files:**
- Modify: `index.html:150-154`

- [ ] **Step 1: Update H1, subhead, and CTA href**

Replace lines 150–154:

```html
      <h1 class="v5-fadeup v5-d2">An independent studio building apps, games, and tools.</h1>
      <p class="hero__sub v5-fadeup v5-d3">One developer. The best AI tools. Shipping across iOS and web.</p>
      <div class="hero__actions v5-fadeup v5-d4">
        <a href="#apps" class="btn btn--solid cta">See the work</a>
        <a href="#about" class="btn btn--ghost cta">About →</a>
      </div>
```

- [ ] **Step 2: Verify**

Start dev server if not running: `python3 -m http.server 4317 --directory /Users/malikbanks/bleek-vision-website`

Open `http://localhost:4317`. Confirm:
- H1 reads "An independent studio building apps, games, and tools."
- Subhead reads "One developer. The best AI tools. Shipping across iOS and web."
- "See the work" button scrolls to the Apps section (once that section exists with `id="apps"` — for now it will 404-scroll, which is expected).

- [ ] **Step 3: Commit**

```bash
git add index.html
git commit -m "Update hero copy and CTA for investor/Anthropic positioning"
```

---

## Task 2: Nav links

**Files:**
- Modify: `index.html:122-126`

- [ ] **Step 1: Update nav**

Replace lines 122–126:

```html
      <div class="nav__links" id="navLinks">
          <a href="#apps">Apps</a>
          <a href="#games">Games</a>
          <a href="#about">About</a>
          <a href="mailto:malik@bleekvision.com">Contact</a>
        </div>
```

- [ ] **Step 2: Verify**

Reload `http://localhost:4317`. Confirm nav shows "Apps · Games · About · Contact". Open hamburger at mobile width — all four links present.

- [ ] **Step 3: Commit**

```bash
git add index.html
git commit -m "Split nav into Apps and Games anchors"
```

---

## Task 3: Stats bar HTML

**Files:**
- Modify: `index.html` — insert after line 162 (closing `</section>` of hero)

- [ ] **Step 1: Insert stats bar between hero and work section**

After `</section>` on line 162 (end of hero), insert:

```html
  <!-- ──────────  STATS BAR  ────────── -->
  <section class="stats" aria-label="Studio at a glance">
    <div class="stats__inner wrap">
      <div class="stats__item">
        <span class="stats__num">4</span>
        <span class="stats__label">iOS apps live on the App Store</span>
      </div>
      <div class="stats__item">
        <span class="stats__num">1</span>
        <span class="stats__label">Web platform live</span>
      </div>
      <div class="stats__item">
        <span class="stats__num">4</span>
        <span class="stats__label">Product categories</span>
      </div>
      <div class="stats__item">
        <span class="stats__num">1</span>
        <span class="stats__label">Developer</span>
      </div>
    </div>
  </section>
```

- [ ] **Step 2: Verify (unstyled)**

Reload `http://localhost:4317`. Stats bar HTML is present between hero and products — unstyled is fine, CSS comes in Task 4.

- [ ] **Step 3: Commit**

```bash
git add index.html
git commit -m "Add stats bar HTML (4 iOS apps, 1 web platform, 4 categories, 1 developer)"
```

---

## Task 4: Stats bar + section label CSS

**Files:**
- Modify: `styles.css` — append to end of file

- [ ] **Step 1: Append stats bar styles**

Add to the end of `styles.css`:

```css
/* ──────────────────────────  STATS BAR  ────────────────────────── */
.stats {
  padding: 40px 32px;
  border-bottom: 1px solid var(--rule);
}
.stats__inner {
  display: flex;
  gap: 0;
  align-items: flex-start;
}
.stats__item {
  display: flex;
  flex-direction: column;
  gap: 6px;
  flex: 1;
  padding: 0 32px;
  border-left: 1px solid var(--rule);
}
.stats__item:first-child {
  border-left: none;
  padding-left: 0;
}
.stats__num {
  font-size: 2rem;
  font-weight: 800;
  color: var(--accent);
  line-height: 1;
  letter-spacing: -0.03em;
}
.stats__label {
  font-size: 0.75rem;
  color: var(--mute);
  letter-spacing: 0.02em;
  line-height: 1.4;
}

/* ──────────────────────────  SECTION LABELS  ────────────────────────── */
.section-label {
  font-size: 0.6875rem;
  font-weight: 600;
  letter-spacing: 0.12em;
  color: var(--mute);
  text-transform: uppercase;
  margin-bottom: 40px;
}

@media (max-width: 560px) {
  .stats { padding: 32px 24px; }
  .stats__inner { flex-wrap: wrap; gap: 24px; }
  .stats__item {
    flex: 1 1 calc(50% - 12px);
    padding: 0;
    border-left: none;
  }
  .stats__item:nth-child(2),
  .stats__item:nth-child(4) {
    padding-left: 20px;
    border-left: 1px solid var(--rule);
  }
}
```

- [ ] **Step 2: Verify**

Reload `http://localhost:4317`. Confirm:
- Stats bar is a horizontal row of 4 items with muted dividers
- Numbers are in periwinkle (`#89A1C3`), labels in muted grey
- Resize to ≤560px — wraps to 2×2 grid

- [ ] **Step 3: Commit**

```bash
git add styles.css
git commit -m "Add stats bar and section label CSS"
```

---

## Task 5: Split work section into #apps and #games

This is the main structural task. Read carefully before editing — card positions and alternation classes both change.

**Current card order and classes:**
1. MadWeather — no `card--img-left` (image right) → **stays in Apps, position 1, image right** ✓
2. FOCUS//DECK — `card--img-left` (image left) → **stays in Apps, position 2, image left** ✓
3. UNCONTAINED — no `card--img-left` (image right) → **moves to Games, position 1, image right** ✓
4. MomKnows! — `card--img-left` (image left) → **stays in Apps, position 3, becomes image right** → remove `card--img-left`
5. Go Bobby Go — no `card--img-left` (image right) → **moves to Games, position 2, becomes image left** → add `card--img-left`
6. Cipher Protocol — `card--img-left` (image left) → **stays in Apps, position 5, becomes image right** → remove `card--img-left`
7. Estoppel Bot — no `card--img-left` (image right) → **stays in Apps, position 4, becomes image left** → add `card--img-left`

**Files:**
- Modify: `index.html:164-313`

- [ ] **Step 1: Replace the entire work section**

Find the comment `<!-- ──────────  WORK / THE SLATE  ────────── -->` (line 164) through the closing `</section>` (line 313) and replace the entire block with:

```html
  <!-- ──────────  APPS & TOOLS  ────────── -->
  <section class="work" id="apps">
    <div class="slate wrap" style="padding-left:0;padding-right:0;">
      <div class="section-label">APPS &amp; TOOLS</div>

      <!-- MadWeather · image right -->
      <article class="card card--madweather">
        <div class="card__copy">
          <div>
            <div class="card__status"><span class="dot dot--live"><span class="core"></span><span class="ring"></span></span>LIVE ON THE APP STORE</div>
            <h3 class="card__title">MadWeather</h3>
            <div class="card__subtitle">NYC Weather. Real Talk.</div>
            <p class="card__desc">A weather app that talks the way New York actually talks. Plain-language forecasts, borough personalities, and the small details a hometown forecast gets right.</p>
          </div>
          <div class="card__meta">iPhone &amp; iPad · Free with ads · Premium one-time IAP</div>
          <a class="card__cta cta" href="https://apps.apple.com/us/app/madweather/id6758524351" target="_blank" rel="noopener">View on App Store →</a>
        </div>
        <div class="card__mount">
          <div class="card__glow" aria-hidden="true"></div>
          <div class="card__frame"><img src="assets/products/madweather-today.png" alt="MadWeather NYC weather app — borough forecast screen showing plain-language conditions for New York" width="1284" height="2778" loading="lazy" decoding="async" /></div>
        </div>
      </article>

      <!-- FOCUS//DECK · image left -->
      <article class="card card--focusdeck card--mono card--img-left">
        <div class="card__mount">
          <div class="card__glow" aria-hidden="true"></div>
          <div class="card__frame"><img src="assets/products/focusdeck-cyberdeck.png" alt="FOCUS//DECK focus timer iPhone app — cyberdeck UI showing deep work sprint session" width="1320" height="2868" loading="lazy" decoding="async" /></div>
        </div>
        <div class="card__copy">
          <div>
            <div class="card__status"><span class="dot dot--live"><span class="core"></span><span class="ring"></span></span>LIVE ON THE APP STORE</div>
            <h3 class="card__title">FOCUS//DECK</h3>
            <div class="card__subtitle">A pocket cyberdeck for staying on task.</div>
            <p class="card__desc">Stop negotiating with yourself. Pomodoro, ADHD sprints, and deep work, fronted by a drill-sergeant mascot named BIT who won't let you bail mid-session.</p>
          </div>
          <div class="card__meta">iPhone · One-time Pro unlock · No subscriptions</div>
          <a class="card__cta cta" href="https://apps.apple.com/us/app/focus-deck-focus-timer/id6771453354" target="_blank" rel="noopener">View on App Store →</a>
        </div>
      </article>

      <!-- MomKnows! · image right (was left — alternation corrected) -->
      <article class="card card--momknows">
        <div class="card__copy">
          <div>
            <div class="card__status"><span class="dot dot--live"><span class="core"></span><span class="ring"></span></span>LIVE ON THE APP STORE</div>
            <h3 class="card__title">MomKnows!</h3>
            <div class="card__subtitle">The things only she knows.</div>
            <p class="card__desc">A private space for capturing what matters most: emergency information, family stories, the health details that need to be findable when it counts. Privacy-first. Yours forever.</p>
          </div>
          <div class="card__meta">iPhone &amp; iPad · One-time purchase · No subscription</div>
          <a class="card__cta cta" href="https://apps.apple.com/us/app/momknows/id6763380814" target="_blank" rel="noopener">View on App Store →</a>
        </div>
        <div class="card__mount">
          <div class="card__glow" aria-hidden="true"></div>
          <div class="card__frame"><img src="assets/products/momknows-crisis.png" alt="MomKnows! family emergency information app for iPhone — one-time purchase, no subscription" width="1284" height="2778" loading="lazy" decoding="async" /></div>
        </div>
      </article>

      <!-- Estoppel Bot · full-card link, image left (was right — alternation corrected) -->
      <a href="https://estoppelbot.com" class="card card--estoppelbot card--img-left" style="text-decoration:none;" target="_blank" rel="noopener">
        <div class="card__mount">
          <div class="card__glow" aria-hidden="true"></div>
          <div class="card__frame"><img src="assets/products/estoppel-bot-mascot.png" alt="Estoppel Bot — friendly robot paralegal holding an estoppel certificate binder" width="1024" height="1536" loading="lazy" decoding="async" /></div>
        </div>
        <div class="card__copy">
          <div>
            <div class="card__status"><span class="dot dot--live"><span class="core"></span><span class="ring"></span></span>LIVE ON THE WEB</div>
            <h3 class="card__title">Estoppel Bot</h3>
            <div class="card__subtitle">Your super paralegal.</div>
            <p class="card__desc">The estoppel certificate workbench for commercial real estate teams. Collect tenant estoppels, track every closing deadline, and generate the signed certificate — without the email scramble.</p>
          </div>
          <div class="card__meta">Web app · CRE legal ops · Free to start</div>
          <span class="card__cta card__cta--ghost cta">Visit EstoppelBot.com →</span>
        </div>
      </a>

      <!-- Cipher Protocol · full-card link, image right (was left — alternation corrected) -->
      <a href="cipher.html" class="card card--cipher" style="text-decoration:none;">
        <div class="card__copy">
          <div>
            <div class="card__status"><span class="dot dot--mute"><span class="core"></span></span>COMING SPRING 2027</div>
            <h3 class="card__title">Cipher Protocol</h3>
            <div class="card__subtitle">A running app told as a spy thriller.</div>
            <p class="card__desc">You get a briefing before each run. A debrief when you finish. The story moves when you do — a block builds mission by mission, starting free. No leaderboards. No pace gates. No agent left behind.</p>
          </div>
          <div class="card__meta">iPhone · Running app · Spring 2027 · First three missions free</div>
          <span class="card__cta card__cta--ghost cta">Join the waitlist →</span>
        </div>
        <div class="card__mount">
          <div class="card__glow" aria-hidden="true"></div>
          <div class="card__frame"><img src="assets/cipher/shot-missions.webp" alt="Cipher Protocol iOS running app — mission screen showing spy briefing before a run" width="414" height="900" loading="lazy" decoding="async" /></div>
        </div>
      </a>

    </div>
  </section>

  <!-- ──────────  GAMES  ────────── -->
  <section class="work" id="games">
    <div class="slate wrap" style="padding-left:0;padding-right:0;">
      <div class="section-label">GAMES</div>

      <!-- UNCONTAINED · image right -->
      <article class="card card--uncontained">
        <div class="card__copy">
          <div>
            <div class="card__status"><span class="dot dot--live"><span class="core"></span><span class="ring"></span></span>LIVE ON THE APP STORE</div>
            <h3 class="card__title">UNCONTAINED</h3>
            <div class="card__subtitle">The deeper you go.</div>
            <p class="card__desc">Nuclear fission puzzles. Seventy-two levels, nine atom types, chain reactions that don't forgive bad angles. Six chapters, from First Light to Vacuum Decay.</p>
          </div>
          <div class="card__meta">iPhone &amp; iPad · No ads · No timers · No tricks</div>
          <a class="card__cta cta" href="https://apps.apple.com/us/app/uncontained/id6761268905" target="_blank" rel="noopener">View on App Store →</a>
        </div>
        <div class="card__mount">
          <div class="card__glow" aria-hidden="true"></div>
          <div class="card__frame"><img src="assets/products/uncontained-dark-matter.png" alt="UNCONTAINED nuclear fission puzzle game for iPhone — Dark Matter chapter level" width="1242" height="2688" loading="lazy" decoding="async" /></div>
        </div>
      </article>

      <!-- Go, Bobby, Go! · image left (was right — alternation corrected) -->
      <article class="card card--gobobbygo card--img-left" id="gobobbygo">
        <div class="card__mount">
          <div class="card__glow" aria-hidden="true"></div>
          <div class="card__frame"><img src="assets/products/gobobbygo-city.png" alt="Go, Bobby, Go! Road Trip kids car ride game for iPhone — Bobby running along a city sidewalk collecting coins at dusk" width="990" height="2151" loading="lazy" decoding="async" /></div>
        </div>
        <div class="card__copy">
          <div>
            <div class="card__status"><span class="dot dot--work"><span class="core"></span></span>COMING TO THE APP STORE</div>
            <h3 class="card__title">Go, Bobby, Go! Road Trip</h3>
            <div class="card__subtitle">A car ride game for kids.</div>
            <p class="card__desc">Straight from the Go, Bobby, Go! picture books. Bobby runs beside the car at your real speed: stop at a light and he stops, hit the highway and he takes off. Tap to jump, grab the coins, and watch the city, the highway, and the rings of a planet roll by from the back seat.</p>
          </div>
          <div class="card__meta">iPhone &amp; iPad · Made for kids 6–8 · One-time purchase · No ads · No accounts</div>
          <span class="card__cta card__cta--ghost cta">Coming soon →</span>
        </div>
      </article>

    </div>
  </section>
```

- [ ] **Step 2: Verify**

Reload `http://localhost:4317`. Confirm:
- "APPS & TOOLS" label appears before MadWeather
- Card order in Apps: MadWeather → FOCUS//DECK → MomKnows! → Estoppel Bot → Cipher Protocol
- "GAMES" label appears before UNCONTAINED
- Card order in Games: UNCONTAINED → Go Bobby Go
- MomKnows! image is now on the **right**
- Estoppel Bot image is now on the **left**
- Cipher Protocol image is now on the **right**
- Go Bobby Go image is now on the **left**
- EstoppelBot card shows "LIVE ON THE WEB" with a green pulsing dot
- EstoppelBot card links to `https://estoppelbot.com` (check href in browser devtools)
- Nav "Apps" link scrolls to Apps section; "Games" link scrolls to Games section

- [ ] **Step 3: Commit**

```bash
git add index.html
git commit -m "Split work section into #apps and #games with section labels and corrected card alternation"
```

---

## Task 6: Technologies section HTML + CSS

**Files:**
- Modify: `index.html` — insert before `<section class="founder" id="about">`
- Modify: `styles.css` — append to end

- [ ] **Step 1: Insert technologies section in index.html**

Find `<section class="founder" id="about">` and insert immediately before it:

```html
  <!-- ──────────  BUILT WITH  ────────── -->
  <section class="built-with">
    <div class="built-with__inner wrap">
      <div class="built-with__label">BUILT WITH</div>
      <div class="built-with__tools">
        <span>Claude</span>
        <span>Cursor</span>
        <span>ChatGPT</span>
        <span>Higgsfield</span>
      </div>
    </div>
  </section>
```

- [ ] **Step 2: Append technologies section CSS to styles.css**

```css
/* ──────────────────────────  BUILT WITH  ────────────────────────── */
.built-with {
  padding: 64px 32px;
  border-top: 1px solid var(--rule);
}
.built-with__inner {
  display: flex;
  flex-direction: column;
  gap: 20px;
}
.built-with__label {
  font-size: 0.6875rem;
  font-weight: 600;
  letter-spacing: 0.12em;
  color: var(--mute);
  text-transform: uppercase;
}
.built-with__tools {
  display: flex;
  gap: 48px;
  flex-wrap: wrap;
  align-items: center;
}
.built-with__tools span {
  font-size: 0.875rem;
  font-weight: 500;
  color: var(--mute);
  letter-spacing: 0.02em;
}

@media (max-width: 560px) {
  .built-with { padding: 48px 24px; }
  .built-with__tools {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 20px 32px;
  }
}
```

- [ ] **Step 3: Verify**

Reload `http://localhost:4317`. Scroll between the Games section and the Founder section. Confirm:
- "BUILT WITH" label in muted all-caps
- Four tool names on one row: Claude · Cursor · ChatGPT · Higgsfield
- All in muted grey (not accent colour)
- Resize to ≤560px: tools wrap to 2×2 grid

- [ ] **Step 4: Commit**

```bash
git add index.html styles.css
git commit -m "Add Built With technologies section (Claude, Cursor, ChatGPT, Higgsfield)"
```

---

## Task 7: Footer EstoppelBot link

**Files:**
- Modify: `index.html:362`

- [ ] **Step 1: Update footer link**

Find line 362:
```html
          <a href="estoppelbot.html">Estoppel Bot</a>
```

Replace with:
```html
          <a href="https://estoppelbot.com" target="_blank" rel="noopener">Estoppel Bot</a>
```

- [ ] **Step 2: Verify**

Reload `http://localhost:4317`. Scroll to footer. Click "Estoppel Bot" — confirm it opens `estoppelbot.com` in a new tab.

- [ ] **Step 3: Commit and push**

```bash
git add index.html
git commit -m "Update footer EstoppelBot link to estoppelbot.com"
git push origin main
```

---

## Self-Review Checklist

| Spec requirement | Task that covers it |
|-----------------|-------------------|
| Hero H1 updated | Task 1 |
| Hero subhead updated | Task 1 |
| Hero CTA href → #apps | Task 1 |
| Nav: Apps · Games · About · Contact | Task 2 |
| Stats bar (4 items, between hero and apps) | Task 3 + 4 |
| Section labels (APPS & TOOLS / GAMES) | Task 5 |
| Apps section: MadWeather → FOCUS//DECK → MomKnows! → Estoppel Bot → Cipher Protocol | Task 5 |
| Games section: UNCONTAINED → Go Bobby Go | Task 5 |
| Alternation resets at start of each section | Task 5 |
| EstoppelBot href → estoppelbot.com | Task 5 |
| EstoppelBot badge → LIVE ON THE WEB + dot--live | Task 5 |
| Technologies section between Games + Founder | Task 6 |
| Technologies: Claude · Cursor · ChatGPT · Higgsfield | Task 6 |
| Footer EstoppelBot link updated | Task 7 |
| estoppelbot.html not deleted | ✓ not touched in any task |
