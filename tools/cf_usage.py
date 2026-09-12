"""Query Cloudflare account usage: zones, workers, D1 (with sizes), R2, Pages, KV."""
import json, re, urllib.request

ACCOUNT_ID = "82381df5150e583859bcccc1717c7ed2"
CONFIG = r"C:\Users\aanan\AppData\Roaming\xdg.config\.wrangler\config\default.toml"
BASE = "https://api.cloudflare.com/client/v4"

with open(CONFIG, encoding="utf-8") as f:
    token = re.search(r'oauth_token = "([^"]+)"', f.read()).group(1)

def get(path):
    req = urllib.request.Request(BASE + path, headers={
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
    })
    with urllib.request.urlopen(req, timeout=30) as r:
        return json.load(r)

def ok(d):
    return d.get("success", False)

def fmt_bytes(n):
    n = n or 0
    for unit in ("B", "KB", "MB", "GB", "TB"):
        if n < 1024 or unit == "TB":
            return f"{n:.2f} {unit}"
        n /= 1024

# 1. Account
acc = get(f"/accounts/{ACCOUNT_ID}")
print("=== ACCOUNT ===")
print("name:", acc["result"]["name"])
print("id:", acc["result"]["id"])

# 2. Zones (domains)
print("\n=== ZONES / DOMAINS ===")
z = get(f"/zones?account.id={ACCOUNT_ID}")
if ok(z):
    zones = z["result"]
    if not zones:
        print("(no zones / domains)")
    for zn in zones:
        plan = zn.get("plan", {}).get("name", "?")
        print(f"  {zn['name']}  status={zn['status']}  plan={plan}")
else:
    print("ERR:", z.get("errors"))

# 3. Workers scripts
print("\n=== WORKERS ===")
w = get(f"/accounts/{ACCOUNT_ID}/workers/scripts")
if ok(w):
    ws = w["result"]
    print(f"count: {len(ws)}")
    for s in ws:
        print(f"  {s.get('id','?')}  modified={s.get('modified_on','?')[:10]}")
else:
    print("ERR:", w.get("errors"))

# 4. D1 databases (+ per-db size)
print("\n=== D1 DATABASES ===")
d1 = get(f"/accounts/{ACCOUNT_ID}/d1/database")
if ok(d1):
    dbs = d1["result"]
    print(f"count: {len(dbs)}")
    total = 0
    for db in dbs:
        did = db["uuid"]
        size = db.get("file_size") or db.get("size")
        detail = db
        if size is None:
            try:
                det = get(f"/accounts/{ACCOUNT_ID}/d1/database/{did}")
                detail = det.get("result", db)
                size = detail.get("file_size") or detail.get("size")
            except Exception as e:
                pass
        sz = size if isinstance(size, int) else None
        if sz:
            total += sz
        print(f"  {db['name']}  tables={db.get('num_tables','?')}  size={fmt_bytes(sz) if sz is not None else '?'}")
    print(f"  TOTAL D1 storage: {fmt_bytes(total)}  (free limit: 5 GB)")
else:
    print("ERR:", d1.get("errors"))

# 5. R2 buckets
print("\n=== R2 BUCKETS ===")
try:
    r2 = get(f"/accounts/{ACCOUNT_ID}/r2/buckets")
    if ok(r2):
        bks = r2["result"]["buckets"]
        print(f"count: {len(bks)}")
        for b in bks:
            print(f"  {b['name']}  created={b.get('creation_date','?')[:10]}")
    else:
        print("ERR:", r2.get("errors"))
except Exception as e:
    print("R2 query failed:", e)

# 6. Pages projects
print("\n=== PAGES PROJECTS ===")
pg = get(f"/accounts/{ACCOUNT_ID}/pages/projects")
if ok(pg):
    ps = pg["result"]
    print(f"count: {len(ps)}")
    for p in ps:
        print(f"  {p['name']}  subdomain={p.get('subdomain','?')}")
else:
    print("ERR:", pg.get("errors"))

# 7. KV namespaces
print("\n=== KV NAMESPACES ===")
kv = get(f"/accounts/{ACCOUNT_ID}/storage/kv/namespaces")
if ok(kv):
    ks = kv["result"]
    print(f"count: {len(ks)}")
    for k in ks:
        print(f"  {k['title']}  id={k['id']}")
else:
    print("ERR:", kv.get("errors"))
