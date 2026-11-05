-- load-top-500-bars-2026-2026-11-05.sql
-- CompassEats, Nov 5 2026. Top 500 Bars 2026. Ben Nov 5 17:05 ET "1-7:A". This file runs only after Ben's "go".
-- 500 new award rows, ranks 1-500, source_url = the publisher block page. 45 new venues (all bar, active, published). 2 new cities (Antigua, Katowice).
-- Evidence: top-500-bars-2026-evidence-2026-11-05.csv. No rename, price, address, geo, blurb or status change on a live venue.
-- Expected after: venues 11668 (active 11365, closed 303); awards 28296; slugs 13612; listings 11668; labels 24743; cities 3321, sum 11365; ledger 252 rows; audit_log +762 (126068 rows).
BEGIN;
DO $load$
DECLARE
  nl text := $plan$58|Bar Leone|shanghai|Shanghai|China
90|Cato|london|London|United Kingdom
124|Shakerato|amsterdam|Amsterdam|Netherlands
138|Superfine|paris|Paris|France
144|Advocatuur|amsterdam|Amsterdam|Netherlands
145|Abstract Bistrot|paris|Paris|France
180|Stravinsky Parfumerie|barcelona|Barcelona|Spain
245|Britannia Bar|trondheim|Trondheim|Norway
249|The Carlton Bar|milan|Milan|Italy
258|Press Club|washington-dc|Washington DC|United States
299|Avoca|hong-kong|Hong Kong|Hong Kong
321|Fede Cocktail Lab|florence|Florence|Italy
324|Ulew Cocktail Bar|antigua|Antigua|Guatemala
339|Dutch Courage|amsterdam|Amsterdam|Netherlands
374|Clap|dubai|Dubai|United Arab Emirates
375|Mesures|paris|Paris|France
377|Two Moons|macau|Macau|Macao
378|Shady Pig|bali|Canggu|Indonesia
382|The Waratah|sydney|Sydney|Australia
387|Yoi|kyoto|Kyoto|Japan
388|Subastor|sao-paulo|Sao Paulo|Brazil
391|Domashniy Bar|almaty|Almaty|Kazakhstan
395|Le Churchill|marrakech|Marrakesh|Morocco
405|Morgana Lounge Bar|taormina|Taormina|Italy
406|Netsu|dubai|Dubai|United Arab Emirates
412|5L Speakeasy Bar|sofia|Sofia|Bulgaria
416|Ory|munich|Munich|Germany
417|Antique American Bar|bratislava|Bratislava|Slovakia
419|Speak in Code|manchester|Manchester|United Kingdom
423|Sky Bar & Restaurant|bratislava|Bratislava|Slovakia
425|Everson Royce Bar|los-angeles|Los Angeles|United States
431|Ruggine|bologna|Bologna|Italy
440|Botanical by Alfonse|namur|Namur|Belgium
445|Penicillin|shanghai|Shanghai|China
455|Sartoria|palermo|Palermo|Italy
462|BoB the other side|milan|Milan|Italy
463|Maria Mezcal|lima|Lima|Peru
465|El Koktel|warsaw|Warsaw|Poland
473|Art|katowice|Katowice|Poland
483|Noble Roots|belgrade|Belgrade|Serbia
484|Dragonfly|edinburgh|Edinburgh|United Kingdom
486|Bar Glue|liverpool|Liverpool|United Kingdom
490|Urania|zagreb|Zagreb|Croatia
495|Vibes|nice|Nice|France
498|Nucleo|rome|Rome|Italy$plan$;
  cl text := $plan$antigua|Antigua|Guatemala|GT|1
katowice|Katowice|Poland|PL|1$plan$;
  al text := $plan$1|89e647b929
2|5c7c64ab03
3|a45d654209
4|2d64be2724
5|f666df5301
6|5dde540c28
7|5d717b675f
8|4834f0a15b
9|fde05d62a1
10|01e8f7a7d3
11|be4d971102
12|54866b70a6
13|a4249334e6
14|10788d0e05
15|17d212b769
16|82b44b967f
17|114e7e85f2
18|b031886a48
19|f3bc486ac0
20|bcb4e4b84f
21|7354fda9db
22|1f97b4f29c
23|05b2f7610f
24|bfbc85db67
25|73438bd8cd
26|0421aed12b
27|012855b792
28|846912e3a1
29|8568e9d2e5
30|fec141b0fc
31|b12fffb75f
32|53059d0c81
33|c7a3c0308a
34|df9d307d66
35|74a0eb0cc4
36|ff718d2b90
37|ecbb074260
38|18ae06b942
39|4403c182f4
40|f802b602c1
41|740d862737
42|c76570eed2
43|2786cd9cb9
44|956e6ffb64
45|79140112ef
46|02ebc28502
47|03f9ae3090
48|c9867db238
49|036cb7e5ed
50|c15d0dc615
51|08b99c5d91
52|24dd660df4
53|1fa8307ed2
54|5fffaa9af2
55|52bbfca7eb
56|54a7c89399
57|bbbd76c206
59|ca7462648a
60|3e100d6dc4
61|330958cefd
62|0398aa18f7
63|39e15680eb
64|cdf6da8d11
65|928fd51437
66|6cd9c1b505
67|528bcb4252
68|6a52eabeef
69|1c25b2bb07
70|e9eb241e35
71|42bbe62038
72|40e59554e1
73|1423546ff8
74|264b524873
75|128293c37e
76|835c6082aa
77|1ff0982e3c
78|bd75262274
79|25783f3dc4
80|b3b51b159d
81|88c6365b3e
82|99a978b880
83|3418617247
84|091d79a6f2
85|1936e8ad9f
86|bfce45e8af
87|27493434c0
88|9e292b3ff5
89|e86c58df78
91|9162f49ab7
92|04121927dd
93|5a0c96c3ee
94|77c7853582
95|2a90808d57
96|afa90bcb58
97|357802e073
98|96ab20c41c
99|6723ea2cea
100|a92da40289
101|0a0425ab1b
102|e955672c8f
103|09431b9089
104|d1add621c8
105|e0686a098e
106|0141814b1c
107|4a5e7acb5c
108|96a41b5ec6
109|ad5e94ad80
110|96b45598ae
111|acb8d6ce6c
112|b7731d6c56
113|df00870d8d
114|59d44bb899
115|88a61f19b3
116|f95a7eae43
117|b60abb118f
118|825841b307
119|3503821ac6
120|64f6d69510
121|22e824e70a
122|0afaabd3ce
123|d4713fdf10
125|ee59820013
126|51118f9027
127|b54e968e86
128|818e796590
129|1b64a08928
130|9f786ca890
131|6af8c74bd3
132|3c8603b388
133|5af1a142fe
134|49982aa63d
135|51674838f2
136|64c396cc97
137|afdd93e931
139|9c916f0949
140|c9c25851ed
141|9d7e3e0d94
142|5a10f59276
143|85763dcb0d
146|7eda7ecaa2
147|d8be9c5bb8
148|5bbf5bfa27
149|943a7a1ba2
150|965f32f04d
151|18960e46d6
152|7528a66f9b
153|d046490a61
154|62d3a80d5a
155|b36ed03992
156|d0b6797a9a
157|315505b64f
158|314a4e2d47
159|3e2a8aa427
160|5821e6f420
161|cc76232de7
162|f8b60bb853
163|e7ad405be9
164|1e153f586e
165|2613881bf1
166|e2838a6bf1
167|c65c071897
168|21e55353a7
169|5c115f5da3
170|7d346b7684
171|8aeb44db55
172|f3be5b1735
173|76668adb57
174|1918096a41
175|2b29153019
176|b650f67cca
177|2988652c65
178|f01c7f187a
179|7c8e87c220
181|9246bee346
182|426f79ac2e
183|97098d900b
184|c5a953654f
185|941f41d72b
186|d8a57ae393
187|efef7b9410
188|4d06d43951
189|549052a728
190|da8d395298
191|261395d97c
192|78b2df0a39
193|e60728f652
194|82ad00117c
195|c412b929ae
196|0f9e0a7d0e
197|05e3a1ae2d
198|406641b4c6
199|0a2d39e6bd
200|13098c0869
201|d93d8d6d0f
202|07a347cdb7
203|9f118c39fc
204|570eb26822
205|2c8eb14d3b
206|6131c9eb7e
207|8df8ac22d3
208|070a7decc4
209|bc2b977ab7
210|e002167a67
211|c364550e8b
212|3a8435ad35
213|fa5fc953be
214|5c8b7d69d0
215|db36dd716d
216|9ec8d0e3c9
217|a40d3247d9
218|3f63f68796
219|0403fb1677
220|232cbce8db
221|579265aa74
222|2c999c532c
223|bf9f86c005
224|f7242985ce
225|fdc71eac83
226|fcc9b663a5
227|9ee0da838c
228|fd6d30880f
229|6c4370c6a8
230|03b28fe151
231|cb3cd230b2
232|79d5359761
233|aa449093e9
234|4c0dbcc0c6
235|80496dda8c
236|da8d7efe73
237|915cf83d84
238|5857606ead
239|037c0c1e0c
240|e922b62103
241|d4e7351799
242|d2c1cb7228
243|8efdf81741
244|e1ba80a398
246|93a3963f9d
247|71509290b0
248|dabb8342a6
250|3074dc38e6
251|de378ecdb3
252|dab15a929a
253|f0d3a8ee85
254|fd4e1302bc
255|0552ba91f4
256|5807e401d9
257|efc873f914
259|0c3b941bb9
260|826c297928
261|9b6f7b64f2
262|078cf5c796
263|cb79c0751f
264|67b0edf67d
265|ce8f3ad381
266|608a7bb06a
267|cc9755f309
268|d0c514cd67
269|0b94216775
270|dd64d59972
271|7d58fbced8
272|2dcb0bb68d
273|c0bcf8d709
274|7b6648edd0
275|f79c151601
276|bef43f853a
277|c9b02066a6
278|27e6f36d11
279|418463e608
280|cfe0c5e039
281|b3f2382cb5
282|47c972fb32
283|70d78d31d4
284|5f53bb827b
285|37889ef392
286|200744636d
287|8e0dfc7bba
288|e2d85a0b22
289|fa1773f2f9
290|eb8ec4eb23
291|1bd8d24a78
292|cb42831194
293|d7fb47107b
294|9cdafd245d
295|e8061415fb
296|ccf0b80a21
297|60e8ffc199
298|3154ab0916
300|6670c4bede
301|9d704d0f72
302|eee71c3856
303|a924426e0a
304|5c5403ab08
305|6f0b877a60
306|647df91aa5
307|a0576465a8
308|747cae52d8
309|2d106939fa
310|8fc85ce002
311|3d02bab0b5
312|60f0400918
313|e55771ca10
314|fe0cb79da6
315|086948f186
316|3544ed6cee
317|da1a10b6cb
318|084f959b14
319|7bac3c68f8
320|7035175286
322|d6be15b37d
323|37e2e6b8e7
325|cc4bfd02d9
326|c6367da3c6
327|19f3589a35
328|3a4cc16224
329|fcf88c2ae3
330|a4b17aaf23
331|3ca9cad8b7
332|d6686e448b
333|ac2515e93c
334|0c7f92059b
335|a4e307ad26
336|861fcf255d
337|858b9235c9
338|df1825084a
340|1e8e0f2809
341|22fc005070
342|3df1b0fa85
343|da96fa6ee2
344|3713ed47f6
345|136bc9d089
346|74349d4485
347|79530cadea
348|7476deab7c
349|6282a1b0d0
350|06d30d61f9
351|b4f551bee4
352|b01a93b29e
353|09b69840da
354|e971d33539
355|953b4951da
356|fcbbe94857
357|ee436b23b5
358|269e419f3c
359|0ed32864c0
360|7b1ddd7c98
361|0383463b57
362|012465dd2b
363|0c88b9f57a
364|e9057f267e
365|2d547160d8
366|6177a50e7f
367|4dcdddb39b
368|412c9eeae2
369|91b54ffbe5
370|a5c93351ab
371|98fc69d15a
372|4249f54d54
373|52809f8499
376|3bf95b8a77
379|82eb000e06
380|19ecd3b830
381|947003ef80
383|76024bcb58
384|c869e42840
385|4065bce4d2
386|84449a64ca
389|01598d2686
390|e5fac9252c
392|c41317d511
393|e4c9d46458
394|8d2b36ffe0
396|170ed61fc0
397|d2186520c0
398|d16359a1c2
399|b375d8b43a
400|048a018db9
401|4ab9a6f08e
402|aa7e8e2a22
403|647f6bcaf6
404|367fcd4044
407|3a86d31125
408|57ef0713b5
409|f26eaf4d14
410|54393bdd58
411|5ee4d73a7e
413|56ad6e3295
414|6b410785f7
415|046b5ba9af
418|c75253b519
420|a542bfff02
421|7ae5011bbc
422|475af214b9
424|71eff9c5a1
426|2492107aef
427|baa199026d
428|9d6455abe8
429|2e38c8fac4
430|278e2d6648
432|4942bd061b
433|b834011466
434|57c1a21b09
435|90ba5c99b2
436|45c66b8d89
437|37c7815dd9
438|fc1bc8c4d2
439|c937e34d80
441|c6b90ebdc9
442|b27a885361
443|c054d2d195
444|d71e9ab86c
446|2845fa21b3
447|24f273b619
448|0d6a554162
449|edf86b4152
450|f77c21875a
451|3f7358fd1e
452|0a791e5a9b
453|99ced2f109
454|bb1c65d427
456|7838b37a31
457|b294e1f0aa
458|05e0905338
459|9d7a42beb9
460|8d029668f2
461|d7a3958beb
464|aa97999d76
466|062ae78893
467|ca1582b31c
468|9812f7966f
469|01628a9fb2
470|35b28ed862
471|a512539ec2
472|c281268010
474|579388e6c8
475|36d3e0104b
476|33d1ebb75c
477|97dbf1fe77
478|1ffcac902f
479|05b81445a4
480|a1b2c31972
481|18616a0247
482|2bf502a1d0
485|3f6b53f1d9
487|60f5d02279
488|d4cd1b3fe3
489|b09fdb818a
491|9285a0ea9e
492|8a922f068d
493|d5f67fdd6e
494|a267f95c3b
496|39790c5a55
497|5753ab6302
499|ecd1daeb67
500|d4569d460d$plan$;
  p jsonb; n bigint; s text; fp text; aud_max bigint; first_award bigint;
BEGIN
  -- PRE gates
  IF md5(nl||E'\n#\n'||cl||E'\n#\n'||al) <> '84b16926548c67b911b2031bd00e2136' THEN RAISE EXCEPTION 'plan text'; END IF;
  WITH r AS (SELECT split_part(x,'|',1)::int r, split_part(x,'|',2) name, split_part(x,'|',3) city_slug, split_part(x,'|',4) clab, split_part(x,'|',5) colab FROM regexp_split_to_table(nl,E'\n') x),
       q AS (SELECT r.*, trim(both '-' from regexp_replace(lower(f_unaccent(r.name)),'[^a-z0-9]+','-','g')) slug FROM r),
       w AS (SELECT q.*, 've_'||left(md5(q.city_slug||':'||q.slug),10) id, coalesce(c.id,'ci_'||left(md5(q.city_slug),10)) city_id, c.id IS NULL is_new FROM q LEFT JOIN cities c ON c.slug=q.city_slug),
       ca AS (SELECT split_part(x,'|',1) slug, split_part(x,'|',2) display, split_part(x,'|',3) country, split_part(x,'|',4) country_iso, split_part(x,'|',5)::int venues_count FROM regexp_split_to_table(cl,E'\n') x),
       a0 AS (SELECT split_part(x,'|',1)::int r, 've_'||split_part(x,'|',2) venue_id FROM regexp_split_to_table(al,E'\n') x UNION ALL SELECT r, id FROM w),
       aa AS (SELECT r, venue_id, 'No. '||r category, 'https://www.top500bars.com/'||(CASE WHEN r<=25 THEN '1-25-2026' WHEN r<=50 THEN '26-50-2026' WHEN r<=75 THEN '51-75-2026' WHEN r<=100 THEN '76-100-2026' WHEN r<=150 THEN '150-101-2026' WHEN r<=200 THEN '200-151-2026' WHEN r<=250 THEN 'copie-de-300-251-2026' WHEN r<=300 THEN '300-251-2026' WHEN r<=350 THEN '301-350-2026' WHEN r<=400 THEN '351-400-2026' WHEN r<=450 THEN '401-450-2026' WHEN r<=500 THEN '451-500-2026' END) url FROM a0)
  SELECT jsonb_build_object(
    'new',(SELECT jsonb_agg(jsonb_build_object('id',id,'name',name,'city_id',city_id,'city_slug',city_slug,'slug',slug)) FROM w),
    'aw',(SELECT jsonb_agg(jsonb_build_object('venue_id',venue_id,'rank',r,'category',category,'url',url)) FROM aa),
    'cities',(SELECT jsonb_agg(jsonb_build_object('id','ci_'||left(md5(slug),10),'slug',slug,'display',display,'country',country,'country_iso',country_iso,'venues_count',venues_count)) FROM ca),
    'upd',(SELECT jsonb_agg(jsonb_build_object('id',city_id,'plus',c)) FROM (SELECT city_id, count(*) c FROM w WHERE NOT is_new GROUP BY 1) y),
    'labels',(SELECT jsonb_agg(jsonb_build_object('venue_id',id,'label',l,'col',col)) FROM (SELECT id, clab l, 'city_display' col FROM w UNION ALL SELECT id, colab, 'country' FROM w) y)) INTO p;
  IF (SELECT md5(string_agg(e->>'id',E'\n' ORDER BY e->>'id' COLLATE "C")) FROM jsonb_array_elements(p->'new') e) <> 'afbd6e677ded3b0d5df32155e342a305' THEN RAISE EXCEPTION 'venue ids'; END IF;
  IF (SELECT md5(string_agg(t,E'\n' ORDER BY t COLLATE "C")) FROM (SELECT (e->>'venue_id')||'|'||(e->>'rank')||'|'||(e->>'category')||'|'||(e->>'url') t FROM jsonb_array_elements(p->'aw') e) y) <> '75af058c2f1299ab12f35e209ce50152' THEN RAISE EXCEPTION 'award rows'; END IF;
  SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id, E'\n' ORDER BY v.id COLLATE "C")) INTO fp FROM venues v WHERE v.id IN (SELECT 've_'||split_part(x,'|',2) FROM regexp_split_to_table(al,E'\n') x);
  IF fp IS DISTINCT FROM '2dbf674463e772e07e73fa11291e7b68' THEN RAISE EXCEPTION 'live venue fingerprint %', fp; END IF;
  IF (SELECT count(*) FROM venues) <> 11623 OR (SELECT count(*) FROM venues WHERE status='active') <> 11320 OR (SELECT count(*) FROM venues WHERE status='closed') <> 303 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 27796 OR (SELECT max(id) FROM awards) <> 34967 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards WHERE year=2026 AND source_id='top-500-bars') <> 0 THEN RAISE EXCEPTION '2026 rows exist'; END IF;
  IF (SELECT count(*) FROM award_categories WHERE source_id='top-500-bars' AND category IN (SELECT 'No. '||g FROM generate_series(1,500) g)) <> 500 THEN RAISE EXCEPTION 'categories'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13567 OR (SELECT count(*) FROM listings) <> 11623 OR (SELECT count(*) FROM city_label_source) <> 24653 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 35 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM cities) <> 3319 OR (SELECT sum(venues_count) FROM cities) <> 11320 OR (SELECT count(*) FROM source_capture_ledger) <> 250 THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published before'; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> 125306 OR aud_max <> 131135 THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  SELECT count(*) INTO n FROM jsonb_to_recordset(p->'new') x(id text, name text, slug text, city_slug text) WHERE x.id <> 've_'||left(md5(x.city_slug||':'||x.slug),10) OR trim(both '-' from regexp_replace(lower(f_unaccent(x.name)),'[^a-z0-9]+','-','g')) <> x.slug;
  IF n <> 0 THEN RAISE EXCEPTION 'id or slug rule %', n; END IF;
  SELECT count(*) INTO n FROM jsonb_to_recordset(p->'new') x(id text, name text, slug text, city_slug text, city_id text) WHERE EXISTS (SELECT 1 FROM venues v WHERE v.id=x.id OR (v.city_id=x.city_id AND v.norm_key=norm_key(x.name))) OR EXISTS (SELECT 1 FROM slugs t WHERE t.city_slug=x.city_slug AND t.slug=x.slug);
  IF n <> 0 THEN RAISE EXCEPTION 'venue clash %', n; END IF;
  SELECT count(*) INTO n FROM jsonb_to_recordset(p->'cities') x(id text, slug text) WHERE x.id <> 'ci_'||left(md5(x.slug),10) OR EXISTS (SELECT 1 FROM cities c WHERE c.id=x.id OR c.slug=x.slug) OR EXISTS (SELECT 1 FROM slugs t WHERE t.city_slug=x.slug AND t.is_canonical);
  IF n <> 0 THEN RAISE EXCEPTION 'city clash %', n; END IF;
  IF (SELECT count(*) FROM jsonb_to_recordset(p->'upd') x(id text) JOIN cities c ON c.id=x.id) <> 35 THEN RAISE EXCEPTION 'cities to update'; END IF;
  RAISE NOTICE 'pre gates passed';
  -- WRITE: cities
  INSERT INTO cities (id, slug, display, country, country_iso, kind, region_id, lat, lng, venues_count)
    SELECT x.id, x.slug, x.display, x.country, x.country_iso, 'city'::city_kind, NULL, NULL, NULL, x.venues_count FROM jsonb_to_recordset(p->'cities') x(id text, slug text, display text, country text, country_iso text, venues_count int);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'cities %', n; END IF;
  UPDATE cities c SET venues_count = c.venues_count + x.plus FROM jsonb_to_recordset(p->'upd') x(id text, plus int) WHERE c.id=x.id;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 35 THEN RAISE EXCEPTION 'city counts %', n; END IF;
  -- WRITE: venues, listings, slugs
  INSERT INTO venues (id, name, category, city_id, status) SELECT x.id, x.name, 'bar'::venue_category, x.city_id, 'active'::venue_status FROM jsonb_to_recordset(p->'new') x(id text, name text, city_id text);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 45 THEN RAISE EXCEPTION 'venues %', n; END IF;
  INSERT INTO listings (venue_id, property_id, published) SELECT x.id, 'eats', true FROM jsonb_to_recordset(p->'new') x(id text);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 45 THEN RAISE EXCEPTION 'listings %', n; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) SELECT 'eats', x.city_slug, x.slug, x.id, true FROM jsonb_to_recordset(p->'new') x(id text, city_slug text, slug text);
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 45 THEN RAISE EXCEPTION 'slugs %', n; END IF;
  -- WRITE: city labels, with hand audit rows
  WITH ins AS (INSERT INTO city_label_source (venue_id, label, from_column, publisher, note) SELECT x.venue_id, x.label, x.col::label_column_t, 'top-500-bars', '2026 edition, new venue' FROM jsonb_to_recordset(p->'labels') x(venue_id text, label text, col text) RETURNING *)
    INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', i.id::text, 'INSERT', NULL, to_jsonb(i) FROM ins i;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 90 THEN RAISE EXCEPTION 'labels %', n; END IF;
  -- WRITE: awards
  SELECT max(id) INTO first_award FROM awards;
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
    SELECT x.venue_id, 'top-500-bars', 2026, x.rank, x.category, NULL, x.url FROM jsonb_to_recordset(p->'aw') x(venue_id text, rank int, category text, url text) ORDER BY x.rank;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 500 THEN RAISE EXCEPTION 'awards %', n; END IF;
  -- WRITE: ledger
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('top-500-bars','award',500,'cleanup:load-top-500-bars-2026-2026-11-05 | 2026 edition, ranks 1-500 | https://www.top500bars.com/1-100-2026 | Ben Nov 5 17:05 ET "1-7:A"'),
    ('top-500-bars','city_label',90,'cleanup:load-top-500-bars-2026-2026-11-05 | city labels of 45 new venues; country label from the cities table where the publisher gives a city only | Ben Nov 5 17:05 ET "1-7:A"');
  -- POST gates
  IF (SELECT count(*) FROM venues) <> 11668 OR (SELECT count(*) FROM venues WHERE status='active') <> 11365 OR (SELECT count(*) FROM venues WHERE status='closed') <> 303 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> 28296 OR (SELECT count(*) FROM awards WHERE id > first_award) <> 500 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT md5(string_agg(t,E'\n' ORDER BY t COLLATE "C")) FROM (SELECT venue_id||'|'||rank||'|'||category||'|'||source_url t FROM awards WHERE id > first_award AND year=2026 AND source_id='top-500-bars') y) <> '75af058c2f1299ab12f35e209ce50152' THEN RAISE EXCEPTION 'rows after'; END IF;
  IF (SELECT count(*) FROM awards WHERE year=2026 AND source_id='top-500-bars') <> 500 OR (SELECT count(DISTINCT rank) FROM awards WHERE year=2026 AND source_id='top-500-bars') <> 500 THEN RAISE EXCEPTION 'list counts after'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13612 OR (SELECT count(*) FROM listings) <> 11668 OR (SELECT count(*) FROM city_label_source) <> 24743 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 35 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM cities) <> 3321 OR (SELECT sum(venues_count) FROM cities) <> 11365 THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 252 THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 OR (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'published after'; END IF;
  SELECT count(*) INTO n FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id=v.id AND s.property_id='eats' AND s.is_canonical) <> 1; IF n <> 0 THEN RAISE EXCEPTION 'canonical %', n; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:INSERT=500,cities:INSERT=2,cities:UPDATE=35,city_label_source:INSERT=90,listings:INSERT=45,slugs:INSERT=45,venues:INSERT=45' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$load$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
