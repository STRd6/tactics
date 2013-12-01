Map Generator
=============

    Feature = require "./feature"
    {Grid} = require "./lib/util"
    Resource = require "./resource"

Hold the terrain and whatnot for a level.

    groundSprites = ["ground", "frozen", "stone"].map (type) ->
      [0..7].map (i) ->
        "#{type}#{i}"
      .map Resource.sprite

    wall = ->
      sprite: groundSprites[0].rand()
      lit: []
      seen: []
      features: [Feature.Wall()]

    ground = ->
      bush = rand() < 0.1

      sprite: groundSprites[0].rand()
      lit: []
      seen: []
      features: [0...bush].map ->
        Feature.Bush()

    module.exports =
      generate: (size) ->
        Grid size, (x, y) ->
          if rand() < 0.10
            wall()
          else
            ground()
