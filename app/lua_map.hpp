#pragma once
#include "lua.hpp"
#include <map>

namespace lua {
  template <class K, class V>
  struct peek_helper<std::map<K, V>> : peek_helper_base {
    using peek_helper_base::peek_helper_base;
    using return_type = std::map<K, V>;
    auto operator()() -> return_type {
      auto res = std::map<K, V> {};
      lua_pushnil(L);
      while (lua_next(L, -2) != 0) {
        auto value = pop<V>(L);
        auto key   = peek<K>(L);
        res.insert(std::make_pair(key, value));
      }
      return res;
    }
  };

  template <class K, class V>
  struct push_helper<std::map<K, V>> : push_helper_base {
    using push_helper_base::push_helper_base;
    using argument_type = const std::map<K, V>;
    auto operator()(argument_type m) -> void {
      lua_newtable(L);
      for (const auto& p : m) {
        push_key_value(L, p.first, p.second);
      }
    }
  };
}
