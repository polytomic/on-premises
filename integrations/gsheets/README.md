# Google Sheets

Set the following environment variables if you plan to use Google Sheets connections:

- `GSHEETS_CLIENT_ID`, `GSHEETS_CLIENT_SECRET`
  Google OAuth Client ID and secret, obtained by creating a [OAuth 2.0 Client ID](https://console.developers.google.com/apis/credentials).

  The Google Drive API and Google Sheets API *must* be enabled for the associated project. See [Google Help](https://support.google.com/googleapi/answer/6158841?hl=en) for instructions on enabling APIs.

  Your valid redirect URLs _must_ include `{POLYTOMIC_URL}/connect/gsheets`.
