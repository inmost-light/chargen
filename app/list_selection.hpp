#pragma once
#include "event_source.hpp"
#include <Rocket/Core.h>
#include <string>

struct list_selection : event_source<std::string>, public Rocket::Core::EventListener {
  list_selection(Rocket::Core::Element& e) : event_source {""} {
    e.AddEventListener("click", this);
  }
  
  auto ProcessEvent(Rocket::Core::Event& event) -> void override {
    auto target = event.GetTargetElement();
    if (target->GetTagName() == "button") {
      value = target->GetInnerRML().CString();
      notify_listeners();
      value.clear();
    }
  }
};

