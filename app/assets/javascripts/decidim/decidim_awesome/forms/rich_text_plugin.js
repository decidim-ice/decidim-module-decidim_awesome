"use strict";

function _typeof(obj) {
  "@babel/helpers - typeof";
  if (typeof Symbol === "function" && typeof Symbol.iterator === "symbol") {
    _typeof = function _typeof(obj) {
      return typeof obj;
    };
  } else {
    _typeof = function _typeof(obj) {
      return obj &&
        typeof Symbol === "function" &&
        obj.constructor === Symbol &&
        obj !== Symbol.prototype
        ? "symbol"
        : typeof obj;
    };
  }
  return _typeof(obj);
}

var _excluded = ["value", "userData"];

function _objectWithoutProperties(source, excluded) {
  if (source == null) return {};
  var target = _objectWithoutPropertiesLoose(source, excluded);
  var key, i;
  if (Object.getOwnPropertySymbols) {
    var sourceSymbolKeys = Object.getOwnPropertySymbols(source);
    for (i = 0; i < sourceSymbolKeys.length; i++) {
      key = sourceSymbolKeys[i];
      if (excluded.indexOf(key) >= 0) continue;
      if (!Object.prototype.propertyIsEnumerable.call(source, key)) continue;
      target[key] = source[key];
    }
  }
  return target;
}

function _objectWithoutPropertiesLoose(source, excluded) {
  if (source == null) return {};
  var target = {};
  var sourceKeys = Object.keys(source);
  var key, i;
  for (i = 0; i < sourceKeys.length; i++) {
    key = sourceKeys[i];
    if (excluded.indexOf(key) >= 0) continue;
    target[key] = source[key];
  }
  return target;
}

function _classCallCheck(instance, Constructor) {
  if (!(instance instanceof Constructor)) {
    throw new TypeError("Cannot call a class as a function");
  }
}

function _defineProperties(target, props) {
  for (var i = 0; i < props.length; i++) {
    var descriptor = props[i];
    descriptor.enumerable = descriptor.enumerable || false;
    descriptor.configurable = true;
    if ("value" in descriptor) descriptor.writable = true;
    Object.defineProperty(target, descriptor.key, descriptor);
  }
}

function _createClass(Constructor, protoProps, staticProps) {
  if (protoProps) _defineProperties(Constructor.prototype, protoProps);
  if (staticProps) _defineProperties(Constructor, staticProps);
  return Constructor;
}

function _inherits(subClass, superClass) {
  if (typeof superClass !== "function" && superClass !== null) {
    throw new TypeError("Super expression must either be null or a function");
  }
  subClass.prototype = Object.create(superClass && superClass.prototype, {
    constructor: { value: subClass, writable: true, configurable: true }
  });
  if (superClass) _setPrototypeOf(subClass, superClass);
}

function _setPrototypeOf(o, p) {
  _setPrototypeOf =
    Object.setPrototypeOf ||
    function _setPrototypeOf(o, p) {
      o.__proto__ = p;
      return o;
    };
  return _setPrototypeOf(o, p);
}

function _createSuper(Derived) {
  var hasNativeReflectConstruct = _isNativeReflectConstruct();
  return function _createSuperInternal() {
    var Super = _getPrototypeOf(Derived),
      result;
    if (hasNativeReflectConstruct) {
      var NewTarget = _getPrototypeOf(this).constructor;
      result = Reflect.construct(Super, arguments, NewTarget);
    } else {
      result = Super.apply(this, arguments);
    }
    return _possibleConstructorReturn(this, result);
  };
}

function _possibleConstructorReturn(self, call) {
  if (call && (_typeof(call) === "object" || typeof call === "function")) {
    return call;
  } else if (call !== void 0) {
    throw new TypeError(
      "Derived constructors may only return object or undefined"
    );
  }
  return _assertThisInitialized(self);
}

function _assertThisInitialized(self) {
  if (self === void 0) {
    throw new ReferenceError(
      "this hasn't been initialised - super() hasn't been called"
    );
  }
  return self;
}

function _isNativeReflectConstruct() {
  if (typeof Reflect === "undefined" || !Reflect.construct) return false;
  if (Reflect.construct.sham) return false;
  if (typeof Proxy === "function") return true;
  try {
    Boolean.prototype.valueOf.call(
      Reflect.construct(Boolean, [], function () {})
    );
    return true;
  } catch (e) {
    return false;
  }
}

function _getPrototypeOf(o) {
  _getPrototypeOf = Object.setPrototypeOf
    ? Object.getPrototypeOf
    : function _getPrototypeOf(o) {
        return o.__proto__ || Object.getPrototypeOf(o);
      };
  return _getPrototypeOf(o);
}

/**
 * Decidim rich text editor control plugin
 * Renders standard Decidim WYSIWYG editor
 *
 * Registers Decidim Richtext as a subtype for the textarea control
 */
// configure the class for runtime loading
if (!window.fbControls) window.fbControls = [];
window.fbControls.push(function (controlClass, allControlClasses) {
  var controlTextarea = allControlClasses.textarea;
  /**
   * DecidimRichtext control class
   *
   * NOTE: I haven't found a way to set the userData value using this plugin
   *       For this reason the value of the field must be collected manually
   *       from the hidden input name same as the field with the suffix '-input'
   */

  var controlRichtext = /*#__PURE__*/ (function (_controlTextarea) {
    _inherits(controlRichtext, _controlTextarea);

    var _super = _createSuper(controlRichtext);

    function controlRichtext() {
      _classCallCheck(this, controlRichtext);

      return _super.apply(this, arguments);
    }

    _createClass(
      controlRichtext,
      [
        {
          key: "configure",
          value:
            /**
             * configure the richtext editor requirements
             */
            function configure() {
              window.fbEditors.richtext = {};
            }
          /**
           * build a div DOM element & convert to a richtext editor
           * @return {DOMElement} DOM Element to be injected into the form.
           */
        },
        {
          key: "build",
          value: function build() {
            var _this$config = this.config,
              value = _this$config.value,
              userData = _this$config.userData,
              attrs = _objectWithoutProperties(_this$config, _excluded); // hidden input for storing the current HTML value of the div

            this.inputId = this.id + "-input";
            this.input = this.markup("input", null, {
              name: name,
              id: this.inputId,
              type: "hidden",
              value: (userData && userData[0]) || value
            });
            var css = this.markup(
              "style",
              "\n        #"
                .concat(
                  attrs.id,
                  " { height: auto; padding-left: 0; padding-right: 0; }\n        #"
                )
                .concat(attrs.id, " div.ql-container { height: ")
                .concat(attrs.rows || 1, "rem; }\n        #")
                .concat(
                  attrs.id,
                  " p.help-text { margin-top: .5rem; }\n        "
                ),
              {
                type: "text/css"
              }
            ); // console.log("build value", value, "userData", userData, "attrs", attrs, attrs.id);

            this.wrapper = this.markup("div", null, attrs);
            return this.markup("div", [css, this.input, this.wrapper], attrs);
          }
          /**
           * When the element is rendered into the DOM, execute the following code to initialise it
           * @param {Object} evt - event
           */
        },
        {
          key: "onRender",
          value: function onRender(evt) {
            // const value = this.config.value || '';
            if (window.fbEditors.richtext[this.id]) {
              // console.log("todo destroy", window.fbEditors.richtext[this.id]);
              // window.fbEditors.richtext[this.id].richtext('destroy')
            }

            window.fbEditors.quill[this.id] = {};
            var editor = window.fbEditors.quill[this.id]; // createQuillEditor does all the job to update the hidden input wrapper

            editor.instance = window.Decidim.createQuillEditor(this.wrapper); // editor.data = new Delta();
            // if (value) {
            //   editor.instance.setContents(window.JSON.parse(this.parsedHtml(value)));
            // }
            // editor.instance.on('text-change', function(delta) {
            //   console.log("text-change", "delta", delta, "editor", editor);
            // //   // editor.data = editor.data.compose(delta);
            // });
            // console.log("render! editor", editor, "this", this, "value", value);

            return evt;
          }
        }
      ],
      [
        {
          key: "definition",
          get:
            /**
             * Class configuration - return the icons & label related to this control
             * @returndefinition object
             */
            function get() {
              return {
                icon: "📝",
                i18n: {
                  default: "Rich Text Editor"
                }
              };
            }
        }
      ]
    );

    return controlRichtext;
  })(controlTextarea); // register Decidim richtext as a richtext control

  controlTextarea.register("richtext", controlRichtext, "textarea");
});
