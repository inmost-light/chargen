#pragma once
#include "lua.hpp"
#include "utils.hpp"
#include <vector>

namespace lua {
  template <class U>
  struct peek_helper<std::vector<U>> : peek_helper_base {
    using peek_helper_base::peek_helper_base;
    using return_type = std::vector<U>;
    auto operator()() -> return_type {
      auto v = std::vector<U> {};
      auto len = lua_rawlen(L, -1);
      for (auto i = 1; i <= len; ++i) {
        lua_rawgeti(L, -1, i);
        v.push_back(lua::pop<U>(L));
      }
      return v;
    }
  };
  
  template <class U>
  struct push_helper<std::vector<U>> : push_helper_base {
    using push_helper_base::push_helper_base;
    using argument_type = const std::vector<U>&;
    auto operator()(argument_type vec) -> void {
      lua_newtable(L);
      utils::for_enumerate(vec, [=] (int i, const U& x) {
        lua::push(L, x);
        lua_rawseti(L, -2, i + 1);
      });
    }
  };
}
