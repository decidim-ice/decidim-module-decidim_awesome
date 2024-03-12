/**
 * Decidim rich text editor control plugin
 * Renders standard Decidim WYSIWYG editor
 *
 * Registers Decidim Richtext as a subtype for the textarea control
 */

import createEditor from "src/decidim/decidim_awesome/editor";

// configure the class for runtime loading
if (!window.fbControls) {
  window.fbControls = []
}
window.fbControls.push(function(controlClass, allControlClasses) {
  const controlTextarea = allControlClasses.textarea

  /**
   * DecidimRichtext control class
   *
   * NOTE: I haven't found a way to set the userData value using this plugin
   *       For this reason the value of the field must be collected manually
   *       from the hidden input name same as the field with the suffix '-input'
   */
  class controlRichtext extends controlTextarea {

    /**
     * Class configuration - return the icons & label related to this control
     * @return {JSON} definition object
     */
    static get definition() {
      return {
        icon: "📝",
        i18n: {
          default: "Rich Text Editor"
        }
      }
    }

    /**
     * configure the richtext editor requirements
     * @return {void}
     */
    configure() {
      window.fbEditors.tiptap = {};
    }

    /**
     * build a div DOM element & convert to a richtext editor
     * @return {DOMElement} DOM Element to be injected into the form.
     */
    build() {
      const { value, userData, ...attrs } = this.config;

      // hidden input for storing the current HTML value of the div
      this.inputId = `${this.id}-input`;
      // console.log("build plugin: this",this)
      this.input = this.markup("input", null, {
        name: name,
        id: this.inputId,
        type: "hidden",
        value: (userData && userData[0]) || value || ""
      });

      this.editorInput = this.markup("div", null, {
        style: "height: 25rem",
        class: "editor-input"
      });

      const options = this.classConfig && this.classConfig.editorOptions || {"contentTypes": {image: ["image/jpeg", "image/png"]}};
      const wrapperAttrs = {
        "id": attrs.id, 
        "name": attrs.name, 
        "type": attrs.type, 
        "className": "editor-container", 
        "data-toolbar": "basic", 
        "data-disabled": "false", 
        "data-options": JSON.stringify(options)
      };
      // console.log("build value", value, "userData", userData, "attrs", attrs, attrs.id, "wrapperAttrs", wrapperAttrs,"this",this);
      this.wrapper = this.markup("div", this.editorInput, wrapperAttrs);
      return this.markup("div", [this.input, this.wrapper], {style: "margin-top: 1rem"});
    }

    /**
     * When the element is rendered into the DOM, execute the following code to initialise it
     * @param {Object} evt - event
     * @return {Object} evt - event
     */
    onRender(evt) {
      if (window.fbEditors.tiptap[this.id]) {
        console.log("destroying editor", window.fbEditors.tiptap[this.id]);
        window.fbEditors.tiptap[this.id].instance.destroy();
      }

      window.fbEditors.tiptap[this.id] = {};
      const editor = window.fbEditors.tiptap[this.id];
      editor.instance = createEditor(this.wrapper);
      // const value = this.config.value || "";
      // console.log("render! editor", editor, "this", this, "value", value);
      // editor.data = new Delta();
      // if (value) {
      //   editor.instance.setContents(window.JSON.parse(this.parsedHtml(value)));
      // }
      // editor.instance.on('text-change', function(delta) {
      //   console.log("text-change", "delta", delta, "editor", editor);
      // //   // editor.data = editor.data.compose(delta);
      // });

      return evt;
    }
  }

  // register Decidim richtext as a richtext control
  controlTextarea.register("richtext", controlRichtext, "textarea");
})
