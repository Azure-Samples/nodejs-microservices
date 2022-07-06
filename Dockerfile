# syntax=docker/dockerfile:1
FROM node:16
ENV NODE_ENV=production

WORKDIR /app
COPY package*.json .
RUN npm ci --only=production --cache /tmp/empty-cache
COPY dist dist
EXPOSE 3000
CMD [ "node", "dist/main" ]