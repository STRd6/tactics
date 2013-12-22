Character Classes
=================

Exploring various character classes here.

    Names = require "./names"

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
        spriteName: "slime"
        abilities: [
          "Move"
          "Melee"
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
        ]
        type: "Mage"

      Harpy:
        spriteName: "harpy"
        abilities: [
          "Blink"
          "Melee"
        ]
        health: 3
        healthMax: 3
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
        ]
        sight: 5
        type: "Giant"

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

      Wizard:
        health: 2
        healthMax: 2
        spriteName: "wizard"
        animation: ["wizard0", "wizard1"]
        abilities: [
          "Blink"
          "Fireball"
          "Farsight"
        ]
        type: "Mage"

      Archer:
        spriteName: "elf_archer"
        abilities: [
          "Move"
          "Ranged"
        ]
