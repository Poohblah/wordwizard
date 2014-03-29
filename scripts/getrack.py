# script to import dictionary and tileset

import random
import itertools
import time
# import ../models

# globals
min_tiles = 4
max_tiles = 8

dictfn    = 'resources/en/dictionaries/twl06.txt'
tilesetfn = 'resources/en/tilesets/superscrabble.txt'

# open files
dictf    = open(dictfn)
tilesetf = open(tilesetfn)

# get dictionary object
dictobj = {}
for line in dictf:
    word = line.strip().lower()
    letterstr = ''.join(sorted(word))
    wordlist = dictobj.get(letterstr)
    if not wordlist:
        dictobj[letterstr] = []
        wordlist = dictobj[letterstr]
    wordlist.append(word)

# get back of tiles
tilebag = []
for line in tilesetf:
    tile, num = line.strip().split()
    tile.lower()
    num = int(num)
    for i in range(num): tilebag = tilebag + [tile]

class Rack():
    def __init__(self, tl=[], wl=[]):
        self.tiles = tl
        self.wordlist = wl

# try generating tile rack on the fly and then finding all words
def getrack():
    maxlen = 0
    rack = []
    while maxlen < 7:
        random.shuffle(tilebag)
        rack = tilebag[0:8]
        
        lettersets = {}
        for i in range(2, 9):
            for s in itertools.permutations(rack, i):
                ls = ''.join(s)
                if ls in lettersets: continue
                wl = dictobj.get(ls)
                if wl: lettersets[ls] = wl
        
        wordlist = []
        for ls, wl in lettersets.items():
            wordlist += wl
    
        maxlen = len(max(wordlist, key=lambda x: len(x)))
        
    return Rack(rack, wordlist)

def getdict():
    return dictobj

def gettilebag():
    return tilebag
