<a name="readme-top"></a>

[![Contributors][contributors-shield]][contributors-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]




<!-- PROJECT LOGO -->
<br />
<div align="center">

<h1 align="center">Polytomic On-Premises</h1>

  <p align="center">
    Most of the information on hosting Polytomic on-premises can be found alongside the rest of our documentation. If you are new to Polytomic on-premises, that is the best place to start. This repo contains instructions for setting up Polytomic on specific container deployment platforms.
    <br />
    <a href="https://polytomic.readme.io/docs/on-premise-setup"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://polytomic.com">View Demo</a>
    ·
    <a href="https://github.com/polytomic/on-premises/issues">Report Bug</a>
    ·
    <a href="https://github.com/polytomic/on-premises/issues">Request Feature</a>
  </p>
</div>



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
    </li>
    <li>
      <a href="#deployments">Deployments</a>
      <ul>
        <li><a href="#ecs">ECS</a></li>
        <li><a href="#docker-compose">Docker Compose</a></li>
        <li><a href="#aptible">Aptible</a></li>
        <li><a href="#gke">GKE</a></li>
        <li><a href="#eks">EKS</a></li>
        <li><a href="#kind">KIND</a></li>
      </ul>
    </li>
    <li><a href="#contributing">Contributing</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project

Before beginning, please read the [On-Premises Setup document](https://polytomic.readme.io/docs/on-premise-setup).

During setup you will need a specific tagged version to deploy. You can find version tags and their changelogs here: https://docs.polytomic.com/changelog


<p align="right">(<a href="#readme-top">back to top</a>)</p>


## Deployments

Polytomic offers a number of deployment options. The following sections will walk you through the steps to deploy Polytomic on each platform.

### ECS

Follow the steps in the [ECS terraform module](terraform/modules/ecs) to deploy Polytomic on ECS.

A number of examples can be found in the [terraform/examples](terraform/examples/) directory.


<p align="right">(<a href="#readme-top">back to top</a>)</p>


### Docker Compose
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



### Aptible


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


### GKE

Follow the steps in the [GKE terraform module](terraform/examples/gke-complete) to deploy Polytomic on GKE.


### EKS

Follow the steps in the [EKS terraform module](terraform/examples/eks-complete) to deploy Polytomic on EKS.


### Kind

To get a sandbox kubernetes environment set up, run the sandbox script located at `hack/sandbox.sh`

It will setup a local kind cluster and install the polytomic helm chart.

```
./hack/sandbox.sh
```


<!-- CONTRIBUTING -->
## Contributing

Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Install git hooks (`git config core.hooksPath hack/hooks`)
3. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
4. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
5. Push to the Branch (`git push origin feature/AmazingFeature`)
6. Open a Pull Request

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- 
## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>
 -->




<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/polytomic/on-premises.svg?style=for-the-badge
[contributors-url]: https://github.com/github_username/repo_name/graphs/contributors
[forks-shield]: https://img.shields.io/github/contributors/polytomic/on-premises.svg?style=for-the-badge
[forks-url]: https://github.com/github_username/repo_name/network/members
[stars-shield]: https://img.shields.io/github/contributors/polytomic/on-premises.svg?style=for-the-badge
[stars-url]: https://github.com/github_username/repo_name/stargazers
[issues-shield]: https://img.shields.io/github/contributors/polytomic/on-premises.svg?style=for-the-badge
[issues-url]: https://github.com/github_username/repo_name/issues

