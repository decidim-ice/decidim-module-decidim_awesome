import "select2"

$(() => {
    $('select.multiusers-select').each(function() {
    const url = $(this).attr("data-url");
    $(this).select2({
      ajax: {
        url: url,
        delay: 100,
        dataType: "json",
        processResults: (data) => {
          return {
            results: data
          }
        }
      },
      escapeMarkup: (markup) => markup,
      templateSelection: (item) => `${item.text}`,
      minimumInputLength: 1,
      theme: "foundation"
    });
  });
});
