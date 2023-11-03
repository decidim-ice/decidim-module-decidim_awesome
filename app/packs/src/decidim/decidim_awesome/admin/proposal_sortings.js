import "select2"

$(() => {
  const $select = $("#config_additional_proposal_sortings");
  $select.select2({
    theme: "foundation"
  });
  $("#additional_proposal_sortings-enable-all").on("click", (evt) => {
    evt.preventDefault();
    $select.find("option").prop("selected", true);
    $select.trigger("change");
  });
});
