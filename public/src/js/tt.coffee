# texttwist redux

##############################
## General helper functions ##
##############################

$.fn.randomize = (selector)->
    $elems = if selector then $(this).find(selector) else $(this).children()
    $parents = $elems.parent()
    $parents.each ()->
        $(this).children(selector).sort( ()->
            return Math.round(Math.random()) - 0.5
        ).remove().appendTo(this)

    return this

##########################
## Game-related classes ##
##########################

##############
## TileRack ##
##############

class TileRack

    constructor: ()->
        @addTileToRack('n')
        @addTileToRack('e')
        @addTileToRack('a')
        @addTileToRack('r')
        @addTileToRack('e')
        @addTileToRack('r')
        @addTileToRack('l')

    addTileToRack: (char)->
        newtile = $("<div data-char='#{char}' class=\"tile\">#{@getCharText(char)}</div>")
        $("#source-tiles").append(newtile)

    getCharText: (char)->
        return char.toUpperCase()
    
    getTileChar: (tile)->
        return tile.attr('data-char')
    
    getWord: ()->
        return $("#dest-tiles > .tile").map ()->
            return $(this).attr('data-char')
        .get().join("")
    
    shuffleSourceTiles: ()->
        $("#source-tiles").randomize('div')
    
    typeTile: (char)->
        # move tile from source to destination
        tile = $("#source-tiles > [data-char='" + char + "']:first")
        if tile.length == 0
            return
        tile.remove()
        $("#dest-tiles").append(tile)
        console.log('tile:\t', tile.text())
    
    delTile: ()->
        # move tile from destination to source
        tile = $("#dest-tiles > .tile:last")
        tile.remove()
        $("#source-tiles").append(tile)
    
    clearAllTiles: ()->
        $("#dest-tiles > .tile").each ()=>
            @delTile()

############################
## AnswerTable and Answer ##
############################

class Answer
    constructor: (@word)->
        @length = @word.length
        @element = $("<p class=\"unmarked\" data-word='#{@word}' data-length='#{@len}'>#{word}</p>")

    findElement: ()->
        return $("#answers-table td[data-word='#{@word}']")

    markAnswered: ()->
        @element.removeClass("unmarked")
        @element.addClass("marked")

class AnswerTable

    constructor: (wordlist)->
        @answers = {}

        lengths = {}
        for word in wordlist
            ans = new Answer(word)
            @answers[word] = ans
            if not lengths[ans.length] then lengths[ans.length] = []
            lengths[ans.length].push(ans)
        lenarr = []
        for len, list of lengths
            list.sort (a, b)->
                return a.word > b.word
            lenarr.push(len)
        lenarr.sort()
        @answersTableElem = $("#answers-table tr")
        for len in lenarr
            newdiv = $("<td></td>")
            for word in lengths[len]
                newdiv.append(word.element)
                @answersTableElem.append(newdiv)

    guessWord: (word)->
        if @answers[word]? then @answers[word].markAnswered()

####################
## Game and Round ##
####################
        
class Round

    constructor: ()->

        ## Register event handlers ##
        
        $(document).keydown (event)=>
            event.preventDefault()
            console.log('keycode\t', event.keyCode)
            switch
                # 8 -> backspace
                when event.keyCode == 8 then @backspaceHandler()
                # 13 -> enter
                when event.keyCode == 13 then @enterHandler()
                # 32 -> space
                when event.keyCode == 32 then @shuffleHandler()
                when 65 <= event.keyCode && event.keyCode <= 90 
                    @letterHandler(event.keyCode)

    startRound: ()->
        @rack = new TileRack()
        wordlist = ['ear', 'earn', 'learn', 'eel', 'earl', 'lee', 'ran', 'reel', 'leer',
            'err', 'rare', 'near', 'nearer', 'lane', 'lean', 'leaner', 'relearn']
        @ansTable = new AnswerTable(wordlist)

    ## Event handlers ##
    
    enterHandler: ()->
        word = @rack.getWord()
        $("#word").text(word)
        @ansTable.guessWord(word)
        @rack.clearAllTiles()
    
    shuffleHandler: ()->
        @rack.shuffleSourceTiles()
    
    backspaceHandler: ()->
        @rack.delTile()
    
    letterHandler: (keycode)->
        char = 'abcdefghijklmnopqrstuvwxyz'.charAt(keycode - 65)
        console.log('char:\t', char)
        @rack.typeTile(char)

class Game
    constructor: ()->
        @round = new Round()
        @round.startRound()

###
Ready to start! :D
###
    
$(document).ready ()->

    game = new Game()
