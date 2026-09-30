//
//  welcome.js
//  bleek-vision-website
//
//  Created by Shabaka Malik Banks on 9/30/26.
//  Copyright © 2026 Bleek Vision LLC. All rights reserved.
//

const SYMPATHIES_LINES = {
  'cipher-9':         'Your sympathies are noted: the Ninth. Good. We need people who can keep a record and keep their nerve.',
  'cinder':           "Your sympathies are noted: the Cinder Doctrine. The Ninth doesn't punish that. It remembers it.",
  'umbra':            "Your sympathies are noted: the Umbra Network. Be careful who you say that to. Some of them are already listening.",
};

function getSympathiesLine(sympathies) {
  const key = (sympathies ?? '').toLowerCase().trim();
  return SYMPATHIES_LINES[key] ?? "You kept your sympathies to yourself. Discretion. We'll take that as a good sign.";
}

export function welcomeEmail(sympathies) {
  const sympathiesLine = getSympathiesLine(sympathies);
  return `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="color-scheme" content="light">
<title>You're on file</title>
<style>
  body { margin: 0; padding: 0; background: #1A1A1A; font-family: Courier, 'Courier New', monospace; }
  .wrap { max-width: 600px; margin: 40px auto; padding: 20px; }
  .panel { background: #D8D0BC; border: 1px solid #B8AC9A; padding: 40px 44px; }
  .eyebrow { font-size: 11px; letter-spacing: 0.12em; text-transform: uppercase; color: #5A5040; margin: 0 0 24px; }
  .salutation { font-size: 15px; color: #1A1510; margin: 0 0 20px; line-height: 1.6; }
  p { font-size: 14px; color: #2A2018; line-height: 1.7; margin: 0 0 18px; }
  .sympathies { font-style: italic; border-left: 2px solid #8A7A68; padding-left: 16px; color: #3A2A18; }
  .sig { font-size: 13px; color: #1A1510; margin: 28px 0 0; }
  .postscript { font-size: 12px; color: #5A4A38; border-top: 1px solid #B8AC9A; margin-top: 24px; padding-top: 18px; font-style: italic; }
  .footer { font-size: 11px; color: #7A6A58; line-height: 1.6; margin-top: 24px; border-top: 1px solid #B8AC9A; padding-top: 20px; }
  .footer a { color: #5A4A38; }
</style>
</head>
<body>
<div class="wrap">
  <div class="panel">
    <p class="eyebrow">CIPHER PROTOCOL — CONFIRMED</p>
    <p class="salutation">Agent,</p>
    <p>Your line is confirmed. Your file is open.</p>
    <p class="sympathies">${sympathiesLine}</p>
    <p>Here is what happens next: nothing, for a while. That's deliberate. When Operation 001 is ready, a package will be waiting, and so will I.</p>
    <p>Until then, keep your routes. Same streets. Same hours. We'll know where to find you.</p>
    <p class="sig">The Archivist</p>
    <p class="postscript">A note from Vector: charge the earpiece, and wear the good shoes. Don't tell anyone about this letter. They won't believe you, and that's the best cover there is.</p>
    <div class="footer">
      <p style="margin:0;">One email a month, at most. <a href="{{{RESEND_UNSUBSCRIBE_URL}}}">Unsubscribe</a> anytime.</p>
      <p style="margin:8px 0 0;">Bleek Vision LLC · [POSTAL ADDRESS] · <a href="mailto:malik@bleekvision.com">malik@bleekvision.com</a></p>
    </div>
  </div>
</div>
</body>
</html>`;
}

export function welcomeEmailText(sympathies) {
  const sympathiesLine = getSympathiesLine(sympathies);
  return `CIPHER PROTOCOL — CONFIRMED

Agent,

Your line is confirmed. Your file is open.

${sympathiesLine}

Here is what happens next: nothing, for a while. That's deliberate. When Operation 001 is ready, a package will be waiting, and so will I.

Until then, keep your routes. Same streets. Same hours. We'll know where to find you.

The Archivist

---
A note from Vector: charge the earpiece, and wear the good shoes. Don't tell anyone about this letter. They won't believe you, and that's the best cover there is.

---
One email a month, at most. To unsubscribe: {{{RESEND_UNSUBSCRIBE_URL}}}

Bleek Vision LLC · [POSTAL ADDRESS] · malik@bleekvision.com
`;
}
