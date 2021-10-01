// = require_self

let formBuilderList = formBuilderList || [];
let DecidimAwesome = DecidimAwesome || {};
$(() => {
  $("body").on("click", "a.awesome-auto-edit", (e) => {
    e.preventDefault();
    const $link = $(e.currentTarget);
    const scope = $link.data("scope");
    const $target = $(`span.awesome-auto-edit[data-scope="${scope}"]`);
    const $constraints = $(`.constraints-editor[data-key="${scope}"]`);
    if($target.length == 0) return;
    
    const key = $target.data('key');
    const attribute = $target.data('var');
    const $hidden = $(`input[name="config[${attribute}][${key}]"]`);
    const $container = $(`.${attribute}_container[data-key="${key}"]`);
    const $delete = $('.delete-box', $container);

    const rebuildLabel = (text, scope) => {
      $target.text(text);
      $target.attr("data-key", text);
      $target.data("key", text);
      if(scope) {
        $target.attr("data-scope", scope);
        $target.data("scope", scope);
        $link.attr("data-scope", scope);
        $link.data("scope", scope);
      }
      $link.show();
    };

    const rebuildHmtl = (result) => {
      rebuildLabel(result.key, result.scope);
      $constraints.replaceWith(result.html);
      // update hidden input if exists
      $hidden.attr("name", `config[${attribute}][${result.key}]`);
      $container.data("key", result.key);
      $container.attr("data-key", result.key);
      $delete.attr("href", $delete.attr("href").replace(`key=${key}`, `key=${result.key}`))
      formBuilderList.forEach((builder) => {
        if(builder.key == key) {
          builder.key = result.key;
        }
      });
    };

    $target.html(`<input class="awesome-auto-edit" data-scope="${scope}" type="text" value="${key}">`);
    const $input = $(`input.awesome-auto-edit[data-scope="${scope}"]`);
    $link.hide();
    $input.select();
    $input.on("keypress", (e) => {
      // if(e.code == "Space") {
      //   e.preventDefault();
      // }
      if(e.code == "Enter") {
        e.preventDefault();
        $.post(DecidimAwesome.rename_scope_label_path, 
          { key: key, 
            scope: scope, 
            attribute: attribute, 
            text: $input.val() 
          },
          (result) => rebuildHmtl(result), 
          "json").fail((err) => {
            console.error("Error saving key", key, "ERR:", err);
            rebuildLabel(key);
          })
      }
    });
    $input.on("blur", () => {
      rebuildLabel(key);
    });
  });
});