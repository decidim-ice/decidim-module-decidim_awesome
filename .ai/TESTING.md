# Testing Guidelines

## Overview

This project uses **RSpec** for testing with a focus on:
- Unit tests for models, helpers, services
- Integration tests for controllers
- Feature tests for user-facing functionality
- Comprehensive coverage of new features

## Running Tests

```bash
# All tests
bundle exec rspec

# Specific file
bundle exec rspec spec/controllers/admin/checks_controller_spec.rb

# Specific test
bundle exec rspec spec/controllers/admin/checks_controller_spec.rb:89

# With verbose output
bundle exec rspec --format documentation

# With coverage report
bundle exec rspec --format coverage
```

## Special Test Cases

### Awesome Summary Spec

The `awesome_summary_spec.rb` is a comprehensive test that validates all Decidim Awesome features work correctly in both enabled and disabled states. This test **requires** the `FEATURES` environment variable:

```bash
# Test with features enabled
FEATURES=enabled bundle exec rspec spec/awesome_summary_spec.rb

# Test with features disabled
FEATURES=disabled bundle exec rspec spec/awesome_summary_spec.rb
```

**Important**: Running this spec without the `FEATURES` env var will skip the test with a reminder message.

**What it tests**:
- Registered components (enabled/disabled state)
- Activated concerns (enabled/disabled state)
- Basic rendering with features on/off
- Custom menus functionality
- CSP directives configuration

**When to run**:
- After making changes to feature toggles
- Before releases to validate both states work
- When modifying core awesome configuration

## Test Structure

```ruby
# spec/controllers/admin/some_controller_spec.rb
require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe SomeController do
      routes { Decidim::DecidimAwesome::AdminEngine.routes }

      let(:user) { create(:user, :confirmed, :admin, organization:) }
      let(:organization) { create(:organization) }

      before do
        request.env["decidim.current_organization"] = user.organization
        sign_in user, scope: :user
      end

      describe "GET #index" do
        it "returns http success" do
          get :index
          expect(response).to have_http_status(:success)
        end
      end
    end
  end
end
```

## Factories & Fixtures

The project uses FactoryBot for creating test objects:

```ruby
# Create single object
user = create(:user, :confirmed)

# Create association
admin = create(:user, :admin, organization:)

# Build (in-memory, not persisted)
post = build(:post)

# Attributes only
attrs = attributes_for(:user)
```

Common factories:
- `create(:user)` - User object
- `create(:organization)` - Organization
- `create(:meeting)` - Meeting component
- `create(:proposal)` - Proposal

## Test Patterns

### Helper Tests

```ruby
describe SystemCheckerHelpers do
  let(:user) { create(:user, :admin) }
  let(:controller_instance) { ApplicationController.new }

  before do
    allow(controller_instance).to receive(:current_user).and_return(user)
  end

  describe "#decidim_version" do
    it "returns current version" do
      expect(helper.decidim_version).to eq(Decidim.version)
    end
  end
end
```

### Mocking External APIs

```ruby
describe "#awesome_latest_version" do
  let(:faraday_response) do
    double(success?: true, body: releases.to_json)
  end

  before do
    allow(Faraday).to receive(:get).and_return(faraday_response)
  end

  it "returns latest version" do
    expect(helper.awesome_latest_version).to eq("0.14.2")
  end
end
```

### Error Handling

```ruby
describe "#fetch_latest_version" do
  context "when API fails" do
    before do
      allow(Faraday).to receive(:get).and_raise(StandardError.new("Network error"))
      allow(Rails.logger).to receive(:error)
    end

    it "returns nil" do
      expect(helper.awesome_latest_version).to be_nil
    end

    it "logs the error" do
      helper.awesome_latest_version
      expect(Rails.logger).to have_received(:error)
    end
  end
end
```

## Test Coverage Targets

| Component | Target Coverage |
|-----------|-----------------|
| Models | 90%+ |
| Controllers | 80%+ |
| Helpers | 85%+ |
| Services | 90%+ |
| Overall | 80%+ |

## New Feature Testing Checklist

When adding a new feature, ensure:

- [ ] Unit tests for business logic
- [ ] Controller tests for endpoints
- [ ] Helper tests for view helpers
- [ ] Integration tests for workflows
- [ ] Error cases are tested
- [ ] Edge cases are covered
- [ ] External APIs are mocked
- [ ] Security considerations tested
- [ ] Locale keys added and tested
- [ ] CHANGELOG entry created with PR references

## Common Test Assertions

```ruby
# Expectations
expect(object).to eq(value)
expect(array).to include(element)
expect(object).to be_nil
expect(array).to be_empty
expect(value).to be > 5
expect(string).to match(/regex/)

# Mocking
allow(object).to receive(:method).and_return(value)
expect(object).to have_received(:method)
expect(object).to have_received(:method).with(arg)

# Database
expect { action }.to change(Model, :count).by(1)
expect { action }.not_to change(Model, :count)
```

## CI/CD Considerations

Tests are run automatically on:
- Push to branches
- Pull requests
- Before merge to main

Ensure:
- All tests pass locally before pushing
- No test flakiness (tests should be deterministic)
- Tests should complete in reasonable time
- Use `vcr` for recording/replaying HTTP interactions if needed

## Debugging Tests

```bash
# Run with debugging
bundle exec rspec --format documentation --no-fail-fast

# Run single test with output
bundle exec rspec spec/path/to/file_spec.rb:25 -fd

# Use binding.pry for debugging
within a test, add: binding.pry
Then step through with: next, step, continue

# View test output
bundle exec rspec --format json > test_results.json
```

## Best Practices

1. **Keep Tests Focused**
   - One concept per test
   - Clear test names that explain what's being tested
   - Avoid testing implementation details

2. **DRY Testing**
   - Use `let` blocks for setup
   - Use `before` hooks for common setup
   - Create shared examples for repeated patterns

3. **Speed**
   - Minimize database writes
   - Mock external services
   - Use `:js => false` for most tests (system tests use js)
   - Factor out slow operations

4. **Maintainability**
   - Write tests that fail clearly when functionality breaks
   - Avoid magic numbers and strings
   - Document complex test scenarios
   - Keep test code as clean as production code

5. **Coverage**
   - Aim for coverage of all public methods
   - Test both happy and sad paths
   - Test boundary conditions
   - Don't obsess over untestable code (e.g., views)
