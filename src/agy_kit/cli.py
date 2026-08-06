"""
cli.py — agy-kit Python CLI entrypoint
"""

import sys
import argparse

def main():
    parser = argparse.ArgumentParser(description="agy-kit Agent Harness CLI")
    parser.add_argument("--version", action="store_true", help="Print agy-kit version")
    args = parser.parse_args()

    if args.version:
        from agy_kit import __version__
        print(f"agy-kit v{__version__}")
        sys.exit(0)

    parser.print_help()

if __name__ == "__main__":
    main()
