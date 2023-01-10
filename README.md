# azure-nodejs-microservices

Workshop URL: https://aka.ms/ws?src=gh:sinedied/azure-nodejs-microservices/main/docs/

## Prerequisites

- Node.js 18+
- Docker

## Architecture

<!-- can be edited with https://draw.io -->
![Application architecture](./docs/assets/architecture.drawio.png)

## How to run locally

```bash
npm install
npm start
```

## How to build Docker images

```bash
npm run docker:build
```

## How to setup deployment

```bash
./azure/setup.sh
```
