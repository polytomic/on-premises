<a name="readme-top"></a>

[![Contributors][contributors-shield]][contributors-url]
[![Issues][issues-shield]][issues-url]
[![Pull Requests][pr-shield]][pr-url]
[![Release][release-shield]][release-url]

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
        <li><a href="#helm">Helm</a></li>
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

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### GKE

Follow the steps in the [GKE terraform module](terraform/examples/gke-complete) to deploy Polytomic on GKE.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### EKS

Follow the steps in the [EKS terraform module](terraform/examples/eks-complete) to deploy Polytomic on EKS.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### KIND (Kubernetes in Docker)

To get a sandbox kubernetes environment set up, run the sandbox script located at `hack/sandbox.sh`

It will setup a local kind cluster. Then, [install the helm chart](#helm).

```
./hack/sandbox.sh
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Helm

Add the polytomic chart repo

```
helm repo add polytomic https://charts.polytomic.com
helm repo update
```

Download and edit a values.yaml file if desired.

```
curl https://raw.githubusercontent.com/polytomic/on-premises/master/helm/charts/polytomic/values.yaml -o values.yaml
```

Install the chart (detailed information about the chart can be found [here](helm/charts/polytomic/README.md))

```
helm install polytomic polytomic/polytomic -f values.yaml
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

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

### For Maintainers: Cutting a Release

This repository uses component-specific versioning and tagging. Each Terraform module and the Helm chart are versioned independently.

**Quick reference:**
- [VERSIONING.md](VERSIONING.md) - Complete versioning strategy and release process
- [CHANGELOG.md](CHANGELOG.md) - Index of all component changelogs

**Release process summary:**
1. Update the component's CHANGELOG.md (e.g., `terraform/modules/eks/CHANGELOG.md`)
2. For Helm: Update version in `helm/charts/polytomic/Chart.yaml`
3. Commit changes
4. Create and push a component-specific tag (e.g., `terraform/eks/v1.2.0` or `helm/v1.2.0`)
5. Create a GitHub Release
6. Update root CHANGELOG.md with new version

See [VERSIONING.md](VERSIONING.md) for detailed step-by-step instructions and examples.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!--
## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>
 -->

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->

[contributors-shield]: https://img.shields.io/github/contributors/polytomic/on-premises.svg?style=for-the-badge
[contributors-url]: https://github.com/polytomic/on-premises/graphs/contributors
[stars-shield]: https://img.shields.io/github/stars/polytomic/on-premises.svg?style=for-the-badge
[stars-url]: https://github.com/polytomic/on-premises/stargazers
[issues-shield]: https://img.shields.io/github/issues/polytomic/on-premises.svg?style=for-the-badge
[issues-url]: https://github.com/polytomic/on-premises/issues
[license-shield]: https://img.shields.io/github/license/polytomic/on-premises.svg?style=for-the-badge
[license-url]: https://github.com/polytomic/on-premises/blob/master/LICENSE.md
[release-shield]: https://img.shields.io/github/v/release/polytomic/on-premises?style=for-the-badge
[release-url]: https://github.com/polytomic/on-premises/releases
[pr-shield]: https://img.shields.io/github/issues-pr/polytomic/on-premises?style=for-the-badge
[pr-url]: https://github.com/polytomic/on-premises/pulls
