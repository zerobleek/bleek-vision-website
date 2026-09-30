//
//  worker.js
//  bleek-vision-website
//
//  Created by Shabaka Malik Banks on 9/30/26.
//  Copyright © 2026 Bleek Vision LLC. All rights reserved.
//

import { confirmationEmail, confirmationEmailText } from './emails/confirmation.js';
import { welcomeEmail, welcomeEmailText } from './emails/welcome.js';

const TOKEN_TTL = 7 * 24 * 60 * 60; // 7 days in seconds

export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    if (url.pathname === '/api/subscribe' && request.method === 'POST') {
      return handleSubscribe(request, env);
    }

    if (url.pathname === '/api/confirm' && request.method === 'GET') {
      return handleConfirm(request, env);
    }

    return env.ASSETS.fetch(request);
  },
};

// ── POST /api/subscribe ──────────────────────────────────────────────────────

async function handleSubscribe(request, env) {
  const isJSON = request.headers.get('content-type')?.includes('application/json');
  let email, sympathies, source, turnstileToken, honeypot;

  try {
    if (isJSON) {
      const body = await request.json();
      ({ email, sympathies, source, turnstileToken, honeypot } = body);
    } else {
      const form = await request.formData();
      email        = form.get('email')         ?? '';
      sympathies   = form.get('sympathies')    ?? '';
      source       = form.get('source')        ?? 'hero';
      turnstileToken = form.get('cf-turnstile-response') ?? '';
      honeypot     = form.get('website')       ?? '';
    }
  } catch {
    return respond(isJSON, 400, 'bad_request', 'The line dropped. Try again.', null, env);
  }

  // Honeypot: bots fill the hidden field, humans leave it blank
  if (honeypot) {
    return respond(isJSON, 200, 'ok', null, 'CHECK YOUR INBOX, AGENT.', env);
  }

  // Email validation
  email = (email ?? '').trim().toLowerCase();
  if (!isValidEmail(email)) {
    return respond(isJSON, 422, 'invalid_email', "That address won't reach you. Check it and try again.", null, env);
  }

  // Rate limiting (5 requests / minute per IP)
  const ip = request.headers.get('cf-connecting-ip') ?? '0.0.0.0';
  if (env.RATE_LIMITER) {
    const { success } = await env.RATE_LIMITER.limit({ key: ip });
    if (!success) {
      return respond(isJSON, 429, 'rate_limited', 'Too many tries from here. Wait a minute and try again.', null, env);
    }
  }

  // Turnstile verification (skip in dev when secret is not set)
  if (env.TURNSTILE_SECRET && env.TURNSTILE_SECRET !== 'dev') {
    const ok = await verifyTurnstile(turnstileToken, env.TURNSTILE_SECRET, ip);
    if (!ok) {
      return respond(isJSON, 403, 'turnstile_failed', 'The line dropped. Try again.', null, env);
    }
  }

  // Build and sign the confirmation token
  const payload = { email, sympathies: sympathies ?? '', source: source ?? 'hero', ts: Math.floor(Date.now() / 1000) };
  const token = await signToken(payload, env.SIGNUP_SECRET);

  // Send the confirmation email through Resend (best-effort — don't reveal delivery status)
  const confirmUrl = `https://bleekvision.com/api/confirm?t=${token}`;
  await sendEmail(env, {
    from: env.MAIL_FROM ?? 'The Archivist <intake@mail.bleekvision.com>',
    to: email,
    subject: 'Confirm your line',
    previewText: "You answered. Most people don't.",
    html: confirmationEmail(confirmUrl),
    text: confirmationEmailText(confirmUrl),
  });

  const msg = `CHECK YOUR INBOX, AGENT. We sent a confirmation email to ${email}. Tap the link inside to join the waitlist. Nothing else arrives until you do.`;
  return respond(isJSON, 200, 'ok', null, msg, env);
}

// ── GET /api/confirm ─────────────────────────────────────────────────────────

async function handleConfirm(request, env) {
  const url = new URL(request.url);
  const raw = url.searchParams.get('t') ?? '';

  let payload;
  try {
    payload = await verifyToken(raw, env.SIGNUP_SECRET);
  } catch (err) {
    // Tampered or expired — redirect to /cipher with an error flag
    return Response.redirect('https://bleekvision.com/cipher?expired=1', 302);
  }

  const { email, sympathies, source } = payload;

  // Create or update the Resend contact
  await upsertContact(env, { email, sympathies, source });

  // Send the welcome email
  await sendEmail(env, {
    from: env.MAIL_FROM ?? 'The Archivist <intake@mail.bleekvision.com>',
    to: email,
    subject: "You're on file",
    previewText: 'Your line is confirmed. Your file is open.',
    html: welcomeEmail(sympathies),
    text: welcomeEmailText(sympathies),
  });

  return Response.redirect('https://bleekvision.com/cipher?confirmed=1', 302);
}

// ── HMAC token helpers ───────────────────────────────────────────────────────

async function signToken(payload, secret) {
  const data = JSON.stringify(payload);
  const key = await importKey(secret);
  const sig = await crypto.subtle.sign('HMAC', key, new TextEncoder().encode(data));
  const b64 = btoa(String.fromCharCode(...new Uint8Array(sig)));
  const b64url = b64.replace(/\+/g, '-').replace(/\//g, '_').replace(/=/g, '');
  const dataB64 = btoa(data).replace(/\+/g, '-').replace(/\//g, '_').replace(/=/g, '');
  return `${dataB64}.${b64url}`;
}

async function verifyToken(token, secret) {
  const [dataB64, sigB64] = token.split('.');
  if (!dataB64 || !sigB64) throw new Error('malformed');

  const data = atob(dataB64.replace(/-/g, '+').replace(/_/g, '/'));
  const sigBytes = Uint8Array.from(atob(sigB64.replace(/-/g, '+').replace(/_/g, '/')), c => c.charCodeAt(0));

  const key = await importKey(secret);
  const valid = await crypto.subtle.verify('HMAC', key, sigBytes, new TextEncoder().encode(data));
  if (!valid) throw new Error('invalid signature');

  const payload = JSON.parse(data);
  if (Math.floor(Date.now() / 1000) - payload.ts > TOKEN_TTL) throw new Error('expired');
  return payload;
}

async function importKey(secret) {
  const raw = new TextEncoder().encode(secret ?? 'dev-secret-change-me');
  return crypto.subtle.importKey('raw', raw, { name: 'HMAC', hash: 'SHA-256' }, false, ['sign', 'verify']);
}

// ── Resend helpers ───────────────────────────────────────────────────────────

async function sendEmail(env, { from, to, subject, previewText, html, text }) {
  if (!env.RESEND_API_KEY) return; // no-op in dev
  await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: { 'Authorization': `Bearer ${env.RESEND_API_KEY}`, 'Content-Type': 'application/json' },
    body: JSON.stringify({ from, to: [to], subject, html, text,
      headers: { 'X-Entity-Ref-ID': crypto.randomUUID() },
      tags: [{ name: 'product', value: 'cipher-protocol' }],
    }),
  });
}

async function upsertContact(env, { email, sympathies, source }) {
  if (!env.RESEND_API_KEY || !env.RESEND_SEGMENT_ID) return;
  await fetch(`https://api.resend.com/audiences/${env.RESEND_SEGMENT_ID}/contacts`, {
    method: 'POST',
    headers: { 'Authorization': `Bearer ${env.RESEND_API_KEY}`, 'Content-Type': 'application/json' },
    body: JSON.stringify({
      email,
      unsubscribed: false,
      data: {
        sympathies: sympathies || 'none',
        source: source || 'hero',
        confirmed_at: new Date().toISOString(),
      },
    }),
  });
}

// ── Turnstile ────────────────────────────────────────────────────────────────

async function verifyTurnstile(token, secret, ip) {
  const res = await fetch('https://challenges.cloudflare.com/turnstile/v0/siteverify', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ secret, response: token, remoteip: ip }),
  });
  const data = await res.json();
  return data.success === true;
}

// ── Response helpers ─────────────────────────────────────────────────────────

function respond(isJSON, status, code, error, message, env) {
  if (isJSON) {
    return new Response(JSON.stringify({ ok: !error, code, error, message }), {
      status,
      headers: { 'Content-Type': 'application/json' },
    });
  }
  // No-JS fallback: return a minimal HTML page
  const body = error ?? message ?? '';
  const html = `<!doctype html><html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Cipher Protocol — Waitlist</title>
<style>body{font-family:system-ui,sans-serif;background:#030805;color:#EAF7EE;display:flex;align-items:center;justify-content:center;min-height:100vh;margin:0;padding:2rem;}p{max-width:480px;text-align:center;line-height:1.6;}</style>
</head><body><p>${body} <a href="/cipher" style="color:#8CFFAE;">Back to Cipher Protocol →</a></p></body></html>`;
  return new Response(html, { status, headers: { 'Content-Type': 'text/html;charset=utf-8' } });
}

function isValidEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/.test(email);
}
