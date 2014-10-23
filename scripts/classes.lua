local bonus = require 'bonus'
local utils = require 'utils'

local desc  = require 'description'
local add_desc = desc.add_desc

local B, TBL = bonus.def_bonus, bonus.level_table

local classes = {}

local function def_class(name)
  return function(body)
    classes[name] = body 
    add_desc(name)(body.desc)
  end
end

def_class 'Fighter' {
  hit_die = 'd10',

  bonus = utils.flatten {
    B 'none' {
      -- bravery
      will = function(cs)
        return math.min(5, math.floor((cs:level() + 2) / 4))
      end
    },
    B 'none' {
      bab = function(cs) return cs:level() end,
      fortitude = function(cs) return math.floor((cs:level() + 2) / 2) + 1 end,
      reflex = TBL {0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5, 5, 6, 6, 6},
      will   = TBL {0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5, 5, 6, 6, 6},
      fighter_feats  = function(cs) 
        local lvl = cs:level()
        return (lvl == 1 or lvl % 2 == 0) and 1 or 0
      end,

      weapon_prof = {'simple', 'martial'},
      armor_prof  = {'light', 'medium', 'heavy'},

      armor_training = function(cs) 
        return math.min(4, math.floor((cs:level() + 1) / 4))
      end,

      weapon_training = function(cs) 
        return math.min(4, math.floor((cs:level() + 3) / 4) - 1)
      end,
    },
  },
  desc = [[Fighters excel at combat - defeating their enemies, controlling the flow of battle, and surviving such sorties themselves. While their specific weapons and methods grant them a wide variety of tactics, few can match fighters for sheer battle prowess.

Hit Die: d10.

Weapon and Armor Proficiency
A fighter is proficient with all simple and martial weapons and with all armor (heavy, light, and medium) and shields (including tower shields).

Bonus Feats
At 1st level, and at every even level thereafter, a fighter gains a bonus feat in addition to those gained from normal advancement (meaning that the fighter gains a feat at every level). These bonus feats must be selected from those listed as Combat Feats, sometimes also called “fighter bonus feats.”

Bravery (Ex)
Starting at 2nd level, a fighter gains a +1 bonus on Will saves against fear. This bonus increases by +1 for every four levels beyond 2nd.

Armor Training (Ex)
Starting at 3rd level, a fighter learns to be more maneuverable while wearing armor. Whenever he is wearing armor, he reduces the armor check penalty by 1 (to a minimum of 0) and increases the maximum Dexterity bonus allowed by his armor by 1. Every four levels thereafter (7th, 11th, and 15th), these bonuses increase by +1 each time, to a maximum –4 reduction of the armor check penalty and a +4 increase of the maximum Dexterity bonus allowed.
In addition, a fighter can also move at his normal speed while wearing medium armor. At 7th level, a fighter can move at his normal speed while wearing heavy armor.

Armor Mastery (Ex)
At 19th level, a fighter gains Damage Reduction 5/ - whenever he is wearing armor or using a shield.

Weapon Mastery (Ex)
At 20th level, a fighter chooses one weapon, such as the longsword, greataxe, or longbow. Any attacks made with that weapon automatically confirm all critical threats and have their damage multiplier increased by 1 (×2 becomes ×3, for example). In addition, he cannot be disarmed while wielding a weapon of this type.]]
}

def_class 'Wizard' {
  hit_die = 'd6',
  feats = utils.feats_set { 'Scribe Scroll' },
  bonus = B 'none' {
    bab       = function(cs) return math.floor(cs:level() / 2) end,
    fortitude = function(cs) return math.floor(cs:level() / 3) end,
    reflex    = function(cs) return math.floor(cs:level() / 3) end,
    will      = function(cs) return math.floor(cs:level() / 2) + 2 end,
    wizard_feats = function(cs) return cs:level() % 5 == 0 and 1 or 0 end,
    weapon_prof = { 'club', 'dagger', 'heavy crossbow', 'light crossbow', 'quarterstaff' },
    spells_per_day = TBL {
      {3, 1, 0, 0, 0, 0, 0, 0, 0, 0}, -- 1
      {4, 2, 0, 0, 0, 0, 0, 0, 0, 0}, -- 2
      {4, 2, 1, 0, 0, 0, 0, 0, 0, 0}, -- 3
      {4, 3, 2, 0, 0, 0, 0, 0, 0, 0}, -- 4
      {4, 3, 2, 1, 0, 0, 0, 0, 0, 0}, -- 5
      {4, 3, 3, 2, 0, 0, 0, 0, 0, 0}, -- 6
      {4, 4, 3, 2, 1, 0, 0, 0, 0, 0}, -- 7
      {4, 4, 3, 3, 2, 0, 0, 0, 0, 0}, -- 8
      {4, 4, 4, 3, 2, 1, 0, 0, 0, 0}, -- 9
      {4, 4, 4, 3, 3, 2, 0, 0, 0, 0}, -- 10
      {4, 4, 4, 4, 3, 2, 1, 0, 0, 0}, -- 11
      {4, 4, 4, 4, 3, 3, 2, 0, 0, 0}, -- 12
      {4, 4, 4, 4, 4, 3, 2, 1, 0, 0}, -- 13
      {4, 4, 4, 4, 4, 3, 3, 2, 0, 0}, -- 14
      {4, 4, 4, 4, 4, 4, 3, 2, 1, 0}, -- 15
      {4, 4, 4, 4, 4, 4, 3, 3, 2, 0}, -- 16
      {4, 4, 4, 4, 4, 4, 4, 3, 2, 1}, -- 17
      {4, 4, 4, 4, 4, 4, 4, 3, 3, 2}, -- 18
      {4, 4, 4, 4, 4, 4, 4, 4, 3, 3}, -- 19
      {4, 4, 4, 4, 4, 4, 4, 4, 4, 4}, -- 20
    },
  },
  desc = [[While universalist wizards might study to prepare themselves for any manner of danger, specialist wizards research schools of magic that make them exceptionally skilled within a specific focus. Yet no matter their specialty, all wizards are masters of the impossible and can aid their allies in overcoming any danger.

Hit Die: d6

Weapon and Armor Proficiency
Wizards are proficient with the club, dagger, heavy crossbow, light crossbow, and quarterstaff, but not with any type of armor or shield. Armor interferes with a wizard's movements, which can cause his spells with somatic components to fail.

Spells
A wizard casts arcane spells drawn from the sorcerer/wizard spell list. A wizard must choose and prepare his spells ahead of time.

Scribe Scroll
At 1st level, a wizard gains Scribe Scroll as a bonus feat.

Bonus Feats
At 5th, 10th, 15th, and 20th level, a wizard gains a bonus feat. At each such opportunity, he can choose a metamagic feat, an item creation, or Spell Mastery. The wizard must still meet all prerequisites for a bonus feat, including caster level minimums. These bonus feats are in addition to the feats that a character of any class gets from advancing levels. The wizard is not limited to the categories of Item Creation Feats, Metamagic Feats, or Spell Mastery when choosing those feats.]]
}

return classes
