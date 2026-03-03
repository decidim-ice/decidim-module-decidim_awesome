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

## Scope and operations

- Review content-block configuration choices for performance and editorial consistency.
- Validate filter/pagination settings for large process portfolios.
- Monitor block reusability across pages (some blocks can appear on multiple pages).
