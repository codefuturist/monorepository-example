/**
 * Package C - Helpers
 */

export function add(a: number, b: number): number {
  return a + b;
}

export function multiply(a: number, b: number): number {
  return a * b;
}

/**
 * Divide two numbers with precision handling
 * @param a - Dividend
 * @param b - Divisor
 * @param precision - Number of decimal places (default: 2)
 * @returns Result rounded to specified precision
 * @throws Error if divisor is zero
 */
export function divide(a: number, b: number, precision: number = 2): number {
  if (b === 0) {
    throw new Error('Division by zero is not allowed');
  }
  const result = a / b;
  return Number(result.toFixed(precision));
}

/**
 * Calculate percentage
 */
export function percentage(value: number, total: number): number {
  if (total === 0) return 0;
  return Number(((value / total) * 100).toFixed(2));
}

export const version = '1.0.0';
