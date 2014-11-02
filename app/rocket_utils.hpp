#pragma once
#include <Rocket/Core.h>
#include <iostream>
#include <vector>
#include <string>
#include "utils.hpp"

namespace rocket_utils {
  auto operator%(Rocket::Core::Element& doc, const char* id) -> Rocket::Core::Element& {
    auto ptr = doc.GetElementById(id);
    if (!ptr) {
      std::cout << "Element with id [" << id << "] not found" << std::endl;
    }
    return utils::deref(ptr);
  }
  
  auto hide(Rocket::Core::Element& e) -> void {
    e.SetProperty("display", "none");
  }
  
  auto show(Rocket::Core::Element& e) -> void {
    e.SetProperty("display", "block");
    // hack, prevents clicking on hidden buttons
    e.GetContext()->ProcessMouseMove(0, 0, 0);
  }

  auto fill_list(Rocket::Core::ElementDocument&  doc,
                 Rocket::Core::Element&          root,
                 const std::vector<std::string>& items) -> void {
    while (root.GetNumChildren() > 0) {
      root.RemoveChild(root.GetChild(0));
    }
    for (auto& item : items) {
      auto& div = utils::deref(doc.CreateElement("div"));
      auto& btn = utils::deref(doc.CreateElement("button"));
      auto& txt = utils::deref(doc.CreateTextNode(item.c_str()));
      btn.AppendChild(&txt);
      btn.SetAttribute("desc", item.c_str());
      div.AppendChild(&btn);
      root.AppendChild(&div);
    }
  }
}
