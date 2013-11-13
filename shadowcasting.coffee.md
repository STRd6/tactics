Shadowcasting
=============

Based on https://gist.github.com/ebonneville/4200578

Multipliers for transforming coordinates into other octants.

    mult = [
      [1, 0, 0, -1, -1, 0, 0, 1]
      [0, 1, -1, 0, 0, -1, 1, 0]
      [0, 1, 1, 0, 0, -1, -1, 0]
      [1, 0, 0, 1, -1, 0, 0, -1]
    ]

    view = (tile) ->
      tile.seen = tile.lit = true

      return tile

Uses shadowcasting to calculate lighting at specified position

    module.exports = (position, radius) ->
      @tiles = []
      @position = position
      @radius = radius

      # calculates an octant. Called by the this.calculate when calculating lighting
      @calculateOctant = (cx, cy, row, start, end, radius, xx, xy, yx, yy, id) ->
        tile = @tileAt(cx, cy)

        view tile
        @tiles.push tile

        new_start = 0
        return  if start < end
        radius_squared = radius * radius
        i = row

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

            if tile = @tileAt(X, Y)
              l_slope = (dx - 0.5) / (dy + 0.5)
              r_slope = (dx + 0.5) / (dy - 0.5)

              if start < r_slope
                continue
              else if end > l_slope
                break
              else
                if dx * dx + dy * dy < radius_squared
                  view tile

                  @tiles.push tile

                if blocked
                  if tile.opaque
                    new_start = r_slope
                    continue
                  else
                    blocked = false
                    start = new_start
                else
                  if tile.opaque and i < radius
                    blocked = true
                    @calculateOctant cx, cy, i + 1, start, l_slope, radius, xx, xy, yx, yy, id + 1
                    new_start = r_slope

          if blocked
            done = true

      # sets flag lit to false on all tiles within radius of position specified
      @clear = ->
        @tiles.forEach (tile) ->
          tile.lit = false

        @tiles = []

      # sets flag lit to true on all tiles within radius of position specified
      @calculate = ->
        @clear()

        [0..7].forEach (i) =>
          @calculateOctant @position.x, @position.y, 0, 1.0, 0.0, @radius,
            mult[0][i], mult[1][i], mult[2][i], mult[3][i], 0

        tile = @tileAt @position.x, @position.y

        view tile
        @tiles.push tile

      # update the position of the light source
      @update = (position) ->
        @position = position
        @calculate()

      return this
