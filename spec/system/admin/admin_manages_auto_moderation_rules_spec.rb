# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/shared_examples/config_examples"

module Decidim::DecidimAwesome
  module Admin
    describe "Auto moderation rules" do
      let(:organization) { create(:organization) }
      let!(:admin) { create(:user, :admin, :confirmed, organization:) }
      let!(:config) { create(:awesome_config, organization:, var: :auto_moderation_rules, value: rules) }
      let(:rules) { {} }

      before do
        switch_to_host(organization.host)
        login_as admin, scope: :user
        visit decidim_admin_decidim_awesome.auto_moderation_rules_path
      end

      context "when creating a new rule" do
        before do
          click_link_or_button "New"
          fill_in_i18n(
            :auto_moderation_rules_description,
            "#auto_moderation_rules-description-tabs",
            en: "Bad word rule"
          )
          check "Enabled"
        end

        it "does not save the content without rule type" do
          click_link_or_button "Save"

          expect(page).to have_content("There is an error in this field.")
        end

        context "with a rule type" do
          before do
            select "Word filter", from: "Rule type"
            fill_in "auto_moderation_rules_rule_options", with: "badword1, badword2"
          end

          it "saves the content" do
            click_link_or_button "Save"

            expect(page).to have_admin_callout("created successfully")
          end
        end
      end

      context "when editing an existing rule" do
        let(:rules) do
          {
            "rule_1" => {
              "description" => { "en" => "Bad word rule" },
              "enabled" => true,
              "rule_type" => "word_filter",
              "rule_options" => "badword1, badword2"
            }
          }
        end

        before do
          within "tr", text: "Bad word rule" do
            click_link_or_button "Edit"
          end
          fill_in_i18n(
            :auto_moderation_rules_description,
            "#auto_moderation_rules-description-tabs",
            en: "Updated bad word rule"
          )
          click_link_or_button "Save"
        end

        it "updates the content" do
          expect(page).to have_admin_callout("successfully updated")
          expect(page).to have_content("Updated bad word rule")
        end
      end

      context "when deleting a rule" do
        let(:rules) do
          {
            "rule_1" => {
              "description" => { "en" => "Bad word rule" },
              "enabled" => true,
              "rule_type" => "word_filter",
              "rule_options" => "badword1, badword2"
            }
          }
        end

        before do
          within "tr", text: "Bad word rule" do
            accept_confirm { click_link_or_button "Remove" }
          end
        end

        it "deletes the rule" do
          expect(page).to have_no_content("Bad word rule")
        end
      end
    end
  end
end
