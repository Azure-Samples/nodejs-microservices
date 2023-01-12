---
short_title: Node.js Microservices
description: Discover the fundamentals of microservices architecture and how to implement them from code to production, using Node.js, Docker and Azure.
type: workshop
authors: Yohan Lasorsa
contacts: '@sinedied'
# banner_url: assets/pwa-banner.jpg
duration_minutes: 180
audience: students, devs
level: intermediate
tags: node.js, containers, docker, azure, static web apps, javascript, typescript, microservices
published: false
wt_id: 0000-javascript-yolasors
sections_title:
  - Introduction
---

# Microservices in practice with Node.js, Docker and Azure

In this workshop, we'll explore the fundamentals of microservices architecture and how to implement it from code to production, using Node.js, Docker and Azure.

We will build a complete application including a website with authentication and 3 microservices, deploy it to Azure using a CI/CD pipeline, perform load testing to tune the scaling of our services, and use log tracing and monitoring. And we'll do all that without needing to use Kubernetes!

## Goals and topics covered
- Brief review of microservices architecture and its benefits
- Create Node.js services using 3 differents frameworks
  * NestJS
  * Fastify
  * Express
- Containerize services with Docker
- Use Docker multi-stage builds
- Connect services to their database
- Setup a CI/CD pipeline with GitHub Actions
- Deploy services to Azure Container Apps
- Load testing and scaling
- Log tracing and monitoring

## Prerequisites

| | |
|----------------|------------------------------------------------------|
| GitHub account | [Get a free GitHub account](https://github.com/join) |
| Azure account  | [Get a free Azure account](https://azure.microsoft.com/free) |
| A web browser  | https://www.microsoft.com/edge |

We'll use [GitHub Codespaces](https://github.com/features/codespaces) to have an instant dev environment already prepared for this workshop.

If you prefer to work locally, we'll also provide instructions to setup a local dev environment using either VS Code with a [dev container](https://aka.ms/vscode/ext/devcontainer) or a manual install of the needed tools.

---

## Introduction

In this workshop we'll build a simple dice rolling application, with a website and 3 containerized microservices. The focus will be on the microservices: how to build them using different Node.js frameworks, connect them to their database, and deploy them to Azure. We'll also see how to setup a CI/CD pipeline to deploy our services using Infrastructure as Code (IaC), and how to monitor, debug and scale them.

We'll cover a lot of differents topics and concepts here, but don't worry, we'll take it step by step. 

<div class="info" data-title="note">

> This workshop is designed to be modular: when indicated at the top, some of the parts can be skipped so that you can focus on the topics that interest you the most.

</div>

### Application architecture

Here's the architecture we'll build in this workshop:

![Application architecture](./assets/architecture.drawio.png)

Our application is split in 4 main components:

- **A website**, built with plain HTML/JavaScript using [Vite](https://vitejs.dev/) and hosted on [Azure Static Web Apps](https://azure.microsoft.com/services/app-service/static/). This website will allow users to login with GitHub, save their preferences and roll dices.

- **A settings service**, built with [Fastify](https://www.fastify.io/) and hosted on [Azure Container Apps](https://azure.microsoft.com/services/app-service/containers/), using [Azure Cosmos DB](https://azure.microsoft.com/services/cosmos-db/) for its database. This internal API will allow users to save and retrieve their preferences.

- **A dice rolls service**, built with [NestJS](https://nestjs.com/) and hosted on [Azure Container Apps](https://azure.microsoft.com/services/app-service/containers/), , using [Azure Cosmos DB](https://azure.microsoft.com/services/cosmos-db/) for its database. This internal API will allow users to roll dices and get an history of the last rolls.

- **A gateway service**, built with [Express](https://expressjs.com/) and hosted on [Azure Container Apps](https://azure.microsoft.com/services/app-service/containers/). This publicly exposed API will act as a proxy between the website and the other APIs, and will check user authentication.

The user authentication will be provided by [Azure Static Web Apps](https://azure.microsoft.com/services/app-service/static/), which will also host our website. It will rely on [GitHub OAuth](https://docs.github.com/en/developers/apps/building-oauth-apps/authorizing-oauth-apps) as an identity provider.

### Why microservices?

Microservices architecture is a way to build applications by splitting them into small, independent services. Each service is responsible for a specific part of the application, and can be developed, deployed and scaled independently.

Microservices have many benefits:
- **Scalability**: each service can be scaled independently, and can be scaled up or down depending on the load.
- **Resilience**: if one service fails, the others will still be available.
- **Maintainability**: each service can be developed and deployed independently, by different teams, and can be replaced by another service if needed.
- **Flexibility**: each service can be developed with a different technology, and can be replaced by another service if needed.

But there are also some challenges:
- **Complexity**: microservices architecture is more complex than a monolithic application, and requires more infrastructure and tooling.
- **Communication**: services need to communicate with each other, and this can be induce latency and network issues.
- **Debugging**: when a service fails, it can be hard to find the root cause.
- **Monitoring**: it can be difficult to monitor the health of all the services, and detect issues.

We'll see how to address these challenges in this workshop.

---

## Preparation

Before starting the development, we'll need to setup our project and development environment. This includes:

- Creating a new project on GitHub based on a template
- Using a prepared dev container environment on either [GitHub Codespaces](https://github.com/features/codespaces) or [VS Code with Dev Containers extension](https://aka.ms/vscode/ext/devcontainer)

### Creating the project

Open [this GitHub repository](https://github.com/azure-samples/nodejs-microservices-template), select the **Fork** button and click on **Create fork** to create a copy of the project in your own GitHub account.

![Screenshot of GitHub showing the Fork button](./assets/fork-project.png)

Once the fork is created, select the **Code** button, then the **Codespaces** tab and click on **Create Codespaces on main**.

![Screenshot of GitHub showing the Codespaces creation](./assets/create-codespaces.png)

This will start the creation of a dev container environment, which is a pre-configured container with all the needed tools installed. Once it's ready, you have everything you need to start coding. It even ran `npm install` for you!

#### (optional) Working locally with the dev container

If you prefer to work locally, you can also run the dev container on your machine. If you're fine with using Codespaces, you can skip the optional sections.

To work on the project locally using a dev container, first you'll need to install [Docker](https://www.docker.com/products/docker-desktop) and [VS Code](https://code.visualstudio.com/), then install the [Dev Containers](https://aka.ms/vscode/ext/devcontainer) extension.

<div class="tip" data-title="tip">

> You can learn more about Dev Containers in [this video series](https://learn.microsoft.com/shows/beginners-series-to-dev-containers/).
[Check the website](https://containers.dev) and [the specification](https://github.com/devcontainers/spec) if you want to learn more about Dev Containers.

</div>

After that you need to clone the project on your machine:

1. Select the **Code** button, then the **Local** tab and copy your repository url.

![Screenshot of GitHub showing the repository URL](./assets/github-clone.png)

2. Open a terminal and run:

```bash
git clone <your_repo_url>
```

3. Open the project in VS Code, open the **command palette** with `Ctrl+Shift+P` (`Command+Shift+P` on Mac) and enter **Reopen in Container**.

![Screenshot of VS Code showing the "reopen in container" command](./assets/vscode-reopen-in-container.png)

The first time it will take some time to download and setup the container image, meanwhile you can go ahead and read the next sections.

Once the container is ready, you will see "Dev Container: Node.js" in the bottom left corner of VSCode:

![Screenshot of VS Code showing the Dev Container status](./assets/vscode-dev-container-status.png)

#### (optional) Working locally without the dev container

If you want to work locally without using a dev container, you'll need to clone the project and install the following tools:

| | |
|---------------|--------------------------------|
| Git           | [Get Git](https://git-scm.com) |
| Docker v20+   | [Get Docker](https://docs.docker.com/get-docker) |
| Node.js v18+  | [Get Node.js](https://nodejs.org) |
| Azure CLI     | [Get Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli#install) |
| GitHub CLI    | [Get GitHub CLI](https://cli.github.com/manual/installation) |
| Azure Static Web Apps CLI | [Get Azure Static Web Apps CLI](https://github.com/Azure/static-web-apps-cli#installing-the-cli-with-npm-yarn-or-pnpm) |
| Bash v3+      | [Get bash](https://www.gnu.org/software/bash/) (Windows users can use **Git bash** that comes with Git) |
| Perl v5+      | [Get Perl](https://www.perl.org/get.html) |
| jq            | [Get jq](https://stedolan.github.io/jq/download) |
| A code editor | [Get VS Code](https://aka.ms/get-vscode) |

You can test your setup by opening a terminal and typing:

```sh
git --version
docker --version
node --version
az --version
gh --version
swa --version
bash --version
perl --version
jq --version
```

---

## Overview of the project

The project template you forked is a monorepo, a single repository containing multiple projects. It's organized as follows (for the most important files):

```
.azure/           # Azure infrastructure templates and scripts (we'll detail it later)
.devcontainer/    # Dev container configuration
packages/         # The different services of our app
|- gateway-api/   # The API gateway, created with generator-express
|- settings-api/  # The settings API, created with Fastify CLI
|- dice-api/      # The dice API, created with NestJS CLI
+- website/       # The website, created with Vite CLI
api.http          # HTTP requests to test our APIs
package.json      # NPM workspace configuration
```

As we'll be using Node.js to build our APIs and website, we had setup a [NPM workspace](https://docs.npmjs.com/cli/using-npm/workspaces) to manage the dependencies of all the projects in a single place. This means that when you run `npm install` in the root of the project, it will install all the dependencies of all the projects and make it easier to work in a monorepo.

For example, you can run `npm run <script_name> --workspaces` in the root of the project to run a script in all the projects, or `npm run <script_name> --workspace=packages/gateway-api` to run a script for a specific project. 

Otherwise, you can use your regular `npm` commands in any project folder and it will work as usual.

### About the services

The differents services of our app were generated using the respective CLI or generator of the frameworks we'll be using, with very few modifications so we start working quickly on the most important parts of the workshop.

The only changes we made to the generated code is to remove files we don't need, configure the ports for each API, and setup [pino-http](https://github.com/pinojs/pino-http) as the logger to have a consistent logging format across all the services.

<div class="info" data-title="note">

> If you want to see how the services were generated and the details of the changes we made, you can look at [this script](https://github.com/Azure-Samples/nodejs-microservices/blob/main/scripts/create-projects.sh) we used to generate the projects.

</div>

---

## Settings API

- fastify
- create mock DB and service (in memory + simulated delay)
- PUT /settings/{user_id} { dice_faces: 6 }
- GET /settings/{user_id}
- test with REST client/curl
- Dockerfile
- test

---

## Dice API

- nestjs
- create mock DB and service (in memory + simulated delay)
- POST /rolls { dice_faces: } => { result: 4 } + store in DB (w/ date + faces)
- GET  /rolls/history?count=50&dice_faces=6 => { result: [2, 4, 6] }
- test with REST client/curl
- Dockerfile with Docker build
- test

---

## Gateway API

- express
- need auth header with user_id (from SWA) => middleware
- PUT /settings/
- GET /settings/
- POST /rolls { count: 100 } => get settings + N calls to Dice API
  => { result: 4, duration: XX (in ms) }
- GET  /rolls/history?count=50 => get settings + call to Dice API
  => { result: [2, 4, 6] }
- test with REST client/curl
- Dockerfile
- Docker compose to run all yml
- test

---

## Website

- Vite + vanilla HTML/JS
- Start from template!
- Introduce SWA + CLI
- Connect auth for github login
- Set dice type preference (call PUT /settings)
- Roll N dices and show results / time
- Show last N rolls

---

## Azure setup
- Setup azure account
- Explain SWA / ACR / ACA / CosmosDB
- Explain IaC / Bicep
- Use provided Bicep templates + AZ CLI command to create infra
- Explain some of the setup: gateway public, other microservices private, SWA API proxy...

---

## Connecting database

- Explain CosmosDB
- provide connection string in env + adapt code for Settings API
- provide connection string in env + adapt code for Dice API
- test locally
- look in data explorer

---

## Adding CI/CD

- Explain GitHub actions
- Create Azure SP + add secrets
- Create GHA workflow
- Deploy
- test

---

## Monitoring and scaling

- Create dashboard cpu/memory
- test with 100, 1k, 10k rolls -> view graphs
- review ACA scaling rules -> change with AZ CLI
- test again -> view graphs

                    {
                        "name": "scale",
                        "http": {
                            "metadata": {
                                "concurrentRequests": "100"
                            }
                        }
                    }

---

## Logs and tracing
- connect to Dice API logs with AZ CLI
- explain app/system logs
- explain why tracing (N calls, from which request?)
- create log analytics request to trace all requests from api gateway call

--dapr?

---

## Conclusion
- clean up infra
