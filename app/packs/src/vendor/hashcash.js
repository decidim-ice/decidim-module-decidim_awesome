// http://www.hashcash.org/docs/hashcash.html
// <input type="hidden" name="hashcash" data-hashcash="{resource: 'site.example', bits: 16}"/>

import Stamp from "src/vendor/stamp"

export default class Hashcash {
  static default = {
    version: 1,
    bits: 20,
    extension: null,
  }

  constructor(input) {
    this.options = JSON.parse(input.getAttribute("data-hashcash"))
    this.input = input
    this.disableParentForm()
    this.input.dispatchEvent(new CustomEvent("hashcash:mint", {bubbles: true}))

    this.mint((stamp) => {
      this.input.value = stamp.toString()
      // console.log("Hashcash stamp: ", stamp)
      // console.log("Hashcash input: ", this.input.value)
      this.enableParentForm()
      this.input.dispatchEvent(new CustomEvent("hashcash:minted", {bubbles: true, detail: {stamp: stamp}}))
    })
  }

  static setup() {
    if (document.readyState != "loading") {
      var input = document.querySelector("input#hashcash")
      input && new Hashcash(input)
    } else
      document.addEventListener("DOMContentLoaded", Hashcash.setup )
  }

  setSubmitText(submit, text) {
    if (!text) {
      return
    }
    if (submit.tagName == "BUTTON") {
      !submit.originalValue && (submit.originalValue = submit.innerHTML)
      submit.innerHTML = text
    } else {
      !submit.originalValue && (submit.originalValue = submit.value)
      submit.value = text
    }
  }
  
  disableParentForm() {
    this.input.form.querySelectorAll("[type=submit]").forEach((submit) => {    
      this.setSubmitText(submit, this.options["waiting_message"])
      submit.disabled = true
    })
  }
  
  enableParentForm() {
    this.input.form.querySelectorAll("[type=submit]").forEach((submit) => {
      this.setSubmitText(submit, submit.originalValue)
      submit.disabled = null
    })
  }

  mint(callback) {
    var options = this.options
    var resource = this.options.resource
    // Format date to YYMMDD
    var date = new Date
    var year = date.getFullYear().toString()
    year = year.slice(year.length - 2, year.length)
    var month = (date.getMonth() + 1).toString().padStart(2, "0")
    var day = date.getDate().toString().padStart(2, "0")
  
    var stamp = new Stamp(
      options.version || Hashcash.default.version,
      options.bits || Hashcash.default.bits,
      options.date || year + month + day,
      resource,
      options.extension || Hashcash.default.extension,
      options.rand || Math.random().toString(36).substr(2, 10),
    )
    return stamp.work(callback)
  }
}