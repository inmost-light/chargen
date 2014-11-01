#pragma once
#include "lua.hpp"
#include "rolls.hpp"
#include "character_state.hpp"

struct lua_api {
  lua_State* L;
  lua_api(lua_State* lua_state) : L {lua_state} {}

  using state_arg = const character_state&;
  using string_arg = const std::string&;
  
  auto roll() const {
    return lua::call<rolls>(L, "roll");    
  }
  auto roll_view(const rolls& r) const {
    return lua::call<std::string>(L, "roll_view", r);
  }
  auto get_character_state() const {
    return lua::call<character_state>(L, "get_default_char");
  }
  auto print_character_state(state_arg state) const {
    return lua::call<std::string>(L, "print_character_state", state);
  }
  auto set_rolled_abilities(state_arg state, const rolls& rs) const {
    return lua::call<character_state>(L, "set_rolled_abilities", state, rs);
  }
  auto get_races() const {
    return lua::call<std::vector<std::string>>(L, "get_races");
  }
  auto set_race(state_arg state, string_arg race) const {
    return lua::call<character_state>(L, "set_race", state, race);
  }
  auto get_classes() const {
    return lua::call<std::vector<std::string>>(L, "get_classes");
  }
  auto set_class(state_arg state, string_arg cls) const {
    return lua::call<character_state>(L, "set_class", state, cls);
  }
  auto check_if_human(state_arg state) const {
    return lua::call<bool>(L, "check_if_human", state);
  }
  auto get_abilities() const {
    return lua::call<std::vector<std::string>>(L, "get_abilities");
  }
  auto set_human_ability(state_arg state, string_arg ability) const {
    return lua::call<character_state>(L, "set_human_ability", state, ability);
  }
  auto list_available_feats(state_arg state) const {
    return lua::call<std::vector<std::string>>(L, "list_available_feats", state);
  }
  auto list_unavailable_feats(state_arg state) const {
    return lua::call<std::vector<std::string>>(L, "list_unavailable_feats", state);
  }
  auto number_of_feats(state_arg state) const {
    return lua::call<int>(L, "number_of_feats", state);
  }
  auto add_feat(state_arg state, string_arg feat) const {
    return lua::call<character_state>(L, "add_feat", state, feat);
  }
  auto roll_hp(state_arg state) const {
    return lua::call<int>(L, "roll_hp", state);
  }
  auto add_hp_roll(state_arg state, int hp) const {
    return lua::call<character_state>(L, "add_hp_roll", state, hp);
  }
  auto advance_level(state_arg state) const {
    return lua::call<character_state>(L, "advance_level", state);
  }
  auto number_of_spells(state_arg state) const {
    return lua::call<int>(L, "number_of_spells", state);
  }
  auto list_available_spells(state_arg state) const {
    return lua::call<std::vector<std::string>>(L, "list_available_spells", state);
  }
  auto add_spell(state_arg state, string_arg spell) const {
    return lua::call<character_state>(L, "add_spell", state, spell);
  }
  auto get_descriptions() const {
    return lua::call<std::map<std::string, std::string>>(L, "get_descriptions");
  }
  auto at_max_level(state_arg state) const {
    return lua::call<bool>(L, "at_max_level", state);
  }
  auto random_seed(int x) const {
    return lua::call(L, "random_seed", x);
  }
  auto get_level(state_arg state) const {
    return lua::call<int>(L, "get_level", state);
  }
  auto max_hp_gain(state_arg state) const {
    return lua::call<int>(L, "max_hp_gain", state);
  }
};
