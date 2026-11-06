#!/usr/bin/env python3
"""Make pairs.tsv from the list read and the live read. Name key first, then the hand list by card path."""
import re,unicodedata,collections
def key(n):
    s=unicodedata.normalize('NFKD',n.lower());s=''.join(c for c in s if not unicodedata.combining(c));return re.sub(r'[^a-z0-9]+','',s)
live=[]
for l in open('live-read.txt',encoding='utf8').read().split('\n'):
    p=l.split('|');live.append(dict(v=p[0],a=p[1],cat=p[2],city=p[5],name='|'.join(p[10:])))
cards=[]
for l in open('relay-kr-2026-list-pages-2026-11-05.txt',encoding='ascii').read().split('\n'):
    p=l.encode().decode('unicode_escape').encode('latin1','ignore').decode('latin1') if False else l
    x=p.split(' | ');cards.append(dict(cat=x[0],path=x[1].split('/restaurant/')[1],name=re.sub(r'\\u([0-9a-f]{4})',lambda m:chr(int(m.group(1),16)),x[2]),city=x[3].split(',')[0].lower()))
HAND={'kang-minchul-restaurant':'ve_048097aebf','gaggen':'ve_1cc086d414','san':'ve_bc8ab70b1a','restaurant-jueun':'ve_29b1e26fac','collage':'ve_eb42674bb6','eatanic-garden':'ve_2721e3f85e','l-amitie':'ve_2df65d77df','soul-dining':'ve_52cdb713a8','yun':'ve_6ad69f644e','mosu':'ve_409a1b7b21','giwakang':'ve_60883b3d6f','yu-yuan':'ve_0eb99be129','l-amant-secret':'ve_ab8c5b1170',
'andeok':'ve_6e8e63dfdf','mapo-ok':'ve_8972868130','youhan':'ve_e88f43639b','anmok':'ve_b21afea084','songheonjip':'ve_5c2458b538','hapjeongok':'ve_c7bc08d362','3rd-samgyetang':'ve_7df12f5e42','ggupdang':'ve_039aac15f6','limbyungjoo-sandong-kalguksu':'ve_04815c33ca','hapcheon-gukbapjip':'ve_0d9516314c','kyewol-gomtang':'ve_11f6908a41','seokyonanmyunbang':'ve_261ce335c5','hanwolgwan':'ve_2de0f377b9','yukjeon-hoekwan':'ve_3785339543','haemok':'ve_4838a3ba4f','moemiljip':'ve_48830d7142','yakitori-onjung':'ve_4bec88c490','gaeseong-mandu-koong':'ve_7ef4ee5e45','oreno-ramen':'ve_802cd56471','jin-jin':'ve_aa454b8a71','okdongsik':'ve_ae2afe4b27','mandujip':'ve_ee788cda6f','okdol-heyonok':'ve_ef7ebed55a'}
L={l['v']:l for l in live};used={};out=[]
for c in cards:
    if c['path'] in HAND: v=HAND[c['path']];how='hand'
    else:
        m=[l for l in live if key(l['name'])==key(c['name']) and l['city']==c['city']]
        assert len(m)==1,c; v=m[0]['v'];how='same name'
    assert v not in used,c;used[v]=c['path'];l=L[v]
    assert l['cat']==c['cat'] and l['city']==c['city'],(c,l)
    out.append((c['path'],v,l['a'],how))
print('live not paired',[l['name'] for l in live if l['v'] not in used])
print(collections.Counter(o[3] for o in out),len(out))
open('pairs.tsv','w').write('\n'.join('\t'.join(o) for o in out))
for o in out:
    if o[3]=='hand':print(o[0],'<=',L[o[1]]['name'])
