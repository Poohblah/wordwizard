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

shuffle  = (arr) ->
    i = arr.length
    if i is 0 then return false

    while --i
        j = Math.floor(Math.random() * (i+1))
        [arr[i], arr[j]] = [arr[j], arr[i]]

isValidAnswer = (racktiles, anstiles)->
    rl = racktiles.length
    al = anstiles.length
    if al > rl then return false
    ri = 0
    ai = 0
    while 1
        if ai == al then return true
        if ri == rl then return false
        if anstiles[ai] ==  racktiles[ri]
            ri++; ai++
        else if anstiles[ai] > racktiles[ri]
            ri++
        else
            return false

##########################
## Game-related classes ##
##########################

##############
## TileRack ##
##############

class TileRack

    constructor: (@tiles)->

    load: ()->
        @cleanup()
        for tile in @tiles
            @addTileToRack(tile)

    cleanup: ()->
        @clearAllTiles()
        $("#source-tiles").html('')

    addTileToRack: (char)->
        newtile = $("<span data-char='#{char}' class=\"tile\">#{@getCharText(char)}</span>")
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
        $("#source-tiles").randomize('.tile')
    
    typeTile: (char)->
        # move tile from source to destination
        tile = $("#source-tiles > [data-char='" + char + "']:first")
        if tile.length == 0
            return
        tile.remove()
        $("#dest-tiles").append(tile)
    
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
        @element = $("<div class=\"answer unmarked\" data-word='#{@word}' data-length='#{@length}'>#{Array(@length + 1).join("<span class=\"tile\"></span>")}</div>")
        @marked = false

    findElement: ()->
        return $("#answers-table td[data-word='#{@word}']")

    markAnswered: (reveal=false)->
        if @marked then return false
        @element.removeClass("unmarked")
        if reveal then @element.addClass("revealed")
        else @element.addClass("marked")
        for tile, i in @element.find('.tile')
            $(tile).text(@word[i])
        @marked = true

class AnswerTable

    constructor: (wordlist)->
        @answers = {}

        @lengths = {}
        for word in wordlist
            ans = new Answer(word)
            @answers[word] = ans
            if not @lengths[ans.length] then @lengths[ans.length] = []
            @lengths[ans.length].push(ans)
        @lenarr = []
        for len, list of @lengths
            list.sort (a, b)->
                if a.word > b.word then return 1 else return -1
            @lenarr.push(len)
        @lenarr.sort()
        @answersTableElem = $("#answers-table tr")

    load: ()->
        @cleanup()
        for len in @lenarr
            newdiv = $("<td class=\"answer-col\"></td>")
            for word in @lengths[len]
                newdiv.append(word.element)
                @answersTableElem.append(newdiv)

    cleanup: ()->
        @answersTableElem.html('')

    guessWord: (word)->
        if @answers[word]?
            if @answers[word].markAnswered() then return "correct"
            else return "guessed"
        else return "wrong"

    revealAll: ()->
        ans.markAnswered(reveal=true) for word, ans of @answers

####################
## Game and Round ##
####################
        
class Round

    constructor: ()->
        @config =
            locale: 'en'
            tileset: 'superscrabble'
            dictionary: 'sowpods'
            tileRackLength: 7
            minAnswerLength: 3
            maxAnswerLength: 7
            minMaxAnswerLength: 7
        @prepareRound()

    prepareRound: ()->
        @ready = @getDict()
        .then ()=>
            @getTileBag()
        .then ()=>
            @getValidRack()
            @ansTable = new AnswerTable(@wordlist)

    startRound: ()->
        @ready.then ()=>
            @rack.load()
            @ansTable.load()
            @bindEvents()

    stopRound: ()->
        @unbindEvents()
        @ansTable.revealAll()
        @rack.clearAllTiles()
        @status('round over.')

    getDict: ()->
        $.get('/api/getDict').then (res)=>
            @dict = res.payload.dict

    getTileBag: ()->
        $.get('/api/getTileBag') .then (res)=>
            @tilebag = res.payload.tilebag

    getValidRack: ()->
        @wordlist = []
        tilerack = []
        valid = false
        while not valid
            shuffle(@tilebag)
            tilerack = @tilebag.splice(0,@config.tileRackLength).sort()
            @wordlist = []
            for ll, al of @dict
                len = ll.length
                if len >= @config.minAnswerLength and
                len <= @config.maxAnswerLength and
                isValidAnswer(tilerack, ll)
                    @wordlist = @wordlist.concat(al)
                    if len >= @config.minMaxAnswerLength then valid = true
        @rack = new TileRack(tilerack)

    endRound: ()->
        @unbindEvents()
        @rack.cleanup()
        @ansTable.cleanup()
        @status("")

    bindEvents: ()->
        $(document).keydown (event)=>
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

    unbindEvents: ()->
        $(document).unbind("keydown")

    status: (status)->
        $("#status").text(status)

    ## Event handlers ##
    
    enterHandler: ()->
        word = @rack.getWord()
        @rack.clearAllTiles()
        status = @ansTable.guessWord(word)
        switch status
            when "wrong" then @status(word + " is not a valid word.")
            when "correct" then @status(word + " is correct!")
            when "guessed" then @status(word + " has already been guessed.")
    
    shuffleHandler: ()->
        @rack.shuffleSourceTiles()
    
    backspaceHandler: ()->
        @rack.delTile()
    
    letterHandler: (keycode)->
        char = 'abcdefghijklmnopqrstuvwxyz'.charAt(keycode - 65)
        @rack.typeTile(char)

class Game
    constructor: ()->
        @getNewRound()
        @bindEvents()

    getNewRound: ()->
        if @round
            @round.endRound()
            delete @round
        if @nextRound
            @round = @nextRound
        else
            @round = new Round()
        @round.startRound()
        @nextRound = new Round()

    stopRound: ()->
        @round.stopRound()

    bindEvents: ()->
        $("[data-value='newround']").click ()=>
            @getNewRound()
        $("[data-value='stopround']").click ()=>
            @stopRound()

###
Ready to start! :D
###
    
$(document).ready ()->

    window.game = new Game()
