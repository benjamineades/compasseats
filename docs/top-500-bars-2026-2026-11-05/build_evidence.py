import csv,re,unicodedata,hashlib,collections
raw=[l.split('\t') for l in open('top500-2026-raw.tsv',encoding='utf8').read().split('\n')]
live={int(l.split('|')[0]):l.split('|') for l in open('live-read.txt',encoding='utf8').read().split('\n')}
live[478]=['478','1ffcac902f','Gorilas','b','a','thessaloniki','393','']
if 466 in live: pass
new={int(l.split('|')[0]):l.rstrip('\n').split('|') for l in open('plan_new.txt',encoding='utf8')}
assert 478 not in new
plan={int(l.split()[0]):l.split()[1] for l in open('plan_live.txt')}
hand={8:'hand: Hope & Sesame, as Nov 5 decision',11:'hand: The Connaught Bar',66:'hand: Carmen Medellin, as Nov 5 decision',81:'venue name says NYC, city London',170:'venue name says Restaurant, category bar',
 315:'hand: Aman Bar on Aman Venice, category restaurant, holds 2024 and 2025 rows',325:'venue name says Sydney, city Melbourne, holds 2024 and 2025 rows',332:'hand: Alto Rooftop; second Cervia venue ALTO - Ristorante e Cocktail Bar holds 2024 and 2025 rows',
 342:'hand: Stay Gold Flamingo on Stay Gold, as Nov 5 decision',372:"hand: PDT on Please Don't Tell",410:'hand: Eve Bar on Eve Bar Covent Garden',443:'hand: Drinx at Il Gusto di Xinge on Il Gusto di XINGE',466:"hand: Aldea on Carrer de l'Aldea; 50 Best page says Aldea",469:'hand: The Enigma Mansion on Enigma, as Nov 5 decision',478:'hand: Gorilla on Gorilas; 50 Best says Gorilla, guides say Gorilas',494:'hand: Umi, category restaurant, publisher link umi.bar',72:'status closed: fire, no reopening this year',294:'status closed: left Soho Feb 2026, Dalston move announced; recheck',168:'venue name is an address',5:'publisher place says Line; site lineathens.gr'}
def key(s):
    s=unicodedata.normalize('NFKD',s.lower());s=''.join(c for c in s if not unicodedata.combining(c)).replace('&',' and ')
    return re.sub(r'[^a-z0-9]+','',s)
PG=[(25,'1-25-2026'),(50,'26-50-2026'),(75,'51-75-2026'),(100,'76-100-2026'),(150,'150-101-2026'),(200,'200-151-2026'),(250,'copie-de-300-251-2026'),(300,'300-251-2026'),(350,'301-350-2026'),(400,'351-400-2026'),(450,'401-450-2026'),(500,'451-500-2026')]
def page(r):
    for h,p in PG:
        if r<=h: return p
rows=[];c=collections.Counter()
for x in raw:
    r=int(x[0]);nm,pl,co,_,web=x[1],x[2],x[3],x[4],x[5]
    if r in new:
        n=new[r];m={'rank':r,'publisher_name':nm,'publisher_place':pl,'publisher_country':co,'publisher_link':web,'group':'new venue','venue_id':'','live_name':n[1],'category':'bar','status':'active (new)','city_slug':n[2],'rank_2025':'','rank_2024':''}
        c['new']+=1
    else:
        l=live[r];assert l[1]==plan[r],r
        same=key(nm)==key(l[2]);g='same name' if same else 'name differs'
        m={'rank':r,'publisher_name':nm,'publisher_place':pl,'publisher_country':co,'publisher_link':web,'group':g,'venue_id':'ve_'+l[1],'live_name':l[2],'category':{'b':'bar','r':'restaurant'}[l[3]],'status':{'a':'active','c':'closed'}[l[4]],'city_slug':l[5],'rank_2025':l[6],'rank_2024':l[7]}
        c[g]+=1
        if l[6]: c['with2025']+=1
        if l[7]: c['with2024']+=1
        if not l[6] and not l[7]: c['noprior']+=1
    m['note']=hand.get(r,'');m['source_url']='https://www.top500bars.com/'+page(r)
    rows.append(m)
with open('top-500-bars-2026-evidence-2026-11-05.csv','w',newline='',encoding='utf8') as f:
    w=csv.DictWriter(f,fieldnames=list(rows[0]));w.writeheader();w.writerows(rows)
print(c,len(rows))
d=hashlib.sha256(open('top-500-bars-2026-evidence-2026-11-05.csv','rb').read()).hexdigest();print(d)
print('blocks new',collections.Counter((int(m['rank'])-1)//100 for m in rows if m['group']=='new venue'))
print('differs top', [ (m['rank'],m['publisher_name'],m['live_name']) for m in rows if m['group']=='name differs'][:10])
E=None
