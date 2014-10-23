local utils = require 'utils'
local __    = require 'moses'
local bonus  = require 'bonus'

local desc  = require 'description'
local add_desc = desc.add_desc

local B, TBL = bonus.def_bonus, bonus.level_table

local races = {}

local function def_race(name)
  return function(body)
    body.bonus = body.bonus or {}
    body.level_bonus = body.level_bonus or {}
    races[name] = body 
    add_desc(name)(body.desc)
  end
end

def_race 'Dwarf' {
  base_speed = 20,

  bonus = utils.flatten {
    B 'racial' { 
      cha = -2, 
      con = 2, 
      wis = 2, 
      weapon_prof = { 'battleaxe', 'heavy pick', 'warhammer' },
    },
    B 'dodge' {
      ac = function(cs) 
        return 
          cs.under_attack and 
          cs.under_attack.enemy.kind.giant and 2 
          or 0
      end,
    }
  },
  desc = [[Dwarves are both tough and wise, but also a bit gruff. They gain +2 Constitution, +2 Wisdom, and –2 Charisma.
Dwarves are Medium creatures and thus receive no bonuses or penalties due to their size.
Dwarves have a base speed of 20 feet, but their speed is never modified by armor or encumbrance.
Dwarves gain a +4 dodge bonus to AC against monsters of the giant subtype.
Dwarves gain a +2 racial bonus on saving throws against poison, spells, and spell-like abilities.
Dwarves gain a +4 racial bonus to their Combat Maneuver Defense when resisting a bull rush or trip attempt while standing on the ground.]]
}

def_race 'Human' {
  human_ability_bonus = 2,
  base_speed = 30,
  level_bonus = {
    B 'racial' { feats = 1 } -- 1
  },
  desc = [[Human characters gain a +2 racial bonus to one ability score of their choice at creation to represent their varied nature.
Humans are Medium creatures and thus receive no bonuses or penalties due to their size.
Humans have a base speed of 30 feet.
Humans select one extra feat at 1st level.]]
}

def_race 'Elf' {
  bonus = B 'racial' { 
    dex = 2, 
    int = 2, 
    con = -2, 
    weapon_prof = { 'longbow', 'longsword', 'rapier', 'shortbow' }
  },
  base_speed = 30,
  desc = [[Elves are nimble, both in body and mind, but their form is frail. They gain +2 Dexterity, +2 Intelligence, and –2 Constitution.
Elves are Medium creatures and thus receive no bonuses or penalties due to their size.
Elves are Humanoids with the elf subtype.
Elves have a base speed of 30 feet.
Elves are immune to magic sleep effects and gain a +2 racial saving throw bonus against enchantment spells and effects.
Elves receive a +2 racial bonus on caster level checks made to overcome spell resistance. In addition, elves receive a +2 racial bonus on Spellcraft skill checks made to identify the properties of magic items.
Elves are proficient with longbows (including composite longbows), longswords, rapiers, and shortbows (including composite shortbows), and treat any weapon with the word “elven” in its name as a martial weapon.]]
}

return races

