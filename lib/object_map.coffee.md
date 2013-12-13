Object Map
==========

Map all values of an object into a new object where they all have the same
keys, but their values have been transformed by the function.

    module.exports = (object, fn) ->
      Object.keys(object).reduce (results, name) ->
        results[name] = fn(object[name])

        results
      , {}
