## Connecting to ShipBob

Set the following environment variables if you plan to use ShipBob.

- `SHIPBOB_CLIENT_ID`, `SHIPBOB_CLIENT_SECRET`
  ShipBob OAuth Client ID and secret; required if you intend to use ShipBob with Polytomic.

  Instructions for requesting an OAuth client are available on the [ShipBob Developer site](https://developer.shipbob.com/auth)

  Your valid redirect URLs _must_ include `{POLYTOMIC_URL}/connect/shipbob`.
