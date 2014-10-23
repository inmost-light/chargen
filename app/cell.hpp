#pragma once
#include "event_source.hpp"
#include <Rocket/Core.h>

template <class T>
struct cell : event_source<T> {
  std::function<T(const T&)> func; // can't do member init here, gcc bug apparently
  std::function<void(const T&)> on_change = [] (const T&) {};

  cell(const T& init)
    : event_source<T> {init}
    , func {[] (const T& val) { return val; }}
  {}  
  auto update() -> void {
    auto val = func(this->value);
    if (val != this->value) {
      this->value = val;
      on_change(this->value);
      this->notify_listeners();
    }
  }
};
