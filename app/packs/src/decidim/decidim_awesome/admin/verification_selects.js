/* eslint-disable no-new */

import TomSelect from "tom-select/dist/cjs/tom-select.popular";

document.addEventListener("DOMContentLoaded", () => {
  const selectContainer = document.getElementById("config_force_authorization_after_login");

  if (!selectContainer) {
    return;
  }

  new TomSelect(selectContainer, {
    plugins: ["remove_button", "dropdown_input"],
    create: false,
    render: {
      option: function (data, escape) {
        return `<div>${escape(data.text)}</div>`;
      }
    }
  });
});
