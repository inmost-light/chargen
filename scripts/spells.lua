local utils = require 'utils'

local desc  = require 'description'
local add_desc = desc.add_desc

function def_spell(name)
  return function(body)
    add_desc(name)(body.desc)
    return name
  end
end

local spells = {
  { -------------------------------------------------------------------------------- 0 level spells
    def_spell 'Resistance' {
      desc = [[You imbue the subject with magical energy that protects it from harm, granting it a +1 resistance bonus on saves.

Resistance can be made permanent with a permanency spell.School abjuration; Level bard 0, cleric/oracle 0, druid 0, inquisitor 0, paladin 1, sorcerer/wizard 0, summoner 0, witch 0

Casting Time 1 standard action
Components V, S, M/DF (a miniature cloak)

Range touch
Target creature touched
Duration 1 minute
Saving Throw Will negates (harmless); Spell Resistance yes (harmless)]]
    },

    def_spell 'Acid Splash' {
      desc = [[You fire a small orb of acid at the target. You must succeed on a ranged touch attack to hit your target. The orb deals 1d3 points of acid damage. This acid disappears after 1 round.School conjuration (creation) [acid]; Level inquisitor 0, magus 0, sorcerer/wizard 0, summoner 0, witch 0

Casting Time 1 standard action
Components V, S

Range close (25 ft. + 5 ft./2 levels)
Effect one missile of acid
Duration instantaneous
Saving Throw none; Spell Resistance no]]
    }
  },

  { -------------------------------------------------------------------------------- 1 level spells
    def_spell 'Mage Armor' {
      desc = [[An invisible but tangible field of force surrounds the subject of a mage armor spell, providing a +4 armor bonus to AC.

Unlike mundane armor, mage armor entails no armor check penalty, arcane spell failure chance, or speed reduction. Since mage armor is made of force, incorporeal creatures can't bypass it the way they do normal armor.

School conjuration (creation) [force]; Level bloodrager 1, sorcerer/wizard 1, summoner 1, witch 1

Casting Time 1 standard action
Components V, S, F (a piece of cured leather)

Range touch
Target creature touched
Duration 1 hour/level (D)
Saving Throw Will negates (harmless); Spell Resistance no]]
    },

    def_spell 'True Strike' {
      desc = [[You gain temporary, intuitive insight into the immediate future during your next attack. Your next single attack roll (if it is made before the end of the next round) gains a +20 insight bonus. Additionally, you are not affected by the miss chance that applies to attackers trying to strike a concealed target.

School divination; Level alchemist 1, bloodrager 1, inquisitor 1, magus 1, sorcerer/wizard 1; Domain destruction 1, luck 1

Casting Time 1 standard action
Components V, F (small wooden replica of an archery target)

Range personal
Target you
Duration see text]]
    },

    def_spell 'Sleep' {
      desc = [[A sleep spell causes a magical slumber to come upon 4 HD of creatures. Creatures with the fewest HD are affected first. Among creatures with equal HD, those who are closest to the spell's point of origin are affected first. HD that are not sufficient to affect a creature are wasted. Sleeping creatures are helpless. Slapping or wounding awakens an affected creature, but normal noise does not. Awakening a creature is a standard action (an application of the aid another action). Sleep does not target unconscious creatures, constructs, or undead creatures.

School enchantment (compulsion) [mind-affecting]; Level bard 1, sorcerer/wizard 1, witch 1; Domain Night 1

Casting Time 1 round
Components V, S, M (fine sand, rose petals, or a live cricket) 

Range medium (100 ft. + 10 ft./level)
Area one or more living creatures within a 10-ft.-radius burst
Duration 1 min./level
Saving Throw Will negates; Spell Resistance yes]]
    }
  },
  { -- 2 level spells
    def_spell 'Flaming Sphere' {
      desc = [[A burning globe of fire rolls in whichever direction you point and burns those it strikes. It moves 30 feet per round. As part of this movement, it can ascend or jump up to 30 feet to strike a target. If it enters a space with a creature, it stops moving for the round and deals 3d6 points of fire damage to that creature, though a successful Reflex save negates that damage. A flaming sphere rolls over barriers less than 4 feet tall. It ignites flammable substances it touches and illuminates the same area as a torch would.

The sphere moves as long as you actively direct it (a move action for you); otherwise, it merely stays at rest and burns. It can be extinguished by any means that would put out a normal fire of its size. The surface of the sphere has a spongy, yielding consistency and so does not cause damage except by its flame. It cannot push aside unwilling creatures or batter down large obstacles. A flaming sphere winks out if it exceeds the spell's range.

School evocation [fire]; Level bloodrager 2, druid 2, magus 2, sorcerer/wizard 2

Casting Time 1 standard action
Components V, S, M/DF (tallow, brimstone, and powdered iron)

Range medium (100 ft. + 10 ft./level)

Effect 5-ft.-diameter sphere
Duration 1 round/level
Saving Throw Reflex negates; Spell Resistance yes]]
    },

    def_spell 'Fireball' {
      desc = [[A fireball spell generates a searing explosion of flame that detonates with a low roar and deals 1d6 points of fire damage per caster level (maximum 10d6) to every creature within the area. Unattended objects also take this damage. The explosion creates almost no pressure.

You point your finger and determine the range (distance and height) at which the fireball is to burst. A glowing, pea-sized bead streaks from the pointing digit and, unless it impacts upon a material body or solid barrier prior to attaining the prescribed range, blossoms into the fireball at that point. An early impact results in an early detonation. If you attempt to send the bead through a narrow passage, such as through an arrow slit, you must "hit" the opening with a ranged touch attack, or else the bead strikes the barrier and detonates prematurely.

The fireball sets fire to combustibles and damages objects in the area. It can melt metals with low melting points, such as lead, gold, copper, silver, and bronze. If the damage caused to an interposing barrier shatters or breaks through it, the fireball may continue beyond the barrier if the area permits; otherwise it stops at the barrier just as any other spell effect does.

School evocation [fire]; Level bloodrager 3, magus 3, sorcerer/wizard 3; Domain fire 3

Casting Time 1 standard action
Components V, S, M (a ball of bat guano and sulfur)

Range long (400 ft. + 40 ft./level)
Area 20-ft.-radius spread
Duration instantaneous
Saving Throw Reflex half; Spell Resistance yes]]
    }
  },
}

return spells
