Map Features
============

    Feature = require "./feature"
    QuadTree = require "quadtree"

Features are semi-permanent objects that exist at positions on the map.

There is some overlap with characters, but currently they share no common
components.

    module.exports = (I={}, self=Core(I)) ->
      defaults I,
        features: []

      self.attrModels "features", Feature

      featuresToAdd = []
      quadTree = null

      ensureQuadTree = ->
        unless quadTree
          quadTree = QuadTree
            x: 0
            y: 0
            width: self.width()
            heigth: self.height()

          self.features().forEach addToQuadTree

      addToQuadTree = (feature) ->
        p = feature.position()
        p.feature = feature

        quadTree.insert p

      self.extend
        feature: (name, params...) ->
          self.addFeature Feature[name](params...)

        # TODO: Phase addFeature out in favor of `feature` style
        addFeature: (feature) ->
          feature.createdAt(I.currentTurn)
          featuresToAdd.push(feature)

        addNewFeatures: ->
          ensureQuadTree()

          while featuresToAdd.length
            feature = featuresToAdd.pop()

            self.features.push feature
            addToQuadTree(feature)

        featuresAt: (position) ->
          ensureQuadTree()

          quadTree.retrieve(position)
          .filter (result) ->
            position.equal(result)
          .map (result) ->
            result.feature

        updateFeatures: ->
          # Updating and filtering features to only the active features
          self.features self.features().filter (feature) ->
            kept = feature.update self.methodObject()

            if !kept
              quadTree = null

            kept

      return self
