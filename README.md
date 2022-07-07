# Running Polytomic On-Premises

Most of the information on hosting Polytomic on-premises can be found alongside the
rest of our [documentation](https://polytomic.readme.io/docs/on-premise-setup).
If you are new to Polytomic on-premises, that is the best place to start.

This repo contains instructions for setting up Polytomic on specific container
deployment platforms.


# Platform-specific deployment instructions

Before beginning, please read the [On-Premises Setup document](https://polytomic.readme.io/docs/on-premise-setup).

During setup you will need a specific tagged version to deploy. You can find version tags and their changelogs here: https://docs.polytomic.com/docs/changelog

## Docker Compose
1. Install Docker on your machine, as well as the AWS cli with your credentials that you'll use to pull the image.
2. Copy the contents of `examples/docker-compose.yml` into a new file on your host machine.
3. Edit docker-compose.yml:
    - in the `api` `service` entry, change the `latest` docker image tag to a specific release (i.e. `rel2021.11.04`)
    - Fill in the rest of the mandataory environment variables
    - You can use the built-in docker postgres and redis, but it is _highly_ recommended you configure these as separate redis/postgres instances.
       - To do so, just delete the top-level `postgres` and `cache` service blocks in `docker-compose.yml` and specify your connection strings in the environment variables. 
4. run `docker compose up` -- traffic should be served on `localhost:5100`

#### To upgrade:
1. `docker compose down`
2. Edit `docker-compose.yml` to change the release version of the image. Please use a concrete version tag rather than `latest`.
3. `docker compose up`

## Aptible


1. Add your public SSH key to your Aptible account through the Aptible dashboard
1. Install the Aptible CLI ([instructions](https://deploy-docs.aptible.com/docs/cli)).
1. Login to Aptible CLI if you haven't already: `aptible login`.
1. Clone this repo: `git clone https://github.com/polytomic/polytomic-onprem`
1. Change the working directory to the newly cloned repository: `cd polytomic-onprem`
1. Specify the version of Polytomic that you'd like to install in the `Dockerfile`, and commit it. You can see a full release catalog in the [Changelog](https://polytomic.readme.io/docs/changelog).  We strongly suggest specifying a version number when deploying. For example: `568237466542.dkr.ecr.us-west-2.amazonaws.com/polytomic-onprem:rel2021.06.08.02`
1. Create a new Aptible app: `aptible apps:create your-app-name`
1. The result of `apps:create` will be a git remote url. It's a good idea to setup your remote right now: `git remote add <aptible-git-remote-url>`
1. If you are not bringing your own database, create one: `aptible db:create your-database-name --type postgresql`. Record the value of the newly created database credentials. If you are providing your own database, please make sure to grant the Polytomic user `superuser` rights to its own database.
1. If you are not bringing your own cache, create one: `aptible db:create <db-name> --type redis --version 5.0`. Record the value of the newly created database credentials.
1. Polytomic uses Google SSO in order to handle authentication. You will need to setup an OAuth client for Polytomic.
    - In your OAuth Client configuration, Google will allow you to specify *Authorized Javascript Origins*. Set this to `https://$POLYTOMIC_HOST`.
    - In your OAuth Client configuration, Google will allow you to specify *Authorized Redirect URIs*. Set this to `https://$POLYTOMIC_HOST/auth`.
1. Use the above database values, along with Polytomic-provided values in order configure the app. Note: Polytomic needs to know the URI you are hosting it on. If you intend to use an aptible-supplied hostname, you can remove it from here and setup it up later.
    ```
    aptible config:set --app your-app-name \
        ROOT_USER=<first@users.email> \
        DEPLOYMENT=<identifier-provided-by-polytomic> \
        DEPLOYMENT_KEY=<key-provided-by-polytomic> \
        DATABASE_URL=postgresql://<postgres-connection-string> \
        REDIS_URL=redis://<redis-connection-string> \
        POLYTOMIC_URL=https://<uri-you-intend-to-host-polytomic-on> \
        GOOGLE_CLIENT_ID=<google-client-id> \
        GOOGLE_CLIENT_SECRET=<google-client-secret>
    ```
1. We use the recommended method for [synchronized deploys](https://deploy-docs.aptible.com/docs/synchronized-deploys). To do this we:
   1. Get a new AWS ECR auth token: `aws ecr get-login-password`
   1. Push the code to new branch on aptible without trigging a deploy: `git push aptible master:release-2021-06-23`
   1. Trigger a deploy using the credentials:

   ```
   aptible deploy \
        --app your-app-name \
        --git-commitish release-2021-06-23 \
        --private-registry-username AWS \
        --private-registry-password token-from-aws-ecr-get-login-password
   ```

1. Navigate to your Aptible control panel and create a new endpoint for Polytomic.
   - You can use a custom CNAME or one generated by Aptible, just be sure to update the app configuration after (using `config:set` as above)
   - You do not need to change the port (5100 is the default and correct port to expose).
1. You should be able to sign into Polytomic at the specified host with the specified ROOT_USER.


## Kubernetes

#### Quickstart
To get a sandbox kubernetes environment set up run the sandbox script located at `hack/sandbox.sh`

It will setup a local kind cluster and install the polytomic helm chart.

```
./hack/sandbox.sh
```