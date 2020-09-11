// = require form-storage.js
// = require_self

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
  const $form = $('form.answer-questionnaire');

  if (!$form.length) {
    if(window.DecidimAwesome.questionnaire_answered) {
      // console.log("Questionnaire already answered, remove any data saved");
      window.localStorage.removeItem(storeId);
    }
    // console.log("No forms here");
    return;
  }

  const store = new FormStorage(`#${$form.attr('id')}`, {
    name: storeId,
    ignores: [
      '[type="hidden"]',
    ],
  });

  const showMsg = (msg, error = false) => {
    const time = error ? 5000 : 700;
    const $div = $(`<div class="awesome_autosave-notice${error ? ' error' : ''}">${msg}</div>`)
      .appendTo($form);
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

  // restore if available
  store.apply();

  const save = () => {
    store.save();
    showMsg(window.DecidimAwesome.texts.autosaved_success);
  };

  // save changes when modifications
  $form.find('input, textarea, select').on('change', () => {
    save();
  });
});
