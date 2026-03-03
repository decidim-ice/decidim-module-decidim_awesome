# Project Architecture

## Directory Structure

```
decidim-module-decidim_awesome/
├── app/                       # Rails application code
│   ├── api/                   # GraphQL API overrides
│   ├── cells/                 # Cell components (view objects)
│   ├── commands/              # Service objects for business logic
│   ├── controllers/           # Controller classes (concerns in controllers/concerns/)
│   ├── forms/                 # Form objects
│   ├── helpers/               # View helpers
│   ├── jobs/                  # Background jobs
│   ├── models/                # Model overrides
│   ├── overrides/             # Deface template overrides
│   ├── packs/                 # Shakapacker assets (JS, CSS)
│   ├── permissions/           # Permission classes
│   ├── presenters/            # Presenter/Decorator classes
│   ├── queries/               # Query objects
│   ├── serializers/           # API serializers
│   ├── services/              # Service classes
│   ├── types/                 # GraphQL types
│   ├── uploaders/             # Custom validations for ActiveStorage
│   ├── validators/            # Custom validators
│   └── views/                 # View templates
├── config/
│   ├── locales/              # i18n translation files
│   └── i18n-tasks.yml        # i18n configuration
├── lib/
│   ├── decidim/
│   │   └── decidim_awesome/
│   │       ├── version.rb          # Module version and Decidim compatibility
│   │       ├── awesome.rb          # Main module file: config_accessors and autoloads
│   │       ├── engine.rb           # Main Rails engine (public routes, assets and global initializers)
│   │       ├── admin_engine.rb     # Admin-specific engine (admin routes and initializers)
│   │       ├── config.rb           # Config class: per-organization config from DB
│   │       ├── awesome_helpers.rb  # Core helper methods
│   │       ├── menu.rb             # Menu management
│   │       ├── custom_fields.rb    # Custom fields functionality
│   │       ├── system_checker.rb   # System compatibility checks
│   │       ├── voting_manifest.rb  # Voting manifest registry
│   │       ├── authorizer.rb       # Authorization logic
│   │       ├── lock.rb             # Locking mechanism
│   │       ├── request_memoizer.rb # Per-request memoization
│   │       ├── context_analyzers.rb # Context analyzer registry
│   │       ├── context_analyzers/  # Individual context analyzer classes
│   │       ├── middleware/         # Rack middleware (CurrentConfig)
│   │       ├── api/                # GraphQL type definitions
│   │       └── test/               # Shared examples and test helpers
│   └── tasks/                # Rake tasks
├── spec/                     # Test files (RSpec)
├── db/
│   └── migrate/              # Database migrations
└── CHANGELOG.md              # Version history with PRs
```

## Rails Engines

### Main Engine (`lib/decidim/decidim_awesome/engine.rb`)

The main engine handles:
- **Routes**: Public-facing routes (required_authorizations, editor_images, form_builder_i18n)
- **Assets**: JavaScript/CSS packed via Shakapacker (`register_assets_path`)
- **Initializers**: Core configuration and monkey patches (concerns included via `config.to_prepare`)
- **Middleware**: Injects `CurrentConfig` middleware for per-request config
- **Cell view paths**: Registers cell view paths for voting components
- **Auto-loading**: All `app/` directories are auto-loaded

Key responsibilities:
- Define isolated namespace `Decidim::DecidimAwesome`
- Register feature-gated concerns into Decidim core classes
- Register custom proposal component settings and exporters
- Register voting manifests and content blocks
- Register icons

### Admin Engine (`lib/decidim/decidim_awesome/admin_engine.rb`)

Separate engine for admin functionality:
- **Routes**: Admin-only routes mounted at `/admin/decidim_awesome`
- **Isolation**: Separate namespace `Decidim::DecidimAwesome::Admin`
- **Controllers**: Admin controllers accessed via `Decidim::DecidimAwesome::Admin::<ControllerName>`

Routes managed in admin engine:
- `constraints` - Spam/abuse constraint management
- `menus` - Menu item customization
- `custom_redirects` - Custom URL redirects
- `config` - System configuration
- `scoped_styles` - Custom CSS per space
- `proposal_custom_fields` - Proposal custom fields
- `scoped_admins` - Space-specific admins
- `force_authorizations` - Authorization requirements
- `checks` - System health checks (maintenance)
- `private_data` - Private data export/delete
- `hashcash` - Spam prevention settings
- `admin_authorizations` - Authorization overrides

**Why separate?** By isolating admin routes, the main engine stays lean and focused on public functionality.

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

**Important**: All overrides must be tracked in `config/checksums.yml` for maintenance and upgrade compatibility. See [Checksum Tracking](#checksum-tracking) section below.

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

**Testing Concerns in Summary Specs**:

After creating a concern override, you **must add a validation** in `lib/decidim/decidim_awesome/test/shared_examples/summary_examples.rb` to ensure the concern is properly included/excluded based on the feature flag status.

Add your concern check in both the `enabled` and `disabled` sections of the `"activated concerns"` shared example:

```ruby
# lib/decidim/decidim_awesome/test/shared_examples/summary_examples.rb

shared_examples "activated concerns" do |enabled|
  # ... other checks ...

  if enabled
    it "concerns are registered" do
      # ... existing checks ...
      expect(Decidim::YourClass.included_modules).to include(Decidim::DecidimAwesome::YourConcernName)
    end
  else
    it "concerns are not registered" do
      # ... existing checks ...
      expect(Decidim::YourClass.included_modules).not_to include(Decidim::DecidimAwesome::YourConcernName)
    end
  end
end
```

Then validate both states work:
```bash
FEATURES=enabled bundle exec rspec spec/awesome_summary_spec.rb
FEATURES=disabled bundle exec rspec spec/awesome_summary_spec.rb
```

This ensures:
- Concern is **included** when the feature is enabled (matches `enabled: true` check)
- Concern is **not included** when the feature is disabled (matches `enabled: false` check)
- Feature toggle properly controls concern injection

### 3. Complete File Overrides (Last Resort)

**Only when Deface and concerns won't work.**

**Requirements:**
- Document why in code comments
- Track in `checksums.yml`
- Create issue if Decidim could be patched instead

## Checksum Tracking for All Overrides

All overrides (Deface, concerns, and complete file overrides) must be tracked in `lib/decidim/decidim_awesome/checksums.yml` for maintenance and Decidim upgrade compatibility. This file stores MD5 checksums of overridden files to detect when Decidim updates change the original.

### Tracking Format

The `checksums.yml` file is organized by Decidim component/gem, then file path, then version with its MD5 checksum:

```yaml
# lib/decidim/decidim_awesome/checksums.yml
# Tracks checksums of Decidim files that are overridden/decorated
# Uses to detect changes during Decidim upgrades

decidim-core:
  /app/views/layouts/decidim/_head.html.erb:
    decidim-0.31.0: 0faa190f7a4b3db401ffcdfc3d063802
  /app/views/layouts/decidim/_decidim_javascript.html.erb:
    decidim-0.31.0: 8d51790de859ee66f305d9111cdfb324
  /app/services/decidim/open_data_exporter.rb:
    decidim-0.31.0: 3093e8c74ea1a6fb838ec192c782c90b
    decidim-0.31.2: 231a2009ebed95bdfbf3e6d44dfe5e94

decidim-proposals:
  /app/forms/decidim/proposals/proposal_form.rb:
    decidim-0.31.0: ffa0fa0d38a9c77d73d173727bc87cd2
  /app/views/decidim/proposals/proposals/_vote_button.html.erb:
    decidim-0.31.0: 3cd74a9396d20e19ed3821f08cbe2b06
    decidim-0.31.1: f5247f762666de9cf09635fce3a13ce7
  /app/views/decidim/proposals/proposals/show.html.erb:
    decidim-0.31.0: e2c0adf5c283f7396d93207e1b7ab740

decidim-admin:
  /app/views/layouts/decidim/admin/_header.html.erb:
    decidim-0.31.0: 6e5893f735d2097f0e55e8b6666cb201

decidim-assemblies:
  /app/views/decidim/assemblies/admin/assemblies/_form.html.erb:
    decidim-0.31.0: cc06bd20baa7f130e34d04a3c925e2f7
```

### How It Works

1. **When installing Decidim Awesome**: Checksums recorded for current Decidim version
2. **When upgrading Decidim**: Compare old vs new checksums to detect changes
3. **If checksum differs**: File changed in Decidim, may need to update overrides
4. **If checksum matches**: No changes in Decidim file, overrides still compatible

### Generating Checksums

Calculate MD5 checksum for a Decidim file:

```bash
# For a file from installed gem
md5sum $(bundle show decidim-core)/app/views/layouts/decidim/_head.html.erb

# Result: 0faa190f7a4b3db401ffcdfc3d063802  /path/to/file.erb
```

### Checking Checksums

**Quick way to validate all checksums at once**:

```bash
# Run the system checker spec that validates all checksums in checksums.yml
bundle exec rspec spec/lib/system_checker_spec.rb
```

This test automatically:
- Compares every file checksum in `checksums.yml` against the installed Decidim gems
- Reports which files have changed between versions
- Identifies which files need attention after Decidim upgrade
- Much faster than checking manually with MD5 commands

**Manual method** (only needed if test isn't sufficient):

```bash
# Check individual checksum
md5sum $(bundle show decidim-core)/app/views/layouts/decidim/_head.html.erb
```

### Updating on Decidim Upgrade

**When Decidim version changes**:

1. **Check checksum changes** for each file in `checksums.yml`:
   - Get current checksum: `md5sum $(bundle show <gem>)/<path>`
   - Compare with recorded version in checksums.yml
   - If checksum is identical: no changes needed, override still compatible
   - If checksum differs: Decidim file was modified, review changes

2. **For each file with changed checksum**:
   - **Compare versions**: Use git diff or online tool to see what changed in Decidim between versions
     ```bash
     # Example: see what changed in _head.html.erb between 0.31.0 and 0.31.1
     git diff v0.31.0..v0.31.1 -- app/views/layouts/decidim/_head.html.erb
     ```
   - **Analyze impact**: Does the Deface override still make sense?
   - **Three scenarios**:

     **A) Override still needed, structure unchanged**
     - Keep override and partial as-is
     - Update checksum in checksums.yml
     - Test that Deface selector still matches (may have minor spacing changes)
     - Run tests to verify behavior

     **B) Override needs updates due to structural changes**
     - File structure changed significantly
     - Deface selector may no longer match
     - May need to update `.erb.deface` selector (e.g., element classes/IDs changed)
     - May need to update partial if surrounding HTML structure changed
     - Move override `.erb.deface` file to new location if Decidim reorganized views
     - Example: If `_header.html.erb` moved from `layouts/` to `shared/`, move override location too

     **C) Override no longer needed (removed or obsolete)**
     - Decidim implemented the feature natively
     - Or change made override irrelevant
     - **Delete the override** `.erb.deface` file completely
     - Remove Deface-related features from partials if they're no longer used
     - Update checksums.yml to mark as obsolete/removed
     - Example: If Decidim added native support for custom editor, remove proposals editor override

3. **Update checksums.yml** with new version entry:
   
   **For minor/patch version updates** (e.g., 0.31.0 → 0.31.1):
   ```yaml
   decidim-core:
     /app/views/layouts/decidim/_head.html.erb:
       decidim-0.31.0: 0faa190f7a4b3db401ffcdfc3d063802
       decidim-0.31.1: abc1234567890def1234567890abcdef  # Add new version
   ```
   Keep both versions for reference as you may need to track changes across versions.

   **For major version updates** (e.g., 0.31 → 0.32):
   
   - **If file checksum CHANGED** in new version:
     ```yaml
     decidim-core:
       /app/views/layouts/decidim/_head.html.erb:
         decidim-0.32.0: xyz9876543210fedcba9876543210abc  # Only keep new version
     ```
     Remove old version checksums - you only need the current major version.
   
   - **If file checksum UNCHANGED** in new version (same checksum):
     ```yaml
     decidim-core:
       /app/views/layouts/decidim/_head.html.erb:
         decidim-0.31.0: 0faa190f7a4b3db401ffcdfc3d063802  # Keep old - still valid
     ```
     **Keep the old version entry** - it shows the file has been stable across major versions.

4. **Test thoroughly**:
   - Run full test suite: `bundle exec rspec`
   - Test in development_app UI: verify visual appearance and functionality
   - Check browser console for JavaScript errors
   - Test admin panel features if override touches admin code

### Maintenance Workflow

**When Decidim updates**:
```bash
# 1. After updating Decidim in Gemfile
bundle update decidim

# 2. Recreate the test application with new Decidim version
# IMPORTANT: This is required as the test app needs to match the Decidim version
bundle exec rake test_app

# 3. Check which checksums have changed
# This test validates all checksums and shows you which files were modified
bundle exec rspec spec/lib/system_checker_spec.rb

# 4. For each changed checksum reported by the test:
#    - Compare Decidim versions using git or GitHub
#    - Update override .erb.deface file if selector changed
#    - Update/refactor partials if structure changed
#    - Remove override if no longer needed
#    - Move override file if Decidim reorganized views

# 5. Update checksums.yml with new values and clean up obsolete entries
#    For MAJOR version updates (Decidim Awesome 0.14→0.15, Decidim 0.31→0.32):
#    - If checksum CHANGED: Remove old version, add new version checksum
#    - If checksum UNCHANGED: Keep old version entry (shows stability across versions)
#    Example: File changed in 0.32? Replace decidim-0.31.x with decidim-0.32.x
#             File same in 0.32? Keep decidim-0.31.x entry as-is

# 6. Test all Deface overrides and concerns work correctly
bundle exec rspec

# 7. Optionally recreate development_app and test manually
bundle exec rake development_app
cd development_app && bundle exec rails s
```

### Why This Matters

- **Upgrade Safety**: Know which files are affected when upgrading Decidim
- **Conflict Detection**: MD5 changes indicate potential overrides issues
- **Documentation**: Audit trail of what Decidim versions we've tested with
- **Lazy Upgrade**: Don't re-test if checksums haven't changed
- **Maintenance**: Easy to identify obsolete overrides (when native support added)

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
- `Decidim::DecidimAwesome` module (`awesome.rb`) — `config_accessor` definitions with defaults
- `Decidim::DecidimAwesome::Config` class — per-organization config resolved from DB (`AwesomeConfig` model)
- Accessible throughout views/controllers via `awesome_config` helper

## Localization

All user-facing strings are i18n compliant:
- Base language: English (`en.yml`)
- 16 additional languages: Arabic, Catalan, Czech, German, Spanish, Basque, French, Hungarian, Italian, Japanese, Lithuanian, Dutch, Portuguese, Portuguese (Brazilian), Romanian, Swedish
- All 17 locales: ar, ca, cs, de, en, es, eu, fr, hu, it, ja, lt, nl, pt, pt-BR, ro, sv
- Located in `config/locales/`
- Managed via [Crowdin](https://crowdin.com/translate/decidim-awesome) for community translations
- Use `t(".key")` syntax in views/controllers
