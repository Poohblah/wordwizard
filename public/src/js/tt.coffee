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

enterHandler = ()->
    word = getWord()
    $("#word").text(word)

shuffleHandler = ()->
    shuffleSourceTiles()

####################
## Event handlers ##
####################

backspaceHandler = ()->
    # move tile from destination to source
    tile = $("#dest-tiles > .tile:last")
    tile.remove()
    $("#source-tiles").append(tile)

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
        spaceHandler()
    
    else if 65 <= event.keyCode && event.keyCode <= 90
        letterHandler(event.keyCode)
