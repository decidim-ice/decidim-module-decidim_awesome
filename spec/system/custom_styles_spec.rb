# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/shared_examples/custom_styles_examples"

describe "Custom styles", type: :system do
  let(:organization) { create :organization }
  let!(:participatory_process) { create :participatory_process, organization: organization }
  let!(:config) { create :awesome_config, organization: organization, var: :scoped_styles, value: styles }
  let(:config_helper) { create :awesome_config, organization: organization, var: :scoped_style_bar }
  let(:default_background_color) { "rgb(250, 250, 250)"}
  let(:styles) do
    {
      "bar" => "body {background: red;}"
    }
  end

  before do
    switch_to_host(organization.host)
    visit decidim.root_path
  end

  context "when there are custom styles" do
    it_behaves_like "extra css is added"
  end

  context "when there are empty css boxes" do
    let(:styles) do
      {}
    end

    it_behaves_like "no extra css is added"
  end

  context "when constraints are present" do
    let!(:constraint) { create(:config_constraint, awesome_config: config_helper, settings: settings) }
    let!(:other_constraint) { create(:config_constraint, awesome_config: config_helper, settings: other_settings) }
    let(:settings) do
      {}
    end

    let(:other_settings) do
      { "participatory_space_manifest" => "other" }
    end

    before do
      visit decidim.root_path
    end

    context "when there are custom styles" do
      it_behaves_like "extra css is added"
    end

    context "and there are no custom styles" do
      let(:styles) do
        {}
      end

      it_behaves_like "no extra css is added"
    end

    context "and custom styles are scoped" do
      let(:settings) do
        { "participatory_space_manifest" => "participatory_processes" }
      end

      context "and page do not match the scope" do
        it_behaves_like "no extra css is added"
      end

      context "and page matches the scope" do
        before do
          click_link "Processes"
        end

        it_behaves_like "extra css is added"

        context "and none constraint is present" do
          let(:other_settings) do
            { "participatory_space_manifest" => "none" }
          end

          it_behaves_like "no extra css is added"
        end
      end
    end
  end

  context "when there are custom styles with special characters" do
    let(:css) { %(body > a[href="hey"] { color: blue; }) }
    let(:styles) do
      {
        "special" => css
      }
    end

    it "decodes them correctly" do
      expect(page.body).to have_content(css)
    end
  end
end
