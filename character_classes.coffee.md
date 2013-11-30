Character Classes
=================

Exploring various character classes here.

    module.exports =
      ShrubMage:
        abilities: [
          "Entanglement"
        ]
        spriteName: "kobold"

      Grunt:
        abilities: [
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
          "Teleport"
        ]

      Archer:
        abilities: [
          "Ranged"
        ]
        spriteName: "elf_archer"
