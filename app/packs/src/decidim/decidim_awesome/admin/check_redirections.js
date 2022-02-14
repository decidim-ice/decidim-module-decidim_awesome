$(() => {
  $(".check-custom-redirections").on("click", (evt) => {
    evt.preventDefault();
    
    if ($(evt.target).hasClass("disabled")) {
      return;
    }
    
    $(evt.target).addClass("disabled");

    const getReport = (tr, response) => {
      const item = $(tr).data("item");
      const $td = $(tr).find(".redirect-status");

      let type = response.type;
      let status = response.status;
      if (response.type == "opaqueredirect") {
        type = "redirect";
        status = "302";
      }

      if (item.active) {
        if (type ==  "redirect") {
          $td.addClass("success");
        } else {
          $td.addClass("alert");
        }
      } else {
        $td.addClass("muted");
      }

      return `${type} (${status})`;
    };

    $("tr.custom-redirection").each((index, tr) => {
      const $td = $(tr).find(".redirect-status");
      $td.html('<span class="loading-spinner" />');
      fetch($(tr).data("origin"), {method: "HEAD", redirect: "manual"}).
        then((response) => {
          $td.html(getReport(tr, response))
        }).
        catch((error) => {
          console.error("ERROR", error)  
          $td.removeClass("loading");
        });
    });
  });
});
