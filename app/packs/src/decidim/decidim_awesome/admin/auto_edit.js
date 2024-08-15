$(() => {
  let CustomFieldsBuilders = window.CustomFieldsBuilders || [];

  $("body").on("click", "a.awesome-auto-edit", (ev) => {
    ev.preventDefault();
    const $link = $(ev.currentTarget);
    const scope = $link.data("scope");
    const $target = $(`span.awesome-auto-edit[data-scope="${scope}"]`);
    const $constraints = $(`.constraints-editor[data-key="${scope}"]`);
    if ($target.length === 0) {
      return;
    }

    const key = $target.data("key");
    const attribute = $target.data("var");
    const $hidden = $(`[name="config[${attribute}][${key}]"]`);
    const $multiple = $(`[name="config[${attribute}][${key}][]"]`);
    const $container = $(`.proposal_custom_fields_container[data-key="${key}"][data-var="${attribute}"]`);
    const $delete = $container.find(".delete-box");

    const rebuildLabel = (text, withScope) => {
      $target.text(text);
      $target.attr("data-key", text);
      $target.data("key", text);
      if (withScope) {
        $target.attr("data-scope", withScope);
        $target.data("scope", withScope);
        $link.attr("data-scope", withScope);
        $link.data("scope", withScope);
      }
      $link.show();
    };

    const rebuildHmtl = (result) => {
      rebuildLabel(result.key, result.scope);
      $constraints.replaceWith(result.html);

      $hidden.attr("name", `config[${attribute}][${result.key}]`);
      $multiple.attr("name", `config[${attribute}][${result.key}][]`);
      $container.data("key", result.key);
      $container.attr("data-key", result.key);

      if ($delete.length > 0) {
        $delete.attr("href", $delete.attr("href").replace(`key=${key}`, `key=${result.key}`));
      }

      CustomFieldsBuilders.forEach((builder) => {
        if (builder.key === key) {
          builder.key = result.key;
        }
      });
    };

    $target.html(`<input class="awesome-auto-edit" data-scope="${scope}" type="text" value="${key}">`);
    const $input = $(`input.awesome-auto-edit[data-scope="${scope}"]`);
    $link.hide();
    $input.select();
    $input.on("keypress", (evt) => {
      if (evt.code === "Enter" || evt.code === "13" || evt.code === "10") {
        evt.preventDefault();
        $.ajax({
          type: "POST",
          url: window.DecidimAwesome.rename_scope_label_path,
          dataType: "json",
          headers: {
            "X-CSRF-Token": $("meta[name=csrf-token]").attr("content")
          },
          data: {
            key: key,
            scope: scope,
            attribute: attribute,
            text: $input.val()
          }
        })
          .done((result) => rebuildHmtl(result))
          .fail((err) => {
            console.error("Error saving key", key, "ERR:", err);
            rebuildLabel(key);
          });
      }
    });
    $input.on("blur", () => {
      rebuildLabel(key);
    });
  });
});
