/**
 * Bitnexel Lead Worker — live lead store + WhatsApp notification.
 *
 * Endpoints:
 *   GET  /api/health                → liveness probe
 *   POST /api/leads                 → store lead (public, CORS for the website)
 *                                     + fire a WhatsApp notification
 *   GET  /api/leads?since=…         → poll leads (Bearer LEAD_SYNC_TOKEN)
 *   GET  /api/leads/:id             → single lead (Bearer LEAD_SYNC_TOKEN)
 *   PATCH /api/leads/:id/ack        → mark synced (Bearer LEAD_SYNC_TOKEN)
 *
 * Storage: Cloudflare KV (`LEADS` binding). Writes are replicated to the
 * edge within seconds, so the desktop app polling every 30s sees new website
 * leads with near-zero delay.
 */

export interface Env {
  LEADS: KVNamespace;
  STUDIO_WHATSAPP_NUMBER: string;
  WHATSAPP_API_URL?: string;
  CALLMEBOT_API_KEY?: string;
  LEAD_SYNC_TOKEN?: string;
}

export interface StoredLead {
  id: string;
  name: string;
  email: string;
  phone?: string;
  company?: string;
  service: string;
  budget?: string;
  message: string;
  source: string;
  submittedAt: string;
  userAgent?: string;
  notified: boolean;
  synced: boolean;
}

const CORS_HEADERS: Record<string, string> = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PATCH, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  'Access-Control-Max-Age': '86400',
};

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json; charset=utf-8', ...CORS_HEADERS },
  });
}

async function readJson(request: Request): Promise<Record<string, unknown> | null> {
  try {
    return (await request.json()) as Record<string, unknown>;
  } catch {
    return null;
  }
}

function isAuthorized(request: Request, env: Env): boolean {
  if (!env.LEAD_SYNC_TOKEN) return false; // no token configured → deny
  const header = request.headers.get('Authorization') ?? '';
  return header === `Bearer ${env.LEAD_SYNC_TOKEN}`;
}

/** Fire the WhatsApp notification via CallMeBot (best effort, never throws). */
async function notifyWhatsApp(env: Env, lead: StoredLead): Promise<boolean> {
  if (!env.CALLMEBOT_API_KEY) {
    console.log('CALLMEBOT_API_KEY not set — skipping WhatsApp push.', { leadId: lead.id });
    return false;
  }
  const brief = [
    `*New ${lead.source} Lead — Bitnexel*`,
    '',
    `*Name:* ${lead.name}`,
    `*Email:* ${lead.email}`,
    lead.phone ? `*Phone:* ${lead.phone}` : '',
    lead.company ? `*Company:* ${lead.company}` : '',
    `*Service:* ${lead.service}`,
    lead.budget ? `*Budget:* ${lead.budget}` : '',
    '',
    '*Brief:*',
    lead.message,
  ]
    .filter((l) => l !== '')
    .join('\n');

  const base =
    env.WHATSAPP_API_URL ??
    `https://api.callmebot.com/whatsapp.php?phone=%PHONE%&text=%TEXT%&apikey=%KEY%`;

  const url = base
    .replace('%PHONE%', encodeURIComponent(env.STUDIO_WHATSAPP_NUMBER))
    .replace('%TEXT%', encodeURIComponent(brief))
    .replace('%KEY%', encodeURIComponent(env.CALLMEBOT_API_KEY));

  try {
    const res = await fetch(url, { method: 'GET' } as RequestInit);
    return res.ok;
  } catch (err) {
    console.error('WhatsApp notification failed', err);
    return false;
  }
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);
    const path = url.pathname;

    if (request.method === 'OPTIONS') {
      return new Response(null, { status: 204, headers: CORS_HEADERS });
    }

    if (path === '/api/health' && request.method === 'GET') {
      return json({ ok: true, service: 'bitnexel-leads', time: new Date().toISOString() });
    }

    // ── POST /api/leads — public intake from the website ──────────────────
    if (path === '/api/leads' && request.method === 'POST') {
      const body = await readJson(request);
      if (!body) return json({ error: 'Invalid JSON body' }, 400);

      const name = String(body.name ?? '').trim();
      const email = String(body.email ?? '').trim();
      const message = String(body.message ?? '').trim();
      if (!name || !email || !message) {
        return json({ error: 'name, email and message are required' }, 422);
      }

      const lead: StoredLead = {
        id: `lead_${Date.now().toString(36)}_${crypto.randomUUID().slice(0, 8)}`,
        name,
        email,
        phone: body.phone ? String(body.phone).trim() : undefined,
        company: body.company ? String(body.company).trim() : undefined,
        service: String(body.service ?? 'General Inquiry'),
        budget: body.budget ? String(body.budget) : undefined,
        message,
        source: String(body.source ?? 'Website'),
        submittedAt: String(body.submittedAt ?? new Date().toISOString()),
        userAgent: body.userAgent ? String(body.userAgent) : undefined,
        notified: false,
        synced: false,
      };

      // Store in the live queue under a time-ordered key.
      await env.LEADS.put(`lead:${lead.submittedAt}:${lead.id}`, JSON.stringify(lead));
      // Maintain an index pointer for cheap latest-lead polling.
      await env.LEADS.put('latest', lead.submittedAt);

      // Push WhatsApp notification (await so errors surface in worker logs,
      // but never fail the intake).
      lead.notified = await notifyWhatsApp(env, lead);
      await env.LEADS.put(`lead:${lead.submittedAt}:${lead.id}`, JSON.stringify(lead));

      return json({ ok: true, id: lead.id, notified: lead.notified }, 201);
    }

    // ── Everything below requires the desktop sync token ──────────────────
    if (!path.startsWith('/api/leads')) {
      return json({ error: 'Not found' }, 404);
    }
    if (!isAuthorized(request, env)) {
      return json({ error: 'Unauthorized — set LEAD_SYNC_TOKEN and send Authorization: Bearer <token>' }, 401);
    }

    // GET /api/leads?since=<iso>&limit=<n> — polling endpoint for the app.
    if (path === '/api/leads' && request.method === 'GET') {
      const since = url.searchParams.get('since');
      const limit = Math.min(Number(url.searchParams.get('limit') ?? 50), 200);

      const list = await env.LEADS.list({ prefix: 'lead:', limit: 500 });
      const leads: StoredLead[] = [];
      for (const key of list.keys) {
        const raw = await env.LEADS.get(key.name);
        if (!raw) continue;
        const lead = JSON.parse(raw) as StoredLead;
        if (since && lead.submittedAt <= since) continue;
        leads.push(lead);
      }
      leads.sort((a, b) => a.submittedAt.localeCompare(b.submittedAt));
      return json({ leads: leads.slice(-limit), serverTime: new Date().toISOString() });
    }

    // GET /api/leads/:id
    const idMatch = path.match(/^\/api\/leads\/([^/]+)$/);
    if (idMatch && request.method === 'GET') {
      const list = await env.LEADS.list({ prefix: 'lead:', limit: 500 });
      for (const key of list.keys) {
        const raw = await env.LEADS.get(key.name);
        if (!raw) continue;
        const lead = JSON.parse(raw) as StoredLead;
        if (lead.id === idMatch[1]) return json(lead);
      }
      return json({ error: 'Lead not found' }, 404);
    }

    // PATCH /api/leads/:id/ack — the desktop app marks a lead as imported.
    const ackMatch = path.match(/^\/api\/leads\/([^/]+)\/ack$/);
    if (ackMatch && request.method === 'PATCH') {
      const list = await env.LEADS.list({ prefix: 'lead:', limit: 500 });
      for (const key of list.keys) {
        const raw = await env.LEADS.get(key.name);
        if (!raw) continue;
        const lead = JSON.parse(raw) as StoredLead;
        if (lead.id === ackMatch[1]) {
          lead.synced = true;
          await env.LEADS.put(key.name, JSON.stringify(lead));
          return json({ ok: true, id: lead.id, synced: true });
        }
      }
      return json({ error: 'Lead not found' }, 404);
    }

    return json({ error: 'Not found' }, 404);
  },
};
