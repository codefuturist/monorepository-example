"""Main entry point for package-c executable."""

import sys
from decimal import Decimal

try:
    from tabulate import tabulate
except ImportError as e:
    print(f"ERROR: Required dependency 'tabulate' not found: {e}", file=sys.stderr)
    print("Please install with: pip install tabulate>=0.9.0", file=sys.stderr)
    sys.exit(1)

from package_c.math_helpers import divide_precise, percentage


def main():
    """Main function for package-c CLI."""
    print("=" * 60)
    print("Package C - Math Helpers v1.0.0")
    print("=" * 60)

    try:
        print("\n✓ Tabulate dependency loaded successfully")
        print("✓ Math helpers initialized\n")

        # Test cases for demonstration
        test_data = []

        # Division tests
        divisions = [
            (100, 3, 4),
            (22, 7, 6),
            (1, 3, 10),
        ]

        print("Precise Division Results:")
        print("-" * 60)
        for a, b, precision in divisions:
            result = divide_precise(a, b, precision)
            test_data.append([f"{a} ÷ {b}", f"{precision} decimals", str(result)])

        print(tabulate(test_data, headers=["Operation", "Precision", "Result"], tablefmt="grid"))

        # Percentage tests
        pct_data = []
        percentages = [
            (25, 100),
            (3, 4),
            (1, 3),
        ]

        print("\n\nPercentage Calculations:")
        print("-" * 60)
        for part, whole in percentages:
            result = percentage(part, whole)
            pct_data.append([f"{part}/{whole}", f"{result}%"])

        print(tabulate(pct_data, headers=["Fraction", "Percentage"], tablefmt="grid"))

        print("\n" + "=" * 60)
        print("Package C executed successfully!")
        print("=" * 60 + "\n")

    except ZeroDivisionError as e:
        print(f"ERROR: Division by zero - {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
