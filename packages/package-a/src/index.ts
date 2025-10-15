/**
 * Package A - Core functionality
 */

export function greet(name: string): string {
  return `Hello, ${name} from Package A!`;
}

export const version = '1.0.0';

// Export logger functionality
export { Logger, LogLevel, createLogger } from './logger';
