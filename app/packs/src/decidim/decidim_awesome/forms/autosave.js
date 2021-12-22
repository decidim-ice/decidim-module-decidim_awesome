import "form-storage"
import "decode-uri-component"
import "form-serialize"
import "query-string-es5"

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
  const $form = $('form.answer-questionnaire');

  if (!$form.length) {
    if(window.DecidimAwesome.questionnaire_answered) {
      // console.log("Questionnaire already answered, remove any data saved");
      window.localStorage.removeItem(storeId);
      window.localStorage.removeItem(storeCheckboxesId);
    }
    // console.log("No forms here");
    return;
  }

  const store = new FormStorage(`#${$form.attr('id')}`, {
    name: storeId,
    ignores: [
      // '[type="hidden"]',
      '[name="utf8"]',
      '[name="authenticity_token"]',
      '[disabled]',
      '[type="checkbox"]' // there are problems with matrix questions
    ],
  });

  const showMsg = (msg, error = false, default_time = 700) => {
    const time = error ? 5000 : default_time;
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

  if(window.localStorage.getItem(storeId)) {
    showMsg(window.DecidimAwesome.texts.autosaved_retrieved, false, 5000);
  }

  // restore if available
  store.apply();
  // restore checkboxes
  try {
    let checkboxes = JSON.parse(window.localStorage.getItem(storeCheckboxesId));
    for(let id in checkboxes) {
      $("#" + id).prop("checked", checkboxes[id]);
    }
  } catch(e){
    console.log("No checkboxes found");
  }
  // fire change items
  $form.find('input, textarea, select').change();

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
  $form.find('input, textarea, select').on('change', () => {
    save();
  });
});
