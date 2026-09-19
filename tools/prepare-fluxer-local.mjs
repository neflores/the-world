// Prepare an isolated, loopback-only instance from the official Compose files.
// Existing credentials are never replaced.
import { createECDH, randomBytes } from 'node:crypto';
import { existsSync, readFileSync, writeFileSync } from 'node:fs';
import { join, resolve } from 'node:path';

const directory = resolve(process.argv[2] ?? '');
if (!process.argv[2] || !existsSync(join(directory, 'docker-compose.yml'))) {
  throw new Error('Pass the directory containing the official Fluxer Compose files.');
}
const envPath = join(directory, '.env');
if (existsSync(envPath)) {
  throw new Error('The instance already has .env; credentials were preserved.');
}
const env = new Map([
  ['FLUXER_DOMAIN', '127.0.0.1'],
  ['FLUXER_PUBLIC_SCHEME', 'http'],
  ['FLUXER_PUBLIC_PORT', '8088'],
  ['FLUXER_PUBLIC_ORIGIN', 'http://127.0.0.1:8088'],
  ['FLUXER_EDGE_BIND', '127.0.0.1:8088'],
  ['FLUXER_IMAGE_TAG', 'v1'],
  ['FLUXER_S3_ACCESS_KEY', 'fluxer'],
  ['LIVEKIT_API_KEY', 'fluxer'],
  ['FLUXER_VAPID_EMAIL', 'dev@example.invalid'],
  ['FLUXER_EMAIL_ENABLED', 'false'],
  ['FLUXER_LIVEKIT_USE_EXTERNAL_IP', 'false'],
  ['FLUXER_LIVEKIT_NODE_IP', '127.0.0.1'],
]);
for (const name of [
  'POSTGRES_PASSWORD', 'MEILI_MASTER_KEY', 'FLUXER_S3_SECRET_KEY',
  'FLUXER_SUDO_MODE_SECRET', 'FLUXER_CONNECTION_INITIATION_SECRET',
  'FLUXER_GATEWAY_RPC_AUTH_TOKEN', 'FLUXER_ERLANG_COOKIE',
  'FLUXER_MEDIA_PROXY_SECRET_KEY', 'FLUXER_ADMIN_SECRET_KEY_BASE',
  'FLUXER_ADMIN_OAUTH_CLIENT_SECRET', 'LIVEKIT_API_SECRET',
]) {
  env.set(name, randomBytes(32).toString('hex'));
}
env.set('FLUXER_MEDIA_PROXY_UPLOAD_RELAY_SECRET_BASE64', randomBytes(32).toString('base64'));
const vapid = createECDH('prime256v1');
vapid.generateKeys();
env.set('FLUXER_VAPID_PUBLIC_KEY', vapid.getPublicKey().toString('base64url'));
env.set('FLUXER_VAPID_PRIVATE_KEY', vapid.getPrivateKey().toString('base64url'));
const compose = readFileSync(join(directory, 'docker-compose.yml'), 'utf8');
for (const [, required] of compose.matchAll(/\$\{([A-Z_0-9]+):\?/g)) {
  if (!env.has(required)) throw new Error(`Missing required Compose variable: ${required}`);
}
writeFileSync(envPath, [...env].map(([key, value]) => `${key}=${value}`).join('\n') + '\n', {
  encoding: 'utf8', flag: 'wx', mode: 0o600,
});
writeFileSync(join(directory, 'docker-compose.local.yml'), `# Local development: expose services only on this computer.
services:
  livekit:
    ports: !override
      - "127.0.0.1:7881:7881"
      - "127.0.0.1:7882:7882/udp"
`, 'utf8');
console.log(`Prepared local Fluxer configuration in ${directory}; credentials were not printed.`);
