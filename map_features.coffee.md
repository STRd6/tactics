Map Features
============

    Feature = require "./feature"
    QuadTree = require "quadtree"

Features are semi-permanent objects that exist at positions on the map.

    module.exports = (I={}, self=Core(I)) ->
      Object.defaults I,
        features: []

      self.attrModels "features", Feature

      # TODO: Temporary hack to add bushes and walls
      if self.features().length is 0
        self.tileCount().times (i) ->
          position = Point(i % 32, Math.floor(i / 32))
          if rand() < 0.1
            self.features.push Feature.Wall(position)
          else if rand() < 0.025
            self.features.push Feature.Traps.Effect(position, "Fire")
          else if rand() < 0.25
            self.features.push Feature.Bush(position)

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
          # TODO: Scrap quadtree when removing features
          self.features self.features().filter (feature) ->
            kept = feature.update
              addEffect: self.addEffect
              addFeature: self.addFeature
              characterAt: self.characterAt
              find: self.find
              message: self.message
              turn: I.currentTurn

            if !kept
              quadTree = null

            kept

      return self
