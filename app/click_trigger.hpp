#pragma once
#include "input_cell.hpp"
#include <Rocket/Core.h>

struct click_trigger : input_cell<bool>, public Rocket::Core::EventListener {
  click_trigger(Rocket::Core::Element& e) : input_cell {false} {
    e.AddEventListener("click", this);
  }
  
  auto ProcessEvent(Rocket::Core::Event& event) -> void override {
    value = true;
    on_change(value);
    notify_listeners();
    value = false;
  }
};
