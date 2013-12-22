    Constants = require "./ability_constants"

    {SELF, MOVEMENT, LINE_OF_SIGHT, ANY} =  Constants.TARGET_ZONE
    {REST, FIXED} = Constants.COST_TYPE

    {sqrt} = Math

    module.exports =
      Move:
        name: "Move"
        description: "Old boot-y. Hoof it to your next position."
        iconName: "boots"
        actionCost: 1
        targetZone: MOVEMENT
        code: '''
          owner.addEffect
            name: "moving"
            attribute: "physicalAwareness"
            amount: -100
            duration: 1

          # Need to reverse because the effects go on a stack.
          positions = movementPath.copy().reverse()

          positions.forEach (position, i) ->
            to = position
            from = positions[i+1]

            if to and from
              effect "Move", from, to, owner
        '''

      Teleport:
        name: "Teleport"
        description: "Magically appear in a far away location."
        iconName: "teleport"
        actionCost: 2
        range: 50
        targetZone: ANY
        code: '''
          effect "Move", owner.position(), position

          if character
            owner.I.health = 0
            character.I.health = 0

            message "#{owner.name()} teleports into #{character.name()}. There are no survivors."
        '''

      Blink:
        name: "Blink"
        description: "Move somewhere you can see in the blink of an eye."
        iconName: "blink"
        actionCost: 1
        range: 8
        targetZone: LINE_OF_SIGHT
        code: '''
          effect "Move", owner.position(), position

          if character
            owner.I.health = 0
            character.I.health = 0

            message "#{owner.name()} teleports into #{character.name()}."
            message "Life ends in the blink of an eye."
        '''

      Death:
        name: "Death"
        description: "It's probably Ebola. Be careful."
        iconName: "black_cloud"
        actionCost: 2
        range: 8
        targetZone: ANY
        code: '''
          effect "PestilentVapor", position
        '''

      Farsight:
        name: "Farsight"
        description: "Use your mind's eye to visualize lands you've never seen."
        iconName: "farsight"
        actionCost: 1
        range: 16
        targetZone: ANY
        code: '''
          animate
            message: "#{owner.name()}'s wizard eyes see all!"
            position: position
            duration: 2000

          search.adjacent(position, 1 + sqrt(2)).forEach (position) ->
            owner.addMagicalVision(position)
        '''

      Melee:
        name: "Attack"
        description: "Hit enemies with it until they die."
        iconName: "sword"
        range: sqrt(2)
        actionCost: 1
        costType: REST
        targetZone: LINE_OF_SIGHT
        code: '''
          if character
            amount = binomial(owner.strength()) + 1
            character.damage amount

            message "#{owner.name()} strikes #{character.name()} for #{amount}"
        '''

      Ranged:
        name: "Attack"
        description: "Nice for those who don't like to get their hands dirty."
        iconName: "longbow"
        range: 7
        actionCost: 1
        costType: REST
        targetZone: LINE_OF_SIGHT
        code: '''
          if character
            amount = binomial(owner.strength())
            character.damage amount

            message "#{owner.name()} strikes #{character.name()} for #{amount}"
        '''

      Berserk:
        name: "Berserk"
        description: "My hate for you is ticking clock."
        iconName: "sword"
        range: sqrt(2)
        actionCost: 1
        targetZone: LINE_OF_SIGHT
        code: '''
          if character
            amount = binomial(owner.strength()) + 1
            character.damage amount

            message "#{owner.name()} strikes #{character.name()} for #{amount}"
        '''

      Blind:
        name: "Blind"
        description: "Use this when your enemies are too good at seeing you."
        iconName: "blind"
        range: 8
        actionCost: 1
        costType: REST
        targetZone: LINE_OF_SIGHT
        code: '''
          if character
            character.addEffect
              name: "blindness"
              attribute: "sight"
              amount: -100
              duration: 3
        '''

      Regeneration:
        name: "Regeneration"
        description: "Those who regenerate today live to fight another day."
        iconName: "regeneration"
        actionCost: 1
        costType: REST
        targetZone: SELF
        code: '''
          amount = 1
          owner.heal(amount)
          message "#{owner.name()} regenerates #{amount} health."
        '''

      Entanglement:
        name: "Entanglement"
        description: "It's like the times you used to pick blackberries as a kid."
        iconName: "bush0"
        range: 7
        actionCost: 2
        cooldown: 3
        costType: REST
        targetZone: LINE_OF_SIGHT
        code: '''
          search.adjacent(position, 1 + sqrt(2)).forEach (position) ->
            effect "Plant", position
        '''

      Stomp:
        name: "Stomp"
        description: "Destroy everything around you."
        iconName: "stomp"
        range: 1
        actionCost: 2
        cooldown: 2
        targetZone: SELF
        code: '''
          effect "Stomp", position, owner
        '''

      Fireball:
        name: "Fireball"
        description: "Immolated ball of death. Watch out for dry brush."
        iconName: "fireball"
        range: 7
        actionCost: 2
        cooldown: 3
        costType: REST
        targetZone: LINE_OF_SIGHT
        code: '''
          search.adjacent(position, 1 + sqrt(2)).forEach (position) ->
            effect "Fire", position
        '''

      ShrubSight:
        name: "ShrubSight"
        description: "Somehow you know where all the plants are."
        iconName: "bush1"
        actionCost: 1
        cooldown: 3
        targetZone: SELF
        code: '''
          effect "ShrubSight", position, owner
        '''

      Wait:
        name: "Wait"
        description: "Do this if you don't have any other good moves."
        iconName: "hourglass"
        actionCost: 0
        costType: REST
        targetZone: SELF
        code: '''
        '''
