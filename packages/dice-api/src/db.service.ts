import { Injectable } from '@nestjs/common';
import { Container, CosmosClient } from '@azure/cosmos';

export interface Roll {
  sides: number;
  result: number;
  timestamp: number;
}

@Injectable()
export class MockDbService {
  private mockDb: Roll[] = [];

  async addRoll(roll: Roll) {
    await this.delay();
    this.mockDb.push(roll);
    this.mockDb.sort((a, b) => a.timestamp - b.timestamp);
  }

  async getLastRolls(max: number, sides: number) {
    await this.delay();
    return this.mockDb.filter((roll) => roll.sides === sides).slice(-max);
  }

  private async delay() {
    return new Promise((resolve) => setTimeout(resolve, 10));
  }
}

@Injectable()
export class DbService {
  client: CosmosClient;
  rolls: Container;

  constructor(connectionString: string) {
    this.client = new CosmosClient(connectionString);
  }

  async init() {
    const { database } = await this.client.databases.createIfNotExists({
      id: 'dice-db',
    });
    const { container } = await database.containers.createIfNotExists({
      id: 'rolls',
    });
    this.rolls = container;
  }

  async addRoll(roll: Roll) {
    await this.rolls.items.create(roll);
  }

  async getLastRolls(max: number, sides: number) {
    const { resources } = await this.rolls.items
      .query({
        query: `SELECT TOP @max * from r WHERE r.sides = @sides ORDER BY r.timestamp DESC`,
        parameters: [
          { name: '@sides', value: sides },
          { name: '@max', value: max },
        ],
      })
      .fetchAll();
    return (resources as Roll[]).sort((a, b) => a.timestamp - b.timestamp);
  }
}
