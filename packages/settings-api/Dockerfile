# syntax=docker/dockerfile:1

# Run Node.js app
# ------------------------------------
FROM node:20-alpine
ENV NODE_ENV=production

WORKDIR /app
COPY ./package*.json ./
COPY ./packages/settings-api ./packages/settings-api
RUN npm ci --omit=dev --workspace=settings-api --cache /tmp/empty-cache
EXPOSE 4001
CMD [ "npm", "start", "--workspace=settings-api" ]
