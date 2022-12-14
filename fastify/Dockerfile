# syntax=docker/dockerfile:1

# Run Node.js app
# ------------------------------------
FROM node:18-alpine
ENV NODE_ENV=production

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production --cache /tmp/empty-cache
COPY . ./
EXPOSE 4001
CMD [ "npm", "start" ]