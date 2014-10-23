local __        = require 'moses'
local utils     = require 'utils'
local abilities = require 'abilities'
local dice      = require 'dice'
local races     = require 'races'
local classes   = require 'classes'
local feats     = require 'feats'
local xp_table  = require 'xp_table'
local bonus     = require 'bonus'
local B = bonus.def_bonus

local set_functions = {
  sum = utils.flatten,
  merge = __.compose(utils.set, utils.flatten)
}

local vector_functions = {
  sum = utils.sum_vectors,
  merge = utils.sum_vectors
}

local bonus_functions = {
  weapon_prof = set_functions,
  armor_prof  = set_functions,
  spells_per_day = vector_functions,
  
  __index = function()
    return {
      max = __.max,
      sum = utils.sum,
      merge = utils.sum
    }
  end
}
setmetatable(bonus_functions, bonus_functions)

local bonus_stacking = {
  racial = 'sum',
  none   = 'sum',
  __index = function() return 'max' end
}
setmetatable(bonus_stacking, bonus_stacking)

--------------------------------------------------------------------------------
return function(character_state)
  local char = __.clone(character_state)

  local _P  = utils.path
  local _TP = utils.try_path

  function char:human_bonus()
    return B 'racial' {
      [self.human_ability] = _TP(races, self.race, 'human_ability_bonus') or 0 
    }
  end

  function char:should_get_human_ability_bonus()
    return __.has(races[self.race], 'human_ability_bonus')
  end

  function char:feats_avaiable()
    return (self:level() == 1 and 1 or 0) + self:bonus 'feats'
  end

  function char:known_feats()
    return __.extend({}, self.feats, _TP(classes, self.class, 'feats'))
  end

  function char:bonuses()
    local bonuses = {}

    local bonuses_from_feats = utils.flatten(
      __(self:known_feats())
        :map(function(feat) return feats[feat].bonus end)
        :values()
        :value()
    )

    local bonus_structs = utils.concat(
      _TP(races, self.race, 'bonus'),
      _TP(races, self.race, 'level_bonus', self:level()),
      _TP(classes, self.class, 'bonus'),
      _TP(classes, self.class, 'level_bonus', self:level()),
      bonuses_from_feats,
      self:human_bonus()
    )

    __.each(bonus_structs, function(_, bonus)
      local val = type(bonus.adj) == 'function' and bonus.adj(self) or bonus.adj
      __.push(_P(bonuses, bonus.attrib, bonus.type), val)
    end)
    
    return bonuses
  end
  
  function char:bonus(param)
    local bonuses = self:bonuses()
    local cfg = bonus_functions[param]

    return cfg.merge(__.map(bonuses[param] or {}, function(bonus_type, bs)
      return cfg[bonus_stacking[bonus_type]](bs)
    end))
  end

  function char:ability(ability)
    return self.rolled_abilities[ability] + self:bonus(ability)
  end

  function char:modifier(ability)
    return -5 + math.floor(self:ability(ability) / 2)
  end

  function char:base_speed() return _TP(races, self.race, 'base_speed') or 0 end

  function char:ac() return 10 + self:bonus 'ac' end

  function char:level()
    local lvl = __.detect(xp_table, function(xp) return self.xp < xp end)
    return lvl or #xp_table + 1
  end

  function char:bab() return self:bonus 'bab' + self:modifier 'str' end

  function char:hit_die()
    local hd_str = _TP(classes, self.class, 'hit_die')
    local _, hd = dice.parse(hd_str)
    return hd
  end
  
  function char:hp_gain()
    return (self:level() == 1 and self:hit_die()) or dice.roll(1, self:hit_die())
  end

  function char:max_hp()
    return utils.sum(self.hp_rolls)
  end

  function char:fortitude() return self:modifier 'con' + self:bonus 'fortitude' end
  function char:reflex()    return self:modifier 'dex' + self:bonus 'reflex'    end
  function char:will()      return self:modifier 'wis' + self:bonus 'will'      end

  function char:weapon_prof() return self:bonus 'weapon_prof' end
  function char:armor_prof()  return self:bonus 'armor_prof' end

  function char:spells_per_day() return self:bonus 'spells_per_day' end

  function char:fighter_feats() return self:bonus 'fighter_feats' end
  function char:wizard_feats()  return self:bonus 'wizard_feats'  end
  function char:wizard_spells() return self.class == 'Wizard' and 2 or 0 end

  return char
end
