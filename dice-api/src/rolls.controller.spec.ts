import { Test, TestingModule } from '@nestjs/testing';
import { RollsController } from './rolls.controller';

describe('RollsController', () => {
  let controller: RollsController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [RollsController],
    }).compile();

    controller = module.get<RollsController>(RollsController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
