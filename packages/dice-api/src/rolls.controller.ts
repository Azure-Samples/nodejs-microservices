import {
  Body,
  Controller,
  Get,
  Post,
  Query,
  Logger,
  ParseIntPipe,
  DefaultValuePipe,
} from '@nestjs/common';
import { DbService } from './db.service';

@Controller('rolls')
export class RollsController {
  private readonly logger = new Logger(RollsController.name);

  constructor(private readonly db: DbService) {}

  @Post()
  async rollDice(@Body('sides', ParseIntPipe) sides: number) {
    this.logger.log(`Rolling dice [sides: ${sides}]`);
    const result = Math.ceil(Math.random() * sides);
    await this.db.addRoll({
      sides: sides,
      timestamp: Date.now(),
      result,
    });
    return { result };
  }

  @Get('history')
  async getRollsHistory(
    @Query('max', new DefaultValuePipe(10), ParseIntPipe) max: number,
    @Query('sides', new DefaultValuePipe(6), ParseIntPipe) sides: number,
  ) {
    this.logger.log(`Retrieving last ${max} rolls history [sides: ${sides}]`);
    const rolls = await this.db.getLastRolls(max, sides);
    return { result: rolls.map((roll) => roll.result) };
  }
}
