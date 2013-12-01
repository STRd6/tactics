Type
====

Holding all the types of things. Keeping all the types here really just helps
with static analysis. It's possible to use strings to hold and compare types
and for new ones or extensions and modules that may be fine. Eventually they'll
end up here if they're important.

Helpers
-------

    toObject = (list) ->
      list.split("\n").reduce (object, item) ->
        object[item] = item.toLowerCase()

        object
      , {}

List
----

    module.exports = toObject """
      Dirt
      Fire
      Ice
      Plant
      Stone
      Water
    """
