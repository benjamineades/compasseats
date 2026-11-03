import json,re,csv,sys
raw=open(sys.argv[1]).read()
o=json.loads(raw)
t=o['result'] if isinstance(o,dict) else o[0]['text']
if isinstance(o,list): t=json.loads(t)['result']
m=re.search(r'<untrusted-data-[^>]+>\s*(\[.*\])\s*</untrusted',t,re.S)
rows=json.loads(m.group(1))
json.dump(rows,open(sys.argv[2],'w'),ensure_ascii=False)
print(len(rows))
