import { Test, TestingModule } from '@nestjs/testing';
import { RollsController } from './rolls.controller';
import { DbService, MockDbService } from './db.service';

describe('RollsController', () => {
  let controller: RollsController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [RollsController],
      providers: [
        {
          provide: DbService,
          useValue: new MockDbService(),
        },
      ],
    }).compile();

    controller = module.get<RollsController>(RollsController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
