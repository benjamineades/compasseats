"""Pull a Read-connector result from the session transcript by a marker string; print the JSON rows."""
import json, re, sys
T = '/root/.claude/projects/-home-claude/3fd23344-04f8-51f8-9b7e-b8972c1f61fd.jsonl'
marker = sys.argv[1]
hits = []
for line in open(T, encoding='utf-8'):
    try: rec = json.loads(line)
    except Exception: continue
    msg = rec.get('message') or {}
    content = msg.get('content') if isinstance(msg, dict) else None
    if not isinstance(content, list): continue
    for c in content:
        if c.get('type') != 'tool_result': continue
        parts = c.get('content')
        texts = [p.get('text','') for p in parts if isinstance(p, dict)] if isinstance(parts, list) else [parts or '']
        for t in texts:
            if not t.startswith('{"result"'): continue
            inner = json.loads(t)['result']
            m = re.search(r'<untrusted-data-[0-9a-f-]+>\n(\[.*?\])\n</untrusted-data-', inner, re.S)
            if m and marker in m.group(1): hits.append(m.group(1))
if len(hits) != 1: sys.exit(f'marker hits {len(hits)} (expected 1)')
print(hits[0])
