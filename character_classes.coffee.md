Character Classes
=================

Exploring various character classes here.

    Names = require "./names"

    dataTransform = (data) ->
      extend data,
        healthMax: data.healthmax
        abilities: data.abilities.split(',')
        passives: data.passives.split(',')
        spriteName: data.sprite

      delete data.healthmax
      delete data.sprite

      return data

    characterDataFromRemote = (data) ->
      results = {}
      data.forEach (datum) ->
        results[name] = dataTransform(datum)

      return results

    module.exports =
      FireSlime:
        spriteName: "jelly"
        abilities: [
          "Move"
          "Melee"
        ]
        passives: [
          "Fireproof"
          "FireTrail"
        ]
        type: "Slime"

      AcidSlime:
        spriteName: "slime0"
        animation: ["slime0", "slime1", "slime2", "slime1"]
        abilities: [
          "Move"
          "Melee"
          "Blind"
          "Stun Gas"
        ]
        passives: [
          "Uncorrodible"
          "AcidTrail"
        ]
        type: "Slime"

      OilSlime:
        spriteName: "ooze"
        abilities: [
          "Move"
          "Melee"
          "Poison"
        ]
        passives: [
          "OilTrail"
        ]
        type: "Slime"

      ShrubMage:
        spriteName: "kobold"
        abilities: [
          "Move"
          "Entanglement"
          "ShrubSight"
          "MagicMissile"
        ]
        type: "Mage"

      "Earth Wizard":
        spriteName: "wizard"
        abilities: [
          "Move"
          "MagicMissile"
          "Stonesight"
          "Entomb"
        ]

      Harpy:
        spriteName: "harpy"
        abilities: [
          "Blink"
          "Melee"
        ]
        name: Names.monster.rand()

      Grunt:
        spriteName: "goblin"
        abilities: [
          "Move"
          "Melee"
          "Regeneration"
        ]

      Giant:
        spriteName: "hill_giant"
        movement: 3
        health: 5
        healthMax: 5
        name: Names.monster.rand()
        abilities: [
          "Move"
          "Stomp"
          "Berserk"
          "Demolish"
        ]
        passives: [
          "LeadFoot"
        ]
        sight: 5
        type: "Giant"

      Icedactyl:
        spriteName: "simulacrum_flying"
        type: "Ice"
        health: 5
        movement: 6
        abilities: [
          "Move"
          "Melee"
          # TODO: Ice Attack
        ]
        passives: [
          "Iceproof"
          # TODO: Fire Vulnerable
        ]

      Priest:
        health: 4
        spriteName: "dwarf"
        abilities: [
          "Move"
          "Melee"
          "Heal"
        ]
        type: "Mage"

      Knight:
        health: 4
        healthMax: 4
        spriteName: "human"

      Lich:
        health: 4
        healthMax: 4
        spriteName: "lich"
        sight: 0
        abilities: [
          "Blink"
          "Death"
        ]
        passives: [
          "Clairvoyance"
          "Undead"
        ]
        type: "Mage"

      Scout:
        actions: 3
        health: 2
        healthMax: 2
        spriteName: "thief"
        movement: 6
        sight: 9
        passives: [
          "EagleEye"
        ]

      Skeleton:
        sight: 5
        spriteName: "skeletal_warrior"
        passives: [
          "Undead"
        ]

      FrostMage:
        health: 2
        healthMax: 2
        spriteName: "ice_statue"
        abilities: [
          "Move"
          "MagicMissile"
          "IceWall"
        ]
        passives: [
          "Iceproof"
        ]
        type: "Mage"

      Wizard:
        health: 2
        healthMax: 2
        spriteName: "wizard"
        animation: ["wizard0", "wizard1"]
        abilities: [
          "Blink"
          "Fireball"
          "Farsight"
          "MagicMissile"
        ]
        type: "Mage"

      Archer:
        spriteName: "elf_archer"
        abilities: [
          "Move"
          "Ranged"
        ]
