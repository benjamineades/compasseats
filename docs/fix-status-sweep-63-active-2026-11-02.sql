-- fix-status-sweep-63-active-2026-11-02.sql
-- CompassEats, Nov 2 2026. Closed-venue sweep, first 201 venues. Ben: 14:14 ET "1A, 2A, 3A, 4A, 5A". This file runs only after his "go".
-- Scope: 63 venues, status closed to active and listings.published false to true, in one transaction, with city counts.
-- Groups: Group 1 dated 2026 evidence or live booking (20). Group 2 seasonal with dates (8). Group 3 undated site or listing, no closure note (34; Ben 1A). HODAN moved in Istanbul (1; Ben 4A).
-- Other 138 venues of the 201: no change. Evidence for all 201: closed-sweep-201-evidence-2026-11-02.csv.
-- Award rows, names, slugs and price do not change. No ledger row (status precedent, D1). No live page changes: the live site reads the Sheet.
-- Expected after: venues 11,296 (active 10,988, closed 308); cities sum 10,988; closed published 0; active not published 0; audit_log +168 (cities 42, listings 63, venues 63).
--
--   Group 1 | ve_7b26d42de5 | Aburi Hana | OPEN/strong | Closed fall 2025 for renovation; Streets of Toronto (Sep 8 2026) and OpenTable say it reopened Sept 17 2026 with live booking and reviews to Oct 17 2026 at 102 Yorkville  | https://www.opentable.com/r/aburi-hana-toronto
--   Group 1 | ve_ccc40ebfb6 | Atelier | OPEN/strong | atelierrestaurant.ca offers booking Wed-Sat 6-8pm and lists 2026 recognitions; OpenTable listing shows reviews up to Apr 29 2026 at 540 Rochester St. | https://atelierrestaurant.ca
--   Group 1 | ve_65ed1f31ff | Baan Tepa Culinary Space | OPEN/strong | BK Magazine (13 Mar 2026) reports Baan Tepa at No. 53 on Asia's 50 Best Restaurants 2026 (51-100 list), the top Bangkok entry. | https://www.bkmagazine.com/food/restaurants/5-bangkok-restaurants-feature-on-asias-50-best-restaurants-51-100-for-2026/
--   Group 1 | ve_271991cc7f | Bar Dali | OPEN/medium | Sotheby's Realty journal (2026-03-10) lists Bar Dali at The Opus, Business Bay, as operating; wow-emirates piece (modified 2026-04-05) lists Thursday-Saturday hours. An u | https://sothebysrealty.ae/the-journal/best-bars-in-business-bay/
--   Group 1 | ve_0d0ff2027e | Brutus Tavern | OPEN/medium | Protothema (24 Apr 2026) reports Brutus Tavern, 3 Leventi St, Kolonaki, ranked No. 72 in the 2026 World's 101 Best Steak Restaurants, in the present tense. The venue's ow | https://en.protothema.gr/2026/04/24/a-greek-restaurant-in-the-101-best-steakhouses-in-the-world/
--   Group 1 | ve_efad8f7bba | Cara de Vaca | OPEN/strong | Players of Life article dated Oct 26, 2026 says Cara de Vaca returns to its original home at Río de la Plata 448, San Pedro Garza García, reopening Oct 27, 2026 at 6 pm a | https://playersoflife.com/monterrey/cara-de-vaca-x-siempre-el-iconico-restaurante-de-chuy-villarreal-regresa-a-casa/
--   Group 1 | ve_e889827c8f | Chef Kang's Noodle House | OPEN/strong | Eatbook.sg review published 19 Jun 2026 (modified 2 Jul 2026) covers the stall at Jackson Square, 11 Lorong 3 Toa Payoh, with current hours and no closure; it notes only  | https://eatbook.sg/chef-kang-wanton-mee/
--   Group 1 | ve_6ad36e0dca | Citrus & Cane | OPEN/medium | Own site lists Wed-Sun 5-11pm at 606 Trounce Alley with reservations; Victoria Buzz (Apr 1 2026) reports it ranked 87 on North America's 50 Best Bars. | https://www.citrusandcane.com/
--   Group 1 | ve_3205d5e257 | Hakusi | OPEN/strong | Hakusi's own site shows a MICHELIN 2026 badge, CatchTable reservations and journal posts dated 2026.10.13, 10.14 and 10.30; Michelin card lists One Star in the 2026 Guide | https://hakusi.kr
--   Group 1 | ve_50be2d0d8e | Jara by Martín Berasategui | OPEN/strong | OpenTable page shows live booking slots dated 2026-11-02; Michelin card has no closure note; The Lana (Dorchester Collection) page offers online booking. | https://opentable.jp/r/jara-by-martin-berasategui-dubai
--   Group 1 | ve_007ed23db8 | La Sirena | OPEN/medium | OpenTable page for Marcello's La Sirena (6316 S Dixie Hwy) shows a live booking widget set to 2 Nov 2026, dinner hours Wed-Sun, reviews through 23 May 2026, and cites a P | https://www.opentable.co.uk/marcellos-la-sirena
--   Group 1 | ve_71d370a063 | Mostly Harmless | OPEN/strong | Yonder city guide (17 Jul 2026) lists Mostly Harmless at 110 Queen's Road West, Sai Ying Pun, Tue-Sun 17:00-midnight with no closure; Time Out HK listing carried a 4 Sep  | https://www.yonder.fr/cityguides/hong-kong/night-life/mostly-harmless
--   Group 1 | ve_d4468950ef | Nite Kong | OPEN/medium | nitekong.com (last modified 17 Apr 2026) presents Nite Kong as a cocktail bar of Drink Kong with a BOOK NOW link to the Campo Marzio booking page. drinkkong.com links to  | https://www.nitekong.com
--   Group 1 | ve_b1b42b2c4c | Outram Park Fried Kway Teow Mee (#02-17) | OPEN/strong | Seth Lui article (updated 31 Jul 2026) reports no closure, lists the Hong Lim #02-17 stall's hours (Tue-Sat 6am-3pm) and says the author queued there on two consecutive d | https://sethlui.com/char-kway-teow-showdown-singapore/
--   Group 1 | ve_63a6f6253e | Pierre's TT | OPEN/strong | Tbreak (2026-09-05) says it reopened for the 2026 dining season after a summer pause, Tue-Sat dinner, taking reservations; Michelin card shows no closure note. | https://tbreak.com/pierres-tt-dubai-new-dining-season/
--   Group 1 | ve_c3fc87c499 | Pitiona | OPEN/medium | OpenTable Germany listing for Pitiona Cocina de Autor shows 'reserved 12 times today' and a 1,201-review rating, so live booking. No closure notice seen; no official site | https://opentable.de/features/neighborhood-gem-restaurants-oaxaca-oaxaca
--   Group 1 | ve_06e7909221 | Ristorante Locanda Orico da Albrici | OPEN/strong | locandaorico.ch posts a 2026 notice: closed 19 July to 17 August 2026, reopening 18 August; regular lunch and dinner hours, closed Sun and Mon. | https://www.locandaorico.ch
--   Group 1 | ve_44b74070e1 | Roti Chaofa Phuket | OPEN/medium | Michelin card live with no closure note (Tue-Sun 06:30-13:30, 44 Chaofa Rd); Phuket101 page last updated Sept 14 2026 lists the same hours and address. | https://guide.michelin.com/en/phuket-region/phuket/restaurant/roti-chaofa
--   Group 1 | ve_fd4e1302bc | Santos y Desamparados | OPEN/strong | Visit Madrid tourism page (updated 22 Jun 2026) lists the bar at Costanilla de los Desamparados 4 with hours Sun-Fri 19:00-03:00, Sat to 03:30; Que.es (31 Jul 2026) descr | https://www.esmadrid.com/noche/santos-desamparados
--   Group 1 | ve_71b12b0051 | Vetri Cucina | OPEN/strong | OpenTable page, fetched Nov 2 2026, has a live reservation widget defaulting to Nov 2 2026, dinner daily, and menu pricing for New Year's Eve 12.31.26 and December 2026 p | https://www.opentable.com/r/vetri
--   Group 2 | ve_fbf30f35ca | 16âme | OPEN_SEASONAL/strong | Serre Chevalier tourism page lists 2026-27 opening periods: Fri and weekends 4-20 Dec 2026, Tue-Sun 21 Dec 2026 to 14 Mar 2027, then Fri and weekends to 25 Apr 2027. It w | https://www.serre-chevalier.com/en/go-out/restaurants/16ame
--   Group 2 | ve_fe72a55b3c | Beef Club | OPEN_SEASONAL/medium | Serfaus-Fiss-Ladis tourism listing for Beef Club (Schlosshotel Fiss) shows it closed 13 Jun to 7 Dec 2026 and open Tue-Sat 18:30-23:30 from 8 Dec 2026 to 4 Apr 2027. Mich | https://serfaus-fiss-ladis.at/en/Villages-region/From-A-Z/Beef-Club_isd_157541
--   Group 2 | ve_e841e49aae | Bruderherz Fine Dine | OPEN_SEASONAL/medium | Serfaus-Fiss-Ladis tourism page for the restaurant lists 04/10-03/12/2026 as 'Closed' (a planned break, 4 Oct to 3 Dec 2026), shows a 'Michelin 2026' image and gives Ober | https://serfaus-fiss-ladis.at/en/Villages-region/From-A-Z/Bruderherz-Fine-Dine_isd_135920
--   Group 2 | ve_360a80b032 | Fine Dining Ecco St. Moritz | OPEN_SEASONAL/medium | Graubünden tourism page lists Ecco St. Moritz (Via Maistra 3, Champfèr) as open 19:00-23:00 daily 12 Dec 2025-15 Mar 2026 and 16 Dec 2026-14 Mar 2027, closed 16 Mar-15 De | https://www.graubuenden.ch/de/gastronomie/ecco-st-moritz
--   Group 2 | ve_d9a2af4de3 | Gourmetrestaurant Gütsch by Markus Neff | OPEN_SEASONAL/strong | Own site lists winter 2025/26 (Dec 13 2025 to Apr 6 2026) and summer 2026 (Jun 27 to Oct 18 2026) seasons; mountain restaurant at Gütsch-Express station, so closed now be | https://www.guetsch.com
--   Group 2 | ve_719794767d | Restaurant La Table d'Adrien | OPEN_SEASONAL/strong | Verbier tourist office listing (updated 10 Oct 2026) gives the 2026-27 season as 11 Dec 2026 to 14 Mar 2027, Tue-Sat 19:00-22:00. Relais & Châteaux and MySwitzerland page | https://www.verbier.ch/en/practice/taste-restaurants-and-bars/la-table-dadrien-verbier-en-2923066
--   Group 2 | ve_9cc44ba52f | Restaurant Ötztaler Stube | OPEN_SEASONAL/medium | Hotel Das Central's own page shows dining Wed-Sat from 6.30 pm, an unlabeled date range '04.11. - 17.04.2027' beside the hours, online table booking, and a package runnin | https://central-soelden.com/en/gourmet/culinary-and-wine/oetztaler-stube.html
--   Group 2 | ve_0a64d6733c | Ristorante Capri | OPEN_SEASONAL/medium | Zermatt tourism page for Ristorante Capri (Mont Cervin Palace) shows it closed 30 Mar-18 Dec 2026 and 'Open from Sat, 19 Dec 2026'; Tue-Sun 19:00-22:00 in winter season. | https://zermatt.swiss/en/p/ristorante-capri-mont-cervin-palace-01tVj000005DlKxIAK
--   Group 3 | ve_8b5854c9bd | Alma by Juan Amador | OPEN/medium | Time Out Singapore page last updated 5 Aug 2026 lists current hours (Wed-Fri lunch, Mon-Sat dinner) with no closure notice; recipe.net lists it at Goodwood Park Hotel, 22 | https://www.timeout.sg/restaurant/alma-by-juan-amador
--   Group 3 | ve_4025b6f6ff | Alpine Gourmet Prato Borni | OPEN_SEASONAL/medium | Grand Hotel Zermatterhof's own page lists Thu-Mon 19:00-22:00, online reservations, Bahnhofstrasse 55, no closure notice. A Zermatterhof menu PDF uploaded Feb 2026 is hea | https://www.zermatterhof.ch/restaurants-and-bars/alpine-gourmet-prato-borni/?lang=en
--   Group 3 | ve_97d2dab781 | Amal Restaurant Armani Hotel - Burj khalifa | OPEN/medium | Armani Hotels' Dec 2025 festive PDF lists Armani/Amal set menus for 20-31 Dec; hotel dining page still names Armani/Amal; Eat App page shows a Book a table button and hou | https://www.armanihotels.com/wp-content/uploads/2025/12/Festive-season-at-Armani-2026.pdf
--   Group 3 | ve_856c6504e9 | Art di Daniele Sperindio | OPEN/medium | Venue site lists address 1 St Andrews Road, National Gallery Singapore #06-02 and hours Tue-Sun lunch and dinner, no closure notice; page undated. | https://artdidanielesperindio.com/locateus
--   Group 3 | ve_f9a29e6145 | BOCA | OPEN/medium | Venue's own site lists current hours at Gate Village 6, DIFC, and announces a Michelin Green Star; no closure notice. OpenTable listing shows hours daily 12:00-02:00 (und | https://boca.ae/
--   Group 3 | ve_4ad7a410e1 | Burjé1968 - Bistrot&Terrace | OPEN_SEASONAL/medium | burje1968.it (copyright 2026) says the bistro at Str. Burje 11, Corvara, is open to the public daily 12:00-13:45, booking by phone or email, linked to Hotel Arkadia. The  | https://www.burje1968.it
--   Group 3 | ve_5d8567bd4f | Bvlgari Il Ristorante - Luca Fantin | OPEN/medium | Bvlgari Hotels' own page announces a four-hands dinner with Kyoto Kitcho on 15-16 November and a Gambero Rosso Three Forks award, with no closure notice, but the year is  | https://www.bulgarihotels.com/fr_FR/tokyo-osaka-restaurants/whats-on/article/tokyo-osaka/at-the-hotel/La-Cucina-di-Luca-Fantin
--   Group 3 | ve_fe597436c3 | CUR8 | OPEN/medium | SunStar (14 Nov 2025) lists Cur8, Banilad Town Center, among Michelin Guide Cebu 2026 Bib Gourmand awardees; Infatuation page updated 4 Dec 2025 with no closure note. | https://www.sunstar.com.ph/cebu/complete-list-michelin-guide-2026-awardees-in-cebu
--   Group 3 | ve_cb170b74ab | Castellana Restaurant | OPEN/medium | Castellana's own site shows an address at 1/F Club Lusitano Building, 16 Ice House Street, Central, a reservation link, hours (Wine Table Mon-Sat from 5:30pm) and no clos | https://castellanahongkong.com/
--   Group 3 | ve_bb28803745 | Dot Bar Drinkery & Kitchen | OPEN/medium | The Dot Magazine's best cocktail bars guide (modified 27 Nov 2025) lists Dot Bar, Floor 3, 75 Hai Ba Trung, District 1, as moved to a much bigger location, active. Tatler | https://thedotmagazine.com/the-best-cocktail-bars-in-ho-chi-minh-city/
--   Group 3 | ve_c96bcd051e | Eat and Cook - Best Fine Dining KL | OPEN/medium | Michelin card for Eat and Cook (Bandar Bukit Jalil, KL) shows a regular schedule, closed Mon/Tue, with no closure note. FunNow lists Eat and Cook booking with a RM 50 dep | https://guide.michelin.com/en/kuala-lumpur-region/kuala-lumpur/restaurant/eat-and-cook
--   Group 3 | ve_72e993e4a4 | Esora | OPEN/weak | Time Out Singapore's listing (15 Mohamed Sultan Road; last updated 6 Aug 2026) shows current hours and an autumn menu with no closure notice. An Eatapp page shows Wed-Sun | https://www.timeout.sg/restaurant/esora
--   Group 3 | ve_cdb234e39f | Flora (Food & Wine) | OPEN/medium | Michelin card (Grão Vasco 21, Viseu) shows hours and no closure note, and its description refers to the 2026 Portugal edition where Flora holds a Bib Gourmand. | https://guide.michelin.com/pt/pt_PT/viseu-region/viseu/restaurant/flora-1210835
--   Group 3 | ve_5f73c18166 | Gourmetrestaurant Schlossherrnstube | OPEN/medium | Michelin card (Dorfstr. 85, Ischgl) shows One Star in the 2026 MICHELIN Guide Austria, no closure note, hours Thu-Sat evenings. | https://guide.michelin.com/en/tirol/ischgl/restaurant/schlossherrnstube
--   Group 3 | ve_5126fcd962 | Howard's Gourmet | OPEN/medium | Lai Sun Dining group site (howardsgourmet.com redirects there) lists Howard's Gourmet at 5/F CCB Tower, 3 Connaught Rd Central, with hours and booking contacts, no closur | https://laisundining.com/
--   Group 3 | ve_ae2f9ac9ac | ILUKA | OPEN/medium | Venue site (last modified 28 Oct 2025) lists dinner Tue-Sat at Peder Skrams Gade 15, online booking, and planned closures for Feb 2026 with a reopening date, so it planne | https://restaurantiluka.dk
--   Group 3 | ve_a726b58f0e | Jerár | OPEN/medium | Ta Nea (16 Jan 2026) describes Jerar in Dafni in the present tense as a lit, award-winning bistro-style restaurant with an open kitchen; Michelin card (Bib Gourmand) and  | https://www.tanea.gr/print/2026/01/16/lifearts/blue-diary/i-upper-class-katiforizei-sti-dafni-kai-ti-drapetsona/
--   Group 3 | ve_63997a9912 | Kinship | OPEN/medium | Michelin Guide's 18 Nov 2025 Washington DC ceremony article lists Kinship (Eric Ziebold, Célia Laurent) with one star. OpenTable page shows 1015 7th St NW dinner hours an | https://guide.michelin.com/en/article/michelin-guide-ceremony/all-the-stars-in-the-michelin-guide-washington-d.c.-2025
--   Group 3 | ve_43736eeb52 | La Dame de Pic - One Za'abeel | OPEN/medium | Michelin card (25th floor, The Link, One&Only One Za'abeel) has no closure note; Anne-Sophie Pic's site and ladamedepicdubai.com list Tue-Sat hours with a SevenRooms book | https://guide.michelin.com/en/dubai-emirate/dubai/restaurant/la-dame-de-pic-dubai
--   Group 3 | ve_a91476b875 | Mural Farmhouse | OPEN/medium | Michelin card (Gmunder Strasse 27, WunderLocke hotel, Sendling) shows no closed note, lists Mon-Sun hours, 1 star + Green Star; Locke page lists Mural Farmhouse with a Ch | https://guide.michelin.com/be/nl/bayern/mnchen/restaurant/mural-farmhouse
--   Group 3 | ve_d783347096 | Oshino | OPEN/medium | Venue site (oshino.sg) lists Raffles Hotel Shopping Arcade #01-11, 328 North Bridge Road, with lunch and dinner hours, an online reservation link and no closure notice; u | https://www.oshino.sg
--   Group 3 | ve_aea4740c84 | Parador la Huella | OPEN_SEASONAL/medium | Official site paradorlahuella.com is live with a reservation link and no closure notice. El Observador (14 Dec 2025) describes La Huella as active, preparing for its summ | https://www.paradorlahuella.com
--   Group 3 | ve_a3d506a9e2 | Paznauerstube | OPEN_SEASONAL/medium | Trofana Royal's own gourmet page lists the Paznaunerstube with online booking, email/phone reservations, a winter 2025-26 menu card and a 'MICHELIN Stern 2026' mention. N | https://www.trofana-royal.at/en/gourmet/gourmet-restaurants/
--   Group 3 | ve_c50a153c74 | Restaurant 1877 | OPEN/medium | restaurant1877.no shows hours (dinner from 18:00 Mon-Fri), a 'book table' link and gift cards, with no closure notice (page last modified 10 Oct 2024). Fjord Norway lists | https://restaurant1877.no
--   Group 3 | ve_d6b10893f2 | Restaurant Berggericht | OPEN/medium | Tyrol.com tourism listing shows Berggericht at Hinterstadt 15, 6370 Kitzbühel open daily 12:00-16:00 for the coming days, with no closure or season break noted. Kitzbühel | https://www.tyrol.com/activities/food/restaurants/berggericht
--   Group 3 | ve_bf7024c9b1 | Restaurant L'equateur | OPEN/medium | Tabelog shows L'Equateur (3-6-34 Motoazabu) taking reservations (omakase only); it closed end of 2022 and reopened about a year later under owner-sommelier Hirokazu Kawas | https://ssl.tabelog.com/en/tokyo/A1307/A130702/13121866/
--   Group 3 | ve_b69774d8b6 | Restaurant LeMontBlanc | OPEN/medium | Michelin card shows daily hours with no closure note; MySwitzerland page for LeCrans lists dinner hours and a starred-restaurant offer valid 30.10.2026 to 01.12.2026. | https://guide.michelin.com/lt/en/wallis/crans-montana/restaurant/le-montblanc
--   Group 3 | ve_46babcc6b2 | SAN Sablon | OPEN/medium | sansablon.be shows current tasting menus, dinner Tue-Sat and lunch Fri-Sat, booking page and phone, with no closure notice; its only closure notices are Aug 2024 and 24 D | https://www.sansablon.be
--   Group 3 | ve_b4cb7d747c | Samia’s Dish | OPEN/medium | Listmag (15 Dec 2025) lists Samia's Dish, Ahmad Al Attas, Al Zahra, Jeddah, among the Bib Gourmands of the inaugural Michelin Guide Saudi Arabia. The Michelin card is liv | https://www.listmag.com/en/eat-drink/experiences/michelin-guide-bib-gourmand-restaurants-saudi-arabia
--   Group 3 | ve_a3dcd4d0cd | Teible | OPEN/medium | Michelin card (Jameel Arts Centre, Jaddaf Waterfront) has no closure note; OpenTable listing shows hours and a Summer Restaurant Week menu (undated). | https://guide.michelin.com/en/dubai-emirate/dubai/restaurant/teible
--   Group 3 | ve_6698b9aa28 | Testina | OPEN/medium | Michelin Guide card (3F, 8 Lyndhurst Terrace) is live with hours and no closed note, and testina.hk shows hours and a 'Book a table' button at the same address. An older  | https://guide.michelin.com/en/hong-kong-region/hong-kong/restaurant/testina
--   Group 3 | ve_c3eabbb9f8 | The Continental | OPEN/medium | The Upper House's own page for The Continental (Unit 406, L4 Pacific Place, 88 Queensway) shows daily hours, recurring brunch and happy hour, an afternoon tea promotion ' | https://www.upperhouse.com/hongkong/restaurants-and-bars/the-continental
--   Group 3 | ve_e2777cbdc0 | Ullrs Wine & Dine | OPEN_SEASONAL/medium | Tirol tourism listing says 'Geoeffnet im Winter' (open in winter; summer half board only, no a la carte), Alte Arlbergstrasse 2, in the Ullrhaus hotel; Falstaff hotel pag | https://www.tirol.at/aktivitaeten/kulinarik/gastronomie/ullrs-winedine
--   Group 3 | ve_d043456f0b | Wagyumafia | OPEN/medium | Wagyumafia's own site lists WAGYUMAFIA HONG KONG at Shop 1B, G/F, 32 Oi Kwan Rd, Wan Chai (opened fall 2018) with a reservation link and no closure notice. Time Out HK li | https://wagyumafia.com/pages/reservation
--   Group 6 (moved) | ve_9041097ddd | HODAN | MOVED/strong | Hurriyet Daily News (Sept 26 2026) says Hodan moved to Nisantasi about two months earlier after 4.5 years in its historic Beyoglu building. The restaurant continues under | https://www.hurriyetdailynews.com/amp/sometimes-a-chefs-greatest-skill-is-knowing-when-not-to-intervene-227353
BEGIN;
DO $fix$
DECLARE
  aud_max bigint; n bigint; s text;
  va constant text[] := ARRAY['ve_007ed23db8','ve_06e7909221','ve_0a64d6733c','ve_0d0ff2027e','ve_271991cc7f','ve_3205d5e257','ve_360a80b032','ve_4025b6f6ff','ve_43736eeb52','ve_44b74070e1','ve_46babcc6b2','ve_4ad7a410e1','ve_50be2d0d8e','ve_5126fcd962','ve_5d8567bd4f','ve_5f73c18166','ve_63997a9912','ve_63a6f6253e','ve_65ed1f31ff','ve_6698b9aa28','ve_6ad36e0dca','ve_719794767d','ve_71b12b0051','ve_71d370a063','ve_72e993e4a4','ve_7b26d42de5','ve_856c6504e9','ve_8b5854c9bd','ve_9041097ddd','ve_97d2dab781','ve_9cc44ba52f','ve_a3d506a9e2','ve_a3dcd4d0cd','ve_a726b58f0e','ve_a91476b875','ve_ae2f9ac9ac','ve_aea4740c84','ve_b1b42b2c4c','ve_b4cb7d747c','ve_b69774d8b6','ve_bb28803745','ve_bf7024c9b1','ve_c3eabbb9f8','ve_c3fc87c499','ve_c50a153c74','ve_c96bcd051e','ve_cb170b74ab','ve_ccc40ebfb6','ve_cdb234e39f','ve_d043456f0b','ve_d4468950ef','ve_d6b10893f2','ve_d783347096','ve_d9a2af4de3','ve_e2777cbdc0','ve_e841e49aae','ve_e889827c8f','ve_efad8f7bba','ve_f9a29e6145','ve_fbf30f35ca','ve_fd4e1302bc','ve_fe597436c3','ve_fe72a55b3c'];
BEGIN
  -- PRE gates
  IF (SELECT count(*) FROM venues) <> 11296 OR (SELECT count(*) FROM venues WHERE status='active') <> 10925 OR (SELECT count(*) FROM venues WHERE status='closed') <> 371 THEN RAISE EXCEPTION 'venues before'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 10925 THEN RAISE EXCEPTION 'cities before'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts x ON x.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(x.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published before'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'active not published before'; END IF;
  IF (SELECT count(*) FROM listings) <> 11296 OR (SELECT count(*) FROM listings WHERE property_id <> 'eats') <> 0 THEN RAISE EXCEPTION 'listings before'; END IF;
  IF (SELECT count(*) FROM awards) <> 25097 OR (SELECT count(*) FROM slugs) <> 13017 OR (SELECT count(*) FROM price) <> 7728 THEN RAISE EXCEPTION 'awards slugs price before'; END IF;
  IF (SELECT max(id) FROM source_capture_ledger) <> 234 THEN RAISE EXCEPTION 'ledger before'; END IF;
  SELECT count(*), max(id) INTO n, aud_max FROM audit_log; IF n <> 118608 OR aud_max <> 124122 THEN RAISE EXCEPTION 'audit before % / %', n, aud_max; END IF;
  SELECT md5(string_agg(v.id||'|'||v.name||'|'||v.status||'|'||v.city_id, E'\n' ORDER BY v.id COLLATE "C")) INTO s FROM venues v WHERE v.id = ANY (va);
  IF s IS DISTINCT FROM '5c49415e91226dfada01c83cec0e2e31' THEN RAISE EXCEPTION 'venue fingerprint %', s; END IF;
  SELECT md5(string_agg(c.id||'|'||c.venues_count, E'\n' ORDER BY c.id COLLATE "C")) INTO s FROM cities c WHERE c.id IN (SELECT DISTINCT city_id FROM venues WHERE id = ANY (va));
  IF s IS DISTINCT FROM '59b0128b6a1d8e4780a105d542829328' THEN RAISE EXCEPTION 'city fingerprint %', s; END IF;
  -- WRITE
  UPDATE venues SET status='active' WHERE id = ANY (va) AND status='closed';
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 63 THEN RAISE EXCEPTION 'status %', n; END IF;
  UPDATE listings SET published=true WHERE venue_id = ANY (va) AND NOT published;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 63 THEN RAISE EXCEPTION 'published %', n; END IF;
  UPDATE cities SET venues_count=1 WHERE id='ci_05c47b3c01' AND venues_count=0;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_05c47b3c01 %', n; END IF;
  UPDATE cities SET venues_count=3 WHERE id='ci_0851b3c43e' AND venues_count=2;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_0851b3c43e %', n; END IF;
  UPDATE cities SET venues_count=3 WHERE id='ci_0c52bfa385' AND venues_count=2;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_0c52bfa385 %', n; END IF;
  UPDATE cities SET venues_count=60 WHERE id='ci_12fff1be2f' AND venues_count=59;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_12fff1be2f %', n; END IF;
  UPDATE cities SET venues_count=4 WHERE id='ci_1aa09e24a1' AND venues_count=3;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_1aa09e24a1 %', n; END IF;
  UPDATE cities SET venues_count=267 WHERE id='ci_1b1537ad28' AND venues_count=261;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_1b1537ad28 %', n; END IF;
  UPDATE cities SET venues_count=22 WHERE id='ci_1d6bd4e16a' AND venues_count=21;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_1d6bd4e16a %', n; END IF;
  UPDATE cities SET venues_count=1 WHERE id='ci_2313d96a22' AND venues_count=0;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_2313d96a22 %', n; END IF;
  UPDATE cities SET venues_count=35 WHERE id='ci_2609eaea1a' AND venues_count=34;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_2609eaea1a %', n; END IF;
  UPDATE cities SET venues_count=41 WHERE id='ci_3531a466fc' AND venues_count=40;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_3531a466fc %', n; END IF;
  UPDATE cities SET venues_count=1 WHERE id='ci_37f9e52c21' AND venues_count=0;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_37f9e52c21 %', n; END IF;
  UPDATE cities SET venues_count=89 WHERE id='ci_3c40d285e6' AND venues_count=82;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_3c40d285e6 %', n; END IF;
  UPDATE cities SET venues_count=5 WHERE id='ci_4e9eaa94e2' AND venues_count=4;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_4e9eaa94e2 %', n; END IF;
  UPDATE cities SET venues_count=3 WHERE id='ci_4f0386c7a6' AND venues_count=2;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_4f0386c7a6 %', n; END IF;
  UPDATE cities SET venues_count=48 WHERE id='ci_60d99e58d6' AND venues_count=47;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_60d99e58d6 %', n; END IF;
  UPDATE cities SET venues_count=40 WHERE id='ci_6763bf4daf' AND venues_count=39;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_6763bf4daf %', n; END IF;
  UPDATE cities SET venues_count=71 WHERE id='ci_79cca97018' AND venues_count=70;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_79cca97018 %', n; END IF;
  UPDATE cities SET venues_count=2 WHERE id='ci_7de0049ee5' AND venues_count=0;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_7de0049ee5 %', n; END IF;
  UPDATE cities SET venues_count=4 WHERE id='ci_8012e949be' AND venues_count=2;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_8012e949be %', n; END IF;
  UPDATE cities SET venues_count=1 WHERE id='ci_83ac2e08cc' AND venues_count=0;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_83ac2e08cc %', n; END IF;
  UPDATE cities SET venues_count=69 WHERE id='ci_8f6599a3a1' AND venues_count=68;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_8f6599a3a1 %', n; END IF;
  UPDATE cities SET venues_count=28 WHERE id='ci_8fde6a6592' AND venues_count=26;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_8fde6a6592 %', n; END IF;
  UPDATE cities SET venues_count=6 WHERE id='ci_91b1fd2bea' AND venues_count=5;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_91b1fd2bea %', n; END IF;
  UPDATE cities SET venues_count=27 WHERE id='ci_954918891f' AND venues_count=26;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_954918891f %', n; END IF;
  UPDATE cities SET venues_count=3 WHERE id='ci_9ae6a3ac12' AND venues_count=2;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_9ae6a3ac12 %', n; END IF;
  UPDATE cities SET venues_count=1 WHERE id='ci_a1ac06771f' AND venues_count=0;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_a1ac06771f %', n; END IF;
  UPDATE cities SET venues_count=5 WHERE id='ci_a28019996b' AND venues_count=4;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_a28019996b %', n; END IF;
  UPDATE cities SET venues_count=3 WHERE id='ci_b6540200be' AND venues_count=1;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_b6540200be %', n; END IF;
  UPDATE cities SET venues_count=120 WHERE id='ci_b90bbd2b87' AND venues_count=119;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_b90bbd2b87 %', n; END IF;
  UPDATE cities SET venues_count=1 WHERE id='ci_c0b4e31f3f' AND venues_count=0;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_c0b4e31f3f %', n; END IF;
  UPDATE cities SET venues_count=25 WHERE id='ci_c1fd4f351f' AND venues_count=24;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_c1fd4f351f %', n; END IF;
  UPDATE cities SET venues_count=1 WHERE id='ci_cddd747a2c' AND venues_count=0;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_cddd747a2c %', n; END IF;
  UPDATE cities SET venues_count=204 WHERE id='ci_d3197fb64e' AND venues_count=198;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_d3197fb64e %', n; END IF;
  UPDATE cities SET venues_count=124 WHERE id='ci_d793880d5b' AND venues_count=123;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_d793880d5b %', n; END IF;
  UPDATE cities SET venues_count=4 WHERE id='ci_dbbbbf2eff' AND venues_count=3;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_dbbbbf2eff %', n; END IF;
  UPDATE cities SET venues_count=2 WHERE id='ci_e0e34c5ad0' AND venues_count=1;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_e0e34c5ad0 %', n; END IF;
  UPDATE cities SET venues_count=5 WHERE id='ci_e6464db2fa' AND venues_count=4;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_e6464db2fa %', n; END IF;
  UPDATE cities SET venues_count=76 WHERE id='ci_ed2539fe89' AND venues_count=75;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_ed2539fe89 %', n; END IF;
  UPDATE cities SET venues_count=593 WHERE id='ci_ef0cc10ff4' AND venues_count=591;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_ef0cc10ff4 %', n; END IF;
  UPDATE cities SET venues_count=13 WHERE id='ci_f5216cfefa' AND venues_count=12;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_f5216cfefa %', n; END IF;
  UPDATE cities SET venues_count=24 WHERE id='ci_f579627674' AND venues_count=23;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_f579627674 %', n; END IF;
  UPDATE cities SET venues_count=2 WHERE id='ci_fa946ae620' AND venues_count=1;
  GET DIAGNOSTICS n = ROW_COUNT; IF n <> 1 THEN RAISE EXCEPTION 'city ci_fa946ae620 %', n; END IF;
  -- POST gates
  IF (SELECT count(*) FROM venues) <> 11296 OR (SELECT count(*) FROM venues WHERE status='active') <> 10988 OR (SELECT count(*) FROM venues WHERE status='closed') <> 308 THEN RAISE EXCEPTION 'venues after'; END IF;
  IF (SELECT sum(venues_count) FROM cities) <> 10988 THEN RAISE EXCEPTION 'cities after'; END IF;
  IF (SELECT count(*) FROM cities c LEFT JOIN city_venue_counts x ON x.city_id=c.id WHERE c.venues_count IS DISTINCT FROM coalesce(x.active_venues,0)) <> 0 THEN RAISE EXCEPTION 'city view after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND l.published) <> 0 THEN RAISE EXCEPTION 'closed published after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='closed' AND NOT l.published) <> 308 THEN RAISE EXCEPTION 'closed not published after'; END IF;
  IF (SELECT count(*) FROM listings l JOIN venues v ON v.id=l.venue_id WHERE v.status='active' AND NOT l.published) <> 0 THEN RAISE EXCEPTION 'active not published after'; END IF;
  IF (SELECT count(*) FROM awards) <> 25097 OR (SELECT count(*) FROM slugs) <> 13017 OR (SELECT count(*) FROM price) <> 7728 THEN RAISE EXCEPTION 'awards slugs price after'; END IF;
  IF (SELECT max(id) FROM source_capture_ledger) <> 234 THEN RAISE EXCEPTION 'ledger after'; END IF;
  SELECT string_agg(table_name||':'||action||'='||c, ',' ORDER BY table_name COLLATE "C", action COLLATE "C") INTO s
    FROM (SELECT table_name, action, count(*) c FROM audit_log WHERE id > aud_max GROUP BY 1,2) z;
  IF s IS DISTINCT FROM 'cities:UPDATE=42,listings:UPDATE=63,venues:UPDATE=63' THEN RAISE EXCEPTION 'audit: %', s; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > aud_max AND table_name='venues' AND row_pk = ANY (va) AND (old_row-'status')=(new_row-'status') AND old_row->>'status'='closed' AND new_row->>'status'='active') <> 63 THEN RAISE EXCEPTION 'audit status rows'; END IF;
  IF (SELECT count(*) FROM audit_log WHERE id > aud_max AND table_name='listings' AND row_pk = ANY (va) AND (old_row-'published')=(new_row-'published') AND old_row->>'published'='false' AND new_row->>'published'='true') <> 63 THEN RAISE EXCEPTION 'audit published rows'; END IF;
  RAISE NOTICE 'OK: all gates passed';
END
$fix$;
COMMIT;
