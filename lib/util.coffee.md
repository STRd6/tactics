Util
====

Deferred
--------

Use jQuery deferred

    global.Deferred = jQuery.Deferred

Helpers
-------

    isObject = (object) ->
      Object::toString.call(object) is "[object Object]"

Size
----

A 2d extent.

    Size = (width, height) ->
      if isObject(width)
        {width, height} = width

      width: width
      height: height
      __proto__: Size.prototype

    Size.prototype =
      scale: (scalar) ->
        Size(@width * scalar, @height * scalar)

      toString: ->
        "Size(#{@width}, #{@height})"

      each: (iterator) ->
        [0...@height].forEach (y) ->
          [0...@width].forEach (x) ->
            iterator(x, y)

Point Extensions
----------------

    Point.prototype.scale = (scalar) ->
      if isObject(scalar)
        Point(@x * scalar.width, @y * scalar.height)
      else
        Point(@x * scalar, @y * scalar)

    Point.prototype.sign = ->
      Point(@x.sign(), @y.sign())

Extra utilities that may be broken out into separate libraries.

    module.exports =

      Size: Size

A 2d grid of values.

      Grid: ({width, height}, defaultValue) ->
        generateValue = (x, y) ->
          if typeof defaultValue is "function"
            defaultValue(x, y)
          else
            defaultValue

        grid =
          [0...height].map (y) ->
            [0...width].map (x) ->
              generateValue(x, y)

        self =
          contract: (x, y) ->
            height -= y
            width -= x

            grid.length = height

            grid.forEach (row) ->
              row.length = width

            return self

          copy: ->
            Grid(width, height, self.get)

          get: (x, y) ->
            if x.x?
              {x, y} = x

            return if x < 0 or x >= width
            return if y < 0 or y >= height

            grid[y][x]

          set: (x, y, value) ->
            if x.x?
              {x, y} = x

            return if x < 0 or x >= width
            return if y < 0 or y >= height

            grid[y][x] = value

          each: (iterator) ->
            grid.forEach (row, y) ->
              row.forEach (value, x) ->
                iterator(value, x, y)

            return self

          expand: (x, y) ->
            newRows = [0...y].map (y) ->
              [0...width].map (x) ->
                generateValue(x, y + height)

            grid = grid.concat newRows

            grid = grid.map (row, y) ->
              row.concat [0...x].map (x) ->
                generateValue(width + x, y)

            height = y + height
            width = x + width

            return self

Return a 1-dimensional array of the data within the grid.

          toArray: ->
            grid.reduce (a, b) ->
              a.concat(b)
            , []

        return self
