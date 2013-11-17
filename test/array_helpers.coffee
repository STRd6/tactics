{intersection, indexOf} = require "../array_helpers"

Number::equal = (other) ->
  (this + 0) == other

describe "Array Helpers", ->
  it "indexOf", ->
    assert indexOf([1, 2, 3], 2) is 1

  it "intersection", ->
    result = intersection [Point(1, 1), Point(2, 1), Point(3, 1)], [Point(1, 1)]

    assert result.length is 1
