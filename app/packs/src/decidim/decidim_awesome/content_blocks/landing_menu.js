document.addEventListener("DOMContentLoaded", function() {
  document.querySelectorAll("[data-landing-menu]").forEach(function(nav) {
    nav.querySelectorAll(".landing-menu__link").forEach(function(link) {
      const href = link.getAttribute("href");
      if (href && href.startsWith("#") && !document.querySelector(href)) {
        link.remove();
      }
    });

    nav.querySelectorAll(".landing-menu__mobile-dropdown li").forEach(function(li) {
      const link = li.querySelector("a");
      if (link) {
        const href = link.getAttribute("href");
        if (href && href.startsWith("#") && !document.querySelector(href)) {
          li.remove();
        }
      }
    });

    nav.classList.remove("hidden");
  });
});
