/**
 * importOptionB.gs  —  regenerated 2026-07-18
 *
 * FULL Option B set: 131 existing rows (restaurants) + 10 new (bars) = 141 rows total.
 * Replacing the whole file is safe — nothing already done is lost.
 *
 * Writes blurb_short, blurb_long and chef onto matching rows of the "venues" sheet.
 * Matches by slug. When a slug is shared by more than one venue row (twin rows),
 * the "city" field picks the correct one, so a blurb can never land on the wrong city.
 * Touches ONLY those three columns. Never modifies awards, status, coords, or venues.ts.
 */

var OPTION_B = [
  {
    "slug": "piazza-duomo",
    "city": "Alba",
    "chef": "Enrico Crippa",
    "blurb_short": "Behind a famous red door in Alba, a soft-pink room serving some of Piedmont's most personal cooking.",
    "blurb_long": "Up the stair, past a Francesco Clemente fresco, Chef Enrico Crippa builds menus that turn almost entirely on the plant world — vegetables, flowers, and herbs, much of it from the restaurant's own farm and picked the same day. Come in autumn and the Langhe's white truffle takes over; the wine list runs to several volumes and is reason enough to make the trip on its own. Three Michelin stars and a long stay on the World's 50 Best. Worth the detour into truffle country."
  },
  {
    "slug": "le-clos-des-sens",
    "city": "Annecy",
    "chef": "Franck Derouet; Thomas Lorival",
    "blurb_short": "Above Lake Annecy, a fiercely local three-star kitchen where almost everything comes from the alpine lakes, the garden, or within 100 km.",
    "blurb_long": "Le Clos des Sens built its name on a radical idea: a near-total commitment to the local. Founding chef Laurent Petit made it Annecy's first three-star restaurant in 2019 — no coffee, no far-flung spices, just fish from the three alpine lakes, vegetables from a 1,500-square-meter permaculture garden, and foraged plants from the surrounding hills. When Petit stepped away at the end of 2022, two longtime members of the house took over — Chef Franck Derouet in the kitchen and Thomas Lorival running the wine and the room — and held onto all three stars without breaking a thing. The cooking leans vegetal and lacustrine: raw féra lifted by a house garum fermented for weeks, aged pike grilled like red meat, every plate scattered with seasonal flowers and herbs. There's a Green Star, and famously it's one of the more affordable three-stars in France. A serene, deeply rooted evening above the lake."
  },
  {
    "slug": "casa-marcial",
    "city": "Arriondas",
    "chef": "Nacho Manzano",
    "blurb_short": "Deep in the Asturian mountains, a family kitchen built on the exact spot where the family began.",
    "blurb_long": "Casa Marcial sits in a remote hamlet outside Arriondas, ringed by mountains — and on the very ground where Chef Nacho Manzano's grandmother once kept a shop and cider press, where his father later ran a roadside bar and his mother a small country restaurant. He cooks with his sisters Esther in the kitchen and Sandra out front, and his nephew Jesús alongside, and the food is almost entirely about this corner of Asturias: traditional plates like his mother's stewed free-range chicken and the region's beloved fabes, reimagined with modern technique and produce from their own organic garden. Opened in 1993, it earned its first Michelin star in 2000, its second in 2010 and its third in late 2024, along with a Green Star for how seriously they take sustainability. A meal here is really a chef showing you where he's from. Worth getting a little lost in the hills to find."
  },
  {
    "slug": "restaurant-schwarzwaldstube",
    "city": "Baiersbronn",
    "chef": "Torsten Michel",
    "blurb_short": "Deep in the Black Forest, the kitchen that's held three Michelin stars longer than any other in Germany.",
    "blurb_long": "Tucked inside the Traube Tonbach hotel in a pine valley near Baiersbronn, Schwarzwaldstube — \"Black Forest parlor\" — has held three Michelin stars since 1992, the longest unbroken run of any restaurant in Germany. Chef Torsten Michel took the kitchen over in 2016 from the legendary Harald Wohlfahrt and hasn't let the standard slip, working classic French foundations through modern technique with the region's own ingredients. The dining room looks straight out over the valley through floor-to-gable glass, and the wine list and pairings are a destination in themselves. A kitchen fire forced a rebuild a few years back; the cooking never missed a beat. Three Michelin stars, and worth the drive into the forest."
  },
  {
    "slug": "cocina-hermanos-torres",
    "city": "Barcelona",
    "chef": "Sergio Torres; Javier Torres",
    "blurb_short": "In Barcelona, twin brothers built a restaurant that's really one enormous kitchen with tables around it.",
    "blurb_long": "Twin chefs Sergio and Javier Torres opened Cocina Hermanos Torres in 2018 in a converted Barcelona warehouse, and earned three Michelin stars by 2022. The conceit is right there in the room: instead of hiding the kitchen, they put it dead center — cooking islands under soft \"clouds\" of light, with the tables arranged around them, so dinner plays out as theater. The brothers trace it all back to their grandmother Catalina's kitchen, and the Mediterranean cooking leans on seasonal local produce handled with a light touch, like cured squid with poultry consommé and caviar. Three Michelin stars plus a green star for sustainability. Worth building a Barcelona night around."
  },
  {
    "slug": "disfrutar",
    "city": "Barcelona",
    "chef": "Oriol Castro; Eduard Xatruch; Mateu Casañas",
    "blurb_short": "Barcelona's avant-garde wonder — named the best restaurant in the world in 2024.",
    "blurb_long": "Disfrutar (Catalan for \"enjoy\") is run by three chefs — Oriol Castro, Eduard Xatruch and Mateu Casañas — who met in Ferran Adrià's legendary elBulli kitchen and stayed until it closed. They opened here in Barcelona's Eixample in 2014, earned three Michelin stars in 2024, and that same year were named No. 1 on the World's 50 Best. Their cooking is playful, technical Mediterranean wizardry — think a multi-spherical pesto, \"solid bubbles,\" even a living table that changes through the meal — built on the techniques they pioneered and the rest of the fine-dining world now borrows. Two menus, Classic and Festival, in a bright, ceramic-lined room. There's always a waiting list, and it's earned. Book the moment you know your dates."
  },
  {
    "slug": "lasarte",
    "city": "Barcelona",
    "chef": "Martín Berasategui; Paolo Casagrande",
    "blurb_short": "Barcelona's first restaurant to win three Michelin stars — the legendary Martín Berasategui's flagship in the city, run day to day by his longtime protégé.",
    "blurb_long": "Lasarte is the Barcelona embassy of Martín Berasategui, one of the most decorated chefs alive, named for the Basque town where he built his empire. He opened it in 2006 and recruited Chef Paolo Casagrande to lead the kitchen; in 2017 it became the first restaurant in Barcelona ever to hold three Michelin stars. The two have worked side by side for over two decades, and the cooking shows it — Berasategui's iconic dishes alongside Casagrande's own creations, all built on flawless seasonal produce in immaculate balance. The room is one of the most striking in Spain, with undulating ceilings meant to evoke waves and jellyfish-like lamps overhead, inside the five-star Monument Hotel on Passeig de Gràcia. Polished, generous, and right in the heart of the city."
  },
  {
    "slug": "grand-hotel-les-trois-rois",
    "city": "Basel",
    "chef": "Peter Knogl",
    "blurb_short": "Three Michelin stars on the bank of the Rhine, inside one of Europe's oldest grand hotels — French cooking from a self-described king of sauces.",
    "blurb_long": "Cheval Blanc is the flagship restaurant of the Grand Hotel Les Trois Rois, a riverside Basel institution with more than three centuries of history behind it. Chef Peter Knogl has held three Michelin stars here for years with a style all his own: classic French haute cuisine lifted with Mediterranean warmth and quiet Asian accents, built around the product and, above all, the sauce. He's been dubbed the \"king of sauces,\" and he means it — every plate arrives with a spoon so you don't leave a drop behind. Expect impeccable seafood, his celebrated Bresse pigeon, and a room of antiques, chandeliers and Rhine views to match. Among the handful of three-star tables in all of Switzerland, and one of the most consistent anywhere."
  },
  {
    "slug": "atelier-moessmer-norbert-niederkofler",
    "city": "Brunico",
    "chef": "Norbert Niederkofler",
    "blurb_short": "In a former textile villa in the Dolomites, the fullest expression yet of \"Cook the Mountain.\"",
    "blurb_long": "Chef Norbert Niederkofler spent decades developing a single idea — Cook the Mountain, the principle that only what the Alpine region actually produces belongs on the plate — and in 2023 he gave it a home in his hometown of Brunico, inside the nineteenth-century Villa Moessmer, once tied to a famous local wool mill. The discipline is real: no olive oil, no citrus, very little salt, with acidity coming from grapes and berries and preservation done by fermenting, drying and smoking. He renovated the protected building himself, kept its old floors and a fabric sample book on display, and within months had three Michelin stars and a Green Star; in 2025 it landed at number 20 on the World's 50 Best. Each morning the team heads out to see what the mountains will give that day, and you eat the answer from a counter facing the open kitchen. Few restaurants taste this much like the ground they stand on."
  },
  {
    "slug": "l-enclume",
    "city": "Cartmel",
    "chef": "Simon Rogan",
    "blurb_short": "In a former blacksmith's workshop in a tiny Lake District village, the first restaurant in northern England to win three stars — built around its own farm.",
    "blurb_long": "Simon Rogan opened L'Enclume in an 800-year-old Cartmel smithy in 2002 (the name is French for \"anvil\"), and over two decades turned a remote Cumbrian village into a serious dining destination. Almost everything on the long, ever-changing tasting menu comes from \"Our Farm,\" a 12-acre plot a mile away that Rogan designed for the kitchen — he likes to say his job is growing the perfect carrot rather than cooking it perfectly. The signature \"Anvil\" dessert nods to the building's past; the village now holds his sister restaurants, a shop, and rooms scattered among the cottages so you can stay the night. Three Michelin stars (a UK-first for the north, awarded 2022), a Green Star, and La Liste's No.1 restaurant in the world for 2024."
  },
  {
    "slug": "la-villa-madie",
    "city": "Cassis",
    "chef": "Dimitri Droisneau",
    "blurb_short": "Perched on a wild cove beneath the dramatic cliffs of Cap Canaille, one of the south of France's handful of three-star tables.",
    "blurb_long": "Chef Dimitri Droisneau came up through some of Paris's most serious kitchens — La Tour d'Argent, Le Bristol, L'Ambroisie under Bernard Pacaud — before he and his wife Marielle took over La Villa Madie in 2013, in the secluded Anse de Corton just east of Cassis. The setting is staggering: a minimalist room and terrace hanging over the Mediterranean below the highest sea cliff in France. Droisneau's cooking is pointedly restrained — rarely more than five elements on a plate — built on his own 3,000-square-meter garden and seafood from nearby Marseille, with a signature carabineros prawn paired with red berries that the Michelin inspectors called celestial. The third star came in 2022. Time a long lunch for the warm months and dine on the water's edge."
  },
  {
    "slug": "geranium",
    "city": "Copenhagen",
    "chef": "Rasmus Kofoed; Søren Ledet",
    "blurb_short": "On the eighth floor above Copenhagen's football stadium, an unlikely setting for one of the world's very best.",
    "blurb_long": "Take the lift up Parken Stadium — yes, the football stadium — to the eighth floor, and you'll find Chef Rasmus Kofoed's Geranium, the first Danish restaurant ever to hold three Michelin stars, with huge windows over the park and a peek at the pitch below. Kofoed cooks with a precision that's honestly a little absurd, and the plates are some of the prettiest you'll see anywhere; he dropped meat entirely in 2022, so the long \"Universe\" menu runs on Scandinavian seafood and biodynamic vegetables and somehow never feels like it's missing a thing. His partner Søren Ledet runs a famously warm room and a drinks list to match, down to a juice pairing that's no afterthought. Topped the World's 50 Best and landed in its hall of fame. Worth every floor of the climb."
  },
  {
    "slug": "noma",
    "city": "Copenhagen",
    "chef": "René Redzepi",
    "blurb_short": "The Copenhagen restaurant that rewrote the rules — New Nordic cooking started here, and the world followed.",
    "blurb_long": "It's genuinely hard to picture the last twenty years of food without it. When Chef René Redzepi opened Noma in a Copenhagen warehouse in 2003, he set out to prove that Nordic ingredients — not foie gras, not caviar — could carry cooking of the very highest order, and the cook-by-the-season idea that the entire restaurant world now takes for granted spread out from this room. He threw out the white tablecloths and the stiff service, too, and had the cooks themselves carry plates to the table. Five turns at No.1 on the World's 50 Best across two incarnations, three Michelin stars. If you only ever build one trip around a restaurant, it's a defensible choice."
  },
  {
    "slug": "le-1947-a-cheval-blanc",
    "city": "Courchevel",
    "chef": "Yannick Alléno",
    "blurb_short": "High in the Alps at Cheval Blanc Courchevel, the ski resort's only three-Michelin-star table — five tables, named for a legendary wine vintage.",
    "blurb_long": "Le 1947 takes its name from the most coveted vintage of Château Cheval Blanc, and the room lives up to it: an intimate, all-white space with just five tables wrapped around an open kitchen, snow-draped peaks filling the windows. Chef Yannick Alléno earned its third Michelin star in 2017 and has held it since, building a contemporary cuisine around superb Savoie ingredients and, above all, his sauces — the fruit of a years-long obsession with extraction and fermentation that genuinely reshaped how French kitchens think about them. It runs only through the winter season, serving a small number of diners each night. A three-star pilgrimage you reach by mountain road, worth planning a whole trip around."
  },
  {
    "slug": "atrio-caceres",
    "city": "Cáceres",
    "chef": "Toño Pérez; José Polo",
    "blurb_short": "In medieval Cáceres, a three-star restaurant as famous for its wine cellar as its cooking.",
    "blurb_long": "Atrio is the decades-long life project of Chef Toño Pérez and his partner, sommelier José Polo — childhood friends who built it inside the UNESCO-listed old town of Cáceres, in Spain's quiet Extremadura. The cooking is Pérez's love letter to the region: Iberian and Extremaduran ingredients run through modern technique, often built into a long tasting menu around a single product. But the cellar is the stuff of legend — one of the great private wine collections anywhere, vast enough that the list comes as a book, and notorious enough that thieves once pulled off a headline-making heist of its rarest bottles. Three Michelin stars, in a contemporary space folded into medieval stone. Worth the trip out to Extremadura."
  },
  {
    "slug": "fzn-by-bjorn-frantzen",
    "city": "Dubai",
    "chef": "Björn Frantzén; Torsten Vildgaard",
    "blurb_short": "The UAE's first three-Michelin-star restaurant — Björn Frantzén's Nordic-Japanese spectacle, high in Atlantis The Palm.",
    "blurb_long": "FZN made history fast: the first restaurant in the United Arab Emirates to earn three Michelin stars, and it did it within months of opening in late 2024. It's the Dubai outpost of Chef Björn Frantzén — whose Stockholm flagship and Singapore sibling are also three-star, making him the only chef anywhere to hold three of them at once — set inside Atlantis The Palm and run day to day by his handpicked executive chef, Torsten Vildgaard. The format is pure Frantzén theatre: a doorbell, a Scandi living room for canapés, a house tour, then a counter around the open kitchen for a nine-course run of Nordic cooking gilded with Japanese precision and luxury seafood. Don't fill up before the miso madeleines at the end. A grand finale in a city that likes them."
  },
  {
    "slug": "restaurant-quique-dacosta",
    "city": "Dénia",
    "chef": "Quique Dacosta",
    "blurb_short": "Chef Quique Dacosta's Dénia restaurant, where the tasting menu is treated as an art form in its own right.",
    "blurb_long": "Chef Quique Dacosta walked in as a 17-year-old in 1989, bought the place in 1999, and put his own name over the door in 2009 — and it shows, because the cooking is unmistakably personal. He rebuilds the menu almost completely every year, treating a meal as something closer to art than dinner; one recent menu, \"Octavo,\" cheekily argues cooking deserves a place alongside the seven classical fine arts. The inspiration keeps circling back to the Mediterranean, and the whole thing is built to lodge in your memory even as it vanishes on the plate. Three Michelin stars and a longtime World's 50 Best name. Go when you're in the mood to be surprised."
  },
  {
    "slug": "aponiente",
    "city": "Cádiz",
    "chef": "Ángel León",
    "blurb_short": "Chef Ángel León's \"kitchen of the sea,\" set in an old tide mill on the Cádiz salt marshes.",
    "blurb_long": "They call Chef Ángel León the Chef of the Sea, and he's earned it: working from a centuries-old tide mill on the marshes outside Cádiz, he's spent over a decade cooking almost entirely from the ocean, and he's the one who introduced edible plankton to fine dining. The meal starts outside, on wooden walkways through recovered estuaries where some of the ingredients are gathered. Inside, the tasting menu runs on things most kitchens discard or never consider — marine \"sausages,\" plankton, lesser-known fish — and even the desserts come from the sea. It was Andalucía's first three-Michelin-star restaurant and holds one of the first-ever Michelin Green Stars for sustainability. Worth the detour into the marshes."
  },
  {
    "slug": "les-pres-d-eugenie-relais-chateaux",
    "city": "Eugénie-les-Bains",
    "chef": "Hugo Souchet; Michel Guérard",
    "blurb_short": "The country estate where Michel Guérard, a founding father of nouvelle cuisine, held three Michelin stars for nearly half a century.",
    "blurb_long": "Michel Guérard — one of the inventors of nouvelle cuisine and the man who put cuisine minceur on the cover of Time — opened Les Prés d'Eugénie with his wife Christine in 1974, in a small spa village in the Landes, and held three Michelin stars there from 1977 until his death in August 2024. Remarkably, the kitchen kept all three the following year: the restaurant is now guided by his daughters Éléonore and Adeline, with head chef Hugo Souchet, who trained alongside Guérard for years preparing exactly this succession. The cooking carries his DNA forward — naturalist, light-handed, precise, marrying diverse flavours with the touch of a conductor. The estate itself is a Relais & Châteaux palace of eight hectares, with several historic buildings, a thermal spa and seven poetic gardens. A meal here is a pilgrimage into French culinary history, served in the lush Gascon countryside."
  },
  {
    "slug": "enoteca-pinchiorri",
    "city": "Florence",
    "chef": "Annie Féolde; Riccardo Monco",
    "blurb_short": "A Florentine legend with one of the greatest wine cellars on earth — the rare Italian three-star you visit as much for the bottles as the plates.",
    "blurb_long": "Enoteca Pinchiorri started as a wine shop, and the wine is still half the legend: a cellar of well over 100,000 bottles and thousands of labels, from Romanée-Conti to early Sassicaia, deep enough that regulars come as much to drink as to eat. Chef Annie Féolde and Giorgio Pinchiorri built it from that wine bar on Via Ghibellina in the 1970s into a fixture of Italian fine dining set in a frescoed Renaissance palazzo; along the way she became the first woman outside France to win three Michelin stars. Today the kitchen is led by Chef Riccardo Monco, whose refined, unshowy Italian cooking lets luxury ingredients speak, and a pastry team turns out a soufflé people remember for years. Bring an appetite, a sense of occasion, and ideally a serious wine budget."
  },
  {
    "slug": "auberge-du-vieux-puits",
    "city": "Fontjoncouse",
    "chef": "Gilles Goujon",
    "blurb_short": "In a tiny Languedoc village, Chef Gilles Goujon's three-star country auberge built on trompe-l'oeil and truffle.",
    "blurb_long": "You have to mean it to get out to Fontjoncouse — barely a village, deep in the Languedoc backcountry — and that's part of the appeal of Chef Gilles Goujon's Auberge du Vieux Puits. He holds three Michelin stars out here, cooking that's deeply rooted in the local market yet full of playful sleight of hand: textures, precise cooking, trompe-l'oeil plates that aren't what they look like. The dish people travel for is his \"rotten\" carrus hen egg — truffled, set over mushroom purée, with a warm briochine and a drinkable cappuccino alongside. Three Michelin stars, genuinely off the beaten path. Worth every kilometer of the detour."
  },
  {
    "slug": "schloss-schauenstein",
    "city": "Fürstenau",
    "chef": "Andreas Caminada",
    "blurb_short": "A 26-year-old took over an empty Swiss castle in 2003 — two decades on, it's one of the Alps' great tables.",
    "blurb_long": "Chef Andreas Caminada cooks inside an honest-to-goodness castle at the foot of Piz Beverin, and there are eleven rooms upstairs if you want to make a real night of it. He builds the menu almost entirely out of Graubünden — a lot of it from the restaurant's own garden — instead of reaching for the usual luxury suspects, so the food tastes like the place you're sitting in. It's wood-clad and warm, big on foraging, and even the no-and-low pairing is something they clearly sweated over. Three Michelin stars and a steady spot on the World's 50 Best. Remote, yes — that's rather the point."
  },
  {
    "slug": "el-celler-de-can-roca",
    "city": "Girona",
    "chef": "Joan Roca; Josep Roca; Jordi Roca",
    "blurb_short": "Three Roca brothers, one restaurant in Girona, and two turns as the best in the world.",
    "blurb_long": "The setup is the secret: Chef Joan Roca runs the savory kitchen, his brother Josep the wine, and Jordi the desserts — they call themselves an equilateral triangle, and four decades in, the geometry holds. The cooking is built on memory and travel and a real environmental conscience, beginning with a run of appetizers that nod to their own greatest hits. It's twice been No.1 on the World's 50 Best and a top-five mainstay since 2009, so tables are coveted — bookings open at midnight on the 1st, eleven months out, and go fast. Three Michelin stars. Mark your calendar and plan the trip around the table you land."
  },
  {
    "slug": "haerlin",
    "city": "Hamburg",
    "chef": "Christoph Rüffer",
    "blurb_short": "After thirteen years at two Michelin stars, Chef Christoph Rüffer took a third in 2025 — Hamburg's second restaurant ever to reach the summit.",
    "blurb_long": "Inside the Fairmont Hotel Vier Jahreszeiten, a grand old address overlooking the Inner Alster lake, Chef Christoph Rüffer has cooked for more than twenty years — patiently, with a style that's grown quieter and more confident rather than flashier. His seasonal menus are built on superb produce and the kind of deeply worked sauces other chefs talk about for days, with langoustine and saddle of venison among the dishes that show him at full stretch. The room is its own pleasure: Chinese silk wallpaper, soft sage-and-cream tones, Nymphenburg porcelain figures for the four seasons. The third Michelin star arrived in 2025, and it had been a long time coming. A serene, old-world Hamburg evening at the top of its game."
  },
  {
    "slug": "amber",
    "city": "Hong Kong",
    "chef": "Richard Ekkebus",
    "blurb_short": "A dairy-free French kitchen high in The Landmark Mandarin Oriental — and one of Hong Kong's most quietly radical rooms.",
    "blurb_long": "Chef Richard Ekkebus has led Amber since 2005, and a few years back he did something almost unheard of at this level: he stripped dairy out of a French kitchen entirely, then gluten, refined sugar and salt, chasing food that's lighter and more healthful without giving up an ounce of finesse. The set menus lean on first-rate produce treated with real care, run vegetarian versions in parallel, and thread sustainability through everything — the restaurant carries a Michelin Green Star alongside its stars. After sixteen straight years at two Michelin stars it was raised to three in 2025, and it's been a regular on the World's 50 Best for years. The room, redone in warm champagne tones, feels like a hush after the noise of Central. One of the most distinctive tables in the city."
  },
  {
    "slug": "caprice",
    "city": "Hong Kong",
    "chef": "Guillaume Galliot",
    "blurb_short": "Contemporary French dining on the sixth floor of the Four Seasons, with Victoria Harbour filling the windows.",
    "blurb_long": "Chef Guillaume Galliot grew up in the Loire Valley and trained in the classical French tradition before spending two decades cooking across Asia, arriving at Caprice in 2017. The food is unabashedly luxurious French — premium ingredients, immaculate technique, a real flair for global accents — and he's known for things like a hot-and-cold onion soup and a Brittany blue lobster roasted in butter. The room is one of the most glamorous in Hong Kong, all crystal chandeliers and an open kitchen, with that harbour view as the backdrop and a cheese trolley and wine list to match. Caprice held three Michelin stars early on, lost the third, then won it back in 2019 and has held all three since. The kind of room that turns dinner into an occasion."
  },
  {
    "slug": "forum-restaurant",
    "city": "Hong Kong",
    "chef": "Wong Lung To",
    "blurb_short": "Hong Kong's \"Abalone King\" built this Causeway Bay institution around one ingredient — and turned it into one of the city's grandest Cantonese rooms.",
    "blurb_long": "Founder Yeung Koon-yat earned the nickname the \"Abalone King\" the hard way: he spent three years learning to prepare a single dried Japanese abalone, slow-braised for the better part of a day on layers of bamboo, ribs, and chicken until the core turns almost sugary. The dish that resulted — Ah Yat abalone, named for him — has been served to Deng Xiaoping and Jacques Chirac and remains the reason people come. Since Yeung's passing in 2023, his longtime apprentice Wong Lung To has kept the kitchen exacting, the calligraphy on the walls, and the prices firmly in \"the rich man's canteen\" territory. Three Michelin stars. Order the abalone days in advance, and don't sleep on the clay-pot fried rice cooked tableside."
  },
  {
    "slug": "hisa-franko",
    "city": "Kobarid",
    "chef": "Ana Roš",
    "blurb_short": "Self-taught Chef Ana Roš put Slovenia on the world's culinary map — and her remote Soča Valley restaurant became the country's first to hold three Michelin stars.",
    "blurb_long": "Chef Ana Roš never trained in a professional kitchen; she was a competitive skier and a diplomacy student before she taught herself to cook at Hiša Franko, the family guesthouse in the green Soča Valley near the Italian border. Her food is the valley itself — wild herbs, mountain dairy, river trout, game and berries gathered nearby — and through a Netflix Chef's Table episode and a World's Best Female Chef title she more or less single-handedly drew the world to a Slovenian village of barely a thousand people. Cult dishes like the corn beignet with fermented cheese and the potato baked in a crust of summer hay anchor a long, personal tasting menu, poured alongside natural Slovenian wines. In 2023 it became the first restaurant in Slovenia to earn three Michelin stars. Remote, warm, and worth every hour of the drive in."
  },
  {
    "slug": "gion-sasaki",
    "city": "Kyoto",
    "chef": "Hiroshi Sasaki",
    "blurb_short": "Kyoto kaiseki with the volume turned up — three Michelin stars and the most fun you'll have at a counter in the old city.",
    "blurb_long": "In a city where fine dining tends toward reverent hush, Gion Sasaki is a happy rebel. Chef Hiroshi Sasaki turned his open kitchen into what regulars call the \"Sasaki Theatre\": he leans across the counter to explain a dish, pour a sake, or spin a story, and the room hums with an energy you don't expect from three-star kaiseki. Don't mistake the warmth for looseness — the cooking is seriously good, modern kaiseki rooted in Kyoto tradition but unafraid to surprise, right down to the brick oven behind the counter. His influence runs deep, too: a whole lineage of his former apprentices now run acclaimed restaurants of their own across the city. Book far ahead, and sit at the counter. Half the show is the chef."
  },
  {
    "slug": "hyotei",
    "city": "Kyoto",
    "chef": "Yoshihiro Takahashi",
    "blurb_short": "Chef Yoshihiro Takahashi is roughly the fifteenth generation to run Hyotei — a Kyoto kaiseki house that began as a teahouse for temple pilgrims more than four hundred years ago.",
    "blurb_long": "Hyotei started as a roadside teahouse serving travelers to Kyoto's Nanzen-ji temple some four centuries ago, and the same family has kept it ever since — Chef Yoshihiro Takahashi now carries it, around fifteen generations on. You dine in separate little tearooms with thatched roofs, set in a garden so old and so quiet it seems to slow time down, over pure, refined kaiseki rooted in the tea ceremony. Two things are unmissable: the famous \"Hyotei egg,\" a soft-boiled egg made to a secret method and served here for over a century, and the morning porridge, supposedly born when a hungry patron turned up at dawn after a long night out. Three Michelin stars, and a living piece of Kyoto. Few meals carry this much history so lightly."
  },
  {
    "slug": "kikunoi-honten",
    "city": "Kyoto",
    "chef": "Yoshihiro Murata",
    "blurb_short": "A century-old Kyoto ryotei at the foot of Higashiyama, run by the chef who helped get washoku recognized by UNESCO.",
    "blurb_long": "Founded in 1912 and now in the hands of third-generation chef Yoshihiro Murata, Kikunoi is Kyoto kaiseki at its most refined — private tatami rooms with their own gardens, menus that turn with the seasons, ingredients available only days a year. The name means \"chrysanthemum well,\" after a spring on the grounds said to have bubbled up in the shape of the flower; its water still goes into the dashi. Murata trades in tradition but isn't bound by it, occasionally folding in Western ingredients, and he's done more than almost anyone to carry Japanese cuisine abroad — he was instrumental in washoku's UNESCO heritage listing. Three Michelin stars. A genuine pilgrimage table for anyone serious about kaiseki."
  },
  {
    "slug": "miyamasou",
    "city": "Kyoto",
    "chef": "Hisato Nakahigashi",
    "blurb_short": "Ninety minutes up into the mountains north of Kyoto, a centuries-old pilgrims' inn where the chef forages nearly everything you eat by his own hand.",
    "blurb_long": "Miyamasou began in the 1890s as a guesthouse for pilgrims walking to the remote Bujō-ji temple, deep in the Hanase mountains, and the same family has run it ever since — fourth-generation chef Hisato Nakahigashi now carries it forward. He trained in France, including at a three-star kitchen, before coming home at 26 to take it on. His cuisine is tsumikusa — \"freshly picked\" — a style descended from the Heian aristocracy's pastime of gathering wild herbs to welcome spring, and Nakahigashi forages most of it himself: wild mountain vegetables in spring, river sweetfish in summer, mushrooms in autumn, bear and boar and venison in winter. You dine, and can stay the night, in a quiet wood building set among trees and a murmuring river. In the 2026 Michelin guide it was promoted to three stars — Kyoto's first new three-star in six years. Few meals taste this completely of the place around them."
  },
  {
    "slug": "mizai",
    "city": "Kyoto",
    "chef": "Hitoshi Ishihara",
    "blurb_short": "Hidden in a lantern-lit pavilion in Kyoto's oldest park, a three-star kaiseki built on the spirit of the tea ceremony — never quite perfect, by design.",
    "blurb_long": "Chef Hitoshi Ishihara trained from age fifteen at the legendary three-star Kitchō Arashiyama, eventually becoming its executive chef, before opening Mizai in 2004 in a discreet pavilion on the edge of Maruyama Park. The name comes from a Zen phrase meaning \"not yet there\" — perfection forever chased, never wholly arrived at — and it sets the tone for a kitchen in permanent pursuit of better. The cooking follows the form of chakaiseki, the tea-ceremony meal: it opens with a simple dish and freshly steamed rice, moves through lavish sashimi and seasonal stews in vessels chosen to announce the time of year, and closes with strong matcha. There's only one seating each evening, at 6pm sharp, and attendants meet you at the park's edge and walk you back out by lantern at the end. Three Michelin stars, and a reservation worth planning a year around."
  },
  {
    "slug": "la-marine",
    "city": "Noirmoutier-en-l'Île",
    "chef": "Alexandre Couillon",
    "blurb_short": "On the windswept tip of Noirmoutier island, a fisherman's son turned a tiny harbor restaurant into one of France's most spellbinding three-star tables.",
    "blurb_long": "Chef Alexandre Couillon and his wife Céline took over his parents' restaurant on the L'Herbaudière harbor in 1999, and over two decades built it into something extraordinary — in 2023 it became the only new restaurant in France to earn three Michelin stars that year, and the first ever in the Vendée. Couillon cooks the island almost literally: the day's catch from the Noirmoutier fish market, coastal plants gathered along the shore, vegetables from his own plots, with braising and live fire doing much of the work. Dishes like charcoal-grilled mackerel with beetroot or flame-grilled lettuce with elderflower vinegar sound humble and land like revelations. There's a Green Star for the restaurant's deep ecological commitment, and a serene new dining room opened in 2025. Remote, salt-sprayed, and worth every mile of the trip out to the island."
  },
  {
    "slug": "christopher-coutanceau",
    "city": "La Rochelle",
    "chef": "Christopher Coutanceau",
    "blurb_short": "A three-Michelin-star ode to the Atlantic, right on the beach in La Rochelle.",
    "blurb_long": "The sign out front reads \"Christopher Coutanceau, chef and fisherman,\" and that about sums it up. Chef Coutanceau grew up fishing these waters and now runs his family's restaurant on La Concurrence beach with partner Nicolas Brossard, building the menu each morning around the local catch and the ocean's own seasons. He's one of the most committed sustainability voices in French cooking — he won the Michelin Guide's first sustainable-gastronomy prize and refuses endangered or spawning species — and he makes a humble sardine sing as readily as turbot or sea urchin. The restaurant earned three Michelin stars in 2020, lost the third in 2023, and won it back in 2025. Look for the seasonal scallop pithiviers. As fresh and briny as a gust off the Atlantic."
  },
  {
    "slug": "azurmendi-jatetxea",
    "city": "Larrabetzu",
    "chef": "Eneko Atxa",
    "blurb_short": "In the hills outside Bilbao, Chef Eneko Atxa's glass-walled temple to sustainable Basque cooking.",
    "blurb_long": "Chef Eneko Atxa was one of the youngest chefs ever to earn a third Michelin star, and he did it at Azurmendi — his first restaurant, opened in 2005 when he was in his twenties. The building is the first thing people talk about: a bioclimatic glass structure built into a Larrabetzu hillside, with a rooftop greenhouse, a seed bank for indigenous Basque species, and geothermal and solar systems woven through it. The long Adarrak tasting menu starts up in that greenhouse, where you see where the meal begins, and runs through dishes like his famous truffled egg \"cooked inside out.\" It won the World's 50 Best Sustainable Restaurant award back in 2014, long before that was a fashionable thing to chase, and has climbed as high as No. 14 on the main list. Three Michelin stars. Worth the trip out from Bilbao."
  },
  {
    "slug": "martin-berasategui",
    "city": "San Sebastián",
    "chef": "Martín Berasategui",
    "blurb_short": "The Basque flagship of Spain's most-decorated chef — three Michelin stars held without a break since 2001, and a tasting menu that doubles as a tour of his career.",
    "blurb_long": "Martín Berasategui learned to cook in his parents' San Sebastián tavern, trained through his teens in France, and in 1993 opened his own restaurant in the hills of Lasarte-Oria, just outside the city. The first star came six months later, the second in 1996, the third in 2001 — and he's held all three ever since, the bedrock of a global empire that has made him the most Michelin-starred chef in Spain. The tasting menu is laid out chronologically, each dish marked with the year he created it, so dinner becomes a walk through four decades of one of modern cooking's most restless minds; the 1993 millefeuille of smoked eel, foie gras and green apple is the dish everyone comes for, and it's as good as its reputation. The room is calm and light, with windows over the green Basque countryside. He calls himself a \"conveyor of happiness.\" Spend an evening here and you'll see why."
  },
  {
    "slug": "la-table-du-castellet",
    "city": "Le Castellet",
    "chef": "Fabien Ferré",
    "blurb_short": "In a luxury Provençal resort near the Paul Ricard racing circuit, the youngest French chef ever to debut straight at three Michelin stars.",
    "blurb_long": "Chef Fabien Ferré spent years as second-in-command to Christophe Bacquié here; when Bacquié left in 2023 and the stars were reset, Ferré stepped up, made the kitchen his own, and in March 2024 pulled off something almost unheard of — three Michelin stars in a single stroke, at 35, the youngest French chef to land directly at the summit. His cooking is a love letter to Provence: Mediterranean seafood and vegetables, minimalist and precise, lifted by full-bodied sauces, with signatures like squid perfumed with marjoram. The contemporary dining room looks out over lavender beds, ponds and the Var hills toward the sea, and the cheese cellar alone — some fifty artisanal varieties you choose yourself — is worth the trip. A genuine special-occasion table in the south of France."
  },
  {
    "slug": "alain-ducasse-at-the-dorchester",
    "city": "London",
    "chef": "Alain Ducasse; Jean-Philippe Blondet",
    "blurb_short": "Contemporary French haute cuisine inside one of Mayfair's grand hotels — three Michelin stars, held for over a decade.",
    "blurb_long": "Chef Alain Ducasse — one of the most decorated chefs alive, with three-star rooms in Paris and Monaco — opened this restaurant inside The Dorchester on Park Lane in 2007, and it took three Michelin stars by 2010. The kitchen is now run by Chef Jean-Philippe Blondet, who worked alongside him for years before taking the reins and has kept the standard exactly where it was. The style is what they call naturalité: French technique in service of the ingredient, seasonal and unshowy. A few signatures have been there since opening — a lobster medallion with chicken quenelles and Périgord truffle, a rum baba to finish — and you get to choose your own glass from a collection of Baccarat crystal. A grand, old-school London evening, done properly."
  },
  {
    "slug": "core-by-clare-smyth",
    "city": "London",
    "chef": "Clare Smyth",
    "blurb_short": "Refined, sustainable British cooking in Notting Hill — the first restaurant from a British woman to hold three Michelin stars.",
    "blurb_long": "Chef Clare Smyth spent years as chef patron at Restaurant Gordon Ramsay, where she became the first woman to run a three-Michelin-star kitchen in the UK, before opening Core in a Notting Hill townhouse in 2017. It took two Michelin stars almost immediately and a third in 2021, making her the first British woman to hold three at her own restaurant. Her cooking is deeply, proudly British — top produce from dedicated UK farmers, turned into dishes meant to spark memory and emotion. The signatures say it best: \"Potato and Roe,\" a single potato in dulse beurre blanc that's pure quiet brilliance, and a dessert built to taste like a Malteser. Start with a drink in the Whiskey & Seaweed bar. Polished, warm, and never stuffy."
  },
  {
    "slug": "helene-darroze-at-the-connaught",
    "city": "London",
    "chef": "Hélène Darroze",
    "blurb_short": "Chef Hélène Darroze brought the flavors of her native southwest France to a Mayfair grand hotel — and made the dining room warm and unstuffy rather than starchy.",
    "blurb_long": "A fourth-generation chef from Les Landes, below Bordeaux, Chef Hélène Darroze cooks her heritage at The Connaught: foie gras, Espelette pepper (there are little pots of it on the tables), and Armagnac from her own family, folded together with ideas gathered on her travels, like lobster with tandoori spices. The room, redesigned by Pierre Yovanovitch in soft blush and pale wood, is deliberately cosy for a place at this level — the opposite of a hushed temple. Don't skip the signature Baba dessert, served with a choice of Armagnacs from her brother Marc. Named the World's Best Female Chef in 2015, she earned the restaurant's third Michelin star in 2021. A grand London occasion that somehow still feels like dinner at a friend's."
  },
  {
    "slug": "jade-dragon",
    "city": "Macau",
    "chef": "Kelvin Au Yeung",
    "blurb_short": "Inside a Cotai casino resort, Jade Dragon is Cantonese cooking at full opulence — the only spot in Greater China with three Michelin stars and three Black Pearl diamonds.",
    "blurb_long": "Jade Dragon is a temple to Cantonese fine dining inside Macau's City of Dreams — a lavish room of ebony, jade, crystal and beaded curtains, with calligraphers and tea masters on hand and a private lift to reach it. Chef Kelvin Au Yeung's cooking honors tradition while reaching for the best of everything: meats barbecued over fragrant lychee wood (the suckling pig has a serious following), double-boiled tonic soups drawn from Guangdong's nourishing-broth tradition, and dim sum at lunch worth planning around. It holds three Michelin stars and, uniquely among Chinese restaurants in Greater China, three Black Pearl diamonds as well. Cantonese grandeur with nothing held back."
  },
  {
    "slug": "diverxo",
    "city": "Madrid",
    "chef": "Dabiz Muñoz",
    "blurb_short": "Madrid's only three-Michelin-star restaurant — edible theatre from one of the world's most fearless chefs.",
    "blurb_long": "As a kid, Chef Dabiz Muñoz told his father he'd run a restaurant with queues around the block; his father said sure, when pigs fly. Flying pigs now cover the walls of DiverXO, Madrid's only three-Michelin-star restaurant, and the last laugh is thoroughly his. After cooking at Hakkasan and Nobu in London, he opened here in 2007 and climbed to three stars by 2013, restoring a top Michelin honor to Madrid after two decades without one. His single tasting menu — \"The Kitchen of the Flying Pigs\" — is irreverent, maximalist Spanish cooking shot through with Asian influences, served as edible \"canvases,\" and it's spent years near the very top of the World's 50 Best. Loud, theatrical, and unlike anywhere else. Come ready for a ride."
  },
  {
    "slug": "am-par-alexandre-mazzia",
    "city": "Marseille",
    "chef": "Alexandre Mazzia",
    "blurb_short": "A 20-seat Marseille room where a former pro basketball player serves forty tiny, spice-driven dishes.",
    "blurb_long": "Chef Alexandre Mazzia took the third Michelin star at AM in 2021, and almost nothing about the place is conventional. He was a professional basketball player before he cooked, he grew up in the Congo, and that childhood runs straight through his food — a virtuoso run of spices, roasting and smoking across some forty small dishes, with signature oddities like smoked-eel chocolate and algae popcorn. The room near the Vélodrome seats only about twenty, kitchen open to the tables, concrete and oak and no tablecloths. The name itself is a double meaning: his initials, and the French word for soul. Three Michelin stars. Come with an open mind and an empty stomach."
  },
  {
    "slug": "le-petit-nice-passedat-hotel-5-etoiles-relais-chateaux-a-marseille",
    "city": "Marseille",
    "chef": "Gérald Passédat",
    "blurb_short": "On a rocky cove facing the Mediterranean, a century-old family inn where Gérald Passédat cooks the sea of Marseille like no one else.",
    "blurb_long": "Le Petit Nice has belonged to the Passédat family since 1917, and Gérald — third generation, raised a few metres from the water — has turned it into a three-Michelin-star ode to the Mediterranean, a star held since 2008. He works with local fishermen to bring in as many as 65 species through the year, many of them humble bycatch other kitchens ignore, and builds a \"gastronomic dive\" of a menu that descends, course by course, from shallow-water shellfish to fish of the great depths. The robust sauces and broths are made from heads, livers and cooking juices; olive oil stands in for cream and butter. The dining room and terrace hang right over the sea, with the Château d'If on the horizon. Dishes like the loup de mer named for the chef's aunt have become signatures. Time a long lunch for a clear day and let the Mediterranean do the rest."
  },
  {
    "slug": "flocons-de-sel",
    "city": "Megève",
    "chef": "Emmanuel Renaut",
    "blurb_short": "A wood-and-stone chalet high above an Alpine ski village, where three Michelin stars are built almost entirely from the mountain itself.",
    "blurb_long": "Flocons de Sel sits up a winding road above Megève, a chalet on the edge of the forest with the peaks for a backdrop — and Chef Emmanuel Renaut cooks the landscape around it almost literally. A Meilleur Ouvrier de France who fell for these mountains as a boy, he builds his three-Michelin-star menus from lake fish, foraged herbs and mushrooms, mountain cheeses and alpine plants, with a pure, pared-back touch and the occasional wink — langoustines with gentian, say. His pike-and-monkfish dumpling has become a signature. The cellar hides a small obsession, too: one of the great collections of Chartreuse, some bottles dating from before 1900. Stay the night if you can — it's a Relais & Châteaux refuge as much as a restaurant."
  },
  {
    "slug": "restaurant-mirazur",
    "city": "Menton",
    "chef": "Mauro Colagreco",
    "blurb_short": "Chef Mauro Colagreco's restaurant on the French-Italian border, with the sea below and the gardens running the menu.",
    "blurb_long": "Tucked onto the coast right where France meets Italy, Mirazur has the kind of Mediterranean view that would carry a lesser restaurant on its own — but Chef Mauro Colagreco isn't a coast-on-the-view sort. He runs the whole place by the lunar calendar now, harvesting from his own terraced gardens and building daily menus around nature itself: roots, leaves, flowers, fruit. The cooking is flawless but never fussy — big, harmonious flavors you don't need a decoder ring for. It topped the World's 50 Best, became the first restaurant anywhere to go fully plastic-free, and even bought a local bakery to make its own bread. Three Michelin stars. Go for the food; the view is just showing off."
  },
  {
    "slug": "enrico-bartolini",
    "city": "Milan",
    "chef": "Enrico Bartolini; Davide Boglioli",
    "blurb_short": "Milan's only three-Michelin-star table, perched on the top floor of a museum — from the most decorated chef in Italy.",
    "blurb_long": "Chef Enrico Bartolini collects Michelin stars the way some people collect stamps: he's the most starred chef in Italy, with a galaxy of restaurants and the rare distinction of once being awarded four stars in a single year. This is the flagship, on the third floor of MUDEC, Milan's Museum of Cultures, and the only three-star in the city — a pared-back room of concrete and glass that keeps all the drama on the plate. His watchword is \"intensity and fullness of flavour,\" contemporary Italian cooking with deep roots, run day to day with resident chef Davide Boglioli. The dish to know is the beetroot risotto with gorgonzola, an earthy, funky modern classic that lands on nearly every table. Proof that Milan does substance as well as style."
  },
  {
    "slug": "osteria-francescana",
    "city": "Modena",
    "chef": "Massimo Bottura",
    "blurb_short": "Modena's temple to storytelling on a plate — twice the best restaurant in the world.",
    "blurb_long": "Chef Massimo Bottura took the Italian dishes everyone thinks they know and turned them into something closer to storytelling you can eat — a lemon tart named for the moment one got dropped, a love letter to the crunchy corner of nonna's lasagna, a \"Five Ages of Parmigiano Reggiano\" that's really five textures of one cheese. It nearly didn't make it: when it opened in 1995, locals were not at all sure about a man rethinking a cuisine this sacred. He stuck with it, twice landed at No.1 on the World's 50 Best, and hung contemporary art all over the dining room while he was at it. Three Michelin stars. One of the genuinely few places that changed how Italy cooks."
  },
  {
    "slug": "le-louis-xv-alain-ducasse-a-l-hotel-de-paris",
    "city": "Monaco",
    "chef": "Alain Ducasse; Emmanuel Pilon",
    "blurb_short": "The first hotel restaurant in the world to win three Michelin stars — Alain Ducasse's gilded Riviera landmark on Monaco's Place du Casino.",
    "blurb_long": "When Prince Rainier challenged a young Alain Ducasse to win three Michelin stars within four years, Ducasse did it in 33 months — he was 33 years old, and the Louis XV became the first hotel restaurant ever to reach the summit. Nearly four decades later it's still there, the glittering heart of a global empire, in a Belle Époque room dripping with chandeliers off the casino square. The cooking is what Ducasse calls naturalité: the Riviera on a plate, built from small farmers, fishermen and the produce of Provence and the Italian coast, in service of the ingredient rather than spectacle. Since 2022 his loyal lieutenant Emmanuel Pilon — a fourth-generation Lyonnais chef — has run the kitchen day to day, balancing Ducasse classics with his own touch. Jackets required, and worth dressing for. One of the grand rooms of European dining."
  },
  {
    "slug": "eleven-madison-park",
    "city": "New York",
    "chef": "Daniel Humm",
    "blurb_short": "A plant-based three-Michelin-star landmark on Madison Square Park — once named the best restaurant in the world.",
    "blurb_long": "Chef Daniel Humm has held three Michelin stars at Eleven Madison Park since 2012, and in 2017 it was named No. 1 on the World's 50 Best. Then he did something genuinely radical: after the pandemic, during which the restaurant became a relief kitchen serving over a million meals, he reopened in 2021 with an entirely plant-based menu — and in 2022 it became the first plant-based restaurant in Michelin history to earn three stars. It's a temple of precision where nearly everything is custom-made, the plating is art, and vegetables do things you wouldn't believe (a tonburi \"caviar\" quenelle, a warm vegan roll with faux butter). As of 2025 there are a few optional animal-protein courses again. A real statement about what luxury can be."
  },
  {
    "slug": "jungsik",
    "city": "New York",
    "chef": "Jungsik Yim",
    "blurb_short": "Chef Jungsik Yim's Tribeca restaurant was the first Korean restaurant outside South Korea to earn three Michelin stars — it launched New York's Korean fine-dining boom.",
    "blurb_long": "When Chef Jungsik Yim opened Jungsik in Tribeca in 2011, modern Korean fine dining barely existed in New York; today the city has a dozen Michelin-starred Korean restaurants, and many of their chefs came up through his kitchen. His cooking takes the familiar — banchan, gimbap, bibimbap — and makes it quietly startling, from raw striped jack with white kimchi to crisp octopus with gochujang aioli, all plated with a clean downtown elegance. In December 2024 it became the first Korean restaurant outside South Korea to win three Michelin stars, and Yim took the James Beard Outstanding Chef award months later. Refined, original, and genuinely satisfying — the kind of meal that makes you nod to yourself while you eat."
  },
  {
    "slug": "le-bernardin",
    "city": "New York",
    "chef": "Eric Ripert",
    "blurb_short": "Chef Eric Ripert's Midtown temple to seafood, and one of New York's most quintessential rooms.",
    "blurb_long": "Nearly everything here is in service of balance — between simplicity and refinement, French foundation and global reach — and Chef Eric Ripert has held that line for over three decades. The menu tells you the philosophy before the food does: it's divided into Almost Raw, Barely Touched, and Lightly Cooked, an entire worldview about not getting in the seafood's way. There's a generous à la carte rather than a forced march through a tasting menu, which makes it the rare room at this level you can drop into on your own terms. Three Michelin stars and a regular on the World's 50 Best. Dress up — everyone else will have."
  },
  {
    "slug": "per-se",
    "city": "New York",
    "chef": "Thomas Keller",
    "blurb_short": "Chef Thomas Keller's New York counterpart to The French Laundry, with Central Park laid out below.",
    "blurb_long": "There's no bad seat at Per Se — every table looks out over Central Park like it's your own backyard. It's Chef Thomas Keller's New York companion to The French Laundry, and it runs on the same exacting logic: two nine-course tasting menus daily (one all-vegetable), choreographed so precisely that no single ingredient ever repeats across the meal. \"Oysters and Pearls\" and the big dessert finale are the dependable bookends; everything between is a quiet master class in confidence. Three Michelin stars, a 2,000-bottle cellar, and Keller's fingerprints on every detail. The New York archetype of American fine dining."
  },
  {
    "slug": "hajime",
    "city": "Osaka",
    "chef": "Hajime Yoneda",
    "blurb_short": "Chef Hajime Yoneda was an electronics engineer before he was a cook — and he earned three Michelin stars faster than any restaurant in history, in well under two years.",
    "blurb_long": "There's a measured, almost scientific precision to Chef Hajime Yoneda's cooking, and it's no accident: he was a design engineer before he ever picked up a knife, and at Hajime, in Osaka's Edobori district, recipes are documented and temperatures controlled to a fraction of a degree. The food is innovative French in spirit but built around themes of nature, the Earth and the cosmos, served in a hushed, gallery-like room. The dish to know is \"Chikyu\" — Planet Earth — a single plate of more than a hundred vegetables, herbs and grains arranged to evoke the living world. It took three Michelin stars within roughly seventeen months of opening, the fastest on record anywhere, and has held them ever since. Book the full menu; the short one leaves out the planet."
  },
  {
    "slug": "kashiwaya-osaka-senriyama",
    "city": "Osaka",
    "chef": "Hideaki Matsuo",
    "blurb_short": "A three-star kaiseki ryotei hidden in a quiet Osaka suburb, built on the hospitality of the tea ceremony.",
    "blurb_long": "Kashiwaya takes its name from a ryokan inn once run by Hideaki Matsuo's ancestors, and his cooking carries that lineage forward: traditional kaiseki shaped by the etiquette and aesthetics of the Kyoto tea ceremony, served across seven tatami private rooms in sukiya style. The menu runs to eight dishes that change every month — grilled amadai tilefish marinated in fermented shrimp is a signature — and ingredients are bought and prepped against your exact reservation time for maximum freshness. It's an unusual spot for a three-star: a calm residential corner of Suita rather than Kyoto or central Osaka, which suits the unpretentious local food culture it grew from. Three Michelin stars since 2010, a Green Star, and a 2026 Mentor Chef Award for Matsuo's work training the next generation."
  },
  {
    "slug": "maaemo",
    "city": "Oslo",
    "chef": "Esben Holmboe Bang",
    "blurb_short": "Norway's only three-Michelin-star restaurant, where a Danish chef cooks the Norwegian landscape from organic, biodynamic and wild produce alone.",
    "blurb_long": "Maaemo — from a Finnish word for \"Mother Earth\" — opened in a then-rough Oslo neighbourhood in 2010, and by 2012 had become the first Nordic restaurant to debut straight into the Michelin guide at two stars. Danish chef and co-founder Esben Holmboe Bang took the third star in 2016, sharing the moment with Copenhagen's Geranium as the first three-star kitchens in the Nordics. When the restaurant moved to a new Bjørvika location it lost the stars on a technicality, then won all three back in 2021 along with a Green Star. The long tasting menu — sometimes north of 20 servings — runs entirely on organic, biodynamic and foraged Norwegian produce, from a signature glazed langoustine scented with spruce smoke to porridge with reindeer heart and brown butter. Over half the guests fly in just to eat here. A deeply personal, place-rooted argument for what the far north can put on a plate."
  },
  {
    "slug": "alleno",
    "city": "Paris",
    "chef": "Yannick Alléno",
    "blurb_short": "Chef Yannick Alléno's flagship inside the Pavillon Ledoyen, where sauce is treated as the whole point.",
    "blurb_long": "Chef Yannick Alléno took over the historic Pavillon Ledoyen on the Champs-Élysées in 2014, opened his eponymous restaurant on its top floor, and had three Michelin stars seven months later. The thing that sets his cooking apart is a near-religious focus on sauces — he rebuilt them from scratch using extraction and fermentation techniques he developed himself, and calls the result Modern Cuisine. The room is a listed historic monument with early-1900s detailing and windows over the Petit Palais, and the service runs on a \"table concierge\" idea where the team learns your preferences before you even arrive. Three Michelin stars and a World's 50 Best name. Booking is genuinely hard — plan weeks out."
  },
  {
    "slug": "arpege",
    "city": "Paris",
    "chef": "Alain Passard",
    "blurb_short": "Chef Alain Passard's Paris flagship, where vegetables from his own gardens are treated like royalty.",
    "blurb_long": "Chef Passard still cooks here most days, more than three decades after buying the place from his mentor — which already sets it apart from most rooms at this level. Vegetables arrive each morning from his three kitchen gardens in the French countryside and get turned into some of the most precise, beautiful plates in the city; he's the rare three-star chef who'd rather talk about fruit and flowers than foie gras. There's still meat and fish on the menu, but the garden is unmistakably the star. Three Michelin stars held since 1996, and a leap into the World's 50 Best top ten. Not cheap, and not trying to be."
  },
  {
    "slug": "l-ambroisie",
    "city": "Paris",
    "chef": "Shintaro Awa",
    "blurb_short": "On the Place des Vosges, the most uncompromising expression of classical French haute cuisine in Paris — no tasting menu, no gimmicks, just perfection.",
    "blurb_long": "For decades this was the purest temple of old-guard French cooking in the city: Bernard Pacaud, an orphan trained from fifteen under the legendary Eugénie Brazier, took the best luxury ingredients and cooked them flawlessly, with no foams, no foraged flourishes, and no tasting menu — just a short à la carte of starters, mains, and desserts. The langoustine feuillantine with curry sauce and the chocolate tart are cult classics regulars return for year after year. Pacaud stepped away in 2025 and handed the kitchen to Shintaro Awa, formerly Eric Frechon's right hand at Le Bristol, who tends the same dishes with his own touch. The setting — antique mirrors, marble floors, a 17th-century house on Paris's loveliest square — is reason enough. This is for a milestone where the bill is beside the point."
  },
  {
    "slug": "le-cinq",
    "city": "Paris",
    "chef": "Christian Le Squer",
    "blurb_short": "Inside the Four Seasons George V, one of the grandest dining rooms in Paris — three Michelin stars, opulence without apology.",
    "blurb_long": "Le Cinq is haute cuisine in full palace dress: lofty columns, ornate mouldings, towering floral sculptures, light pouring in from an interior garden. Chef Christian Le Squer — who'd already held three stars for over a decade at Pavillon Ledoyen — took over in 2014 and regained the third star here in 2016, and he's one of only a handful of chefs in Paris leading a three-star kitchen. A Breton at heart, he keeps returning to his childhood coast: sea bass with caviar and fermented milk, a gratinated Parisian onion that bursts with soup at the touch of a spoon. The cellar runs to 50,000 bottles, the pastry forgoes sugar for fruit and honey, and the George V holds a Europe-leading six Michelin stars across its restaurants. A quintessential grand Parisian night."
  },
  {
    "slug": "le-pre-catelan",
    "city": "Paris",
    "chef": "Frédéric Anton",
    "blurb_short": "A Napoleon III pavilion hidden in the Bois de Boulogne, where a Robuchon protégé serves some of the most precise haute cuisine in Paris.",
    "blurb_long": "Built in 1856 as a pleasure pavilion deep in the Bois de Boulogne, Le Pré Catelan is now one of Paris's ten three-Michelin-star restaurants, a green-and-silver jewel box redesigned by Pierre-Yves Rochon. Frédéric Anton — a Meilleur Ouvrier de France who spent seven years under Joël Robuchon at Jamin — has run the kitchen since 1997 and earned the third star in 2007. His style is one of disciplined restraint: top-drawer produce stripped to its essentials, scallops and langoustine and caviar handled with razor precision and sauces of real depth, building toward a quiet crescendo. Signatures like the langoustine raviolo with foie gras jelly nod to his Robuchon roots. Unusually for a room at this level, glass tables replace white cloths. Named Gault & Millau's Chef of the Year for 2025. A serene, historic Parisian splurge a world away from the city's bustle."
  },
  {
    "slug": "pierre-gagnaire",
    "city": "Paris",
    "chef": "Pierre Gagnaire",
    "blurb_short": "Chef Pierre Gagnaire's Paris flagship — three-star cooking with a poet's playfulness and a jazz musician's restlessness.",
    "blurb_long": "Gagnaire grew up in his family's Michelin-starred kitchen and has never once been interested in standing still. The menu reads like poetry, and the food turns up as little \"satellite\" portions sent into orbit rather than neat single plates — try to name his one emblematic dish and you'll give up, which is exactly how he likes it. A jazz and contemporary-art obsessive, he reinvents constantly; the room is quiet and understated, anchored by a sweeping charcoal mural. Three stars since 1996 and a longtime name on the World's 50 Best. Adventurous, generous, and worth the splurge."
  },
  {
    "slug": "plenitude",
    "city": "Paris",
    "chef": "Arnaud Donckele",
    "blurb_short": "Inside LVMH's Cheval Blanc hotel overlooking the Seine, the Paris home of a chef who treats sauce like a perfumer treats scent — three Michelin stars won in record time.",
    "blurb_long": "Chef Arnaud Donckele already held three stars at La Vague d'Or in Saint-Tropez when he opened Plénitude in 2021 on the first floor of Cheval Blanc Paris, the LVMH hotel set in the restored Samaritaine, its windows facing the Seine and the Pont Neuf. It won three Michelin stars within roughly seven months — an almost unheard-of feat. Donckele works as a self-described saucier-parfumeur, composing his sauces like a master perfumer building a fragrance in top, heart and base notes; you're asked to taste each one first, before the dish it belongs to, to follow its aromatic arc. The room is an intimate cocoon of cream and yellow with just 26 seats, and pastry prodigy Maxime Frédéric handles the desserts. There's a wine cellar carved from a single block of wood and a 19/20 from Gault & Millau. A long, poetic, sauce-led evening at the symbolic heart of Paris."
  },
  {
    "slug": "epicure",
    "city": "Paris",
    "chef": "Arnaud Faye",
    "blurb_short": "Three Michelin stars in a palace-hotel garden off the Faubourg Saint-Honoré — Parisian haute cuisine at its most polished.",
    "blurb_long": "Epicure is the grand dining room of Le Bristol, the palace hotel on the rue du Faubourg Saint-Honoré, and few rooms in Paris feel this serene — bright and pale, opening onto a manicured courtyard garden in the middle of the city. After the long, celebrated era of Chef Éric Frechon, the kitchen is now led by Chef Arnaud Faye, who keeps three Michelin stars with light, precise, vegetable-forward cooking that doesn't skimp on generosity. They bake all their own bread in-house from heirloom wheat, the sauces are concentrated but weightless, and the plating verges on art direction. A few classics endure, like a langoustine and a truffled macaroni that have long defined the house. Old-world Paris, kept quietly at the top of its game."
  },
  {
    "slug": "boury",
    "city": "Roeselare",
    "chef": "Tim Boury",
    "blurb_short": "In an unassuming brick villa in West Flanders, one of Belgium's handful of three-star tables.",
    "blurb_long": "Chef Tim Boury cooks in a brick villa on a busy road in Roeselare, with his wife Inge Waeles running a warm, multilingual room out front — proof, as the Michelin inspectors put it, that three-star cooking doesn't have to be stiff. The food is creative French built on superb West Flemish produce, and Chef Boury is celebrated above all for his sauces and his knack for letting one great ingredient speak; the seafood courses are where he's strongest. After five years at two Michelin stars he was awarded the third in 2022, joining Belgium's very short list of three-star kitchens. He also runs an academy that trains young cooks from around the world. Fly into Brussels, take the train west, and don't think twice."
  },
  {
    "slug": "la-pergola",
    "city": "Rome",
    "chef": "Heinz Beck",
    "blurb_short": "On the top floor of the Rome Cavalieri, the Eternal City's only three-Michelin-star restaurant — with one of the great views in all of dining.",
    "blurb_long": "Perched atop Monte Mario, Rome's highest hill, La Pergola gazes out over St Peter's, the Colosseum and a sea of red-tiled roofs — and it's been Rome's sole three-star restaurant since 2005, the first the city ever had. The improbable hero is Chef Heinz Beck, a Bavarian who arrived in 1994 meaning to stay a couple of years and is still here three decades later, having quietly become one of the maestros of Italian gastronomy. His cooking is classic and hyper-technical but never static, increasingly bent toward a lighter, health-minded style; the one dish he'll never retire is the fagottelli \"La Pergola,\" his ingenious riff on carbonara. The cellar runs to tens of thousands of bottles, including vintages from the early twentieth century, and the room was lavishly restyled in 2024. Book months out, dress the part, and let the sun set over Rome."
  },
  {
    "slug": "le-calandr",
    "city": "Rubano",
    "chef": "Massimiliano Alajmo; Raffaele Alajmo",
    "blurb_short": "In small-town Padua country, the Alajmo brothers turned the family restaurant into one of Italy's defining tables.",
    "blurb_long": "Chef Massimiliano Alajmo cooks here alongside his brother Raffaele, who runs the room — they took over from their parents in 1994 and have since built it into the heart of a group spanning a dozen restaurants across three countries. The setting is pared-back and quietly considered, down to the porcelain the brothers designed themselves, and Max's cooking sits somewhere between comfort and mischief: dishes like the Cappuccino Murrina, a nod to Venetian glassblowing in cuttlefish and sea urchin, have been around long enough to count as icons. Three Michelin stars and a steady place on the World's 50 Best. Worth the short hop from Padua."
  },
  {
    "slug": "le-coquillage",
    "city": "Saint-Méloir-des-Ondes",
    "chef": "Hugo Roellinger",
    "blurb_short": "On a Breton headland over the bay of Mont-Saint-Michel, a former merchant-navy sailor turned his family's seafood spot into one of France's most poetic three-star tables.",
    "blurb_long": "Hugo Roellinger spent his first life at sea before following his father Olivier — himself a former three-star chef and now a renowned spice merchant — into the kitchen at Château Richeux. He took over Le Coquillage in 2014, dropped meat from the menu in 2017, and in 2025 earned a third Michelin star to go with the Green Star he'd already held for sustainability. The single set menu, \"Au gré du vent et de la lune\" (at the whim of the wind and the moon), is built almost entirely from the sea and the surrounding land: spider crab with wild herbs and a slow-cooked egg yolk, raw scallop under sea-anemone, Breton blue lobster served two ways, all threaded with the family's beloved spices and seaweed. The dishes carry dreamlike names and arrive on plates made from local beach clay. It's a genuine 2.5-hour journey from Paris — and the kind that rewards every minute."
  },
  {
    "slug": "la-vague-d-or",
    "city": "Saint-Tropez",
    "chef": "Arnaud Donckele",
    "blurb_short": "Inside Cheval Blanc St-Tropez, under the pines by the sea, a chef who treats sauces like poetry — three Michelin stars on the Riviera.",
    "blurb_long": "Chef Arnaud Donckele, who trained under Michel Guérard and Alain Ducasse, became the youngest chef ever awarded three Michelin stars here, and his cooking is unlike anyone else's — built around sauces he calls \"ephemeral\" and \"velvety,\" whose names read like a guide to the Mediterranean deep. He starts with a painstaking study of each local fish, then composes around it; his turf dishes chase the perfect tomato or courgette to set off pigeon or lamb. The setting is pure Côte d'Azur fantasy: a pine-shaded terrace at the LVMH-owned Cheval Blanc, the bay of Saint-Tropez shimmering below, a 19/20 from Gault & Millau to go with the three stars. Open evenings in season. A long, golden, sauce-drenched dinner you won't forget."
  },
  {
    "slug": "addison-by-william-bradley",
    "city": "San Diego",
    "chef": "William Bradley",
    "blurb_short": "Southern California's first three-Michelin-star restaurant, high on a bluff above San Diego's Carmel Valley.",
    "blurb_long": "Chef William Bradley has run the kitchen at Addison since it opened in 2006, and he calls what he does California Gastronomy — global ideas filtered through Southern California's ingredients and seasons. The stars came slowly and then all at once: one in 2019, a second in 2021, and a third in December 2022 that made Addison the first restaurant in Southern California to hold three. The dishes can be playful — chicken liver churros, a riff on chips and dip — but the technique underneath is exacting, like the shellfish chawanmushi the Michelin inspectors single out. The room sits high on a bluff, with arched windows, soaring ceilings, a long tasting menu and a wine cellar at its heart. A genuine special-occasion table, and San Diego's proudest one."
  },
  {
    "slug": "atelier-crenn",
    "city": "San Francisco",
    "chef": "Dominique Crenn",
    "blurb_short": "Chef Dominique Crenn's San Francisco room, where the menu arrives as a poem and dinner follows it line by line.",
    "blurb_long": "Chef Dominique Crenn opened Atelier Crenn in 2011 as a deeply personal project — \"atelier\" meaning workshop — and built it around what she calls Poetic Culinaria: your menu is handed over as a poem she wrote, each line corresponding to a course. In 2018 she became the first female chef in the United States to hold three Michelin stars, a genuine line in the sand for the country's dining world. The small Marina-district room is hung with her late father's paintings, the menu is pescatarian and seafood-forward, and the pastry finale has a reputation all its own. Three Michelin stars. Worth building an evening around."
  },
  {
    "slug": "benu",
    "city": "San Francisco",
    "chef": "Corey Lee",
    "blurb_short": "Down a SoMa alley, the first San Francisco restaurant to earn three Michelin stars.",
    "blurb_long": "Chef Corey Lee spent nine years with Chef Thomas Keller at The French Laundry — eventually as head chef — before opening Benu in 2010, and in 2014 it became the first restaurant in San Francisco to hold three Michelin stars, making Chef Lee the first Korean chef anywhere to earn them. The fixed menu is his life's work: French technique carrying the Korean and Cantonese flavors he grew up around, heavy on seafood and vegetables, served in a spare, calm room. He's been known for years for a faux shark's-fin soup convincing enough to fool the experts, and for a thin-skinned soup dumpling that shifts with the seasons. Three Michelin stars held for over a decade, a James Beard award, and a place on the World's 50 Best since 2019. Book ahead — though they do keep a few tables for the spontaneous."
  },
  {
    "slug": "akelarre-restaurant-pedro-subijana",
    "city": "San Sebastián",
    "chef": "Pedro Subijana",
    "blurb_short": "On a hillside above the Bay of Biscay, one of the founding kitchens of New Basque Cuisine.",
    "blurb_long": "Chef Pedro Subijana took over Akelarre in 1975, and along with a small circle of peers he helped invent New Basque Cuisine — the movement that turned this stretch of Spain into one of the world's great eating cities. His cooking still runs on that balance of deep tradition and restless creativity, and the room competes with it for your attention: an octagonal dining space on the slope of Mount Igueldo with the Cantabrian Sea filling the windows. He earned the first Michelin star in 1978, the second in 1982 and the third in 2007, and has held all three since. There's a hotel and spa attached now if you want to make a night of it. Time it for sunset and let the view do half the work."
  },
  {
    "slug": "arzak",
    "city": "San Sebastián",
    "chef": "Elena Arzak; Juan Mari Arzak",
    "blurb_short": "A century-old San Sebastián institution where the Arzak family has been quietly rewriting Basque cooking for generations.",
    "blurb_long": "Chef Juan Mari Arzak earned the restaurant's first Michelin star in 1974, and his daughter Chef Elena Arzak now runs the kitchen in the same family mansion the Arzaks have held since 1897 — a rare bit of culinary dynasty that mostly only Spain seems to produce. The cooking pairs deep Basque tradition with restless experimentation, much of it worked out in their in-house laboratory and a \"flavour workbench\" of more than a thousand ingredients. The menu is built to keep changing, so you go for the invention as much as any one dish, and the wine list runs to a genuinely absurd few thousand bottles. Three Michelin stars, half a century in the guide, and a long stay on the World's 50 Best."
  },
  {
    "slug": "mingles",
    "city": "Seoul",
    "chef": "Mingoo Kang",
    "blurb_short": "The first restaurant in Seoul ever to earn three Michelin stars — and the place that made the case for modern Korean fine dining to the world.",
    "blurb_long": "Chef Mingoo Kang trained under Martín Berasategui in San Sebastián and was the youngest-ever head chef at Nobu Bahamas before returning home to open Mingles in 2014 — the name means mixing disparate things into a harmonious whole, which is exactly the project. His cooking turns on jang, the trio of Korean fermented sauces (doenjang, ganjang, gochujang) that he makes in-house over months and years, married to French and Japanese technique and a deep seam of Korean tradition. The signatures tell the story: a long-simmered \"Mingling Pot\" rich with umami, and a \"Jang Trio\" dessert that reinvents those three ferments as something sweet. It earned its first star in 2017, climbed to two, and in February 2025 became Seoul's first three-star restaurant, also landing at No. 5 on Asia's 50 Best. A bright, deeply Korean argument for where the country's cooking can go."
  },
  {
    "slug": "les-amis",
    "city": "Singapore",
    "chef": "Sébastien Lepinoy",
    "blurb_short": "Singapore's first independent fine-dining restaurant, and the city-state's enduring temple to classical French haute cuisine.",
    "blurb_long": "Founded in 1994 by a group of friends who loved French food and culture — les amis means \"the friends\" — this was Singapore's first independent fine-dining restaurant, and three decades on it remains the standard-bearer for pure French haute cuisine in Asia. Chef Sébastien Lepinoy, a longtime Robuchon disciple, took over in 2013, won two Michelin stars in the inaugural 2016 Singapore guide and a third in 2019. He sources prized seasonal produce from across France and treats it with exacting classical technique; signatures like the foie gras with black truffle and the sole with caviar show the house style. The wine cellar runs past 3,000 bottles, mostly Burgundy and Bordeaux, and Les Amis is the only restaurant in Asia to hold the \"three pillars\" — three Michelin stars, five Forbes stars and a Wine Spectator Grand Award. A polished, classic special-occasion room in the heart of the city."
  },
  {
    "slug": "odette",
    "city": "Singapore",
    "chef": "Julien Royer",
    "blurb_short": "Named for the grandmother who taught him to cook, Julien Royer's modern-French landmark inside Singapore's National Gallery — three stars, and twice the best in Asia.",
    "blurb_long": "Chef Julien Royer grew up the son of fourth-generation farmers in Cantal, in central France, foraging and gardening and eating by the seasons — lessons he credits to his grandmother Odette, for whom the restaurant is named. He trained under Michel Bras before landing in Singapore, and in 2015 opened Odette in the National Gallery, a serene blush-and-oak room hung with a cascading art installation. The cooking is French to its bones but quietly shaped by his years in Asia, built on obsessive sourcing from small producers around the world; the rosemary-smoked organic egg and the mushroom tea have been signatures since day one. It took two Michelin stars in Singapore's first guide in 2016, a third in 2019, and topped Asia's 50 Best in both 2019 and 2020. Refined, personal, and quietly emotional. One of the great tables of the city."
  },
  {
    "slug": "frantzen",
    "city": "Stockholm",
    "chef": "Björn Frantzén",
    "blurb_short": "Sweden's only three-Michelin-star restaurant, and one of the most ambitious dining rooms in the world.",
    "blurb_long": "Chef Björn Frantzén — a former professional footballer who turned to cooking — runs what is still the only restaurant in Sweden to hold three Michelin stars. The experience is theatrical from the doorbell: you start with drinks in a top-floor lounge while the day's ingredients are walked through, then move down to a counter facing the kitchen for a long menu that's Nordic at heart but threaded with French richness and Japanese precision. He first opened in 2008 as Frantzén/Lindeberg in the old town, closed in 2016 to rebuild bigger in a Norrmalm townhouse, and took the third star soon after reopening. He's since become the only chef on earth to hold three separate three-star restaurants, with siblings in Singapore and Dubai, and Frantzén has spent years near the top of the World's 50 Best. People fly in just for the famous French toast. A genuine pilgrimage, and worth every krona."
  },
  {
    "slug": "evvai-restaurant",
    "city": "São Paulo",
    "chef": "Luiz Filipe Souza",
    "blurb_short": "One of the first restaurants in all of Latin America to win three Michelin stars — Brazil and Italy on one plate.",
    "blurb_long": "When the Michelin Guide handed out Brazil's — and Latin America's — first three-star ratings, Evvai was one of two names called, a milestone you can taste. Chef Luiz Filipe Souza, of Italian descent and trained at three-star Reale in Italy, built the place around a concept he calls \"Oriundi,\" the cooking of Italians who emigrated to Brazil: Italian technique meeting Brazilian ingredients, so a tortellini might be stuffed with Amazonian chestnuts and a moqueca reimagined with heart of palm. He also hand-draws a little pop-art card for every dish, which tells you something about the spirit of the place — serious about the food, much less so about the pomp. The name means \"yay!\" in Italian. It fits."
  },
  {
    "slug": "jl-studio",
    "city": "Taichung",
    "chef": "Jimmy Lim",
    "blurb_short": "The only Singaporean restaurant in the world with three Michelin stars isn't in Singapore at all — it's Chef Jimmy Lim's JL Studio, in the Taiwanese city of Taichung.",
    "blurb_long": "Chef Jimmy Lim grew up the son of a Singaporean hawker cook, trained in some of the world's most famous kitchens — The French Laundry, Noma, Per Se — and then set out to prove that Singaporean food belonged in the fine-dining conversation, not just the hawker centre. At JL Studio in Taichung, he reimagines the dishes of home through Taiwanese ingredients and French technique: satay, chilli crab and Hainanese chicken rice turned into something unexpected, finished by a kaya toast dessert served inside an edible eggshell of frozen coconut jam. In 2023 it became the first Singaporean restaurant anywhere to earn three Michelin stars — a milestone made sweeter for happening abroad. A delicious argument, course after course."
  },
  {
    "slug": "le-palais",
    "city": "Taipei",
    "chef": "Ken Chan; Matt Chen",
    "blurb_short": "On the 17th floor above Taipei Main Station, the first restaurant in Taiwan ever to win three Michelin stars — and one of the most affordable three-stars on earth.",
    "blurb_long": "Despite the French name (it means \"the palace\"), Le Palais is a temple to Cantonese banquet cooking, set in the lavish Palais de Chine Hotel. Head chef Ken Chan left Hong Kong for Taiwan three decades ago — dropping out of school at twelve to push a dim sum trolley — and became the restaurant's chef in 2010; executive chef Matt Chen, Macau-born, joined in 2017. Together they've held three Michelin stars since the inaugural Taipei guide in 2018, the only Taiwanese restaurant to do so for years. The signature is a Cantonese-style crispy roast duck, flamed tableside with kaoliang liquor and ordered two days ahead, but the dim sum, abalone and stir-fries are all exacting. Prices are gentle by three-star standards, which makes it one of the great fine-dining values anywhere. A grand, glamorous Cantonese feast right above the city's busiest transit hub."
  },
  {
    "slug": "hotel-l-assiette-champenoise",
    "city": "Reims",
    "chef": "Arnaud Lallement",
    "blurb_short": "If you're touring Champagne, Chef Arnaud Lallement's three-Michelin-star table just outside Reims — and its vast list of grower Champagnes — is the meal to build the trip around.",
    "blurb_long": "Chef Arnaud Lallement grew up in this house: his parents opened L'Assiette Champenoise in 1975, he took over the kitchen, lost his father in 2002, and then climbed steadily to a third Michelin star in 2014 — a star he openly dedicated to his dad. His philosophy is \"manger vrai,\" eating true: clean flavors, impeccable produce, masterful sauces poised right on the edge of acidity. The dish that says it best is the Brittany blue lobster he calls \"a tribute to my father,\" after the festive lobster his dad cooked on special occasions. It all sits in a Relais & Châteaux mansion in the heart of Champagne, with one of the deepest Champagne lists anywhere to match. Family-run, deeply felt, and worth the detour off the vineyard road."
  },
  {
    "slug": "azabu-kadowaki",
    "city": "Tokyo",
    "chef": "Toshiya Kadowaki",
    "blurb_short": "A six-seat Tokyo counter where Chef Toshiya Kadowaki has turned truffle rice into a pilgrimage.",
    "blurb_long": "Chef Toshiya Kadowaki opened this Azabu-Juban restaurant in 2000, earned two Michelin stars in 2010, and was bumped to three in 2020 — and yet the room has stayed tiny on purpose, just six seats at the counter and a low-ceilinged private room built to feel like a tearoom. The cooking is kaiseki at heart but threaded with Western ingredients and technique, the kind of quiet East-meets-West that reveals itself course by course. The thing people travel for is the truffle rice: a clay pot of hot rice buried under generous shavings of black truffle, served near the end of the meal and spoken about long after. Three Michelin stars, in a space that seats fewer people than most kitchens employ. Book well ahead."
  },
  {
    "slug": "ginza-harutaka",
    "city": "Tokyo",
    "chef": "Harutaka Takahashi",
    "blurb_short": "Edo-style sushi from a Jiro disciple, served in a deliberate crescendo at a counter carved from a single cypress.",
    "blurb_long": "Chef Harutaka Takahashi spent more than a decade at Jiro Ono's legendary counter before opening his own place in Ginza, and he runs it with quiet confidence and zero interest in trends. The sushi here is plotted like music — Michelin likens it to Boléro — each piece placed in a deliberate order that builds toward a crescendo of sweetness, acidity and temperature. The room is its own statement: a long counter milled from a single piece of Nara cypress, black marble underfoot, glass and lacquer vessels chosen with a collector's eye. The rice is firm and vividly vinegared, the fish bought that morning at Toyosu. It's among the very few sushi counters anywhere to hold three Michelin stars. Sit, trust the order, and let it build."
  },
  {
    "slug": "gastronomy-joel-robuchon",
    "city": "Tokyo",
    "chef": "Kenichiro Sekiya",
    "blurb_short": "A French château transplanted to Tokyo, glittering with crystal — three Michelin stars held every year since the city's first guide.",
    "blurb_long": "Few restaurants commit to a fantasy like this one: a French-style château in the middle of Tokyo's Ebisu Garden Place, its upstairs grand dining room dripping with Baccarat chandeliers and Swarovski crystal. It carries the name and legacy of the late Chef Joël Robuchon, the \"Chef of the Century,\" and has held three Michelin stars in every Tokyo guide since the very first — a run of luxury-French consistency almost no one matches. The kitchen is led by Chef Kenichiro Sekiya, who in 2023 became the first Japanese chef ever named a Meilleur Ouvrier de France in cuisine — a very big deal. Expect the famous Robuchon touches: the caviar, the almost-illegally buttery mashed potato, a bread trolley and dessert wagon that test your resolve. Unapologetically grand, and gloriously so."
  },
  {
    "slug": "kagurazaka-ishikawa",
    "city": "Tokyo",
    "chef": "Hideki Ishikawa",
    "blurb_short": "Down a stone-lined Kagurazaka alley, a seven-seat counter serving some of Tokyo's most quietly assured kaiseki.",
    "blurb_long": "You reach Hideki Ishikawa's counter by stepping off a cobbled lane, past a small garden and a stone path purified with water in the Shinto manner — the first sign that comfort here is taken very seriously. Ishikawa's guiding idea is \"mui-shizen,\" cooking true to nature and free of artifice, which in practice means light flavors, clean plating, and Niigata rice cooked fresh and served in earthen bowls. The clay-pot rice, presented tableside, tends to steal the evening. He's held three Michelin stars since the guide first reached Tokyo in 2008, and trained a generation of chefs — including the man who'd open Kohaku three doors down. Counter seats are the hard part; book well ahead."
  },
  {
    "slug": "kanda",
    "city": "Tokyo",
    "chef": "Hiroyuki Kanda",
    "blurb_short": "An eight-seat counter in Toranomon where one of Tokyo's most consistent chefs has held three stars for going on two decades.",
    "blurb_long": "Hiroyuki Kanda grew up in a family restaurant in Tokushima, trained in Paris and Japan, and has held three Michelin stars without interruption since the Tokyo guide launched in 2008 — a run that puts him among the most consistent chefs anywhere. His motto, \"subtle flavour is true flavour,\" tells you what to expect: carefully chosen seasonal ingredients, minimal intervention, rice cooked so precisely the surface dimples like crab burrows. There's no written menu, the room (designed by artist Hiroshi Sugimoto) seats only a handful at the counter, and Kanda himself works it personally. He's also a Michelin Mentor Award winner for the chefs he's brought up. Intimate, exacting, and worth the effort of the booking."
  },
  {
    "slug": "kohaku",
    "city": "Tokyo",
    "chef": "Koji Koizumi",
    "blurb_short": "Ishikawa's protégé became Japan's youngest three-star chef here — kaiseki with an avant-garde streak, three doors from where he trained.",
    "blurb_long": "Koji Koizumi spent nine years as Hideki Ishikawa's right hand before opening Kohaku in the same Kagurazaka alley, and in 2016 he earned a third Michelin star at thirty-six — the youngest chef in Japan to do it. His kaiseki keeps the classical bones — dashi, seasonal logic, a different menu every visit — but slips in ingredients tradition would never touch: truffle, caviar, foie gras, star anise. Find it behind a façade of tightly aligned bamboo and a painted white tiger (the kanji of the name). The counter is effectively always sold out, so the private room is your realistic way in. Three Michelin stars, and one of Tokyo's more genuinely surprising rooms at this level."
  },
  {
    "slug": "l-effervescence",
    "city": "Tokyo",
    "chef": "Shinobu Namae",
    "blurb_short": "A serene Nishi-Azabu refuge where French technique meets Japanese terroir — and a whole turnip becomes the signature dish.",
    "blurb_long": "Shinobu Namae took a roundabout path here — rock band, dreams of journalism, then a Michel Bras cookbook that redirected his life — before training under Bras in Hokkaido and France and at Heston Blumenthal's Fat Duck. At L'Effervescence he applies French method to meticulously sourced Japanese ingredients, often listing his farmers and fishers on the menu. The signature isn't a luxury showpiece but a single Tokyo turnip, slow-cooked for hours and dressed with brioche crumbs — an homage to the people who grow his food. The meal ends with a Sowa-style matcha, the room is a hushed escape from the city, and the whole operation aims to be \"regenerative,\" publishing an annual waste-and-emissions report. Three Michelin stars and a Green Star."
  },
  {
    "slug": "l-osier",
    "city": "Tokyo",
    "chef": "Olivier Chaignon",
    "blurb_short": "Owned by Shiseido and named for Ginza's willow trees, Tokyo's most enduring temple to French haute cuisine.",
    "blurb_long": "L'Osier — French for \"the willow,\" after the trees that once symbolized Ginza — opened in 1973 inside Shiseido's world and has been a fixture of the neighborhood ever since, now occupying a serene room beneath a nine-meter glass atrium with a willow artwork at the door. Chef Olivier Chaignon, who trained at Taillevent and Pierre Gagnaire before taking over in 2013, cooks classical French with a lighter, contemporary hand and a real sustainability streak, building close ties with producers across Japan and France. Expect blue lobster, precise pigeon, wagyu, and exacting service in a luxurious, art-filled space. Three Michelin stars held continuously since the 2019 guide, plus a Green Star."
  },
  {
    "slug": "myoujyaku",
    "city": "Tokyo",
    "chef": "Hidetoshi Nakamura",
    "blurb_short": "Down a quiet Nishi-Azabu staircase, a minimalist kaiseki counter that vaulted to three Michelin stars in just three years — seawater is sometimes the only seasoning.",
    "blurb_long": "Chef Hidetoshi Nakamura cooked in Kyoto and Tokushima and spent eleven years as head chef at a one-star Tokyo kitchen before opening Myoujyaku in 2022. It took two Michelin stars in its very first guide and, in the 2026 edition, became the sole restaurant in Tokyo promoted to three — a remarkably fast ascent. The name comes from a philosopher's idea of akarusabi, an aesthetic where radiance lives in restraint, and that's the cooking exactly: a minimalist take on kaiseki where many courses turn on just one or two ingredients. A clear broth might be nothing but matsutake mushrooms and water, seasoned only with mineral-light seawater drawn from a spring beneath the seabed. You find it down a staircase, marked by a single lantern brushed by a calligrapher. A non-showy tour de force — and proof of how much restraint can hold."
  },
  {
    "slug": "nihonryori-ryugin",
    "city": "Tokyo",
    "chef": "Seiji Yamamoto",
    "blurb_short": "Seiji Yamamoto's \"singing dragon\" — progressive kaiseki from a chef once known to CT-scan a pike eel to understand it, three Michelin stars strong since 2012.",
    "blurb_long": "Chef Seiji Yamamoto opened RyuGin in 2003 and spent the next two decades pushing kaiseki somewhere new — keeping the form's reverence for season, balance and the life of an ingredient, but bringing an almost scientific curiosity to it (he famously once used a CT scanner to study a pike eel's skeleton). His best-known dishes run from a hand-torn beef with matsutake to a \"RyuGin-style\" snow crab that uses every part of the animal, and the centuries-old dragon-adorned plates are part of the theatre. The name means \"the dragon's voice,\" nihonryori simply \"Japanese cuisine.\" It's held three Michelin stars since the 2012 guide, ranks among the World's 50 Best, and from January to March serves an exclusive fugu course. Now in Tokyo Midtown Hibiya, with city views and an open kitchen. One of the defining tables of modern Japanese cooking."
  },
  {
    "slug": "maison-pic",
    "city": "Valence",
    "chef": "Anne-Sophie Pic",
    "blurb_short": "Four generations of Michelin history in one family, now led by Anne-Sophie Pic — the most decorated female chef in the world.",
    "blurb_long": "The Pic story runs back to an Ardèche inn in 1889; Anne-Sophie's grandfather André won three Michelin stars in 1934, her father Jacques regained them in 1973, and the restaurant lost the third again in 1995 — three years after Jacques's sudden death, when Anne-Sophie had trained beside him for barely three months. Largely self-taught, she took control in the late 1990s and won the third star back in 2007, becoming the only woman in France to run a three-star kitchen and, today, the most-starred female chef in the world. Her culinary signature, which she calls Suffusion, is built on intricate aromatic layering and a deep love of Japan; she now serves a single set menu of seven or ten \"ports of call,\" with original drink pairings drawing on wines, infusions and rare teas. The Valence dining room glows under a Starck-designed Baccarat chandelier, opening onto 400 square metres of aromatic gardens. A singular, sensory expression of one family's century at the summit."
  },
  {
    "slug": "casa-perbellini-12-apostoli",
    "city": "Verona",
    "chef": "Giancarlo Perbellini",
    "blurb_short": "A three-Michelin-star homecoming inside one of Italy's oldest restaurants, in the heart of Verona.",
    "blurb_long": "Chef Giancarlo Perbellini first walked into 12 Apostoli as a teenager, decades ago — it's one of Italy's oldest restaurants, set in a frescoed palazzo whose history reaches back centuries. In 2023 he came full circle and took it over, moving his already two-starred Casa Perbellini into the historic rooms and giving the whole place a contemporary restyle by designer Patricia Urquiola. A year later it earned a third Michelin star. His cooking is classic at the root but never static — clear, generous, unfussy flavors he's spent a lifetime refining. There are three tasting menus plus a twelve-seat chef's table set right inside the open kitchen, the number a nod to the twelve merchants the place is named for. The kind of room where the building itself is part of the meal."
  },
  {
    "slug": "steirereck",
    "city": "Vienna",
    "chef": "Heinz Reitbauer",
    "blurb_short": "Vienna's most quietly radical kitchen, tucked into a glass pavilion in the middle of the Stadtpark.",
    "blurb_long": "Chef Heinz Reitbauer runs Steirereck with a devotion to provenance that borders on the unreasonable — herbs off the roof, produce from the restaurant's own farm, citrus from a nearby imperial orangery. It's been known for years for dishes like char cooked in beeswax, and the bread and cheese trolley has a reputation that travels well past Austria. If you've got one evening in Vienna for something special, this is where to spend it: three Michelin stars, a steady spot on the World's 50 Best — go hungry and let them lead."
  },
  {
    "slug": "cenador-de-amos",
    "city": "Villaverde de Pontones",
    "chef": "Jesús Sánchez",
    "blurb_short": "Cantabria's only three-Michelin-star restaurant, in an 18th-century palace in a tiny northern village.",
    "blurb_long": "Chef Jesús Sánchez and his wife Marián Martínez opened Cenador de Amós in 1993 in an 18th-century manor house in the small Cantabrian village of Villaverde de Pontones, and built it into the only three-Michelin-star restaurant in the region — the first star came around 1995, the second in 2016, the third in 2019. Navarrese by birth and Cantabrian by choice, Chef Sánchez cooks the northern coast: the Cantabrian Sea, the seasons, and a deep commitment to sustainability that's earned a Green Star. You'll spot him by his ever-present flat cap, which his whole kitchen wears too. The welcome starts with drinks in a glass pavilion before you move into the rustic-elegant dining rooms, and the house-baked bread alone is worth the trip. A real sense of place, on a plate."
  },
  {
    "slug": "the-french-laundry",
    "city": "Yountville",
    "chef": "Thomas Keller",
    "blurb_short": "Chef Thomas Keller's Napa landmark — and the kitchen that quietly trained a generation of America's best.",
    "blurb_long": "Grant Achatz, René Redzepi, Corey Lee — all passed through this Yountville kitchen before going on to define their own. For decades it's been one of the hardest bookings in America, and the cooking earns it: exacting French technique, pristine Napa Valley ingredients, a long tasting menu served in a room where someone has clearly agonized over every detail down to the height of the counters. Three Michelin stars and two years atop the World's 50 Best. The reservation is the hard part; the rest takes care of itself."
  },
  {
    "slug": "de-librije",
    "city": "Zwolle",
    "chef": "Thérèse Boer; Nelson Tanate",
    "blurb_short": "The Netherlands' only three-Michelin-star restaurant, set in the courtyard of a former prison in Zwolle.",
    "blurb_long": "For three decades De Librije has been the standard-bearer of Dutch fine dining — the country's only three-Michelin-star restaurant, held continuously since 2004, and a longtime name on the World's 50 Best. It was built by Chef Jonnie Boer and his wife Thérèse, who took it over in 1993; Jonnie became the most influential Dutch chef of his generation, a pioneer of cooking the Dutch landscape through foraging, local produce and fermentation, before his sudden death in 2025. The kitchen carries on under longtime head chef Nelson Tanate, with Thérèse leading the room, and the food still reads as a love letter to Dutch terroir — IJsselmeer pike-perch, house-smoked bacon, a Riesling beurre blanc. You dine in the glass-roofed courtyard of a former women's prison. Singular, and quietly moving."
  },
  {
    "slug": "vendome",
    "city": "Bergisch Gladbach",
    "chef": "Joachim Wissler; Dennis Kuckuck",
    "blurb_short": "A destination kitchen in a castle hotel outside Cologne, long at the front of modern German cooking.",
    "blurb_long": "Vendôme sits inside the grand Schloss Bensberg hotel just outside Cologne, and it made its name under Chef Joachim Wissler — one of the people who basically dragged German fine dining into its modern era, taking the country's traditional food and running it through global ingredients and ideas. His longtime sous-chef Chef Dennis Kuckuck has taken over the stoves and hasn't let the standard slip an inch: French classics with a modern edge, everything clean and balanced and built to make you pay attention. Both menus come with or without meat, in five or seven courses, and the alcohol-free pairing is as considered as the wine list. Two Michelin stars. And since you're already in a castle, you may as well stay the night."
  },
  {
    "slug": "alinea",
    "city": "Chicago",
    "chef": "Grant Achatz",
    "blurb_short": "Chicago's temple of modernist cooking, where dinner is staged as much as it's plated.",
    "blurb_long": "Chef Grant Achatz turned dinner into performance art when he opened Alinea in Lincoln Park in 2005, and it still sets the pace for American modernist cooking. Scented vapors, tableside flourishes, an edible helium balloon, a dessert painted straight onto the table in front of you — you're part of the show as much as the staff are. Two Michelin stars and a long run on the World's 50 Best back up what the room already makes clear. Go for the spectacle; stay for the fact that it's also, quietly, extraordinary food."
  },
  {
    "slug": "hof-van-cleve",
    "city": "Kruishoutem",
    "chef": "Floris Van der Veken; Peter Goossens",
    "blurb_short": "A Belgian farmhouse that's been one of the country's defining kitchens for over three decades.",
    "blurb_long": "Don't let the farmhouse fool you — inside is one of Belgium's most carefully considered dining rooms, right down to the custom cutlery and the clipped topiary. Chef Peter Goossens ran it from 1987 until handing the keys to Chef Floris Van der Veken in 2022, and the same obsession carries on: Belgian produce, global technique, and as much care lavished on a humble leek as on a noble turbot. Leave room, because the dessert trolley and the cheese board are legends in their own right. Two Michelin stars and a longtime fixture on the World's 50 Best. Worth the drive into the Flemish countryside."
  },
  {
    "slug": "pujol",
    "city": "Mexico City",
    "chef": "Enrique Olvera",
    "blurb_short": "Chef Enrique Olvera's Mexico City landmark, where ancient tradition and invention sit at the same table.",
    "blurb_long": "Olvera has done as much as anyone alive to carry Mexican cooking onto the world stage without ever cutting it loose from roots that go back thousands of years — and Pujol, now twenty-five-plus years in, is where it all started. The seasonal tasting menu is the heart of it, but the thing a lot of people come for is the taco omakase, which shares a name with street food and almost nothing else. Whatever you do, don't skip the mole madre — a sauce they've kept going and aged for well over a thousand days. Two Michelin stars and a long run on the World's 50 Best. Come hungry, come curious."
  },
  {
    "slug": "quintonil",
    "city": "Mexico City",
    "chef": "Jorge Vallejo; Alejandra Flores",
    "blurb_short": "Named for a wild Mexican herb, Chef Jorge Vallejo's Mexico City kitchen turns the country's pantry into quiet art.",
    "blurb_long": "Chef Vallejo is out gathering ingredients every single day — local gardens, orchards, the length of Mexico's astonishing pantry — and it shows up on the plate as some of the prettiest food you'll come across, a leafy little bouquet where a tamale should be, flowers ringing a pool of mole. The room's stylish and genuinely relaxed, run out front by his wife Alejandra Flores, and the all-Mexican wine pairing changes constantly and is well worth a yes. Two Michelin stars and a regular near the top of the World's 50 Best. A bright, big-hearted case for modern Mexican cooking."
  },
  {
    "slug": "d-o-m",
    "city": "São Paulo",
    "chef": "Alex Atala",
    "blurb_short": "Chef Alex Atala's São Paulo landmark — a tasting menu that travels to the far reaches of the Amazon.",
    "blurb_long": "Atala is Brazil's most internationally known chef, and D.O.M. is where he makes his case: a tasting menu redesigned every year, built on deep research into native Amazonian ingredients and Brazilian folklore. Expect things you've likely never eaten — priprioca root, tucupi, jambu — handled with real technique rather than novelty. The charming counter-move is at lunch, where the long-running Executive Menu serves a perfected version of Brazil's everyday rice and beans, reportedly Chef Atala's own favorite thing on offer. Two Michelin stars and years on Latin America's 50 Best. Go in with an open mind and you'll leave with a longer list of ingredients you love."
  },
  {
    "slug": "asador-etxebarri",
    "city": "Axpe",
    "chef": "Bittor Arginzoniz",
    "blurb_short": "Chef Bittor Arginzoniz's temple to fire, deep in the Basque hills — where everything passes over flame.",
    "blurb_long": "People make a genuine pilgrimage out to this restored country house at the foot of Mt Anboto, and it's all for one thing: Chef Bittor Arginzoniz's mastery of fire. He cooks over different woods, on grills and pulleys he built himself, with a control over flame that's reshaped how a whole generation of cooks thinks about grilling. Everything's been kissed by it — Palamós prawns, his own chorizo, the legendary aged beef chop, even the milk ice cream with beetroot at the end. The room is proudly plain; the cooking does all the talking. One Michelin star and a World's 50 Best regular, about an hour out of Bilbao. Book months ahead — it's worth the wait and then some."
  },
  {
    "slug": "noor",
    "city": "Groningen",
    "chef": "Paco Morales",
    "blurb_short": "In Córdoba, the only three-Michelin-star restaurant rebuilding the lost cuisine of Al-Andalus from medieval manuscripts — no New World ingredients allowed.",
    "blurb_long": "\"Noor\" means light in Arabic, and Chef Paco Morales — who trained at elBulli and Mugaritz — opened it in his hometown in 2016 with an idea no one else was chasing: to resurrect the cooking of Al-Andalus, the medieval Islamic civilization that made Córdoba the most advanced city of its age. Working with historians and archaeologists, he reconstructs flavors from centuries-old Arabic texts, what he calls gastro-archaeology — many of these dishes hadn't been cooked in any form for hundreds of years. Each season the restaurant advances through a new historical period, and the discipline is total: no tomatoes or potatoes in the pre-1492 menus, carob standing in for the chocolate that didn't yet exist, his signature white-sesame karim nodding to the Abbasid table. Every plate arrives with a card citing its source. First star in 2016, second in 2019, third in 2024. A meal here is less dinner than a manuscript you can taste."
  },
  {
    "slug": "daniel",
    "city": "New York",
    "chef": "Daniel Boulud",
    "blurb_short": "Chef Daniel Boulud's Upper East Side flagship — old-world French grandeur, going strong for three decades.",
    "blurb_long": "Chef Boulud started cooking at fourteen and still lights up behind the stoves of his Upper East Side room, which has been the place for big deals and bigger occasions since 1993. He trained under a who's-who of French legends and brought that elegant, old-world style to New York whole — updated classics with his thumbprint on every one. If you can swing it, the Canard à la Presse is a genuine bit of theater (you order it a day ahead, they roast the duck and press the juices tableside for the sauce), but there are prix-fixe and vegetarian routes too if you'd rather keep it simpler. One Michelin star and a longtime World's 50 Best name. The kind of grand New York night that doesn't really exist anywhere else."
  },
  {
    "slug": "astrance",
    "city": "Paris",
    "chef": "Pascal Barbot",
    "blurb_short": "Chef Pascal Barbot's Paris kitchen, set in the legendary room where Robuchon once made his name.",
    "blurb_long": "There's real history in these walls — this is where Joël Robuchon built his reputation at Jamin — and Chef Pascal Barbot, with partner Christophe Rohat out front, has made the space his own while quietly tipping a hat to the great chef. Barbot cooks with an undimmed obsession for produce and a real love of Asian and plant-forward ideas, and longtime fans will be glad his famous button-mushroom and foie gras millefeuille is still very much on the menu. There's a stunning glass wine cellar, and a maître d' who'll find you the rare bottle you didn't know you wanted. One Michelin star and a longtime presence on the World's 50 Best. Quietly one of Paris's best."
  },
  {
    "slug": "maison-lameloise",
    "city": "Chagny",
    "chef": "Éric Pras",
    "blurb_short": "A century-old Burgundy institution in a 15th-century coaching inn — and the only three-Michelin-star table in the region.",
    "blurb_long": "The Lameloise family took over a coaching inn in the small Burgundy town of Chagny in 1921, and across three generations — Pierre, Jean and Jacques — built it into one of France's most enduring restaurants, winning the third Michelin star in 1979. When Jacques retired in 2009, he handed the kitchen not to a relative but to Éric Pras, a Meilleur Ouvrier de France who'd trained under Troisgros, Bernard Loiseau and Pierre Gagnaire — and Pras has held all three stars ever since, a rare case of buying into a three-star house without the level slipping. His cooking is a faithful, living tribute to Burgundian terroir — snails, Bresse poultry, Charolais beef, Morvan hazelnut — refined with contemporary precision and the odd jaunt to the seaside. \"Tradition is the future,\" as he puts it. Five intimate dining rooms, a deep regional wine list, and rooms upstairs if you want to linger. The heart of fine dining in wine country."
  },
  {
    "slug": "narisawa",
    "city": "Tokyo",
    "chef": "Yoshihiro Narisawa",
    "blurb_short": "Tokyo's most thoughtful kitchen, where Japan's rural landscapes become the menu.",
    "blurb_long": "Chef Yoshihiro Narisawa cooks to a philosophy he calls innovative satoyama cuisine — built around Japan's rural hill-and-foothill country and the old idea of living in step with it. In practice that means deep ties to Japan's foraging and farming communities, native ingredients turned through European technique, even lacquerware and washi paper in the room. It was the very first winner of Asia's 50 Best Sustainable Restaurant award back in 2013, long before sustainability was a dining buzzword. Two Michelin stars and a fixture in the World's 50 Best top tier. Come curious."
  },
  {
    "slug": "maido",
    "city": "Lima",
    "chef": "Mitsuharu Tsumura",
    "blurb_short": "Chef Mitsuharu Tsumura's Lima landmark — Nikkei cooking, Japan and Peru on one plate, recently crowned the world's best.",
    "blurb_long": "\"Maido\" is the greeting you'll hear the second you walk in, and it sets the tone for the whole thing. Chef Mitsuharu Tsumura — born in Lima, trained in Osaka — has spent fifteen-plus years here doing more than maybe anyone to put Nikkei cooking, the Japanese-Peruvian crossover, on the world map. The long tasting menu reaches deeper into the Amazon every year, with things like sustainable paiche \"ham\" and squid ramen turning up among the courses. It's been named the best restaurant in South America and, in 2025, the World's Best Restaurant outright. Come ready to eat your way between two cultures at once."
  },
  {
    "slug": "borago",
    "city": "Santiago",
    "chef": "Rodolfo Guzmán",
    "blurb_short": "Chef Rodolfo Guzmán's Santiago kitchen, built entirely from Chile's wild edges.",
    "blurb_long": "Boragó is Chef Rodolfo Guzmán's deep dive into what Chile actually tastes like — the \"Endémica\" menu shifts with whatever turns up at the door, sourced from 200-odd tiny producers and foragers stretched from Patagonia to the Atacama, plus the restaurant's own biodynamic farm half an hour away. Dinner runs a dozen-plus courses, each one explained by where its ingredients came from, and the plating has a sense of mischief — ice cream that looks like a mushroom on a leaf, a dish styled after a Van Gogh sunflower. A longtime fixture near the top of Latin America's 50 Best. A real taste of a country, not just a meal."
  },
  {
    "slug": "central",
    "city": "Lima",
    "chef": "Virgilio Martínez; Pía León",
    "blurb_short": "Chef Virgilio Martínez and Pía León's Lima landmark — a menu that climbs Peru by altitude, and the first South American restaurant ever named world's best.",
    "blurb_long": "No one else builds a menu quite like this: Chef Virgilio Martínez and his wife and co-chef Pía León take you up through Peru by elevation, one course at a time, from shellfish pulled below sea level to things that only grow high in the Andes. They're a little obsessed — Martínez's sister runs a whole team that roams the country hunting down ingredients most people have never heard of, then they figure out how to put them on a plate. There's a restaurant in the mountains near Cusco and another in Tokyo now, but Central in Lima's Barranco is the heart of it. In 2023 it became the first South American restaurant ever named the World's Best, and it pretty much redrew the map doing it. Worth crossing the world for."
  },
  {
    "slug": "la-rei-natura-by-michelangelo-mammoliti",
    "city": "Serralunga d'Alba",
    "chef": "Michelangelo Mammoliti",
    "blurb_short": "Among the Barolo vineyards of the Langhe, a chef obsessed with gardens and memory earned three Michelin stars in barely two years.",
    "blurb_long": "Chef Michelangelo Mammoliti trained for years in France under Ducasse, Gagnaire and Alléno before coming home to Piedmont, and at La Rei Natura — inside the Il Boscareto resort, surrounded by Barolo vines — he cooks something deeply his own. His food draws on neurogastronomy and childhood memory, much of it built from a 200-square-meter greenhouse and garden where he grows 130 varieties of tomato and countless herbs, roots and flowers himself. There are three tasting menus, including a blind one called Mad100%Natura that's the purest expression of his obsession with the plant world. It opened in 2023 and reached three Michelin stars by late 2025 — one of the fastest ascents Italy has ever seen. A two-hour drive from Milan through some of the loveliest wine country in Europe, and worth every switchback."
  },
  {
    "slug": "moor-hall-restaurant-with-rooms",
    "city": "Lancashire",
    "chef": "Mark Birchall",
    "blurb_short": "A 16th-century manor in the Lancashire countryside with its own five-acre gardens — and three Michelin stars built on what grows a few steps from the kitchen.",
    "blurb_long": "Chef Mark Birchall cooked at L'Enclume before taking the kitchen at Moor Hall, a Grade II–listed Tudor manor near Aughton, half an hour north of Liverpool, that its owners restored and reopened in 2015 with a modern, Scandi-style dining room grafted onto the old house. Lancashire-born and deeply tied to the area, he builds his menus around the restaurant's own five acres of gardens and a tight circle of local farmers and artisans, with house charcuterie, a micro-dairy and bread baked on site. Dinner begins with snacks, the last served in the kitchen where Birchall walks you through the day's produce. His way with humble roots is the stuff of legend — a turnip with crab, sunflower seeds and anise hyssop that the Michelin inspectors single out. The third star came in 2025, alongside a Green Star; there are rooms if you'd rather stay. A genuine special journey, star or no."
  },
  {
    "slug": "mugaritz",
    "city": "Munich",
    "chef": "Andoni Luis Aduriz",
    "blurb_short": "Just outside San Sebastián, one of the world's ten best restaurants — and one of its most stubbornly experimental.",
    "blurb_long": "Mugaritz is less a restaurant than an open question about what dinner can be. Chef Andoni Luis Aduriz builds a long, ever-shifting tasting menu — a fair amount of it eaten with your hands — and there's a glossary on the table he wrote with his staff and even past guests, which tells you how much he enjoys bending the form. Expect conceptual, genuinely surprising plates from a two-Michelin-star kitchen that's held its place in the World's 50 Best top ten for years. Come ready to go along with it rather than order from it — that's the fun."
  },
  {
    "slug": "isshisouden-nakamura",
    "city": "Tokyo",
    "chef": "Motokazu Nakamura",
    "blurb_short": "Chef Motokazu Nakamura is the sixth generation to cook here — a Kyoto kaiseki house whose name means the craft passes to one son, and has for two centuries.",
    "blurb_long": "Long before it was one of Kyoto's great kaiseki restaurants, Isshisouden Nakamura was a family of fish-carriers, hauling the catch from Wakasa Bay down the old \"mackerel road\" into the city. Nearly two hundred years on, Chef Motokazu Nakamura — sixth generation, and the only child entrusted with the family's secrets, as the name \"isshisoden\" implies — cooks a pure, pared-back Kyoto cuisine shaped by a stretch of Zen-temple training. The restraint is the point: a white-miso New Year's soup made only with well water drawn on site, a tilefish doused again and again in sake as it grills. You eat in tatami rooms in a quiet townhouse, with three Michelin stars held since 2011. Tradition kept alive rather than embalmed."
  },
  {
    "slug": "da-vittorio",
    "city": "Brusaporto",
    "chef": "Enrico Cerea; Roberto Cerea",
    "blurb_short": "A three-Michelin-star family institution in the hills outside Bergamo, run by the Cereas for generations.",
    "blurb_long": "Da Vittorio is family in the deepest sense. Founded by Vittorio Cerea in Bergamo in 1966 and now run by his children — chefs Enrico and Roberto in the kitchen, their siblings across the wine cellar and dining room, their mother Bruna presiding over it all — it moved out to a villa in the green Cantalupa hills in 2005 and has held three Michelin stars since 2010. The cooking is Lombard tradition with a creative streak and almost reckless generosity; it made its name on seafood in a meat-loving region, and the paccheri they're known for is the dish people order no matter what menu they choose. It's also a Relais & Châteaux estate, so you can stay the night. Come hungry, and stay a while."
  },
  {
    "slug": "providence",
    "city": "Los Angeles",
    "chef": "Michael Cimarusti",
    "blurb_short": "The most principled three Michelin stars in LA — Chef Michael Cimarusti only cooks wild-caught, sustainable fish, and it tastes like luxury.",
    "blurb_long": "On Melrose Avenue, Providence has spent two decades quietly making the case that less can floor you. Chef Michael Cimarusti fell for the ocean as a kid fishing in Providence, Rhode Island — yes, the namesake — and to this day works almost entirely with wild-caught American seafood, including a soft-poached egg with sea urchin and salt-roasted Santa Barbara spot prawns people have been ordering for years. Co-owner Donato Poto runs the room with that rare warmth-plus-polish, all under a drifting “Sea Clouds” glass sculpture. Three Michelin stars and a James Beard nod for hospitality just made official what the regulars never doubted."
  },
  {
    "slug": "quince",
    "city": "San Francisco",
    "chef": "Michael Tusk",
    "blurb_short": "Northern California’s pantry meets an Italian heart in San Francisco’s Jackson Square — Chef Michael Tusk’s pasta alone has helped hold three Michelin stars since 2017.",
    "blurb_long": "Quince is what happens when a chef’s love of Italy collides head-on with the produce of Northern California. Chef Michael Tusk and his wife Lindsay opened it in 2003 and settled it into a handsome 1907 brick-and-timber building in 2009, and a good chunk of the menu rolls in from their own farm up the coast in Bolinas. The pasta is the part to get excited about — delicate agnolotti, folded by hand, changing with the season — backed by a caviar list that means business. Three Michelin stars and a 2026 James Beard award for Outstanding Chef later, the smartest move is simple: show up hungry and let the tasting menu wander."
  },
  {
    "slug": "quintessence",
    "city": "Tokyo",
    "chef": "Shuzo Kishida",
    "blurb_short": "A French restaurant in Tokyo so devoted to the essentials it writes a new menu every single day — and it’s held three Michelin stars since the city’s very first guide.",
    "blurb_long": "Quintessence is Chef Shuzo Kishida’s long argument that French cooking gets better the more you take away. He trained at Paris’s L’Astrance under Pascal Barbot, and his Shinagawa room is gloriously stripped back — no music, barely any décor, nothing to distract you from the plate. The menu is rewritten daily, so nobody gets the same dinner twice, all of it built on his trinity of product, flame and seasoning. Ask anyone who’s been and they’ll bring up the goat-milk bavarois and a meringue ice cream that has no business being that good. Three Michelin stars since 2008, and a reservation worth rearranging a trip for."
  },
  {
    "slug": "re-naa",
    "city": "Stavanger",
    "chef": "Sven Erik Renaa",
    "blurb_short": "Norway’s first three–Michelin-star restaurant outside Oslo, where Chef Sven Erik Renaa cooks the cold, clean Rogaland coast for just twenty-two lucky guests a night.",
    "blurb_long": "Tucked into the Eilert Smith Hotel on Stavanger’s waterfront, Re-naa is reason enough to point yourself toward the far edge of Norway. Chef Sven Erik Renaa and his wife Torill built the place around closeness — every single table is a chef’s table — and around whatever the fjords, farms and North Sea hand over that week. The cooking is precise and unhurried, with a light Japanese accent, content to let one perfect piece of tuna or hand-dived squid do the talking. Chef Renaa was the first chef outside Oslo to win one star, then two, now three: a very big deal achieved very quietly."
  },
  {
    "slug": "restaurant-abac",
    "city": "Barcelona",
    "chef": "Jordi Cruz",
    "blurb_short": "One of the youngest chefs ever to earn a Michelin star, Chef Jordi Cruz now runs three of them in a garden-wrapped Barcelona hideaway — and the tasting menu starts in the kitchen.",
    "blurb_long": "Chef Jordi Cruz was barely into his twenties when he became one of the youngest cooks anywhere to land a Michelin star, and at ABaC he clearly never got the memo to slow down. Set in an elegant little hotel with a private garden up on Avinguda Tibidabo, it runs a single, restlessly evolving tasting menu that keeps reinventing Catalan and Mediterranean flavors. You begin among the cooks with a round of appetizers before being walked to the dining room, where the parade has included Aqua Mirabilis — a dessert that doffs its cap to the world’s oldest perfume house. Three Michelin stars since 2017, and still one of Spain’s most thrilling tables."
  },
  {
    "slug": "restaurant-amador",
    "city": "Vienna",
    "chef": "Juan Amador; David Fleckinger",
    "blurb_short": "Austria’s first-ever three–Michelin-star restaurant lives in a working wine cellar, where Chef Juan Amador folds his Spanish roots into German precision.",
    "blurb_long": "Head down into the brick-vaulted cellar of the Hajszan Neumann winery on Vienna’s green outskirts and you’ve found Amador — the first restaurant in all of Austria to hit three Michelin stars. Chef Juan Amador, German-born of Spanish descent, kicks things off with a salvo of tapas-style bites before a tasting menu of real finesse that he builds with Chef David Fleckinger. You’re properly off the grid down here (your phone will get no signal, and honestly, good), which only tightens the focus on the glass and the plate. The wine list, as you’d hope given the address, is something special."
  },
  {
    "slug": "restaurant-bareiss",
    "city": "Baiersbronn",
    "chef": "Claus-Peter Lumpp",
    "blurb_short": "In a Black Forest village improbably stacked with three-star kitchens, Chef Claus-Peter Lumpp has held his trio since 2007 — with sauce work that’s the stuff of legend.",
    "blurb_long": "Baiersbronn is a tiny Black Forest village with a wildly outsized food reputation — more than one three-star kitchen calls it home — and Restaurant Bareiss is right at the heart of it. Chef Claus-Peter Lumpp has run this dining room inside the Hotel Bareiss since 1992, cooking classic French sharpened with local touches like venison from the estate's own hunt. Across just a handful of tables, the meal rolls toward a gloriously old-school grand finale of cheese and praline trolleys. Trained under Eckart Witzigmann and Alain Ducasse, Chef Lumpp bets on timeless over trendy every time — and three Michelin stars since 2007 say the bet keeps paying off."
  },
  {
    "slug": "restaurant-de-l-hotel-de-ville-de-crissier",
    "city": "Crissier",
    "chef": "Franck Giovannini",
    "blurb_short": "Regulars just call it “Crissier” — a Swiss cathedral of classic French cooking that has passed three Michelin stars down a near-mythic line of chefs since 1994.",
    "blurb_long": "Not many restaurants come with a dynasty attached, but Crissier, just outside Lausanne, does. The legend started with the great Frédy Girardet and carried through Philippe Rochat and Benoît Violier; today Chef Franck Giovannini works the pass, having cooked beside every one of them. He keeps Girardet's golden rule — rarely more than three flavors on a plate — and sends out classical French so clean and so à la minute it feels almost defiant. The dining rooms are named after the chefs who built the place, in case you forget you're eating inside history. Three Michelin stars, not dropped once since 1994."
  },
  {
    "slug": "restaurant-es-senz",
    "city": "Grassau",
    "chef": "Edip Sigl",
    "blurb_short": "Chef Edip Sigl went from opening night to three Michelin stars in under three years — Bavarian Alpine cooking boiled down to its pure essence.",
    "blurb_long": "ES:SENZ — a wink at Chef Edip Sigl's initials and at the idea of essence — sits inside the Das Achental resort near the Chiemsee, and its climb has been almost suspiciously fast: open in 2021, three Michelin stars by 2024. Chef Sigl, who learned plenty under Chef Juan Amador, builds each dish from just a few flawless components, served as either an all-local “Chiemgau pur” menu or a more well-travelled cousin. The cooking is refined but never stuffy — they leave the sauces on your table so you can sneak seconds — and a saffron ice cream waits at the finish. For a slice of Bavaria better known for lakes and ski lifts, that's quite the plot twist."
  },
  {
    "slug": "restaurant-gordon-ramsay",
    "city": "London",
    "chef": "Matt Abé",
    "blurb_short": "Forget the television persona — Chef Gordon Ramsay's first and finest restaurant has quietly held three Michelin stars since 2001, with chef patron Matt Abé at the controls.",
    "blurb_long": "On a hushed corner of Royal Hospital Road in Chelsea is where the whole Gordon Ramsay story began, back in 1998 — and where it's still at its most grown-up. The famous TV chef is rarely behind the pass these days; Chef Matt Abé runs the kitchen, turning out modern French cooking of almost unnerving consistency, including the lobster, langoustine and salmon ravioli that's been on the menu since day one. The room is small, the decor understated, the service warm rather than starchy — proof that three-star dining doesn't have to come with a side of intimidation. Three Michelin stars held since 2001 make this one of London's longest-running greats."
  },
  {
    "slug": "eatrenalin",
    "city": "Rust",
    "chef": "Peter Hagen-Wiest",
    "blurb_short": "Half tasting menu, half theme-park ride: at Europa-Park you glide through themed rooms over eight courses — and in 2026 the food picked up a Michelin star.",
    "blurb_long": "There is, truly, nothing else like Eatrenalin. Inside Germany's Europa-Park you sink into a patented “floating chair” and drift through a string of wildly themed rooms — an ocean here, an umami-drenched hall there — while eight courses arrive perfectly in step with the scenery, scents and soundtrack. It had every right to be a gimmick; instead, under culinary director Chef Peter Hagen-Wiest, it went and earned a Michelin star in 2026. Pick the meat-and-fish “Red Dimensions” or the vegetarian “Green Dimensions,” clear about two hours, and let yourself be carried — literally — through one of the most gleefully original dinners on earth. Best part: you don't even need a park ticket."
  },
  {
    "slug": "kimball-house",
    "city": "Atlanta",
    "chef": "Miles Macquarrie",
    "blurb_short": "A converted Decatur train depot with metro Atlanta's best oyster program and a Michelin-honored bar — cocktails built from the restaurant's own garden and local farms.",
    "blurb_long": "Set inside a lovingly restored rail depot in Decatur, Kimball House borrows its name — and a bit of its swagger — from a grand 19th-century Atlanta hotel, reviving that era's habit of pairing fresh oysters with a proper cocktail. The raw bar is the best in the city, twenty-plus varieties from both coasts (a few grown on the restaurant's own Florida oyster farm). But the bar is the real headliner: beverage director Miles Macquarrie lets the seasons, local farms and an on-site garden run the menu, from house-made bitters and preserves to terroir-driven martinis built around a single herb grown out back. The drinks earned the Michelin Guide's Exceptional Cocktails Award for Atlanta in 2024 — though for a first visit the move is simple: a dozen oysters and the house martini, the Kimball House, and settle in."
  },
  {
    "slug": "bar-leone",
    "city": "Hong Kong",
    "chef": "Lorenzo Antinori",
    "blurb_short": "A Roman corner bar transplanted to Hong Kong's Central: aperitivo, a warm hello, no spectacle. Unpretentious proved a competitive advantage — it topped the World's 50 Best Bars.",
    "blurb_long": "The cocktail world spends enormous energy on spectacle, which is what makes Bar Leone quietly radical: its entire thesis is *come in, have an aperitivo, feel at home*. Founder Lorenzo Antinori — later named International Bartender of the Year — recreated the corner bars of Rome in the middle of Hong Kong, all easy conviviality and classics poured properly rather than reinvented into oblivion. That warmth, backed by genuinely excellent drinks, carried it to the top of the World's 50 Best Bars, a first for a bar in Asia. Regulars and first-timers get the same welcome, which is rarer than it should be."
  },
  {
    "slug": "paradiso",
    "city": "Barcelona",
    "chef": "Giacomo Giannotti",
    "blurb_short": "Cocktails engineered over months and served with a magician's timing, the menu rebuilt around a new theme each year. You get in through a fridge door in a pastrami shop.",
    "blurb_long": "At Paradiso, a cocktail is closer to a small theatrical act — an ever-changing menu built each year around a single theme, drinks developed in a dedicated lab, serves designed to *do something* in front of you. The Supercool Martini is poured tableside and freezes into an iceberg in the glass as you watch. Founder Giacomo Giannotti — a Tuscan who named the place after his family's gelateria — wraps all this in a warm, whale-ribbed room hidden behind a refrigerator door in a pastrami shop in El Born, so the setting amplifies the drinks instead of upstaging them. It topped the World's 50 Best Bars and has stayed near the summit for years; once you've watched a drink assembled like a magic trick, you understand why."
  },
  {
    "slug": "kumiko",
    "city": "Chicago",
    "chef": "Julia Momosé",
    "blurb_short": "No sign out front, just a hushed light-wood room named for Japanese joinery that uses no nails. The drinks are the same: restrained, precise, quietly enormous.",
    "blurb_long": "Kumiko takes its name from the Japanese craft of assembling intricate wooden latticework without nails, and the whole place runs on that same principle: precision you feel more than notice. The room is deliberately calm — light wood, exposed brick, no sign out front, a short corridor that gives you a second to settle before you sit — and the drinks match it, leaning on sake, shochu, and Japanese ingredients to land big, complex flavors without ever raising their voice. Even the alcohol-free \"spiritfrees\" get the same serious treatment. Julia Momosé — a multiple James Beard Award winner for both the bar and her cocktail book — treats food and drinks as equals here, which is part of how Kumiko was named World's Best Bar at the Spirited Awards and became one of the rare few to earn three pins from the Pinnacle Guide, a Michelin-style rating system for bars. Come for a drink, stay for dinner, leave calmer than you arrived."
  },
  {
    "slug": "the-connaught-bar",
    "city": "London",
    "chef": "Agostino Perrone",
    "blurb_short": "Order the martini and they wheel a whole trolley to your table to build it in front of you, exactly as dry as you want. Hotel bars should all be this fun.",
    "blurb_long": "Back in 2008, hotel bars were mostly where you waited for someone. The Connaught Bar showed up and made the room the destination. Agostino Perrone has been running it the whole time, and you really just come for one thing: the martini trolley pulls up to your table and they build it to order, fussing over which bitters and how dry until it's exactly yours. The room helps, all silver leaf and moody Cubist angles, but honestly it's the trolley. It's twice been crowned World's Best Bar by the World's 50 Best Bars, and it's charted on that list more than anywhere else. Get the martini. Don't overthink it."
  },
  {
    "slug": "the-american-bar",
    "city": "London",
    "chef": "",
    "blurb_short": "The Hanky Panky and the White Lady were both born here, and yes, you can still order them where they were invented. Bring your good jacket.",
    "blurb_long": "The American Bar has been shaking drinks since the 1890s, which makes it the oldest cocktail bar still standing in London, and two of its old bartenders basically wrote the whole playbook. Ada Coleman, running one of the world's most famous bars back when that was unheard of for a woman, invented the Hanky Panky right here. Her successor Harry Craddock wrote the 1930 Savoy Cocktail Book and handed us the White Lady and the Corpse Reviver No. 2. All still on the menu, all still excellent. There's a pianist every night, a lot of marble and mirror, and a guest list over the years running from Churchill to Sinatra. It's been named World's Best Bar by both the World's 50 Best Bars and the Spirited Awards, so nobody's overselling it. Go dressed up and drink something with a hundred years on it."
  },
  {
    "slug": "please-don-t-tell",
    "city": "New York",
    "chef": "",
    "blurb_short": "You get in through a phone booth inside a hot-dog shop. Pick up the receiver and wait for the door to click. The drinks earn the theatrics.",
    "blurb_long": "Getting into PDT is half the fun: you walk into Crif Dogs, a hot-dog joint on St. Marks, squeeze into a vintage phone booth, and pick up the receiver until a hidden door clicks open. Jim Meehan opened it this way in 2007 and the trick got copied so hard that PDT basically gets blamed for every speakeasy you've been to since. But the booth is just the doorway. Under all the taxidermy you can get a Benton's Old Fashioned, made with bacon-fat-washed bourbon, one of those drinks people still talk about, and a genuinely great Crif Dogs hot dog to go with it because why not. The World's 50 Best Bars once put it at number one in the world, and the bar's taken a James Beard Award. Get the Old Fashioned, get the hot dog, tell no one."
  },
  {
    "slug": "artesian",
    "city": "London",
    "chef": "",
    "blurb_short": "Purple velvet, towering brass chandeliers, and a room that knows it. Four years running it was the best bar on the planet, and it still puts on a show.",
    "blurb_long": "Some bars you feel before you order, and Artesian is one of them: high ceilings, big bay windows, tiered brass chandeliers, deep purple seats, art deco done with a wink instead of a straight face. It lives inside the Langham on Regent Street, and for four straight years the World's 50 Best Bars named it the World's Best Bar, which almost nobody manages. The team behind that streak has moved on since, and the bar leaned into playful, sustainability-minded menus that sneak oddballs like chicory, daikon and marshmallow into drinks that still taste familiar. Come for a cocktail and let the room do the entertaining. It's very good at it."
  },
  {
    "slug": "dante-nyc",
    "city": "New York",
    "chef": "Linden Pride; Nathalie Hudson",
    "blurb_short": "A 1915 Village café turned all-day Italian aperitivo bar, and the reason half of New York suddenly started drinking Garibaldis. Come for coffee, stay till the spritzes.",
    "blurb_long": "Caffè Dante opened on MacDougal Street in 1915 and spent a hundred years as the neighborhood Italian spot before Linden Pride and Nathalie Hudson took it over in 2015 and turned it into an all-day aperitivo bar without bulldozing its soul. The drinks stay easy and Italian: a whole page of Negroni riffs, and a Garibaldi of just Campari and slowly whipped \"fluffy\" orange juice that somehow became a cocktail everyone copies now. Roll in for an espresso in the morning or pasta and a spritz at night, nobody's rushing you. It's been named World's Best Bar by the World's 50 Best Bars, and the Spirited Awards gave it World's Best Bar and Best American Restaurant Bar in one year. Order the Garibaldi. It's two ingredients and it'll ruin you for the regular kind."
  },
  {
    "slug": "the-dead-rabbit",
    "city": "New York",
    "chef": "Sean Muldoon; Jack McGarry",
    "blurb_short": "Irish pub on the ground floor, award-winning cocktail den upstairs, all in an 1828 townhouse named after a 19th-century street gang. Start with the Irish coffee, then go up.",
    "blurb_long": "Two Belfast lads, Sean Muldoon and Jack McGarry, opened the Dead Rabbit in 2013 in an 1828 building near the bottom of Manhattan and named it after a gang that used to run the Five Points. Downstairs is a proper Irish pub with pints, pub food, and an Irish coffee people will genuinely fight you over. Head up to the Parlor and it flips into a serious cocktail room, seasonal menus told like a comic book, and the biggest Irish whiskey collection in the country behind the bar. It's twice been named World's Best Bar by the World's 50 Best Bars and keeps stacking up Spirited Awards. Get the Irish coffee downstairs first. Then climb the stairs and settle in."
  },
  {
    "slug": "handshake-speakeasy",
    "city": "Mexico City",
    "chef": "",
    "blurb_short": "Behind a hotel curtain in Mexico City, a piña colada that comes out crystal clear and took two whole days to make. Sounds ridiculous. Tastes incredible.",
    "blurb_long": "Push through a curtain in Colonia Juárez and Handshake looks like a 1920s speakeasy but runs like a science lab. Everything gets clarified and prepped for days, so the piña colada arrives clear as water and bracing instead of thick and sweet, and the fig martini that first made their name is way more work than it has any right to be. Some of these drinks take two days before they hit your glass, which is a little unhinged, and then you taste one and get it. Handshake has topped the World's 50 Best Bars, the first Mexican bar ever to pull that off, and it keeps landing Best Bar in North America. If the main room's packed, the izakaya downstairs runs the same trick."
  }
];

function importOptionB() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var sh = ss.getSheetByName('venues');
  if (!sh) { throw new Error('Sheet "venues" not found.'); }

  var data = sh.getDataRange().getValues();
  var header = data[0];
  function col(name) {
    var i = header.indexOf(name);
    if (i < 0) throw new Error('Missing column in venues sheet: ' + name);
    return i;
  }
  var cSlug = col('slug'), cCity = col('city_display'),
      cShort = col('blurb_short'), cLong = col('blurb_long'), cChef = col('chef');

  // slug -> [row indexes into data]
  var bySlug = {};
  for (var r = 1; r < data.length; r++) {
    var s = String(data[r][cSlug] || '').trim();
    if (!s) continue;
    (bySlug[s] = bySlug[s] || []).push(r);
  }

  // Pull the three target columns so we can mutate then write back in 3 bulk calls.
  var n = data.length - 1;
  var shortCol = sh.getRange(2, cShort + 1, n, 1).getValues();
  var longCol  = sh.getRange(2, cLong + 1, n, 1).getValues();
  var chefCol  = sh.getRange(2, cChef + 1, n, 1).getValues();

  var written = 0, notFound = [], ambiguous = [];
  for (var i = 0; i < OPTION_B.length; i++) {
    var e = OPTION_B[i];
    var cand = bySlug[e.slug] || [];
    var target = -1;
    if (cand.length === 0) { notFound.push(e.slug); continue; }
    else if (cand.length === 1) { target = cand[0]; }
    else {
      var m = cand.filter(function (ri) {
        return String(data[ri][cCity] || '').trim() === String(e.city || '').trim();
      });
      if (m.length === 1) { target = m[0]; }
      else { ambiguous.push(e.slug + ' [' + (e.city || '?') + ']'); continue; }
    }
    var k = target - 1; // index into the pulled columns (data row r -> k = r-1)
    shortCol[k][0] = e.blurb_short;
    longCol[k][0]  = e.blurb_long;
    chefCol[k][0]  = e.chef;
    written++;
  }

  sh.getRange(2, cShort + 1, n, 1).setValues(shortCol);
  sh.getRange(2, cLong + 1, n, 1).setValues(longCol);
  sh.getRange(2, cChef + 1, n, 1).setValues(chefCol);

  var msg = 'rows written: ' + written + ' / ' + OPTION_B.length;
  if (!notFound.length && !ambiguous.length) msg += ', all slugs matched.';
  if (notFound.length)  msg += '\n\nNOT FOUND (' + notFound.length + '): ' + notFound.join(', ');
  if (ambiguous.length) msg += '\n\nAMBIGUOUS – add/fix city (' + ambiguous.length + '): ' + ambiguous.join(', ');
  Logger.log(msg);
}
