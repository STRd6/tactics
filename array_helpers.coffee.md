Array Helpers
=============

A bunch of array helpers that will work with Points and other objects that
implement an `.equal` method.

Returns the index of the element in the array if present, undefined if not.

    indexOf = (array, item) ->
      for element, index in array
        return index if element.equal(item)

      return

    without = (array, values...) ->
      array.reject (element) ->
        indexOf(values, element)?

    unique = (array) ->
      array.reduce (results, element) ->
        results.push element unless indexOf(results, element)
        results
      , []

    intersection = (array, others...) ->
      unique(array).filter (item) ->
        others.every (array) ->
          indexOf(array, item)?

    module.exports = {
      indexOf
      intersection
      unique
      without
    }
