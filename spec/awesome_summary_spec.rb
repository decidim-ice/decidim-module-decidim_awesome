# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/shared_examples/summary_examples"

# This test is a quick summary of the features available in awesome and a test for them enabled or not

shared_examples "with features enabled" do
  it_behaves_like "registered components", true
  it_behaves_like "activated concerns", true
  it_behaves_like "basic rendering", true
  it_behaves_like "custom menus", true
  it_behaves_like "csp directives", true
end

shared_examples "with features disabled" do
  it_behaves_like "registered components", false
  it_behaves_like "activated concerns", false
  it_behaves_like "basic rendering", false
  # custom menu checks after system checks so MenuRegistry is initialized with defaults
  it_behaves_like "custom menus", false
  it_behaves_like "csp directives", false
end

describe Decidim::DecidimAwesome do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let!(:scoped_styles) { create(:awesome_config, organization:, var: :scoped_styles, value: { bar: styles }) }
  let!(:allow_images_in_proposals) { create(:awesome_config, organization:, var: :allow_images_in_proposals, value: true) }
  let!(:allow_images_in_editors) { create(:awesome_config, organization:, var: :allow_images_in_editors, value: true) }
  let!(:allow_videos_in_editors) { create(:awesome_config, organization:, var: :allow_videos_in_editors, value: true) }
  let!(:auto_save_forms) { create(:awesome_config, organization:, var: :auto_save_forms, value: true) }
  let!(:intergram_for_admins) { create(:awesome_config, organization:, var: :intergram_for_admins, value: true) }
  let!(:intergram_for_public) { create(:awesome_config, organization:, var: :intergram_for_public, value: true) }
  let!(:intergram_public_settings) { create(:awesome_config, organization:, var: :intergram_for_public_settings, value: intergram) }
  let!(:intergram_admins_settings) { create(:awesome_config, organization:, var: :intergram_for_admins_settings, value: intergram) }
  let!(:validate_title_min_length) { create(:awesome_config, organization:, var: :validate_title_min_length, value: 10) }
  let!(:validate_title_max_caps_percent) { create(:awesome_config, organization:, var: :validate_title_max_caps_percent, value: 10) }
  let!(:validate_title_max_marks_together) { create(:awesome_config, organization:, var: :validate_title_max_marks_together, value: 10) }
  let!(:validate_title_start_with_caps) { create(:awesome_config, organization:, var: :validate_title_start_with_caps, value: true) }
  let!(:validate_body_min_length) { create(:awesome_config, organization:, var: :validate_body_min_length, value: 10) }
  let!(:validate_body_max_caps_percent) { create(:awesome_config, organization:, var: :validate_body_max_caps_percent, value: 10) }
  let!(:validate_body_max_marks_together) { create(:awesome_config, organization:, var: :validate_body_max_marks_together, value: 10) }
  let!(:validate_body_start_with_caps) { create(:awesome_config, organization:, var: :validate_body_start_with_caps, value: true) }
  let!(:weighted_proposal_voting) { create(:awesome_config, organization:, var: :weighted_proposal_voting, value: []) }
  let!(:additional_proposal_sortings) { create(:awesome_config, organization:, var: :additional_proposal_sortings, value: []) }

  let(:styles) { "body {background: red;}" }
  let(:intergram) do
    { chat_id: "some-id" }
  end

  case ENV.fetch("FEATURES", nil)
  when "enabled"
    it_behaves_like "with features enabled"
  when "disabled"
    it_behaves_like "with features disabled"
  else
    puts 'Please execute this test with the env FEATURES set to "enabled" or "disabled"'
    puts ""
    puts "FEATURES=disabled bundle exec rspec spec/system/awesome_summary_spec.rb"
    puts "FEATURES=enabled bundle exec rspec spec/system/awesome_summary_spec.rb"
    puts ""
    puts "TEST SKIPPED!"
  end
end
