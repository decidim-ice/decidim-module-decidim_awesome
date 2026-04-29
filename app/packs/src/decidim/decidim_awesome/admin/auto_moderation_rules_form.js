/* eslint-disable no-new */

import TomSelect from "tom-select/dist/cjs/tom-select.popular";

document.addEventListener("DOMContentLoaded", () => {
  const selectContainer = document.getElementById("auto_moderation_rules_rule_options");

  if (!selectContainer) {
    return;
  }

  new TomSelect(selectContainer, {
    plugins: ["remove_button"],
    create: true
  });
});
