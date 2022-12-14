import { Injectable } from '@nestjs/common';

export interface Roll {
  diceFaces: number;
  result: number;
  timestamp: number;
}

@Injectable()
export class DbService {
  private mockDb: Roll[] = [];

  async getLastRolls(max: number, diceFaces: number) {
    await this.delay();
    return this.mockDb
      .filter((roll) => roll.diceFaces === diceFaces)
      .slice(-max);
  }

  async addRoll(roll: Roll) {
    await this.delay();
    this.mockDb.push(roll);
    this.mockDb.sort((a, b) => a.timestamp - b.timestamp);
  }

  private async delay() {
    return new Promise((resolve) => setTimeout(resolve, 10));
  }
}
