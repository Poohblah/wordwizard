#!/usr/bin/env python
# script to import dictionary and tileset

import random
import itertools
import time
import json
# import ../models

# globals
min_tiles = 3
max_tiles = 8
min_max_tiles = 7

def gettilebag():
    # get bag of tiles
    tilesetfn = 'resources/en/tilesets/superscrabble.txt'
    tilesetf = open(tilesetfn)
    tilebag = []
    for line in tilesetf:
        tile, num = line.strip().split()
        tile.lower()
        num = int(num)
        for i in range(num): tilebag = tilebag + [tile]
    return tilebag

def getdictobj():
    dictfn    = 'resources/en/dictionaries/sowpods.txt'
    dictf    = open(dictfn)
    dictobj = {}
    for line in dictf:
        word = line.strip().lower()
        letterstr = ''.join(sorted(word))
        wordlist = dictobj.get(letterstr)
        if not wordlist:
            dictobj[letterstr] = []
            wordlist = dictobj[letterstr]
        wordlist.append(word)
    return dictobj

class Rack():
    def __init__(self, tl=[], wl=[]):
        self.tiles = tl
        self.wordlist = wl

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

    def to_dict(self):
        result = { "letters": {}, "wordlist": self.wordlist }
        for l, tm in self.letters.items(): result["letters"][l] = tm.to_dict()
        return result

    def construct_from_dict(self, d):
        self.wordlist = d["wordlist"]
        for l, tmd in d["letters"].items():
            ntm = Tilemap()
            ntm.construct_from_dict(tmd)
            self.letters[l] = ntm

    def construct_from_json_file(self, filename):
        f = open(filename, 'r')
        self.construct_from_dict(json.load(f))

def getrack2(tilebag, tm):
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
    r = Rack(rack, wordlist)
    print r.tiles
    print r.wordlist
    return r
    
if __name__ == '__main__':
    make_dictobj()
    print "tilemapping created. creating tilerack..."
    for i in range(100):
        rack = getrack2()
        print rack.tiles
        print rack.wordlist
