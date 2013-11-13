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

    Sprite = require "./sprite"
    cache = require "./images"

    Resource =
      dataURL: (name) ->
        cache[name]
      sprite: (name) ->
        Sprite.load cache[name]

    module.exports = Resource