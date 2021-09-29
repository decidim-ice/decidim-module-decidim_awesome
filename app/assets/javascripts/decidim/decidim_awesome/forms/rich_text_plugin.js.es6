/**
 * Decidim rich text editor control plugin
 * Renders standard Decidim WYSIWYG editor
 *
 * Registers Decidim Richtext as a subtype for the textarea control
 */

// configure the class for runtime loading
if (!window.fbControls) window.fbControls = []
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
     * @returndefinition object
     */
    static get definition() {
      return {
        i18n: {
          default: 'Rich Text Editor'
        },
      }
    }

    /**
     * configure the richtext editor requirements
     */
    configure() {
      window.fbEditors.richtext = {};
    }

    /**
     * build a div DOM element & convert to a richtext editor
     * @return {DOMElement} DOM Element to be injected into the form.
     */
    build() {
      const { value, userData, ...attrs } = this.config;

      // hidden input for storing the current HTML value of the div
      this.inputId = this.id + '-input'
      this.input = this.markup('input', null, {
        name: name,
        id: this.inputId,
        type: 'hidden',
        value: (userData && userData[0]) || value
      });

      const css = this.markup(
        'style',
        `
        #${attrs.id} { height: auto; padding-left: 0; padding-right: 0; }
        #${attrs.id} div.ql-container { height: ${attrs.rows || 1}rem; }
        #${attrs.id} p.help-text { margin-top: .5rem; }
        `,
        { type: 'text/css' }
      );
      // console.log("build value", value, "userData", userData, "attrs", attrs, attrs.id);
      this.wrapper = this.markup('div', null, attrs);
      return this.markup('div', [css, this.input, this.wrapper], attrs);
    }

    /**
     * When the element is rendered into the DOM, execute the following code to initialise it
     * @param {Object} evt - event
     */
    onRender(evt) {
      // const value = this.config.value || '';
      if (window.fbEditors.richtext[this.id]) {
        // console.log("todo destroy", window.fbEditors.richtext[this.id]);
        // window.fbEditors.richtext[this.id].richtext('destroy')
      }

      window.fbEditors.quill[this.id] = {};
      const editor = window.fbEditors.quill[this.id];
      // createQuillEditor does all the job to update the hidden input wrapper
      editor.instance = new window.Decidim.createQuillEditor(this.wrapper);
      // editor.data = new Delta();
      // if (value) {
      //   editor.instance.setContents(window.JSON.parse(this.parsedHtml(value)));
      // }
      // editor.instance.on('text-change', function(delta) {
      //   console.log("text-change", "delta", delta, "editor", editor);
      // //   // editor.data = editor.data.compose(delta);
      // });

      // console.log("render! editor", editor, "this", this, "value", value);
      return evt
    }
  }

  // register Decidim richtext as a richtext control
  controlTextarea.register('richtext', controlRichtext, 'textarea');
})
