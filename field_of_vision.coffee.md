Field Of Vision
===============

Based on https://gist.github.com/ebonneville/4200578

Multipliers for transforming coordinates into other octants.

    mult = [
      [1, 0, 0, -1, -1, 0, 0, 1]
      [0, 1, -1, 0, 0, -1, 1, 0]
      [0, 1, 1, 0, 0, -1, -1, 0]
      [1, 0, 0, 1, -1, 0, 0, -1]
    ]

    debug = false

    colors = [
      [1, 0, 0]
      [0, 1, 0]
      [0, 0, 1]
      [1, 1, 0]
      [0, 1, 1]
      [1, 0, 1]
    ].map (values) ->
      rgb = values.map (value) ->
        value * 255
      .join(",")

      "rgba(#{rgb}, 0.125)"

Uses shadowcasting to calculate lighting at specified position

`calculateOctant` is the meat of the algorithm. I basically understand it, but the
code isn't really in a position to be modified easily yet.

http://roguebasin.roguelikedevelopment.org/index.php?title=FOV_using_recursive_shadowcasting explains it fairly well.

TODO: Maybe we can avoid passing in tileAt and just use opaque instead.

    calculateOctant = (positions, tileAt, opaque, cx, cy, row, start, end, radius, xx, xy, yx, yy, id) ->
      tile = tileAt(cx, cy)

      positions.push Point(cx, cy)

      new_start = 0
      return if start < end
      radius_squared = radius * radius

      dx = -row
      dy = -row
      X = cx + dx * xx + dy * xy
      Y = cy + dx * yx + dy * yy

      if id > 0
        markTile(Point(X, Y), 4)

      return unless row <= radius
      done = false

      [row..radius].forEach (i) =>
        return if done

        dx = -i - 1
        dy = -i
        blocked = false

        while dx <= 0
          dx += 1
          X = cx + dx * xx + dy * xy
          Y = cy + dx * yx + dy * yy

          d = radius - Math.sqrt(dx * dx + dy * dy)
          debugTile(Point(X, Y), "#{d.toFixed(2)}")

          if tile = tileAt(X, Y)
            l_slope = (dx - 0.5) / (dy + 0.5)
            r_slope = (dx + 0.5) / (dy - 0.5)

            if start < r_slope
              continue
            else if end > l_slope
              break
            else
              if dx * dx + dy * dy < radius_squared
                positions.push Point(X, Y)

              if blocked
                if opaque(tile)
                  markTile(Point(X, Y), 1)
                  new_start = r_slope
                  continue
                else
                  markTile(Point(X, Y), 2)
                  blocked = false
                  start = new_start
              else
                if opaque(tile)
                  markTile(Point(X, Y), 0)
                  blocked = true
                  calculateOctant positions, tileAt, opaque, cx, cy, i + 1, start, l_slope, radius,
                    xx, xy, yx, yy, id + 1
                  new_start = r_slope

        if blocked
          done = true

    module.exports =

Calculate the field of vision.

      calculate: (tileAt, opaque, position, radius) ->
        positions = []

        [0..7].forEach (i) =>
          xx = mult[0][i]
          xy = mult[1][i]
          yx = mult[2][i]
          yy = mult[3][i]

          calculateOctant positions, tileAt, opaque, position.x, position.y, 0, 1.0, 0.0, radius,
            xx, xy, yx, yy, 0

        tile = tileAt position.x, position.y

        positions.push position

        return positions

Debug Helpers
-------------

    debugTile = (position, message) ->
      return unless debug

      setTimeout ->
        message.split("\n").forEach (part, i) ->
          canvas.centerText
            position: position.add(Point(0.5, 0.5)).scale(32).add Point(0, i).scale(12)
            text: part
            color: "white"
      , 0

    markTile = (position, color) ->
      return unless debug

      setTimeout ->
        canvas.drawRect
          position: position.scale(32)
          width: 32
          height: 32
          color: colors[color]
      , 0

