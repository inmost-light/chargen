#pragma once

#include <type_traits>
#include <memory>
#include <iostream>
#include <cassert>

#include <lua.hpp>
#include <lauxlib.h>
#include <lualib.h>

namespace lua {
  struct state_wrapper {
    struct lua_state_deleter {
      auto operator()(lua_State* L) -> void {
        lua_close(L);
      }
    };

    std::unique_ptr<lua_State, lua_state_deleter> lua_state {luaL_newstate()};
  
    state_wrapper(const char* path_to_lua_script) {
      auto L = lua_state.get();
      luaL_openlibs(L);
      if (luaL_loadfile(L, path_to_lua_script) || lua_pcall(L, 0,0,0)) {
        std::cout << "lua error: " << lua_tostring(L, -1) << std::endl;
        assert(false && "failed to load lua script");
      }
    }
  };

  //------------------------------------------------------------------------------
  struct stack_helper_base {
    lua_State* L;
    stack_helper_base(lua_State* lua_state) : L {lua_state} {}
  };

  //------------------------------------------------------------------------------
  struct push_helper_base : stack_helper_base {
    using stack_helper_base::stack_helper_base;
  };
    
  template <class T>
  struct push_helper : push_helper_base {
    using push_helper_base::push_helper_base;
    using argument_type = const T&;
    auto operator()(argument_type value) -> void {
      lua_pushnumber(L, value);
    }
  };

  template <class T>
  auto push(lua_State* L, const T& value) -> void {
    auto p = push_helper<T> {L};
    p(value);
  }

  template <>
  auto push_helper<const char*>::operator()(argument_type str) -> void {
    lua_pushstring(L, str);
  }

  template <>
  auto push_helper<bool>::operator()(argument_type b) -> void {
    lua_pushboolean(L, b);
  }

  template <class T>
  auto push_key_value(lua_State* L, const char* key, const T& value) -> void {
    push(L, key);
    push(L, value);
    lua_settable(L, -3);
  }

  template <class T>
  auto push_key_value(lua_State* L, const std::string& key, const T& value) -> void {
    push_key_value(L, key.c_str(), value);
  }

  //------------------------------------------------------------------------------
  struct peek_helper_base : stack_helper_base {
    using stack_helper_base::stack_helper_base;
  };

  template <class T>
  struct peek_helper : peek_helper_base {
    using return_type = T;
    using peek_helper_base::peek_helper_base;
    auto operator()() -> return_type {
      return luaL_checknumber(L, -1);
    }
  };

  template <>
  auto peek_helper<bool>::operator()() -> return_type {
    return lua_toboolean(L, -1);
  }

  template <class T>
  auto peek(lua_State* L) -> T {
    auto p = peek_helper<T> {L};
    return p();
  }

  //------------------------------------------------------------------------------
  struct pop_helper_base : stack_helper_base {
    using stack_helper_base::stack_helper_base;
    ~pop_helper_base() { lua_pop(L, 1); } 
  };

  template <class T>
  struct pop_helper : pop_helper_base {
    using pop_helper_base::pop_helper_base;
    using return_type = T;
    auto operator()() -> return_type {
      return peek<T>(L);
    }
  };

  template <class T>
  auto pop(lua_State* L) -> T {
    static_assert(std::is_base_of<pop_helper_base, pop_helper<T>>::value,
                  "pop_helpers must inherit from pop_helper_base");
    auto p = pop_helper<T> {L};
    return p();
  }

  template <class T>
  auto pop(lua_State* L, const char* field) -> T {
    lua_getfield(L, -1, field);
    return pop<T>(L);
  }

  template <>
  auto pop(lua_State* L) -> void { }
  template <>
  auto pop(lua_State*, const char*) -> void { }

  //------------------------------------------------------------------------------
  auto push_args_recursive(lua_State*) -> void {}
  
  template <class T, class... Ts>
  auto push_args_recursive(lua_State* L, const T& arg, const Ts&... args) -> void {
    lua::push(L, arg);
    push_args_recursive(L, args...);
  }

  template <class R = void, class... Args>
  auto call(lua_State* L, const char* function, const Args&... args) -> R {
    lua_getglobal(L, function);
    push_args_recursive(L, args...);
    const auto ret_count = std::is_same<R, void>::value ? 0 : 1;
    if (lua_pcall(L, sizeof...(Args), ret_count, 0)) {
      std::cout << "lua error: " << lua_tostring(L, -1) << std::endl;
      assert(false && "failed to call lua function");
    }
    return pop<R>(L);
  }
}
