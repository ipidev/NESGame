#!/usr/bin/env python3

# Original code by bbbradsmith, adapted by Sean Latham
# https://github.com/bbbradsmith/NES-ca65-example/blob/master/example_fceux_symbolbols.py

import sys
assert sys.version_info[0] >= 3, "Python 3 required."

from collections import OrderedDict

def label_to_nl(labelFile, outputFile, rangeMin, rangeMax):
    labels = []
    try:
        file = open(labelFile, "rt")
        labels = file.readlines()
    except IOError:
        return

    labelDict = {}
    for line in labels:
        words = line.split()
        if (words[0] == "al"):
            address = int(words[1], 16)
            symbol = words[2]
            symbol = symbol.lstrip('.')
            # Skip compiler internals
            if (symbol[0] == '_' and symbol[1] == '_'):
                continue
            if (address >= rangeMin and address <= rangeMax):
                # Handle addresses representing multiple symbols
                if (address in labelDict):
                    text = labelDict[address]
                    textsplit = text.split()
                    if (symbol not in textsplit):
                        text = text + " " + symbol
                        labelDict[address] = text
                else:
                    labelDict[address] = symbol

    outputString = ""
    for (address, symbol) in labelDict.items():
        outputString += ("$%04X#%s#\n" % (address, symbol))
    open(outputFile, "wt").write(outputString)
    
if __name__ == "__main__":
    if len(sys.argv) == 3:
        label_to_nl(sys.argv[1], sys.argv[2] + ".ram.nl", 0x0000, 0x7FF)
        label_to_nl(sys.argv[1], sys.argv[2] + ".0.nl", 0x8000, 0xBFFF)
        label_to_nl(sys.argv[1], sys.argv[2] + ".1.nl", 0xC000, 0xFFFF)
    else:
        print("usage: exportFCEUXsymbolbols.py labelsFilename nesRomFilename")
