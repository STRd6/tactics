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

Bounds
------

    Bounds = ({x, y}, {width, height}) ->
      x: x
      y: y
      width: width
      height: height

    Bounds.prototype =
      toString: ->
        "Bounds({#{@x}, #{@y}}, {#{@width}, #{@height}})"

Global Extensions
-----------------

    

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
      Bounds: Bounds
      Size: Size

A 2d grid of values.

      Grid: (I={}) ->
        Object.defaults I,
          width: 0
          height: 0
          data: []

        constructor = I.constructor ? (x) -> x

        items = I.data.map (x) ->
          constructor(x)

        self =
          get: (x, y) ->
            if x.x?
              {x, y} = x

            return if x < 0 or x >= I.width
            return if y < 0 or y >= I.height

            items[x + y * I.width]

          set: (x, y, value) ->
            if x.x?
              value = y
              {x, y} = x

            return if x < 0 or x >= I.width
            return if y < 0 or y >= I.height

            items[x + y * I.width] = value

          each: (iterator) ->
            items.forEach (item, n) ->
              x = n % I.width
              y = (n / I.width).floor()

              iterator(item, Point(x, y), self)

            return self

          toJSON: ->
            I

        return self
