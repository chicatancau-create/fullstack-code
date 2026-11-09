import express from 'express';

const MAX_TEXT = 50;

export function createExpressApp() {
  const app = express();
  app.disable('x-powered-by');
  app.use(express.json({ limit: '16kb' }));
  app.use((request, response, next) => {
    response.setHeader('X-Content-Type-Options', 'nosniff');
    next();
  });

  app.get('/health', (request, response) => {
    response.json({ status: 'ok' });
  });

  app.post('/echo', (request, response, next) => {
    const body = request.body;
    const keys = body && typeof body === 'object' && !Array.isArray(body) ? Object.keys(body) : [];
    if (!body || typeof body.text !== 'string' || body.text.length === 0 || body.text.length > MAX_TEXT || keys.length !== 1) {
      const error = new Error('invalid');
      error.status = 400;
      return next(error);
    }
    response.json({ text: body.text });
  });

  app.get('/boom', () => {
    throw new Error('sync boom');
  });

  app.get('/async-boom', async () => {
    throw new Error('async boom');
  });

  app.use((request, response) => {
    response.status(404).json({ error: 'not_found' });
  });

  app.use((error, request, response, next) => {
    const status = Number(error.status) || 500;
    const code = status === 400 ? 'invalid' : status === 404 ? 'not_found' : 'internal_error';
    response.status(status).json({ error: code });
  });

  return app;
}
