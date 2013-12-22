Character Presenter
===================

A trash heap where we put all the code to make our haml nice.

Cleans up some of our character HUD markup.

    module.exports = (character) ->
      classes: ->
        classes = []

        if map.activeCharacter() is character
          classes.push "active"

        if character.stunned()
          classes.push "stunned"

        if map.squads()[0].characters().indexOf(character) >= 0
          classes.push "squad1"
        else
          classes.push "squad2"

        classes.join(" ")
