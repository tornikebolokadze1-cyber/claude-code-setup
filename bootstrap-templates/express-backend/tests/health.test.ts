import request from 'supertest';
import { createApp } from '../src/index';
import type { ApiResponse, HealthResponse } from '../src/types';

describe('GET /health', () => {
  const app = createApp();

  it('should return 200 with status ok', async () => {
    const res = await request(app).get('/health');

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);

    const data = res.body as ApiResponse<HealthResponse>;
    expect(data.data).toBeDefined();
    expect(data.data!.status).toBe('ok');
  });

  it('should include a valid ISO timestamp', async () => {
    const res = await request(app).get('/health');
    const data = res.body as ApiResponse<HealthResponse>;

    const timestamp = data.data!.timestamp;
    expect(timestamp).toBeDefined();
    expect(new Date(timestamp).toISOString()).toBe(timestamp);
  });

  it('should include uptime as a non-negative number', async () => {
    const res = await request(app).get('/health');
    const data = res.body as ApiResponse<HealthResponse>;

    expect(typeof data.data!.uptime).toBe('number');
    expect(data.data!.uptime).toBeGreaterThanOrEqual(0);
  });

  it('should include environment string', async () => {
    const res = await request(app).get('/health');
    const data = res.body as ApiResponse<HealthResponse>;

    expect(typeof data.data!.environment).toBe('string');
    expect(data.data!.environment.length).toBeGreaterThan(0);
  });

  it('should include meta.timestamp in the envelope', async () => {
    const res = await request(app).get('/health');
    expect(res.body.meta).toBeDefined();
    expect(res.body.meta.timestamp).toBeDefined();
  });
});

describe('404 handling', () => {
  const app = createApp();

  it('should return 404 for unknown routes', async () => {
    const res = await request(app).get('/nonexistent');

    expect(res.status).toBe(404);
    expect(res.body.success).toBe(false);
    expect(res.body.error.code).toBe('NOT_FOUND');
  });
});
