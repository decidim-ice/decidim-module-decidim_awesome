# frozen_string_literal: true

require "decidim/core/test/factories"

FactoryBot.define do
  factory :awesome_config, class: "Decidim::DecidimAwesome::AwesomeConfig" do
    var { Faker::Hacker.noun }
    value { Decidim::DecidimAwesome.config.to_a.sample(1).to_h }
    organization { create :organization }
  end
end
