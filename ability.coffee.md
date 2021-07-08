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
  - Buffs
  - Debuffs

    {sqrt} = Math
    {binomial} = require "random"
    objectMap = require "./lib/object_map"
    # TODO: Shouldn't need to require this
    Effect = require "./effect"

    {COST_TYPE, TARGET_ZONE} = Constants = require "./ability_constants"

    Ability = (I={}, self=Core(I)) ->
      defaults I,
        range: 1
        actionCost: 1
        cooldown: 0
        name: "?"
        costType: COST_TYPE.FIXED

      self.attrAccessor(
        "actionCost"
        "actionType"
        "cooldown"
        "costType"
        "iconName"
        "name"
        "description"
        "range"
        "targetType"
        "targetZone"
      )

      self.extend
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

        compile: ->
          # TODO: Not too happy about passing binomial sqrt in like this, but
          # maybe it's the way to go. It should be encapsulated in some kind of
          # ENV wrapper if so.
          Function("sqrt", "binomial", CoffeeScript.compile """
            return ({animate, character, effect, feature, message, movementPath, owner, position, search}) ->
            #{indent I.code}
          """, bare: true)(sqrt, binomial)

        perform: (params) ->
          {owner} = params

          self.payCosts(owner)

          self.compile()(params)

          owner.resetTargetting()

      return self

Wherever possible we should reduce complexity and compose simpler actions rather
than special case complex ones. For example: A knight's charging attack could
be handled as a triggered ability that the knight get's a melee attack after
moving adjacent to an enemy, rather than having a special movement style ability
that target's an enemy, but has movement range and connectedness constraints.

    Ability.Abilities = objectMap(require("./abilities"), Ability)

    extend Ability, Constants

    module.exports = Ability

Helpers
-------

    indent = (text, indent="  ") ->
      text.replace(/^/gm, "#{indent}")
