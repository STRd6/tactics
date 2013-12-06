Character Classes
=================

Exploring various character classes here.

    module.exports =
      ShrubMage:
        abilities: [
          "Move"
          "Entanglement"
          "ShrubSight"
        ]
        spriteName: "kobold"

      Grunt:
        abilities: [
          "Move"
          "Melee"
          "Regeneration"
        ]
        spriteName: "goblin"

      Knight:
        health: 4
        healthMax: 4
        spriteName: "human"

      Wizard:
        health: 2
        healthMax: 2
        spriteName: "wizard"
        abilities: [
          "Blink"
          "Fireball"
          "Farsight"
        ]

      Archer:
        abilities: [
          "Move"
          "Ranged"
        ]
        spriteName: "elf_archer"
