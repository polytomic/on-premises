# Deploying Polytomic on Heroku

1. Clone this repository, and `cd` into this folder.
2. Create a new app for your Polytomic Deployment:
```
heroku create my-polytomic-deployment
```

3. If you are not bringing your own database, create one: `heroku addons:create heroku-postgresql:hobby-dev -a my-polytomic-deployment`. If you are providing your own database, please make sure to grant the Polytomic user `superuser` rights to its own database.
4. If you are not bringing your own cache, create one: `heroku addons:create heroku-redis:premium-0`.
5. Polytomic uses Google SSO in order to handle authentication. You will need to setup an OAuth client for Polytomic.
  - In your OAuth Client configuration, Google will allow you to specify *Authorized Javascript Origins*. Set this to `https://$POLYTOMIC_HOST`.
  - In your OAuth Client configuration, Google will allow you to specify *Authorized Redirect URIs*. Set this to `https://$POLYTOMIC_HOST/auth`.

6. You will need to set up the rest of your environment variables:
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

6. Push the container to your heroku account: `heroku container:push app --app my-polytomic-deployment`
7. Release the container: `heroku container:release app --app my-polytomic-deployment`

- adjust redis/postgres sizes in existing instructions
- instruction adjust main dyno
- test dyno sizes/concurrency
- can we assume that they'll have access to ecr? can we push the container directly to heroku?
- do they need to commit the file each time? How can we tell them to upgrade?
