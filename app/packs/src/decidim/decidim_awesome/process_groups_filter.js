// Fetch-based content replacement for process groups filters.
// Avoids full page reload to preserve scroll position.

/**
 * Finds the closest content container for a given element.
 * @param {Element} element - DOM element inside the container.
 * @returns {Element|null} The container element or null.
 */
const getContainer = function(element) {
  return element.closest("[data-process-groups-content]");
};

/**
 * Fetches a URL and replaces the container's inner HTML with the fresh content.
 * @param {Element} container - The content container to update.
 * @param {string} url - The URL to fetch.
 * @param {boolean} pushState - Whether to update browser history.
 * @returns {void}
 */
const fetchAndReplace = function(container, url, pushState = true) {
  const containerId = container.id;
  if (!containerId) {
    window.location.href = url;
    return;
  }

  fetch(url).
    then((response) => response.text()).
    then((html) => {
      const doc = new DOMParser().parseFromString(html, "text/html");
      const fresh = doc.getElementById(containerId);
      if (fresh) {
        container.innerHTML = fresh.innerHTML;
      } else {
        window.location.href = url;
      }
      if (pushState) {
        window.history.pushState({}, "", url);
      }
    }).
    catch(() => {
      window.location.href = url;
    });
};

/**
 * Builds a GET URL from the form's action and current field values.
 * @param {HTMLFormElement} form - The form element.
 * @returns {string} The constructed URL with query params.
 */
const formUrl = function(form) {
  const params = new URLSearchParams(new FormData(form));
  return `${form.action}?${params}`;
};

// Checkbox change: toggle children if parent, then fetch filtered results.
document.addEventListener("change", (event) => {
  if (event.target.type !== "checkbox") {
    return;
  }

  const form = event.target.closest("[data-auto-submit-form]");
  if (!form) {
    return;
  }

  const parentId = event.target.dataset.parentCheckbox;
  if (parentId) {
    form.querySelectorAll(`input[data-parent-taxonomy="${parentId}"]`).
      forEach((ch) => {
        ch.checked = event.target.checked;
      });
  }

  const container = getContainer(form);
  if (container) {
    fetchAndReplace(container, formUrl(form));
  }
});

// Remove tag: uncheck the matching checkbox, then fetch.
document.addEventListener("click", (event) => {
  const button = event.target.closest("[data-remove-tag]");
  if (!button) {
    return;
  }

  const container = getContainer(button);
  if (!container) {
    return;
  }

  const form = container.querySelector("[data-auto-submit-form]");
  if (!form) {
    return;
  }

  const checkbox = form.querySelector(
    `input[name="taxonomy_ids[]"][value="${button.dataset.removeTag}"]`
  );
  if (checkbox) {
    checkbox.checked = false;
  }

  fetchAndReplace(container, formUrl(form));
});

// Status tabs and pagination: fetch instead of full-page navigation.
document.addEventListener("click", (event) => {
  const link = event.target.closest(
    "[data-process-groups-content] .process-groups-filter-tab, " +
      "[data-process-groups-content] .process-groups-pagination a"
  );
  if (!link || !link.href) {
    return;
  }

  event.preventDefault();
  const container = getContainer(link);
  if (container) {
    fetchAndReplace(container, link.href);
  }
});

// Browser back/forward: re-fetch to keep content in sync with URL.
window.addEventListener("popstate", () => {
  document.querySelectorAll("[data-process-groups-content]").
    forEach((container) => {
      fetchAndReplace(container, window.location.href, false);
    });
});
