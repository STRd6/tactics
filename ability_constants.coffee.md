Ability Constants
=================

    module.exports = 
      TARGET_ZONE:
        SELF: 1 # The character itself, skips targetting step
        LINE_OF_SIGHT: 2 # Any tile within character's line of sight and within range
        VISIBLE: 3 # Any tile visible to squad within range
        MOVEMENT: 4 # Visible, passable, connected, movement penalties and bonuses apply
        ANY: 15 # Any tile within range

      COST_TYPE:
        FIXED: 1
        REST: 2
