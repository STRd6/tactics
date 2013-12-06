AI
====

An attempt at simple AI.

Game AI might use cheating because AI programming is hard.

Eventuall AI could cheat less to make the game more "realistic".

Simplest AI:

Find Enemy
Approach Enemy
Attack

    module.exports = (I={}, self=Core(I)) ->
      self.extend
        moveRandomly: ->
          