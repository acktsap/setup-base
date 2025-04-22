#!/usr/bin/env python3

import argparse
import os
import random

def completely_corrupt_file(file_path):
    try:
        # Read the original file
        with open(file_path, 'rb') as file:
            data = file.read()

        # Replace every byte with random garbage
        corrupted_data = bytearray(random.getrandbits(8) for _ in range(len(data)))

        # Optionally truncate the file to simulate total destruction
        if random.choice([True, False]):
            corrupted_data = bytearray()

        # Overwrite the original file
        with open(file_path, 'wb') as file:
            file.write(corrupted_data)

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
