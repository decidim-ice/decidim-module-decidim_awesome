# Development Workflow & Best Practices

## Important: This is a Module, Not an Standalone Application

**Decidim Awesome** is a module that extends the Decidim platform. You cannot run this code directly as a standalone app. Instead:

1. **Development App** - A full Decidim application with this module installed for manual testing
2. **Test App** - A minimal Decidim application for running automated tests

### Setting Up the Apps

Before you can develop or test:

```bash
# Create the development application (includes UI, admin panel, etc.)
bundle exec rake development_app

# Create the test application (minimal setup for RSpec)
bundle exec rake test_app
```

These commands only need to run once. The apps are created in:
- `development_app/` - Full development environment
- `spec/decidim_dummy_app/` - Test environment

After running these, you can start the development server:

```bash
cd development_app
bundle exec rails s -p 3000
```

## Feature Development Workflow

### 1. Planning Phase

Before starting code:
- Create GitHub issue describing the feature/fix
- Discuss approach and design with team
- Identify affected areas (models, views, controllers, etc.)
- Plan locale string additions
- Consider test coverage strategy

### 2. Branch Creation

```bash
# Create feature branch with descriptive name
git checkout -b feature/add-version-checker
# or for fixes
git checkout -b fix/locale-quote-issue
```

### 3. Development

**Before you start:** Make sure the test app has been created with `bundle exec rake test_app`.

```bash
# Install/update dependencies
bundle install

# Make code changes
# Write specs alongside features (TDD recommended)

# Run tests frequently
bundle exec rspec

# Run individual test file
bundle exec rspec spec/controllers/admin/checks_controller_spec.rb

# Run a specific test test located in a particular line
bundle exec rspec spec/controllers/admin/checks_controller_spec.rb:123

# Validate locale files
ruby -Ku -ryaml -e "Dir['config/locales/*.yml'].each { |f| YAML.load_file(f); puts \"✓ #{f}\" }"
```

### 4. Code Quality Checks

```bash
# Check for security vulnerabilities
bundle audit

# Lint and auto-fix Ruby code
bundle exec rubocop -A

# Lint and auto-fix ERB templates
bundle exec erb_lint app/**/*.erb --autocorrect

# Lint and auto-fix JavaScript
npm run lint-fix

# Lint and auto-fix CSS/SCSS
npm run stylelint-fix

# Check test coverage
SIMPLECOV=1 bundle exec rspec
```

### 5. Before Commit

Checklist:
- [ ] All linters passing (run auto-fix): `bundle exec rubocop -A && bundle exec erb_lint app/**/*.erb --autocorrect && npm run lint-fix && npm run stylelint-fix`
- [ ] All tests passing: `bundle exec rspec`
- [ ] Locale files valid: `ruby -Ku -ryaml -e "YAML.load_file('config/locales/en.yml')" && echo "Valid"`
- [ ] Code follows conventions (see CONVENTIONS.md)
- [ ] Comments added for complex logic
- [ ] CHANGELOG updated with feature description + PR reference
- [ ] README updated if user-facing change
- [ ] Base locale (en.yml) updated (other locales via Crowdin)

### 6. Commit Messages

Format:
```
[Feature/Fix] Brief description of change

- Detail about what was changed
- Why the change was made
- How to test the change

Closes #123
```

Example:
```
[Feature] Add version update checking

- Added decidim_version_outdated? helper method
- Fetches latest version from GitHub API (cached 1 hour)
- Shows warning callout when update available
- Updated base locale (en.yml), other translations via Crowdin
- Added comprehensive RSpec tests

Closes #456
PR #519, #518
```

### 7. Push & Create Pull Request

```bash
git push origin feature/add-version-checker
```

Pull Request template should include:
- Description of changes
- Issue reference (Closes #123)
- Testing instructions
- Screenshots for UI changes
- Decidim compatibility version
- Related PRs or issues

## Common Development Tasks

### Adding a New Feature

1. **Create the model/service logic**
   ```ruby
   # app/services/decidim/decidim_awesome/my_service.rb
   module Decidim::DecidimAwesome
     class MyService
       # Implementation
     end
   end
   ```

2. **Add tests**
   ```ruby
   # spec/services/decidim/decidim_awesome/my_service_spec.rb
   describe Decidim::DecidimAwesome::MyService do
     # Test implementation
   end
   ```

3. **Add view/controller logic**
   ```erb
   <!-- app/views/decidim/decidim_awesome/admin/my_view.html.erb -->
   <div class="my-component">
     <%= t(".my_key") %>
   </div>
   ```

4. **Add locale strings to base language (en.yml)**
   ```yaml
   # config/locales/en.yml
   en:
     decidim:
       decidim_awesome:
         admin:
           my_view:
             my_key: "Translation here"
   ```
   Other languages will be translated via Crowdin.

5. **Update CHANGELOG**
   ```markdown
   v0.14.2
   -------
   
   Features:
     - Description of feature ([#PR](link))
   ```

### Fixing a Bug

1. Write a failing test that reproduces the bug
2. Fix the bug in code
3. Verify test passes
4. Update CHANGELOG with fix description + PR reference
5. Update locale files if strings affected

### Adding Translations

When adding new user-facing strings:

1. Add to `config/locales/en.yml` (base language)
2. Use in view: `<%= t(".key") %>`
3. Other languages are managed via [Crowdin](https://crowdin.com/translate/decidim-awesome)
   - Community translators will handle the 16 other languages
   - For urgent needs, you can manually update specific locale files
4. Validate YAML syntax: `ruby -Ku -ryaml -e "Dir['config/locales/*.yml'].each { |f| YAML.load_file(f); puts \"✓ #{f}\" }"`

**All 17 supported locales**: ar, ca, cs, de, en, es, eu, fr, hu, it, ja, lt, nl, pt, pt-BR, ro, sv

### Updating Database Schema

Try to avoid introducing changes in the database unless absolutely necessary.
Instead use the built-in AwesomeConfig Variables.

For migrations:
1. Create migration: `bin/rails generate migration AddFieldToModel`
2. This migration will be create into `development_app` so move into the project first.
2. Write migration logic
3. Add tests for data migration if applicable
4. Document in CHANGELOG

## Code Review Considerations

When reviewing code, check:

1. **Functionality**
   - Does it solve the stated problem?
   - Are edge cases handled?
   - Is error handling present?

2. **Testing**
   - Are there tests?
   - Do tests cover happy and sad paths?
   - Is coverage adequate?

3. **Code Quality**
   - Does it follow conventions?
   - Do all linters pass (RuboCop, ERB Lint, ESLint, Stylelint)?
   - Is code readable and well-commented?
   - Are methods appropriately sized?

4. **Compatibility**
   - Is Decidim version compatible?
   - Does it work with current Ruby version?
   - Are gem dependencies reasonable?

5. **Localization**
   - Are all user-facing strings in en.yml?
   - Are other translations managed via Crowdin?
   - YAML syntax valid?

6. **Documentation**
   - Is CHANGELOG updated?
   - Is README updated if needed?
   - Are complex algorithms commented?

7. **Security**
   - Is user input sanitized?
   - Are permissions checked?
   - Are external APIs called safely?

## Troubleshooting Common Issues

### Tests Failing

```bash
# Clear test database
RAILS_ENV=test bundle exec rake db:reset

# Run tests with verbose output
bundle exec rspec --format documentation --no-fail-fast

# Run single test
bundle exec rspec spec/path/to/test_spec.rb:line_number
```

### Locale File Errors

```bash
# Check syntax of specific file
ruby -ryaml -e "YAML.load_file('config/locales/fr.yml')" && echo "Valid"

# Check all locale files
ruby -e "Dir['config/locales/*.yml'].each { |f| YAML.load_file(f) rescue puts \"ERROR: #{f}\"; puts \"✓ #{File.basename(f)}\" }"
```

### Gem Conflicts

```bash
# Update Gemfile.lock
bundle update

# Reinstall gems
bundle install --redownload

# Check for vulnerabilities
bundle audit update && bundle audit
```

## Performance Considerations

1. **Caching**
   - Cache GitHub API responses (1 hour)
   - Use `Rails.cache.fetch` with expires_in
   - Clear cache when deploying new version

2. **Database Queries**
   - Use eager loading: `includes()`, `preload()`
   - Avoid N+1 queries
   - Add indexes for frequently queried fields

3. **External API Calls**
   - Always set timeouts
   - Handle network errors gracefully
   - Cache responses to avoid repeated calls
   - Log errors for monitoring

## Deployment

After merge to main:

1. Create GitHub release with version number
2. Update gemspec version
3. Push to RubyGems: `gem push`
4. Create GitHub release with changelog
5. Verify RubyGems shows new version

## Useful Commands

```bash
# Module setup (run once)
bundle exec rake development_app    # Create development application
bundle exec rake test_app           # Create test application

# Development server (must cd into development_app first)
cd development_app
bundle exec rails s -p 3000

# Console
bundle exec rails console

# Database tasks
bundle exec rake db:migrate
bundle exec rake db:rollback

# Check gem versions
bundle show gem_name

# Update specific gem
bundle update gem_name

# View all installed gems
bundle list
```

## Resources

- Decidim Documentation: https://docs.decidim.org
- Rails Guides: https://guides.rubyonrails.org
- RSpec Documentation: https://rspec.info/
- Deface Docs: https://github.com/spree/deface
