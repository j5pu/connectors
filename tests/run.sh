#!/bin/bash
# Offline checks for the connectors skill.
cd "$(dirname "$0")/.." || exit 1
fail=0
ok() { echo "ok   $1"; }
ko() { echo "FAIL $1"; fail=1; }
S=skills/connectors

python3 - <<'EOF' && ok "JSON files parse" || ko "JSON files parse"
import json
for p in (".claude-plugin/plugin.json", ".claude-plugin/marketplace.json", "skills/connectors/connectors.json"):
    json.load(open(p))
EOF

python3 - <<'EOF' && ok "baseline is consistent" || ko "baseline is consistent"
import json, sys
d = json.load(open("skills/connectors/connectors.json"))
ids = [c["id"] for c in d["connectors"]]
assert len(ids) == len(set(ids)), "duplicate ids"
req = {"apple-mail", "icloud-mcp", "iwork-mcp", "whatsapp", "desktop-commander", "filesystem"}
assert req <= {c["id"] for c in d["connectors"] if c["required"]}, "required set"
for c in d["connectors"]:
    assert c["kind"] in ("local", "account", "native", "extension"), c["id"]
    if c["required"]:
        assert c.get("probe"), "required connector without probe: " + c["id"]
    if c.get("probe") is None:
        assert c.get("note"), "no probe needs a note: " + c["id"]
assert set(d["states"]) == {"ok", "unverifiable", "absent", "error"}
EOF

head -1 $S/SKILL.md | grep -q '^---$' && grep -q '^name: connectors$' $S/SKILL.md && grep -q '^description: ' $S/SKILL.md && ok "skill frontmatter" || ko "skill frontmatter"
[ -f $S/references/whatsapp-update.md ] && ok "whatsapp update reference" || ko "whatsapp update reference"
grep -q 'Revocaci' -r $S && ko "no Revocación path in the skill" || ok "no Revocación path in the skill"
grep -q '<<' -r $S && ko "no heredoc text" || ok "no heredoc text"
wa=$(python3 -c 'import json;print(json.load(open("skills/connectors/connectors.json"))["whatsapp_checkout"])')
[ -d "$wa/.git" ] && ok "whatsapp checkout exists" || ko "whatsapp checkout exists ($wa)"
exit $fail
