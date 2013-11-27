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

    bushSprites = [0..3].map (i)->
      Resource.sprite("bush#{i}")

    wallSprites = [0..3].map (i) ->
      Resource.sprite("brick_vines#{i}")

    wall = ->
      sprite: wallSprites.rand()
      lit: []
      seen: []
      opaque: true
      solid: true
      features: []

    ground = ->
      bush = rand() < 0.1

      sprite: groundSprites[0].rand()
      lit: []
      seen: []
      opaque: bush
      solid: false
      features: [0...bush].map ->
        Feature.Bush()

    module.exports =
      generate: (size) ->
        Grid size, (x, y) ->
          if rand() < 0.10
            wall()
          else
            ground()
