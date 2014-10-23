#pragma once
#include "event_source.hpp"
#include <Rocket/Core.h>
#include <algorithm>
#include <string>

struct description_hover : event_source<std::string>, public Rocket::Core::EventListener {
  description_hover(Rocket::Core::Element& e) : event_source {""} {
    e.AddEventListener("mouseover", this);
  }
  
  auto ProcessEvent(Rocket::Core::Event& event) -> void override {
    auto target = event.GetTargetElement();
    auto attr = target->GetAttribute("desc");
    if (attr != nullptr) {
      value = attr->Get<Rocket::Core::String>().CString();
      transform(begin(value), end(value), begin(value), ::tolower);
      notify_listeners();
      value.clear();
    }
  }
};

