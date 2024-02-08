# frozen_string_literal: true

require "spec_helper"

describe "Filter Admin actions" do
  let(:login_date) { 3.days.ago }
  let(:organization) { create(:organization) }
  let!(:user) { create(:user, :confirmed, organization:) }
  let!(:admin) { create(:user, :admin, :confirmed, organization:) }
  let!(:admin2) { create(:user, :admin, :confirmed, name: "Lorry 1", email: "test@test.com", organization:, created_at: 6.days.ago) }
  let!(:manager) { create(:user, :user_manager, :confirmed, organization:, created_at: 5.days.ago, last_sign_in_at: login_date) }
  let!(:manager2) { create(:user, :user_manager, :confirmed, name: "Lorry 2", email: "test2@test.com", organization:, created_at: 4.days.ago) }

  let(:resource_controller) { Decidim::DecidimAwesome::Admin::AdminAccountabilityController }

  include_context "with filterable context"

  before do
    # ensure papertrail has the same created_at date as the object being mocked
    Decidim::DecidimAwesome::PaperTrailVersion.admin_role_actions.map { |v| v.update(created_at: v.item.created_at) }

    switch_to_host(organization.host)
    login_as admin, scope: :user

    visit decidim_admin_decidim_awesome.admin_accountability_path

    click_link "List global admins"
  end

  def apply_admin_filter(options, filter)
    within(".filters__section") do
      find_link("Filter").hover
      find_link(options).hover
      click_link(filter)
    end
  end

  with_versioning do
    it "shows filters" do
      expect(page).to have_content("Filter")
      expect(page).to have_css("#q_user_name_or_user_email_cont")
      expect(page).to have_css("#q_created_at_gteq")
      expect(page).to have_css("#q_created_at_lteq")
    end

    it "displays the filter labels" do
      find("a.dropdown").hover
      expect(page).not_to have_content("Participatory space type")
      expect(page).to have_content("Role type")

      find("a", text: "Role type").hover

      within ".filters__section" do
        expect(page).to have_content("Super admin")
        expect(page).to have_content("User manager")
      end
    end

    it "displays all the admins" do
      expect(page).to have_content("Super admin", count: 2)
      expect(page).to have_content("User manager", count: 2)
      expect(page).to have_content(admin.name, count: 1)
      expect(page).to have_content(admin2.name, count: 1)
      expect(page).to have_content(manager.name, count: 1)
      expect(page).to have_content(manager2.name, count: 1)
      expect(page).not_to have_content(user.name, count: 1)

      expect(page).to have_content(login_date.strftime("%d/%m/%Y %H:%M"))
      expect(page).to have_content("Currently active", count: 4)
    end

    context "when filtering admin_actions by ROLE TYPE" do
      it "Admin role type" do
        apply_admin_filter("Role type", "Super admin")

        within "tbody" do
          expect(page).to have_content("Super admin", count: 2)
        end
      end

      it "User manager role type" do
        apply_admin_filter("Role type", "User manager")

        within "tbody" do
          expect(page).to have_content("User manager", count: 2)
        end
      end
    end

    context "when searching by name or email" do
      it "searches by name" do
        search_by_text("Lorry")

        within "tbody" do
          expect(page).to have_content("Lorry", count: 2)
        end
      end

      it "searches by email" do
        search_by_text("@test.com")

        within "tbody" do
          expect(page).to have_content("@test.com", count: 2)
        end
      end
    end

    context "when searching by date" do
      def search_by_date(start_date, end_date)
        within(".filters__section") do
          fill_in(:q_created_at_gteq, with: start_date) if start_date.present?
          fill_in(:q_created_at_lteq, with: end_date) if end_date.present?

          find("*[type=submit]").click
        end
      end

      context "when the start date is earlier" do
        it "displays all entries" do
          search_by_date(7.days.ago, "")

          within "tbody" do
            expect(page).to have_css("tr", count: 4)
          end
        end
      end

      context "when the start date is later" do
        it "displays no entries" do
          search_by_date(1.day.from_now, "")

          within "tbody" do
            expect(page).to have_css("tr", count: 0)
          end
        end
      end

      context "when the end date is later" do
        it "displays all entries" do
          search_by_date("", 5.days.from_now)

          within "tbody" do
            expect(page).to have_css("tr", count: 4)
          end
        end
      end

      context "when the end date is earlier" do
        it "displays no entries" do
          search_by_date("", 7.days.ago)

          within "tbody" do
            expect(page).to have_css("tr", count: 0)
          end
        end
      end

      context "when searching in range" do
        it "displays entries in range" do
          search_by_date(6.days.ago, 5.days.ago)

          within "tbody" do
            expect(page).to have_css("tr", count: 2)
            expect(page).to have_content("Super admin", count: 1)
            expect(page).to have_content("User manager", count: 1)
            expect(page).to have_content(admin2.name, count: 1)
            expect(page).to have_content(manager.name, count: 1)
          end
        end

        it "exports the result" do
          search_by_date(6.days.ago, 5.days.ago)

          find(".exports.dropdown").click
          perform_enqueued_jobs { click_link "Export as CSV" }

          within ".flash.success" do
            expect(page).to have_content("Export job has been enqueued. You will receive an email when it's ready.")
          end

          expect(last_email.subject).to include("Your export", "csv", "is ready")
          expect(last_email.attachments.length).to be_positive
          expect(last_email.attachments.first.filename).to match(/^admin_actions.*\.zip$/)
          expect(current_url).to include(decidim_admin_decidim_awesome.admin_accountability_path)
          expect(current_url).to include("admins=true")
        end
      end
    end
  end
end
