// generated with gen.lua on 30-10-14 19:25:09
#pragma once
#include "lua.hpp"

struct rolls {
  int cha_;
  int con_;
  int dex_;
  int int_;
  int str_;
  int wis_;
  auto operator==(const rolls& rhs) -> bool {
    return
      cha_ == rhs.cha_ &&
      con_ == rhs.con_ &&
      dex_ == rhs.dex_ &&
      int_ == rhs.int_ &&
      str_ == rhs.str_ &&
      wis_ == rhs.wis_;
  }
  auto operator!=(const rolls& rhs) -> bool { return !(*this == rhs); }
};

namespace lua {
  template <>
  auto peek_helper<rolls>::operator()() -> return_type {
    return {
      pop<int>(L, "cha"),
      pop<int>(L, "con"),
      pop<int>(L, "dex"),
      pop<int>(L, "int"),
      pop<int>(L, "str"),
      pop<int>(L, "wis")
    };
  }
}
namespace lua {
  template <>
  auto push_helper<rolls>::operator()(argument_type val) -> void {
    lua_newtable(L);
    push_key_value(L, "cha", val.cha_);
    push_key_value(L, "con", val.con_);
    push_key_value(L, "dex", val.dex_);
    push_key_value(L, "int", val.int_);
    push_key_value(L, "str", val.str_);
    push_key_value(L, "wis", val.wis_);
  }
}
