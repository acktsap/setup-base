#!/usr/bin/env python3

import argparse
import os
import random

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
            print(f"Pass {i + 1}/{passes} completed.")

        print(f"{file_path} has been completely corrupted and is unrecoverable.")

    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Completely corrupt any file to make it unrecoverable.")
    parser.add_argument('file', type=str, help="Path to the file to corrupt.")

    args = parser.parse_args()

    confirmation = input(f"Are you sure you want to completely destroy the file '{args.file}'? This cannot be undone. (yes/no): ")

    if confirmation.lower() == 'yes':
        completely_corrupt_file(args.file)
    else:
        print("Operation cancelled.")
