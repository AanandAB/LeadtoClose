# Bitnexel Lead Worker (Cloudflare)

Live, serverless lead pipeline between the **Bitnexel website** and the
**LeadtoClose desktop app**:

```
Website form ──POST──▶ Cloudflare Worker ──KV store──▶ GET /api/leads ◀── poll (30s) ── LeadtoClose app
                            │
                            └── WhatsApp push (CallMeBot) ──▶ your phone
```

## What it does

| Endpoint | Auth | Purpose |
|---|---|---|
| `POST /api/leads` | public | Website stores a lead **and** fires a WhatsApp notification to the studio number |
| `GET /api/leads?since=<iso>` | Bearer token | Desktop app polls for new leads (live data) |
| `GET /api/leads/:id` | Bearer token | Fetch one lead |
| `PATCH /api/leads/:id/ack` | Bearer token | Mark a lead as imported by the desktop app |
| `GET /api/health` | public | Liveness probe |

## One-time setup (~5 minutes)

```bash
cd cloudflare-worker
npm install

# 1. Create the KV namespace
npx wrangler kv namespace create LEADS
#    → copy the returned id into wrangler.toml → [[kv_namespaces]] id

# 2. Secrets
npx wrangler secret put CALLMEBOT_API_KEY     # WhatsApp push (see below)
npx wrangler secret put LEAD_SYNC_TOKEN       # any long random string

# 3. Deploy
npm run deploy
#    → note the printed URL, e.g. https://bitnexel-leads.<account>.workers.dev
```

Then in the **website** repo set `VITE_LEAD_ENDPOINT=https://bitnexel-leads.<account>.workers.dev/api/leads`
(in `.env.local` for local dev / Pages env vars for production), and in the
**LeadtoClose app → Settings → Live Lead Sync** paste the same base URL plus
the `LEAD_SYNC_TOKEN`.

## WhatsApp auto-notification via CallMeBot (free)

1. Save the number **+34 621 331 709** (CallMeBot) in your phone contacts.
2. Send it this exact message once: `I allow callmebot to send me messages`.
3. You receive your API key — set it as the `CALLMEBOT_API_KEY` secret above.

Until the key is configured, leads are still stored live and the desktop app
still pulls them; only the automatic push to WhatsApp is skipped. The website
additionally opens a `wa.me` deep link with the prefilled brief as a
belt-and-braces fallback, so you never miss a lead.

## Local development

```bash
npm run dev          # wrangler dev on http://localhost:8787
curl -X POST http://localhost:8787/api/leads \
  -H 'Content-Type: application/json' \
  -d '{"name":"Test","email":"t@x.com","message":"Hello","source":"Test"}'
```
