import { Body, Controller, Get, Post, Query, Logger } from '@nestjs/common';
import { DbService } from './db.service';

@Controller('rolls')
export class RollsController {
  private readonly logger = new Logger(DbService.name);

  constructor(private readonly db: DbService) {}

  @Post()
  async rollDice(@Body() body: { sides: number }) {
    this.logger.log(`Rolling dice [${body.sides}]}`);
    const result = Math.ceil(Math.random() * body.sides);
    await this.db.addRoll({
      sides: body.sides,
      timestamp: Date.now(),
      result,
    });
    return { result };
  }

  @Get('history')
  async getHistory(@Query() query) {
    const max = query.max ? Number(query.max) : 10;
    const sides = query.sides ? Number(query.sides) : 6;
    this.logger.log(`Retrieving last ${max} rolls history`);
    const rolls = await this.db.getLastRolls(max, sides);
    return { result: rolls.map((roll) => roll.result) };
  }
}
