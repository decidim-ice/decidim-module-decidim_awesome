import DataPicker from "src/decidim/data_picker"

$(() => {
  const $modal = $("#awesome-verification-modal");
  $(".awesome_participants-td a.managed[data-verification-handler]").on("click", function(evt) {
    evt.preventDefault();
    $("#awesome-verification-modal").foundation("open");
    
    const $button = $(evt.target);
    const url = $button.data("verificationUrl");
    // console.log("button", $button, "modal", $modal, "url", url, "user", user);
    fetch(url).then((res) => res.text()).then((html) => {
      $modal.html(html);  
      $modal.data("datapicker", new DataPicker($modal.find(".data-picker")));
    });
  });

  $(document).on("ajax:complete", (responseText) => {
    const response = JSON.parse(responseText.detail[0].response)
    const $button = $(`[data-verification-handler="${response.handler}"][data-verification-user-id="${response.userId}"]`);
    console.log("ajax:complete", responseText, "response", response, "button", $button);
    $modal.html(response.message);

    if (response.granted) {
      $button.addClass("granted");
    } else {
      $button.removeClass("granted");
      const $forceVerificationCheck = $modal.find("#force_verification_check");
      const $forceVerification = $modal.find("#force_verification");

      if ($forceVerificationCheck.length) {
        $forceVerificationCheck.on("change", function() {
          $forceVerification.prop("disabled", !$forceVerification.prop("disabled"));
          if ($forceVerificationCheck.is(":checked")) {
            $forceVerification.focus();
          }
        });
      }
    }
  });
});
