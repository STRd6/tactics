BitArray = require "../lib/bit_array"

testPattern = (n) ->
  bitArray = BitArray(256)

  [0...256].forEach (i) ->
    bitArray.set(i, i % n is 0)

  reloadedArray = BitArray(bitArray.toJSON())

  [0...256].forEach (i) ->
    test = 0 | (i % n is 0)
    assert.equal reloadedArray.get(i), test, "Bit #{i} is #{test}"

describe "BitArray", ->
  it "should be empty to start", ->
    bitArray = BitArray(256)

    [0...256].forEach (i) ->
      assert.equal bitArray.get(i), 0

  it "should be able to set and get bits", ->
    bitArray = BitArray(256)

    [0...256].forEach (i) ->
      bitArray.set(i, 1)

    [0...256].forEach (i) ->
      assert.equal bitArray.get(i), 1

  it "should be serializable and deserializable", ->
    bitArray = BitArray(256)

    [0...256].forEach (i) ->
      bitArray.set(i, 1)

    reloadedArray = BitArray(bitArray.toJSON())

    [0...256].forEach (i) ->
      assert.equal reloadedArray.get(i), 1, "Bit #{i} is 1"

  it "should be serializable and deserializable with various patterns", ->
    testPattern(1)
    testPattern(2)
    testPattern(3)
    testPattern(4)
    testPattern(5)
    testPattern(7)
    testPattern(11)
    testPattern(32)
    testPattern(63)
    testPattern(64)
    testPattern(77)
    testPattern(128)
