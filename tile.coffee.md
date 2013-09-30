Tile
====

A tile in the isometric board.

    Tile = (I={}) ->
      {sha, back} = I
    
      img = $("<img>",
        src: Resource.url(sha)
        load: ->
          self.height = @height
      ).get(0)
    
      if back
        backImg = $("<img>",
          src: Resource.url(back)
          load: ->
            self.backHeight = @height
        ).get(0)
    
      self = Object.extend {},
        __proto__: Tile::
        img: img
        backImg: backImg
        orientation: [1, 0]
      , I
    
    Tile:: =
      toJSON: ->
        _.omit(@, "img", "backImg")
    
      present: ->
        frontUrl: Resource.url @sha
        backUrl: Resource.url(@back || @sha)
    
      draw: (canvas, x, y, cameraRotation=Matrix.IDENTITY) ->
        imgHeight = imgWidth = 64 # TODO real size
        orientation = cameraRotation.deltaTransformPoint(@orientation).round()
    
        hflip = orientation.y
    
        back = (orientation.x + orientation.y) < 0
        if back && @backImg
          hflip = !hflip
          img = @backImg
    
          offset = 64 - (@backHeight or @height)
        else
          img = @img
          offset = 64 - @height
    
        if hflip
          transform = Matrix.HORIZONTAL_FLIP
        else
          transform = Matrix.IDENTITY
    
        canvas.withTransform Matrix.translation(x + imgWidth/2, y + imgHeight/2 + offset), =>
          canvas.withTransform transform, =>
            canvas.drawImage(img, -imgWidth/2, -imgHeight/2)

    module.exports = Tile
