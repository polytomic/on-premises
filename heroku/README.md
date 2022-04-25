# Deploying Polytomic on Heroku

1. Clone this repository, and `cd` into this folder.
2. Log in to Docker Hub: `docker login`.
3. Log in to the Heroku container repository: `heroku container:login`.
4. Open the Dockerfile and replace <polytomic-version> with the version you want to deploy.
5. Create a new app for your Polytomic Deployment:
```
heroku create my-polytomic-deployment
```

6. If you are not bringing your own database, create one: `heroku addons:create heroku-postgresql:standard-0 -a my-polytomic-deployment`. If you are providing your own database, please make sure to grant the Polytomic user `superuser` rights to its own database.
7. If you are not bringing your own cache, create one: `heroku addons:create heroku-redis:premium-0`.
8. Polytomic uses Google SSO in order to handle authentication. You will need to setup an OAuth client for Polytomic.
  - In your OAuth Client configuration, Google will allow you to specify *Authorized Javascript Origins*. Set this to `https://$POLYTOMIC_HOST`.
  - In your OAuth Client configuration, Google will allow you to specify *Authorized Redirect URIs*. Set this to `https://$POLYTOMIC_HOST/auth`.

9. You will need to set up the rest of your environment variables. You can do this from the CLI or through the Heroku UI.
You can find a full explanation of each variable in the 'Configuration' section here: https://docs.polytomic.com/docs/on-premise-setup. Note: if you used Heroku Redis/Postgres rather than your own, those variables will be set already.
```
heroku config:set --app my-polytomic-deployment\
    DEPLOYMENT=<deployment>\
    DEPLOYMENT_KEY=<deploymentKey>\
    DATABASE_URL=postgres://<postgres-connection-string>\
    DATABASE_POOL_SIZE=50\
    REDIS_URL=redis://<redis-connection-string>\
    REDIS_POOL_SIZE=15\
    POLYTOMIC_URL=<polytomicUrl>\
    GOOGLE_CLIENT_ID=<googleClientId>\
    GOOGLE_CLIENT_SECRET=<googleClientSecret>\
    ROOT_USER=you@yourcompany.com
```

Note that the value for `DATABASE_POOL_SIZE` and `REDIS_POOL_SIZE` may vary
based on your specific Postgres and Redis deployment; the values here are
appropriate for `heroku-postgresql:standard-0` and `heroku-redis:premium-0` with
up to two Polytomic dynos running.

10. Push the container to your heroku account: `heroku container:push web --app my-polytomic-deployment`
11. Release the container: `heroku container:release web --app my-polytomic-deployment`

We recommend running with Standard-2X dynos on Heroku.

## Upgrade a deployment

You can upgrade the version of your deployment at any time by following steps 1, 2, 3, 4, 10, and 11.

