Geometry Helpers
================

Lines and circles and jazz on a grid.

    module.exports =

Call the iterator once for each point on a line from p0 to p1

      line: (p0, p1, iterator) ->
        {x:x0, y:y0} = p0
        {x:x1, y:y1} = p1

        dx = (x1 - x0).abs()
        dy = (y1 - y0).abs()
        sx = (x1 - x0).sign()
        sy = (y1 - y0).sign()
        err = dx - dy

        iterator p0

        while !(x0 is x1 and y0 is y1)
          e2 = 2 * err

          if e2 > -dy
            err -= dy
            x0 += sx

          if e2 < dx
            err += dx
            y0 += sy

          iterator
            x: x0
            y: y0

gross code courtesy of http://en.wikipedia.org/wiki/Midpoint_circle_algorithm

      circle: (center, radius, iterator) ->
        {x:x0, y:y0} = center

        f = 1 - radius
        ddFx = 1
        ddFy = -2 * radius

        x = 0
        y = radius

        iterator Point(x0, y0 + radius)
        iterator Point(x0, y0 - radius)
        iterator Point(x0 + radius, y0)
        iterator Point(x0 - radius, y0)

        while x < y
          if f > 0
            y--
            ddFy += 2
            f += ddFy

          x++
          ddFx += 2
          f += ddFx

          iterator Point(x0 + x, y0 + y)
          iterator Point(x0 - x, y0 + y)
          iterator Point(x0 + x, y0 - y)
          iterator Point(x0 - x, y0 - y)
          iterator Point(x0 + y, y0 + x)
          iterator Point(x0 - y, y0 + x)
          iterator Point(x0 + y, y0 - x)
          iterator Point(x0 - y, y0 - x)
