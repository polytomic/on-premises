## Polytomic for LiveChat

Set the following environment variables if you plan to use Livechat.

- `LIVECHAT_CLIENT_ID`, `LIVECHAT_CLIENT_SECRET`
  LiveChat OAuth Client ID and secret; required if you intend to use LiveChat with Polytomic.

  An OAuth client may be created for your LiveChat license by visiting:

  `https://developers.livechatinc.com/console/apps`

  Your valid redirect URLs _must_ include `{POLYTOMIC_URL}/connect/livechat`.