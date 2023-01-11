#!/bin/python3

import argparse
import json
import os
import random
import subprocess
import sys
import urllib.request
from itertools import groupby


def main():
    parser = argparse.ArgumentParser(description="Generate random GPS coordinates and write them to files as EXIF metadata.")
    parser.add_argument('--exiftool', help="Exiftool binary path", default="/usr/local/bin/exiftool")
    parser.add_argument('folder', help="The folder you want to update.")
    args = parser.parse_args()

    if not os.path.isdir(args.folder):
        print("Please provide a folder")
        sys.exit()

    for _, _, files in os.walk(args.folder):
        for key, group in groupby(sorted(files), lambda x: x[0].lower()):
            grouped_files = map(lambda filename: os.path.join(args.folder, filename), group)
            (lat, long) = generate_location()
            for file in grouped_files:
                add_gps(args.exiftool, file, lat, long)


def generate_location():
    while True:
        lat = round(random.uniform(-90, 90), 6)
        long = round(random.uniform(-180, 180), 6)
        resp = json.load(urllib.request.urlopen(f'http://localhost:9300/geocode?latitude={lat}&longitude={long}'))
        name = resp[0][0]['name']
        dist = resp[0][0]['distance']
        print([name, dist])
        if dist < 10:
            return lat, long


def add_gps(exiftool, path, lat, long):
    print(f"Adding gps data {(lat, long)} to {path}")
    subprocess.run([exiftool, '-GPS*=', path])  # Remove GPS
    subprocess.run([
        exiftool,
        f'-GPSLatitude={lat}',
        f'-GPSLatitudeRef={lat}',
        f'-GPSLongitude={long}',
        f'-GPSLongitudeRef={long}',
        path
    ])


if __name__ == '__main__':
    main()

