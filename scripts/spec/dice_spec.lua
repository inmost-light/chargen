describe('dice', function()
  local dice = require 'dice'
  it('should work the same both for strings and numbers', function()
    for i = 1, 100 do
      math.randomseed(i)
      local x = dice.rolll '4d6'

      math.randomseed(i)
      local y = dice.roll(4, 6)

      assert.are.same(x, y)
    end
  end)

  it('should handle dX notation', function()
    for i = 1, 100 do
      math.randomseed(i)
      local x = dice.rolll 'd6'

      math.randomseed(i)
      local y = dice.roll(1, 6)

      assert.are.same(x, y)
    end
  end)

  it('should parse dice correctly', function()
    assert.are.same({2, 10}, {dice.parse '2d10'})
    assert.are.same({1, 8},  {dice.parse 'd8'})
  end)

  it('returns value in the correct range', function()
    for i = 1, 100 do
      local r = dice.roll(i, 6)
      assert.is_true(r >= i and r <= 6 * i)
    end
  end)
end)
