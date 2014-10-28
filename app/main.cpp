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
  auto char_state = api.get_character_state();
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

  auto& doc = utils::deref(context->LoadDocument("data/main.rml"));
  auto& desc_doc = utils::deref(context->LoadDocument("data/desc.rml"));

  auto desc_hover = description_hover {doc};
  auto desc_topic = cell<string> {""};
  desc_topic.func = [topic = desc_hover(desc_topic)] (const string&) { return topic; };
  desc_topic.on_change = [descriptions = api.get_descriptions(),
                          &div = desc_doc % "desc"] (const string& topic) {
    auto it = descriptions.find(topic);
    if (it != descriptions.end()) {
      div.SetInnerRML(it->second.c_str());
      div.ScrollIntoView();
    }
  };

  auto current_stage = cell<stage> {stage::roll_abilities};

  //------------------------------------------------------------------------------
  auto confirm_roll_btn = click_trigger {doc % "confirm-roll-btn"};
  
  auto roll_btn = click_trigger {doc % "roll-btn"};
  auto roll_result = cell<bool> {false};
  roll_result.func = [r = roll_btn(roll_result)] (bool old) { return !old; };
  roll_result.on_change = [api, &char_state,
                           &l = doc % "roll-result-label"] (bool) {
    auto roll = api.roll();
    char_state = api.set_rolled_abilities(char_state, roll);
    l.SetInnerRML(api.roll_view(roll).c_str());
  };
  roll_result.update(); ;

  //------------------------------------------------------------------------------
  auto races_block = cell<bool> {false};
  races_block.func = [stg = current_stage(races_block)] (bool) {
    return stg == stage::pick_race;
  };
  races_block.on_change = [api, &doc,
                           &div = doc % "choose-race",
                           &lst = doc % "races-list"] (bool active) {
    if (active) {
      auto races = api.get_races();
      fill_list(doc, lst, races);
      show(div);
    }
  };

  auto race_selection = list_selection {doc % "races-list"};
  auto race_state = cell<string> {""};
  race_state.func = [s = race_selection(race_state)] (const string&) { return s; };
  race_state.on_change = [api, &char_state] (const string& race) {
    char_state = api.set_race(char_state, race);
  };

  //------------------------------------------------------------------------------
  auto ab_block = cell<bool> {false};
  ab_block.func = [stg = current_stage(ab_block)] (bool) {
    return stg == stage::pick_human_ability;
  };
  ab_block.on_change = [api, &doc,
                        &div = doc % "choose-human-ability",
                        &lst = doc % "abilities-list"] (bool active) {
    if (active) {
      auto abilities = api.get_abilities();
      fill_list(doc, lst, abilities);
      show(div);
    }
  };

  auto ab_selection = list_selection {doc % "abilities-list"};
  auto ab_state = cell<string> {""};
  ab_state.func = [s = ab_selection(ab_state)] (const string&) { return s; };
  ab_state.on_change = [api, &char_state] (const string& ability) {
    char_state = api.set_human_ability(char_state, ability);
  };

  //------------------------------------------------------------------------------
  auto classes_block = cell<bool> {false};
  classes_block.func = [stg = current_stage(classes_block)] (bool) {
    return stg == stage::pick_class;
  };
  classes_block.on_change = [api, &doc,
                             &div = doc % "choose-class",
                             &lst = doc % "classes-list"] (bool active) {
    if (active) {
      auto classes = api.get_classes();
      fill_list(doc, lst, classes);
      show(div);
    }
  };

  auto class_selection = list_selection {doc % "classes-list"};
  auto class_state = cell<string> {""};
  class_state.func = [s = class_selection(class_state)] (const string&) { return s; };
  class_state.on_change = [api, &char_state] (const string& cls) {
    char_state = api.set_class(char_state, cls);
  };

  //------------------------------------------------------------------------------
  auto feat_selection = list_selection {doc % "feats-list"};
  auto feat_state = cell<string> {""};
  feat_state.func = [s = feat_selection(feat_state)] (const string&) { return s; };
  feat_state.on_change = [api, &char_state] (const string& feat) {
    char_state = api.add_feat(char_state, feat);
  };
  
  auto feats_count = cell<int> {0};
  feats_count.func = [api, &char_state,
                      stg = current_stage(feats_count),
                      pick = feat_selection(feats_count)] (int old) {
    if (stg == stage::pick_feats) {
      if (api.list_available_feats(char_state).empty()) {
        return 0;
      }
      return pick.get().empty() ? api.number_of_feats(char_state) : old - 1;
    }
    return -1;
  };
  feats_count.on_change = [&cnt = doc % "feats-count"] (int count) {
    cnt.SetInnerRML(to_string(count).c_str());
  };

  using feats_t = tuple<bool, int>;
  auto feats_block = cell<feats_t> {make_tuple(false, 0)};
  feats_block.func = [stg = current_stage(feats_block),
                      cnt = feats_count(feats_block)] (feats_t) {
    return make_tuple(stg == stage::pick_feats, cnt);
  };
  feats_block.on_change = [api, &doc, &char_state,
                           &div   = doc % "choose-feats",
                           &lst   = doc % "feats-list",
                           &unlst = doc % "feats-unlist",
                           &cnt   = doc % "feats-count"] (feats_t state) {
    if (get<0>(state)) {
      auto feats = api.list_available_feats(char_state);
      fill_list(doc, lst, feats);
      auto unfeats = api.list_unavailable_feats(char_state);
      fill_list(doc, unlst, unfeats);
      show(div);
    }
  };

  //------------------------------------------------------------------------------
  auto spell_selection = list_selection {doc % "spells-list"};
  auto spell_state = cell<string> {""};
  spell_state.func = [s = spell_selection(spell_state)] (const string&) { return s; };
  spell_state.on_change = [api, &char_state] (const string& spell) {
    char_state = api.add_spell(char_state, spell);
  };

  auto spells_count = cell<int> {0};
  spells_count.func = [api, &char_state,
                       stg  = current_stage(spells_count),
                       pick = spell_selection(spells_count)] (int old) {
    if (stg == stage::pick_spells) {
      if (api.list_available_spells(char_state).empty()) {
        return 0;
      }
      return pick.get().empty() ? api.number_of_spells(char_state) : old - 1;
    }
    return -1;
  };
  spells_count.on_change = [&cnt = doc % "spells-count"] (int count) {
    cnt.SetInnerRML(to_string(count).c_str());
  };

  using spells_t = tuple<bool, int>;
  auto spells_block = cell<spells_t> {make_tuple(false, 0)};
  spells_block.func = [stg = current_stage(spells_block),
                       cnt = spells_count(spells_block)] (spells_t) {
    return make_tuple(stg == stage::pick_spells, cnt);
  };
  spells_block.on_change = [api, &doc, &char_state,
                           &div = doc % "choose-spells",
                           &lst = doc % "spells-list"] (spells_t state) {
    if (get<0>(state)) {
      auto spells = api.list_available_spells(char_state);
      fill_list(doc, lst, spells);
      show(div);
    }
  };

  //------------------------------------------------------------------------------
  auto hp_stage = cell<bool> {false};
  hp_stage.func = [stg = current_stage(hp_stage)] (bool) { return stg == stage::gain_hp; };
  hp_stage.on_change = [api, &char_state,
                        &div = doc % "gain-hp",
                        &lbl = doc % "hp-num"] (bool active) {
    if (active) {
      auto gain = api.roll_hp(char_state);
      char_state = api.add_hp_roll(char_state, gain);
      lbl.SetInnerRML(to_string(gain).c_str());
      show(div);
    }
  };

  auto hp_confirm_btn = click_trigger {doc % "hp-ok"};

  //------------------------------------------------------------------------------
  auto advance_btn = click_trigger {doc % "next-level" % "advance" };
  auto advance_lvl = cell<bool> {false};
  advance_lvl.func = [x = advance_btn(advance_lvl)] (bool old) { return !old; };
  advance_lvl.on_change = [api, &char_state] (bool) {
    char_state = api.advance_level(char_state);
  };
  auto final_block = cell<stage> {stage::roll_abilities};
  final_block.func = [stg = current_stage(final_block)] (stage) { return stg; };
  final_block.on_change = [api, &char_state,
                           &btn  = doc % "next-level" % "advance",
                           &div  = doc % "next-level",
                           &data = doc % "summary"] (stage stg) {
    if (stg == stage::next_level) {
      data.SetInnerRML(api.print_character_state(char_state).c_str());
      if (api.at_max_level(char_state)) {
        btn.SetProperty("visibility", "hidden");
      }
      show(div);
    }
  };

  auto finish_btn = click_trigger {doc % "next-level" % "finish"};
  auto close_app = cell<bool> {false};
  close_app.func = [fin = finish_btn(close_app)] (bool) { return fin; };
  close_app.on_change = [] (bool) { Shell::RequestExit(); };

  //------------------------------------------------------------------------------
  current_stage.func = [api, &char_state,
                        roll = confirm_roll_btn(current_stage),
                        race = race_selection(current_stage),
                        ab   = ab_selection(current_stage),
                        cls  = class_selection(current_stage),
                        feat_cnt  = feats_count(current_stage),
                        spell_cnt = spells_count(current_stage),
                        hp  = hp_confirm_btn(current_stage),
                        adv = advance_btn(current_stage)] (stage old) {
    switch (old) {
    case stage::roll_abilities: return roll ? stage::pick_race : old;
    case stage::pick_race: {
      if (!race.get().empty()) {
        return (api.check_if_human(char_state)) ? stage::pick_human_ability : stage::pick_class;
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
    cout << "current stage: " << stage_ids[static_cast<int>(stg)] << endl;
    for (auto& id : stage_ids) hide(doc % id);
  };
  
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
