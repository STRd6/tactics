Sprite
======

The Sprite class provides a way to load images for use in games.

A sprite is a still 2d image.

An animation can be created from a collection of sprites.

By default, images are loaded asynchronously. A proxy object is
returned immediately. Even though it has a draw method it will not
draw anything to the screen until the image has been loaded.

    LoaderProxy = ->
      draw: ->
      fill: ->
      width: null
      height: null
      image: null

Cache loaded images

    spriteCache = {}

    Sprite = (image, sourceX, sourceY, width, height) ->
      sourceX ||= 0
      sourceY ||= 0
      width ||= image.width
      height ||= image.height

Draw this sprite on the given canvas at the given position.

      draw: (canvas, x, y) ->
        canvas.drawImage(
          image,
          sourceX,
          sourceY,
          width,
          height,
          x,
          y,
          width,
          height
        )

Draw this sprite on the given canvas tiled to the x, y,
width, and height dimensions specified.
  
Repeat options can be `repeat-x`, `repeat-y`, `no-repeat`, or `repeat`. Defaults to `repeat`

      fill: (canvas, x, y, width, height, repeat="repeat") ->
        pattern = canvas.createPattern(image, repeat)
        canvas.drawRect({x, y, width, height, color: pattern})
  
      width: width
      height: height
      image: image
  
Loads all sprites from a sprite sheet found in
your images directory, specified by the name passed in.

Returns an array of sprite objects which will start out empty, but be filled
once the image has loaded.

    Sprite.loadSheet = (name, tileWidth, tileHeight) ->
      url = ResourceLoader.urlFor("images", name)
  
      sprites = []
      image = new Image()
  
      image.onload = ->
        imgElement = this
        (image.height / tileHeight).times (row) ->
          (image.width / tileWidth).times (col) ->
            sprites.push(Sprite(imgElement, col * tileWidth, row * tileHeight, tileWidth, tileHeight))

      image.src = url

      return sprites

Loads a sprite from a given url.
A second optional callback parameter may be passet wich is executeh once the
image is loaded. The sprite proxy data is passed to it as the only parameter.

    Sprite.fromURL = Sprite.load = (url, loadedCallback) ->
      if sprite = spriteCache[url]
        loadedCallback?.defer(sprite)
        return sprite

      img = new Image()
      proxy = LoaderProxy()

      img.onload = ->
        spriteCache[url] = Object.extend(proxy, Sprite(this))

        loadedCallback?(proxy)

      img.src = url

      return proxy

A sprite that draws nothing.

    Sprite.EMPTY = Sprite.NONE = LoaderProxy()
    
Load a sprite with the given name. The first parameter is name The name of the 
image in your images directory. The second parameter is a callback function to 
execute once the image is loaded. The sprite proxy data is passed to this as a parameter.

    Sprite.loadByName = (name, callback) ->
      Sprite.load(ResourceLoader.urlFor("images", name), callback)

    module.exports = Sprite
