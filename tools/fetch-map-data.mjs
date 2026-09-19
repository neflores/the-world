// Refresh only the regional boundary. City scenes are deliberately fictional.
import fs from 'node:fs/promises';
import path from 'node:path';

const directory = path.resolve('assets/geography');
await fs.mkdir(directory, { recursive: true });
const response = await fetch(
  'https://raw.githubusercontent.com/nvkelso/natural-earth-vector/master/geojson/ne_10m_admin_0_countries.geojson',
  { headers: { 'User-Agent': 'WorldFlutterPlayground/0.2' } },
);
if (!response.ok) throw new Error(`Natural Earth: ${response.status}`);
const data = await response.json();
const features = data.features.filter(f => f.properties.ADM0_A3 === 'ISR');
if (!features.length) throw new Error('Israel geometry missing');
await fs.writeFile(path.join(directory, 'region.json'), JSON.stringify({
  source: 'Natural Earth 1:10m',
  features: features.map(f => ({
    type: 'Feature', properties: { name: f.properties.NAME }, geometry: f.geometry,
  })),
}));
console.log('Updated Israel regional boundary. City geography is not downloaded.');
