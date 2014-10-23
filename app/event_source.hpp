#pragma once
#include <vector>
#include <functional>

template <class T>
struct event_source {
  event_source(const T& init) : value {init} {}
  
  template <class U>
  auto operator()(U& listener) -> T& {
    listeners.emplace_back([&] { listener.update(); });
    return value;
  }
  
  auto notify_listeners() -> void {
    for (auto& l : listeners) l();
  }

protected:
  T value;
private:
  std::vector<std::function<void()>> listeners;
};

