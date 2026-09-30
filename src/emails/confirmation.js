//
//  confirmation.js
//  bleek-vision-website
//
//  Created by Shabaka Malik Banks on 9/30/26.
//  Copyright © 2026 Bleek Vision LLC. All rights reserved.
//

export function confirmationEmail(confirmUrl) {
  return `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="color-scheme" content="light">
<title>Confirm your line</title>
<style>
  body { margin: 0; padding: 0; background: #1A1A1A; font-family: Courier, 'Courier New', monospace; }
  .wrap { max-width: 600px; margin: 40px auto; padding: 20px; }
  .panel { background: #D8D0BC; border: 1px solid #B8AC9A; padding: 40px 44px; }
  .eyebrow { font-size: 11px; letter-spacing: 0.12em; text-transform: uppercase; color: #5A5040; margin: 0 0 24px; }
  .salutation { font-size: 15px; color: #1A1510; margin: 0 0 20px; line-height: 1.6; }
  p { font-size: 14px; color: #2A2018; line-height: 1.7; margin: 0 0 18px; }
  .cta-wrap { margin: 32px 0; }
  .cta { display: inline-block; background: #1A1510; color: #D8D0BC; font-family: Courier, 'Courier New', monospace; font-size: 13px; letter-spacing: 0.1em; text-transform: uppercase; text-decoration: none; padding: 14px 28px; }
  .sig { font-size: 13px; color: #1A1510; margin: 28px 0 0; }
  .footer { font-size: 11px; color: #7A6A58; line-height: 1.6; margin-top: 24px; border-top: 1px solid #B8AC9A; padding-top: 20px; }
  .footer a { color: #5A4A38; }
</style>
</head>
<body>
<div class="wrap">
  <div class="panel">
    <p class="eyebrow">CIPHER PROTOCOL — INTAKE</p>
    <p class="salutation">To the occupant,</p>
    <p>You were observed, and you answered. Most people don't.</p>
    <p>Before we say anything else, we need to know this line is yours. Tap below to confirm your email and join the Cipher Protocol waitlist.</p>
    <div class="cta-wrap">
      <a href="${confirmUrl}" class="cta">Confirm your line</a>
    </div>
    <p>Once you do, you'll hear from us when Operation 001 is ready to run, and not before. One email a month, at most.</p>
    <p class="sig">The Archivist</p>
    <div class="footer">
      <p style="margin:0;">If you didn't ask for this, do nothing. This letter was never sent, and nothing more will follow.</p>
      <p style="margin:8px 0 0;">Bleek Vision LLC · [POSTAL ADDRESS] · <a href="mailto:malik@bleekvision.com">malik@bleekvision.com</a></p>
    </div>
  </div>
</div>
</body>
</html>`;
}

export function confirmationEmailText(confirmUrl) {
  return `CIPHER PROTOCOL — INTAKE

To the occupant,

You were observed, and you answered. Most people don't.

Before we say anything else, we need to know this line is yours. Follow the link below to confirm your email and join the Cipher Protocol waitlist.

CONFIRM YOUR LINE:
${confirmUrl}

Once you do, you'll hear from us when Operation 001 is ready to run, and not before. One email a month, at most.

The Archivist

---
If you didn't ask for this, do nothing. This letter was never sent, and nothing more will follow.

Bleek Vision LLC · [POSTAL ADDRESS] · malik@bleekvision.com
`;
}
