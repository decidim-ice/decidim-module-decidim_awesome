import FormStorage from "form-storage";

document.addEventListener("DOMContentLoaded", () => {
  window.DecidimAwesome = window.DecidimAwesome || {};
  if (!window.DecidimAwesome.auto_save_forms) {
    return;
  }

  const questionnaireId = window.DecidimAwesome.current_questionnaire;
  if (!questionnaireId) {
    return;
  }

  const getStorage = () => {
    try {
      return window.localStorage;
    } catch (evt) {
      return null;
    }
  };
  const storage = getStorage();

  const removeItems = (...keys) => {
    try {
      keys.forEach((key) => storage.removeItem(key));
    } catch (evt) {
      console.log("Could not clean autosaved data");
    }
  };

  const storeId = `awesome_autosave:v2:${questionnaireId}`;
  const storeCheckboxesId = `awesome_autosave:v2:checkboxes:${questionnaireId}`;
  if (storage) {
    removeItems(`awesome_autosave:${questionnaireId}`, `awesome_autosave:checkboxes:${questionnaireId}`);
  }
  const form = document.querySelector("form.response-questionnaire");

  if (!form) {
    if (storage && window.DecidimAwesome.questionnaire_answered) {
      removeItems(storeId, storeCheckboxesId);
    }
    return;
  }

  const store = new FormStorage(`#${form.id}`, {
    name: storeId,
    ignores: [
      '[type="hidden"]',
      '[name="utf8"]',
      '[name="authenticity_token"]'
    ]
  });

  const showMsg = (msg, error = false, defaultTime = 700) => {
    const time = error
      ? 5000
      : defaultTime;
    const div = document.createElement("div");
    div.className = `awesome_autosave-notice${error
      ? " error"
      : ""}`;
    div.innerHTML = msg;
    form.appendChild(div);
    setTimeout(() => {
      div.remove();
    }, time);
  };

  if (!storage) {
    showMsg(window.DecidimAwesome.i18n.autosavedError, true);
    return;
  }

  const questionIndexes = {};
  form.querySelectorAll(".question[data-question-id]").forEach((el) => {
    const input = el.querySelector('[name^="questionnaire[responses]["]');
    const match = input && input.name.match(/^questionnaire\[responses\]\[(\d+)\]/);
    if (match) {
      questionIndexes[el.dataset.questionId] = match[1];
    }
  });
  const questionIds = {};
  Object.keys(questionIndexes).forEach((questionId) => {
    questionIds[questionIndexes[questionId]] = questionId;
  });

  const translateKey = (key, pattern, toPrefix) => {
    const match = key.match(pattern);
    if (!match) {
      return key;
    }
    const prefix = toPrefix(match[1]);
    return prefix
      ? prefix + key.slice(match[0].length)
      : null;
  };

  const translateState = (state, translate) => {
    const result = new URLSearchParams();
    new URLSearchParams(state).forEach((value, key) => {
      const newKey = translate(key);
      if (newKey) {
        result.append(newKey, value);
      }
    });
    return result.toString();
  };

  const toQuestionName = (name) => translateKey(name, /^questionnaire\[responses\]\[(\d+)\]/, (idx) => questionIds[idx] && `questionnaire[responses][q${questionIds[idx]}]`);
  const toIndexName = (name) => translateKey(name, /^questionnaire\[responses\]\[q(\d+)\]/, (id) => questionIndexes[id] && `questionnaire[responses][${questionIndexes[id]}]`);
  const toQuestionId = (id) => translateKey(id, /^questionnaire_responses_(\d+)_/, (idx) => questionIds[idx] && `questionnaire_responses_q${questionIds[idx]}_`);
  const toIndexId = (id) => translateKey(id, /^questionnaire_responses_q(\d+)_/, (questionId) => questionIndexes[questionId] && `questionnaire_responses_${questionIndexes[questionId]}_`);

  let savedState = storage.getItem(storeId);
  if (savedState) {
    // restore if available
    try {
      store.applyState(translateState(savedState, toIndexName));
      showMsg(window.DecidimAwesome.i18n.autosavedRetrieved, false, 5000);
    } catch (evt) {
      removeItems(storeId, storeCheckboxesId);
      savedState = null;
    }
  }
  // restore checkboxes
  try {
    let checkboxes = JSON.parse(storage.getItem(storeCheckboxesId));
    Object.keys(checkboxes).forEach((id) => {
      if (Object.prototype.hasOwnProperty.call(checkboxes, id)) {// eslint-disable-line prefer-reflect
        const checkbox = document.getElementById(toIndexId(id));
        if (checkbox) {
          checkbox.checked = checkboxes[id];
        }
      }
    });
  } catch (evt) {
    console.log("No checkboxes found");
  }

  if (savedState) {
    form.querySelectorAll('input:not([type="hidden"]), textarea, select').forEach((el) => {
      el.dispatchEvent(new Event("change", { bubbles: true }));
    });
  }

  const save = () => {
    // save checkbox manually
    let checkboxes = {};
    form.querySelectorAll('input[type="checkbox"]').forEach((el) => {
      const id = toQuestionId(el.id);
      if (id) {
        checkboxes[id] = el.checked;
      }
    });
    try {
      storage.setItem(storeId, translateState(store.getState(), toQuestionName));
      storage.setItem(storeCheckboxesId, JSON.stringify(checkboxes));
    } catch (evt) {
      showMsg(window.DecidimAwesome.i18n.autosavedError, true);
      return;
    }
    showMsg(window.DecidimAwesome.i18n.autosavedSuccess);
  };

  // save changes when modifications
  form.addEventListener("change", save);

  form.addEventListener("submit", () => {
    removeItems(storeId, storeCheckboxesId);
  });
});
