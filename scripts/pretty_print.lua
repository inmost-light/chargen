local character_sheet = require 'character_sheet'
local abilities       = require 'abilities'
local __              = require 'moses'

local function span(desc)
  return '<span class="link" desc="' .. desc:lower() .. '">' .. desc .. '</span>'
end

return function(character_state)
  local char = character_sheet(character_state)
  local abs = __(abilities)
    :map(function(_, name)
           return string.format(span('%s') .. ': %2d [%+2d]', name:lower(), name:upper(), char:ability(name), char:modifier(name))
        end)
    :append {
      string.format('Race: %s / ' .. span('Class') .. ': %s / ' .. span('Level') .. ': %d', char.race, char.class, char:level()),
      span('XP') .. ': ' .. char.xp,
      string.format(span('HP') .. ': %d / ' .. span('AC') .. ': %d / ' .. span('BAB') .. ': %d', char:max_hp(), char:ac(), char:bab()),
      string.format(span('Saves') .. ': ' .. span('Fortitude') .. ': %d / ' .. span('Reflex') .. ': %d / ' .. span('Will') .. ': %d', char:fortitude(), char:reflex(), char:will()),
      'Feats: ' .. __(char:known_feats()):keys():map(function(_,f) return span(f) end):sort():join(', '):value(),
      'Spells: ' .. __(char.spells):values():map(function(_,s) return span(s) end):sort():join(', '):value(),
    }
    :join '<br/>'
    :value()
  return abs
end
