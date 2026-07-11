/**
 * resolveCollisionsFree.gs
 * ----------------------------------------------------------------------------
 * The FREE half of the Job A collision cleanup: city-label folds (ALIAS) and
 * permanent closures (CLOSED). No Places API calls — costs nothing.
 *
 * Run this RIGHT AFTER mergeDuplicateVenues (and after resolveDualCategoryVenues),
 * every publish. Idempotent and only touches the explicitly-listed venues below.
 *
 *   FOLD    -> one venue wrongly duplicated under a second city that shares its
 *              correct pin. Union the duplicate row's awards onto the surviving
 *              (correct-city) row, then delete the duplicate row.
 *   CLOSE   -> set status = 'closed' so preflight excludes it.
 *
 * The paid half (BRANCH / POISON re-pins via geoRequeryCollisions) is separate.
 *
 * SAFETY: leave DRY_RUN = true for the first run. It changes nothing and logs
 * exactly what it WOULD do. Read the log, then set DRY_RUN = false and re-run.
 * ----------------------------------------------------------------------------
 */

var COLFREE_DRY_RUN = true;                 // <-- flip to false only after reading the preview log
var COLFREE_SPREADSHEET_ID = '1dKJY_woXdbO-j9CEADz28IE-1yik1FqHa0BAp29cI5s';
var COLFREE_SHEET_NAME = 'venues';

/** Config baked in from the reconciled worklist (26 folds + 2 closures). */
var COLFREE_CONFIG = JSON.parse(`{"folds":[{"sslug":"tohru-in-der-schreiberei","scity":"Munich","dslug":"tohru-fine-dining","dcity":"London","name":"Tohru*** - Fine Dining"},{"sslug":"table-main","scity":"Roswell","dslug":"table-main","dcity":"Atlanta","name":"Table & Main"},{"sslug":"jory-restaurant","scity":"Willamette Valley, Oregon","dslug":"jory-restaurant","dcity":"Portland","name":"JORY Restaurant"},{"sslug":"tales-by-chapter","scity":"Ho Chi Minh City","dslug":"tales-by-chapter","dcity":"Hanoi","name":"Tales by Chapter"},{"sslug":"pottkind","scity":"Köln","dslug":"pottkind","dcity":"Cologne","name":"Pottkind"},{"sslug":"source-at-gilpin-hotel","scity":"Bowness-on-Windermere","dslug":"source-at-gilpin-hotel","dcity":"Ambleside","name":"SOURCE at Gilpin Hotel"},{"sslug":"the-stonehouse-restaurant","scity":"Santa Barbara","dslug":"the-stonehouse-restaurant","dcity":"Montecito","name":"The Stonehouse Restaurant"},{"sslug":"restaurant-troisgros-le-bois-sans-feuilles","scity":"Ouches","dslug":"restaurant-troisgros-le-bois-sans-feuilles","dcity":"Lyon","name":"Restaurant Troisgros Le Bois sans feuilles"},{"sslug":"restaurant-magdalena","scity":"Schwyz","dslug":"restaurant-magdalena","dcity":"Lucerne","name":"Restaurant Magdalena"},{"sslug":"blue-hill-at-stone-barns","scity":"Tarrytown","dslug":"blue-hill-at-stone-barns","dcity":"New York","name":"Blue Hill At Stone Barns"},{"sslug":"spring-restaurant","scity":"Marietta","dslug":"spring-restaurant","dcity":"Atlanta","name":"Spring Restaurant"},{"sslug":"restaurante-chiron","scity":"Madrid","dslug":"restaurante-chiron","dcity":"Valdemoro","name":"Restaurante Chirón"},{"sslug":"le-chique-restaurant","scity":"Puerto Morelos","dslug":"le-chique-restaurant","dcity":"Cancún","name":"Le Chique Restaurant"},{"sslug":"lautrec","scity":"Farmington","dslug":"lautrec","dcity":"Laurel Highlands, Pennsylvania","name":"Lautrec"},{"sslug":"sahila-the-restaurant","scity":"Köln","dslug":"sahila-the-restaurant","dcity":"Cologne","name":"Sahila - The Restaurant"},{"sslug":"la-cuisine-rademacher","scity":"Köln","dslug":"la-cuisine-rademacher","dcity":"Cologne","name":"La Cuisine Rademacher"},{"sslug":"masterpiece","scity":"Duluth","dslug":"masterpiece","dcity":"Atlanta","name":"Masterpiece"},{"sslug":"zur-tant","scity":"Köln","dslug":"zur-tant","dcity":"Cologne","name":"Zur Tant"},{"sslug":"shinois","scity":"Tokyo","dslug":"shinois","dcity":"Shiga","name":"ShinoiS"},{"sslug":"restaurant-maximilian-lorenz","scity":"Köln","dslug":"restaurant-maximilian-lorenz","dcity":"Cologne","name":"restaurant maximilian lorenz"},{"sslug":"le-moissonnier","scity":"Köln","dslug":"le-moissonnier","dcity":"Cologne","name":"Le Moissonnier"},{"sslug":"the-elderberry-house","scity":"Oakhurst","dslug":"the-elderberry-house","dcity":"Tahoe and Yosemite, California","name":"The Elderberry House"},{"sslug":"inaba-japanese-restaurant","scity":"Torrance","dslug":"inaba-japanese-restaurant","dcity":"Torrence","name":"Inaba Japanese Restaurant"},{"sslug":"auberge-de-l-ill","scity":"Illhaeusern","dslug":"auberge-de-l-ill","dcity":"Alsace","name":"Auberge de l'Ill"},{"sslug":"the-angel-at-hetton","scity":"Hetton","dslug":"the-angel-at-hetton","dcity":"Beersel","name":"The Angel at Hetton"},{"sslug":"harry-sasson","scity":"Bogotá","dslug":"harry-sasson","dcity":"São Paulo","name":"Harry Sasson"}],"closures":[{"slug":"el-baqueano-cocina-autoctona-contemporanea","city":"Buenos Aires","name":"El Baqueano - Cocina Autóctona Contemporanea"},{"slug":"credo-restaurant","city":"Trondheim","name":"Credo restaurant"}]}`);

function colfree_norm_(s){ return String(s==null?'':s).trim().toLowerCase(); }
function colfree_parse_(s){ if(!s) return []; try{ var v=JSON.parse(s); return Array.isArray(v)?v:[]; }catch(e){ Logger.log('  ! bad awards_json: '+s); return []; } }
function colfree_sig_(a){ return [a.source,a.year,a.category,(a.rank==null?'':a.rank)].join('|'); }
function colfree_union_(A,B){ var seen={},out=[]; A.concat(B).forEach(function(a){ var k=colfree_sig_(a); if(!seen[k]){seen[k]=true;out.push(a);} }); return out; }

function resolveCollisionsFree(){
  var sh = SpreadsheetApp.openById(COLFREE_SPREADSHEET_ID).getSheetByName(COLFREE_SHEET_NAME);
  if(!sh){ Logger.log('ABORT: sheet "'+COLFREE_SHEET_NAME+'" not found.'); return; }

  var values = sh.getDataRange().getValues();
  var header = values[0], col = {};
  header.forEach(function(h,i){ col[String(h).trim()] = i; });
  ['slug','name','city_display','type','awards_json','status'].forEach(function(c){
    if(col[c]===undefined) throw new Error('Missing column: '+c);
  });

  // index rows by slug||city  (0-based index into `values`, header is row 0)
  var idx = {};
  for(var r=1;r<values.length;r++){
    var key = colfree_norm_(values[r][col.slug]) + '||' + colfree_norm_(values[r][col.city_display]);
    (idx[key] = idx[key] || []).push(r);
  }
  function find(slug,city){ return (idx[colfree_norm_(slug)+'||'+colfree_norm_(city)] || []).slice(); }

  var writes = [], deletes = [], log = [];

  // ---- FOLDS ----
  COLFREE_CONFIG.folds.forEach(function(f){
    var sIdx = find(f.sslug, f.scity), dIdx = find(f.dslug, f.dcity);
    if(dIdx.length===0){ log.push('OK (already folded): '+f.name+' ('+f.dcity+')'); return; }
    if(sIdx.length===0){ log.push('SKIP (survivor not found): '+f.name+' -> keep '+f.sslug+'/'+f.scity); return; }
    var s = sIdx[0], d = dIdx[0];
    var merged = colfree_union_(colfree_parse_(values[s][col.awards_json]), colfree_parse_(values[d][col.awards_json]));
    writes.push({r:s, c:col.awards_json, v:JSON.stringify(merged)});
    deletes.push(d);
    log.push('FOLD: '+f.name+'  drop <'+f.dcity+'>  into  <'+f.scity+'>  (awards now '+merged.length+')');
  });

  // ---- CLOSURES ----
  COLFREE_CONFIG.closures.forEach(function(cl){
    var hit = find(cl.slug, cl.city);
    if(hit.length===0){ log.push('SKIP (not found): CLOSE '+cl.name+' ('+cl.city+')'); return; }
    if(colfree_norm_(values[hit[0]][col.status])==='closed'){ log.push('OK (already closed): '+cl.name); return; }
    writes.push({r:hit[0], c:col.status, v:'closed'});
    log.push('CLOSE: '+cl.name+' ('+cl.city+') -> status=closed');
  });

  Logger.log('=== resolveCollisionsFree '+(COLFREE_DRY_RUN?'(DRY RUN — no changes written)':'(LIVE)')+' ===');
  log.forEach(function(l){ Logger.log(l); });
  Logger.log('Cell updates: '+writes.length+' | rows to delete: '+deletes.length);
  if(COLFREE_DRY_RUN){ Logger.log('DRY RUN complete. Set COLFREE_DRY_RUN = false to apply.'); return; }

  writes.forEach(function(w){ sh.getRange(w.r+1, w.c+1).setValue(w.v); });
  deletes.sort(function(a,b){ return b-a; }).forEach(function(i){ sh.deleteRow(i+1); });
  Logger.log('Applied. '+writes.length+' cells updated, '+deletes.length+' rows deleted.');
}
