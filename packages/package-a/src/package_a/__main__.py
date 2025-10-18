"""Main entry point for package-a executable."""
import sys
from pathlib import Path

try:
    from colorama import Fore, Style, init
except ImportError as e:
    print(f"ERROR: Required dependency 'colorama' not found: {e}", file=sys.stderr)
    print("Please install with: pip install colorama>=0.4.6", file=sys.stderr)
    sys.exit(1)

from package_a.logger import setup_logger


def main():
    """Main function for package-a CLI."""
    # Initialize colorama
    init(autoreset=True)
    
    # Display header
    print(f"{Fore.CYAN}{'='*60}")
    print(f"{Fore.CYAN}Package A - Logger Utilities v1.2.0")
    print(f"{Fore.CYAN}{'='*60}{Style.RESET_ALL}")
    
    # Test logger functionality
    try:
        import logging
        logger = setup_logger("demo", level=logging.INFO)
        
        print(f"\n{Fore.GREEN}✓ Colorama dependency loaded successfully")
        print(f"{Fore.GREEN}✓ Logger initialized successfully{Style.RESET_ALL}\n")
        
        logger.info("Logger is working correctly!")
        logger.warning("This is a warning message")
        logger.error("This is an error message (expected)")
        
        print(f"\n{Fore.YELLOW}Logger output test completed!")
        print(f"{Fore.CYAN}Log file created at: {Path.cwd() / 'demo.log'}{Style.RESET_ALL}")
        
        print(f"\n{Fore.GREEN}{'='*60}")
        print(f"{Fore.GREEN}Package A executed successfully!{Style.RESET_ALL}")
        print(f"{Fore.GREEN}{'='*60}\n")
        
    except Exception as e:
        print(f"{Fore.RED}ERROR: {e}{Style.RESET_ALL}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
