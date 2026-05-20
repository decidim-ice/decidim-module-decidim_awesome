# Decidim::DecidimAwesome

[![[CI] Tests 0.28](https://github.com/decidim-ice/decidim-module-decidim_awesome/actions/workflows/tests.yml/badge.svg)](https://github.com/decidim-ice/decidim-module-decidim_awesome/actions/workflows/tests.yml)
[![[CI] Lint](https://github.com/decidim-ice/decidim-module-decidim_awesome/actions/workflows/lint.yml/badge.svg)](https://github.com/decidim-ice/decidim-module-decidim_awesome/actions/workflows/lint.yml)
[![Maintainability](https://api.codeclimate.com/v1/badges/2dada53525dd5a944089/maintainability)](https://codeclimate.com/github/decidim-ice/decidim-module-decidim_awesome/maintainability)
[![Test Coverage](https://codecov.io/gh/decidim-ice/decidim-module-decidim_awesome/branch/main/graph/badge.svg?token=TFBMCLLZJG)](https://codecov.io/gh/decidim-ice/decidim-module-decidim_awesome)

**Usability and UX tweaks for Decidim.**

This plugin allows the administrators to expand the possibilities of Decidim beyond some existing limitations.
All tweaks are provided in a optional fashion with granular permissions that let the administrator to choose exactly where to apply those mods. Some tweaks can be applied to an assembly, other in an specific participatory process or even in a type of component only (for instance, only in proposals).

**DISCLAIMER: This module is heavily tested and widely used, however we do not accept any responsibility for breaking anything. Feedback is appreciated though.**

## Why this plugin?

Decidim is an awesome platform, but it has some limitations that can be annoying for the users or the admins. This plugin tries to solve some of them. See the list of tweaks below.

## Usage

DecidimAwesome is a module that hacks Decidim in order to provide more features or improve some aspects of it.

It generates and admin module that allows to choose what hacks to apply.
Each hack can be scoped to one or more specific participatory spaces or components.

### Tweaks:

For easier navigation, tweaks are also grouped by category in dedicated docs pages:

- [Tweaks documentation index](docs/tweaks/index.md)
- [Editor and content creation](docs/tweaks/editor-content.md)
- [Proposals and participation](docs/tweaks/proposals-participation.md)
- [Admin governance and accountability](docs/tweaks/admin-governance.md)
- [UI, theming and navigation](docs/tweaks/ui-theming-navigation.md)
- [Forms, surveys and verifications](docs/tweaks/forms-surveys-verifications.md)
- [Components and integrations](docs/tweaks/components-integrations.md)

## Installation

Add this line to your application's Gemfile:

```ruby
gem "decidim-decidim_awesome"
```

And then execute:

```bash
bundle
bin/rails decidim:upgrade
bin/rails db:migrate
```

> In production mode you must also precompile the assets:
>
> ```
> bin/rails assets:precompile
> ```

Go to `yourdomain/admin/decidim_awesome` and start tweaking things!

> **EXPERTS ONLY**
>
> Under the hood, when running `bundle exec rails decidim:upgrade` the `decidim-decidim_awesome` gem will run the following two tasks (that can also be run manually if you consider):
>
> ```bash
> bin/rails decidim_decidim_awesome:install:migrations
> bin/rails decidim_decidim_awesome:webpacker:install
> ```

The correct version of Decidim Awesome should resolved automatically by the Bundler.
However you can force some specific version using `gem "decidim-decidim_awesome", "~> 0.12.0"` in the Gemfile.

Depending on your Decidim version, choose the corresponding Awesome version to ensure compatibility:

| Awesome version | Compatible Decidim versions |
|---|---|
| 0.14.x | 0.31.x |
| 0.13.x | 0.30.x |
| 0.12.x | 0.29.x |
| 0.11.x | 0.28.x |
| 0.10.x | >= 0.26.7, >= 0.27.x |
| 0.9.2 | >= 0.26.7, >= 0.27.3 |
| 0.9.x | 0.26.x, 0.27.x |
| 0.8.x | 0.25.x, 0.26.x |
| 0.7.x | 0.23.x, 0.24.x |
| 0.6.x | 0.22.x, 0.23.x |
| 0.5.x | 0.21.x, 0.22.x |

Read the [CHANGELOG](CHANGELOG.md) for further details on changes and Decidim compatibility.

## Configuration

Each tweak can be enabled or disabled by default. It also can be deactivated so
admins do not even see it.

In order to personalize default values, create an initializer such as:

> **NOTE**: this is not necessary unless you want to **disable** some features. All features are enabled by default.

```ruby
# config/initializers/awesome_defaults.rb

# Change some variables defaults
Decidim::DecidimAwesome.configure do |config|
  # Enabled by default to all scopes, admins can still limit it's scope
  config.allow_images_in_editors = true

  # Disabled by default to all scopes, admins can enable it and limit it's scope
  config.allow_videos_in_editors = false

  # Disable scoped admins
  config.scoped_admins = :disabled

  # any other config var from lib/decidim/decidim_awesome.rb
  ...
end
```

For a complete list of options take a look at the [module defaults](lib/decidim/decidim_awesome/awesome.rb).

## Missing something?

We add new features and maintain them, however we do it according our needs as this is mostly voluntary work.
So if you feel that you can contribute feel free to create a pull request with your idea. We are open to incorporate anything reasonable.

We do ask some things:
- Each feature has to come with and activation option, same as the already existing (unless is something that do not modify predefined Decidim behavior)
- Try to avoid views or assets overrides. Many times it is just enough to add additional css or scripts that alter existing objects.

You can also ask for new feature by creating and issue and, if you are ready to provide funds for its development just contact us!

Thanks!

## Developing

To start contributing to this project, first:

- Install the basic dependencies (such as Ruby and PostgreSQL)
- Clone this repository

Decidim's main repository also provides a Docker configuration file if you
prefer to use Docker instead of installing the dependencies locally on your
machine.

You can create the development app by running the following commands after
cloning this project:

```bash
bundle
DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password> bundle exec rake development_app
```

Note that the database user has to have rights to create and drop a database in
order to create the dummy test app database.

Then to test how the module works in Decidim, start the development server:

```bash
cd development_app
DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password> bundle exec rails s
```

In case you are using [rbenv](https://github.com/rbenv/rbenv) and have the
[rbenv-vars](https://github.com/rbenv/rbenv-vars) plugin installed for it, you
can add the environment variables to the root directory of the project in a file
named `.rbenv-vars`. If these are defined for the environment, you can omit
defining these in the commands shown above.

### Developer Documentation

This project includes comprehensive documentation in the [`.ai/`](.ai/) folder, designed to help both human developers and AI agents understand the project structure, conventions, and workflows:

- [**README.md**](.ai/README.md) - Overview and quick reference guide
- [**ARCHITECTURE.md**](.ai/ARCHITECTURE.md) - Project structure, Rails engines, and override strategies
- [**CONVENTIONS.md**](.ai/CONVENTIONS.md) - Code style, linting requirements, and best practices
- [**WORKFLOW.md**](.ai/WORKFLOW.md) - Development workflow from setup to deployment
- [**TESTING.md**](.ai/TESTING.md) - RSpec patterns and testing guidelines
- [**QUICK_REFERENCE.md**](.ai/QUICK_REFERENCE.md) - Quick lookup cheat sheet
- [**DEFACE_ANALYSIS.md**](.ai/DEFACE_ANALYSIS.md) - Analysis of Deface overrides

Start with the [.ai/README.md](.ai/README.md) for an overview of the project's architecture, development practices, and override strategies.

### Updating formBuilder languages

There's a rake task to update the translations of the custom field's form builder interface:

```
bundle exec rake update_form_builder_i18n
```

This updates the `app/packs/src/vendor/form_builder_langs` folder.

### Code Styling

Please follow the code styling defined by the different linters that ensure we
are all talking with the same language collaborating on the same project. This
project is set to follow the same rules that Decidim itself follows.

[Rubocop](https://rubocop.readthedocs.io/) linter is used for the Ruby language.

You can run the code styling checks by running the following commands from the
console:

```bash
# Check for issues
bundle exec rubocop

# Auto-fix issues
bundle exec rubocop -A
```

To ease up following the style guide, you should install the plugin to your
favorite editor, such as:

- Sublime Text - [Sublime RuboCop](https://github.com/pderichs/sublime_rubocop)
- Visual Studio Code - [Rubocop for Visual Studio Code](https://github.com/misogi/vscode-ruby-rubocop)

### Testing

To run the tests run the following in the gem development path:

```bash
bundle
DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password> bundle exec rake test_app
DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password> bundle exec rspec
```

> Note: the following is not currently applicable as from version v0.11 this plugin is compatible one version at the time.
> This is left here for future reference.

However, this project works with different versions of Decidim. In order to test them all, we maintain two different Gemfiles: `Gemfile` and `Gemfile.legacy`. The first one is used for development and testing the latest Decidim version supported, the second one is used for testing against the old Decidim version.

You can run run tests against the legacy Decidim versions by using:

```bash
export DATABASE_USERNAME=<username>
export DATABASE_PASSWORD=<password>
RBENV_VERSION=3.2.2 BUNDLE_GEMFILE=Gemfile.legacy bundle
RBENV_VERSION=3.2.2 BUNDLE_GEMFILE=Gemfile.legacy bundle exec rake test_app
RBENV_VERSION=3.2.2 BUNDLE_GEMFILE=Gemfile.legacy bundle exec rspec
```

For convenience, you can use the scripts `bin/test` and `bin/test-legacy` to run tests against one or the other version:

```bash
bin/test spec/
bin/test-legacy spec/
```

- Rbenv is required for this script to work.

> **NOTE:** Remember to reset the database when changing between tests:
> ```bash
> bin/test --reset
> bin/test-legacy --reset
> ```


Note that the database user has to have rights to create and drop a database in
order to create the dummy test app database.

In case you are using [rbenv](https://github.com/rbenv/rbenv) and have the
[rbenv-vars](https://github.com/rbenv/rbenv-vars) plugin installed for it, you
can add these environment variables to the root directory of the project in a
file named `.rbenv-vars`. In this case, you can omit defining these in the
commands shown above.

### Test code coverage

Code coverage report is generated automatically in a folder named `coverage` in the project root which contains
the code coverage report.

```bash
firefox coverage/index.html
```

### Localization

If you would like to see this module in your own language, you can help with its
translation at Crowdin:

https://crowdin.com/translate/decidim-awesome

## License

This engine is distributed under the GNU AFFERO GENERAL PUBLIC LICENSE.

## Credits

This plugin maintainted by [![PokeCode](app/packs/images/decidim/decidim_awesome/pokecode-logo.png) PokeCode](https://pokecode.net/)
