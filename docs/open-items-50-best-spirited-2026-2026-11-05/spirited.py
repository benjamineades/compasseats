# rows taken from the captured publisher text, sha256 14937a09...
import json
rows=[
("Best International Bar Team","Bar Leone","Hong Kong"),
("Best International Cocktail Bar","Satan’s Whiskers","London"),
("Best International Hotel Bar","ARGO at the Four Seasons","Hong Kong"),
("Best International Restaurant Bar","FURA","Singapore"),
("Best New International Cocktail Bar","De Vie","Paris"),
("Best U.S. Bar Team","Service Bar","Washington, D.C."),
("Best U.S. Cocktail Bar","Bar Snack","New York"),
("Best U.S. Hotel Bar","ViceVersa at the Elser Hotel","Miami"),
("Best U.S. Restaurant Bar","Cobra","Columbus"),
("Best New U.S. Cocktail Bar","schmuck.","New York"),
("World's Best Bar","FURA","Singapore"),
("World's Best Cocktail Menu","Allegory at the Eaton Hotel","Washington, D.C."),
("World's Best Spirits Selection","Tlecān","Mexico City"),
("Timeless International Award","The Bamboo Bar at Mandarin Oriental","Bangkok"),
("Timeless U.S. Award","Bryant’s Cocktail Lounge","Milwaukee"),
]
json.dump([{"src":"spirited-awards","rank":"","cat":c,"name":n,"place":p} for c,n,p in rows],open('spirited.json','w'),ensure_ascii=False,indent=0)
