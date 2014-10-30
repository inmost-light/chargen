local utils = require 'utils'
local abilities = require 'abilities'

return {
  race          = 'Human',
  class         = 'Fighter',
  human_ability = 'str',
  xp            = 0,
  feats         = {},
  spells        = {},
  hp_rolls      = {},

  rolled_abilities = utils.map_pairs(abilities, function(_, ability)
    return ability, 10
  end),
}
