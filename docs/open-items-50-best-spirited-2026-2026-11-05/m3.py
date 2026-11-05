import json,re,unicodedata,collections
exec(open('match.py').read().split("res=[]")[0])
terms={'montana':'Hong Kong','borracha':'Accra','god':'Bangkok','g o d':'Bangkok','three horses':'Melbourne','otro':'San José','mius':'Hong Kong','naked':'Athens','gabriel':'Istanbul','tiao':'Beijing','aqua':'Bangkok','problem child':'Makati','m ms':'Seoul','mms':'Seoul','cmyk':'Changsha','pony up':'Shanghai','obsidian':'Shenzhen','spirits library':'Makati','spirit library':'Makati','long fong':'Beijing','longfong':'Beijing','ropewalk':'Galle','chimney':'Hangzhou','aabbcc':'New Delhi','hats':'Jakarta','ritz carlton':'Tokyo','between the sips':'Jakarta','cabinet':'Kuala Lumpur','bop':'Singapore','mil':'Cusco','cobra':'Columbus','bryant':'Milwaukee','carmen':'Medellín','hope':'Guangzhou','bon funk':'Singapore'}
for t,p in terms.items():
    hits=[]
    for v in V:
        kv=' '+k(v['name'])+' '
        if ' '+t+' ' in kv or (t in('mius','aabbcc','cmyk','borracha','ropewalk','obsidian','longfong','bryant','cobra','tiao') and t in kv):
            hits.append((v['id'],v['name'],v['cat'],v['st'],v['cs'],v['co'],v['aw']))
    print('==',t,'|',p,len(hits));
    same=[h for h in hits if k(p) in k(h[4]) or k(h[4]) in k(p)]
    for h in (same+[h for h in hits if h not in same and h[2]=='bar'])[:7]: print('   ',h,[(a['s'][:12],a['y'],a['r']) for a in aw[h[0]]][-3:])
for n in ['makati','manila','cusco','cuzco','galle','hiriketiya','tainan','penang','george-town','san-jose','kathmandu','phnom-penh','changsha','hangzhou','accra','columbus','milwaukee','skillinge','kobarid','giza','atxondo','axpe','monte-carlo','monaco']:
    print(n,[ (c['id'],c['s'],c['d'],c['co']) for c in C['cities'] if c['s']==n])
print([ (a['a'],cid[a['c']]['s']) for a in C['aliases'] if a['a'] in('cusco','giza','atxondo','skillinge','monte carlo','san jose','galle','makati')])
