import TomSelect from "tom-select/dist/cjs/tom-select.popular";

document.addEventListener("decidim:loaded", () => {
  const form = document.querySelector(".new_follow_up_questionnaire, .new_follow_up_questionnaire_");
  if (!form) {
    return;
  }

  const questionnaireSelect = form.querySelector("#follow_up_questionnaire_decidim_questionnaire_id");
  if (!questionnaireSelect) {
    return;
  }

  const adminsWrapper = form.querySelector("#notified-admins-wrapper");
  const adminsSelect = adminsWrapper?.querySelector("select");
  if (adminsSelect) {
    const adminsByQuestionnaireId = JSON.parse(adminsWrapper.dataset.admins || "{}");
    const adminsTomSelect = new TomSelect(adminsSelect, {
      plugins: ["remove_button"],
      create: false
    });

    questionnaireSelect.addEventListener("change", () => {
      const admins = adminsByQuestionnaireId[questionnaireSelect.value] || [];
      const selected = adminsTomSelect.getValue();

      adminsTomSelect.clear(true);
      adminsTomSelect.clearOptions();
      admins.forEach(([text, id]) => adminsTomSelect.addOption({ value: String(id), text }));
      adminsTomSelect.setValue(selected.filter((value) => admins.some(([, id]) => String(id) === value)), true);
    });
  }

  const wrapper = form.querySelector("#responder-fields-wrapper");
  if (!wrapper) {
    return;
  }

  const nameSelect = wrapper.querySelector("#follow_up_questionnaire_responder_name_field");
  const emailSelect = wrapper.querySelector("#follow_up_questionnaire_responder_email_field");
  if (!nameSelect || !emailSelect) {
    return;
  }

  const questionsByQuestionnaireId = JSON.parse(wrapper.dataset.questions || "{}");

  const populate = (select, questions) => {
    const previousValue = select.value;
    select.innerHTML = "";
    select.appendChild(new Option("", ""));
    questions.forEach(([label, id]) => select.appendChild(new Option(label, id)));
    select.value = questions.some(([, id]) => String(id) === previousValue)
      ? previousValue
      : "";
    select.disabled = questions.length === 0;
  };

  questionnaireSelect.addEventListener("change", () => {
    const questions = questionsByQuestionnaireId[questionnaireSelect.value] || [];

    populate(nameSelect, questions);
    populate(emailSelect, questions);
  });
});
