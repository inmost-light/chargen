// generated with gen.lua on 30-10-14 19:25:09
#pragma once
#include "lua.hpp"
#include "lua_vector.hpp"
#include "lua_string.hpp"
#include "lua_map.hpp"

struct character_state {
  std::string class_;
  std::map<std::string, int> feats_;
  std::vector<int> hp_rolls_;
  std::string human_ability_;
  std::string race_;
  rolls rolled_abilities_;
  std::vector<std::string> spells_;
  int xp_;
  auto operator==(const character_state& rhs) -> bool {
    return
      class_ == rhs.class_ &&
      feats_ == rhs.feats_ &&
      hp_rolls_ == rhs.hp_rolls_ &&
      human_ability_ == rhs.human_ability_ &&
      race_ == rhs.race_ &&
      rolled_abilities_ == rhs.rolled_abilities_ &&
      spells_ == rhs.spells_ &&
      xp_ == rhs.xp_;
  }
  auto operator!=(const character_state& rhs) -> bool { return !(*this == rhs); }
};

namespace lua {
  template <>
  auto peek_helper<character_state>::operator()() -> return_type {
    return {
      pop<std::string>(L, "class"),
      pop<std::map<std::string, int>>(L, "feats"),
      pop<std::vector<int>>(L, "hp_rolls"),
      pop<std::string>(L, "human_ability"),
      pop<std::string>(L, "race"),
      pop<rolls>(L, "rolled_abilities"),
      pop<std::vector<std::string>>(L, "spells"),
      pop<int>(L, "xp")
    };
  }
}
namespace lua {
  template <>
  auto push_helper<character_state>::operator()(argument_type val) -> void {
    lua_newtable(L);
    push_key_value(L, "class", val.class_);
    push_key_value(L, "feats", val.feats_);
    push_key_value(L, "hp_rolls", val.hp_rolls_);
    push_key_value(L, "human_ability", val.human_ability_);
    push_key_value(L, "race", val.race_);
    push_key_value(L, "rolled_abilities", val.rolled_abilities_);
    push_key_value(L, "spells", val.spells_);
    push_key_value(L, "xp", val.xp_);
  }
}
