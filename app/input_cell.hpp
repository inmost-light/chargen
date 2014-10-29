#pragma once
#include <vector>
#include <functional>

template <class T>
struct input_cell {
  input_cell(const T& init) : value {init} {}
  
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

