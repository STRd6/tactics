Resource
========

A loader for resources in games and stuff.

We primarily want to load resources from localStorage or resource packfiles
bundled with the page or downloaded from the internet.

I don't know what packfiles are yet, but the seem like a good way to package up
resources.

Locally we can look up pngs by name and return data-urls.

We may even want to store the data-urls as compressed data, but that seems
excessive.

    Sprite = require "sprite"
    images = require "./images"

    spriteCache = {}

    nullImage = new Image

    sourceIndex = 0

    Resource =
      dataURL: (name) ->
        images[name]
      sprite: (name) ->
        return spriteCache[name] if spriteCache[name]

        if images[name]
          spriteCache[name] = Sprite.load images[name]
        else
          spriteCache[name] = Sprite nullImage

      addSource: (gistId) ->
        do (index=sourceIndex) ->
          sourceIndex += 1
          $.ajax
            url: "https://api.github.com/gists/#{gistId}"
            type: "GET"
            dataType: "jsonp"
          .success ({data, meta}) ->
            console.log meta

            remoteImages = JSON.parse data.files["images.json"].content

            Object.keys(remoteImages).forEach (name) ->
              unless spriteCache[name]?.index > index
                Sprite.load remoteImages[name], (sprite) ->
                  if spriteCache[name]
                    extend spriteCache[name], sprite
                  else
                    spriteCache[name] = sprite

                  spriteCache[name].index = index

    module.exports = Resource
