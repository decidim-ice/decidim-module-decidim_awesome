document.addEventListener("turbo:load", function() {
  document.querySelectorAll("[data-landing-menu]").forEach(function(nav) {
    nav.querySelectorAll(".awesome-landing-menu-element--link").forEach(function(link) {
      const href = link.getAttribute("href");
      if (href && href.startsWith("#") && !document.querySelector(href)) {
        const element = link.closest(".awesome-landing-menu-element");
        if (element) {
          element.remove();
        }
      }
    });

    nav.querySelectorAll(".awesome-landing-menu__mobile-dropdown li").forEach(function(li) {
      const link = li.querySelector("a");
      if (link) {
        const href = link.getAttribute("href");
        if (href && href.startsWith("#") && !document.querySelector(href)) {
          li.remove();
        }
      }
    });
  });
});
