#include <Rocket/Core.h>
#include <Rocket/Debugger.h>
#include <Input.h>
#include <Shell.h>
#include <iostream>
#include <functional>
#include <tuple>
#include <map>
#include <ctime>

#include "lua_api.hpp"
#include "utils.hpp"
#include "rocket_utils.hpp"
#include "click_trigger.hpp"
#include "list_selection.hpp"
#include "description_hover.hpp"
#include "cell.hpp"

using namespace std;
using namespace rocket_utils;
namespace RC = Rocket::Core;

RC::Context* context = nullptr;

auto game_loop() -> void {
  glClear(GL_COLOR_BUFFER_BIT);

  context->Update();
  context->Render();

  Shell::FlipBuffers();
}

enum class stage {
  roll_abilities,
  pick_race,
  pick_human_ability,
  pick_class,
  pick_feats,
  pick_spells,
  gain_hp,
  next_level
};

#ifdef NDEBUG
auto APIENTRY WinMain(HINSTANCE, HINSTANCE, LPSTR, int) -> int {
#else
auto main() -> int {
#endif
  auto lua_wrapper = lua::state_wrapper {"scripts/pf.lua"};
  auto api = lua_api {lua_wrapper.lua_state.get()};
  api.random_seed(time(nullptr));

  if (!Shell::Initialise("../") || !Shell::OpenWindow("Character creation", true)) {
    Shell::Shutdown();
    return -1;
  }

  auto opengl_renderer = ShellRenderInterfaceOpenGL {};
  RC::SetRenderInterface(&opengl_renderer);
  opengl_renderer.SetViewport(1024, 768);

  auto system_interface = ShellSystemInterface {};
  RC::SetSystemInterface(&system_interface);

  RC::Initialise();

  context = RC::CreateContext("main", RC::Vector2i(1024, 768));
  if (!context) {
    RC::Shutdown();
    Shell::Shutdown();
    return -1;
  }

  Rocket::Debugger::Initialise(context);
  Input::SetContext(context);

  RC::FontDatabase::LoadFontFace("./assets/Consolas.ttf",
                                 "Consolas",
                                 RC::Font::STYLE_NORMAL,
                                 RC::Font::WEIGHT_NORMAL);
  RC::FontDatabase::LoadFontFace("./assets/Consolas-Bold.ttf",
                                 "Consolas",
                                 RC::Font::STYLE_NORMAL,
                                 RC::Font::WEIGHT_BOLD);

  //------------------------------------------------------------------------------
  auto& doc = utils::deref(context->LoadDocument("data/main.rml"));
  auto& desc_doc = utils::deref(context->LoadDocument("data/desc.rml"));

  //------------------------------------------------------------------------------
  auto desc_topic = description_hover {doc};
  desc_topic.on_change = [descriptions = api.get_descriptions(),
                          &div = desc_doc % "desc"] (const string& topic) {
    auto it = descriptions.find(topic);
    if (it != descriptions.end()) {
      div.SetInnerRML(it->second.c_str());
      div.ScrollIntoView();
    }
  };

  //------------------------------------------------------------------------------
  auto char_state = cell<character_state> {api.get_character_state()};
  
  auto char_level = cell<int> {0};
  char_level.formula = [api, state = char_state(char_level)] (int) {
    return api.get_level(state);
  };
  
  //------------------------------------------------------------------------------
  auto confirm_roll_btn = click_trigger {doc % "confirm-roll-btn"};
  
  auto roll_btn = click_trigger {doc % "roll-btn"};
  auto roll_result = cell<rolls> {api.roll()};
  roll_result.formula = [api, r = roll_btn(roll_result)] (const rolls&) {
    return api.roll();
  };
  roll_result.on_change = [api, &l = doc % "roll-result-label"] (const rolls& roll) {
    l.SetInnerRML(api.roll_view(roll).c_str());
  };
  roll_result.update();

  //------------------------------------------------------------------------------
  fill_list(doc, doc % "races-list", api.get_races());

  auto race_selection = list_selection {doc % "races-list"};

  //------------------------------------------------------------------------------
  fill_list(doc, doc % "abilities-list", api.get_abilities());
  auto ab_selection = list_selection {doc % "abilities-list"};

  //------------------------------------------------------------------------------
  fill_list(doc, doc % "classes-list", api.get_classes());
  auto class_selection = list_selection {doc % "classes-list"};
  
  //------------------------------------------------------------------------------
  auto feat_selection = list_selection {doc % "feats-list"};

  auto max_feats_count = cell<int> {-1};
  max_feats_count.formula = [api, state = char_state(max_feats_count)] (int) {
    return api.list_available_feats(state).empty() ? 0 : api.number_of_feats(state);
  };
  
  auto feats_count = cell<int> {-1};
  feats_count.formula = [api,
                         level = char_level(feats_count),
                         max   = max_feats_count(feats_count),
                         pick  = feat_selection(feats_count)] (int old) {
    return pick.get().empty() ? max.get() : old - 1;
  };
  feats_count.on_change = [&cnt = doc % "feats-count"] (int count) {
    cnt.SetInnerRML(to_string(count).c_str());
  };

  using feats_t = tuple<vector<string>, vector<string>>;
  auto feats_block = cell<feats_t> {make_tuple(vector<string> {}, vector<string> {})};
  feats_block.formula = [api, state = char_state(feats_block)] (const feats_t&) {
    return make_tuple(
      api.list_available_feats(state),
      api.list_unavailable_feats(state)
    );
  };
  feats_block.on_change = [api, &doc,
                           &lst   = doc % "feats-list",
                           &unlst = doc % "feats-unlist"] (const feats_t& state) {
    fill_list(doc, lst,   get<0>(state));
    fill_list(doc, unlst, get<1>(state));
  };

  //------------------------------------------------------------------------------
  auto spell_selection = list_selection {doc % "spells-list"};

  auto max_spells_count = cell<int> {-1};
  max_spells_count.formula = [api, state = char_state(max_spells_count)] (int) {
    return api.list_available_spells(state).empty() ? 0 : api.number_of_spells(state);
  };

  auto spells_count = cell<int> {-1};
  spells_count.formula = [api,
                          level = char_level(spells_count),
                          max   = max_spells_count(spells_count),
                          pick  = spell_selection(spells_count)] (int old) {
    return pick.get().empty() ? max.get() : old - 1;
  };
  spells_count.on_change = [&cnt = doc % "spells-count"] (int count) {
    cnt.SetInnerRML(to_string(count).c_str());
  };

  using spells_t = vector<string>;
  auto spells_block = cell<spells_t> {{}};
  spells_block.formula = [api, state = char_state(spells_block)] (const spells_t&) {
    return api.list_available_spells(state);
  };
  spells_block.on_change = [api, &doc,
                           &lst = doc % "spells-list"] (const spells_t& spells) {
    fill_list(doc, lst, spells);
  };

  //------------------------------------------------------------------------------
  auto max_hp_gain = cell<int> {-1};
  max_hp_gain.formula = [api, state = char_state(max_hp_gain)] (int) {
    return api.max_hp_gain(state);
  };
  auto hp_gain = cell<int> {0};
  hp_gain.formula = [api,
                     state = char_state.view(),
                     max   = max_hp_gain(hp_gain),
                     level = char_level(hp_gain)] (int) {
    return api.roll_hp(state);
  };
  hp_gain.on_change = [&lbl = doc % "hp-num"] (int gain) {
    lbl.SetInnerRML(to_string(gain).c_str());
  };

  auto hp_confirm_btn = click_trigger {doc % "hp-ok"};

  //------------------------------------------------------------------------------
  auto advance_btn = click_trigger {doc % "next-level" % "advance" };

  auto final_block = cell<string> {""};
  final_block.formula = [api, state = char_state(final_block)] (const string&) {
    return api.print_character_state(state);
  };
  final_block.on_change = [api,
                           state = char_state.view(),
                           &btn  = doc % "next-level" % "advance",
                           &data = doc % "summary"] (const string& str) {
    data.SetInnerRML(str.c_str());
    if (api.at_max_level(state)) {
      btn.SetProperty("visibility", "hidden");
    }
  };

  auto finish_btn = click_trigger {doc % "next-level" % "finish"};
  finish_btn.on_change = [] (bool) { Shell::RequestExit(); };

  //------------------------------------------------------------------------------
  char_state.formula = [api,
                        conf_roll = confirm_roll_btn(char_state),
                        roll = roll_result.view(),
                        race = race_selection(char_state),
                        ab = ab_selection(char_state),
                        cls = class_selection(char_state),
                        feat = feat_selection(char_state),
                        spell = spell_selection(char_state),
                        hp = hp_confirm_btn(char_state),
                        hp_gain = hp_gain.view(),
                        adv = advance_btn(char_state)] (const character_state& old) {
    if (conf_roll)            return api.set_rolled_abilities(old, roll);
    if (!race.get().empty())  return api.set_race(old, race);
    if (!ab.get().empty())    return api.set_human_ability(old, ab);
    if (!cls.get().empty())   return api.set_class(old, cls);
    if (!feat.get().empty())  return api.add_feat(old, feat);
    if (!spell.get().empty()) return api.add_spell(old, spell);
    if (hp)                   return api.add_hp_roll(old, hp_gain);
    if (adv)                  return api.advance_level(old);
    // TODO fix invisible button click
  };

  //------------------------------------------------------------------------------
  auto current_stage = cell<stage> {stage::roll_abilities};
  current_stage.formula = [api,
                           state = char_state.view(),
                           roll = confirm_roll_btn(current_stage),
                           race = race_selection(current_stage),
                           ab   = ab_selection(current_stage),
                           cls  = class_selection(current_stage),
                           feat_cnt  = feats_count(current_stage),
                           spell_cnt = spells_count(current_stage),
                           hp  = hp_confirm_btn(current_stage),
                           adv = advance_btn(current_stage),
                           self = current_stage(current_stage)] (stage old) {
    switch (old) {
    case stage::roll_abilities: return roll ? stage::pick_race : old;
    case stage::pick_race: {
      if (!race.get().empty()) {
        return (api.check_if_human(state)) ? stage::pick_human_ability : stage::pick_class;
      } else {
        return old;
      }
    }
    case stage::pick_human_ability: return (!ab.get().empty())  ? stage::pick_class : old;
    case stage::pick_class:         return (!cls.get().empty()) ? stage::pick_feats : old;
    case stage::pick_feats:  return (feat_cnt  == 0) ? stage::pick_spells : old;
    case stage::pick_spells: return (spell_cnt == 0) ? stage::gain_hp     : old;
    case stage::gain_hp:    return hp  ? stage::next_level : old;
    case stage::next_level: return adv ? stage::pick_feats : old;
    }
    
    return old;
  };

  const char* stage_ids[] = {
    "roll-abilities",
    "choose-race",
    "choose-human-ability",
    "choose-class",
    "choose-feats",
    "choose-spells",
    "gain-hp",
    "next-level"
  };
  
  current_stage.on_change = [&doc, &stage_ids] (stage stg) {
    for (auto& id : stage_ids) {
      hide(doc % id);
    }
    auto id = stage_ids[static_cast<int>(stg)];
    show(doc % id);
    cout << "current stage: " << id << endl;
  };

  //------------------------------------------------------------------------------
  doc.Show();
  doc.RemoveReference();

  desc_doc.Show();
  desc_doc.RemoveReference();

  Shell::EventLoop(game_loop);

  context->RemoveReference();
  RC::Shutdown();

  Shell::CloseWindow();
  Shell::Shutdown();

  return 0;
}
