# frozen_string_literal: true

require "spec_helper"

describe "Managing the participants" do
  let(:organization) { create(:organization, available_authorizations:) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let!(:participant1) { create(:user, :confirmed, organization:) }
  let!(:participant2) { create(:user, :confirmed, organization:) }
  let(:available_authorizations) { [handler] }
  let(:handler) { "dummy_authorization_handler" }
  let(:awesome_handler) { "another_dummy_authorization_handler" }
  let!(:authorization) { create(:authorization, user: participant1, name: handler, organization:) }
  let!(:ghost_authorization) { create(:authorization, user: participant2, name: :another_dummy_authorization_handler, organization:) }
  let!(:awesome_config) { create(:awesome_config, var: :admins_available_authorizations, value: [awesome_handler], organization:) }
  let(:last_authorization) { Decidim::Authorization.last }
  let(:last_action_log) { Decidim::ActionLog.last }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin.officializations_path
  end

  it "shows the extra authorization column" do
    within "thead" do
      expect(page).to have_content("Authorizations")
    end
    within "tbody" do
      within "tr", text: participant1.name do
        within "div[data-verification-user-id=\"#{participant1.id}\"]" do
          expect(page).to have_content("Example authorization")
          expect(page).to have_css("svg.checked")
          expect(page).to have_no_content("Another example authorization")
        end
      end
      within "tr", text: participant2.name do
        within "div[data-verification-user-id=\"#{participant2.id}\"]" do
          expect(page).to have_content("Example authorization")
          expect(page).to have_css("svg.unchecked")
          expect(page).to have_no_content("Another example authorization")
        end
      end
    end
  end

  context "when authorization is managed" do
    let(:awesome_handler) { "dummy_authorization_handler" }

    it "can authorize a participant" do
      within "tr", text: participant2.name do
        within "a[data-verification-user-id=\"#{participant2.id}\"]" do
          expect(page).to have_css("svg.unchecked")
        end
        click_on "Example authorization"
      end

      within "#awesome-verification-modal-content" do
        fill_in "Document number", with: "12345678"
        click_button "Authorize #{participant2.name} with Example authorization"
        expect(page).to have_content("#{participant2.name} could not be authorized with Example authorization")
        fill_in "Document number", with: "12345678X"
        click_button "Authorize #{participant2.name} with Example authorization"
        expect(page).to have_content("#{participant2.name} successfully authorized with Example authorization")
        click_on "Close"
      end

      within "tr", text: participant2.name do
        within "a[data-verification-user-id=\"#{participant2.id}\"]" do
          expect(page).to have_content("Example authorization")
          expect(page).to have_css("svg.checked")
        end
      end

      expect(last_authorization.name).to eq("dummy_authorization_handler")
      expect(last_authorization.unique_id).to eq("12345678X")
      expect(last_action_log.action).to eq("admin_creates_authorization")
    end

    it "can revoke an authorization" do
      within "tr", text: participant1.name do
        within "a[data-verification-user-id=\"#{participant1.id}\"]" do
          expect(page).to have_content("Example authorization")
          expect(page).to have_css("svg.checked")
        end
        click_on "Example authorization"
      end

      within "#awesome-verification-modal-content" do
        accept_confirm { click_on "Destroy" }
        expect(page).to have_content("Authorization successfully destroyed")
      end

      within "tr", text: participant1.name do
        within "a[data-verification-user-id=\"#{participant1.id}\"]" do
          expect(page).to have_content("Example authorization")
          expect(page).to have_css("svg.unchecked")
        end
      end
      expect(last_action_log.action).to eq("admin_destroys_authorization")
    end

    it "can force an authorization" do
      within "tr", text: participant2.name do
        within "a[data-verification-user-id=\"#{participant2.id}\"]" do
          expect(page).to have_css("svg.unchecked")
        end
        click_on "Example authorization"
      end

      within "#awesome-verification-modal-content" do
        fill_in "Document number", with: "12345678"
        click_button "Authorize #{participant2.name} with Example authorization"
        check "Force verification with the current data"
        fill_in "Give a reason to force the verification:", with: "Because I can"
        click_button "Authorize #{participant2.name} with Example authorization"
        expect(page).to have_content("#{participant2.name} successfully authorized with Example authorization")
        click_on "Close"
      end

      within "tr", text: participant2.name do
        within "a[data-verification-user-id=\"#{participant2.id}\"]" do
          expect(page).to have_content("Example authorization")
          expect(page).to have_css("svg.checked")
        end
      end

      expect(last_authorization.name).to eq("dummy_authorization_handler")
      expect(last_authorization.unique_id).to eq("12345678")
      expect(last_action_log.action).to eq("admin_forces_authorization")
      expect(last_action_log.extra["reason"]).to eq("Because I can")
    end

    context "when there's a conflict of data" do
      let!(:authorization) { create(:authorization, user: participant1, name: handler, unique_id: "12345678", organization:) }

      it "cannot force an authorization" do
        within "tr", text: participant2.name do
          within "a[data-verification-user-id=\"#{participant2.id}\"]" do
            expect(page).to have_css("svg.unchecked")
          end
          click_on "Example authorization"
        end

        within "#awesome-verification-modal-content" do
          fill_in "Document number", with: "12345678"
          click_button "Authorize #{participant2.name} with Example authorization"
          expect(page).to have_content("There is a conflict with an existing authorization")
          expect(page).to have_no_content("Authorize")
          click_on "Close"
        end

        within "tr", text: participant2.name do
          within "a[data-verification-user-id=\"#{participant2.id}\"]" do
            expect(page).to have_content("Example authorization")
            expect(page).to have_css("svg.unchecked")
          end
        end
        expect(last_action_log).to be_nil
      end
    end
  end
end
