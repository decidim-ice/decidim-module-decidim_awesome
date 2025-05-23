CHANGELOG
=========

v0.12.2
-------

Compatibility:
  - Decidim 0.29.x

Feature:
  - Added HashCash anti-bot mechanism
  - Fixed multi-tenant crossover in admin accountability

v0.12.1
-------

Compatibility:
  - Decidim 0.29.x

Feature:
  - Added formBuilder languages controller to avoid external CDN
  - Fix cache hash in the global menu override
  - Fix crash on updating empty boxes for scoped admins

v0.12.0
-------
Compatibility:
  - Decidim 0.29.x

Features:
  - Upgrade to Decidim v0.29

v0.11.4
-------
Compatibility:
  - Decidim 0.28.x

Features:
  - Fix allowing to accept terms and conditions when forced verifications enabled
  - Some other minor fixes
  - Basque translations

v0.11.3
-------
Compatibility:
  - Decidim v0.28.x

Features:
  - Added user time zones in account settings
  - Added custom styles for the admin panel
  - Added Verification tweaks
  - Added Admin manual verifications

v0.11.2
-------

Compatibility:
  - Decidim v0.28.x

Features:
  - SQL vulnerability fix for admin accountability
  - Private fields proposal draft update fix

v0.11.1
------

Compatibility:
  - Decidim v0.28.x

Features:
  - Added Private Custom Fields feature
  - Added GraphQL types for weighted voting in the API
  - Added GraphQL types for custom fields in the API
  - Adds parsed information about custom fields in the Proposals export
  - Adds parsed information bout private custom fields when admins exports private data
  - Adds a maintenance menu with tools to remove old private data

v0.11
------

Compatibility:
  - Decidim v0.28.x

Features:
  - Redesign to version 0.28
  - Removed markdown editor

v0.10.2
------

Compatibility:
  - Decidim v0.27.4
  - Decidim v0.26.8

Features:
  - Added translations
  - Fix deface override updating <body> tag in the admin

v0.10.1
------

Compatibility:
  - Decidim v0.27.4
  - Decidim v0.26.8

Features:
  - Added translations
  - Fix deface override updating <body> tag
  - Fix ordering with accents

v0.10.0
------

Compatibility:
  - Decidim v0.27.4
  - Decidim v0.26.8

Features:
  - Migrate to [Deface](https://github.com/spree/deface) for overrides
  - Introduce Weighted Voting with configurable manifests for different types of voting with grades
  - Fix wrong behavior showing proposals on map
  - Introduced new sorting options for proposals. Added alphabetical sorting, reverse sorting, sorting by votes first and last.

v0.9.3
------

Compatibility:
  - Decidim v0.27.3
  - Decidim v0.26.7

Features:
  - Fixes for admin accountability leaking other tenants data

v0.9.2
------

Compatibility:
  - Decidim v0.27.3
  - Decidim v0.26.7

Features:
  - Fixes for the menu hacker

v0.9.1
------

Compatibility:
  - Decidim v0.27.x
  - Decidim v0.26.x

Features:
  - Fixes for the Awesome Map
  - Added Admin Accountability feature

v0.9.0
------

Compatibility:
  - Decidim v0.27.x
  - Decidim v0.26.x

Features:
  - Upgrade 0.27 version

v0.8.4
------

Compatibility:
  - Decidim v0.26.x
  - Decidim v0.25.x

Features:
  - Feature: Override validation rules for title and body in proposals, with constrains available
  - Improve loading process to facilitate development

v0.8.3
------

Compatibility:
  - Decidim v0.26.x
  - Decidim v0.25.x

Features:
  - Fix error 500 when visiting pages with questionnaires that are not created
  - Added German language

v0.8.2
------

Compatibility:
  - Decidim v0.26.x
  - Decidim v0.25.x

Features:
  - Fixes in the quill editor

v0.8.1
------

Compatibility:
  - Decidim v0.26.x
  - Decidim v0.25.x

Features:
  - Fixes in the 0.26 webpacker compatibility

v0.8.0
------

Compatibility:
  - Decidim v0.26.x
  - Decidim v0.25.x

Features:
  - Several bug fixing related to deactivating features (now there's a test for it).
  - Now awesome components can be disabled using the `disabled_components` configuration var.
  - Feature: Custom redirections editor: Create shorter URL redirections to other places, inside or outside Decidim.
  - Update to webpacker compatiblity and Decidim 0.25
  - Added tasks `bin/rails decidim_awesome:active_storage_migrations:check_migration_from_carrierwave` and `bin/rails decidim_awesome:active_storage_migrations:migrate_from_carrierwave` (also accessible as a background job from the awesome admin checks)
  - REMOVED: SCSS themes are not available anymore (the alternative is to use custom styles). This is mostly because of webpacker.

v0.7.2
------

Compatibility:
  - Decidim v0.24.x
  - Decidim v0.23.x

Features:
  - Added custom fields (with admin interface and scopable) to replace normal body in proposals.
  - Change Markdown editor behavior: now it is converted to HTML before storing in the database. This makes the editor compatible with all Rich Text editors.
  - Added icons in the awesome config menu
  - Fixes scoped admins accessing process groups

v0.7.1
------

Compatibility:
  - Decidim v0.24.x
  - Decidim v0.23.x

Features:
  - Fix CSS custom styles when using html characters
  - Add Awesome Map content block for the homepage
  - Added processes groups constraint for different scoped tweaks
  - Added "Never" constraint to deactivated scoped tweaks temporarily
  - Change Markdown editor behavior: now it is converted to HTML before storing in the database. This makes the editor compatible with all Rich Text editors. This also takes this feature out the the "experimental" zone as the resulting edited text is fully compatible with standard Decidim.
  - Added scoped admins feature: Any user can be turned into a limited admin and scoped to one or more participatory spaces.
  - Fix allowing access to participatory space admins (only full admins can access the module).
  - Added `participatory_spaces_routes_context` config variable to specify additional routes correspondences to participatory spaces.

v0.7.0
------

Compatibility:
  - Decidim v0.24
  - Decidim v0.23.x
  - Decidim v0.23

v0.6.7
------

Compatibility:
  - Decidim v0.23.x
  - Decidim v0.23
  - Decidim v0.22

Features:
  - Feature: Truncate description in map popups to configurable character limit
  - Add CSS validation and syntax highlighting in CSS boxes editors
  - Fix: filter awesome map by hash takes into account the status of categories

v0.6.6
------

Compatibility:
  - Decidim v0.23.3
  - Decidim v0.23.2
  - Decidim v0.23.1
  - Decidim v0.23
  - Decidim v0.22

Features:
  - Fix: Prevents overrides for menus not specified in awesome config
  - Fix: Respect original @if condition for menu presenter for native menus

v0.6.5
------

Compatibility:
  - Decidim v0.23.3
  - Decidim v0.23.2
  - Decidim v0.23.1
  - Decidim v0.23
  - Decidim v0.22

Features:
  - Allow admins to modify the main Decidim menu

v0.6.4
------

Compatibility:
  - Decidim v0.23.3
  - Decidim v0.23.2
  - Decidim v0.23.1
  - Decidim v0.23
  - Decidim v0.22

Features:
  - Fixes a 500 error when custom styles is empty
  - Fixes removal of existing css boxes when other configuration are changed

v0.6.3
------

Compatibility:
  - Decidim v0.23.3
  - Decidim v0.23.2
  - Decidim v0.23.1
  - Decidim v0.23
  - Decidim v0.22

Features:
  - Adds custom scoped styles

v0.6.2
------

Compatibility:
  - Decidim release/0.23-stable
  - Decidim v0.23.1
  - Decidim v0.23
  - Decidim v0.22

Features:
  - Fixes compatibility with proposals in branch `release/0.23-stable`

v0.6.1
------

Compatibility:
  - Decidim v0.23
  - Decidim v0.22

Features:
  - Improve awesome map categories visualization
  - Fix image uploader
  - Adds announcements for full screen iframes

v0.6
----

Compatibility:
  - Decidim v0.23
  - Decidim v0.22

Features:
  - Full screen iframe component
  - live support chat linked with Telegram

v0.4, 0.5
----

Compatibility:
  - Decidim v0.22
  - Decidim v0.21

Features:
  - Decidim CSS themes for tenants

v0.3
----

Compatibility:
  - Decidim v0.21
  - Decidim v0.20

Features:
  - Awesome map
  - Images in rich text editors
  - Images in textarea editors
  - Autosave forms
  - Scoped constraints for each feature
