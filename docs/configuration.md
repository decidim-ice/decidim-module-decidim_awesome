---
layout: default
title: Configuration
nav_order: 2
---
# Configuration
{: .no_toc }


All features are enabled by default and can be customized or disabled. Once a feature is disabled admins won't be able to tweak it.
{: .fs-6 .fw-300 }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---




In order to personalize default values, create an `initializer` file such as:

```ruby
# config/initializers/awesome_defaults.rb

# Change some variables defaults
Decidim::DecidimAwesome.configure do |config|
  # Enabled by default to all scopes, admins can still limit it's scope
  config.allow_images_in_full_editor = true

  # Disabled by default to all scopes, admins can enable it and limit it's scope
  config.allow_images_in_small_editor = false

  # De-activated, admins don't even see it as an option
  config.use_markdown_editor = :disabled

  # Disable scoped admins
  config.scoped_admins = :disabled

  # any other config var from lib/decidim/decidim_awesome.rb
  ...
end
```

For a complete list of options take a look at the [module defaults](https://github.com/Platoniq/decidim-module-decidim_awesome/blob/main/lib/decidim/decidim_awesome.rb).
