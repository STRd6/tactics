Passives
========

Passives are abilities that are always in effect for a character.

They are similar to [Character Effects](./character_effect) but of a permanent
duration.

    module.exports = Passive = (I={}, self=Core(I)) ->

    Passive.Passives =
      Clairvoyance:
        visionEffect: "Clairvoyance"

      EagleEye:
        visionType: "magic"

TODO: Figure out creature type passives.

      Undead:
        immune: "Death"

      Fireproof:
        immune: "Fire"

      Iceproof:
        immune: "Ice"

      Uncorrodible:
        immune: "Acid"

      FireTrail:
        enter: "Flame"

      AcidTrail:
        enter: "Acid"

      OilTrail:
        enter: "Oil"

      LeadFoot:
        enter: "Crush"
