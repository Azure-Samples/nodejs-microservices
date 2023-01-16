---
short_title: Node.js Microservices
description: Discover the fundamentals of microservices architecture and how to implement it from code to production, using Node.js, Docker and Azure.
type: workshop
authors: Yohan Lasorsa
contacts: '@sinedied'
# banner_url: assets/todo-banner.jpg
duration_minutes: 180
audience: students, devs
level: intermediate
tags: node.js, containers, docker, azure, static web apps, javascript, typescript, microservices
published: false
wt_id: javascript-0000-yolasors
oc_id: AID3057430
sections_title:
  - Welcome
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
|----------------------|------------------------------------------------------|
| GitHub account       | [Get a free GitHub account](https://github.com/join) |
| Azure account        | [Get a free Azure account](https://azure.microsoft.com/free) |
| A web browser        | [Get Microsoft Edge](https://www.microsoft.com/edge) |
| JavaScript knowledge | [JavaScript tutorial on MDN documentation](https://developer.mozilla.org/docs/Web/JavaScript)<br>[JavaScript for Beginners on YouTube](https://www.youtube.com/playlist?list=PLlrxD0HtieHhW0NCG7M536uHGOtJ95Ut2) |

We'll use [GitHub Codespaces](https://github.com/features/codespaces) to have an instant dev environment already prepared for this workshop.

If you prefer to work locally, we'll also provide instructions to setup a local dev environment using either VS Code with a [dev container](https://aka.ms/vscode/ext/devcontainer) or a manual install of the needed tools.

---

## Introduction

In this workshop we'll build a simple dice rolling application, with a website and 3 containerized microservices. The focus will be on the microservices: how to build them using different Node.js frameworks, connect them to their database, and deploy them to Azure. We'll also see how to setup a CI/CD pipeline to deploy our services using Infrastructure as Code (IaC), and how to monitor, debug and scale them.

We'll cover a lot of differents topics and concepts here, but don't worry, we'll take it step by step. 

<div class="info" data-title="note">

> This workshop is designed to be modular: when indicated, some of the parts can be skipped so that you can focus on the topics that interest you the most.

</div>

### Application architecture

Here's the architecture of the application we'll build in this workshop:

![Application architecture](./assets/architecture.drawio.png)

Our application is split into 4 main components:

1. **A website**, built with plain HTML/JavaScript using [Vite](https://vitejs.dev/) and hosted on [Azure Static Web Apps](https://azure.microsoft.com/services/app-service/static/). This website will allow users to login with GitHub, save their preferences and roll dices.

2. **A settings service**, built with [Fastify](https://www.fastify.io/) and hosted on [Azure Container Apps](https://azure.microsoft.com/services/app-service/containers/), using [Azure Cosmos DB](https://azure.microsoft.com/services/cosmos-db/) for its database. This internal API will allow users to save and retrieve their preferences.

3. **A dice rolls service**, built with [NestJS](https://nestjs.com/) and hosted on [Azure Container Apps](https://azure.microsoft.com/services/app-service/containers/), , using [Azure Cosmos DB](https://azure.microsoft.com/services/cosmos-db/) for its database. This internal API will allow users to roll dices and get an history of the last rolls.

4. **A gateway service**, built with [Express](https://expressjs.com/) and hosted on [Azure Container Apps](https://azure.microsoft.com/services/app-service/containers/). This publicly exposed API will act as a proxy between the website and the other APIs, and will check user authentication.

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
- Using a prepared dev container environment on either [GitHub Codespaces](https://github.com/features/codespaces) or [VS Code with Dev Containers extension](https://aka.ms/vscode/ext/devcontainer) (or a manual install of the needed tools)

### Creating the project

Open [this GitHub repository](https://github.com/azure-samples/nodejs-microservices-template), select the **Fork** button and click on **Create fork** to create a copy of the project in your own GitHub account.

![Screenshot of GitHub showing the Fork button](./assets/fork-project.png)

Once the fork is created, select the **Code** button, then the **Codespaces** tab and click on **Create Codespaces on main**.

![Screenshot of GitHub showing the Codespaces creation](./assets/create-codespaces.png)

This will start the creation of a dev container environment, which is a pre-configured container with all the needed tools installed. Once it's ready, you have everything you need to start coding. It even ran `npm install` for you!

<div class="info" data-title="note">

> You don't have to worry about Codespaces usage cost for this workshop, as it's free for forks of our template repository. For personal usage, Codespaces includes up to 60 hours of free usage per month for all GitHub users, see [the pricing details here](https://github.com/features/codespaces).

</div>

#### [optional] Working locally with the dev container

If you prefer to work locally, you can also run the dev container on your machine. If you're fine with using Codespaces, you can skip directly to the next section.

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

3. Open the project in VS Code, open the **command palette** with `Ctrl+Shift+P` (`Command+Shift+P` on macOS) and enter **Reopen in Container**.

![Screenshot of VS Code showing the "reopen in container" command](./assets/vscode-reopen-in-container.png)

The first time it will take some time to download and setup the container image, meanwhile you can go ahead and read the next sections.

Once the container is ready, you will see "Dev Container: Node.js" in the bottom left corner of VSCode:

![Screenshot of VS Code showing the Dev Container status](./assets/vscode-dev-container-status.png)

#### [optional] Working locally without the dev container

If you want to work locally without using a dev container, you'll need to clone the project and install the following tools:

| | |
|---------------|--------------------------------|
| Git           | [Get Git](https://git-scm.com) |
| Docker v20+   | [Get Docker](https://docs.docker.com/get-docker) |
| Node.js v18+  | [Get Node.js](https://nodejs.org) |
| Azure CLI     | [Get Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli#install) |
| GitHub CLI    | [Get GitHub CLI](https://cli.github.com/manual/installation) |
| Azure Static Web Apps CLI | [Get Azure Static Web Apps CLI](https://github.com/Azure/static-web-apps-cli#installing-the-cli-with-npm-yarn-or-pnpm) |
| pino-pretty log formatter | [Get pino-pretty](https://github.com/pinojs/pino-pretty#install) |
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

```sh
.azure/           # Azure infrastructure templates and scripts
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

We generated the base code of our differents services with the respective CLI or generator of the frameworks we'll be using, with very few modifications made so we can start working quickly on the most important parts of the workshop.

The only changes we made to the generated code is to remove the files we don't need, configure the ports for each API, and setup [pino-http](https://github.com/pinojs/pino-http) as the logger to have a consistent logging format across all the services.

<div class="info" data-title="note">

> If you want to see how the services were generated and the details of the changes we made, you can look at [this script](https://github.com/Azure-Samples/nodejs-microservices/blob/main/scripts/create-projects.sh) we used to generate the projects.

</div>

---

<div class="info" data-title="skip notice">

> If you want to skip the Settings API implementation and jump directly to the next section, run this command in the terminal to get the completed code directly: `TODO`

</div>

## Settings API

We'll start by creating the Settings API, which will be responsible for storing the settings of each user. 

It will be a simple API with two endpoints:
- `PUT /settings/{user_id}`: update settings of a user
- `GET /settings/{user_id}`: retrieve settings of a user

The settings data we'll store for each user will be the number of sides of the dice they want to use, using the following format:

```json
{
  "sides": 6
}
```

### Introducing Fastify

We'll be using [Fastify](https://www.fastify.io/) to create our Settings API. Fastify is a web framework highly focused on providing the best developer experience with the least overhead and a powerful plugin architecture.

It's very similar to Express, but it's much faster and more lightweight making it a good choice for microservices. It also comes with first-class TypeScript support, though we'll be using here the default JavaScript template.

### Creating the database plugin

To store the settings of each user, we'll need at some point a database. For now, we'll start by using a mock with an in-memory database, and we'll add the proper connection later when our database will be deployed.

Let's start by creating a plugin for Fastify to make it easy to use in our API.

Create a new file `packages/settings-api/plugins/database.js` with the following content:

```js
import fp from 'fastify-plugin'

// the use of fastify-plugin is required to be able
// to export the decorators to the outer scope

export default fp(async function (fastify, opts) {
  fastify.decorate('db', new MockDatabase());
});
```

Plugins in Fastify are just functions that receive the Fastify instance and the options passed to the plugin. All plugins within the `plugins/` folder will be automatically loaded by Fastify when the server starts.

Using the `decorate` method, we can add properties to the Fastify instance, which will be available in all the routes of our API. It's a form of [dependency injection](https://en.wikipedia.org/wiki/Dependency_injection). We use it here to provide a `db` property that will be an instance of our database service.

Now we'll implement the `MockDatabase` class. Add this code at the bottom of the file:

```js
class MockDatabase {
  constructor() {
    this.db = {};
  }

  async saveSettings(userId, settings) {
    await this.#delay();
    this.db[userId] = settings;
  }
  
  async getSettings(userId) {
    await this.#delay();
    return this.db[userId];
  }

  async #delay() {
    return new Promise(resolve => setTimeout(resolve, 10));
  }
}
```

<div class="tip" data-title="tip">

> We are using the **async/await** keywords to allow asynchronous, promise-based behavior to be written like regular synchronous code. You can read more about it in the [MDN documentation](https://developer.mozilla.org/docs/Learn/JavaScript/Asynchronous/Promises#async_and_await).

</div>

As you can see, we are using a simple object to store the settings of each user. We are also adding a delay of 10ms to simulate the latency of a real database call.

<div class="tip" data-title="tip">

> Did you noticed the `#` before the `#delay()` method? This new feature of JavaScript means that this method is private, and only class members are allowed to call it. You can read more about it in the [MDN documentation](https://developer.mozilla.org/docs/Web/JavaScript/Reference/Classes/Private_class_fields).

</div>

### Creating the routes

Now that we have our database plugin, we can create the routes for our API.

Create a new file `packages/settings-api/routes/settings.js` with the following content:

```js
export default async function (fastify, opts) {

}
```

<div class="tip" data-title="tip">

> In the VS Code editor, you directly add folders when creating a new file by adding them in the path when asked for the file name.
> ![Create a new file with intermediate folders in VS Code](./assets/vscode-create-folder.png)

</div>

Just like plugins, routes are also functions that receive the Fastify instance and the options passed to the plugin. All routes within the `routes/` folder will be automatically loaded by Fastify when the server starts, and **folder names will be used as prefixes for the routes** by convention.

#### Adding the PUT route

We'll start by adding the `PUT /settings/{user_id}` route. Add this code inside the function we just created:

```js
fastify.put('/:userId', async function (request, reply) {
  request.log.info(`Saving settings for user ${request.params.userId}`);
  await fastify.db.saveSettings(request.params.userId, request.body);
  reply.code(204);
});
```

<div class="tip" data-title="tip">

> We use the HTTP verb `PUT` to create or update a resource. In this case, we are creating or updating the settings of a user. This is the common way to implement the "create or update" operation in REST APIs.

</div>

We want to retrieve the `userId` from the URL, so we use the `:userId` syntax in the route definition to define a parameter. We can then access it using `request.params.userId`.

Notice that we do not need to import anything to use the logger and the database, as they provided respectively by the `request` and `fastify` objects.

Finally, we are using the `reply` object to return the HTTP status `204` (meaning "No Content") response, which is a standard way to return an empty response when we create or update a resource in REST APIs.

#### Adding data validation

Wait a minute, what about the request body data? Do we really want to save just *any* data received in our database? Definitely not!

We should validate the data before saving it, and return an error if the data is invalid. Fastify provides a very powerful and convenient validation system that we can use to validate the request body, based on [JSON Schema](https://json-schema.org/).

We can specify the JSON Schema for the request body the optional route options object. Add this code just before the route definition:

```js
const putOptions = {
  schema: {
    body: {
      type: 'object',
      properties: {
        sides: { type: 'number' }
      }
    }
  }
}
```

Then add the `putOptions` object as the second parameter of the `fastify.put()` method:

```js
fastify.put('/:userId', putOptions, async function (request, reply) {
  // ...
});
```

Now fastify will take care of validating the request body, and return an error if the data is invalid.

#### Adding the GET route

Now let's add another route to retrieve the settings of a user. Add this code below the `PUT` route definition:

```js
fastify.get('/:userId', async function (request, reply) {
  const settings = await fastify.db.getSettings(request.params.userId);
  if (settings) {
    return settings;
  }
  return { sides: 6 };
});
```

This time we are using the `GET` HTTP verb, and we are returning the settings of the user if they exist, or a default value if they don't.

Notice that we are returning the settings directly, without using the `reply` object. This is because Fastify will automatically convert the returned object to a JSON response, with the correct `Content-Type` header and a status code `200` by default.

### Testing our API

It's now time to test our API! First we need to start the server. Run the following command in the terminal:

```bash
npm start --workspace=settings-api
```

Notice that the logs are displayed in JSON format. 

![Screenshot showing JSON logs in the terminal](./assets/fastify-json-logs.png)

This is because we are using the `pino` logger, the default logger for Fastify. JSON logs are great for machine processing, but not so much for humans. When debugging our apps we can pipe the output to the [`pino-pretty`](https://github.com/pinojs/pino-pretty) tool to format the logs in a more readable way:

```bash
npm start --workspace=settings-api | pino-pretty
```

![Screenshot showing pretty logs in the terminal](./assets/fastify-pretty-logs.png)

Now it's much better! 🙂

We'll  use the [REST client](https://marketplace.visualstudio.com/items?itemName=humao.rest-client) extension for Visual Studio Code to send requests to our API. This extension allows us to write HTTP requests in a regular text file, and send them with a single click. It's very convenient for testing APIs, as it can be committed to the repository and shared with the team.

Open the file `api.http` file and have a look at the content. We defined a few variables at the top of the file using the `@variable_name = <value>` syntax, then the requests for the APIs below. The request syntax is straightforward, and conforms to the HTTP standard:

```http
[<METHOD>] <URL> [<HTTP_VERSION>]
[<headers>]

[<body>]
```

All sections between square brackets are optional. Alternatively, the `curl` syntax is also supported if you prefer it.
You can separate different requests in a file using `###`.

Now click on the **Send Request** text below the `# Get user settings` comment under the "Setting API" section:

![Screenshot showing how to send a request in the .http file](./assets/fastify-send-request.png)

You should see the following response in the **Response** tab, returning the default settings value:

![Screenshot showing the GET response](./assets/fastify-get-response.png)

Then click on the **Send Request** text below the `# Update user settings` comment, and check that you receive a `204` status code in the response.

Finally, try the `# Get user settings` request again, and you should observe the updated settings.

If everything works as expected, you can now stop the server by pressing `Ctrl+C` in the terminal.

<div class="tip" data-title="tip">

> Using the REST client extension is not mandatory, you can use any other tool you want to send requests to your API. For example, you can use [curl](https://curl.se/) or [Postman](https://www.postman.com/).

</div>

### Creating the Dockerfile

Our settings API is now ready for containerization! Containers are a great way to package and deploy applications, as they allow us to isolate the application from the host environment, and to run it in any environment, from a developer's laptop to a cloud provider.

Let's create a file `Dockerfile` under the `packages/settings-api` folder to build a Docker image for our API:

```dockerfile
# syntax=docker/dockerfile:1
FROM node:18-alpine
ENV NODE_ENV=production

WORKDIR /app
COPY ./package*.json ./
COPY ./packages/settings-api ./packages/settings-api
RUN npm ci --omit=dev --workspace=settings-api --cache /tmp/empty-cache
EXPOSE 4001
CMD [ "npm", "start", "--workspace=settings-api" ]
```

The first statement `FROM node:18-alpine` means that we use the [node image](https://hub.docker.com/_/node) as a base, with Node.js 18 installed. The `alpine` variant is a lightweight version of the image, that results in a smaller container size, which is great for production environments.

The second statement `ENV NODE_ENV=production` sets the `NODE_ENV` environment variable to `production`. This is a convention in the Node.js ecosystem to indicate that the app is running in production mode. It enables production optimizations in most frameworks.

After that, we are specifying our work directory with `WORKDIR /app`. We then need to copy our project files to the container. Because we are using NPM workspaces, it's not enough to copy the `./packages/settings-api` folder, we also need to copy the root `package.json` file and more importantly the `package-lock.json` file, to make sure that the dependencies are installed in the same version as in our local environment.

Then we run the `npm ci` command and a few additional parameters, to install the project dependencies:
- `--omit=dev` tells NPM to only install the production dependencies
- `--workspace=settings-api` tells NPM to install the dependencies only for the `settings-api` project
- `--cache /tmp/empty-cache` tells NPM to use an empty cache folder, to avoid saving the download cache in the container. This is not strictly necessary, but it's a good practice to avoid making our container bigger than necessary.

Next the `EXPOSE 4001` instruction tells Docker than our container listen on the network port `4001` at runtime.

Finally, we use the `CMD` instruction to specify the command that will be executed when the container starts. In our case, we want to run the `npm start` command of the `settings-api` project.

We also need to create a `.dockerignore` file to tell Docker which files to ignore when copying files to the image:

```text
node_modules
*.log
```

`.dockerignore` files work the same way as `.gitignore` files. We are ignoring the `node_modules` folder as we'll run `npm ci` ourselves to only install the dependencies we need.

### Testing our Docker image

You can now build our Docker image and run it locally to test it. First, let's 
move to our `packages/settings-api` folder in the terminal:

```bash
cd packages/settings-api
```

Then build the image by running the following command:

```bash
docker build --tag settings-api --file ./Dockerfile ../..
```

We tag the image with the name `settings-api`, and because we are in a NPM workspace, we need to specify the build context to our repository root with `../..`.

After the build is complete, you can run the image with the following command:

```bash
docker run --rm --publish 4001:4001 settings-api
```

The `--rm` flag tells Docker to delete the container after it stops. The `--publish 4001:4001` flag tells Docker to forward the network traffic from the host port `4001` to the container port `4001`, so we can access the API.

You can now test the API again using the `api.http` file just like before, to check that everything works as expected.

Because we might need to run these commands often, we can add them to the scripts section of the `packages/settings/api/package.json` file:

```json
{
  "scripts": {
    "test": "tap \"test/**/*.test.js\"",
    "start": "fastify start -l info app.js -a 0.0.0.0 -p 4001",
    "dev": "fastify start -w -l info -P app.js -p 4001",
    "docker:build": "docker build --tag settings-api --file ./Dockerfile ../..",
    "docker:run": "docker run --rm --publish 4001:4001 settings-api"
  },
}
```

This way we can use the `npm run docker:build` and `npm run docker:run` commands to build and run the image.

It can be a good idea to now commit the changes to the repository. Commits are cheap, so commit early and often!

---

<div class="info" data-title="skip notice">

> If you want to skip the Dice API implementation and jump directly to the next section, run this command in the terminal to get the completed code directly: `TODO`

</div>

## Dice API

We'll now take care of creating the Dice API, which will be responsible for rolling the dices and getting the results from the last rolls. It will provide two endpoints:

- `POST /rolls`: rolls a dice with the number of sides specified in the request body with the format `{ "sides": 6 }`, stores the result and returns it.
- `GET /rolls/history?max=<max_results>&sides=<number_of_sides>`: returns at most the last `<max_results>` rolls for dices with `<number_of_sides>` sides.

The result data we'll return will be in the following format for the first API:

```json
{
  "result": 4
}
```

And for the history API it will return an array instead:

```json
{
  "result": [2, 4, 6]
}
```

### Introducing NestJS

This time we'll use the [NestJS](https://nestjs.com/) framework to create our API. NestJS is a framework for building efficient, scalable Node.js server-side applications. It uses TypeScript natively, and provides a lot of built-in support for dependency injection, data validation, ORM integrations, multiple transports and more.

Under the hood, it's based on Express, but can also be configured to use Fastify for better performance. It also provides a CLI tool to generate new modules, controllers, services, etc, and to build and test the application easily.

### Creating the database service

Just like we did with the Settings API, we'll start by creating a database service to store the results of the rolls. For now we'll use an in-memory mock database, but we'll later connect a proper database to persist the data.

Open a new terminal and move to the `packages/dice-api` folder.

```bash
cd packages/dice-api
```

Then run the following command to create a new service called `db`:

```bash
npx nest generate service db --flat
```

The `npx` command allows us to run the `nest` CLI tool that is installed locally in the project. The `generate service` command tells the CLI to generate a new service, and the `--flat` flag allows to create the service in the `src` folder instead of creating a new folder for it.

You can see that it created a new file called `db.service.ts` in the `src` folder, along with its unit test file. It also configured `app.module.ts` to provide the new service, so we can use it later with the [dependency injection](https://docs.nestjs.com/providers#dependency-injection) system.

Now we'll complete the `db.service.ts` file to implement the database mock. First let's define the `Roll` interface to model how we'll store the results of the rolls. Add this after the imports:

```typescript
export interface Roll {
  sides: number;
  result: number;
  timestamp: number;
}
```

We need to store 3 things for each roll:
- The number of sides of the dice
- The result of the roll
- The timestamp of when the roll was made

We'll use the timestamp to sort the results by date for the history endpoint.

Let's complete the `DbService` class to implement the mock database:

```typescript
@Injectable()
export class DbService {
  private mockDb: Roll[] = [];

  async addRoll(roll: Roll) {
    await this.delay();
    this.mockDb.push(roll);
    this.mockDb.sort((a, b) => a.timestamp - b.timestamp);
  }
  
  async getLastRolls(max: number, sides: number) {
    await this.delay();
    return this.mockDb
      .filter((roll) => roll.sides === sides)
      .slice(-max);
  }

  private async delay() {
    return new Promise((resolve) => setTimeout(resolve, 10));
  }
}
```

For our mock database, we'll use a simple array to store the rolls. When adding new rolls, we'll make sure that the array is sorted by timestamp, so that we can easily get the last rolls, using the `sort()` method.

When getting the last rolls, we'll filter the array to only keep the rolls with the correct number of sides, and then slice the array to get the last `max` elements. The `slice()` method returns a new array, so we don't modify the original array. Note that the trick with the negative index is to get the last `max` elements, even if the array has less than `max` elements.

Finally, we'll add a small delay to simulate the time it takes to access the database, just like we did in the Settings API.

### Adding the POST route

The next step is to create the routes for the API. We'll start by creating the controller for the `/rolls` route. Run the following command to create a new controller called `rolls`:

```bash
npx nest generate controller rolls --flat
```

Just like with the database, it created a new file called `rolls.controller.ts` in the `src` folder, along with its unit test file, and configured `app.module.ts` to register the new controller.

Now we'll complete the `rolls.controller.ts` file to implement the routes. First we need to add a few imports and configure the logger:

```typescript
import {
  Body,
  Controller,
  Get,
  Post,
  Query,
  Logger,
  ParseIntPipe,
  DefaultValuePipe,
} from '@nestjs/common';
import { DbService } from './db.service';

@Controller('rolls')
export class RollsController {
  private readonly logger = new Logger(DbService.name);

  constructor(private readonly db: DbService) {}
}
```

We instanciate the logger with the name of the class, that's automatically set by NestJS thanks to the `@Controller()` decorator. We also inject the `DbService` service using the constructor: NestJS will automatically create an instance of the service and inject it in the controller using its type as a key.

Add the following code to the class to implement the `POST /rolls` route:

```typescript
  @Post()
  async rollDice(@Body('sides') sides: number) {
    this.logger.log(`Rolling dice [sides: ${sides}]}`);
    const result = Math.ceil(Math.random() * sides);
    await this.db.addRoll({
      sides: sides,
      timestamp: Date.now(),
      result,
    });
    return { result };
  }
```

NestJS makes use of decorators to configure the routes. The `@Post()` decorator indicates that this method will handle the `POST` method, and the `/rolls` route is specified in the `@Controller()` decorator. The `@Body('sides')` decorator tells NestJS to get the body of the request, find the `sides` property and pass it to the method as a parameter.

We then generate a random number between 1 and the number of sides of the dice, and store the result in the database. Finally, we return the result of the roll, and just like Fastify, NestJS will automatically convert the object to JSON and set the correct content type.

<div class="tip" data-title="tip">

> The `{ result }` syntax is a shorthand for `{ result: result }`, and is allowed in JavaScript since ES6.

</div>

### Adding data validation

We added the type `number` to specify the type of the expected property `sides` in the request body, but that's not enough to validate the data: we need to make sure that the property is defined and that its value is an integer.

For that we can use the built-in NestJS [Pipes](https://docs.nestjs.com/pipes). A pipe is a class that implements the `PipeTransform` interface, and has a `transform()` method that takes the value to transform as a parameter, and returns the transformed value. We can use pipes to transform the data, or to validate it.

Let's modify our method to use a pipe to validate the data:

```typescript
  @Post()
  async rollDice(@Body('sides', ParseIntPipe) sides: number) {
    // ...
  }
```

Here we added the `ParseIntPipe` to make sure that our `sides` parameter is an integer. If the value is not an integer (or not defined), NestJS will throw an error, and the request will fail with a 400 status code.

<div class="tip" data-title="tip">

> Built-in pipes provides parsing and validation for basic types, but for more complex scenarios you can use the `ValidationPipe` and define **Data Transfer Objects (DTO)**. You'll need to install use the [class-validator](https://github.com/typestack/class-validator) package for that. Read more about it in the [NestJS documentation](https://docs.nestjs.com/techniques/validation).

</div>

### Adding the GET route

We'll now add a second route to our controller, so we can retrieve the last rolls. Add the following code to the controller:

```typescript
  @Get('history')
  async getHistory(
    @Query('max', new DefaultValuePipe(10), ParseIntPipe) max: number,
    @Query('sides', new DefaultValuePipe(6), ParseIntPipe) sides: number
  ) {
    this.logger.log(`Retrieving last ${max} rolls history [sides: ${sides}]`);
    const rolls = await this.db.getLastRolls(max, sides);
    return { result: rolls.map((roll) => roll.result) };
  }
```

By adding the `'history'` route inside the `@Get()` decorator, we're making the route of this API `GET /rolls/history` as we defined `'rolls'` to be the route prefix for our controller. Just like we did using previously using the `@Body()` decorator, we can use the `@Query()` decorator to get the query parameters of the request and validate then. Since we want them to be optional this time, we added the `DefaultValuePipe` to set a default value if the parameter is not defined.

Finally, we retrieve the last rolls from the database, and return the result as an array of integers. We use the `map()` method to extract the `result` property from each roll.

### Testing our API

We finished implementing our API, so let's test it using the same method we used for the Settings API.

Start the server using `npm start | pino-pretty` and open the file `api.http` file. Go to the "Dice API" section and hit **Send Request** on the `POST /rolls` request. Check that the response is correct, and send a few requests to verify that the result is a random number between 1 and 6.

Then, hit **Send Request** on the `GET /rolls/history` request. Check that the response is an array containing the last results you got from the previous calls. You can also try to change the `max` and `sides` query parameters to see how the results change.

If everything works as expected, you can stop the server by pressing `Ctrl+C` in the terminal.

### Creating the Dockerfile

It's time to create the Dockerfile for our Dice API. Unlike the Settings API, our Dice API have a **build** step to compile the TypeScript code to JavaScript.

We'll use the [multi-stage build](https://docs.docker.com/develop/develop-images/multistage-build/) feature of Docker to build our API and create a smaller container image, while keeping our Dockerfile readable and maintainable.

 Create a new file named `Dockerfile` in the `dice-api` folder, with the following content:

```dockerfile
# syntax=docker/dockerfile:1

# Build Node.js app
# ------------------------------------
FROM node:18-alpine as build
WORKDIR /app
COPY ./package*.json ./
COPY ./packages/dice-api ./packages/dice-api
RUN npm ci --workspace=dice-api --cache /tmp/empty-cache
RUN npm run build --workspace=dice-api
```

For this first stage, we use amost the same setup as before. The first difference is that we define a name for this stage, using the `as` keyword. We'll use this name later to copy the compiled code from this stage to the next one.

The second difference is that instead of running the `start` script using the `CMD` instruction, we run the `build` script. This will compile the TypeScript code to JavaScript, and put the compiled code in the `dist` folder.

Now we can create the second stage of our Dockerfile, that will be used to create the final Docker image. Add the following code after the first stage:

```dockerfile
# Run Node.js app
# ------------------------------------
FROM node:18-alpine
ENV NODE_ENV=production

WORKDIR /app
COPY ./package*.json ./
COPY ./packages/dice-api/package.json ./packages/dice-api/
RUN npm ci --omit=dev --workspace=dice-api --cache /tmp/empty-cache
COPY --from=build app/packages/dice-api/dist packages/dice-api/dist
EXPOSE 4002
CMD [ "node", "packages/dice-api/dist/main" ]
```

This stage is very similar to the first one, with few differences:
- We're not copying the whole `packages/dice-api` folder this time, but only the `package.json` file. We need this file to install the dependencies, but we don't need to copy the source code.
- We're using the `--omit=dev` option of the `npm ci` command to only install the production dependencies, as we don't need the development dependencies in our final Docker image.
- We're copying the compiled code from the first stage using the `--from=build` option of the `COPY` instruction. This will copy the compiled code from the `build` stage to our final Docker image.

Finally we tell Docker to expose port 4002, and run compiled `main.js` file when the container starts just like we did for the Settings API.

With this setup, Docker will first create a container to build our app, and then create a second container where we copy the compiled app code from the first container to create the final Docker image.

As previously, you also need to create a `.dockerignore` file to tell Docker which files to ignore when copying files to the image:

```text
node_modules
*.log
```

### Testing our Docker image

You can now build the Docker image and run it locally to test it. First, let's 
add the commands to build and run the Docker image to our `package.json` file:

```json
{
  "scripts": {
    // ...
    "docker:build": "docker build --tag dice-api --file ./Dockerfile ../..",
    "docker:run": "docker run --rm --publish 4002:4002 dice-api"
  },
}
```

Now we can build the image by running this command from the `dice-api` folder:

```bash
npm run docker:build
```

After the build is complete, you can run the image with the following command:

```bash
npm run docker:run | pino-pretty
```

You can now test the API again using the `api.http` file just like before, to check that everything works as expected.

After you checked that everything works as expected, commit the changes to the repository to keep track of your progress.

---

## Gateway API

Our third service is the Gateway API. This API will make use of the two services we built previously to provide a public backend for our client website.

The Gateway API goal is to provide data endpoints tailored for the website, and will require user authentication. Because of that, the routes will a bit be different from the ones we used in the previous services:
- `GET /settings`: returns the current settings for the authenticated user.
- `PUT /settings`: updates the settings for the authenticated user.
- `POST /rolls`: rolls N dices using the settings for the authenticated user, and returns the results. The number of dices to roll is specified in the request body with the format `{ "count": 100 }`.
- `GET /rolls/history?max=<max_results>`: returns at most the last `<max_results>` rolls for the authenticated user, using its saved settings.

### Introducing Express

Does [Express](https://expressjs.com) really need an introduction? It's one of the most popular Node.js web frameworks, used by many applications in production. It's minimalistic, flexible, and benefits from a large ecosystem of plugins and a huge active developer community.

While it doesn't provide a lot of features out of the box compared to more modern frameworks like [NestJS](https://nestjs.com) or [Fastify](https://www.fastify.io), it's still a great choice for building services especially if your want something unopinionated that you can easily customize to your needs.

### Creating the authentication middleware






- need auth header with user_id (from SWA) => middleware
- PUT /settings/
- GET /settings/
- POST /rolls { count: 100 } => get settings + N calls to Dice API
  => { result: 4, duration: XX (in ms) }
- GET  /rolls/history?count=50 => get settings + call to Dice API
  => { result: [2, 4, 6] }
- test with REST client/curl
- Dockerfile

### Creating the proxy service
### Adding the routes
### Testing our API
### Creating the Dockerfile
### Testing our Docker image

---

## Using Docker compose
- Docker compose to run all yml


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
