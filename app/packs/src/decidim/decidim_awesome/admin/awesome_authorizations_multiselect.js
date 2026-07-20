import TomSelect from "tom-select/dist/cjs/tom-select.popular";

const initializeTomSelect = () => {
  document.querySelectorAll('input[tabs_prefix="awesome_authorization_groups_tabs_prefix"]').forEach((input) => {
    input.tomselect = new TomSelect(input, {
      plugins: ["remove_button", "dropdown_input"],
      allowEmptyOption: true,
      placeholder: window.DecidimAwesome.i18n.awesomeAuthorizationGroupsPlaceholder,
      options: window.DecidimAwesome.awesomeAuthorizationGroups,
      items: input.value.split(",").filter((item) => item !== "")
    });
  });
};

document.addEventListener("turbo:load", () => {
  if (window.DecidimAwesome.awesomeAuthorizationGroups) {
    initializeTomSelect();
  }
});
