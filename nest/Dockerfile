# syntax=docker/dockerfile:1

# Build Node.js app
# ------------------------------------
FROM node:18 as build
WORKDIR /app
COPY package*.json ./
RUN npm ci --cache /tmp/empty-cache
COPY . ./
RUN npm run build

# Run Node.js app
# ------------------------------------
FROM node:18
ENV NODE_ENV=production

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production --cache /tmp/empty-cache
COPY --from=build app/dist dist
EXPOSE 3000
CMD [ "node", "dist/main" ]