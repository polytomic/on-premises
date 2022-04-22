# Deploying Polytomic on Heroku

1. Clone this repository, and `cd` into this folder.
2. Open Dockerfile and replace <polytomic-version> with the version you want to deploy
3. Create a new app for your Polytomic Deployment:
```
heroku create my-polytomic-deployment
```

4. If you are not bringing your own database, create one: `heroku addons:create heroku-postgresql:standard-0 -a my-polytomic-deployment`. If you are providing your own database, please make sure to grant the Polytomic user `superuser` rights to its own database.
5. If you are not bringing your own cache, create one: `heroku addons:create heroku-redis:premium-0`.
6. Polytomic uses Google SSO in order to handle authentication. You will need to setup an OAuth client for Polytomic.
  - In your OAuth Client configuration, Google will allow you to specify *Authorized Javascript Origins*. Set this to `https://$POLYTOMIC_HOST`.
  - In your OAuth Client configuration, Google will allow you to specify *Authorized Redirect URIs*. Set this to `https://$POLYTOMIC_HOST/auth`.

7. You will need to set up the rest of your environment variables. You can do this from the CLI or through the Heroku UI.
You can find a full explanation of each variable at https://docs.polytomic.com. Note: if you used Heroku Redis/Postgres, those variables will be set already.
```
heroku config:set --app my-polytomic-deployment\
    DEPLOYMENT=<deployment>\
    DEPLOYMENT_KEY=<deploymentKey>\
    DATABASE_URL=postgres://<postgres-connection-string>\
    REDIS_URL=redis://<redis-connection-string>\
    POLYTOMIC_URL=<polytomicUrl>\
    GOOGLE_CLIENT_ID=<googleClientId>\
    GOOGLE_CLIENT_SECRET=<googleClientSecret>\
    ROOT_USER=you@yourcompany.com
```

8. Push the container to your heroku account: `heroku container:push web --app my-polytomic-deployment`
9. Release the container: `heroku container:release web --app my-polytomic-deployment`

## Upgrade a deployment

You can upgrade the version of your deployment at any time by following steps 1, 2, 8, and 9.
- instruction adjust main dyno
- test dyno sizes/concurrency
