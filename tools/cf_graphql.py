"""Cloudflare GraphQL: Workers requests + subrequests for the last 7 days."""
import json, re, urllib.request, datetime

ACCOUNT_ID = "82381df5150e583859bcccc1717c7ed2"
CONFIG = r"C:\Users\aanan\AppData\Roaming\xdg.config\.wrangler\config\default.toml"
with open(CONFIG, encoding="utf-8") as f:
    token = re.search(r'oauth_token = "([^"]+)"', f.read()).group(1)

now = datetime.datetime.utcnow()
geq = (now - datetime.timedelta(days=7)).strftime("%Y-%m-%dT%H:%M:%SZ")
leq = now.strftime("%Y-%m-%dT%H:%M:%SZ")

query = """
{
  viewer {
    accounts(filter: {accountTag: "%s"}) {
      workersInvocationsAdaptive(
        filter: {datetime_geq: "%s", datetime_leq: "%s"},
        limit: 10000
      ) {
        sum { requests subrequests }
        dimensions { date }
      }
    }
  }
}
""" % (ACCOUNT_ID, geq, leq)

req = urllib.request.Request(
    "https://api.cloudflare.com/client/v4/graphql",
    data=json.dumps({"query": query}).encode(),
    headers={"Authorization": f"Bearer {token}", "Content-Type": "application/json"},
)
with urllib.request.urlopen(req, timeout=30) as r:
    data = json.load(r)

if data.get("errors"):
    print("ERRORS:", json.dumps(data["errors"])[:800])
else:
    accts = data["data"]["viewer"]["accounts"]
    if not accts:
        print("no account data returned")
    for a in accts:
        rows = a.get("workersInvocationsAdaptive", [])
        total_req = 0
        total_sub = 0
        print("=== Workers requests (last 7 days) ===")
        for row in rows:
            s = row.get("sum", {})
            d = row.get("dimensions", {}).get("date", "?")
            r = s.get("requests", 0)
            sb = s.get("subrequests", 0)
            total_req += r
            total_sub += sb
            print(f"  {d}: {r:,} requests, {sb:,} subrequests")
        print(f"  TOTAL: {total_req:,} requests, {total_sub:,} subrequests")
        days = max(len(rows), 1)
        print(f"  AVG/day: {total_req//days:,} requests (free limit: 100,000/day)")
