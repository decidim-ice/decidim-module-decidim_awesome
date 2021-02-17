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

      textarea = page.find("textarea")
      textarea.fill_in with: "body {background: red;}"
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

      fill_in "foo", with: "body {background: green;}"
      find("*[type=submit]").click

      expect(page).to have_admin_callout("updated successfully")
      expect(page).not_to have_content("body {background: red;}")
      expect(page).to have_content("body {background: green;}")
      expect(page).to have_content("body {background: blue;}")
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

        within first(".scoped-style") do
          accept_confirm { click_link "Remove this CSS box" }
        end

        expect(page).to have_admin_callout("removed successfully")
        expect(page).to have_content("body {background: red;}")
        expect(page).not_to have_content("body {background: blue;}")
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
        within first(".scoped-style") do
          click_link "Add case"
        end

        select "Processes", from: "constraint_participatory_space_manifest"
        within ".modal-content" do
          find("*[type=submit]").click
        end

        sleep 2

        within first(".constraints-editor") do
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
          within first(".constraints-editor") do
            expect(page).to have_content("Processes")
          end

          within first(".scoped-style") do
            accept_confirm { click_link "Remove this CSS box" }
          end

          within first(".constraints-editor") do
            expect(page).not_to have_content("Processes")
          end

          expect(Decidim::DecidimAwesome::AwesomeConfig.find_by(organization: organization, var: :scoped_style_bar)).not_to be_present
        end
      end
    end
  end
end
