CHANGELOG
=========

v0.7.2
------

Compatibility:
  - Decidim v0.24.x
  - Decidim v0.23.x

Features:
  - Added custom fields (with admin interface and scopable) to replace normal body in proposals.
  - Change Markdown editor behaviour: now it is converted to HTML before storing in the database. This makes the editor compatible with all Rich Text editors.

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
  - Change Markdown editor behaviour: now it is converted to HTML before storing in the database. This makes the editor compatible with all Rich Text editors. This also takes this feature out the the "experimental" zone as the resulting edited text is fully compatible with standard Decidim.
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
