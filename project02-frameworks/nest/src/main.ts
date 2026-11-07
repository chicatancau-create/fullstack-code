import 'reflect-metadata';
import { ArgumentsHost, Catch, ExceptionFilter, HttpException, ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

@Catch()
class ContractFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    const response = host.switchToHttp().getResponse();
    const status = exception instanceof HttpException ? exception.getStatus() : 500;
    const error = status === 400 ? 'invalid' : status === 404 ? 'not_found' : 'internal_error';
    response.status(status).json({ error });
  }
}

export async function createNestApp() {
  const app = await NestFactory.create(AppModule, { logger: false });
  app.use((request: any, response: any, next: () => void) => {
    response.setHeader('X-Content-Type-Options', 'nosniff');
    next();
  });
  app.useGlobalPipes(new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true, transform: true }));
  app.useGlobalFilters(new ContractFilter());
  await app.init();
  return app;
}

if (require.main === module) {
  createNestApp().then(async (app) => {
    await app.listen(Number(process.env.PORT || 8799), '127.0.0.1');
    console.log('nest listening on 8799');
  });
}
