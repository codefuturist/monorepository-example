"""Main entry point for package-b executable."""

import sys

try:
    from rich.console import Console
    from rich.table import Table
    from rich.panel import Panel
except ImportError as e:
    print(f"ERROR: Required dependency 'rich' not found: {e}", file=sys.stderr)
    print("Please install with: pip install rich>=13.0.0", file=sys.stderr)
    sys.exit(1)

from package_b.strings import truncate, kebab_case


def main():
    """Main function for package-b CLI."""
    console = Console()

    # Display header
    console.print(
        Panel.fit("[bold cyan]Package B - String Utilities v1.0.0[/bold cyan]", border_style="cyan")
    )

    try:
        # Test string utilities
        test_cases = [
            ("Hello World From Package B", 15),
            ("This is a very long string that needs truncation", 20),
            ("Short", 50),
        ]

        console.print("\n[green]✓ Rich dependency loaded successfully[/green]")
        console.print("[green]✓ String utilities initialized[/green]\n")

        # Create results table
        table = Table(title="String Utility Demonstrations", border_style="blue")
        table.add_column("Original", style="yellow")
        table.add_column("Truncated", style="cyan")
        table.add_column("Kebab Case", style="magenta")

        for text, max_len in test_cases:
            truncated = truncate(text, max_len)
            kebab = kebab_case(text)
            table.add_row(text, truncated, kebab)

        console.print(table)

        console.print("\n[bold green]" + "=" * 60 + "[/bold green]")
        console.print("[bold green]Package B executed successfully![/bold green]")
        console.print("[bold green]" + "=" * 60 + "[/bold green]\n")

    except Exception as e:
        console.print(f"[bold red]ERROR: {e}[/bold red]")
        sys.exit(1)


if __name__ == "__main__":
    main()
