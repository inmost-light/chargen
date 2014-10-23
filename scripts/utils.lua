local __ = require 'moses'

local utils = {}

function utils.sum(lst)
  return __.foldl(lst, function(x, y) return x + y end, 0)
end

local function map_pairs_impl(iter_func, container, func)
  local res = {}
  iter_func(container, function(k, v)
    local kk, vv = func(k, v)
    res[kk] = vv
  end)
  return res
end

function utils.map_pairs(container, func)
  return map_pairs_impl(__.each, container, func)
end

function utils.map_ipairs(container, func)
  return map_pairs_impl(__.eachi, container, func)
end

function utils.set(a)
  return __(a)
    :invert()
    :map(function() return true end)
    :value()
end

function utils.feats_set(feats)
  return __.map(utils.set(feats), function() return 1 end)
end

function utils.path(tbl, ...)
  assert(tbl, 'utils.path: the actual table must be not nil')
  local t = tbl
  __.each({...}, function(_, key)
    t[key] = t[key] or {}
    t = t[key]
  end)
  return t
end

function utils.try_path(tbl, ...)
  assert(tbl, 'utils.path: the actual table must be not nil')
  local t = tbl
  for _, key in ipairs {...} do
    t = t[key]
    if not t then return nil end
  end
  return t
end

function utils.flatten(tbl)
  return __.flatten(tbl, true)
end

function utils.concat(...)
  local res = {}
  __.each({...}, function(_, tbl)
    __.each(tbl, function(_, value)
      __.push(res, value)
    end)
  end)
  return res
end

function utils.sum_vectors(vs)
  return __.foldl(vs, function(acc, vec)
    return __.map(__.zip(vec, acc), function (_, pair) 
      return pair[1] + (pair[2] or 0)
    end)
  end, {})
end

return utils
