# Decidim::DecidimAwesome

[![Build](https://github.com/Platoniq/decidim-module-decidim_awesome/workflows/Build/badge.svg)](https://github.com/Platoniq/decidim-module-decidim_awesome/actions)
[![Maintainability](https://api.codeclimate.com/v1/badges/2dada53525dd5a944089/maintainability)](https://codeclimate.com/github/Platoniq/decidim-module-decidim_awesome/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/2dada53525dd5a944089/test_coverage)](https://codeclimate.com/github/Platoniq/decidim-module-decidim_awesome/test_coverage)

Usability and UX tweaks for Decidim.

This plugin allows the administrators to expand the possibilities of Decidim beyond some existing limitations. 
All tweaks are provided in a optional fashion with granular permissions that let the administrator to choose exactly where to apply those mods. Some tweaks can be applied to any assembly, other in an specific participatory process or even in type of component only.

**This in beta status, we do not accept any responsibility for breaking anything. Feedback is appreciated though.**

## Usage

DecidimAwesome is a module that hacks Decidim in order to provide more features or improve some aspects of it.

It generates and admin module that allows to choose what hacks to apply.
Each hack can be scoped to one or more specific participatory spaces or components.

### Tweaks:

#### 1. Image support for the Quill editor

Modifies the WYSIWYG editor in Decidim by adding the possibility to insert images. When uploading images, Drag & Drop is supported. Images will be uploaded to the server and inserted as external resources (it doesn't use base64 inline encoding).

This feature allows you use images in newsletters as well.

![Images in Quill Editor](examples/quill-images.png)

#### 2. Auto-save for surveys and forms

With this feature admins can activate (globally or scoped) an auto-save feature for any form in Decidim.

It works purely in the client side by using LocalStorage capabilities of the browser. Data is store every time any field changes and retrieved automatically if the same user with the same browser returns to it in the future.

Saving the form removes the stored data.

![Auto save in forms](examples/auto-save.png)

#### 3. Images in proposals

Event if you haven't activated the WYSIWYG editor (Quill) in public views (ie: proposals use a simple textarea). You can allow users to upload images in them by dragg & drop over the text area.

![Proposal images](examples/proposal-images.png)

#### 4. Markdown editor for proposals

Allows to use markdown when creating proposals instead of a bare textarea.

#### 5. Admin scope configuration

All tweaks can be configured and scoped to a specific participatory space, a type of participatory space, a type of component or a specific component.

Many scopes can be defined for every tweak.

![Admin tweaks for editors](examples/admin-editors.png)


#### 6. To be continued...

Some things in the road-map: 

1. Improve the conversation in comments by allowing images
1. Direct export of surveys in PDF
1. Allow to create surveys where the responding user is known
1. Propose something! or even better send a PR!


## Installation

Add this line to your application's Gemfile:

```ruby
gem "decidim-decidim_awesome", git: "https://github.com/Platoniq/decidim-module-decidim_awesome"
```

And then execute:

```bash
bundle
bundle exec rails decidim_decidim_awesome:install:migrations
bundle exec rails db:migrate
```

## Configuration

Each tweak can be enabled or disabled by default. It also can be deactivated so 
admins do not even see it.

In order to personalize default values, create an initializer such as:

```ruby
# config/initializers/awesome_defaults.rb

# Change some variables defaults
Decidim::DecidimAwesome.configure do |config|
  # Enabled by default to all scopes, admins can still limit it's scope
  config.allow_images_in_full_editor = true

  # Disabled by default to all scopes, admins can enable it and limit it's scope
  config.allow_images_in_small_editor = false

  # De-activated, admins don't even see it as an option
  config.use_markdown_editor = :disabled
end
```

For a complete list of options take a look at the [module defaults](lib/decidim/decidim_awesome.rb).

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

### Code Styling

Please follow the code styling defined by the different linters that ensure we
are all talking with the same language collaborating on the same project. This
project is set to follow the same rules that Decidim itself follows.

[Rubocop](https://rubocop.readthedocs.io/) linter is used for the Ruby language.

You can run the code styling checks by running the following commands from the
console:

```
bundle exec rubocop
```

To ease up following the style guide, you should install the plugin to your
favorite editor, such as:

- Atom - [linter-rubocop](https://atom.io/packages/linter-rubocop)
- Sublime Text - [Sublime RuboCop](https://github.com/pderichs/sublime_rubocop)
- Visual Studio Code - [Rubocop for Visual Studio Code](https://github.com/misogi/vscode-ruby-rubocop)

### Testing

To run the tests run the following in the gem development path:

```bash
bundle
DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password> bundle exec rake test_app
DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password> bundle exec rspec
```

However, this project also make use of the gem [Appraisals](https://github.com/thoughtbot/appraisal) in order to test againts several versions of Decidim. The idea is to suport same supported versions of Decidim.

You can run run all tests againts all Decidim versions by using:
```bash
bundle exec appraisal install
DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password> bundle exec rake test_app
DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password> bundle exec appraisal rspec
```


Note that the database user has to have rights to create and drop a database in
order to create the dummy test app database.

In case you are using [rbenv](https://github.com/rbenv/rbenv) and have the
[rbenv-vars](https://github.com/rbenv/rbenv-vars) plugin installed for it, you
can add these environment variables to the root directory of the project in a
file named `.rbenv-vars`. In this case, you can omit defining these in the
commands shown above.

### Test code coverage

If you want to generate the code coverage report for the tests, you can use
the `SIMPLECOV=1` environment variable in the rspec command as follows:

```bash
SIMPLECOV=1 bundle exec rspec
```

This will generate a folder named `coverage` in the project root which contains
the code coverage report.

### Localization

If you would like to see this module in your own language, you can help with its
translation at Crowdin:

https://crowdin.com/translate/decidim-awesome

## License

This engine is distributed under the GNU AFFERO GENERAL PUBLIC LICENSE.

## Credits

This plugin has been developed by ![Platoniq](app/assets/images/decidim/decidim_awesome/platoniq-logo.png)
