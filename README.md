# Polytomic On Premises

This repository contains instructions and scripts for running Polytomic on premises. When run on premises, Polytomic will process all queries within your private cloud.

## Requirements

* Ability to run Docker containers
* Ability to expose running Polytomic container to external traffic with SSL/TLS termination
* Postgres database

## Configuration

Polytomic accepts configuration via environment variables. The following are required:

* `DEPLOYMENT`
  A unique key for your on premises deploy, provided by Polytomic.

* `DATABASE_URL`
  Connection URL for Polytomic's database; should be in the form of `postgres://user:password@host:port/database`.

* `POLYTOMIC_URL`
  Base URL for accessing Polytomic; for example, `https://polytomic.mycompany.com`. This will be used when redirecting back from Google and other integrations after authenticating with OAuth.

* `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`
  Google OAuth Client ID and secret, obtained by creating a [OAuth 2.0 Client ID](https://console.developers.google.com/apis/credentials)

  Your valid redirect URLs *must* include `{POLYTOMIC_URL}/auth`.

The following environment variables are optional, depending on which integrations you plan to use:

* `ZENDESK_CLIENT_ID`, `ZENDESK_CLIENT_SECRET`
  Zendesk OAuthn Client ID and secret; required if you intend to use Zendesk with Polytomic. An OAuth client may be created in your Zendesk domain by visiting:

  `https://<my_company>.zendesk.com/agent/admin/api/oauth_clients`

  You will need to ensure Zendesk can communicate with Polytomic; Zendesk publishes the [IP ranges](https://support.zendesk.com/hc/en-us/articles/203660846) they use.

* `LIVECHAT_CLIENT_ID`, `LIVECHAT_CLIENT_SECRET`
* `SHIPBOB_CLIENT_ID`, `SHIPBOB_CLIENT_SECRET`

## Information We Need

In order to provide secure communication with our integrations, we whitelist specific domains. For on premises installations, we use `<deployment>.op.polytomic.net`.

Before you can use the integrations, we'll need the hostname which we should point your on premises domain to. You may choose to use this as the primary domain for your installation, as well. In that case, set `POLYTOMIC_URL` accordingly.

## First Run

Before you can start Polytomic, you need to create the base database schema. You can do this using the provided Docker container.

```bash
$ docker run -it -e DATABASE_URL=... polytomic-onprem:latest ./migrate up
```

After migrations have completed, you can run the container without a command, and the server will start.

## Data We Send

Polytomic On Premises makes the following outbound requests:

* periodic ping to `license.polytomic.com` to verify your license is valid
* application traces are sent to DataDog; these *do not* include queries executed, but do help us understand how Polytomic is performing
* errors are sent to Sentry.io when they occur to assist us with debugging
