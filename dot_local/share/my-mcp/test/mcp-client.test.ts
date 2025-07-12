import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { spawn, ChildProcess } from 'child_process';
import { promisify } from 'util';
import { exec } from 'child_process';

const execAsync = promisify(exec);

describe('MCP Server with Inspector', () => {
  let serverProcess: ChildProcess;

  beforeAll(async () => {
    await execAsync('npm run build');

    serverProcess = spawn('node', ['dist/index.js'], {
      stdio: ['pipe', 'pipe', 'pipe'],
    });

    await new Promise((resolve) => setTimeout(resolve, 1000));
  }, 15000);

  afterAll(() => {
    if (serverProcess) {
      serverProcess.kill('SIGTERM');
    }
  });

  it('should start server without errors', () => {
    expect(serverProcess.pid).toBeDefined();
    expect(serverProcess.killed).toBe(false);
  });

  it('should respond to basic JSON-RPC request', async () => {
    const request = {
      jsonrpc: '2.0',
      id: 1,
      method: 'tools/list',
      params: {},
    };

    const response = await new Promise((resolve, reject) => {
      let responseData = '';

      const timeout = setTimeout(() => {
        reject(new Error('Request timeout'));
      }, 5000);

      serverProcess.stdout?.on('data', (data) => {
        responseData += data.toString();
        try {
          const parsed = JSON.parse(responseData);
          clearTimeout(timeout);
          resolve(parsed);
        } catch {
          // Continue reading if JSON is incomplete
        }
      });

      serverProcess.stdin?.write(JSON.stringify(request) + '\n');
    });

    expect(response).toHaveProperty('result');
    expect(
      (response as { result: { tools: Array<{ name: string }> } }).result.tools
    ).toHaveLength(1);
    expect(
      (response as { result: { tools: Array<{ name: string }> } }).result
        .tools[0].name
    ).toBe('echo');
  });

  it('should handle echo tool call', async () => {
    const request = {
      jsonrpc: '2.0',
      id: 2,
      method: 'tools/call',
      params: {
        name: 'echo',
        arguments: { text: 'Test message' },
      },
    };

    const response = await new Promise((resolve, reject) => {
      let responseData = '';

      const timeout = setTimeout(() => {
        reject(new Error('Request timeout'));
      }, 5000);

      serverProcess.stdout?.on('data', (data) => {
        responseData += data.toString();
        try {
          const parsed = JSON.parse(responseData);
          clearTimeout(timeout);
          resolve(parsed);
        } catch {
          // Continue reading if JSON is incomplete
        }
      });

      serverProcess.stdin?.write(JSON.stringify(request) + '\n');
    });

    expect(response).toHaveProperty('result');
    expect(
      (response as { result: { content: Array<{ text: string }> } }).result
        .content
    ).toHaveLength(1);
    expect(
      (response as { result: { content: Array<{ text: string }> } }).result
        .content[0].text
    ).toBe('Echo: Test message');
  });
});
