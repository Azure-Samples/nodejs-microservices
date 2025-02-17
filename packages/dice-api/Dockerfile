# syntax=docker/dockerfile:1

# Build Node.js app
# ------------------------------------
FROM node:20-alpine as build
WORKDIR /app
COPY ./package*.json ./
COPY ./packages/dice-api ./packages/dice-api
RUN npm ci --workspace=dice-api --cache /tmp/empty-cache
RUN npm run build --workspace=dice-api

# Run Node.js app
# ------------------------------------
FROM node:20-alpine
ENV NODE_ENV=production

WORKDIR /app
COPY ./package*.json ./
COPY ./packages/dice-api/package.json ./packages/dice-api/
RUN npm ci --omit=dev --workspace=dice-api --cache /tmp/empty-cache
COPY --from=build app/packages/dice-api/dist packages/dice-api/dist
EXPOSE 4002
CMD [ "npm", "run", "start:prod", "--workspace=dice-api" ]
