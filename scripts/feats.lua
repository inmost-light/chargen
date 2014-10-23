local bonus = require 'bonus'
local __ = require 'moses'

local desc  = require 'description'
local add_desc = desc.add_desc

local B, TBL = bonus.def_bonus, bonus.level_table

local feats = {}

local function def_feat(name)
  return function(body)
    __.template(body, {
      bonus = {},
      prereq = function() return true end
    })
    add_desc(name)(body.desc)
    feats[name] = body
  end
end

def_feat 'Iron Will' {
  bonus = B 'none' { will = 2 },
  desc = [[You are more resistant to mental effects.

<b>Benefit</b>: You get a +2 bonus on all Will saving throws.]]
}

def_feat 'Great Fortitude' {
  bonus = B 'none' { fortitude = 2 },
  desc = [[You are resistant to poisons, diseases, and other maladies.

<b>Benefit</b>: You get a +2 bonus on all Fortitude saving throws.]]
}

def_feat 'Lightning Reflexes' {
  bonus = B 'none' { reflex = 2 },
  desc = [[You have faster reflexes than normal.

<b>Benefit</b>: You get a +2 bonus on all Reflex saving throws.]]
}

def_feat 'Power Attack' {
  prereq = function(cs)
    return cs:ability 'str' >= 13 and cs:bab() >= 1
  end,
  desc = [[You can make exceptionally deadly melee attacks by sacrificing accuracy for strength.

<b>Prerequisites</b>: Str 13, base attack bonus +1.

<b>Benefit</b>: You can choose to take a –1 penalty on all melee attack rolls and combat maneuver checks to gain a +2 bonus on all melee damage rolls. This bonus to damage is increased by half (+50%) if you are making an attack with a two-handed weapon, a one handed weapon using two hands, or a primary natural weapon that adds 1-1/2 times your Strength modifier on damage rolls. This bonus to damage is halved (–50%) if you are making an attack with an off-hand weapon or secondary natural weapon.

When your base attack bonus reaches +4, and every 4 points thereafter, the penalty increases by –1 and the bonus to damage increases by +2.

You must choose to use this feat before making an attack roll, and its effects last until your next turn. The bonus damage does not apply to touch attacks or effects that do not deal hit point damage.]]
}

def_feat 'Cleave' {
  prereq = function(cs)
    return cs:ability 'str' >= 13 and cs:bab() >= 1 and __.has(cs.feats, 'Power Attack')
  end,
  desc = [[You can strike two adjacent foes with a single swing.

<b>Prerequisites</b>: Str 13, Power Attack, base attack bonus +1.

<b>Benefit</b>: As a standard action, you can make a single attack at your full base attack bonus against a foe within reach. If you hit, you deal damage normally and can make an additional attack (using your full base attack bonus) against a foe that is adjacent to the first and also within reach. You can only make one additional attack per round with this feat. When you use this feat, you take a –2 penalty to your Armor Class until your next turn.]]
}

def_feat 'Toughness' {
  bonus = B 'none' { 
    hp = function(cs)
      return 3 + math.max(0, cs:level() - 3)
    end
  },
  desc = [[You have enhanced physical stamina.

<b>Benefit</b>: You gain +3 hit points. For every Hit Die you possess beyond 3, you gain an additional +1 hit point. If you have more than 3 Hit Dice, you gain +1 hit points whenever you gain a Hit Die (such as when you gain a level).]]
}

def_feat 'Scribe Scroll' {
  prereq = function(cs) return cs.class == 'Wizard' end,
  desc = [[You can create magic scrolls.

<b>Prerequisite</b>: Caster level 1st.

<b>Benefit</b>: You can create a scroll of any spell that you know. Scribing a scroll takes 2 hours if its base price is 250 gp or less, otherwise scribing a scroll takes 1 day for each 1,000 gp in its base price. To scribe a scroll, you must use up raw materials costing half of this base price.]]
}

return feats
