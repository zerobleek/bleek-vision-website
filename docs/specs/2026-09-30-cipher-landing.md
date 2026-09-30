# Cipher Protocol Landing Page and Mailing List Spec

Sep 30, 2026 · @Shabaka Malik Banks

A new page at bleekvision.com/cipher promotes Cipher Protocol and replaces the Google Form waitlist with a real, double opt-in mailing list on Resend, served by the site's existing Cloudflare Worker. Mockups are in the Cipher Protocol Landing Page canvas; Claude Code builds it in the bleek-vision-website repo.

## Decisions

| Question | Decision | Why |
| --- | --- | --- |
| Where the page lives | `bleekvision.com/cipher` (`cipher.html`), inside the studio nav and footer | One home for the studio; the Cipher world lives inside it, the same pattern as the product cards |
| Mailing list provider | Resend (Contacts, Segments, Broadcasts) | Already on your account; has an API for the Worker and handles unsubscribes for broadcasts |
| Signup backend | A small handler at `/api/subscribe` and `/api/confirm` in the site's existing Cloudflare Worker | The site already deploys with Wrangler; no new host, no third-party form |
| Opt-in | Double opt-in: nobody joins the list until they click the confirmation letter | Keeps the list clean and proves consent |
| What we collect | Email (required), sympathies (optional: CIPHER-9, Cinder, Umbra), signup source (hero or footer) | Sympathies make later emails feel in-world and tell you which faction resonates |
| Bot protection | Cloudflare Turnstile (invisible) plus a hidden honeypot field | Free, no puzzles for real people |
| Tracking | No open or click tracking in emails; no cookies on the page | Matches the app's privacy stance |
| Existing Google Form | Retired: every link to it points to `/cipher` | One list, owned by you |

## Page structure

The page keeps the studio's navy nav and footer (DESIGN.md) and switches to Cipher's own world in between: ground `#030805`, phosphor `#8CFFAE`, text `#EAF7EE` / `#BFE3C9`, labels `#6FA982`, VT323 for display, IBM Plex Mono for the one label per section that needs it, system sans for reading text. CRT scanlines only on the hero and handler sections. No neon greens: the old site card's `#36F07A` is retired.

| # | Section | Content | Art |
| --- | --- | --- | --- |
| 1 | Hero | "YOU HAVE BEEN OBSERVED." One-paragraph pitch that says "running app" in the first read. Email field + "Join the waitlist". Line: coming to iPhone in spring 2027, one email a month at most, unsubscribe anytime | Sealed package photo, fading in from the right |
| 2 | Every run is a mission | Briefing, run, debrief explained in one paragraph | Three real app screenshots in phone frames |
| 3 | It starts with a package | The intake story in four sentences; Sign in with Apple is optional | Foam tray photo |
| 4 | Two voices in your ear | The Archivist and Vector, one line each, plus an intercepted line from the unknown party | Codec portraits |
| 5 | Where do your sympathies lie? | The three factions with their insignia and pitch lines | Inline SVG insignia (same geometry as the app) |
| 6 | No agent left behind | No leaderboards; rest days count; runs stay on your phone | Live Activity screenshot |
| 7 | Operation 001 | Vienna teaser, "The first three missions are free", second signup form | Vienna key art, darkened |

Phone layout (390 px): everything stacks; the three screenshots become a swipeable row. Copy in the mockups is final unless you change it; the voice and every line of dialogue are in the next section.

## Voice and lore

Runners first, spies second. The page sells a running app, so every section leads with something a runner recognises (distance, pace, treadmill, rest days, earbuds, Apple Health, 2 km building to 5.5 km) and uses the spy story as the reason it's more fun than a plain tracker. The tone is a quiet, cerebral spy film: short sentences, understatement, a little withholding. Spy terms appear as flavour in headlines, eyebrows and dialogue, never in the sentence that explains what the app does. Section eyebrows read like a case file: FILE 01 · HOW A RUN WORKS, FILE 02 · GETTING STARTED, FILE 03 · YOUR HANDLERS, FILE 04 · ALLEGIANCES.

Rules for Claude Code and for any future copy:

- **The one-sentence test.** A runner who has never heard of the app should understand it from the hero alone: a running app, told as a spy thriller, with a voice in your earbuds, where the story moves when you run.
- **Canon comes from the app.** Faction pitch lines and taglines, the Vienna facts (exposed March 2029, burned within three days, nine cells, operating since 1961) and mission distances must match the app.
- **Plain where it matters.** Buttons, the signup form, unsubscribe, privacy and Apple Health stay literal. The call to action is "Join the waitlist"; "intake package" stays in the field label as flavour.
- **Welcome every pace.** Name slow paces out loud ("a 14-minute mile completes the mission exactly like a 7"). No leaderboards, no pace-shaming, rest days count.
- **No hype words.** No "epic", "immersive", "revolutionary" or exclamation marks.

### Dialogue on the page

| Where | Speaker | Line | Source |
| --- | --- | --- | --- |
| Hero body | The Archivist (unattributed) | "Not your name. Your routes. The same streets at the same hours, in weather most people stay in for." | App, intake letter |
| Handler card | The Archivist | "This first run is a test of one thing: that you come back." | App, mission 001-01 briefing |
| Handler card | Vector | "Take the harder line, hills included. The intel is waiting at the top." | **New line**, built from the app's "Go direct" choice. Add it to Vector's script so the app and site agree |
| Intercept strip | Unknown party | "Agent. The Archivist is lying to you about Vienna." | App, mission 001-03 |
| No agent left behind | The Ninth | "The Ninth cares that you came back." | Echoes 001-01 |

Character notes: the Archivist recruits and withholds; she speaks in verdicts and never explains. Vector is a career case officer, methodical and dry, who trusts evidence first; his lines are practical and a little paternal. The unknown party (the Interlocutor) only ever appears as an intercept and always casts doubt on the Archivist.

### Form and state copy

| State | Copy |
| --- | --- |
| Field label | WHERE DO WE SEND YOUR INTAKE PACKAGE? |
| Button | Join the waitlist |
| Faction chips legend | Pick a side (optional) |
| Line under the form | Coming to iPhone in spring 2027. One email a month, at most. Unsubscribe anytime. |
| Invalid email | That address won't reach you. Check it and try again. |
| Rate limited | Too many tries from here. Wait a minute and try again. |
| Network error | The line dropped. Try again. |
| Sent | CHECK YOUR INBOX, AGENT. We sent a confirmation email to [email]. Tap the link inside to join the waitlist. Nothing else arrives until you do. |
| Confirmed (/cipher?confirmed=1) | YOU'RE ON FILE, AGENT. You're on the waitlist. We'll email you when Operation 001 is ready to run. |
| Bad or expired link | This link has expired. Links last seven days. Join the waitlist again and we'll send a fresh one. |

## Signup flow

Nothing is stored until the person confirms, so the list only ever holds people who asked to be on it.

1. The visitor enters an email, optionally picks a faction, and taps **Join the waitlist**. The page posts `{email, sympathies, source, turnstileToken}` to `POST /api/subscribe` with JavaScript; without JavaScript the form still posts normally and gets a plain confirmation page.
2. The Worker checks the Turnstile token, the honeypot field, the email format, and a rate limit of 5 requests a minute per IP (Workers Rate Limiting binding).
3. The Worker makes a signed token: email, sympathies, source and a timestamp, signed with HMAC-SHA256 using the `SIGNUP_SECRET`, valid for 7 days.
4. The Worker sends the confirmation letter through Resend with the link `https://bleekvision.com/api/confirm?t=<token>`. It answers the page with the same "Check your inbox, agent" message every time, whether or not the address is already on the list, so nobody can probe who is subscribed.
5. The person clicks the link. The Worker verifies the signature and age, then creates the contact in Resend in the **Cipher Protocol** segment with the properties `sympathies`, `source` and `confirmed_at`. If the contact already exists it only updates those properties.
6. The Worker redirects to `/cipher?confirmed=1`, where the page shows "You're on file, agent", and sends the welcome letter.

Every message the form and the confirm link can show is in Voice and lore → Form and state copy (mockup: Signup states).

## Build tasks for Claude Code

Repo: `zerobleek/bleek-vision-website` (a local copy is at `~/bleek-vision-website`). It is plain HTML and CSS deployed as a Cloudflare Worker with static assets; today `wrangler.jsonc` has no `main`, so there is no server code yet.

| File | Change |
| --- | --- |
| `cipher.html` (new) | The page, built to the desktop and phone mockups. Loads VT323 and IBM Plex Mono from Google Fonts on this page only. Real `<label>`s, `aria-live` status region for form states, reduced-motion safe. |
| `styles.css` | Add a scoped `.cipher-*` block with the Cipher tokens. Update `.card--cipher` world colours from `#36F07A` to `#8CFFAE` on `#030805`. |
| `assets/cipher/` (new) | Art and screenshots from `~/Desktop/Bleek Vision LLC/05 - Products/Cipher Protocol/02 - Art/Web/`, converted to WebP with explicit width and height. Plus a 1200×630 `og-cipher.png` (package photo + CIPHER PROTOCOL wordmark in VT323). |
| `src/worker.js` (new) | `POST /api/subscribe` and `GET /api/confirm` as in the signup flow; every other path goes to `env.ASSETS.fetch(request)`. Emails built in `src/emails/` with HTML and plain-text versions. |
| `wrangler.jsonc` | Add `"main": "src/worker.js"`, an assets binding `ASSETS` with `run_worker_first: ["/api/*"]`, a rate-limit binding, and vars `RESEND_SEGMENT_ID` and `MAIL_FROM`. Secrets go in with `wrangler secret put`: `RESEND_API_KEY`, `SIGNUP_SECRET`, `TURNSTILE_SECRET`. |
| `.assetsignore` (new) | Keep `src/`, `docs/`, `*.md`, `wrangler.jsonc` and `.github/` out of the public assets, so the Worker's source is never downloadable. |
| `index.html` | Replace the Cipher card with the updated card (mockup: StudioCard): new subtitle, copy, meta line, fresh screenshot, CTA to `/cipher`. Point the footer's Cipher Protocol link to `/cipher`. Remove every Google Form link. |
| `privacy.html` | New "Mailing list" section (see Privacy and compliance). |
| `sitemap.xml` | Add `https://bleekvision.com/cipher`. |
| `DESIGN.md`, `PRODUCT.md` | Record the Cipher page, its tokens and the mailing list. |

## Setup Malik does

These need your accounts, so Claude Code can't do them. About 30 minutes, most of it waiting for DNS.

- [ ] **Resend: add the sending domain** `mail.bleekvision.com` (a subdomain keeps marketing mail's reputation separate from your own inbox). Resend shows the DNS records to add.
- [ ] **Cloudflare DNS:** add Resend's SPF, DKIM and MX records for `mail.bleekvision.com`, plus a DMARC record (`_dmarc.bleekvision.com`, start with `p=none`). Wait for Resend to show Verified. Note: your `estoppelbot.com` domain in Resend shows as failed verification, so check it while you're there.
- [ ] **Resend: create the segment** "Cipher Protocol" and the contact properties `sympathies`, `source`, `confirmed_at`. I can do this part for you from this chat, since Resend is connected here.
- [ ] **Resend: create an API key** limited to sending and contacts. Give it to Claude Code only through `wrangler secret put RESEND_API_KEY`, never in a file.
- [ ] **Cloudflare Turnstile:** create a widget for `bleekvision.com` (invisible mode). The site key goes in `cipher.html`; the secret key via `wrangler secret put TURNSTILE_SECRET`.
- [ ] **A mailing address** for the email footer. US law (CAN-SPAM) requires a physical postal address in marketing email; a PO box or a virtual mailbox works and keeps your home address private.

## Emails

All mail comes from "The Archivist" `<intake@mail.bleekvision.com>`, with replies going to `malik@bleekvision.com`. Each has a plain-text version, the mailing address and an unsubscribe link. The layout is a single cream panel (`#D8D0BC`) with typewriter-style type falling back to Courier, since email clients drop web fonts and background images.

| Email | When | Subject | Body (short) |
| --- | --- | --- | --- |
| Confirmation letter | Right after signup | Confirm your line | Full text under Letters below (mockup: Email) |
| Welcome | Right after confirming | You're on file | Full text under Letters below, with one line that changes by sympathies |
| Dispatch | Monthly at most, sent by you as a Resend broadcast | Varies | Build progress, a story fragment, TestFlight invites when ready |
| Launch | Launch day | Operation 001 is live | App Store link; the first three missions are free |

### Letters

**Confirmation letter.** Subject: Confirm your line. Preview text: You answered. Most people don't.

> To the occupant,
>
> You were observed, and you answered. Most people don't.
>
> Before we say anything else, we need to know this line is yours. Tap below to confirm your email and join the Cipher Protocol waitlist.
>
> CONFIRM YOUR LINE (button)
>
> Once you do, you'll hear from us when Operation 001 is ready to run, and not before. One email a month, at most.
>
> The Archivist
>
> If you didn't ask for this, do nothing. This letter was never sent, and nothing more will follow.

**Welcome letter.** Subject: You're on file. Preview text: Your line is confirmed. Your file is open.

> Agent,
>
> Your line is confirmed. Your file is open.
>
> [SYMPATHIES LINE]
>
> Here is what happens next: nothing, for a while. That's deliberate. When Operation 001 is ready, a package will be waiting, and so will I.
>
> Until then, keep your routes. Same streets. Same hours. We'll know where to find you.
>
> The Archivist
>
> A note from Vector: charge the earpiece, and wear the good shoes. Don't tell anyone about this letter. They won't believe you, and that's the best cover there is.

| Sympathies on file | Line in the welcome letter |
| --- | --- |
| CIPHER-9 | Your sympathies are noted: the Ninth. Good. We need people who can keep a record and keep their nerve. |
| The Cinder Doctrine | Your sympathies are noted: the Cinder Doctrine. The Ninth doesn't punish that. It remembers it. |
| The Umbra Network | Your sympathies are noted: the Umbra Network. Be careful who you say that to. Some of them are already listening. |
| None given | You kept your sympathies to yourself. Discretion. We'll take that as a good sign. |

Dispatch and launch story lines are placeholders for your script.

## Privacy and compliance

- **Consent is explicit:** double opt-in, and the line under every form says what they'll get and how often.
- **Unsubscribe in one click** in every email (Resend's unsubscribe link for broadcasts; the Worker's own signed link for the transactional letters).
- **CAN-SPAM:** real sender name, honest subject lines, postal address in every email.
- **Stored per subscriber:** email, sympathies, source, confirmation date. No name, no IP address, no location, no device data. No open or click tracking.
- **privacy.html gets a "Mailing list" section** saying exactly that, naming Resend as the processor, and explaining how to leave the list or ask for deletion (reply to any email, or write to malik@bleekvision.com).
- **Secrets never in the repo:** all keys through `wrangler secret put`. This is one of the items on your pre-MVP security review list.

## Done when

- [ ] `/cipher` matches the desktop and phone mockups and passes WCAG AA contrast, with keyboard access and reduced motion honoured.
- [ ] A real signup gets the confirmation letter within a minute, in the inbox (not spam) at Gmail and iCloud.
- [ ] Clicking the link creates the contact in the Cipher Protocol segment with its sympathies, shows "You're on file", and sends the welcome letter.
- [ ] Signing up twice with the same address shows the same message and leaves one contact.
- [ ] A tampered or expired link shows a polite error, not a stack trace.
- [ ] Six quick submissions from one IP hit the rate limit.
- [ ] `https://bleekvision.com/src/worker.js` returns 404.
- [ ] No Google Form links remain anywhere on the site.
- [ ] The home page Cipher card matches the StudioCard mockup and links to `/cipher`.
- [ ] Lighthouse on `/cipher`: 90+ for performance and accessibility on mobile.

## Open questions

- [ ] Which postal address goes in the email footer? Needed before the first email sends.
- [ ] Is "coming to iPhone in spring 2027" the public line you want, or keep it to "2027"?
- [ ] OK to say "the first three missions are free" publicly now?
- [ ] Later: a studio-wide "Bleek Vision dispatch" signup in the site footer, using the same Worker with a second segment. Not in this build.

## Handoff prompt for Claude Code

Open Claude Code on `~/bleek-vision-website` (a separate session from the Cipher Protocol app), after the setup steps above are done, and paste:

```
Read DESIGN.md, PRODUCT.md and docs/specs/2026-09-30-cipher-landing.md.
Build the Cipher Protocol landing page and mailing list exactly as the spec says:
cipher.html, the scoped .cipher styles, the Worker at src/worker.js with
/api/subscribe and /api/confirm, wrangler.jsonc, .assetsignore, the updated
home-page card, privacy.html and sitemap.xml. Art is in
~/Desktop/Bleek Vision LLC/05 - Products/Cipher Protocol/02 - Art/Web/.
Secrets come from wrangler secret put; never write keys to files.
Run it with wrangler dev, test every item under "Done when", then commit
small steps and show me before deploying.
```
