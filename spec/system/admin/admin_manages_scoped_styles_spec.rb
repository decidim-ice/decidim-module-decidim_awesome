# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/shared_examples/box_label_editor_examples"

describe "Admin manages scoped styles", type: :system do
  let(:organization) { create(:organization) }
  let!(:admin) { create(:user, :admin, :confirmed, organization: organization) }
  let(:styles) do
    {}
  end
  let!(:config) { create(:awesome_config, organization: organization, var: :scoped_styles, value: styles) }
  let(:config_helper) { create(:awesome_config, organization: organization, var: :scoped_style_bar) }
  let!(:constraint) { create(:config_constraint, awesome_config: config_helper, settings: { "participatory_space_manifest" => "participatory_processes" }) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin_decidim_awesome.config_path(:styles)
  end

  context "when creating a new box" do
    it "saves the content in the hash" do
      click_link_or_button "Add a new CSS box"

      expect(page).to have_admin_callout("created successfully")

      sleep 1
      page.execute_script('document.querySelector(".CodeMirror").CodeMirror.setValue("body {background: red;}");')

      click_link_or_button "Update configuration"

      expect(page).to have_admin_callout("updated successfully")
      expect(page).to have_content("body {background: red;}")
    end
  end

  shared_examples "saves content" do |key|
    it "updates succesfully" do
      expect(page).to have_content("body {background: red;}")
      expect(page).to have_content("body {background: blue;}")

      sleep 1
      page.execute_script("document.querySelector(\"[data-key=#{key}] .CodeMirror\").CodeMirror.setValue(\"body {background: green;}\");")
      click_link_or_button "Update configuration"

      expect(page).to have_admin_callout("updated successfully")
      expect(page).not_to have_content("body {background: red;}")
      expect(page).to have_content("body {background: green;}")
      expect(page).to have_content("body {background: blue;}")
    end

    it "shows error message if invalid" do
      sleep 1
      page.execute_script("document.querySelector(\"[data-key=#{key}] .CodeMirror\").CodeMirror.setValue(\"I am invalid CSS\");")
      click_link_or_button "Update configuration"

      expect(page).to have_admin_callout("Error updating configuration! CSS in box ##{key} is invalid")
      expect(page).not_to have_content("body {background: red;}")
      expect(page).to have_content("body {background: blue;}")
      expect(page).to have_content("I am invalid CSS")
      within ".scoped_styles_container[data-key=\"#{key}\"] .form-error" do
        expect(page).to have_content("Error: Invalid CSS ")
      end
    end
  end

  context "when updating new box" do
    let(:styles) do
      {
        "foo" => "body {background: red;}",
        "bar" => "body {background: blue;}"
      }
    end

    it_behaves_like "saves content", "foo"

    it_behaves_like "edits box label inline", :css, :foo

    context "when removing a box" do
      let(:styles) do
        {
          "foo" => "body {background: red;}",
          "bar" => "body {background: blue;}"
        }
      end

      it "updates the content in the hash" do
        expect(page).to have_content("body {background: red;}")
        expect(page).to have_content("body {background: blue;}")

        within ".scoped_styles_container[data-key=\"foo\"]" do
          accept_confirm { click_link_or_button "Remove this CSS box" }
        end

        expect(page).to have_admin_callout("removed successfully")
        expect(page).to have_content("body {background: blue;}")
        expect(page).not_to have_content("body {background: red;}")
        expect(Decidim::DecidimAwesome::AwesomeConfig.find_by(organization: organization, var: :scoped_style_foo)).not_to be_present
        expect(Decidim::DecidimAwesome::AwesomeConfig.find_by(organization: organization, var: :scoped_style_bar)).to be_present
      end
    end

    context "when adding a constraint" do
      let(:styles) do
        {
          "foo" => "body {background: red;}",
          "bar" => "body {background: blue;}"
        }
      end

      it "adds a new config helper var" do
        find("#new-scoped_style_foo").click

        select "Processes", from: "constraint_participatory_space_manifest"
        within "#constraintsModal" do
          find("*[type=submit]").click
        end

        within ".scoped_styles_container[data-key=\"foo\"] .constraints-editor" do
          expect(page).to have_content("Processes")
        end

        expect(Decidim::DecidimAwesome::AwesomeConfig.find_by(organization: organization, var: :scoped_style_bar)).to be_present
        expect(Decidim::DecidimAwesome::AwesomeConfig.find_by(organization: organization, var: :scoped_style_bar).constraints.first.settings).to eq("participatory_space_manifest" => "participatory_processes")
      end

      context "when removing a constraint" do
        let(:styles) do
          {
            "foo" => "body {background: red;}",
            "bar" => "body {background: blue;}"
          }
        end

        it "removes the helper config var" do
          within ".scoped_styles_container[data-key=\"bar\"] .constraints-editor" do
            expect(page).to have_content("Processes")
          end

          within ".scoped_styles_container[data-key=\"bar\"] .constraints-editor" do
            click_link_or_button "Delete"
          end

          within ".scoped_styles_container[data-key=\"bar\"] .constraints-editor" do
            expect(page).not_to have_content("Processes")
          end

          visit decidim_admin_decidim_awesome.config_path(:styles)

          within ".scoped_styles_container[data-key=\"bar\"] .constraints-editor" do
            expect(page).not_to have_content("Processes")
          end

          expect(Decidim::DecidimAwesome::AwesomeConfig.find_by(organization: organization, var: :scoped_style_bar)).to be_present
          expect(Decidim::DecidimAwesome::AwesomeConfig.find_by(organization: organization, var: :scoped_style_bar).constraints).not_to be_present
        end
      end
    end
  end
end
