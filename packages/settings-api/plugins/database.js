import fp from 'fastify-plugin'
import { CosmosClient } from '@azure/cosmos';

// the use of fastify-plugin is required to be able
// to export the decorators to the outer scope

export default fp(async function (fastify, opts) {
  const connectionString = process.env.DATABASE_CONNECTION_STRING;
  if (connectionString) {
    const db = new Database(connectionString);
    await db.init();
    fastify.decorate('db', db);
    fastify.log.info('Connection to database successful.');
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
    this.client = new CosmosClient(connectionString)
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
    await this.settings.items.upsert({ id: userId, settings });
  }
  
  async getSettings(userId) {
    const { resource } = await this.settings.item(userId).read();
    return resource?.settings;
  }
}
