# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/shared_examples/box_label_editor_examples"
require "decidim/decidim_awesome/test/shared_examples/custom_styles_examples"

describe "Admin manages scoped styles", type: :system do
  let(:organization) { create(:organization) }
  let!(:admin) { create(:user, :admin, :confirmed, organization: organization) }
  let(:styles) do
    {}
  end
  let(:var_name) { :scoped_style }
  let!(:config) { create(:awesome_config, organization: organization, var: "#{var_name}s", value: styles) }
  let(:config_helper) { create(:awesome_config, organization: organization, var: "#{var_name}_bar") }
  let!(:constraint) { create(:config_constraint, awesome_config: config_helper, settings: { "participatory_space_manifest" => "participatory_processes" }) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin_decidim_awesome.config_path(:scoped_admin_styles)
  end

  describe "public custom styles" do
    before do
      visit decidim_admin_decidim_awesome.config_path(:scoped_styles)
    end

    it_behaves_like "creates a new box", "public frontend"

    context "when updating new box" do
      let(:styles) do
        {
          "foo" => "body {background: red;}",
          "bar" => "body {background: blue;}"
        }
      end

      it_behaves_like "saves content", "foo"
      it_behaves_like "edits box label inline", :css, :foo
      it_behaves_like "removes a box"
      it_behaves_like "adds a constraint", "public frontend"
      it_behaves_like "removes a constraint"
    end
  end

  it_behaves_like "creates a new box", "admin panel"

  context "when updating new box" do
    let(:styles) do
      {
        "foo" => "body {background: red;}",
        "bar" => "body {background: blue;}"
      }
    end

    it_behaves_like "saves content", "foo"
    it_behaves_like "edits box label inline", :css, :foo
    it_behaves_like "removes a box"
    it_behaves_like "adds a constraint", "admin panel"
    it_behaves_like "removes a constraint"
  end
end
