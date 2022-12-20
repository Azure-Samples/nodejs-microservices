'use strict'

const fp = require('fastify-plugin')
const { CosmosClient } = require("@azure/cosmos");

// the use of fastify-plugin is required to be able
// to export the decorators to the outer scope

module.exports = fp(async function (fastify, opts) {
  const connectionString = process.env.COSMOS_CONNECTION_STRING;
  if (1 || connectionString) {
    const db = new Database({ endpoint: 'https://azcheckin-db-kxevz2kwuvkbi.documents.azure.com:443/', key: 'tjSR9tob3Xaq8JeOnAqz2vjFcGr8NLmzKbye3PC08cSe3KNhQUNPMPSUiroPADjVUuxp3XQ0BIdY3ftXm7vUbw==' });
    await db.init();
    fastify.decorate('db', db);
  } else {
    fastify.decorate('db', new MockDatabase());
    fastify.log.warn('No DB connection string provided, using mock database.');
  }
});

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

class Database {
  constructor(connectionString) {
    this.client = new CosmosClient({ ...connectionString })
  }

  async init() {
    const { database } = await this.client.databases.createIfNotExists({
      id: 'settings-db'
    });
    const { container } = await database.containers.createIfNotExists({
      id: 'settings'
    });
    this.settings = container;
  }

  async saveSettings(userId, settings) {
    this.settings.items.upsert({ id: userId, settings });
  }
  
  async getSettings(userId) {
    const { resource } = await this.settings.item(userId).read();
    return resource?.settings;
  }
}
