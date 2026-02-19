document.addEventListener("turbo:load", () => {
  const container = document.querySelector("[data-process-groups-filter]");
  if (!container) return;

  const tabs = container.querySelectorAll("[data-filter]");
  const items = container.querySelectorAll("[data-status]");

  const applyFilter = (filter) => {
    tabs.forEach((tab) => {
      tab.classList.toggle("is-active", tab.dataset.filter === filter);
    });

    items.forEach((item) => {
      item.style.display = (filter === "all" || item.dataset.status === filter) ? "" : "none";
    });
  };

  tabs.forEach((tab) => {
    tab.addEventListener("click", () => applyFilter(tab.dataset.filter));
  });
});
