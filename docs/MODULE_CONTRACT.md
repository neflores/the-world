# Embedding World

Use `WorldModule(host:, capabilities:, bridge:, source:)` in any of the four
supported host surfaces. The Playground is an executable example. World receives
safe projections and emits typed intents; it never imports host routing, auth,
Fluxer, payment or transport implementations. `WorldView` is a compatibility API
for 0.2 consumers, not the recommended embedding boundary.

Capabilities control availability, not backend authorization. Dispatch rechecks
the current capabilities, including actions from a previously opened dialog.
The host must authorize and await every write. Failed writes retain the previous
projection and the editor stays open. Favorite ownership is the host user's
personal state; the demo stores it locally.

The source emits an initial snapshot and ordered replacements without a
load/watch gap. Source errors preserve a last known snapshot (`stale`); errors
before the first value produce `error`. Other lifecycle values are `loading`,
`ready`, `empty` and `restricted`. Replacing the source cancels the old subscription
and resets navigation. Source disposal and reconnect policy belong to the host.

Diagnostics identify source, asset and intent failures through the bridge. Error
objects are host-only and must be redacted before logging; UI displays safe text.
Never send credentials or private domain DTOs inside public World projections.

No license is added: the owner explicitly deferred this decision on 2026-09-19.

Inject `WorldClock` for server-aligned time; `ManualWorldClock` supports repeatable
scenarios. Expiry refreshes every five seconds, or immediately when the manual
clock changes, including open World dialogs. `WorldRenderPolicy` defines the
avatar budget and motion policy. Sampling is stable across payload order, keeps
the viewer first, and strips hidden/expired users. Hidden users must still be
omitted by the backend; the snapshot's filtering is only defense in depth.
