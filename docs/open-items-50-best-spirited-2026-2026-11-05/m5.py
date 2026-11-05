import json,re,unicodedata,collections
exec(open('match.py').read().split("res=[]")[0])
R=json.load(open('match1.json'))
new=[('Montana','Hong Kong'),('La Borracha','Accra'),('G.O.D','Bangkok'),('Three Horses','Melbourne'),('Otro Bar','San José'),('Mius','Hong Kong'),('Naked','Athens'),('Bar Gabriel','Istanbul'),('Tiao','Beijing'),('Aqua Bar','Bangkok'),('Problem Child','Makati'),('M+MS Bar','Seoul'),('CMYK','Changsha'),('Pony Up','Shanghai'),('Obsidian Bar','Shenzhen'),('The Spirits Library','Makati'),('Bar Long Fong','Beijing'),('Chimney','Hangzhou'),('Aabbcc','New Delhi'),('Hats Bar','Jakarta'),('The Bar at the Ritz-Carlton Tokyo','Tokyo'),('Between the Sips','Jakarta'),('Cabinet 8','Kuala Lumpur'),('BOP','Singapore'),('Bar Bon Funk','Singapore'),('Cobra','Columbus'),('Bryant’s Cocktail Lounge','Milwaukee')]
BAR={'asia-50-best-bars','worlds-50-best-bars','top-500-bars','north-america-50-best-bars','spirited-awards','europe-50-best-bars'}
matched=set(c[0] for r in R for c in r['cands'] if r['group'] in('exact_city','loose_city','contain_city'))
seen=set()
for n,p in new:
    cs=cityids(p)
    if p in seen: continue
    seen.add(p)
    rows=[]
    for v in V:
        if v['cid'] in cs and v['id'] not in matched:
            h=[a for a in aw[v['id']] if a['s'] in BAR and a['y']>=2022]
            if h or v['cat']=='bar': rows.append((v['id'],v['name'],v['cat'],v['st'],[(a['s'][:9],a['y'],a['r']) for a in h][-2:]))
    print('==',p,[x[0] for x in new if x[1]==p]);
    for x in rows[:30]: print('   ',x)
