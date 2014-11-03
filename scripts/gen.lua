local __ = require 'moses'
require 'pf'

local type_conversion = {
  number  = 'int',
  boolean = 'bool',
  string  = 'std::string',
}

local function gen(name, tbl, hints, includes)
  local proc = __(tbl)
    :map(function(_, v) return type(v) end)
    :map(function(k, t) 
           return 
             hints[k] or 
             type_conversion[t] or 
             error('need type hint for key <' .. k .. '> of type <' .. t .. '>') 
        end)
    :value()

  local kv = __.zip(__.values(proc), __.keys(proc))
  __.sort(kv, function(a, b) return a[2] < b[2] end)

  local struct_body = __(kv)
    :map(function(_, v) return '  ' .. v[1] .. ' ' .. v[2] .. '_;' end)
    :join '\n'
    :value()

  local equals_body = __(kv)
    :map(function(_, v) 
           local n = v[2] .. '_'
           return '      ' .. n .. ' == rhs.' .. n
        end)
    :join ' &&\n'
    :value() .. ';'

  local peek_helper_body = __(kv)
    :map(function(_, v) 
           local t, n = v[1], v[2]
           return '      pop<' .. t .. '>(L, "' .. n .. '")'
        end)
    :join ',\n'
    :value()

  local push_helper_body = __(kv)
    :map(function(_, v)
           local n = v[2]
           return '    push_key_value(L, "' .. n .. '", val.' .. n .. '_);'
        end)
    :join '\n'
    :value()

  local struct =
    'struct ' .. name .. ' {\n' ..
    struct_body .. '\n' ..
    '  auto operator==(const ' .. name .. '& rhs) const -> bool {\n' ..
    '    return\n' ..
    equals_body .. '\n' ..
    '  }\n' ..
    '  auto operator!=(const ' .. name .. '& rhs) const -> bool { return !(*this == rhs); }\n' ..
    '};\n\n'

  local peek_helper =
    'namespace lua {\n' ..
    '  template <>\n' ..
    '  auto peek_helper<' .. name .. '>::operator()() -> return_type {\n' ..
    '    return {\n' ..
    peek_helper_body .. '\n' ..
    '    };\n' ..
    '  }\n' ..
    '}\n'

  local push_helper =
    'namespace lua {\n' ..
    '  template <>\n' ..
    '  auto push_helper<' .. name .. '>::operator()(argument_type val) -> void {\n' ..
    '    lua_newtable(L);\n' ..
    push_helper_body .. '\n' ..
    '  }\n' ..
    '}\n'
  
  local headers = __(includes)
    :addTop '"lua.hpp"'
    :map(function(_, hpp) return '#include ' .. hpp end)
    :join '\n'
    :value()

  local res =
    '#pragma once\n' ..
    headers .. '\n\n' ..
    struct .. peek_helper .. push_helper
  
  return res
end

local function gen_structs(structs)
  for name, v in pairs(structs) do
    local new = gen(name, v.body or {}, v.types or {}, v.includes or {})

    local old = {}

    local f = io.open('../app/' .. name .. '.hpp', 'r')
    if f then
      for line in f:lines() do
        table.insert(old, line)
      end
      f:close()

      old = __(old)
        :tail(2)
        :join '\n'
        :value() .. '\n'
    end

    if old ~= new then
      local f = io.open('../app/' .. name .. '.hpp', 'w')
      f:write('// generated with gen.lua on ' .. os.date('%d-%m-%y %H:%M:%S') .. '\n')
      f:write(new)
      f:close()
      print('[+] ' .. name)
    end
  end
end

--------------------------------------------------------------------------------
gen_structs {
  rolls = {
    body = roll(),
  },

  character_state = {
    body = get_default_char(), 
    types = {
      rolled_abilities = 'rolls', 
      feats            = 'std::map<std::string, int>', 
      spells           = 'std::vector<std::string>',
      hp_rolls         = 'std::vector<int>'
    }, 
    includes = {'"lua_vector.hpp"', '"lua_string.hpp"', '"lua_map.hpp"'}
  }
}

