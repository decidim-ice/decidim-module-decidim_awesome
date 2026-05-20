# Content blocks

Content blocks are customizable landing page sections that surface key information and navigation paths for participants. They can be added, configured, and sequenced by admins in Settings → Content blocks.

## Tweaks

### 7.1 Awesome Processes content block

Adds a homepage content block to showcase processes/groups with status filters, manual/automatic selection, and configurable limits.

#### Admin description

Highlights key processes and manages their homepage visibility without editorial overhead.
Concerns: automatic selection based on status can surface incomplete/barely-started processes. Manual curation recommended.
Recommend rotating featured processes; pair with clear status labels so participants know process maturity level.

#### Technical area

- **Enabling/Disabling:** Feature is built-in; enabled by default and cannot be disabled via initializer (use component removal in admin UI if not needed)

```ruby
# config/initializers/awesome_defaults.rb
# No explicit configuration; this is a content-block add-on
# Admins can choose whether to add this block to homepage in Settings → Content blocks
```

- **Content block:** Appears on homepage; configurable title and description
- **Selection:** Admin chooses processes manually or auto-select by status/type (active, open for participation, etc.)
- **Display:** Shows process tiles with thumbnail, title, status badge; configurable item count per row
- **Filtering:** Homepage visitors see status filter tabs (open/closed/all); they can explore without leaving homepage
- **Performance:** Process query optimized; pagination if >20 items
- **Ordering:** Manual drag-to-reorder or auto-sort by creation date/status change
- **Mobile:** Responsive card layout; single-column on small screens
- **Dependency:** Similar to Tweak 7.2 (Process Groups) but for individual processes

![Awesome Processes admin settings](../../examples/awesome_processes_admin.png)

### 7.2 Process Groups content block

Adds a process-group landing block with status tabs, taxonomy filters and pagination.

#### Admin description

Showcases grouped processes with rich filtering for large portfolios. Reduces navigation friction for users discovering related processes.
Concerns: filter combinations can expose zero-result states. Label filters clearly and provide "no results" guidance.
Recommend limiting visible filters to 2-3 most relevant; archive old process groups to keep list manageable.

#### Technical area

- **Enabling/Disabling:** Feature is built-in; cannot be disabled (use component removal in admin UI if not needed)

```ruby
# config/initializers/awesome_defaults.rb
# No explicit configuration; this is a content-block add-on
# Admins can choose whether to add this block to pages in Settings → Content blocks
```

- **Content block:** Landing page block dedicated to process groups
- **Filtering:** Status tabs (open/closed/all); taxonomy-based filters (e.g., type, theme); multiple selections allowed
- **Pagination:** Groups divided into pages if >10; per-page count configurable
- **Display:** Process group cards with thumbnail, title, status, description excerpt
- **Performance:** Filters applied server-side; indexed for fast querying
- **Mobile:** Responsive filter UI; filters collapse into dropdown on small screens
- **Customization:** Title, description, item-per-page, visible filters configurable by admin
- **Dependency:** Complements Tweak 7.1 (Awesome Processes) for group-level discovery vs. individual processes

![Process Groups admin settings](../../examples/awesome_process_groups_admin.png)
![Process Groups public view](../../examples/awesome_process_groups_public.png)

### 7.3 Awesome Rich Text content block

Adds a fully configurable rich-text content block for landing pages with multi-column layouts, background images/colors, and per-column access restrictions for non-authenticated users.

#### Admin description

- Allows editorial teams to build rich homepage sections without custom code: free-form HTML content, multi-column grids, section titles, and branded backgrounds.
- Per-column restrictions let admins gate videos or links behind a login prompt, driving participant registration without hiding content entirely.
- Concern: content is stored as HTML in block settings; ensure editors are aware of the sanitization applied before saving raw markup.
- Recommendation: assign a meaningful **Block ID** (e.g., `our-team`, `latest-news`) so the section can be targeted by the Landing Menu block anchor links and custom CSS rules.

#### Technical area

- **Admin visibility:** Block appears in the "Add content block" dropdown as *Awesome Rich Text block*; configured in Settings → Homepage content blocks.
- **Default behavior:** Enabled by default (`rich_text_block: true`). Set to `:disabled` to hide it completely from admins.
- **Admin control:** Yes — admins add as many instances as needed and configure each independently.

```ruby
# config/initializers/awesome_defaults.rb
Decidim::DecidimAwesome.configure do |config|
  # Enable rich text content block (default: true)
  config.rich_text_block = true

  # Maximum number of columns per block instance (default: 5)
  config.max_rich_text_columns = 5

  # Disable completely (hidden from admins):
  # config.rich_text_block = :disabled
end
```

- **Block settings:**
  - `block_id` — Custom HTML `id` attribute for the section (sanitized: lowercase, alphanumeric, hyphens/underscores only). Auto-generated as `awesome-rich-text-<id>` if left blank.
  - `title` — Optional translatable section heading rendered as `<h2>`.
  - `columns` — Array of column definitions (up to `max_rich_text_columns`, default 5). Each column supports:
    - `body` — Translatable rich-text HTML content.
    - `background_color` — CSS hex color applied as `--awesome-rich-text-bg` CSS variable.
    - `background_image` — Uploaded image file; overrides background color when present.
    - `background_image_placement` — One of `cover_center`, `cover_top`, `cover_bottom`, `contain_center`, `repeat`.
    - `restrict_videos` — When enabled, `<iframe>`, `<video>`, and `.disabled-iframe` elements are replaced by a "Sign in to watch this video" login button for unauthenticated users.
    - `restrict_links` — When enabled, link `href` attributes are stripped and replaced with a login modal trigger for unauthenticated users.

- **Grid layout:** Single column renders full-width. Two or more columns use a responsive CSS grid (`md:grid-cols-{n}`); single column on mobile.
- **Security:** Column body HTML is passed through `decidim_sanitize_editor_admin` before rendering. Access restrictions are enforced server-side — not just via CSS — so restricted content is never sent to the browser for unauthenticated requests.
- **CSS targeting:** Use `.awesome-rich-text` for block-level styles and `.awesome-rich-text__column:nth-child(n)` for per-column overrides (selector hints shown in the admin form).
- **Cross-references:** Works with Tweak 7.4 (Landing Menu block) — set a `block_id` here and use it as an anchor URL (`#your-block-id`) in the Landing Menu.

![Awesome Rich Text admin settings](../../examples/awesome_rich_text_admin.gif)
![Awesome Rich Text public view](../../examples/awesome_rich_text_public.gif)

### 7.4 Awesome Landing Menu content block

Adds an anchor-based navigation menu for landing pages with configurable sticky positioning, alignment, and mobile visibility.

#### Admin description

- Lets admins build an in-page navigation bar that links to other content blocks by their `block_id` anchor, or to any internal/external URL.
- Sticky mode keeps the menu visible while scrolling, improving navigation in long one-page layouts.
- Concern: anchor links only work if the target block's `block_id` matches exactly (case-sensitive after sanitization).
- Recommendation: add the Landing Menu block at the top of the homepage content block stack; pair with the Rich Text block (Tweak 7.3) for anchor targets.

#### Technical area

- **Admin visibility:** Block appears in the "Add content block" dropdown as *Awesome global menu*; configured in Settings → Homepage content blocks.
- **Default behavior:** Enabled by default (`landing_menu_block: true`). Set to `:disabled` to hide from admins.
- **Admin control:** Yes — admins configure items, order, sticky behavior, and alignment per instance.

```ruby
# config/initializers/awesome_defaults.rb
Decidim::DecidimAwesome.configure do |config|
  # Enable landing menu content block (default: true)
  config.landing_menu_block = true

  # Disable completely (hidden from admins):
  # config.landing_menu_block = :disabled
end
```

- **Block settings:**
  - `menu_items` — JSON array of `{ name (translatable), url, visible }` objects; managed via the dedicated item editor.
  - `sticky` — Boolean; renders the menu with sticky CSS positioning when enabled.
  - `show_on_mobile` — Boolean; controls visibility on small screens.
  - `alignment` — One of `left`, `center`, `right`.
- **Link handling:** External URLs open in a new tab with `rel="noopener noreferrer"`; relative paths and anchor links (`#block-id`) open in the same page.
- **Cross-references:** Designed to complement Tweak 7.3 (Awesome Rich Text block) for anchor navigation.

![Awesome Landing Menu admin settings](../../examples/awesome_landing_menu.gif)

## Scope and operations

- Review content-block configuration choices for performance and editorial consistency.
- Validate filter/pagination settings for large process portfolios.
- Monitor block reusability across pages (some blocks can appear on multiple pages).
