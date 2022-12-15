import { Module } from '@nestjs/common';
import { LoggerModule } from 'nestjs-pino';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { DbService } from './db.service';
import { RollsController } from './rolls.controller';

@Module({
  imports: [LoggerModule.forRoot()],
  controllers: [AppController, RollsController],
  providers: [AppService, DbService],
})
export class AppModule {}
