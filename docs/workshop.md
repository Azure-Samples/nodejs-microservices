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
|---------------|-----------------|
| GitHub account | https://github.com/join |
| Azure account | TODO https://azcheck.in/sno230125
| A chromium-based browser | https://www.microsoft.com/edge |

We'll use [GitHub Codespaces](https://github.com/features/codespaces) to have an instant dev environment already prepared for this workshop.

TODO warning free tier codespaces

### Working locally

If you prefer to work locally, you can use the [dev container](https://code.visualstudio.com/docs/devcontainers/containers) feature of VS Code to replicate the environment on your machine.

Here's what you need to install on your machine:

| | |
|---------------|-----------------|
| Git           | https://git-scm.com |
| Docker v20+   | TODO |
| Node.js v18+ (optional)  | https://nodejs.org |
| VS Code | https://aka.ms/get-vscode |
| Dev Containers extension for VS Code | TODO |

TODO instruction reload container


You can test your setup by opening a terminal and typing:

```sh
git --version
docker --version
node --version
```

---

## Introduction

In this workshop we'll build a simple dice rolling application, with a website and 3 containerized microservices. The focus will be on the microservices: how to build them using different Node.js frameworks, connect them to their database, and deploy them to Azure. We'll also see how to setup a CI/CD pipeline to deploy our services using Infrastructure as Code (IaC), and how to monitor, debug and scale them.

We'll cover a lot of differents topics and concepts here, but don't worry, we'll take it step by step. 

<div class="note">

> This workshop is designed to be modular: when indicated at the top, some of the parts can be skipped so that you can focus on the topics that interest you the most.

</div>

### Application architecture

Here's the architecture we'll build in this workshop:

![Application architecture](./docs/assets/architecture.drawio.png)

Our application is split in 4 main components:

- A website, built with plain HTML/JavaScript using [Vite](https://vitejs.dev/) and hosted on [Azure Static Web Apps](https://azure.microsoft.com/services/app-service/static/). This website will allow users to login with GitHub, save their preferences and roll dices.

- A settings service, built with [Fastify](https://www.fastify.io/) and hosted on [Azure Container Apps](https://azure.microsoft.com/services/app-service/containers/), using [Azure Cosmos DB](https://azure.microsoft.com/services/cosmos-db/) for its database. This internal API will allow users to save and retrieve their preferences.

- A dice rolls service, built with [NestJS](https://nestjs.com/) and hosted on [Azure Container Apps](https://azure.microsoft.com/services/app-service/containers/), , using [Azure Cosmos DB](https://azure.microsoft.com/services/cosmos-db/) for its database. This internal API will allow users to roll dices and get an history of the last rolls.

- A gateway service, built with [Express](https://expressjs.com/) and hosted on [Azure Container Apps](https://azure.microsoft.com/services/app-service/containers/). This publicly exposed API will act as a proxy between the website and the other APIs, and will check user authentication.

The user authentication will be provided by [Azure Static Web Apps](https://azure.microsoft.com/services/app-service/static/), which will also host our website. It will rely on [GitHub OAuth](https://docs.github.com/en/developers/apps/building-oauth-apps/authorizing-oauth-apps) as an identity provider.

### Why microservices?

Microservices architecture is a way to build applications by splitting them into small, independent services. Each service is responsible for a specific part of the application, and can be developed, deployed and scaled independently.

Microservices architecture has many benefits:

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

Open [this GitHub repository](https://github.com/azure-samples/nodejs-microservices-template), select the **Code** button, then the **Codespaces** tab and click on **Create Codespaces on main**.

![Screenshot of GitHub showing the Codespaces creation](./docs/assets/create-codespaces.png)


The first step

- GitHub template
+ clone locally if needed

### NPM workspace

- explain
- benefits

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
