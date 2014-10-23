describe('bonus builder', function()
  local bonus = require 'bonus'
  local B = bonus.def_bonus

  it('should construct bonus struct correctly', function()
    assert.are.same(
      {{ type = 'racial', attrib = 'str', adj = 1 }},
      B 'racial' { str = 1 }
    )
  end)
end)
