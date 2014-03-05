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

    constructor: (tiles)->
        for tile in tiles
            @addTileToRack(tile)

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
        @element = $("<p class=\"unmarked\" data-word='#{@word}' data-length='#{@len}'>#{Array(@length + 1).join("-")}</p>")

    findElement: ()->
        return $("#answers-table td[data-word='#{@word}']")

    markAnswered: ()->
        @element.removeClass("unmarked")
        @element.addClass("marked")
        @element.text(@word)

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
            # console.log('keycode\t', event.keyCode)
            switch
                # 8 -> backspace
                when event.keyCode == 8
                    event.preventDefault()
                    @backspaceHandler()
                # 13 -> enter
                when event.keyCode == 13
                    event.preventDefault()
                    @enterHandler()
                # 32 -> space
                when event.keyCode == 32
                    event.preventDefault()
                    @shuffleHandler()
                when 65 <= event.keyCode && event.keyCode <= 90
                    event.preventDefault()
                    @letterHandler(event.keyCode)

        @startRound()

    startRound: ()->
        $.get('/api/getRound').then (res)=>
            # next line isn't working for some reason
            # if res.status is not 'ok' then throw "Error with getRound"
            @rack = new TileRack(res.payload.tiles)
            @ansTable = new AnswerTable(res.payload.words)

    endRoud: ()->
        # release keypress bindings

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
        @getNewRound()

    getNewRound: ()->
        if @round
            @round.endRound()
            delete @round
        @round = new Round()

###
Ready to start! :D
###
    
$(document).ready ()->

    game = new Game()
