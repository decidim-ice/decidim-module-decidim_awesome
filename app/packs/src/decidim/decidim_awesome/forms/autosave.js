import FormStorage from "form-storage"

$(() => {
  window.DecidimAwesome = window.DecidimAwesome || {};
  if (!window.DecidimAwesome.auto_save_forms) {
    return;
  }

  const questionnaireId = window.DecidimAwesome.current_questionnaire;
  if (!questionnaireId) {
    // console.log("Not a questionnaire page")
    return;
  }

  const storeId = `awesome_autosave:${questionnaireId}`;
  const storeCheckboxesId = `awesome_autosave:checkboxes:${questionnaireId}`;
  const $form = $("form.answer-questionnaire");

  if (!$form.length) {
    if (window.DecidimAwesome.questionnaire_answered) {
      // console.log("Questionnaire already answered, remove any data saved");
      window.localStorage.removeItem(storeId);
      window.localStorage.removeItem(storeCheckboxesId);
    }
    // console.log("No forms here");
    return;
  }

  const store = new FormStorage(`#${$form.attr("id")}`, {
    name: storeId,
    ignores: [
      // '[type="hidden"]',
      '[name="utf8"]',
      '[name="authenticity_token"]',
      "[disabled]",
      // there are problems with matrix questions
      '[type="checkbox"]' 
    ]
  });

  const showMsg = (msg, error = false, defaultTime = 700) => {
    const time = error ? 5000 : defaultTime; // eslint-disable-line no-ternary, multiline-ternary
    const $div = $(`<div class="awesome_autosave-notice${error ? " error" : ""}">${msg}</div>`).appendTo($form); // eslint-disable-line no-ternary, multiline-ternary
    setTimeout(() => {
      $div.fadeOut(500, () => {
        $div.remove();
      });
    }, time);
  };

  if (!window.localStorage) {
    showMsg(window.DecidimAwesome.texts.autosaved_error, true);
    return;
  }

  if (window.localStorage.getItem(storeId)) {
    showMsg(window.DecidimAwesome.texts.autosaved_retrieved, false, 5000);
  }

  // restore if available
  store.apply(); // eslint-disable-line prefer-reflect
  // restore checkboxes
  try {
    let checkboxes = JSON.parse(window.localStorage.getItem(storeCheckboxesId));
    for (let id in checkboxes) { // eslint-disable-line guard-for-in
      $(`#${id}`).prop("checked", checkboxes[id]);
    }
  } catch (evt) {
    console.log("No checkboxes found");
  }
  // this trigger the "change" event, it seems that it is too much
  // $form.find('input, textarea, select').change();

  const save = () => {
    store.save();
    // save checkbox manually
    let checkboxes = {};
    $form.find('input[type="checkbox"]').each((index, el) => {
      checkboxes[el.id] = el.checked;
    });
    window.localStorage.setItem(storeCheckboxesId, JSON.stringify(checkboxes));
    showMsg(window.DecidimAwesome.texts.autosaved_success);
  };

  // save changes when modifications
  $form.find("input, textarea, select").on("change", () => {
    save();
  });
});
