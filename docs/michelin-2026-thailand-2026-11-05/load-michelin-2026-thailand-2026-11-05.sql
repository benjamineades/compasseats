-- load-michelin-2026-thailand-2026-11-05.sql
-- CompassEats, Nov 5 2026. Michelin Thailand: the 2026 label. Ben choices 1-6:A, Nov 5 18:56 ET. This file runs only after Ben's "go".
-- Rule 2.1.1 and 2.1.7: the 178 legacy rows hold the 2026 edition (ceremony Nov 27, 2025: https://guide.michelin.com/en/article/michelin-guide-ceremony/michelin-guide-thailand-2026). Relabel 2025 -> 2026, no source_url. Retire 0.
-- Then 2 new rows, year 2026, source_url = the card (/us/en/): One Star Aksorn (live venue), Bib Gourmand Krua Apsorn (Dusit) (new venue).
-- Source: docs/michelin-2026-thailand-2026-11-05/relay-th-2026-list-pages-2026-11-05.txt sha256 4baab2de66eb6211ef805d7cb4f86ab7beee02af8cbfd63848b5d1acb2cdaff3.
-- No rename, price, address, geo, blurb or status change on a live venue.
-- Expected after: venues 11673 (active 11370, closed 303); awards 28368; slugs 13617; listings 11673; labels 24753; cities 3321, sum 11370; ledger 258 rows; Michelin 2025/2026/2027 4752/6770/122; audit_log +186.
BEGIN;
DO $load$
DECLARE
  rl text := $plan$56|ve_554dca07f5|Three Stars|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/sorn
71|ve_d14b90da5e|Three Stars|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/suhring
1487|ve_df337c9f87|Two Stars|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/le-normandie
1496|ve_65ed1f31ff|Two Stars|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/baan-tepa
1499|ve_cc7cde333c|Two Stars|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/chef-s-table1184372
1501|ve_00ee742044|Two Stars|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/cote-by-mauro-colagreco
1510|ve_09a0eddd98|Two Stars|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/gaa-1194845
1522|ve_7590a28759|Two Stars|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/inddee
1525|ve_d8308ff080|Two Stars|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/mezzaluna
1528|ve_9b1b47ce68|Two Stars|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/r-haan
3913|ve_0c8c633103|One Star|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/80-20
3915|ve_c18c1fe399|One Star|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/avant
3916|ve_f79607559b|One Star|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/blue-by-alain-ducasse
3923|ve_06dbda2609|One Star|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/bo-lan
3927|ve_19d015da36|One Star|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/cannubi-by-umberto-bombana
3928|ve_57624d2531|One Star|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/chim-by-siam-wisdom
3929|ve_04ae14fccc|One Star|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/coda-1206365
3931|ve_4fb84113eb|One Star|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/elements
3932|ve_c9ebbd94de|One Star|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/etcha
3942|ve_260c4c33ff|One Star|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/gaggan-anand
3953|ve_f9ba888437|One Star|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/goat
3954|ve_ed11d0cfd0|One Star|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/haoma
3961|ve_4d422625bb|One Star|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/igniv
3969|ve_88c7c0c420|One Star|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/jay-fai
3970|ve_02ef15c6b4|One Star|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/juksunchae
3971|ve_7e5311f93e|One Star|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/le-du
3984|ve_3dce2015e3|One Star|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/maison-dunand
3987|ve_29c14151d5|One Star|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/mia
3994|ve_06c130d2bf|One Star|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/nahm
4003|ve_1c8b08e204|One Star|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/nawa
4004|ve_07435fce14|One Star|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/nusara-1192382
4016|ve_d55db66fe4|One Star|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/potong
4026|ve_d956f31ccf|One Star|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/resonance
4036|ve_482462eaec|One Star|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/samrub-samrub-thai
4037|ve_9ac6a9654a|One Star|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/saneh-jaan
4039|ve_e6838a78be|One Star|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/signature-1194955
4040|ve_48c25944ad|One Star|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/sushi-saito-1208794
4047|ve_51fccd2985|One Star|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/wana-yook
6924|ve_9d47a94a4e|One Star|https://guide.michelin.com/us/en/nonthaburi-region/nonthaburi/restaurant/akkee
6926|ve_d202b826b4|One Star|https://guide.michelin.com/us/en/nonthaburi-region/nonthaburi/restaurant/suan-thip
7360|ve_fddc554cc8|One Star|https://guide.michelin.com/us/en/th-phang-nga-region/th-phang-nga/restaurant/aulis-1210910
7369|ve_3a7ee15f36|One Star|https://guide.michelin.com/us/en/phuket-region/phuket/restaurant/pru
9398|ve_61981631c4|Bib Gourmand|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/ann-tha-din-daeng
9399|ve_9f89cf7189|Bib Gourmand|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/aunglo-by-yangrak
9400|ve_fa9c7990e7|Bib Gourmand|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/baan-pee-lek
9401|ve_4c61de3d5b|Bib Gourmand|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/beer-hima-prachachuen
9402|ve_c66116144c|Bib Gourmand|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/bokkia-tha-din-daeng
9403|ve_4d3d2b9980|Bib Gourmand|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/bunloet
9404|ve_1072511a79|Bib Gourmand|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/grim-nguan-noodle
9405|ve_85a0d6b339|Bib Gourmand|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/here-hai
9406|ve_a3e84c3f7b|Bib Gourmand|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/hia-wan-khao-tom-pla
9407|ve_b30ba8b03c|Bib Gourmand|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/jaan-by-khun-jim
9408|ve_d3bd425530|Bib Gourmand|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/janhom
9409|ve_0be8f372f5|Bib Gourmand|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/k-panich
9410|ve_52a8e7ad11|Bib Gourmand|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/keawloon
9411|ve_dcd05ce7df|Bib Gourmand|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/kin-kub-koi
9412|ve_5ae8e6bf27|Bib Gourmand|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/kolun-h
9413|ve_b2d60b3de7|Bib Gourmand|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/lucky-seafood
9414|ve_c57f64b168|Bib Gourmand|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/maan-muang
9415|ve_e210849f66|Bib Gourmand|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/no-name-noodle
9416|ve_04cf48f53a|Bib Gourmand|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/eat-pad-thai
9417|ve_242a6332d7|Bib Gourmand|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/pae-jok-38-years
9418|ve_0d2e8ee6d4|Bib Gourmand|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/phed-phed-bistro
9419|ve_f2392a915f|Bib Gourmand|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/plu
9420|ve_5837479041|Bib Gourmand|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/prik-yuak
9421|ve_bf6b150a08|Bib Gourmand|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/guay-tiew-mu-rung-rueang
9422|ve_007615f444|Bib Gourmand|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/samlor
9423|ve_092acd629b|Bib Gourmand|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/somsak-pu-ob-charoen-rat
9424|ve_acf0ff5baf|Bib Gourmand|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/ten-suns
9425|ve_ca266e026f|Bib Gourmand|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/thai-niyom
9426|ve_0260161d67|Bib Gourmand|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/thai-tham
9427|ve_cc47467d7d|Bib Gourmand|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/thien-duong
9428|ve_f1587a7bf1|Bib Gourmand|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/urai-braised-goose
9796|ve_cfb032e12d|Bib Gourmand|https://guide.michelin.com/us/en/chiang-mai-region/chiang-mai/restaurant/chawee
9797|ve_59e74c6856|Bib Gourmand|https://guide.michelin.com/us/en/chiang-mai-region/chiang-mai/restaurant/dan-chicken-rice-san-sai
9798|ve_af0a74d092|Bib Gourmand|https://guide.michelin.com/us/en/chiang-mai-region/chiang-mai/restaurant/euang-kam-sai
9799|ve_db9bba980d|Bib Gourmand|https://guide.michelin.com/us/en/chiang-mai-region/chiang-mai/restaurant/gongkham
9800|ve_447ad081de|Bib Gourmand|https://guide.michelin.com/us/en/chiang-mai-region/chiang-mai/restaurant/guay-jub-chang-moi-tat-mai
9801|ve_10073d7a22|Bib Gourmand|https://guide.michelin.com/us/en/chiang-mai-region/chiang-mai/restaurant/huan-soontaree
9802|ve_58bc6cb0d7|Bib Gourmand|https://guide.michelin.com/us/en/chiang-mai-region/chiang-mai/restaurant/huen-muan-jai
9803|ve_5e48dec9a7|Bib Gourmand|https://guide.michelin.com/us/en/chiang-mai-region/chiang-mai/restaurant/khao-soi-mae-sai
9804|ve_239a6bf9bf|Bib Gourmand|https://guide.michelin.com/us/en/chiang-mai-region/chiang-mai/restaurant/krua-lawng-khao
9805|ve_5dff83cac6|Bib Gourmand|https://guide.michelin.com/us/en/chiang-mai-region/chiang-mai/restaurant/lung-khajohn-wat-ket
9806|ve_a72c0f5bfd|Bib Gourmand|https://guide.michelin.com/us/en/chiang-mai-region/chiang-mai/restaurant/magnolia-cafe
9807|ve_55d3e61b04|Bib Gourmand|https://guide.michelin.com/us/en/chiang-mai-region/chiang-mai/restaurant/meena-rice-based-cuisine
9808|ve_901735a5d1|Bib Gourmand|https://guide.michelin.com/us/en/chiang-mai-region/chiang-mai/restaurant/rasik-local-kitchen
9809|ve_fc929cd7b2|Bib Gourmand|https://guide.michelin.com/us/en/chiang-mai-region/chiang-mai/restaurant/rotee-pa-day
9810|ve_203e7ffcb1|Bib Gourmand|https://guide.michelin.com/us/en/chiang-mai-region/chiang-mai/restaurant/saiyut-and-doctor-sai-kitchen
9811|ve_77af594dd0|Bib Gourmand|https://guide.michelin.com/us/en/chiang-mai-region/chiang-mai/restaurant/sanae-thai-cuisine
9812|ve_e4886fb250|Bib Gourmand|https://guide.michelin.com/us/en/chiang-mai-region/chiang-mai/restaurant/sanpakoi-kanomjeen
9813|ve_86b194cc62|Bib Gourmand|https://guide.michelin.com/us/en/chiang-mai-region/chiang-mai/restaurant/tue-ka-ko-na-prince
9856|ve_2fe7abc9ba|Bib Gourmand|https://guide.michelin.com/us/en/chon-buri-region/chon-buri_2758557/restaurant/khao-lam-mae-khai-toon-klao
9857|ve_cf56deaf06|Bib Gourmand|https://guide.michelin.com/us/en/chon-buri-region/chon-buri_2758557/restaurant/krua-laew-tae-r-rom
9858|ve_57259650b4|Bib Gourmand|https://guide.michelin.com/us/en/chon-buri-region/chon-buri_2758557/restaurant/la-voi
9859|ve_51e0736f3a|Bib Gourmand|https://guide.michelin.com/us/en/chon-buri-region/chon-buri_2758557/restaurant/lung-shall-kitchen
9860|ve_29ff82e089|Bib Gourmand|https://guide.michelin.com/us/en/chon-buri-region/chon-buri_2758557/restaurant/pladids
10731|ve_43d1e05d2f|Bib Gourmand|https://guide.michelin.com/us/en/khon-kaen-region/khon-kaen/restaurant/baan-heng
10732|ve_2fea614a03|Bib Gourmand|https://guide.michelin.com/us/en/khon-kaen-region/khon-kaen/restaurant/here-joi-beef-noodle
10733|ve_2cc3091377|Bib Gourmand|https://guide.michelin.com/us/en/khon-kaen-region/khon-kaen/restaurant/jok-guay-jab-tom-sen-bat-queue
10734|ve_7aafb4d065|Bib Gourmand|https://guide.michelin.com/us/en/khon-kaen-region/khon-kaen/restaurant/khon-kaen-grilled-pork-neck
10735|ve_c1a2b0726d|Bib Gourmand|https://guide.michelin.com/us/en/khon-kaen-region/khon-kaen/restaurant/khun-jaeng-guay-tiew-pak-mor-kao-wang
10736|ve_dcc8b2a42a|Bib Gourmand|https://guide.michelin.com/us/en/khon-kaen-region/khon-kaen/restaurant/leng-yentafo
10737|ve_c6c657ea89|Bib Gourmand|https://guide.michelin.com/us/en/khon-kaen-region/khon-kaen/restaurant/mekin-farm
10738|ve_5b5caa90aa|Bib Gourmand|https://guide.michelin.com/us/en/khon-kaen-region/khon-kaen/restaurant/praprai
10739|ve_0bea31301b|Bib Gourmand|https://guide.michelin.com/us/en/khon-kaen-region/khon-kaen/restaurant/prasit-pochana
10740|ve_2967137c6f|Bib Gourmand|https://guide.michelin.com/us/en/khon-kaen-region/khon-kaen/restaurant/so-jeng
10741|ve_f0553e0f93|Bib Gourmand|https://guide.michelin.com/us/en/khon-kaen-region/khon-kaen/restaurant/sriruen-pad-thai-reunrom-road
10752|ve_7b35234b84|Bib Gourmand|https://guide.michelin.com/us/en/cchanghwad-suraasdrthaanii/koh-samui_7770005/restaurant/baan-suan-lung-khai
10753|ve_cf75147034|Bib Gourmand|https://guide.michelin.com/us/en/cchanghwad-suraasdrthaanii/koh-samui_7770005/restaurant/jun-hom
11265|ve_4f173ec841|Bib Gourmand|https://guide.michelin.com/us/en/nakhon-pathom-region/nakhon-pathom/restaurant/krua-jay-sim
11266|ve_67f5b7d35f|Bib Gourmand|https://guide.michelin.com/us/en/nakhon-pathom-region/nakhon-pathom/restaurant/nai-ngieb-phutthamonthon-sai-4
11267|ve_180eece4af|Bib Gourmand|https://guide.michelin.com/us/en/nakhon-pathom-region/nakhon-pathom/restaurant/plaew-nakhon-pathom
11268|ve_ee817cec5a|Bib Gourmand|https://guide.michelin.com/us/en/nakhon-ratchasima-region/nakhon-ratchasima/restaurant/banmai-chay-nam
11269|ve_0189256b95|Bib Gourmand|https://guide.michelin.com/us/en/nakhon-ratchasima-region/nakhon-ratchasima/restaurant/kai-yang-saeng-thai
11270|ve_7d82b331d9|Bib Gourmand|https://guide.michelin.com/us/en/nakhon-ratchasima-region/nakhon-ratchasima/restaurant/khanom-ochin
11271|ve_42e191ba8c|Bib Gourmand|https://guide.michelin.com/us/en/nakhon-ratchasima-region/nakhon-ratchasima/restaurant/krua-suwimol
11272|ve_2597b0b03e|Bib Gourmand|https://guide.michelin.com/us/en/nakhon-ratchasima-region/nakhon-ratchasima/restaurant/lab-somphit
11273|ve_88b51c5458|Bib Gourmand|https://guide.michelin.com/us/en/nakhon-ratchasima-region/nakhon-ratchasima/restaurant/nub-1243494
11274|ve_131ba44a3b|Bib Gourmand|https://guide.michelin.com/us/en/nakhon-ratchasima-region/nakhon-ratchasima/restaurant/pa-pleung-mhee-kratok
11275|ve_478f4be4f0|Bib Gourmand|https://guide.michelin.com/us/en/nakhon-ratchasima-region/nakhon-ratchasima/restaurant/sow-jeck-pochana
11440|ve_52c9ed849e|Bib Gourmand|https://guide.michelin.com/us/en/nonthaburi-region/nonthaburi/restaurant/chai-phochana
11441|ve_ceb56e1c5d|Bib Gourmand|https://guide.michelin.com/us/en/nonthaburi-region/nonthaburi/restaurant/chang-wang-imm
11442|ve_8599c396c2|Bib Gourmand|https://guide.michelin.com/us/en/nonthaburi-region/nonthaburi/restaurant/hong-seng-pochana
11443|ve_9793d6cc48|Bib Gourmand|https://guide.michelin.com/us/en/nonthaburi-region/nonthaburi/restaurant/kaeng-pa-loong-sa-nga
11444|ve_1599f1d608|Bib Gourmand|https://guide.michelin.com/us/en/nonthaburi-region/nonthaburi/restaurant/sann
11642|ve_096be69bd1|Bib Gourmand|https://guide.michelin.com/us/en/pathum-thani-region/pathum-thani/restaurant/khao-mun-gai-nha-jone
11643|ve_cff2ea2cb9|Bib Gourmand|https://guide.michelin.com/us/en/pathum-thani-region/pathum-thani/restaurant/morakot-kitchen
11644|ve_ef4210c136|Bib Gourmand|https://guide.michelin.com/us/en/pathum-thani-region/pathum-thani/restaurant/pae-pochana
11660|ve_23e36444e7|Bib Gourmand|https://guide.michelin.com/us/en/th-phang-nga-region/th-phang-nga/restaurant/hok-kee-lao
11661|ve_99c445aa98|Bib Gourmand|https://guide.michelin.com/us/en/th-phang-nga-region/th-phang-nga/restaurant/krachang-khao-lak
11662|ve_98931cb8fc|Bib Gourmand|https://guide.michelin.com/us/en/th-phang-nga-region/th-phang-nga/restaurant/krua-luang-ten
11663|ve_113ca78e27|Bib Gourmand|https://guide.michelin.com/us/en/th-phang-nga-region/th-phang-nga/restaurant/mon-phochana
11664|ve_2bd60008af|Bib Gourmand|https://guide.michelin.com/us/en/th-phang-nga-region/th-phang-nga/restaurant/roe-dang
11665|ve_29c04d7296|Bib Gourmand|https://guide.michelin.com/us/en/th-phang-nga-region/th-phang-nga/restaurant/krua-tonfon
11677|ve_3a39e62568|Bib Gourmand|https://guide.michelin.com/us/en/phra-nakhon-si-syutthaya-region/phra-nakhon-si-ayutthaya/restaurant/baan-pu-karn
11678|ve_c1c52b60af|Bib Gourmand|https://guide.michelin.com/us/en/phra-nakhon-si-syutthaya-region/phra-nakhon-si-ayutthaya/restaurant/baan-ta-koh-rai
11679|ve_41f0f282db|Bib Gourmand|https://guide.michelin.com/us/en/phra-nakhon-si-syutthaya-region/phra-nakhon-si-ayutthaya/restaurant/khanom-mho-kaeng-mae-yai-phai-ling
11680|ve_68f0e2320e|Bib Gourmand|https://guide.michelin.com/us/en/phra-nakhon-si-syutthaya-region/phra-nakhon-si-ayutthaya/restaurant/kin-lookdeaw
11681|ve_2c3107515f|Bib Gourmand|https://guide.michelin.com/us/en/phra-nakhon-si-syutthaya-region/phra-nakhon-si-ayutthaya/restaurant/pa-lek-boat-noodles
11682|ve_1c90c6dc4f|Bib Gourmand|https://guide.michelin.com/us/en/phra-nakhon-si-syutthaya-region/phra-nakhon-si-ayutthaya/restaurant/pranom-shredded-chicken-noodles
11683|ve_703169de74|Bib Gourmand|https://guide.michelin.com/us/en/phra-nakhon-si-syutthaya-region/phra-nakhon-si-ayutthaya/restaurant/ruanthai-kungpao
11684|ve_7db4d938af|Bib Gourmand|https://guide.michelin.com/us/en/phra-nakhon-si-syutthaya-region/phra-nakhon-si-ayutthaya/restaurant/u-khao
11685|ve_3c51e02932|Bib Gourmand|https://guide.michelin.com/us/en/phuket-region/phuket/restaurant/a-pong-mae-sunee
11686|ve_74b5967754|Bib Gourmand|https://guide.michelin.com/us/en/phuket-region/phuket/restaurant/chuan-chim
11687|ve_f2cc1c81d0|Bib Gourmand|https://guide.michelin.com/us/en/phuket-region/phuket/restaurant/go-benz
11688|ve_7df42be157|Bib Gourmand|https://guide.michelin.com/us/en/phuket-region/phuket/restaurant/khao-tom-thanon-di-buk
11689|ve_927d2deb89|Bib Gourmand|https://guide.michelin.com/us/en/phuket-region/phuket/restaurant/kin-kub-ei
11690|ve_d234288b2c|Bib Gourmand|https://guide.michelin.com/us/en/phuket-region/phuket/restaurant/krua-baan-platong
11691|ve_a76b6e01c7|Bib Gourmand|https://guide.michelin.com/us/en/phuket-region/phuket/restaurant/krua-kao-kuk
11692|ve_73e2545e69|Bib Gourmand|https://guide.michelin.com/us/en/phuket-region/phuket/restaurant/krua-praya-phuket
11693|ve_09d60a25d6|Bib Gourmand|https://guide.michelin.com/us/en/phuket-region/phuket/restaurant/mor-mu-dong
11694|ve_109a86f846|Bib Gourmand|https://guide.michelin.com/us/en/phuket-region/phuket/restaurant/naam-yoi
11695|ve_f4684f1fa2|Bib Gourmand|https://guide.michelin.com/us/en/phuket-region/phuket/restaurant/niyom-salt-grilled-duck
11696|ve_9f037b5d8d|Bib Gourmand|https://guide.michelin.com/us/en/phuket-region/phuket/restaurant/one-chun
11697|ve_bc86555f31|Bib Gourmand|https://guide.michelin.com/us/en/phuket-region/phuket/restaurant/pathongko-mae-pranee
11698|ve_44b74070e1|Bib Gourmand|https://guide.michelin.com/us/en/phuket-region/phuket/restaurant/roti-chaofa
11699|ve_ba755a7b46|Bib Gourmand|https://guide.michelin.com/us/en/phuket-region/phuket/restaurant/roti-taew-nam
11700|ve_662a06e56d|Bib Gourmand|https://guide.michelin.com/us/en/phuket-region/phuket/restaurant/surf-turf-by-soul-kitchen
11701|ve_b38b8d75a1|Bib Gourmand|https://guide.michelin.com/us/en/phuket-region/phuket/restaurant/the-charm
11702|ve_1a54e4f33d|Bib Gourmand|https://guide.michelin.com/us/en/phuket-region/phuket/restaurant/toh-daeng-by-baan-ar-jor-museum-home
11703|ve_f32a2b946b|Bib Gourmand|https://guide.michelin.com/us/en/phuket-region/phuket/restaurant/ton-mayom
11937|ve_28d1107597|Bib Gourmand|https://guide.michelin.com/us/en/samut-sakhon-region/samut-sakhon/restaurant/ruean-panya
12314|ve_6ca1ba93a9|Bib Gourmand|https://guide.michelin.com/us/en/cchanghwad-suraasdrthaanii/suraasdrthaanii_2719394/restaurant/dear-phangan
12315|ve_6e9ae9de21|Bib Gourmand|https://guide.michelin.com/us/en/cchanghwad-suraasdrthaanii/suraasdrthaanii_2719394/restaurant/keo-pla
12316|ve_0137a9444c|Bib Gourmand|https://guide.michelin.com/us/en/cchanghwad-suraasdrthaanii/suraasdrthaanii_2719394/restaurant/lucky-restaurant
12317|ve_2273b1f262|Bib Gourmand|https://guide.michelin.com/us/en/cchanghwad-suraasdrthaanii/suraasdrthaanii_2719394/restaurant/nampetch
12318|ve_492cb1490f|Bib Gourmand|https://guide.michelin.com/us/en/cchanghwad-suraasdrthaanii/suraasdrthaanii_2719394/restaurant/pa-ting
12319|ve_e3f314d340|Bib Gourmand|https://guide.michelin.com/us/en/cchanghwad-suraasdrthaanii/suraasdrthaanii_2719394/restaurant/phunisa
12320|ve_7ae41a5665|Bib Gourmand|https://guide.michelin.com/us/en/cchanghwad-suraasdrthaanii/suraasdrthaanii_2719394/restaurant/yok-kheng
12759|ve_30d4122ad8|Bib Gourmand|https://guide.michelin.com/us/en/ubon-ratchathani-province/ubon-ratchathani/restaurant/agave
12760|ve_859ac4e389|Bib Gourmand|https://guide.michelin.com/us/en/ubon-ratchathani-province/ubon-ratchathani/restaurant/mok
12761|ve_3d24c06022|Bib Gourmand|https://guide.michelin.com/us/en/ubon-ratchathani-province/ubon-ratchathani/restaurant/som-tum-jinda
12765|ve_9b36040b77|Bib Gourmand|https://guide.michelin.com/us/en/udon-thani-region/udon-thani/restaurant/khao-piak-udon
12766|ve_7c42d67c95|Bib Gourmand|https://guide.michelin.com/us/en/udon-thani-region/udon-thani/restaurant/khao-soi-thai-yai
12767|ve_1ee9fa6ac6|Bib Gourmand|https://guide.michelin.com/us/en/udon-thani-region/udon-thani/restaurant/krua-khun-nid
12768|ve_76950b6f5b|Bib Gourmand|https://guide.michelin.com/us/en/udon-thani-region/udon-thani/restaurant/majchapasuk
12769|ve_d996f54622|Bib Gourmand|https://guide.michelin.com/us/en/udon-thani-region/udon-thani/restaurant/pad-thai-bua-dang
12770|ve_7e3852becc|Bib Gourmand|https://guide.michelin.com/us/en/udon-thani-region/udon-thani/restaurant/peng-duck-noodles$plan$;
  aw text := $plan$ve_4e1280a372|One Star|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/aksorn
ve_b877b4ed0e|Bib Gourmand|https://guide.michelin.com/us/en/bangkok-region/bangkok/restaurant/krua-apsorn-sam-sen$plan$;
  nw text := $plan$ve_b877b4ed0e|krua-apsorn-dusit|bangkok|ci_b90bbd2b87|Bangkok|Krua Apsorn (Dusit)$plan$;
  n bigint; s text; fp text; aud_max bigint; first_award bigint;
BEGIN
  -- PRE gates
  IF md5(rl) <> '2ece8182b5861c9e8931e8186be9e442' OR md5(aw) <> 'b79edc11c568a4761bccb1467eec665b' OR md5(nw) <> '24fbba6b9458be19fc2df2e510adc8f5' THEN RAISE EXCEPTION 'plan text'; END IF;
  SELECT md5(string_agg(t, E'\n' ORDER BY t COLLATE "C")) INTO fp FROM (
    SELECT a.id||'|'||v.id||'|'||a.category||'|'||v.status||'|'||v.city_id||'|'||v.name t
    FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id
    WHERE a.source_id='michelin' AND c.country='Thailand' AND a.year=2025 AND a.source_url IS NULL AND a.rank IS NULL AND a.distinction IS NULL) y;
  IF fp IS DISTINCT FROM 'e0ea9ad1aa75b9b6a819c425bcecb8eb' THEN RAISE EXCEPTION 'relabel fingerprint %', fp; END IF;
  IF (SELECT count(*) FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Thailand') <> 178 THEN RAISE EXCEPTION 'Thailand Michelin rows'; END IF;
  IF (SELECT count(*) FROM venues) <> 11672 OR (SELECT count(*) FROM venues WHERE status='active') <> 11369 OR (SELECT count(*) FROM venues WHERE status='closed') <> 303 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT count(*) FROM awards) <> 28366 OR (SELECT max(id) FROM awards) <> 35537 THEN RAISE EXCEPTION 'awards before'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> 4930 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 6590 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> 122 THEN RAISE EXCEPTION 'Michelin before'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13616 OR (SELECT count(*) FROM listings) <> 11672 OR (SELECT count(*) FROM city_label_source) <> 24751 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 35 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables before'; END IF;
  IF (SELECT count(*) FROM cities) <> 3321 OR (SELECT sum(venues_count) FROM cities) <> 11369 OR (SELECT count(*) FROM source_capture_ledger) <> 255 OR (SELECT max(id) FROM source_capture_ledger) <> 309 THEN RAISE EXCEPTION 'cities, ledger before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published before'; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> 126227 OR aud_max <> 132056 THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  -- Plan rows against live rows
  SELECT count(*) INTO n FROM regexp_split_to_table(rl,E'\n') x LEFT JOIN awards a ON a.id=split_part(x,'|',1)::bigint
    WHERE a.id IS NULL OR a.venue_id<>split_part(x,'|',2) OR a.category<>split_part(x,'|',3) OR a.year<>2025 OR a.source_id<>'michelin' OR a.source_url IS NOT NULL;
  IF n <> 0 THEN RAISE EXCEPTION 'relabel rows %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(aw,E'\n') x WHERE split_part(x,'|',1) NOT IN (SELECT split_part(y,'|',1) FROM regexp_split_to_table(nw,E'\n') y) AND NOT EXISTS (SELECT 1 FROM venues v WHERE v.id=split_part(x,'|',1) AND v.status='active');
  IF n <> 0 THEN RAISE EXCEPTION 'award venues %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(aw,E'\n') x WHERE split_part(x,'|',2) NOT IN (SELECT category FROM award_categories WHERE source_id='michelin');
  IF n <> 0 THEN RAISE EXCEPTION 'categories %', n; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_url IN (SELECT split_part(x,'|',3) FROM regexp_split_to_table(aw,E'\n') x) OR a.source_url IN (SELECT split_part(x,'|',4) FROM regexp_split_to_table(rl,E'\n') x)) THEN RAISE EXCEPTION 'url in use'; END IF;
  IF EXISTS (SELECT 1 FROM awards a WHERE a.source_id='michelin' AND a.venue_id IN (SELECT split_part(x,'|',1) FROM regexp_split_to_table(aw,E'\n') x)) THEN RAISE EXCEPTION 'new row venue holds Michelin'; END IF;
  -- New venue
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\n') x WHERE split_part(x,'|',1) <> 've_'||left(md5(split_part(x,'|',3)||':'||split_part(x,'|',2)),10) OR split_part(x,'|',2) <> trim(both '-' from regexp_replace(lower(f_unaccent(split_part(x,'|',6))),'[^a-z0-9]+','-','g'));
  IF n <> 0 THEN RAISE EXCEPTION 'id or slug rule %', n; END IF;
  SELECT count(*) INTO n FROM regexp_split_to_table(nw,E'\n') x WHERE EXISTS (SELECT 1 FROM venues v WHERE v.id=split_part(x,'|',1) OR v.norm_key=norm_key(split_part(x,'|',6))) OR EXISTS (SELECT 1 FROM slugs t WHERE t.city_slug=split_part(x,'|',3) AND t.slug=split_part(x,'|',2)) OR NOT EXISTS (SELECT 1 FROM cities c WHERE c.id=split_part(x,'|',4) AND c.slug=split_part(x,'|',3) AND c.display=split_part(x,'|',5));
  IF n <> 0 THEN RAISE EXCEPTION 'venue clash or city %', n; END IF;
  RAISE NOTICE 'pre gates passed';
  -- WRITE: relabel
  UPDATE awards a SET year=2026 FROM regexp_split_to_table(rl,E'\n') x WHERE a.id=split_part(x,'|',1)::bigint;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 178 THEN RAISE EXCEPTION 'relabel %', n; END IF;
  -- WRITE: venue, listing, slug, city count
  INSERT INTO venues (id, name, category, city_id, status) SELECT split_part(x,'|',1), split_part(x,'|',6), 'restaurant'::venue_category, split_part(x,'|',4), 'active'::venue_status FROM regexp_split_to_table(nw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'venues %', n; END IF;
  INSERT INTO listings (venue_id, property_id, published) SELECT split_part(x,'|',1), 'eats', true FROM regexp_split_to_table(nw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'listings %', n; END IF;
  INSERT INTO slugs (property_id, city_slug, slug, venue_id, is_canonical) SELECT 'eats', split_part(x,'|',3), split_part(x,'|',2), split_part(x,'|',1), true FROM regexp_split_to_table(nw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'slugs %', n; END IF;
  UPDATE cities c SET venues_count = c.venues_count + y.k FROM (SELECT split_part(x,'|',4) id, count(*)::int k FROM regexp_split_to_table(nw,E'\n') x GROUP BY 1) y WHERE c.id=y.id;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city counts %', n; END IF;
  -- WRITE: city labels, with hand audit rows
  WITH ins AS (INSERT INTO city_label_source (venue_id, label, from_column, publisher, note)
      SELECT split_part(x,'|',1), l.label, l.col::label_column_t, 'michelin', '2026 edition, new venue' FROM regexp_split_to_table(nw,E'\n') x
      CROSS JOIN LATERAL (VALUES (split_part(x,'|',5),'city_display'),('Thailand','country')) l(label,col) RETURNING *)
    INSERT INTO audit_log (table_name, row_pk, action, old_row, new_row) SELECT 'city_label_source', i.id::text, 'INSERT', NULL, to_jsonb(i) FROM ins i;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'labels %', n; END IF;
  -- WRITE: awards
  SELECT max(id) INTO first_award FROM awards;
  INSERT INTO awards (venue_id, source_id, year, rank, category, distinction, source_url)
    SELECT split_part(x,'|',1), 'michelin', 2026, NULL, split_part(x,'|',2), NULL, split_part(x,'|',3) FROM regexp_split_to_table(aw,E'\n') x;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 2 THEN RAISE EXCEPTION 'awards %', n; END IF;
  -- WRITE: ledger
  INSERT INTO source_capture_ledger (publisher, field_type, items, job) VALUES
    ('michelin','award',178,'relabel:load-michelin-2026-thailand-2026-11-05 | rule 2.1.7: Thailand edition live at capture = 2026 (ceremony Nov 27, 2025, https://guide.michelin.com/en/article/michelin-guide-ceremony/michelin-guide-thailand-2026) | year 2025 -> 2026, no source_url, retire 0 | relay sha256 4baab2de66eb6211ef805d7cb4f86ab7beee02af8cbfd63848b5d1acb2cdaff3 | Ben choices 1-6:A, Nov 5 18:56 ET'),
    ('michelin','award',2,'cleanup:load-michelin-2026-thailand-2026-11-05 | Thailand 2026 rows not in the legacy rows: One Star Aksorn, Bib Gourmand Krua Apsorn (Dusit), list read Nov 5, 2026 | relay sha256 4baab2de66eb6211ef805d7cb4f86ab7beee02af8cbfd63848b5d1acb2cdaff3 | Ben choices 1-6:A, Nov 5 18:56 ET'),
    ('michelin','city_label',2,'cleanup:load-michelin-2026-thailand-2026-11-05 | city labels of 1 new venue | Ben choices 1-6:A, Nov 5 18:56 ET');
  -- POST gates
  IF (SELECT count(*) FROM venues) <> 11673 OR (SELECT count(*) FROM venues WHERE status='active') <> 11370 OR (SELECT count(*) FROM venues WHERE status='closed') <> 303 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT count(*) FROM awards) <> 28368 OR (SELECT count(*) FROM awards WHERE id > first_award) <> 2 THEN RAISE EXCEPTION 'awards after'; END IF;
  IF (SELECT md5(string_agg(venue_id||'|'||category||'|'||source_url, E'\n' ORDER BY venue_id COLLATE "C")) FROM awards WHERE id > first_award AND year=2026 AND source_id='michelin') <> 'b79edc11c568a4761bccb1467eec665b' THEN RAISE EXCEPTION 'rows after'; END IF;
  IF (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2025) <> 4752 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2026) <> 6770 OR (SELECT count(*) FROM awards WHERE source_id='michelin' AND year=2027) <> 122 THEN RAISE EXCEPTION 'Michelin after'; END IF;
  SELECT string_agg(category||'='||k, ',' ORDER BY category) INTO s FROM (SELECT a.category, count(*) k FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Thailand' AND a.year=2026 GROUP BY 1) z;
  IF s IS DISTINCT FROM 'Bib Gourmand=137,One Star=33,Three Stars=2,Two Stars=8' THEN RAISE EXCEPTION 'Thailand 2026 %', s; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Thailand' AND a.year<>2026) THEN RAISE EXCEPTION 'Thailand other year'; END IF;
  IF EXISTS (SELECT 1 FROM awards a JOIN venues v ON v.id=a.venue_id JOIN cities c ON c.id=v.city_id WHERE a.source_id='michelin' AND c.country='Thailand' GROUP BY a.venue_id, a.year, a.category HAVING count(*)>1) THEN RAISE EXCEPTION 'duplicate rows'; END IF;
  IF (SELECT count(*) FROM slugs) <> 13617 OR (SELECT count(*) FROM listings) <> 11673 OR (SELECT count(*) FROM city_label_source) <> 24753 OR (SELECT count(*) FROM price) <> 7759 OR (SELECT count(*) FROM redirects) <> 35 OR (SELECT count(*) FROM city_aliases) <> 222 THEN RAISE EXCEPTION 'tables after'; END IF;
  IF (SELECT count(*) FROM cities) <> 3321 OR (SELECT sum(venues_count) FROM cities) <> 11370 THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts k ON k.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(k.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM source_capture_ledger) <> 258 THEN RAISE EXCEPTION 'ledger after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 OR (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'published after'; END IF;
  SELECT count(*) INTO n FROM venues v WHERE (SELECT count(*) FROM slugs s WHERE s.venue_id=v.id AND s.property_id='eats' AND s.is_canonical) <> 1; IF n <> 0 THEN RAISE EXCEPTION 'canonical %', n; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'awards:INSERT=2,awards:UPDATE=178,cities:UPDATE=1,city_label_source:INSERT=2,listings:INSERT=1,slugs:INSERT=1,venues:INSERT=1' THEN RAISE EXCEPTION 'audit after %', s; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$load$;
COMMIT;
SELECT 'OK: all gates passed' AS result;
