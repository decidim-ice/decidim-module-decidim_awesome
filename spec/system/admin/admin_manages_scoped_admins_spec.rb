# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/shared_examples/box_label_editor_examples"

describe "Admin manages scoped admins" do
  let(:organization) { create(:organization) }
  let!(:admin) { create(:user, :admin, :confirmed, organization:) }
  let!(:user) { create(:user, :confirmed, organization:) }
  let!(:user2) { create(:user, :confirmed, organization:) }
  let!(:user3) { create(:user, :confirmed, organization:) }
  let(:admins) do
    {}
  end
  let!(:config) { create(:awesome_config, organization:, var: :scoped_admins, value: admins) }
  let(:config_helper) { create(:awesome_config, organization:, var: :scoped_admin_bar) }
  let!(:constraint) { create(:config_constraint, awesome_config: config_helper, settings: { "participatory_space_manifest" => "participatory_processes" }) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin_decidim_awesome.config_path(:admins)
  end

  context "when creating a new box" do
    it "saves the content" do
      click_link_or_button 'Add a new "Scoped Admins" group'

      expect(page).to have_admin_callout("created successfully")

      expect(page).to have_no_content(user.name.to_s)
      sleep 1
      page.execute_script("$('.multiusers-select:first').append(new Option('#{user.name}', #{user.id}, true, true)).trigger('change');")

      click_link_or_button "Update configuration"

      expect(page).to have_admin_callout("updated successfully")
      expect(page).to have_content(user.name.to_s)
    end
  end

  shared_examples "saves content" do |_key|
    it "updates succesfully" do
      expect(page).to have_no_content(user.name.to_s)
      expect(page).to have_content(user2.name.to_s)
      expect(page).to have_content(user3.name.to_s)

      sleep 1
      page.execute_script("$('.multiusers-select:first').append(new Option('#{user.name}', #{user.id}, true, true)).trigger('change');")
      click_link_or_button "Update configuration"

      expect(page).to have_admin_callout("updated successfully")
      expect(page).to have_content(user.name.to_s)
      expect(page).to have_content(user.name.to_s)
      expect(page).to have_content(user3.name.to_s)
    end
  end

  context "when updating new box" do
    let(:admins) do
      {
        "foo" => [user2.id.to_s],
        "bar" => [user3.id.to_s]
      }
    end

    it_behaves_like "saves content", "foo"

    it_behaves_like "edits box label inline", :admins, :foo

    context "when removing a box" do
      let(:admins) do
        {
          "foo" => [user2.id.to_s],
          "bar" => [user3.id.to_s]
        }
      end

      it "updates the content" do
        expect(page).to have_content(user2.name.to_s)
        expect(page).to have_content(user3.name.to_s)

        within ".scoped_admins_container[data-key=\"foo\"]" do
          accept_confirm { click_link_or_button 'Remove this "Scoped Admins" group' }
        end

        expect(page).to have_admin_callout("removed successfully")
        expect(page).to have_content(user3.name.to_s)
        expect(page).to have_no_content(user2.name.to_s)
        expect(Decidim::DecidimAwesome::AwesomeConfig.find_by(organization:, var: :scoped_admin_foo)).not_to be_present
        expect(Decidim::DecidimAwesome::AwesomeConfig.find_by(organization:, var: :scoped_admin_bar)).to be_present
      end
    end

    context "when adding a constraint" do
      let(:admins) do
        {
          "foo" => [user2.id.to_s],
          "bar" => [user3.id.to_s]
        }
      end

      it "adds a new config helper var" do
        within ".scoped_admins_container[data-key=\"foo\"]" do
          click_link_or_button "Add case"
        end

        select "Processes", from: "constraint_participatory_space_manifest"
        within "#new-modal-scoped_admin_foo" do
          find("*[type=submit]").click
        end

        sleep 2

        within ".scoped_admins_container[data-key=\"foo\"] .constraints-editor" do
          expect(page).to have_content("Processes")
        end

        expect(Decidim::DecidimAwesome::AwesomeConfig.find_by(organization:, var: :scoped_admin_bar)).to be_present
        expect(Decidim::DecidimAwesome::AwesomeConfig.find_by(organization:, var: :scoped_admin_bar).constraints.first.settings).to eq("participatory_space_manifest" => "participatory_processes")
      end

      context "when removing a constraint" do
        let(:admins) do
          {
            "foo" => [user2.id.to_s],
            "bar" => [user3.id.to_s]
          }
        end

        it "removes the helper config var" do
          within ".scoped_admins_container[data-key=\"bar\"] .constraints-editor" do
            expect(page).to have_content("Processes")
          end

          within ".scoped_admins_container[data-key=\"bar\"]" do
            click_link_or_button "Delete"
          end

          within ".scoped_admins_container[data-key=\"bar\"] .constraints-editor" do
            expect(page).to have_no_content("Processes")
          end

          visit decidim_admin_decidim_awesome.config_path(:admins)

          within ".scoped_admins_container[data-key=\"bar\"] .constraints-editor" do
            expect(page).to have_no_content("Processes")
          end

          expect(Decidim::DecidimAwesome::AwesomeConfig.find_by(organization:, var: :scoped_admin_bar)).to be_present
          expect(Decidim::DecidimAwesome::AwesomeConfig.find_by(organization:, var: :scoped_admin_bar).constraints).not_to be_present
        end
      end
    end
  end
end
