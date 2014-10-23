local __ = require 'moses'
local utils = require 'utils'

local function roll(rolls_count, sides)
  local rolls = __.map(__.rep(1, rolls_count), function() return math.random(sides) end)
  return utils.sum(rolls), rolls
end

local function parse(str)
  local rolls, sides = string.match(str, '(%d*)d(%d+)')
  return tonumber(rolls) or 1, tonumber(sides)
end

local function rolll(str)
  return roll(parse(str))
end

return {
  roll  = roll,
  parse = parse,
  rolll = rolll,
}
