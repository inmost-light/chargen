describe('utils', function()
  local utils = require 'utils'

  it('should create new table using all the keys', function()
    local a = {1, a = 2}
    local b = utils.map_pairs(a, function(k, v)
      return 'a' .. k, 'b' .. v
    end)

    assert.are.same({ a1 = 'b1', aa = 'b2'}, b)
  end)

  it('should create new table using numeric keys', function()
    local a = {1, a = 2}
    local b = utils.map_ipairs(a, function(k, v)
      return 'a' .. k, 'b' .. v
    end)

    assert.are.same({ a1 = 'b1' }, b)
  end)

  it('path should create missing keys', function()
    local a = {}

    utils.path(a, 'b', 'c', 'd')
    assert.are.same({}, a.b.c.d)
    a.b.c.d.x = 123
    assert.are.same({x = 123}, utils.path(a, 'b', 'c', 'd'))
  end)

  it('try_path should return field if it exists', function()
    local t = { a = { b = {1,2,3} } }
    assert.are.same(2, utils.try_path(t, 'a', 'b', 2))
    assert.is.falsy(utils.try_path(t, 'a', 'b', 'c'))
  end)

  it('concat should concat arrays', function()
    assert.are.same({1,2,3,4,5}, utils.concat({1,2}, {3,4}, {5}))
  end)

  it('concat ignore nils', function()
    assert.are.same({1,2,3,4,5}, utils.concat({1,2}, nil, {3,4}, {5}))
  end)

  it('should sum empty list of vectors correctly', function()
    assert.are.same(
      {},
      utils.sum_vectors {}
    )
  end)
  it('should sum a list containing one vector correctly', function()
    assert.are.same(
      {1, 2, 3},
      utils.sum_vectors {{1, 2, 3}}
    )
  end)
  it('should sum vectors correctly', function()
    assert.are.same(
      {5, 7, 9},
      utils.sum_vectors {{1, 2, 3}, {4, 5, 6}}
    )
  end)
end)
