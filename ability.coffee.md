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

  - Overwatch
  - Heal
  - Dig
  - Teleport
  - Buffs
  - Debuffs

    {sqrt} = Math
    Search = require "./map_search"
    Effect = require "./effect"

    # TODO we don't have tileAt, so we can't do all searches
    search = Search()

    Ability = (I={}, self=Core(I)) ->
      Object.defaults I,
        range: 1
        actionCost: 1
        cooldown: 0
        name: "?"
        costType: Ability.COST_TYPE.FIXED

      self.attrAccessor(
        "actionCost"
        "actionType"
        "cooldown"
        "costType"
        "iconName"
        "name"
        "range"
        "targetType"
        "targetZone"
      )

      Object.extend self,
        canPay: (owner) ->
          (owner.actions() >= self.actionCost()) and
          (owner.cooldown(self) is 0)

        payCosts: (owner) ->
          owner.setCooldown(self)

          switch self.costType()
            when COST_TYPE.REST
              owner.actions(0)
            when COST_TYPE.FIXED
              owner.actions owner.actions() - self.actionCost()
            else
              throw "Unknown action cost type"

        validTargets: (owner, tileAt) ->

        perform: (owner, target) ->
          self.payCosts(owner)

          # TODO: Not sure if this should be on I
          I.perform(owner, target)

          owner.resetTargetting()

      return self

Wherever possible we should reduce complexity and compose simpler actions rather
than special case complex ones. For example: A knight's charging attack could
be handled as a triggered ability that the knight get's a melee attack after
moving adjacent to an enemy, rather than having a special movement style ability
that target's an enemy, but has movement range and connectedness constraints.

Should there be range types too? Connected, any, passable, etc?

    {SELF, MOVEMENT, LINE_OF_SIGHT} = Ability.TARGET_ZONE = TARGET_ZONE =
      SELF: 1 # The character itself, skips targetting step
      LINE_OF_SIGHT: 2 # Any tile within character's line of sight and within range
      VISIBLE: 3 # Any tile visible to squad within range
      MOVEMENT: 4 # Visible, passable, connected, movement penalties and bonuses apply
      ANY: 15 # Any tile within range

    Ability.TARGET_TYPE = TARGET_TYPE =
      FRIENDLY: 1
      ENEMY: 2
      OPEN: 3
      WALL: 4
      ANY: 15

    {FIXED, REST} = Ability.COST_TYPE = COST_TYPE =
      FIXED: 1
      REST: 2

    Ability.Abilities =
      Move: Ability
        name: "Move"
        iconName: "boots"
        actionCost: 1
        targetZone: MOVEMENT
        perform: (owner, {position}) ->
          owner.updatePosition position

      Melee: Ability
        name: "Attack"
        iconName: "sword"
        range: sqrt(2)
        actionCost: 1
        costType: REST
        targetZone: LINE_OF_SIGHT
        perform: (owner, {position, character}) ->
          if character
            character.damage 1

      Ranged: Ability
        name: "Attack"
        iconName: "longbow"
        range: 6
        actionCost: 1
        costType: REST
        targetZone: LINE_OF_SIGHT
        perform: (owner, {position, character}) ->
          if character
            character.damage 1

      Regeneration: Ability
        name: "Regeneration"
        iconName: "regeneration"
        actionCost: 1
        costType: REST
        targetZone: SELF
        perform: (owner) ->
          owner.heal(1)

      Fireball: Ability
        name: "Fireball"
        iconName: "fireball"
        range: 7
        actionCost: 2
        cooldown: 3
        costType: COST_TYPE.REST
        targetZone: TARGET_ZONE.LINE_OF_SIGHT
        perform: (owner, {position, addEffect}) ->
          search.adjacent(position, 1 + sqrt(2)).forEach (position) ->
            addEffect(Effect(), position)

      Wait: Ability
        name: "Wait"
        iconName: "hourglass"
        actionCost: 1
        costType: COST_TYPE.REST
        targetZone: TARGET_ZONE.SELF
        perform: ->

      Cancel: Ability
        name: "Cancel"
        actionCost: 0
        targetZone: TARGET_ZONE.SELF
        perform: (owner, {position, character}) ->
          owner.targettingAbility null

    module.exports = Ability
