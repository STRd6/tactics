Character Presenter
===================

A trash heap where we put all the code to make our haml nice.

Cleans up some of our character HUD markup.

    module.exports = (character) ->
      classes: ->
        classes = ["squad"]

        if map.activeCharacter() is character
          classes.push "active"

        if character.actions() is 0
          classes.push "inactive"

        if character.stunned()
          classes.push "stunned"

        unless character.alive()
          classes.push "dead"

        race = map.squads().select (squad) ->
          squad.characters().indexOf(character) >= 0
        .first().race()

        classes.push race

        classes.join(" ")

      click: (e) ->
        $target = $(e.currentTarget)

        return if $target.is(".stunned, .dead, .inactive")

        squad = map.activeSquad()
        character = squad.activatableCharacters().filter (c) ->
          c?.name() is $target.find(".name").text()
        .first()

        if character
          squad.activeCharacter(character)
