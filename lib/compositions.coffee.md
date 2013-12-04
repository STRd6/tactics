Compositions
============

The compositions module provides helper methods to compose nested data models.

Compositions uses observables to keep the internal data in sync.

    module.exports = (I={}, self=Core(I)) ->

      self.extend

Observe any number of attributes as simple observables. For each attribute name passed in we expose a public getter/setter method and listen to changes when the value is set.

        attrObservable: (names...) ->
          names.each (name) ->
            self[name] = Observable(I[name])

            self[name].observe (newValue) ->
              I[name] = newValue

          return self

Observe an attribute as a model. Treats the attribute given as an Observable
model instance exposting a getter/setter method of the same name. The Model
constructor must be passed in explicitly.

        attrModel: (name, Model) ->
          model = Model(I[name])

          self[name] = Observable(model)

          self[name].observe (newValue) ->
            I[name] = newValue.I

          return self

Observe an attribute as a list of sub-models. This is the same as `attrModel`
except the attribute is expected to be an array of models rather than a single one.

        attrModels: (name, Model) ->
          models = (I[name] or []).map (x) ->
            Model(x)

          self[name] = Observable(models)

          self[name].observe (newValue) ->
            I[name] = newValue.map (instance) ->
              instance.I

          return self

The JSON representation is kept up to date via the observable properites and resides in `I`.

        toJSON: ->
          I

Return our public object.

      return self
