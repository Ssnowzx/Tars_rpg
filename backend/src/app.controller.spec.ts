import { Test, TestingModule } from '@nestjs/testing';
import { AppController } from './app.controller';
import { AppService } from './app.service';

describe('AppController', () => {
  let appController: AppController;

  beforeEach(async () => {
    const app: TestingModule = await Test.createTestingModule({
      controllers: [AppController],
      providers: [AppService],
    }).compile();

    appController = app.get<AppController>(AppController);
  });

  describe('root', () => {
    it('deve retornar o nome e a versão da API', () => {
      const info = appController.getInfo();
      expect(info.name).toBe('Fertways API');
      expect(info.version).toBeDefined();
    });
  });
});
