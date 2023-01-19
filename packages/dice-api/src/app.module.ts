import { Module, Logger } from '@nestjs/common';
import { LoggerModule } from 'nestjs-pino';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { DbService, MockDbService } from './db.service';
import { RollsController } from './rolls.controller';

@Module({
  imports: [LoggerModule.forRoot()],
  controllers: [AppController, RollsController],
  providers: [
    AppService,
    {
      provide: DbService,
      useFactory: async () => {
        const logger = new Logger(DbService.name);
        const connectionString = process.env.DATABASE_CONNECTION_STRING;
        if (connectionString) {
          const db = new DbService(connectionString);
          await db.init();
          logger.log('Connection to database successful.');
          return db;
        }
        logger.warn('No DB connection string provided, using mock database.');
        return new MockDbService();
      },
    },
  ],
})
export class AppModule {}
