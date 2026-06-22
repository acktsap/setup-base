#!/usr/bin/env python3

import argparse
import os
import random
import sys

def completely_corrupt_file(file_path, passes=3):
    try:
        file_size = os.path.getsize(file_path)

        # Overwrite multiple times with random data
        for i in range(passes):
            with open(file_path, 'r+b') as file:
                file.seek(0)
                file.write(bytearray(random.getrandbits(8) for _ in range(file_size)))
                file.flush()
                os.fsync(file.fileno())
            print(f"{file_path}: pass {i + 1}/{passes} completed.")

        print(f"{file_path} has been completely corrupted and is unrecoverable.")
        return True

    except Exception as e:
        print(f"{file_path}: an error occurred: {e}", file=sys.stderr)
        return False

def collect_stdin_files():
    if sys.stdin.isatty():
        return []

    return [line.rstrip('\n') for line in sys.stdin if line.rstrip('\n')]

def read_confirmation_from_tty(prompt):
    try:
        with open('/dev/tty', 'r+') as tty:
            tty.write(prompt)
            tty.flush()
            return tty.readline()
    except OSError:
        print("Confirmation requires a terminal. Rerun with --yes to skip the prompt.", file=sys.stderr)
        return None

def prompt_confirmation(files, assume_yes, read_from_stdin=True):
    if assume_yes:
        return True

    if len(files) == 1:
        prompt = f"Are you sure you want to completely destroy the file '{files[0]}'? This cannot be undone. (yes/no): "
    else:
        file_list = "\n".join(f"  - {file_path}" for file_path in files)
        prompt = f"Are you sure you want to completely destroy these {len(files)} files?\n{file_list}\nThis cannot be undone. (yes/no): "

    if read_from_stdin:
        if sys.stdin.isatty():
            try:
                response = input(prompt)
            except EOFError:
                response = None
        else:
            response = sys.stdin.readline()
        if response == '':
            response = read_confirmation_from_tty(prompt)
    else:
        response = read_confirmation_from_tty(prompt)

    if response is None:
        return False

    return response.strip().lower() == 'yes'

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Completely corrupt any file to make it unrecoverable.")
    parser.add_argument('files', nargs='*', help="Path(s) to the file(s) to corrupt.")
    parser.add_argument('-y', '--yes', action='store_true', help="Skip the confirmation prompt.")
    parser.add_argument('-p', '--passes', type=int, default=3, help="Number of overwrite passes. Default: 3.")

    args = parser.parse_args()
    read_confirmation_from_stdin = bool(args.files)
    files = args.files if args.files else collect_stdin_files()

    if not files:
        parser.error("at least one file path is required")

    if args.passes < 1:
        parser.error("--passes must be at least 1")

    if prompt_confirmation(files, args.yes, read_confirmation_from_stdin):
        results = [completely_corrupt_file(file_path, args.passes) for file_path in files]
        success = all(results)
        sys.exit(0 if success else 1)
    else:
        print("Operation cancelled.")
        sys.exit(1)
