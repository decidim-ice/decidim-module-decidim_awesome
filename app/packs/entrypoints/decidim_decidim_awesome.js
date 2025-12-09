import "src/decidim/decidim_awesome/awesome_application.js"

// Load Stimulus controllers
import { definitionsFromContext } from "src/decidim/refactor/support/stimulus"

if (window.Stimulus) {
  const context = require.context("../src/decidim/controllers", true, /controller\.js$/)
  window.Stimulus.load(definitionsFromContext(context))
}

// // Images
require.context("../images", true)

// // CSS
import "entrypoints/decidim_decidim_awesome.scss";


