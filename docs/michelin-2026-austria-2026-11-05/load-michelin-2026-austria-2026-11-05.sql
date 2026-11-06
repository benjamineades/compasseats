-- load-michelin-2026-austria-2026-11-05.sql
-- CompassEats, Nov 5 2026. Michelin Austria: the 2026 label. DRAFT, choices not yet given. This file runs only after Ben's "go".
-- Rule 2.1.1 and 2.1.7: the legacy rows hold the 2026 edition (selection Mar 18, 2026: https://guide.michelin.com/at/en/article/michelin-guide-ceremony/all-starred-restaurants---michelin-guide-austria-2026). Relabel 156 rows 2025 -> 2026, source_url = the card (/us/en/), the star article for 5897. Retire 0.
-- 2 sourced 2025 Bib rows (5898, 5938, URL = the 2025 Bib article) stay as 2025 history.
-- 5 new rows, year 2026: One Star TIAN, One Star Kirchenwirt (Leogang), One Star Thaller - Restaurant (new venue), Bib Wörgötter - Wirtshaus, all with the card URL. Bib Schlosskeller Wirtshaus, no URL (card gone).
-- 2 venues to closed, published false: Schlosskeller Südsteiermark, Schlosskeller Wirtshaus. Own site: "Restaurantbetrieb wurde mit 19. Oktober 2026 eingestellt" (https://www.schlosskellersuedsteiermark.at/).
-- Source: docs/michelin-2026-austria-2026-11-05/relay-at-2026-list-pages-2026-11-05.txt sha256 a7a3ea3d880885565f1865c38e9fa15edd5029b329114e3396e31cc5f21b0c80.
-- OPUS (Vienna): on the star article, card 404 on Nov 5. No venue, no row in this file.
-- No rename, price, address, geo or blurb change.
-- Expected after: venues 11674 (active 11369, closed 305); awards 28373; slugs 13618; listings 11674; labels 24755; cities 3321, sum 11369; ledger 261 rows; Michelin 2025/2026/2027 4596/6931/122; audit_log +172.
BEGIN;
DO $load$
DECLARE
  rl text := $plan$1319|ve_dff12a59f8|Three Stars|https://guide.michelin.com/us/en/vienna/wien/restaurant/amador
1333|ve_ca840dae3d|Three Stars|https://guide.michelin.com/us/en/vienna/wien/restaurant/steirereck-im-stadtpark
1895|ve_40d28061c5|Two Stars|https://guide.michelin.com/us/en/steiermark/ehrenhausen_1039101/restaurant/die-weinbank-restaurant
1975|ve_514ac623be|Two Stars|https://guide.michelin.com/us/en/salzburg-region/golling-an-der-salzach_1039956/restaurant/dollerer
1986|ve_48bc0f3eaa|Two Stars|https://guide.michelin.com/us/en/tirol/hall-in-tirol_1040546/restaurant/schwarzer-adler-109176
2118|ve_c4d60aaaa2|Two Stars|https://guide.michelin.com/us/en/tirol/ischgl_1041328/restaurant/stuva-104899
2252|ve_1df7f717c0|Two Stars|https://guide.michelin.com/us/en/vorarlberg/lech-am-arlberg_7770322/restaurant/griggeler-stuba
2255|ve_05df6b956a|Two Stars|https://guide.michelin.com/us/en/vorarlberg/lech-am-arlberg_7770322/restaurant/rote-wand-chef-s-table
2477|ve_416af087fb|Two Stars|https://guide.michelin.com/us/en/niederosterreich/mautern-an-der-donau_1050463/restaurant/landhaus-bacher
2486|ve_fb6905ec77|Two Stars|https://guide.michelin.com/us/en/tirol/mieming_7770405/restaurant/restaurant-141-by-joachim-jaud
2577|ve_c82967b28d|Two Stars|https://guide.michelin.com/us/en/oberosterreich/neufelden_1043292/restaurant/ois
2951|ve_9da2eae87f|Two Stars|https://guide.michelin.com/us/en/salzburg-region/salzburg/restaurant/ikarus
2962|ve_14069684ad|Two Stars|https://guide.michelin.com/us/en/salzburg-region/salzburg/restaurant/senns-restaurant
3017|ve_bd408ea3c3|Two Stars|https://guide.michelin.com/us/en/tirol/sankt-anton-am-arlberg_1045218/restaurant/gourmetrestaurant-tannenhof
3024|ve_20184d6a58|Two Stars|https://guide.michelin.com/us/en/salzburg-region/sankt-veit-im-pongau_1045495/restaurant/krauterreich-by-vitus-winkler
3039|ve_14c14db60c|Two Stars|https://guide.michelin.com/us/en/burgenland/schutzen-am-gebirge_1051731/restaurant/taubenkobel
3478|ve_d159fc215c|Two Stars|https://guide.michelin.com/us/en/vienna/wien/restaurant/doubek
3483|ve_acf6983c74|Two Stars|https://guide.michelin.com/us/en/vienna/wien/restaurant/konstantin-filippou
3494|ve_e3413976b4|Two Stars|https://guide.michelin.com/us/en/vienna/wien/restaurant/mraz-sohn
3511|ve_2c5398e744|Two Stars|https://guide.michelin.com/us/en/vienna/wien/restaurant/silvio-nickol-gourmet-restaurant
3556|ve_9c1d9ed48f|Two Stars|https://guide.michelin.com/us/en/salzburg-region/werfen_1047689/restaurant/obauer
3619|ve_b08abac8f4|One Star|https://guide.michelin.com/us/en/tirol/achenkirch_1037662/restaurant/grundler-s-gourmet-stuberl
3654|ve_c728eb0883|One Star|https://guide.michelin.com/us/en/steiermark/altaussee_1037837/restaurant/geiger-alm
3871|ve_2dcbdc3574|One Star|https://guide.michelin.com/us/en/steiermark/bad-gleichenberg_1038211/restaurant/geschwister-rauch-restaurant
4993|ve_c988d005ee|One Star|https://guide.michelin.com/us/en/steiermark/fehring_1039353/restaurant/lilli-fine-dining
4999|ve_ea2936e055|One Star|https://guide.michelin.com/us/en/niederosterreich/feuersbrunn_1048933/restaurant/morwald-%E2%80%9Etoni-m-%E2%80%9C
5005|ve_fe72a55b3c|One Star|https://guide.michelin.com/us/en/tirol/fiss_1039458/restaurant/beef-club
5007|ve_e841e49aae|One Star|https://guide.michelin.com/us/en/tirol/fiss_1039458/restaurant/bruderherz-fine-dine
5110|ve_a7c0633855|One Star|https://guide.michelin.com/us/en/steiermark/gamlitz_1039719/restaurant/sattlerhof
5191|ve_020200b069|One Star|https://guide.michelin.com/us/en/karnten/grafenstein_1040018/restaurant/moritz-1212679
5200|ve_8b8e5eb04e|One Star|https://guide.michelin.com/us/en/steiermark/seiersberg_1045978/restaurant/artis-1212496
5201|ve_919a374540|One Star|https://guide.michelin.com/us/en/steiermark/seiersberg_1045978/restaurant/geniesserei-am-markt-steiermark-t-dinner-by-alexander-posch
5202|ve_a73c1a7ac2|One Star|https://guide.michelin.com/us/en/steiermark/seiersberg_1045978/restaurant/zur-goldenen-birn
5209|ve_20fd06fdc8|One Star|https://guide.michelin.com/us/en/oberosterreich/grieskirchen_1040098/restaurant/waldschanke-104685
5218|ve_ba96f056e4|One Star|https://guide.michelin.com/us/en/oberosterreich/grossraming_1040162/restaurant/rau-nature-based-cuisine
5248|ve_b9fa546726|One Star|https://guide.michelin.com/us/en/niederosterreich/hadersdorf-am-kamp_1049409/restaurant/esslokal
5369|ve_f7214874da|One Star|https://guide.michelin.com/us/en/vorarlberg/hirschegg/restaurant/kilian-stuba
5622|ve_553babaed0|One Star|https://guide.michelin.com/us/en/tirol/innervillgraten_1041303/restaurant/gannerhof
5624|ve_a3d506a9e2|One Star|https://guide.michelin.com/us/en/tirol/ischgl_1041328/restaurant/paznaunerstube
5627|ve_5f73c18166|One Star|https://guide.michelin.com/us/en/tirol/ischgl_1041328/restaurant/schlossherrnstube
5686|ve_7718a4f807|One Star|https://guide.michelin.com/us/en/niederosterreich/kirchberg-am-wechsel_1049902/restaurant/gaumenkitzel
5691|ve_04f7b3d9e9|One Star|https://guide.michelin.com/us/en/tirol/kitzbuhel_1041658/restaurant/les-deux-kitzbuhel-brasserie-bar
5823|ve_dedb6a516b|One Star|https://guide.michelin.com/us/en/burgenland/konigsdorf_1050155/restaurant/am-mahrbach
5866|ve_cfef9f87e2|One Star|https://guide.michelin.com/us/en/niederosterreich/langenlois_1050200/restaurant/heurigenhof-brundlmayer
5880|ve_2c47b53bde|One Star|https://guide.michelin.com/us/en/vorarlberg/lauterach_1042285/restaurant/guth
5890|ve_35197980cb|One Star|https://guide.michelin.com/us/en/vorarlberg/lech-am-arlberg_7770322/restaurant/la-fenice-1212360
5897|ve_fb7dc1ff33|One Star|https://guide.michelin.com/at/en/article/michelin-guide-ceremony/all-starred-restaurants---michelin-guide-austria-2026
5915|ve_aa667e9089|One Star|https://guide.michelin.com/us/en/salzburg-region/leogang_1042392/restaurant/dahoam-by-andreas-herbst
5927|ve_f42b1927e5|One Star|https://guide.michelin.com/us/en/steiermark/leutschach-an-der-weinstra%C3%9Fe_7770345/restaurant/lieperts
5933|ve_3fd7d3ec02|One Star|https://guide.michelin.com/us/en/tirol/lienz_1042466/restaurant/ansitz-12
5937|ve_9acf561dcf|One Star|https://guide.michelin.com/us/en/steiermark/ligist_1042478/restaurant/worgotter-fine-dining
5954|ve_796b20bc8e|One Star|https://guide.michelin.com/us/en/oberosterreich/leonding_1042394/restaurant/kliemstein-vino-vitis
5955|ve_501866509c|One Star|https://guide.michelin.com/us/en/oberosterreich/leonding_1042394/restaurant/rossbarth
5956|ve_29b8c87571|One Star|https://guide.michelin.com/us/en/oberosterreich/leonding_1042394/restaurant/verdi
5989|ve_552d769ad5|One Star|https://guide.michelin.com/us/en/vorarlberg/lochau_1042543/restaurant/mangold
6413|ve_03dda05136|One Star|https://guide.michelin.com/us/en/salzburg-region/maria-alm-am-steinernen-meer_1042713/restaurant/rar-fine-dining
6414|ve_ba35a32755|One Star|https://guide.michelin.com/us/en/karnten/maria-worth_1042729/restaurant/hubert-wallner
6447|ve_7eca949360|One Star|https://guide.michelin.com/us/en/salzburg-region/mauterndorf_1042793/restaurant/mesnerhaus
6726|ve_6a6892f0f6|One Star|https://guide.michelin.com/us/en/tirol/nauders_1043212/restaurant/s-kammerli
6736|ve_54371eca36|One Star|https://guide.michelin.com/us/en/tirol/neustift-im-stubaital_1043356/restaurant/hubertusstube
6976|ve_659f81b68a|One Star|https://guide.michelin.com/us/en/tirol/obergurlg_7770324/restaurant/austria-stuben
7021|ve_b36a1f3bde|One Star|https://guide.michelin.com/us/en/oberosterreich/ort-im-innkreis_1043979/restaurant/kammer5
7542|ve_729ed76107|One Star|https://guide.michelin.com/us/en/karnten/rennweg-am-katschberg_1044891/restaurant/gamskogelhutte-fine-dining-by-stefan-lastin
7726|ve_80e4f50060|One Star|https://guide.michelin.com/us/en/salzburg-region/salzburg/restaurant/esszimmer
7728|ve_81f500aab7|One Star|https://guide.michelin.com/us/en/salzburg-region/salzburg/restaurant/pfefferschiff
7730|ve_81914eba0d|One Star|https://guide.michelin.com/us/en/salzburg-region/salzburg/restaurant/the-glass-garden
7829|ve_d899c9fd11|One Star|https://guide.michelin.com/us/en/steiermark/sankt-andra-im-sausal_1045211/restaurant/harald-irka-am-pfarrhof-fine-dine
7830|ve_fdeca5ad67|One Star|https://guide.michelin.com/us/en/tirol/sankt-anton-am-arlberg_1045218/restaurant/alpin-gourmet-stube
7832|ve_e2777cbdc0|One Star|https://guide.michelin.com/us/en/tirol/sankt-anton-am-arlberg_1045218/restaurant/ullrs-gourmetstube
7836|ve_f76a89cd97|One Star|https://guide.michelin.com/us/en/salzburg-region/sankt-gilgen_1045272/restaurant/atelier-fischer
7840|ve_707b16ee30|One Star|https://guide.michelin.com/us/en/steiermark/sankt-joseph_7770382/restaurant/broadmoar
7841|ve_cd944f8fec|One Star|https://guide.michelin.com/us/en/steiermark/sankt-kathrein-am-offenegg_1045314/restaurant/zeitraum
7844|ve_58bf6630bc|One Star|https://guide.michelin.com/us/en/oberosterreich/sankt-wolfgang-im-salzkammergut_1045504/restaurant/paula
7907|ve_26e4daa81e|One Star|https://guide.michelin.com/us/en/oberosterreich/scharding_1045861/restaurant/lukas-restaurant
8281|ve_181db728e7|One Star|https://guide.michelin.com/us/en/oberosterreich/steyr_1046382/restaurant/lukas-kapeller
8312|ve_0cfb53de38|One Star|https://guide.michelin.com/us/en/steiermark/straden_1046422/restaurant/saziani
8321|ve_084f389fc1|One Star|https://guide.michelin.com/us/en/tirol/stumm_1046484/restaurant/guat-z-essen
8381|ve_9cc44ba52f|One Star|https://guide.michelin.com/us/en/tirol/solden_1046538/restaurant/otztaler-stube
8450|ve_5d73adf691|One Star|https://guide.michelin.com/us/en/tirol/telfs_1046604/restaurant/interalpen-chef-s-table
8729|ve_75b0e78fde|One Star|https://guide.michelin.com/us/en/oberosterreich/traunkirchen_1046777/restaurant/bootshaus-1212990
8765|ve_5c37dd4f68|One Star|https://guide.michelin.com/us/en/tirol/tux_7770294/restaurant/bergfried-chefs-table
8895|ve_c9f3675ecd|One Star|https://guide.michelin.com/us/en/vienna/wien/restaurant/aend
8899|ve_13fece5602|One Star|https://guide.michelin.com/us/en/vienna/wien/restaurant/addiert
8900|ve_3d97e80f27|One Star|https://guide.michelin.com/us/en/vienna/wien/restaurant/apron
8902|ve_5e3b1bb227|One Star|https://guide.michelin.com/us/en/vienna/wien/restaurant/edvard
8904|ve_112c10789b|One Star|https://guide.michelin.com/us/en/vienna/wien/restaurant/esszimmer-everybody-s-darling
8905|ve_c544a8185e|One Star|https://guide.michelin.com/us/en/vienna/wien/restaurant/glasswing
8906|ve_ed9b16c3e0|One Star|https://guide.michelin.com/us/en/vienna/wien/restaurant/herzig
8909|ve_6e8bd090c8|One Star|https://guide.michelin.com/us/en/vienna/wien/restaurant/jola
8910|ve_4af0c24032|One Star|https://guide.michelin.com/us/en/vienna/wien/restaurant/pramerl-the-wolf
8913|ve_4ab8f316e7|One Star|https://guide.michelin.com/us/en/vienna/wien/restaurant/z-som
8948|ve_315e62ed13|One Star|https://guide.michelin.com/us/en/oberosterreich/vorchdorf_1047329/restaurant/tanglberg
8960|ve_ae7ae1c431|One Star|https://guide.michelin.com/us/en/niederosterreich/waidhofen-an-der-thaya_1052291/restaurant/zimmerl
9041|ve_0c96433ef6|One Star|https://guide.michelin.com/us/en/karnten/weissensee_1047660/restaurant/die-forelle
9044|ve_66510fec11|One Star|https://guide.michelin.com/us/en/karnten/weissensee_1047660/restaurant/rouge-noir
9103|ve_d38dd14d87|One Star|https://guide.michelin.com/us/en/niederosterreich/zau%C3%9Fenberg_7770379/restaurant/himmelreich
9209|ve_a94f2f6ed8|Bib Gourmand|https://guide.michelin.com/us/en/tirol/achenkirch_1037662/restaurant/grundler-s-geniesser-wirtshaus
9278|ve_44ab9a320b|Bib Gourmand|https://guide.michelin.com/us/en/tirol/anras_1037957/restaurant/das-pfleger
9283|ve_901e3be188|Bib Gourmand|https://guide.michelin.com/us/en/burgenland/apetlon_1048328/restaurant/zum-frohlichen-arbeiter
9533|ve_3bafd1da29|Bib Gourmand|https://guide.michelin.com/us/en/vorarlberg/bizau_1038405/restaurant/schwanen-106612
9581|ve_6b7df4f801|Bib Gourmand|https://guide.michelin.com/us/en/vorarlberg/brand_1038454/restaurant/gufer-55
10181|ve_e1b5bc689c|Bib Gourmand|https://guide.michelin.com/us/en/steiermark/fehring_1039353/restaurant/malerwinkl
10245|ve_1b7db18667|Bib Gourmand|https://guide.michelin.com/us/en/steiermark/gamlitz_1039719/restaurant/weinkehr
10317|ve_e1a2e58e03|Bib Gourmand|https://guide.michelin.com/us/en/niederosterreich/grafenegg_1049167/restaurant/morwald-grafenegg-restaurant
10320|ve_c3c38e40d2|Bib Gourmand|https://guide.michelin.com/us/en/steiermark/seiersberg_1045978/restaurant/mohrenwirt
10321|ve_671f46b224|Bib Gourmand|https://guide.michelin.com/us/en/steiermark/seiersberg_1045978/restaurant/rauch-rebe
10374|ve_58e42a71d9|Bib Gourmand|https://guide.michelin.com/us/en/tirol/hall-in-tirol_1040546/restaurant/secco
10445|ve_168cf55411|Bib Gourmand|https://guide.michelin.com/us/en/niederosterreich/haslau-an-der-donau_1049496/restaurant/haslauerhof
10475|ve_3a39dab240|Bib Gourmand|https://guide.michelin.com/us/en/vorarlberg/hirschegg/restaurant/carnozet
10476|ve_0585a7da42|Bib Gourmand|https://guide.michelin.com/us/en/vorarlberg/hittisau_1040905/restaurant/ernele
10477|ve_8f7008ae11|Bib Gourmand|https://guide.michelin.com/us/en/vorarlberg/hittisau_1040905/restaurant/krone-1212356
10518|ve_8b55a3640e|Bib Gourmand|https://guide.michelin.com/us/en/niederosterreich/hofamt-priel_7770374/restaurant/landgasthof-hinterleithner
10650|ve_eb9cd42125|Bib Gourmand|https://guide.michelin.com/us/en/vorarlberg/innerbraz_1041279/restaurant/gasthof-rossle
10745|ve_f1f24a63f1|Bib Gourmand|https://guide.michelin.com/us/en/niederosterreich/kirchberg-am-wechsel_1049902/restaurant/wirtshaus-molzbachhof
10748|ve_42a0cbebc6|Bib Gourmand|https://guide.michelin.com/us/en/tirol/kitzbuhel_1041658/restaurant/mocking-das-wirtshaus
10749|ve_c63263d954|Bib Gourmand|https://guide.michelin.com/us/en/steiermark/kitzeck-im-sausal_1041659/restaurant/wirtshaus-im-weinkitz
10862|ve_e95baddee4|Bib Gourmand|https://guide.michelin.com/us/en/niederosterreich/langenlebarn-oberaigen_1050199/restaurant/floh
10864|ve_b753c165c3|Bib Gourmand|https://guide.michelin.com/us/en/steiermark/langenwang_1042222/restaurant/wirtshaus-krainer
10909|ve_63937f9a7a|Bib Gourmand|https://guide.michelin.com/us/en/oberosterreich/lichtenberg_1042431/restaurant/der-holzpoldl
11041|ve_1677c64207|Bib Gourmand|https://guide.michelin.com/us/en/vorarlberg/lustenau_1042601/restaurant/freigeist
11145|ve_8ee67abacb|Bib Gourmand|https://guide.michelin.com/us/en/tirol/matrei-in-osttirol_1042760/restaurant/saluti
11256|ve_a7f5405a52|Bib Gourmand|https://guide.michelin.com/us/en/steiermark/murau_1043059/restaurant/lercher-s-wirtshaus
11327|ve_e0a988fe42|Bib Gourmand|https://guide.michelin.com/us/en/steiermark/neuberg-an-der-murz_1043248/restaurant/gasthof-schaffer
11486|ve_e043f5df5f|Bib Gourmand|https://guide.michelin.com/us/en/niederosterreich/oberrohrbach_1050877/restaurant/goldenes-brundl
11489|ve_443fc3d230|Bib Gourmand|https://guide.michelin.com/us/en/tirol/obertilliach_1043879/restaurant/scherer
11659|ve_2aff5894da|Bib Gourmand|https://guide.michelin.com/us/en/oberosterreich/pfaffing_1044181/restaurant/die-schmiede
11757|ve_a77ecd83a7|Bib Gourmand|https://guide.michelin.com/us/en/burgenland/purbach-am-neusiedler-see_1051160/restaurant/fossil
11879|ve_a26077c5be|Bib Gourmand|https://guide.michelin.com/us/en/burgenland/rust_1051454/restaurant/kirchenwirt-105648
11934|ve_4845e4eb8e|Bib Gourmand|https://guide.michelin.com/us/en/salzburg-region/salzburg/restaurant/brandstatter
12004|ve_30b3753169|Bib Gourmand|https://guide.michelin.com/us/en/niederosterreich/sankt-georgen-an-der-leys_1051508/restaurant/hueber-der-wirt-in-brundl
12005|ve_282c67ef46|Bib Gourmand|https://guide.michelin.com/us/en/steiermark/sankt-martin-am-grimming_1045382/restaurant/wirtshaus-im-dorfhotel-mayer
12007|ve_a70fd42717|Bib Gourmand|https://guide.michelin.com/us/en/steiermark/sankt-veit-am-vogau_1045490/restaurant/thaller-gasthaus
12008|ve_9bbb039a7a|Bib Gourmand|https://guide.michelin.com/us/en/salzburg-region/sankt-veit-im-pongau_1045495/restaurant/wirtshaus-by-vitus-winkler
12057|ve_56642edf5a|Bib Gourmand|https://guide.michelin.com/us/en/vorarlberg/schwarzenberg_1045819/restaurant/gasthof-adler-105914
12166|ve_407708371a|Bib Gourmand|https://guide.michelin.com/us/en/niederosterreich/siegersdorf_1051781/restaurant/das-markthof
12305|ve_fabac56e48|Bib Gourmand|https://guide.michelin.com/us/en/steiermark/straden_1046422/restaurant/krispels-genusstheater
12543|ve_04db6af961|Bib Gourmand|https://guide.michelin.com/us/en/salzburg-region/taxenbach_1046589/restaurant/taxenbacherhof
12745|ve_9d272cf447|Bib Gourmand|https://guide.michelin.com/us/en/niederosterreich/tulln-an-der-donau_1052117/restaurant/sodoma
12827|ve_c3d8648ab6|Bib Gourmand|https://guide.michelin.com/us/en/vienna/wien/restaurant/chez-bernard
12828|ve_cb2b06b783|Bib Gourmand|https://guide.michelin.com/us/en/vienna/wien/restaurant/tante-liesl
12829|ve_e1fe265f0f|Bib Gourmand|https://guide.michelin.com/us/en/vienna/wien/restaurant/lola-1201445
12830|ve_e2993571f3|Bib Gourmand|https://guide.michelin.com/us/en/vienna/wien/restaurant/mast-weinbistro
12831|ve_d1400c0a21|Bib Gourmand|https://guide.michelin.com/us/en/vienna/wien/restaurant/meierei-im-stadtpark
12832|ve_2b7584aa96|Bib Gourmand|https://guide.michelin.com/us/en/vienna/wien/restaurant/mochi
12833|ve_6b991beb09|Bib Gourmand|https://guide.michelin.com/us/en/vienna/wien/restaurant/rosi-1216730
12834|ve_f09cd919e1|Bib Gourmand|https://guide.michelin.com/us/en/vienna/wien/restaurant/tian-bistro-am-spittelberg
12875|ve_94da227c08|Bib Gourmand|https://guide.michelin.com/us/en/niederosterreich/wilfersdorf_1052491/restaurant/schlosskuche-walpersdorf-blauenstein
12920|ve_c8bef9b8e5|Bib Gourmand|https://guide.michelin.com/us/en/niederosterreich/weissenkirchen-in-der-wachau_1052422/restaurant/jamek
12921|ve_f59540f8bc|Bib Gourmand|https://guide.michelin.com/us/en/niederosterreich/weissenkirchen-in-der-wachau_1052422/restaurant/prandtauerhof-gutshofrestaurant
12937|ve_e2a33c72d7|Bib Gourmand|https://guide.michelin.com/us/en/burgenland/weppersdorf_1052430/restaurant/gasthaus-fuchs
12943|ve_212774e992|Bib Gourmand|https://guide.michelin.com/us/en/tirol/westendorf_1047700/restaurant/gasthaus-steinberg
12950|ve_4b6699d829|Bib Gourmand|https://guide.michelin.com/us/en/burgenland/wimpassing-an-der-leitha_7770383/restaurant/ziegelwerk-gasthaus
12958|ve_53c64ac2bd|Bib Gourmand|https://guide.michelin.com/us/en/niederosterreich/winzendorf_1052540/restaurant/puchegger-wirt
13030|ve_385b9ff1fc|Bib Gourmand|https://guide.michelin.com/us/en/tirol/zoblen_1048140/restaurant/s-morent
21840|ve_5b3af84920|Bib Gourmand|https://guide.michelin.com/us/en/steiermark/turnau_1046853/restaurant/wirtshaus-steirereck-am-pogusch
21846|ve_6a9f7f565e|One Star|https://guide.michelin.com/us/en/tirol/tux_7770294/restaurant/die-geniesserstube-im-alpenhof$plan$;
  aw text := $plan$ve_110e46ef2f|One Star|https://guide.michelin.com/us/en/steiermark/sankt-veit-am-vogau_1045490/restaurant/thaller-restaurant
ve_3019edc0d9|Bib Gourmand|https://guide.michelin.com/us/en/steiermark/ligist_1042478/restaurant/worgotter-wirtshaus
ve_408dd2d0e2|One Star|https://guide.michelin.com/us/en/salzburg-region/leogang_1042392/restaurant/kirchenwirt
ve_d3fd2ae165|Bib Gourmand|
ve_ef06954a85|One Star|https://guide.michelin.com/us/en/vienna/wien/restaurant/tian$plan$;
  nw text := $plan$ve_110e46ef2f|thaller-restaurant|sankt-veit-am-vogau|ci_1dd325947d|Sankt Veit am Vogau|Thaller - Restaurant$plan$;
  cl text := $plan$ve_fb7dc1ff33|Schlosskeller Südsteiermark|active|ci_f957c08967
ve_d3fd2ae165|Schlosskeller Wirtshaus|active|ci_f957c08967$plan$;
  n bigint; s text; fp text; aud_max bigint; first_award bigint;
BEGIN
  -- PRE gates
  IF md5(rl) <> '0087cfdcb4332ce5d9ef5a97d0aadb1e' OR md5(aw) <> 'f53dccd388ecc506bba0e73b0c0b6fb2' OR md5(nw) <> 'ca8b6163b192bd9014849b5985c07df9' OR md5(cl) <> 'aee815dedbfee255c63bacac8825160b' THEN RAISE EXCEPTION 'plan text'; END IF;
  SELECT md5(string_agg(t, E'\n' ORDER BY t COLLATE "C")) INTO fp FROM (
    SELECT a.id||'|'||v.id||'|'||a.category||'|'||v.status||'|'||v.city_id||'|'||v.name t
    FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id
    WHERE a.source_id='michelin' AND c.country='Austria' AND a.year=2025 AND a.source_url IS NULL AND a.rank IS NULL AND a.distinction IS NULL) y;
  IF fp IS DISTINCT FROM '46c427f16c2d05bcac2106942aa3c01f' THEN RAISE EXCEPTION 'relabel fingerprint %', fp; END IF;
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Austria') <> 158 THEN RAISE EXCEPTION 'Austria Michelin rows'; END IF;
  IF (SELECT count(*) FROM venues) <> 11673 OR (SELECT count(*) FROM venues WHERE status='active') <> 11370 OR (SELECT count(*) FROM venues WHERE status='closed') <> 303 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 28368 OR (SELECT max(id) FROM awards) <> 35539 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> 4752 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 6770 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> 122 THEN RAISE EXCEPTION 'Michelin before'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13617 OR (SELECT count(*) FROM listings) <> 11673 OR (SELECT count(*) FROM city_label_source) <> 24753 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 35 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM cities) <> 3321 OR (SELECT sum(venues_count) FROM cities) <> 11370 OR (SELECT count(*) FROM source_capture_ledger) <> 258 OR (SELECT max(id) FROM source_capture_ledger) <> 312 THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published before'; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> 126413 OR aud_max <> 132242 THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  -- Plan rows against live rows
  SELECT count(*) INTO n FROM regexp_split_to_table(rl,E'\n') x LEFT JOIN awards a ON a.id=split_part(x,'|',1)::bigint
    WHERE a.id IS NULL OR a.venue_id<>split_part(x,'|',2) OR a.category<>split_part(x,'|',3) OR a.year<>2025 OR a.source_id<>'michelin' OR a.source_url IS NOT NULL;
  IF n <> 0 THEN RAISE EXCEPTION 'relabel rows %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(aw,E'\n') x WHERE split_part(x,'|',1) NOT IN (SELECT split_part(y,'|',1) FROM regexp_split_to_table(nw,E'\n') y) AND NOT EXISTS (SELECT 1 FROM venues v WHERE v.id=split_part(x,'|',1) AND v.status='active');
  IF n <> 0 THEN RAISE EXCEPTION 'award venues %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(aw,E'\n') x WHERE split_part(x,'|',2) NOT IN (SELECT category FROM award_categories WHERE source_id='michelin');
  IF n <> 0 THEN RAISE EXCEPTION 'categories %', n; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_url IN (SELECT nullif(split_part(x,'|',3),'') FROM regexp_split_to_table(aw,E'\n') x) OR a.source_url IN (SELECT nullif(split_part(x,'|',4),'') FROM regexp_split_to_table(rl,E'\n') x)) THEN RAISE EXCEPTION 'url in use'; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_id='michelin' AND a.year=2026 AND a.venue_id IN (SELECT split_part(x,'|',1) FROM regexp_split_to_table(aw,E'\n') x)) THEN RAISE EXCEPTION 'new row venue holds Michelin 2026'; END IF;
  -- Closures
  SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id, E'\n' ORDER BY v.id COLLATE "C")) INTO s FROM venues v WHERE v.id IN (SELECT split_part(x,'|',1) FROM regexp_split_to_table(cl,E'\n') x);
  IF s IS DISTINCT FROM (SELECT md5(string_agg(x, E'\n' ORDER BY x COLLATE "C")) FROM regexp_split_to_table(cl,E'\n') x) THEN RAISE EXCEPTION 'closure fingerprint %', s; END IF;
  IF (SELECT venues_count FROM cities WHERE id='ci_f957c08967') <> 2 OR (SELECT venues_count FROM cities WHERE id='ci_1dd325947d') <> 1 THEN RAISE EXCEPTION 'city counts before'; END IF;
  IF (SELECT count(*) FROM listings WHERE venue_id IN (SELECT split_part(x,'|',1) FROM regexp_split_to_table(cl,E'\n') x) AND published) <> 2 THEN RAISE EXCEPTION 'closure listings'; END IF;
  -- New venue
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\n') x WHERE split_part(x,'|',1) <> 've_'||left(md5(split_part(x,'|',3)||':'||split_part(x,'|',2)),10) OR split_part(x,'|',2) <> trim(both '-' from regexp_replace(lower(f_unaccent(split_part(x,'|',6))),'[^a-z0-9]+','-','g'));
  IF n <> 0 THEN RAISE EXCEPTION 'id or slug rule %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\n') x WHERE EXISTS (SELECT 1 FROM venues v WHERE v.id=split_part(x,'|',1) OR v.norm_key=norm_key(split_part(x,'|',6))) OR EXISTS (SELECT 1 FROM slugs t WHERE t.city_slug=split_part(x,'|',3) AND t.slug=split_part(x,'|',2)) OR NOT EXISTS (SELECT 1 FROM cities c WHERE c.id=split_part(x,'|',4) AND c.slug=split_part(x,'|',3) AND c.display=split_part(x,'|',5));
  IF n <> 0 THEN RAISE EXCEPTION 'venue clash or city %', n; END IF;
  RAISE NOTICE 'pre gates passed';
  -- WRITE: relabel
  UPDATE awards a SET year=2026, source_url=nullif(split_part(x,'|',4),'') FROM regexp_split_to_table(rl,E'\n') x WHERE a.id=split_part(x,'|',1)::bigint;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 156 THEN RAISE EXCEPTION 'relabel %', n; END IF;
  -- WRITE: venue, listing, slug
  INSERT INTO venues (id, name, category, city_id, status) SELECT split_part(x,'|',1), split_part(x,'|',6), 'restaurant'::venue_category, split_part(x,'|',4), 'active'::venue_status FROM regexp_split_to_table(nw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'venues %', n; END IF;
  INSERT INTO listings (venue_id, property_id, published) SELECT split_part(x,'|',1), 'eats', true FROM regexp_split_to_table(nw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'listings %', n; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) SELECT 'eats', split_part(x,'|',3), split_part(x,'|',2), split_part(x,'|',1), true FROM regexp_split_to_table(nw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'slugs %', n; END IF;
  -- WRITE: city labels, with hand audit rows
  WITH ins AS (INSERT INTO city_label_source (venue_id, label, from_column, publisher, note)
      SELECT split_part(x,'|',1), l.label, l.col::label_column_t, 'michelin', '2026 edition, new venue' FROM regexp_split_to_table(nw,E'\n') x
      CROSS JOIN LATERAL (VALUES (split_part(x,'|',5),'city_display'),('Austria','country')) l(label,col) RETURNING *)
    INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', i.id::text, 'INSERT', NULL, to_jsonb(i) FROM ins i;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'labels %', n; END IF;
  -- WRITE: awards
  SELECT max(id) INTO first_award FROM awards;
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
    SELECT split_part(x,'|',1), 'michelin', 2026, NULL, split_part(x,'|',2), NULL, nullif(split_part(x,'|',3),'') FROM regexp_split_to_table(aw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 5 THEN RAISE EXCEPTION 'awards %', n; END IF;
  -- WRITE: closures and city counts
  UPDATE venues SET status='closed' WHERE id IN (SELECT split_part(x,'|',1) FROM regexp_split_to_table(cl,E'\n') x) AND status='active';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'status %', n; END IF;
  UPDATE listings SET published=false WHERE venue_id IN (SELECT split_part(x,'|',1) FROM regexp_split_to_table(cl,E'\n') x) AND published;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'published %', n; END IF;
  UPDATE cities SET venues_count=0 WHERE id='ci_f957c08967' AND venues_count=2;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city leibnitz %', n; END IF;
  UPDATE cities SET venues_count=2 WHERE id='ci_1dd325947d' AND venues_count=1;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city sankt veit %', n; END IF;
  -- WRITE: ledger
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('michelin','award',156,'relabel:load-michelin-2026-austria-2026-11-05 | rule 2.1.7: Austria edition live at capture = 2026 (selection Mar 18, 2026, https://guide.michelin.com/at/en/article/michelin-guide-ceremony/all-starred-restaurants---michelin-guide-austria-2026) | year 2025 -> 2026, source_url = the card (/us/en/), the star article for 5897, retire 0 | relay sha256 a7a3ea3d880885565f1865c38e9fa15edd5029b329114e3396e31cc5f21b0c80 | DRAFT, choices not yet given'),
    ('michelin','award',5,'cleanup:load-michelin-2026-austria-2026-11-05 | Austria 2026 rows not in the legacy rows: One Star TIAN, Kirchenwirt (Leogang), Thaller - Restaurant; Bib Wörgötter - Wirtshaus, Schlosskeller Wirtshaus | list read Nov 5, 2026 | relay sha256 a7a3ea3d880885565f1865c38e9fa15edd5029b329114e3396e31cc5f21b0c80 | DRAFT, choices not yet given'),
    ('michelin','city_label',2,'cleanup:load-michelin-2026-austria-2026-11-05 | city labels of 1 new venue | DRAFT, choices not yet given');
  -- POST gates
  IF (SELECT count(*) FROM venues) <> 11674 OR (SELECT count(*) FROM venues WHERE status='active') <> 11369 OR (SELECT count(*) FROM venues WHERE status='closed') <> 305 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> 28373 OR (SELECT count(*) FROM awards WHERE id > first_award) <> 5 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT md5(string_agg(venue_id||'|'||category||'|'||coalesce(source_url,''), E'\n' ORDER BY venue_id||'|'||category||'|'||coalesce(source_url,'') COLLATE "C")) FROM awards WHERE id > first_award AND year=2026 AND source_id='michelin') <> 'f53dccd388ecc506bba0e73b0c0b6fb2' THEN RAISE EXCEPTION 'rows after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> 4596 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 6931 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> 122 THEN RAISE EXCEPTION 'Michelin after'; END IF;
  SELECT string_agg(category||'='||k, ',' ORDER BY category) INTO s FROM (SELECT a.category, count(*) k FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Austria' AND a.year=2026 GROUP BY 1) z;
  IF s IS DISTINCT FROM 'Bib Gourmand=61,One Star=79,Three Stars=2,Two Stars=19' THEN RAISE EXCEPTION 'Austria 2026 %', s; END IF;
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Austria' AND a.year=2025) <> 2 THEN RAISE EXCEPTION 'Austria 2025'; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Austria' GROUP BY a.venue_id, a.year, a.category HAVING count(*)>1) THEN RAISE EXCEPTION 'duplicate rows'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13618 OR (SELECT count(*) FROM listings) <> 11674 OR (SELECT count(*) FROM city_label_source) <> 24755 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 35 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM cities) <> 3321 OR (SELECT sum(venues_count) FROM cities) <> 11369 THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 261 THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 OR (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'published after'; END IF;
  SELECT count(*) INTO n FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id=v.id AND s.property_id='eats' AND s.is_canonical) <> 1; IF n <> 0 THEN RAISE EXCEPTION 'canonical %', n; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:INSERT=5,awards:UPDATE=156,cities:UPDATE=2,city_label_source:INSERT=2,listings:INSERT=1,listings:UPDATE=2,slugs:INSERT=1,venues:INSERT=1,venues:UPDATE=2' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$load$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
