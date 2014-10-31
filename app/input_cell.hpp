#pragma once
#include <vector>
#include <functional>

template <class T>
struct input_cell {
  // not using `value {init}` here
  // http://www.stroustrup.com/4th.html
  // It's a bug in the standard. Fixed for C++14. For now use one of the traditional notations
  input_cell(const T& init) : value(init) {}
  
  template <class U>
  auto operator()(U& listener) -> std::reference_wrapper<const T> {
    listeners.emplace_back([&] { listener.update(); });
    return value;
  }
  
  auto notify_listeners() -> void {
    for (auto& l : listeners) l();
  }

  std::function<void(const T&)> on_change = [] (const T&) {};
  
protected:
  T value;
private:
  std::vector<std::function<void()>> listeners;
};

