#!/bin/bash 2>nul

python art/tools/join.py --template art/tools/fwk.h.inl --path ./ --output ./fwk.h
python art/tools/join.py --template art/tools/fwk.c.inl --path ./ --output ./fwk.c
python art/tools/join.py --template art/tools/fwk.3.inl --path ./ --output ./fwk.3
