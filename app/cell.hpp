#pragma once
#include "input_cell.hpp"
#include <Rocket/Core.h>

template <class T>
struct cell : input_cell<T> {
  std::function<T(const T&)> formula; // can't do member init here, gcc bug apparently

  cell(const T& init)
    : input_cell<T> {init}
    , formula {[] (const T& val) { return val; }}
  {}  
  auto update() -> void {
    auto val = formula(this->value);
    if (val != this->value) {
      this->value = val;
      this->on_change(this->value);
      this->notify_listeners();
    }
  }
};
