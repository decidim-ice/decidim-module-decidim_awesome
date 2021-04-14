# frozen_string_literal: true

require "spec_helper"

describe "Admin manages custom CSS", type: :system do
  let(:organization) { create :organization }
  let!(:admin) { create(:user, :admin, :confirmed, organization: organization) }
  let(:styles) do
    {}
  end
  let!(:config) { create :awesome_config, organization: organization, var: :scoped_styles, value: styles }
  let(:config_helper) { create :awesome_config, organization: organization, var: :scoped_style_bar }
  let!(:constraint) { create(:config_constraint, awesome_config: config_helper, settings: { "participatory_space_manifest" => "participatory_processes" }) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin_decidim_awesome.config_path(:styles)
  end

  context "when creating a new box" do
    it "saves the content in the hash" do
      click_link "Add a new CSS box"

      expect(page).to have_admin_callout("created successfully")

      sleep 1
      page.execute_script('document.querySelector(".CodeMirror").CodeMirror.setValue("body {background: red;}");')

      find("*[type=submit]").click

      expect(page).to have_admin_callout("updated successfully")
      expect(page).to have_content("body {background: red;}")
    end
  end

  context "when updating new box" do
    let(:styles) do
      {
        "foo" => "body {background: red;}",
        "bar" => "body {background: blue;}"
      }
    end

    it "updates the content in the hash" do
      expect(page).to have_content("body {background: red;}")
      expect(page).to have_content("body {background: blue;}")

      sleep 1
      page.execute_script('document.querySelector("[data-key=foo] .CodeMirror").CodeMirror.setValue("body {background: green;}");')
      find("*[type=submit]").click

      expect(page).to have_admin_callout("updated successfully")
      expect(page).not_to have_content("body {background: red;}")
      expect(page).to have_content("body {background: green;}")
      expect(page).to have_content("body {background: blue;}")
    end

    context "and there are CSS errors" do
      it "shows error message" do
        sleep 1
        page.execute_script('document.querySelector("[data-key=foo] .CodeMirror").CodeMirror.setValue("I am invalid CSS");')
        find("*[type=submit]").click

        expect(page).to have_admin_callout("Error updating configuration! CSS in box #foo is invalid")
        expect(page).not_to have_content("body {background: red;}")
        expect(page).to have_content("body {background: blue;}")
        expect(page).to have_content("I am invalid CSS")
        within ".scoped-style[data-key=\"foo\"] .form-error" do
          expect(page).to have_content("Error: Invalid CSS ")
        end
      end
    end

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

        within ".scoped-style[data-key=\"foo\"]" do
          accept_confirm { click_link "Remove this CSS box" }
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
        within ".scoped-style[data-key=\"foo\"]" do
          click_link "Add case"
        end

        select "Processes", from: "constraint_participatory_space_manifest"
        within ".modal-content" do
          find("*[type=submit]").click
        end

        sleep 2

        within ".scoped-style[data-key=\"foo\"] .constraints-editor" do
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
          within ".scoped-style[data-key=\"bar\"] .constraints-editor" do
            expect(page).to have_content("Processes")
          end

          within ".scoped-style[data-key=\"bar\"]" do
            click_link "Delete"
          end

          within ".scoped-style[data-key=\"bar\"] .constraints-editor" do
            expect(page).not_to have_content("Processes")
          end

          visit decidim_admin_decidim_awesome.config_path(:styles)

          within ".scoped-style[data-key=\"bar\"] .constraints-editor" do
            expect(page).not_to have_content("Processes")
          end

          expect(Decidim::DecidimAwesome::AwesomeConfig.find_by(organization: organization, var: :scoped_style_bar)).to be_present
          expect(Decidim::DecidimAwesome::AwesomeConfig.find_by(organization: organization, var: :scoped_style_bar).constraints).not_to be_present
        end
      end
    end
  end
end
