#pragma once
#include "event_source.hpp"
#include <Rocket/Core.h>

struct click_trigger : event_source<bool>, public Rocket::Core::EventListener {
  click_trigger(Rocket::Core::Element& e) : event_source {0} {
    e.AddEventListener("click", this);
  }
  
  auto ProcessEvent(Rocket::Core::Event& event) -> void override {
    value = true;
    notify_listeners();
    value = false;
  }
};
