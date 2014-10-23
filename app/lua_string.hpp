#pragma once
#include "lua.hpp"
#include <string>

namespace lua {
  template <>
  auto peek_helper<std::string>::operator()() -> return_type {
    return {luaL_checkstring(L, -1)};
  }

  template <>
  auto push_helper<std::string>::operator()(argument_type str) -> void {
    push(L, str.c_str());
  }
}
