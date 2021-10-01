// = require_self

$(() => {
  $("body").on("click", "a.awesome-auto-edit", (e) => {
    e.preventDefault();
    const $link = $(e.currentTarget);
    console.log($link)
    const scope = $link.data("scope");
    const $target = $(`span.awesome-auto-edit[data-scope="${scope}"]`);
    if($target.length == 0) return;
    
    const key = $target.data('key');
    const attribute = $target.data('var');

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
          (result) => {
            console.log(result)
            $target.text(result.key);
            $target.attr("data-key", result.key);
            $target.attr("data-scope", result.scope);
            $link.attr("data-scope", result.scope);
            $target.data("key", result.key);
            $target.data("scope", result.scope);
            $link.data("scope", result.scope);
            $link.show();          
          }, 
          "json").fail((err) => {
            console.error(err, key, $target);
            $target.text(key);
            $link.show();      
          })
      }
    });
    $input.on("blur", () => {
      $target.text(key);
      $link.show();
    });
  });
});