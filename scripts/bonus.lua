local __ = require 'moses'

local function def_bonus(bonus_type)
  return function(bonuses)
    local res = {}
    __.each(bonuses, function(attrib, adj)
      __.push(res, { type = bonus_type, attrib = attrib, adj = adj })
    end)
    return res
  end
end

local function level_table(values)
  return function(cs) return values[math.min(cs:level(), #values)] end
end

return {
  def_bonus   = def_bonus,
  level_table = level_table
}
