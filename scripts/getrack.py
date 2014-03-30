#!/usr/bin/env python
# script to import dictionary and tileset

import random
import itertools
import time
# import ../models

# globals
min_tiles = 3
max_tiles = 8
min_max_tiles = 7

dictfn    = 'resources/en/dictionaries/sowpods.txt'
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

class Tilemap():
    def __init__(self):
        self.letters = {}
        self.wordlist = []

    def add(self, tileset, wordlist):
        if not tileset:
            self.wordlist = wordlist
            return
        letter = tileset[0]
        ntm = self.letters.get(letter)
        if not ntm:
            ntm = self.letters[letter] = Tilemap()
        ntm.add(tileset[1:], wordlist)

    def construct(self, tilemapping):
        for tileset, wordlist in tilemapping.items():
            self.add(tileset, wordlist)

    def find_words(self, tileset, min_len=0):
        wl = []
        for i in range(0, len(tileset) - min_len):
            ntm = self.letters.get(tileset[i])
            if ntm: wl += self.wordlist + ntm.find_words(tileset[i+1:], min_len=min_len)
            else: wl += self.wordlist
        return wl

    def get_wordlist(self, tileset):
        if not tileset: return self.wordlist
        ntm = self.letters.get(tileset[0])
        if not ntm: return None
        return ntm.get_wordlist(tileset[1:])

tm = Tilemap()
tm.construct(dictobj)

def getrack2():
    st = time.clock()
    maxlen = 0
    rack = []
    wordlist = []
    i = 0
    while maxlen < min_max_tiles:
        i += 1
        random.shuffle(tilebag)
        rack = ''.join(sorted(tilebag[0:max_tiles]))
        wordlist = tm.find_words(rack)
        if wordlist: maxlen = len(max(wordlist, key=lambda x: len(x)))

    et = time.clock()
    tt = et - st
    print "total time to make rack:", tt
    print "tileracks tested:", i
    return Rack(rack, wordlist)
    
if __name__ == '__main__':
    print "tilemapping created. creating tilerack..."
    for i in range(100):
        rack = getrack2()
        print rack.tiles
        print rack.wordlist
