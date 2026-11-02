import collections
live={};names={}
for l in open('live.txt',encoding='utf8'):
    k,p,n,c,pr=l.rstrip('\n').split('|');live[p]=k;names[p]=(n,c,pr)
art={};an={}
for l in open('article.txt',encoding='utf8'):
    k,p,n=l.rstrip('\n').split('|');art[p]=k;an[p]=n
snap={}
for l in open('snap.txt',encoding='utf8'):
    k,p=l.rstrip('\n').split('|');snap[p]=k
print('counts live',collections.Counter(live.values()),'art',collections.Counter(art.values()),'snap',collections.Counter(snap.values()))
print('ARTICLE not in live star lists:',[ (p,art[p],live.get(p)) for p in art if live.get(p)!=art[p]])
print('LIVE star not in article:',[ (p,live[p]) for p in live if live[p]!='B' and p not in art])
print('article name != live name:')
for p in art:
    if p in names and names[p][0]!=an[p]: print('  ',art[p],p,'| art:',an[p],'| live:',names[p][0])
print('NEW in live vs snapshot:')
for p in sorted(live,key=lambda x:live[x]):
    if p not in snap: print('  ',live[p],p,names[p])
print('GONE from live vs snapshot:')
for p in sorted(snap,key=lambda x:snap[x]):
    if p not in live: print('  ',snap[p],p, '(article %s)'%art[p] if p in art else '')
print('CATEGORY change:')
for p in live:
    if p in snap and snap[p]!=live[p]: print('  ',snap[p],'->',live[p],p,names[p][0])
print('price dist',collections.Counter((live[p],names[p][2]) for p in live))
print('countries suffix',collections.Counter(names[p][1].split(', ')[-1] for p in live))
