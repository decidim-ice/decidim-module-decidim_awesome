# Application Context System Tests

This directory contains system tests for the `application_context!` feature added to the Decidim::DecidimAwesome::Config class.

## Overview

The `application_context!` method was added to properly handle user authentication context when evaluating configuration settings. This method:

1. Sets the application context with the current user
2. Updates the context state to "user_logged_in" or "anonymous" based on the user's authentication status
3. Affects how configurations with user-context constraints are evaluated

## Test Coverage

### Unit Tests (`spec/lib/config_spec.rb`)

- Tests the `application_context!` method directly
- Verifies context setting for logged in vs anonymous users
- Tests edge cases and parameter handling
- Verifies impact on configuration evaluation

### System Tests (`spec/system/public/application_context_spec.rb`)

- Tests application context functionality in browser environment
- Verifies menu visibility based on user authentication context
- Tests context preservation across user login/logout
- Integration tests with actual UI components

### Controller Integration Tests (`spec/system/public/required_authorizations_application_context_spec.rb`)

- Tests application context usage in RequiredAuthorizationsController
- Verifies proper context setting in authorization flows
- Tests context-dependent authorization requirements
- Validates error handling and redirects

## Key Test Scenarios

1. **Anonymous User Context**: Verifies that anonymous users get "anonymous" context
2. **Logged User Context**: Verifies that logged users get "user_logged_in" context  
3. **Menu Visibility**: Tests that menu items with visibility constraints work correctly
4. **Authorization Flow**: Tests that authorization requirements respect user context
5. **Context Transitions**: Tests behavior when users login/logout

## Usage Examples

The `application_context!` method is used in various parts of the application:

```ruby
# In controllers
config = Config.new(current_organization)
config.application_context!(current_user: current_user)

# Affects configuration evaluation
config.config[:some_setting] # Will respect user context constraints
```

## Test Patterns

All tests follow established Decidim and DecidimAwesome patterns:

- Use FactoryBot factories (`create(:awesome_config)`, etc.)
- Follow RSpec conventions with proper `describe`, `context`, `it` blocks
- Use Capybara for system tests with proper page interactions
- Include proper setup/teardown with `before` blocks
- Use shared examples where appropriate