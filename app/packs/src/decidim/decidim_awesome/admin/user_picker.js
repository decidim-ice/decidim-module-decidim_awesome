import TomSelect from "tom-select/dist/cjs/tom-select.popular";

document.addEventListener("DOMContentLoaded", () => {
  const tagContainers = document.querySelectorAll(".multiusers-select");
  const config = (element) => ({
    plugins: ["remove_button", "dropdown_input"],
    create: false,
    render: {
      option: function (data, escape) {
        return `<div>${escape(data.text)}</div>`;
      },
      item: function (data, escape) {
        return Boolean(data.is_admin) || data.isAdmin === "true"
          ? `<div class="is-admin">${escape(data.text)}</div>`
          : `<div>${escape(data.text)}</div>`;
      }
    },
    shouldLoad: function (query) {
      return query.length > 1;
    },
    load: function (query, callback) {
      const { url } = element.dataset;
      const join = url.includes("?")
        ? "&"
        : "?";
      const params = new URLSearchParams({
        term: query
      });

      fetch(`${url}${join}${params}`).
        then((response) => response.json()).
        then((json) => callback(json)).
        catch(() => callback());
    }
  });

  tagContainers.forEach((container) => new TomSelect(container, config(container)));
});
