// Group D browser reader. Paste into a guide.michelin.com tab (Chrome connector, javascript_tool), then run:
//   window.readSel('<selection slug>', '<KEY>')   e.g. window.readSel('sweden','SE')
// It reads the Fujian (Jing Li) card label, the 4 tier lists of /us/en/selection/<slug>/restaurants/<tier> (pages until the h1 total),
// then every card, with a 3.5 s pause between requests. Result on window[KEY]: lists, cards, errors, relay (sorted, non-ASCII as \uXXXX), sha (hex bytes joined by ':').
// Relay line: category | href | list name | list city | list price | label year | guide | status | final path | closure note or '-'.
// Poll with a 40-43 s wait per call. Then write window[KEY].relay into <article><pre> and read it with get_page_text.
window.readSel = async function(sel, key){
 const S = window[key] = {sel, started:new Date().toISOString(), lists:{}, cards:[], errors:[], done:false};
 const sleep = ms=>new Promise(r=>setTimeout(r,ms));
 const esc = s=>s.replace(/[^\x00-\x7f]/g, c=>'\\u'+c.charCodeAt(0).toString(16).padStart(4,'0'));
 const tiers=[['3-stars-michelin','Three Stars'],['2-stars-michelin','Two Stars'],['1-star-michelin','One Star'],['bib-gourmand','Bib Gourmand']];
 try{
  const f=await fetch('/us/en/fujian-province/fuzhou_1026814/restaurant/jing-li'); const fh=await f.text();
  S.fujian=[f.status,(new DOMParser().parseFromString(fh,'text/html').querySelector('meta[name=description]')?.content||'').match(/in the (\d{4}) MICHELIN Guide ([^.]*)\./)?.slice(1).join(' '), new Date().toISOString()];
  await sleep(3500);
  const items=[];
  for(const [t,cat] of tiers){
   let page=1,total=null,got=[];
   while(true){
    const url='/us/en/selection/'+sel+'/restaurants/'+t+(page>1?'/page/'+page:'');
    const r=await fetch(url); const h=await r.text(); await sleep(3500);
    if(r.status===404 && /no selected restaurants/i.test(h)){total=0;break;}
    if(r.status!==200){S.errors.push([url,r.status]);break;}
    const doc=new DOMParser().parseFromString(h,'text/html');
    const m=(doc.querySelector('h1')?.textContent||'').match(/of\s+([\d,]+)\s+restaurant/); total=m?+m[1].replace(',',''):0;
    const cs=doc.querySelectorAll('.row.restaurant__list-row.js-restaurant__list_items .card__menu');
    if(!cs.length){S.errors.push([url,'no cards']);break;}
    cs.forEach(c=>{const sc=[...c.querySelectorAll('.card__menu-footer--score')].map(x=>x.textContent.replace(/\s+/g,' ').trim());
      got.push({cat, href:c.querySelector('.card__menu-content--title a')?.getAttribute('href'), name:c.querySelector('.card__menu-content--title')?.textContent.replace(/\s+/g,' ').trim(), loc:sc[0]||'', pr:sc[1]||''});});
    if(got.length>=total) break; page++; if(page>30) break;
   }
   S.lists[cat]=[total,got.length]; items.push(...got);
  }
  for(const it of items){
   let st='ERR',fin='-',lab='-',gd='-',cl='-';
   try{const r=await fetch(it.href); st=String(r.status); fin=new URL(r.url).pathname; const h=await r.text();
    const d=(new DOMParser().parseFromString(h,'text/html').querySelector('meta[name=description]')?.content||'').match(/in the (\d{4}) MICHELIN Guide ([^.]*)\./);
    if(d){lab=d[1];gd=d[2];}
    const cm=h.match(/permanently closed|closed permanently|temporarily closed|has (?:now )?closed/i); if(cm) cl=cm[0];
   }catch(e){S.errors.push([it.href,String(e)]);}
   S.cards.push([it.cat,it.href,it.name,it.loc,it.pr,lab,gd,st,fin,cl].join(' | '));
   await sleep(3500);
  }
  S.lines=S.cards.map(esc).sort(); S.relay=S.lines.join('\n');
  const b=await crypto.subtle.digest('SHA-256',new TextEncoder().encode(S.relay));
  S.sha=[...new Uint8Array(b)].map(x=>x.toString(16).padStart(2,'0')).join(':');
 }catch(e){S.errors.push(String(e));}
 S.done=true; S.ended=new Date().toISOString();
};
