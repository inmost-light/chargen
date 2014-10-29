#pragma once
#include "input_cell.hpp"
#include <Rocket/Core.h>
#include <string>

struct list_selection : input_cell<std::string>, public Rocket::Core::EventListener {
  list_selection(Rocket::Core::Element& e) : input_cell {""} {
    e.AddEventListener("click", this);
  }
  
  auto ProcessEvent(Rocket::Core::Event& event) -> void override {
    auto target = event.GetTargetElement();
    if (target->GetTagName() == "button") {
      value = target->GetInnerRML().CString();
      on_change(value);
      notify_listeners();
      value.clear();
    }
  }
};

