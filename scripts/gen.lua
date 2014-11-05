local __ = require 'moses'
require 'pf'

local type_conversion = {
  number  = 'int',
  boolean = 'bool',
  string  = 'std::string',
}

local function template(str)
  return setmetatable({}, {
    __div = function(this, dict)
      return str:gsub('( *)%%([%w_]+)%%', function(spaces, key)
        return spaces .. dict[key]:gsub('\n([^\n]+)', '\n' .. spaces .. '%1')
      end)
    end
  })
end

local function indented_template(spaces_count)
  return function(str)
    local spaces = string.rep(' ', spaces_count)
    local str = str:gsub('^'  .. spaces, '')
          str = str:gsub('\n' .. spaces, '\n')
    return template(str)
  end
end

local function gen(name, tbl, hints, includes)
  local X = template
  local XCROP = indented_template

  local proc = __(tbl)
    :map(function(_, v) return type(v) end)
    :map(function(k, t) 
           return 
             hints[k] or 
             type_conversion[t] or 
             error('need type hint for key <' .. k .. '> of type <' .. t .. '>') 
        end)
    :value()

  local kv = __(proc)
    :values()
    :zip(__.keys(proc))
    :sort(function(a, b) return a[2] < b[2] end)
    :map(function(_, p) return { type = p[1], name = p[2] } end)
    :value()

  local struct_body = __(kv)
    :map(function(_, v) return X'%type% %name%_;' / v end)
    :join '\n'
    :value()

  local equals_body = __(kv)
    :map(function(_, v) 
           return X'%name%_ == rhs.%name%_' / v
        end)
    :join ' &&\n'
    :value() .. ';'

  local peek_helper_body = __(kv)
    :map(function(_, v) 
           return X'pop<%type%>(L, "%name%")' / v
        end)
    :join ',\n'
    :value()

  local push_helper_body = __(kv)
    :map(function(_, v)
           return X'push_key_value(L, "%name%", val.%name%_);' / v
        end)
    :join '\n'
    :value()

  local struct_parts = {}
  struct_parts.definition = XCROP(4) [[
    struct %T% {
      %members%
      auto operator==(const %T%& rhs) const -> bool {
        return
          %equals_body%
      }
      auto operator!=(const %T%& rhs) const -> bool { return !(*this == rhs); }
    };
    ]] / { T = name, members = struct_body, equals_body = equals_body }

  struct_parts.peek_helper = XCROP(4) [[
    namespace lua {
      template <>
      auto peek_helper<%T%>::operator()() -> return_type {
        return {
          %peek_helper_body%
        };
      }
    }]] / { T = name, peek_helper_body = peek_helper_body }

  struct_parts.push_helper = XCROP(4) [[
    namespace lua {
      template <>
      auto push_helper<%T%>::operator()(argument_type val) -> void {
        lua_newtable(L);
        %push_helper_body%
      }
    }]] / { T = name, push_helper_body = push_helper_body }
  
  struct_parts.headers = __(includes)
    :addTop '"lua.hpp"'
    :map(function(_, header) return '#include ' .. header end)
    :join '\n'
    :value()

  local res = XCROP(4) [[
    #pragma once
    %headers%

    %definition%
    %peek_helper%
    %push_helper%
    ]] / struct_parts
  
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

