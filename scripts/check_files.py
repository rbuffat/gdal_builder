#!/usr/bin/env python3

import os
import sys

path = sys.argv[1]

print("Check files in {}".format(path))

for root, dirs, files in os.walk(path):

    for fname in files:
        fpath = os.path.join(root, fname)
        print(fpath, os.path.getsize(fpath))
