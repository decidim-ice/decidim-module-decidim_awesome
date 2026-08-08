document.addEventListener("decidim:loaded", () => {
  const form = document.querySelector(".new_follow_up_questionnaire, .new_follow_up_questionnaire_");
  if (!form) return;

  const questionnaireSelect = form.querySelector("#follow_up_questionnaire_decidim_questionnaire_id");
  const wrapper = form.querySelector("#responder-fields-wrapper");
  if (!questionnaireSelect || !wrapper) return;

  const fetchUrl = wrapper.dataset.fetchUrl; // habría que añadir data-fetch-url en el erb

  const toggleDisabledHiddenFields = () => {
    const enabled = Boolean(questionnaireSelect.value);
    const selects = wrapper.querySelectorAll("select");

    selects.forEach((select) => select.setAttribute("disabled", "disabled"));
    wrapper.classList.add("hidden");

    if (enabled) {
      selects.forEach((select) => select.removeAttribute("disabled"));
      wrapper.classList.remove("hidden");
    }
  };

  questionnaireSelect.addEventListener("change", () => {
    const id = questionnaireSelect.value;
    if (!id) {
      wrapper.innerHTML = "";
      toggleDisabledHiddenFields();
      return;
    }

    fetch(`${fetchUrl}?decidim_questionnaire_id=${encodeURIComponent(id)}`)
      .then((response) => response.text())
      .then((html) => {
        wrapper.innerHTML = html;
        toggleDisabledHiddenFields();
      });
  });

  toggleDisabledHiddenFields();
});
