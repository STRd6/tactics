Ability
=======

Abilities of characters can be activated in the tactical screen.

Abilities can target:

  - Self
  - LoS
  - Visible to Squad
  - Any tile within range

Abilities may have additional range restrictions.

Abilities don't necessarily have to target a character, they may target a map
tile.

Abilities usually consume all remaining character actions.

Some abilities may need both actions unused to activate.

Some abilities may have a cooldown.

Some abilities may require zero actions to activate and only have a cooldown.

Some abilities may be situational (like Force Door being only available targetting the door adjacent to the character)

Some cool abilities that should be in the game

  - Movement
  - Ranged Attacks
  - Melee Attacks
  - Overwatch
  - Heal
  - Dig
  - Teleport
  - Fireball
  - Buffs
  - Debuffs

    Ability = (I={}, self=Core(I)) ->
      Object.defaults I,
        range: (character) ->
          character.movement()
        actionCost: 1
        name: "Move"
        costType: Ability.COST_TYPE.FIXED

      self.attrAccessor(
        "actionCost"
        "actionType"
        "costType"
        "iconName"
        "name"
        "range"
      )

      Object.extend self,
        payCosts: (owner) ->
          switch self.costType()
            when COST_TYPE.REST
              owner.actions(0)
            when COST_TYPE.FIXED
              owner.actions owner.actions() - self.actionCost()
            else
              throw "Unknown action cost type"

        validTargets: (owner, tileAt) ->

          
      return self

Wherever possible we should reduce complexity and compose simpler actions rather
than special case complex ones. For example: A knight's charging attack could
be handled as a triggered ability that the knight get's a melee attack after
moving adjacent to an enemy, rather than having a special movement style ability
that target's an enemy, but has movement range and connectedness constraints.

Should there be range types too? Connected, any, passable, etc?

    Ability.TARGET_TYPE =
      SELF: 1 # The character itself, skips targetting step
      LOS: 2 # Any tile within character's line of sight and within range
      VISIBLE: 3 # Any tile visible to squad within range
      ANY: 4 # Any tile within range
      MOVEMENT: 5 # Visible, passable, connected

    Ability.COST_TYPE =
      FIXED: 1
      REST: 2

    module.exports = Ability
