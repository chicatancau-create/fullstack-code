import 'reflect-metadata';
import { Body, Controller, Get, HttpCode, HttpStatus, Module, Post } from '@nestjs/common';
import { IsNotEmpty, IsString, MaxLength } from 'class-validator';

export class EchoDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(50)
  text!: string;
}

@Controller()
export class AppController {
  @Get('health')
  health() {
    return { status: 'ok' };
  }

  @Post('echo')
  @HttpCode(HttpStatus.OK)
  echo(@Body() body: EchoDto) {
    return { text: body.text };
  }

  @Get('boom')
  boom() {
    throw new Error('sync boom');
  }

  @Get('async-boom')
  async asyncBoom() {
    throw new Error('async boom');
  }
}

@Module({ controllers: [AppController] })
export class AppModule {}
