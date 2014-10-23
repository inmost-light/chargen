describe('character sheet', function()
  local character_sheet = require 'character_sheet'
  local utils = require 'utils'
  local __    = require 'moses'
  local char

  local function test_levels(test)
    local old_level_func = char.level
    local res = __.map(__.range(1, 20), function(i)
      char.level = function() return i end
      return test(char)
    end)
    char.level = old_level_func
    return res
  end

  before_each(function()
    local default_character_state = require 'default_character'
    char = character_sheet(default_character_state)
  end)

  it('should update abilities correctly', function()
    local con = char:ability 'con'
    char.race = 'Dwarf'
    assert.are.equal(con + 2, char:ability 'con')
  end)

  it('should update modifiers correctly', function()
    local con = char:modifier 'con'
    char.race = 'Dwarf'
    assert.are.equal(con + 1, char:modifier 'con')
  end)

  it('should handle human ability bonus correctly', function()
    local con = char:ability 'con'
    char.race = 'Human'
    assert.are.equal(con, char:ability 'con')
    char.human_ability = 'con'
    assert.are.equal(con + 2, char:ability 'con')
  end)

  it('should handle human bonus feats correctly', function()
    char.race = 'Human'
    assert.are.equal(2, char:feats_avaiable())
  end)

  it('should update base speed correctly', function()
    char.race = 'Dwarf'
    assert.are.equal(20, char:base_speed())
    char.race = 'Human'
    assert.are.equal(30, char:base_speed())
  end)

  it("should apply dwarf's dodge bonus correctly", function()
    local utils = require 'utils'

    local ac = char:ac()

    char.race = 'Dwarf'
    utils.path(char, 'under_attack', 'enemy').kind = utils.set { 'giant' }

    assert.are.equal(ac + 2, char:ac())
  end)

  it('should give fighters extra combat feats at first and even levels', function()
    char.class = 'Fighter'
    assert.are.same(
      {1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1},
      test_levels(function() return char:fighter_feats() end)
    )
  end)

  it('should calculate level correctly', function()
    assert.are.equal(1, char:level())
    char.xp = 2000
    assert.are.equal(2, char:level())
    char.xp = 1700000
    assert.are.equal(19, char:level())
    char.xp = 99999999
    assert.are.equal(20, char:level())
  end)
  
  it('should give fighters bravery bonus to will saves', function()
    char.class = 'Fighter'

    assert.are.equal(0, char:bonus 'will')

    char.xp = 1300
    assert.are.equal(1, char:bonus 'will')

    char.xp = 3300
    assert.are.equal(2, char:bonus 'will')
  end)

  it('should handle basic feats correctly', function()
    local w, f, r = char:bonus 'will', char:bonus 'fortitude', char:bonus 'reflex'
    char.feats = utils.feats_set { 'Iron Will', 'Great Fortitude', 'Lightning Reflexes' }
    assert.are.equal(w + 2, char:bonus 'will')
    assert.are.equal(f + 2, char:bonus 'fortitude')
    assert.are.equal(r + 2, char:bonus 'reflex')
  end)

  it('should apply Toughness bonuses correctly', function()
    char.feats = utils.feats_set { 'Toughness' }
    assert.are.equal(3, char:bonus 'hp')
    char.xp = 10000
    assert.are.equal(3 + 2, char:bonus 'hp')
  end)

  it('should check feats prereqs', function()
    local feats = require 'feats'

    char.rolled_abilities.str = 10;
    assert.is_falsy(feats['Power Attack'].prereq(char))
    char.rolled_abilities.str = 13
    char.class = 'Fighter'
    assert.is_true(feats['Power Attack'].prereq(char))

    assert.is_falsy(feats['Cleave'].prereq(char))
    char.feats = utils.feats_set { 'Power Attack' }
    assert.is_not_falsy(feats['Cleave'].prereq(char))
  end)

  it('should calculate hit die correctly', function()
    char.class = 'Fighter'
    assert.are.equal(10, char:hit_die())
  end)

  it('should calculate hp gain correctly', function()
    char.class = 'Fighter'
    assert.are.equal(10, char:hp_gain())
    local dice = require 'dice'
    char.xp = 10000
    for i = 1, 1000 do
      local gain = char:hp_gain()
      assert.is_true(gain >= 1 and gain <= 10)
    end
  end)

  it([[should calculate fighter's weapon profs correclty]], function()
    char.class = 'Fighter'
    assert.are.same(
      utils.set {'simple', 'martial'},
      char:weapon_prof()
    )
  end)

  it([[should calculate fighter's armor profs correctly]], function()
    char.class = 'Fighter'
    assert.are.same(
      utils.set {'light', 'medium', 'heavy'},
      char:armor_prof()
    )
  end)

  it('should calculate spells per day correctly', function()
    char.class = 'Wizard'
    assert.are.same(
      {3, 1, 0, 0, 0, 0, 0, 0, 0, 0},
      char:spells_per_day()
    )
  end)

  it([[should give wizards 'Scribe Scroll' feat]], function()
    local feats = require 'feats'
    char.class = 'Wizard'
    assert.is_true(feats['Scribe Scroll'].prereq(char))
    assert.is.truthy(char:known_feats()['Scribe Scroll'])
  end)

  it([[should give wizards 2 spells on level-up]], function()
    char.class = 'Fighter'
    assert.are.same(0, char:wizard_spells())
    char.class = 'Wizard'
    assert.are.same(2, char:wizard_spells())
  end)
end)
