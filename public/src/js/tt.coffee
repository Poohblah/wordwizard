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

###########################
## Tile helper functions ##
###########################

getCharText = (char)->
    return char.toUpperCase()

getTileChar = (tile)->
    return tile.attr('data-char')

getWord = ()->
    return $("#dest-tiles > .tile").map( ()-> return $(this).attr('data-char')).get().join("")

shuffleSourceTiles = ()->
    $("#source-tiles").randomize('div')

delTile = ()->
    # move tile from destination to source
    tile = $("#dest-tiles > .tile:last")
    tile.remove()
    $("#source-tiles").append(tile)

clearAllTiles = ()->
    $("#dest-tiles > .tile").each ()->
        delTile()

####################
## Event handlers ##
####################

enterHandler = ()->
    word = getWord()
    $("#word").text(word)
    clearAllTiles()

shuffleHandler = ()->
    shuffleSourceTiles()

backspaceHandler = ()->
    delTile()

letterHandler = (keycode)->
    char = 'abcdefghijklmnopqrstuvwxyz'.charAt(keycode - 65)
    console.log('char:\t', char)

    # move tile from source to destination
    tile = $("#source-tiles > [data-char='" + char + "']:first")
    if tile.length == 0
        return
    tile.remove()
    $("#dest-tiles").append(tile)
    console.log('tile:\t', tile.text())

###################
## Prepare round ##
###################

addTileToRack = (char)->
    newtile = $("<div data-char='#{char}' class=\"tile\">#{getCharText(char)}</div>")
    $("#source-tiles").append(newtile)

newRack = ()->
    addTileToRack('n')
    addTileToRack('e')
    addTileToRack('a')
    addTileToRack('r')
    addTileToRack('e')
    addTileToRack('r')
    addTileToRack('l')

startRound = ()->
    newRack()

$(document).ready ()->

    #############################
    ## Register event handlers ##
    #############################
    
    $(document).keydown (event)->
        event.preventDefault()
        console.log('keycode\t', event.keyCode)
    
        # 8 -> backspace
        if event.keyCode == 8
            backspaceHandler()
    
        # 13 -> enter
        else if event.keyCode == 13
            enterHandler()
    
        # 32 -> space
        else if event.keyCode == 32
            shuffleHandler()
        
        else if 65 <= event.keyCode && event.keyCode <= 90
            letterHandler(event.keyCode)
    
    ###############
    ## START! :D ##
    ###############

    startRound()
