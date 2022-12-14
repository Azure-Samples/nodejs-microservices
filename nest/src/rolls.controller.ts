import { Body, Controller, Get, Post, Query } from '@nestjs/common';
import { Logger } from 'nestjs-pino';
import { DbService } from './db.service';

@Controller('rolls')
export class RollsController {
  constructor(private readonly logger: Logger, private db: DbService) {}

  @Post()
  async rollDice(@Body() body: { diceFaces: number }) {
    this.logger.log(`Rolling dice [${body.diceFaces}]}`);
    const result = Math.ceil(Math.random() * body.diceFaces);
    await this.db.addRoll({
      diceFaces: body.diceFaces,
      timestamp: Date.now(),
      result,
    });
    return { result };
  }

  @Get('history')
  async getHistory(@Query() query) {
    const max = query.max ? Number(query.max) : 10;
    const diceFaces = query.diceFaces ? Number(query.diceFaces) : 6;
    this.logger.log(`Retrieving last ${max} rolls history`);
    const rolls = await this.db.getLastRolls(max, diceFaces);
    return { result: rolls.map((roll) => roll.result) };
  }
}
