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

  - Ranged Attacks
  - Melee Attacks
  - Heal
  - Dig
  - Fireball
  - Buffs
  - Debuffs

    Ability = (I={}, self=Core(I)) ->
      Object.defaults I,
        range: 1
        actionCost: 1
        name: "Strike"
        costType: Ability.COST_TYPE.REST

    Ability.TARGET_TYPE =
      SELF: 1
      LOS: 2
      VISIBLE: 3
      ANY: 4

    Ability.COST_TYPE =
      FIXED: 1
      REST: 2

    module.exports = Ability
