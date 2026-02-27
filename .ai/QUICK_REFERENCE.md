# Quick Reference for AI Agents

## Project at a Glance

| Aspect | Details |
|--------|---------|
| **Project** | Decidim Awesome - UX/usability module for Decidim |
| **Language** | Ruby (Rails) |
| **Current Version** | 0.14.1 |
| **Decidim Compat** | 0.31.x (>= 0.31.0, < 0.32) |
| **Min Ruby** | 3.3 |
| **Testing** | RSpec |
| **Locales** | 17 languages (ar, ca, cs, de, en, es, eu, fr, hu, it, ja, lt, nl, pt, pt-BR, ro, sv) |

## Critical Files

| File | Purpose |
|------|---------|
| `lib/decidim/decidim_awesome/version.rb` | Version info, update here for releases |
| `CHANGELOG.md` | Keep updated with PR references |
| `config/locales/*.yml` | User-facing strings (17 locale files, Crowdin-managed) |
| `spec/` | All tests go here following rails structure |
| `app/` | Application code (models, views, controllers, etc.) |
| `decidim-decidim_awesome.gemspec` | Gem definition |

## Common Commands

```bash
# Test everything
bundle exec rspec

# Test a file
bundle exec rspec spec/controllers/admin/checks_controller_spec.rb

# Validate locales
ruby -Ku -ryaml -e "Dir['config/locales/*.yml'].each { |f| YAML.load_file(f); puts \"✓ #{f}\" }"

# Security check
bundle audit

# Rails console
bundle exec rails console
```

## Before Committing Code

**Always verify:**
1. ✅ Tests pass: `bundle exec rspec`
2. ✅ YAML valid: Check all locale files
3. ✅ Base locale (en.yml) updated (other locales managed via Crowdin)
4. ✅ CHANGELOG updated with PR reference
5. ✅ No security vulnerabilities

## Locale File Requirements

When adding new strings:

1. Add to `config/locales/en.yml` (base language)
2. Other languages are translated via [Crowdin](https://crowdin.com/translate/decidim-awesome)
3. For urgent fixes, you can manually update specific locale files, but Crowdin is preferred

**All 17 supported locales**: ar, ca, cs, de, en, es, eu, fr, hu, it, ja, lt, nl, pt, pt-BR, ro, sv

Format in views: `<%= t(".key_name") %>`

## Code Organization

```
Namespace: Decidim::DecidimAwesome

Examples:
- Decidim::DecidimAwesome::VERSION
- Decidim::DecidimAwesome::Config
- Decidim::DecidimAwesome::Admin::ChecksController
- Decidim::DecidimAwesome::Admin::SystemCheckerHelpers
```

## Important Conventions

- **Files**: `snake_case.rb`
- **Classes**: `PascalCase`
- **Methods**: `snake_case`
- **Comments**: `# frozen_string_literal: true` at file top
- **Views**: Use Deface for non-intrusive overrides
- **Tests**: Use FactoryBot, RSpec format

## Testing Patterns

```ruby
# What to test
describe "Feature name" do
  let(:object) { create(:factory) }
  
  context "when condition" do
    it "does something" do
      expect(result).to eq(expected)
    end
  end
end

# What to mock
allow(ExternalService).to receive(:method).and_return(value)

# What to verify
expect(object).to have_received(:method).with(args)
```

## RedFlags 🚩

DON'T do these:

- ❌ Modify code without tests
- ❌ Add strings without adding to en.yml (translations managed via Crowdin)
- ❌ Forget to validate YAML syntax
- ❌ Forget PR references in CHANGELOG
- ❌ Skip error handling in external API calls
- ❌ Use hardcoded values (i18n instead)
- ❌ Forget to update version in `version.rb` for releases
- ❌ Create commits without clear messages

## Release Checklist

When preparing a release:

1. ✅ Version updated in `lib/decidim/decidim_awesome/version.rb`
2. ✅ CHANGELOG.md has version section with:
   - Decidim compatibility  
   - Features with [#PR](link) format
   - Fixes with [#PR](link) format
3. ✅ All tests passing
4. ✅ All locale files valid
5. ✅ README updated if needed
6. ✅ Git tag created: `git tag v0.14.1`
7. ✅ Gem built: `gem build`
8. ✅ Gem pushed: `gem push`
9. ✅ GitHub release created with changelog

## GitHub API Integration

New feature: Version checking via GitHub API

- **Helper**: `SystemCheckerHelpers` (app/helpers/...)
- **Client**: Faraday (HTTP client)
- **Cache**: 1 hour via Rails.cache
- **Repos**:
  - Decidim Awesome: `decidim-ice/decidim-module-decidim_awesome`
  - Decidim: `decidim/decidim`

Methods:
- `awesome_latest_version` - Latest Awesome version (same minor)
- `awesome_version_outdated?` - Check if update available
- `decidim_latest_version` - Latest Decidim version (same minor)
- `decidim_version_outdated?` - Check if Decidim update available

## Need Help?

Reference these .ai files:
- **README.md** - Overview and AI capabilities
- **ARCHITECTURE.md** - Project structure and patterns
- **CONVENTIONS.md** - Code style and standards
- **TESTING.md** - How to write tests
- **WORKFLOW.md** - Development process and troubleshooting

## External Resources

- **Decidim Docs**: https://docs.decidim.org
- **This Repo**: https://github.com/decidim-ice/decidim-module-decidim_awesome
- **RSpec**: https://rspec.info/
- **Rails Guides**: https://guides.rubyonrails.org
- **GitHub API**: https://docs.github.com/en/rest

---

**Last Updated**: 26 February 2026  
**Decidim Awesome Version**: 0.14.1
