---
short_title: Node.js Microservices
description: Discover the fundamentals of microservices architecture and how to implement them from code to production monitoring, using Node.js, Docker and Azure.
type: workshop
authors: Yohan Lasorsa
contacts: '@sinedied'
# banner_url: assets/pwa-banner.jpg
duration_minutes: 180
audience: students, devs
level: intermediate
tags: node.js, containers, docker, azure, static web apps, javascript, typescript, microservices
published: false
sections_title:
  - Introduction
---

# Microservices in practice with Node.js, Docker and Azure

In this workshop, discover the fundamentals of microservices architecture and how to implement them from code to production monitoring, using Node.js, Docker and Azure.

We will build a complete application including a website with authentication and 3 microservices, deploy it to Azure using a CI/CD pipeline and then perform load testing to tune the scaling of our services, and use log tracing and monitoring. And we won't even need to use Kubernetes!


## Workshop Objectives
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
| Node.js v18+  | https://nodejs.org |
| Git | https://git-scm.com |
| GitHub account | https://github.com/join |
| Azure account | TODO
| A code editor | https://aka.ms/get-vscode |
| A chromium-based browser | https://www.microsoft.com/edge |

You can test your setup by opening a terminal and typing:

```sh
node --version
git --version
```