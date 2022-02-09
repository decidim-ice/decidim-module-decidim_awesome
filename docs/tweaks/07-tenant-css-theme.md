---
layout: default
title: Custom CSS themes for tenant
excerpt: "DecidimAwesome Tweak: Custom CSS themes  for tenant"
parent: Tweaks
nav_order: 7
---

# Custom CSS themes for every tenant

When customizing CSS for a Decidim installation, each change affects all the organizations (tenant).

This feature allows to customize each organization css without affecting the others in the same Decidim installation.

##### To create a theme

1. Get your hostname for the organization, theme search will be based on this (e.g: `myorganization.com`)
2. Create in you Decidim application this folder: `app/assets/themes/`
3. Create a file in that folder with the same name as the host and suffixed `.css` or `.scss` (e.g: `app/assets/themes/myorganization.com.scss`)
4. Modify that file as you like, you can use any SASS function available (such as `@import`)
5. Restart your server, enjoy!

See an example here:
https://github.com/Platoniq/decidim-demo/tree/master/app/assets/themes

NOTE: Files presents in the `app/assets/themes` folder are added automatically into the precompile list of Rails by this plugin.

## Sponsors

> TBD

