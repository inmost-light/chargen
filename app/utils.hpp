#pragma once
#include <cassert>

namespace utils {
  template <class C, class F>
  auto for_enumerate(C& container, F f) -> void {
    auto i = 0;
    for (auto& element : container) {
      f(i++, element);
    }
  }
  
  template <class T>
  auto deref(T* ptr) -> T& {
    assert(ptr != nullptr);
    return *ptr;
  }
}
