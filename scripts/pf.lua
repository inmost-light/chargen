package.path = package.path .. ';./scripts/?.lua'

require 'events'
local __              = require 'moses'
local utils           = require 'utils'
local dice            = require 'dice'
local abilities       = require 'abilities'
local character_sheet = require 'character_sheet'
local races           = require 'races'
local spells          = require 'spells'
local classes         = require 'classes'
local feats           = require 'feats'
local xp_table        = require 'xp_table'
local default_char    = require 'default_character'
local pretty_print    = require 'pretty_print'
--------------------------------------------------------------------------------
-- API -------------------------------------------------------------------------
--------------------------------------------------------------------------------
function roll()
  return utils.map_pairs(abilities, function(_, ability)
    return ability, dice.roll(3, 6)
  end)
end

function roll_view(roll_data)
  local view = __.map(abilities, function(_, ability)
    return 
      [[<span class="link" desc="]] .. ability .. [[">]] ..
      string.upper(ability) .. [[</span>]] ..
      ': ' ..
      roll_data[ability]
  end)
  return __.join(view, '<br/>')
end

function get_default_char()
  return __.clone(default_char)
end

function set_rolled_abilities(state, rolls)
  state.rolled_abilities = rolls;
  return state
end

function get_races()
  local race_names = __.keys(races)
  return __.sort(race_names)
end

function set_race(state, race_name)
  state.race = race_name
  return state
end

function get_classes()
  local class_names = __.keys(classes)
  return __.sort(class_names)
end

function set_class(state, class_name)
  state.class = class_name
  return state
end

function print_character_state(state)
  return pretty_print(state)
end

function check_if_human(state)
  return character_sheet(state):should_get_human_ability_bonus()
end

function get_abilities()
  return __.map(abilities, function(_, a) return string.upper(a) end)
end

function set_human_ability(state, ability)
  state.human_ability = string.lower(ability)
  return state
end

function number_of_feats(state)
  local cs = character_sheet(state)
  -- temporary
  return cs:feats_avaiable() + cs:fighter_feats() + cs:wizard_feats()
end

function number_of_spells(state)
  return character_sheet(state):wizard_spells()
end

function list_available_feats(state)
  local cs = character_sheet(state)
  local kv = __.zip(__.keys(feats), __.values(feats))
  return __(feats)
    :keys()
    :zip(__.values(feats))
    :filter(function(_, feat) 
              return not __.has(cs:known_feats(), feat[1]) and feat[2].prereq(cs) 
           end)
    :map(function(_, feat) return feat[1] end)
    :sort()
    :value()
end

function list_unavailable_feats(state)
  local cs = character_sheet(state)
  local kv = __.zip(__.keys(feats), __.values(feats))
  return __(feats)
    :keys()
    :zip(__.values(feats))
    :filter(function(_, feat) 
              return not __.has(cs:known_feats(), feat[1]) and not feat[2].prereq(cs) 
           end)
    :map(function(_, feat) return feat[1] end)
    :sort()
    :value()
end

function list_available_spells(state)
  local spells_per_day = character_sheet(state):spells_per_day()
  local max_spell_level = (__.find(spells_per_day, 0) or #spells_per_day) - 1
  local available_spells = __.take(spells, max_spell_level)
  return __(available_spells)
    :flatten(true)
    :filter(function(_, spell) return not __.find(state.spells, spell) end)
    :sort()
    :value()
end

function add_spell(state, spell_name)
  __.push(state.spells, spell_name)
  return state
end

function add_feat(state, feat_name)
  local rank = state.feats[feat_name] or 0
  state.feats[feat_name] = rank + 1
  return state
end

function roll_hp(state)
  return character_sheet(state):hp_gain()
end

function add_hp_roll(state, hp)
  __.push(state.hp_rolls, hp)
  return state
end

function advance_level(state)
  local lvl = character_sheet(state):level()
  state.xp = xp_table[math.min(#xp_table, lvl)]
  return state
end

function get_descriptions()
  local desc = require 'description'
  return desc.data
end

function at_max_level(state)
  return character_sheet(state):level() == #xp_table + 1
end

function random_seed(x)
  math.randomseed(x)
end
