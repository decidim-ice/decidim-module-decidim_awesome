# frozen_string_literal: true

require "spec_helper"

describe "Admin manages users autoblocks feature" do
  let(:organization) { create(:organization, available_authorizations: [:dummy_authorization_handler, :another_dummy_authorization_handler, :id_documents]) }
  let!(:admin) { create(:user, :admin, :confirmed, organization:) }
  let!(:user) { create(:user, :confirmed, organization:) }
  let!(:user_with_unconfirmed_email) { create(:user, organization:) }
  let!(:spam_user) { create(:user, :confirmed, organization:, email: "user@spam.org") }
  let!(:user_with_spam_links) { create(:user, :confirmed, organization:, email: "user@spamlinks.com", about: "Visit www.try-spam.org") }

  let!(:user_with_spam_links_in_comments) { create(:user, :confirmed, organization:, email: "user@spamcomments.org") }
  let(:body) { { en: "Visit www.spam-bot.org, you won't regret!" } }
  let(:participatory_process) { create(:participatory_process, organization:) }
  let(:component) { create(:component, participatory_space: participatory_process) }
  let(:commentable) { create(:dummy_resource, component:) }
  let!(:comment) { create(:comment, body:, commentable:, author: user_with_spam_links_in_comments) }

  let!(:user_with_blank_about) { create(:user, :confirmed, organization:, about: nil) }

  let(:last_force_authorization_after_login) { Decidim::DecidimAwesome::AwesomeConfig.find_by(var: :force_authorization_after_login) }
  let(:last_force_authorization_with_any_method) { Decidim::DecidimAwesome::AwesomeConfig.find_by(var: :force_authorization_with_any_method) }
  let(:last_force_authorization_help_text) { Decidim::DecidimAwesome::AwesomeConfig.find_by(var: :force_authorization_help_text) }

  let!(:user_autoblocks) { create(:awesome_config, organization:, var: :users_autoblocks, value: rules) }
  let(:rules) { [] }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin_decidim_awesome.users_autoblocks_path
  end

  context "when no rules exist" do
    it "hides the scores calculation form" do
      expect(page).to have_content("Users automatic blocks")
      expect(page).not_to have_content("Calculate scores")
    end
  end

  context "when rules are present" do
    let(:rules) do
      [{
        id: 1,
        type:,
        weight:,
        allowlist:,
        blocklist:,
        application_type:
      }]
    end
    let(:type) { "about_blank" }
    let(:weight) { 10 }
    let(:allowlist) { "" }
    let(:blocklist) { "" }
    let(:application_type) { "positive" }

    it "shows a form to calculate scores" do
      expect(page).to have_content("Users automatic blocks")
      expect(page).to have_field(name: "users_autoblocks_config[threshold]", visible: :visible)
      expect(page).to have_field(name: "users_autoblocks_config[block_justification_message]", visible: :hidden)
      expect(page).to have_field(name: "users_autoblocks_config[perform_block]", visible: :visible)

      expect(page).to have_button("Calculate scores")
    end

    context "when performing the scores calculation" do
      before do
        fill_in "Threshold", with: "5"
        click_button "Calculate scores"
      end

      it "displays a message with found users count" do
        expect(page).to have_content("1 user found with enough score to be blocked")
      end

      it "does not perform any users block" do
        expect(Decidim::User.blocked.count).to be_zero
      end
    end

    context "when enabling the block option" do
      before do
        fill_in "Threshold", with: "5"
        check "Perform users blocking"
      end

      it "displays a mandatory field with block justification message" do
        expect(page).to have_field(name: "users_autoblocks_config[block_justification_message]", visible: :visible)
        accept_confirm { click_button "Detect and block users" }
        within "label[for='users_autoblocks_config_block_justification_message']" do
          expect(page).to have_content("There is an error in this field.")
        end
      end
    end

    context "when performing the block" do
      before do
        fill_in "Threshold", with: "5"
        check "Perform users blocking"
        fill_in "Block justification message", with: "Your account has been blocked due to suspicious activity"
        accept_confirm { click_button "Detect and block users" }
      end

      context "with about user blank rule" do
        it "detects and blocks the user" do
          expect(Decidim::User.blocked.count).to eq(1)

          expect(user_with_blank_about.reload).to be_blocked
        end

        context "with allowlist" do
          let(:allowlist) { user_with_blank_about.email.split("@").last }

          it "does not block users with email domain affected by the allowlist" do
            expect(Decidim::User.blocked.count).to eq(0)
          end
        end
      end

      context "with user with no contents activities rule" do
        let(:type) { "activities_blank" }

        it "detects and blocks the regular users affected by the rule" do
          expect(Decidim::User.blocked.count).to eq(6)

          [user, user_with_unconfirmed_email, spam_user, user_with_spam_links, user_with_blank_about].each do |us|
            expect(us.reload).to be_blocked
          end

          [admin, user_with_spam_links_in_comments].each do |us|
            expect(us.reload).not_to be_blocked
          end
        end

        context "with allowlist" do
          let(:allowlist) { "spam.org" }

          it "does not block users with email domain affected by the allowlist" do
            expect(Decidim::User.blocked.count).to eq(5)

            expect(spam_user.reload).not_to be_blocked
          end
        end

        context "with blocklist" do
          let(:blocklist) { "spam.org" }

          it "blocks only users with email domain affected by the blocklist" do
            expect(Decidim::User.blocked.count).to eq(1)

            expect(spam_user.reload).to be_blocked
          end
        end
      end

      context "with links in comments or about rule" do
        let(:type) { "links_in_comments_or_about" }

        it "detects and blocks the users" do
          expect(Decidim::User.blocked.count).to eq(2)

          [user_with_spam_links, user_with_spam_links_in_comments].each do |us|
            expect(us.reload).to be_blocked
          end
        end

        context "with allowlist" do
          let(:allowlist) { "spamlinks.com" }

          it "does not block users with links inclunding domains affected by the allowlist" do
            expect(Decidim::User.blocked.count).to eq(1)

            expect(user_with_spam_links.reload).not_to be_blocked
          end
        end

        context "with blocklist" do
          let(:blocklist) { "spamlinks.com" }

          it "blocks only users with links incluing domains affected by the blocklist" do
            expect(Decidim::User.blocked.count).to eq(1)

            expect(user_with_spam_links.reload).to be_blocked
          end
        end
      end

      context "with links included in lists in comments or about rule" do
        let(:type) { "links_in_comments_or_about_with_domains" }

        it "detects and blocks the users" do
          expect(Decidim::User.blocked.count).to eq(2)

          [user_with_spam_links, user_with_spam_links_in_comments].each do |us|
            expect(us.reload).to be_blocked
          end
        end

        context "with allowlist" do
          let(:allowlist) { "www.try-spam.org" }

          it "does not block users with links inclunding domains affected by the allowlist" do
            expect(Decidim::User.blocked.count).to eq(1)

            expect(user_with_spam_links.reload).not_to be_blocked
          end
        end

        context "with blocklist" do
          let(:blocklist) { "www.try-spam.org" }

          it "blocks only users with links incluing domains affected by the blocklist" do
            expect(Decidim::User.blocked.count).to eq(1)

            expect(user_with_spam_links.reload).to be_blocked
          end
        end
      end

      context "with unconfirmed email rule" do
        let(:type) { "email_unconfirmed" }

        it "detects and blocks the users" do
          expect(Decidim::User.blocked.count).to eq(1)

          expect(user_with_unconfirmed_email.reload).to be_blocked
        end

        context "with allowlist" do
          let(:allowlist) { user_with_unconfirmed_email.email.split("@").last }

          it "does not block users with email domain affected by the allowlist" do
            expect(Decidim::User.blocked.count).to eq(0)
          end
        end
      end

      context "with email domain rule" do
        let(:type) { "email_domain" }

        it "skips the detection if no allowlist or blocklist is configured" do
          expect(Decidim::User.blocked.count).to eq(0)
        end

        context "with allowlist" do
          let(:allowlist) { "spam.org" }

          it "blocks all regular users except those whose email domain is on the allowlist" do
            expect(Decidim::User.blocked.count).to eq(6)

            [user, user_with_unconfirmed_email, user_with_spam_links_in_comments, user_with_spam_links, user_with_blank_about].each do |us|
              expect(us.reload).to be_blocked
            end

            [admin, spam_user].each do |us|
              expect(us.reload).not_to be_blocked
            end
          end
        end

        context "with blocklist" do
          let(:blocklist) { "spam.org" }

          it "blocks only users whose email domain is on the blocklist" do
            expect(Decidim::User.blocked.count).to eq(1)

            expect(spam_user.reload).to be_blocked
          end
        end
      end

      context "with multiple rules" do
        let(:rules) do
          [{
            id: 1,
            type: "activities_blank",
            weight: 2,
            allowlist:,
            blocklist:,
            application_type:
          }, {
            id: 1,
            type: "links_in_comments_or_about_with_domains",
            weight: 3,
            allowlist:,
            blocklist:,
            application_type:
          }]
        end

        it "blocks users with enough score suming the weight of each rule" do
          expect(Decidim::User.blocked.count).to eq(1)
          expect(user_with_spam_links_in_comments.reload).not_to be_blocked
          expect(user_with_spam_links.reload).to be_blocked
        end
      end
    end
  end
end
