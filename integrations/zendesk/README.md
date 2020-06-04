# Polytomic for Zendesk

Set the following environment variables if you plan to use Zendesk.

- `ZENDESK_CLIENT_ID`, `ZENDESK_CLIENT_SECRET`
  Zendesk OAuth Client ID and secret; required if you intend to use Zendesk with Polytomic. An OAuth client may be created in your Zendesk domain by visiting:

  `https://<my_company>.zendesk.com/agent/admin/api/oauth_clients`

  You will need to ensure Zendesk can communicate with Polytomic; Zendesk publishes the [IP ranges](https://support.zendesk.com/hc/en-us/articles/203660846) they use.

  Your valid redirect URLs _must_ include `{POLYTOMIC_URL}/connect/zendesk_support`.
