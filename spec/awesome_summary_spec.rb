# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/shared_examples/summary_examples"

# This test is a quick summary of the features available in awesome and a test for them enabled or not

shared_examples "with features enabled" do
  it_behaves_like "registered components", true
  it_behaves_like "activated concerns", true
  it_behaves_like "basic rendering", true
  it_behaves_like "custom menus", true
end

shared_examples "with features disabled" do
  it_behaves_like "registered components", false
  it_behaves_like "activated concerns", false
  it_behaves_like "basic rendering", false
  # custom menu checks after system checks so MenuRegistry is initialized with defaults
  it_behaves_like "custom menus", false
end

describe Decidim::DecidimAwesome do
  let(:organization) { create :organization }
  let(:user) { create :user, :admin, :confirmed, organization: organization }
  let!(:config) { create :awesome_config, organization: organization, var: :scoped_styles, value: { bar: styles } }
  let!(:allow_images_in_proposals) { create(:awesome_config, organization: organization, var: :allow_images_in_proposals, value: true) }
  let!(:allow_images_in_small_editor) { create(:awesome_config, organization: organization, var: :allow_images_in_small_editor, value: true) }
  let!(:allow_images_in_full_editor) { create(:awesome_config, organization: organization, var: :allow_images_in_full_editor, value: true) }
  let!(:use_markdown_editor) { create(:awesome_config, organization: organization, var: :use_markdown_editor, value: true) }
  let!(:allow_images_in_markdown_editor) { create(:awesome_config, organization: organization, var: :allow_images_in_markdown_editor, value: true) }
  let!(:auto_save_forms) { create(:awesome_config, organization: organization, var: :auto_save_forms, value: true) }
  let!(:intergram_for_admins) { create(:awesome_config, organization: organization, var: :intergram_for_admins, value: true) }
  let!(:intergram_for_public) { create(:awesome_config, organization: organization, var: :intergram_for_public, value: true) }
  let!(:config_public_settings) { create(:awesome_config, organization: organization, var: :intergram_for_public_settings, value: intergram) }
  let!(:config_admins_settings) { create(:awesome_config, organization: organization, var: :intergram_for_admins_settings, value: intergram) }
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
    puts "FEATUES=disabled bundle exec rspec spec/system/awesome_summary_spec.rb"
    puts "FEATUES=enabled bundle exec rspec spec/system/awesome_summary_spec.rb"
    puts ""
    puts "TEST SKIPPED!"
  end
end
