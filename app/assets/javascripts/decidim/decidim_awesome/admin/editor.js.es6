// = require quill.min
// = require image-upload.min
// = require image-resize.min
// = require_self

((exports) => {
  exports.DecidimAwesome = exports.DecidimAwesome || {};

  // Redefines Quill editor with images
  if(exports.DecidimAwesome.allow_images_in_full_editor  || exports.DecidimAwesome.allow_images_in_small_editor) {

	  const quillFormats = ["bold", "italic", "link", "underline", "header", "list", "video", "image"];

	  const createQuillEditor = (container) => {
	    const toolbar = $(container).data("toolbar");
	    const disabled = $(container).data("disabled");

	    let quillToolbar = [
	      ["bold", "italic", "underline"],
	      [{ list: "ordered" }, { list: "bullet" }],
	      ["link", "clean"]
	    ];

	    if (toolbar === "full") {
	      quillToolbar = [
	        [{ header: [1, 2, 3, 4, 5, 6, false] }],
	        ...quillToolbar,
	        exports.DecidimAwesome.allow_images_in_full_editor ? ["video", "image"] : ["video"]
	      ];
	    } else if (toolbar === "basic") {
	      quillToolbar = [
	        ...quillToolbar,
	        exports.DecidimAwesome.allow_images_in_small_editor ? ["video", "image"] : ["video"]
	      ];
	    }

	    const $input = $(container).siblings('input[type="hidden"]');
	    const token = $( 'meta[name="csrf-token"]' ).attr( 'content' );
	    const quill = new Quill(container, {
	      modules: {
	        toolbar: quillToolbar,
	        imageResize: {
	          modules: ["Resize", "DisplaySize"]
	        },
	        imageUpload: {
						url: exports.DecidimAwesome.editor_uploader_path, // server url. If the url is empty then the base64 returns
						method: 'POST', // change query method, default 'POST'
						name: 'image', // custom form name
						withCredentials: false, // withCredentials
						headers: { 'X-CSRF-Token': token }, // add custom headers, example { token: 'your-token'}
						// personalize successful callback and call next function to insert new url to the editor
						callbackOK: (serverResponse, next) => {
							$(quill.getModule("toolbar").container).last().removeClass('editor-loading')
							next(serverResponse.url);
						},
						// personalize failed callback
						callbackKO: serverError => {
							$(quill.getModule("toolbar").container).last().removeClass('editor-loading')
							alert(serverError.message);
						},
						checkBeforeSend: (file, next) => {
							$(quill.getModule("toolbar").container).last().addClass('editor-loading')
							next(file); // go back to component and send to the server
						}
					}
	      },
	      formats: quillFormats,
	      theme: "snow"
	    });

	    if (disabled) {
	      quill.disable();
	    }

	    quill.on("text-change", () => {
	      const text = quill.getText();

	      // Triggers CustomEvent with the cursor position
	      // It is required in input_mentions.js
	      let event = new CustomEvent("quill-position", {
	        detail: quill.getSelection()
	      });
	      container.dispatchEvent(event);

	      if (text === "\n") {
	        $input.val("");
	      } else {
	        $input.val(quill.root.innerHTML);
	      }
	    });

	    quill.root.innerHTML = $input.val() || "";
	  };

	  const quillEditor = () => {
	    $(".editor-container").each((idx, container) => {
	      createQuillEditor(container);
	    });
	  };

	  exports.Decidim = exports.Decidim || {};
	  exports.Decidim.quillEditor = quillEditor;
	  exports.Decidim.createQuillEditor = createQuillEditor;

  }
})(window);