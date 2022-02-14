$(() => {
  let CustomFieldsBuilders = window.CustomFieldsBuilders || [];

  $("body").on("click", "a.awesome-auto-edit", (e) => {
    e.preventDefault();
    const $link = $(e.currentTarget);
    const scope = $link.data("scope");
    const $target = $(`span.awesome-auto-edit[data-scope="${scope}"]`);
    const $constraints = $(`.constraints-editor[data-key="${scope}"]`);
    if ($target.length == 0) {
      return;
    }

    const key = $target.data("key");
    const attribute = $target.data("var");
    const $hidden = $(`[name="config[${attribute}][${key}]"]`);
    const $multiple = $(`[name="config[${attribute}][${key}][]"]`);
    const $container = $(`.${attribute}_container[data-key="${key}"]`);
    const $delete = $(".delete-box", $container);

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
      // update hidden input if exists
      $hidden.attr("name", `config[${attribute}][${result.key}]`);
      $multiple.attr("name", `config[${attribute}][${result.key}][]`);
      $container.data("key", result.key);
      $container.attr("data-key", result.key);
      $delete.attr("href", $delete.attr("href").replace(`key=${key}`, `key=${result.key}`))
      CustomFieldsBuilders.forEach((builder) => {
        if (builder.key == key) {
          builder.key = result.key;
        }
      });
    };

    $target.html(`<input class="awesome-auto-edit" data-scope="${scope}" type="text" value="${key}">`);
    const $input = $(`input.awesome-auto-edit[data-scope="${scope}"]`);
    $link.hide();
    $input.select();
    $input.on("keypress", () => {
      if (e.code == "Enter" || e.code == "13" || e.code == "10") {
        e.preventDefault();
        $.ajax(
          {
            type: "POST",
            url: DecidimAwesome.rename_scope_label_path,
            dataType: "json",
            headers: {
              "X-CSRF-Token": $("meta[name=csrf-token]").attr("content")
            },
            data: { key: key,
              scope: scope,
              attribute: attribute,
              text: $input.val()
            }
          }).
          done((result) => rebuildHmtl(result)).
          fail((err) => {
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
