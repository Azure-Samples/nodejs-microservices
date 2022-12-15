# syntax=docker/dockerfile:1

# Run Node.js app
# ------------------------------------
FROM node:18
ENV NODE_ENV=production

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production --cache /tmp/empty-cache
COPY . ./
EXPOSE 3000
CMD [ "node", "./bin/www" ]