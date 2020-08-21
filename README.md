# Polytomic On Premises

This repository contains instructions and scripts for running Polytomic on premises. When run on premises, Polytomic will process all queries within your private cloud.

Find out more about [Polytomic](https://www.polytomic.com) and schedule a demo by emailing [contact@polytomic.com](email:contact@polytomic.com).

## Requirements

- Ability to run Docker containers
- Ability to expose running Polytomic container to external traffic with SSL/TLS termination
- Postgres database for pipeline configuration
- Redis for caching (optional)

## Deploying

We ship Polytomic On Premises as a Docker image. To pull the latest version of the software, use the following image name:

`568237466542.dkr.ecr.us-west-2.amazonaws.com/polytomic-onprem:latest`

A sample [Docker Compose](https://docs.docker.com/compose/) configuration [is available here](./examples/docker-compose.yml).

## Configuration

Polytomic accepts configuration via environment variables. The following are required:

- `ROOT_USER`
  The email address to use when starting for the first time; this user will be able to add additional users and configure Polytomic

- `DEPLOYMENT`
  A unique identifier for your on premises deploy, provided by Polytomic.

- `DEPLOYMENT_KEY`
  The license key for your deployment, provided by Polytomic.

- `DATABASE_URL`
  Connection URL for Polytomic's database; should be in the form of `postgres://user:password@host:port/database`.

- `REDIS_URL`
  Connection URL for Redis; should be in the form of `redis://:password@host:6379/`.

  For SSL/TLS connections specify the protocol as `rediss` (two `s`'s).

  Note: this was previously named `CACHE_URL`; Polytomic will still use that
  environment variable if `REDIS_URL` is unset, however it is deprecated and
  will be removed in a future version.

- `POLYTOMIC_URL`
  Base URL for accessing Polytomic; for example, `https://polytomic.mycompany.com`. This will be used when redirecting back from Google and other integrations after authenticating with OAuth.

- `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`
  Google OAuth Client ID and secret, obtained by creating a [OAuth 2.0 Client ID](https://console.developers.google.com/apis/credentials)

  **Your valid redirect URLs _must_ include `{POLYTOMIC_URL}/auth`.**

## Monitoring

The Polytomic On Premises image exposes a health-check endpoint at `/status.txt`, which can be used to verify the container is up and running.

## First Run

### Database Schema

Polytomic runs database migrations on startup. Therefore the database user accessing the Polytomic database will need permission to create and alter the schema.

### Organization & User

Polytomic uses GSuite for authenticating users. The first user email address is set via the `ROOT_USER` environment variable. This user will be able to add additional users through the web interface.

Note that you only need to add users who will be configuring pipelines in Polytomic; users who interact with the integrations are tracked independently.

## Data We Record

Polytomic On Premises makes the following outbound requests:

- Periodic requests to `ping.polytomic.com` to verify your license is valid and to record usage telemetry; telemetry **does not** include any personally identifiable information.
- Application traces are sent to DataDog; these _may_ include queries executed, but **do not** contain variables used while processing the pipline. These traces help us understand how Polytomic is performing.
- Errors are sent to Sentry.io when they occur to assist us with debugging; error payloads **do not** contain values used to trigger the pipeline.

## Integrations & Connections

Some integrations require additional configuration when running on premises. See the [Integrations documentation](./integrations) for more information.