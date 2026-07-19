function auditTargetCities() {
  const SHEET_ID = '1dKJY_woXdbO-j9CEADz28IE-1yik1FqHa0BAp29cI5s';
  const ss = SpreadsheetApp.openById(SHEET_ID);
  const sheet = ss.getSheetByName('venues');
  const data = sheet.getDataRange().getValues();
  const headers = data[0];

  const ci = headers.indexOf('city_slug');
  const cd = headers.indexOf('city_display');
  const co = headers.indexOf('country');

  const patterns = ['york', 'brooklyn', 'angeles', 'beverly', 'christchurch', 'auckland'];
  const map = {};

  for (let r = 1; r < data.length; r++) {
    const cs = String(data[r][ci] || '');
    const disp = String(data[r][cd] || '');
    const country = String(data[r][co] || '');
    const hay = (cs + ' ' + disp).toLowerCase();
    if (patterns.some(function(p){ return hay.indexOf(p) !== -1; })) {
      const key = cs + '  ||  ' + disp + '  ||  ' + country;
      map[key] = (map[key] || 0) + 1;
    }
  }

  Logger.log('city_slug  ||  city_display  ||  country   =>  venue count');
  Logger.log('-----------------------------------------------------------');
  Object.keys(map).sort().forEach(function(k){
    Logger.log(k + '   =>  ' + map[k]);
  });
  Logger.log('-----------------------------------------------------------');
  Logger.log('Done.');
}
