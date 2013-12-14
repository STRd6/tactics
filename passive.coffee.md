Passives
========

Passives are abilities that are always in effect for a character.

    module.exports = Passive = (I={}, self=Core(I)) ->

    Passive.Passives =
      Clairvoyance:
        enter: "Clairvoyance"

      EagleEye:
        visionType: "magic"

TODO: Figure out creature type passives.

      Undead:
        immune: "Death"
