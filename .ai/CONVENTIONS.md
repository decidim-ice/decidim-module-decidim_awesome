# Code Conventions & Standards

## Ruby/Rails Style

This project follows standard Rails conventions:

1. **File Organization**
   - Controllers in `app/controllers/`
   - Models in `app/models/`
   - Views in `app/views/`
   - Helpers in `app/helpers/`
   - Services in `app/services/` or `app/commands/`

2. **Naming Conventions**
   - Classes: `PascalCase`
   - Methods: `snake_case`
   - Constants: `SCREAMING_SNAKE_CASE`
   - Files: `snake_case.rb`

3. **Method Length**
   - Keep methods focused and under 30 lines when possible
   - Extract complex logic into separate methods or service objects

4. **Comments**
   - Use comments for "why", not "what" (code should be self-documenting)
   - Comment complex algorithms or non-obvious logic
   - Use `# frozen_string_literal: true` at top of files

## Code Quality & Linting

All code should pass linting checks before committing. Run these commands to automatically fix most issues:

1. **Ruby (RuboCop)**
   ```bash
   # Auto-fix Ruby style issues
   bundle exec rubocop -A
   ```
   - Checks Ruby code style and common mistakes
   - `-A` flag auto-corrects safe violations
   - Configuration in `.rubocop.yml`

2. **ERB Templates (ERB Lint)**
   ```bash
   # Auto-fix ERB template issues
   bundle exec erb_lint app/**/*.erb --autocorrect
   ```
   - Validates ERB template syntax and style
   - Checks for accessibility issues
   - Configuration in `.erb-lint.yml`

3. **JavaScript (ESLint)**
   ```bash
   # Auto-fix JavaScript style and errors
   npm run lint-fix
   ```
   - Checks JavaScript code style
   - Enforces consistent patterns
   - Configuration in `.eslintrc.js` or `package.json`

4. **CSS/SCSS (Stylelint)**
   ```bash
   # Auto-fix CSS/SCSS style issues
   npm run stylelint-fix
   ```
   - Validates CSS/SCSS syntax and conventions
   - Enforces consistent formatting
   - Configuration in `.stylelintrc.json` or `package.json`

**Pre-commit workflow:**
```bash
# Run all linters before committing
bundle exec rubocop -A
bundle exec erb_lint app/**/*.erb --autocorrect
npm run lint-fix
npm run stylelint-fix

# Then run tests
bundle exec rspec

# If all pass, commit
git add .
git commit -m "[Feature] Your commit message"
```

## Module Structure

All code should be within the `Decidim::DecidimAwesome` namespace:

```ruby
module Decidim
  module DecidimAwesome
    module Admin
      class MyController < DecidimAwesome::Admin::ApplicationController
        # Implementation
      end
    end
  end
end
```

## Locale Files (YAML)

1. **File Format**
   ```yaml
   en:
     decidim:
       some_module:
         some_key: "Some value"
         interpolated: "Value is %{variable}"
   ```

2. **Supported Languages** (17 total)
   - ar.yml (Arabic)
   - ca.yml (Catalan)
   - cs.yml (Czech)
   - de.yml (German)
   - en.yml (English) - Base language
   - es.yml (Spanish)
   - eu.yml (Basque)
   - fr.yml (French)
   - hu.yml (Hungarian)
   - it.yml (Italian)
   - ja.yml (Japanese)
   - lt.yml (Lithuanian)
   - nl.yml (Dutch)
   - pt.yml (Portuguese)
   - pt-BR.yml (Portuguese/Brazilian)
   - ro.yml (Romanian)
   - sv.yml (Swedish)

   **Note**: Translations are managed via [Crowdin](https://crowdin.com/translate/decidim-awesome). When adding new strings, add them to `en.yml` first, then they will be translated by the community.

3. **Validation**
   ```bash
   ruby -Ku -ryaml -e "Dir['config/locales/*.yml'].each { |f| YAML.load_file(f); puts \"✓ #{f}\" }"
   ```

4. **Key Naming**
   - Use dot notation for nested keys
   - Be descriptive: `awesome_update_available` not `update_msg`
   - Group related keys together

## Testing (RSpec)

1. **File Locations**
   ```
   spec/
   ├── controllers/
   ├── models/
   ├── helpers/
   ├── services/
   └── system/  # Feature tests
   ```

2. **Test Structure**
   ```ruby
   describe ClassName do
     let(:object) { create(:object) }
     
     describe "#method_name" do
       context "when condition is true" do
         it "does something" do
           expect(object.method_name).to eq(expected)
         end
       end
     end
   end
   ```

3. **Coverage Requirements**
   - New features should include specs
   - Aim for >80% code coverage
   - Test both success and failure paths
   - Use mocks for external API calls

## Views & Templates (ERB)

1. **Template Syntax**
   - Use ERB tags: `<%= %>` for output, `<% %>` for logic
   - Use Deface for non-intrusive overrides
   - Keep logic minimal (use helpers/presenters)

2. **HTML Structure**
   - Use semantic HTML5
   - Follow Tailwind CSS conventions
   - Ensure accessibility (ARIA labels, semantic elements)

3. **Form Helpers**
   ```erb
   <%= form_with(model: object) do |f| %>
     <%= f.text_field :name %>
     <%= f.submit %>
   <% end %>
   ```

## Git Commit Messages

1. **Format**
   ```
   [Feature/Fix/Docs] Brief description

   Longer explanation if needed.
   
   Closes #123
   ```

2. **Examples**
   ```
   [Feature] Add version update checker for Decidim
   
   Fetches latest version from GitHub API and displays
   warning on System Compatibility page.
   
   Includes specs and updated base locale (en.yml).
   
   PR #519, #518
   ```

3. **Reference Issues/PRs**
   - Use `#123` for GitHub issues
   - Use `Closes #123` to auto-close issues
   - Link related PRs in description

## Documentation

1. **README Updates**
   - Document new features in README.md
   - Include usage examples where applicable
   - Keep feature list current

2. **CHANGELOG Updates**
   - Add entry for each new feature/fix
   - Include PR links: `([#123](https://github.com/decidim-ice/decidim-module-decidim_awesome/pull/123))`
   - Group by version with Decidim compatibility

3. **Code Comments**
   - Document complex algorithms
   - Explain "why" not "what"
   - Keep comments updated with code

## Compatibility

1. **Decidim Version**
   - Update `lib/decidim/decidim_awesome/version.rb`
   - `COMPAT_DECIDIM_VERSION` specifies supported versions
   - Current: `0.31.x`

2. **Ruby Version**
   - Minimum Ruby 3.3 (set in gemspec)
   - Use modern Ruby features where appropriate

3. **Gems**
   - Keep dependencies minimal
   - Use already-included gems when possible
   - Faraday is preferred for HTTP calls

## Security

1. **Sanitization**
   - Always sanitize user input
   - Use Rails helpers: `sanitize()`, `h()`
   - Check for authorization with Decidim permissions

2. **API Calls**
   - Use HTTP client (Faraday) with timeouts
   - Handle network errors gracefully
   - Log errors but don't expose sensitive data

3. **Dependencies**
   - Check for security vulnerabilities: `bundle audit`
   - Keep gems updated regularly
   - Review security releases promptly
