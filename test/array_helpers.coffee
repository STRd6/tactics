{intersection, indexOf} = require "../array_helpers"

Number::equal = (other) ->
  (this + 0) == other

describe "Array Helpers", ->
  describe "unique", ->
    it "doesn't duplicate elements whose index is 0", ->
      arr = [
        Point
          x: 4
          y: 5
        Point
          x: 6
          y: 4
        Point
          x: 4
          y: 5
      ]

      assert unique(arr).length is 2

  it "indexOf", ->
    assert indexOf([1, 2, 3], 2) is 1

  it "intersection", ->
    result = intersection [Point(1, 1), Point(2, 1), Point(3, 1)], [Point(1, 1)]

    assert result.length is 1
