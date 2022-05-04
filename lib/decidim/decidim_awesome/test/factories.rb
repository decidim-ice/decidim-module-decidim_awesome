# frozen_string_literal: true

require "decidim/core/test/factories"
require "decidim/proposals/test/factories"
require "decidim/surveys/test/factories"

FactoryBot.define do
  factory :awesome_config, class: "Decidim::DecidimAwesome::AwesomeConfig" do
    var { Faker::Hacker.noun }
    value { Decidim::DecidimAwesome.config.to_a.sample(1).to_h }
    organization { create :organization }
  end

  factory :config_constraint, class: "Decidim::DecidimAwesome::ConfigConstraint" do
    settings { { Faker::Hacker.noun => Faker::Hacker.noun } }
    awesome_config { create :awesome_config }
  end

  factory :awesome_editor_image, class: "Decidim::DecidimAwesome::EditorImage" do
    file { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }
    path { Faker::Internet.url(host: "", scheme: "") }
    author { create :user }
    organization { create :organization }
  end

  factory :map_component, parent: :component do
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :proposals).i18n_name }
    manifest_name { :awesome_map }
    participatory_space { create(:participatory_process, :with_steps, organization: organization) }
  end

  factory :iframe_component, parent: :component do
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :proposals).i18n_name }
    manifest_name { :awesome_iframe }
    participatory_space { create(:participatory_process, :with_steps, organization: organization) }
  end
end
