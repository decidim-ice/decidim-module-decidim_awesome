# Project Architecture

## Directory Structure

```
decidim-module-decidim_awesome/
├── app/                        # Rails application code
│   ├── api/                   # GraphQL API overrides
│   ├── cells/                 # Cell components (view objects)
│   ├── commands/              # Service objects for business logic
│   ├── controllers/           # Controller overrides via Deface
│   ├── forms/                 # Form objects
│   ├── helpers/               # View helpers
│   ├── jobs/                  # Background jobs
│   ├── models/                # Model overrides
│   ├── overrides/             # Deface template overrides
│   ├── packs/                 # Webpacker assets (JS, CSS)
│   ├── permissions/           # Permission classes
│   ├── presenters/            # Presenter/Decorator classes
│   ├── queries/               # Query objects
│   ├── serializers/           # API serializers
│   ├── services/              # Service classes
│   ├── types/                 # GraphQL types
│   ├── uploaders/             # CarrierWave uploaders
│   ├── validators/            # Custom validators
│   └── views/                 # View templates
├── config/
│   ├── locales/              # i18n translation files (8 languages)
│   └── i18n-tasks.yml        # i18n configuration
├── lib/
│   ├── decidim/
│   │   └── decidim_awesome/
│   │       ├── version.rb    # Module version and Decidim compatibility
│   │       └── engine.rb     # Rails engine definition
│   └── tasks/                # Rake tasks
├── spec/                      # Test files (RSpec)
├── db/
│   └── migrate/              # Database migrations
└── CHANGELOG.md              # Version history with PRs
```

## Key Modules & Classes

### SystemCheckerHelpers (`app/helpers/decidim/decidim_awesome/admin/system_checker_helpers.rb`)
Provides helper methods for system compatibility checks:
- `decidim_version_valid?` - Validates Decidim version compatibility
- `decidim_version_outdated?` - Checks for newer Decidim versions
- `awesome_version_outdated?` - Checks for newer Awesome versions
- Fetches from GitHub API (uses Faraday client)

### Version Management (`lib/decidim/decidim_awesome/version.rb`)
```ruby
VERSION = "0.14.1"
COMPAT_DECIDIM_VERSION = [">= 0.31.0", "< 0.32"].freeze
```

## Design Patterns

### Deface Overrides
The module uses [Deface](https://github.com/spree/deface) for non-intrusive view modifications:
- Located in `app/overrides/`
- Allows customizing Decidim views without forking
- Overrides are CSS/XPath-selector based

### Service Objects & Commands
Business logic is extracted into:
- **Commands**: For operations that modify state (in `app/commands/`)
- **Services**: For reusable operations (in `app/services/`)

### Presenters/Decorators
Used to extend model behavior for views:
- Located in `app/presenters/concerns/`
- Wrap models to add presentation logic without polluting models

## Override Strategy

When extending Decidim functionality, follow this priority order:

### 1. Deface Overrides (Preferred)

**Use Deface when you need to modify Decidim views or templates.**

The module follows best practices with `.html.erb.deface` format for clean, maintainable overrides.

**Location**: `app/overrides/decidim/` (mirrors Decidim's view structure)

#### Best Practice: Single Render Pattern

Each `.html.erb.deface` file should contain **only one render command** delegating to a custom partial. This keeps overrides lean and all logic in organized partials.

**Example - Good (Preferred)**:

```erb
<!-- app/overrides/decidim/proposals/admin/proposals/_form/replace_editor.html.erb.deface -->
<!-- replace "erb[loud]:contains('form.translated :editor, :body')" -->

<%= render partial: "decidim/decidim_awesome/admin/proposals/editor", locals: { form: form } %>
```

Partial with all logic:
```erb
<!-- app/views/decidim/decidim_awesome/admin/proposals/_editor.html.erb -->
<div class="custom-editor">
  <% if awesome_config[:custom_editor_enabled] %>
    <%= form.translated :editor, :body, options: { toolbar: "custom" } %>
  <% else %>
    <%= form.translated :editor, :body %>
  <% end %>
</div>
```

**Example - Avoid (Multiple lines of logic)**:

❌ **Don't do this:**
```erb
<!-- app/overrides/layouts/decidim/_head/add_awesome_tags.html.erb.deface -->
<% append_stylesheet_pack_tag "decidim_decidim_awesome", media: "all" %>
<% append_javascript_pack_tag "decidim_decidim_awesome", defer: false %>
<% append_javascript_pack_tag("decidim_decidim_awesome_custom_fields") if Decidim::DecidimAwesome.enabled?(:proposal_custom_fields) %>
```

✅ **Do this instead:**
```erb
<!-- app/overrides/layouts/decidim/_head/add_awesome_tags.html.erb.deface -->
<!-- insert_after "erb[loud]:contains('append_stylesheet_pack_tag')" -->

<%= render "layouts/decidim/decidim_awesome/asset_tags" %>
```

```erb
<!-- app/views/layouts/decidim/decidim_awesome/_asset_tags.html.erb -->
<% append_stylesheet_pack_tag "decidim_decidim_awesome", media: "all" %>
<% append_javascript_pack_tag "decidim_decidim_awesome", defer: false %>
<% append_javascript_pack_tag("decidim_decidim_awesome_custom_fields") if Decidim::DecidimAwesome.enabled?(:proposal_custom_fields) %>
```

**Overrides Structure**:
```
app/overrides/decidim/
├── admin/
│   ├── officializations/
│   │   └── index/
│   │       ├── add_td.html.erb.deface          # Add table column
│   │       ├── add_modal.html.erb.deface       # Add modal component
│   │       └── add_th.html.erb.deface          # Add table header
│   └── proposals/
│       ├── _form/
│       │   └── replace_editor.html.erb.deface  # Replace editor with custom version
│       └── show/
│           └── add_private_body.html.erb.deface # Add custom field display
├── shared/                                     # Shared component overrides
├── proposals/                                   # For proposal-specific views
└── system/                                      # For system/admin configuration
```

**Key Guidelines**:
1. One override per file (one deface action)
2. Delegate to custom partials for all logic
3. Use descriptive names: `add_`, `replace_`, `remove_` prefix
4. Custom partials go in `app/views/decidim/decidim_awesome/` mirroring the override structure
5. Keep deface selectors simple and robust (prefer class/id over complex XPath)
6. Add comments explaining what the override does (<!-- insert_after ".my-selector" -->)

**Current Status**: See [DEFACE_ANALYSIS.md](DEFACE_ANALYSIS.md) for a detailed analysis of all 25 existing overrides:
- ✅ 21 overrides following best practice (84%)
- ⚠️ 4 overrides needing improvement (16%) - with specific recommendations

**Benefits:**
- Non-intrusive (doesn't replace entire file)
- Survives Decidim updates as long as selectors remain stable
- Clean separation: override file + partial = single responsibility
- Easy to track and modify behavior
- Simple to disable/enable via feature flags
- Testing is easier (test partial behavior, not complex integration)

### 2. Concerns for Minimal Model/Controller Overrides

**Use concerns when Deface isn't viable and you need minimal overrides.**

**Location**: 
- `app/models/concerns/decidim/` - For model extensions
- `app/controllers/concerns/decidim/` - For controller extensions
- `app/helpers/concerns/decidim/` - For helper extensions

**Example:**
```ruby
# app/models/concerns/decidim/user_extra_methods.rb
module Decidim::UserExtraMethods
  extend ActiveSupport::Concern
  
  included do
    # Add custom associations, validations, etc.
  end
  
  def my_custom_method
    # Implementation
  end
end

# In engine.rb (auto-included via Rails)
initializer "decidim_awesome.models" do
  Decidim::User.include(Decidim::UserExtraMethods)
end
```

**Benefits:**
- Minimal code footprint
- Isolated in concerns
- Easy to track what was changed
- Less likely to break on updates

### 3. Complete File Overrides (Last Resort)

**Only when Deface and concerns won't work.** This is rare and requires checksum tracking.

**Requirements:**
- Document why in code comments
- Track in `checksums.yml`
- Create issue if Decidim could be patched instead

**Checksum Tracking**:

Create at `config/checksums.yml` to track all overridden files:

```yaml
# config/checksums.yml
# Track of all complete file overrides and their original checksums
# This helps detect when Decidim updates require merging our changes

overrides:
  "app/views/decidim/my_component/override.html.erb":
    decidim_version: "0.31.0"
    original_checksum: "abc123def456"
    reason: "Added custom field that couldn't be done via Deface"
    pr_link: "https://github.com/decidim/decidim/pull/12345"
    status: "pending_merge"  # pending_merge, merged, obsolete
    notes: "Waiting for Decidim v0.32 to add native support"
```

**After Decidim Updates**:
- Compare checksums to detect changes
- Merge changes carefully
- Update status and notes
- Remove if code was merged upstream

## Technology Stack

- **Framework**: Ruby on Rails (with Decidim integration)
- **HTTP Client**: Faraday (for GitHub API calls)
- **Testing**: RSpec
- **Styling**: Tailwind CSS
- **Template Engine**: ERB + Deface
- **Asset Pipeline**: Shakapacker (formerly Webpacker)
- **i18n**: Rails i18n + i18n-tasks

## Release Process

1. Version updated in `lib/decidim/decidim_awesome/version.rb`
2. Changelog updated in `CHANGELOG.md` with:
   - Version number
   - Decidim compatibility
   - Features/fixes with PR links
3. Git tag created (v0.14.1)
4. Gem built and pushed to RubyGems
5. GitHub release created

## Configuration

Main configuration stored in:
- `Decidim::DecidimAwesome::Config` class
- Stored in database via `config` model
- Accessible throughout views/controllers

## Localization

All user-facing strings are i18n compliant:
- Base language: English (`en.yml`)
- 7 additional languages: Spanish, Catalan, French, Italian, Portuguese, German, Czech
- Located in `config/locales/`
- Use `t(".key")` syntax in views/controllers
