# frozen_string_literal: true

require "spec_helper"

describe "Filter Admin actions" do
  let(:user_creation_date) { 7.days.ago }
  let(:login_date) { 6.days.ago }
  let!(:organization) { create(:organization) }
  let!(:admin) { create(:user, :admin, :confirmed, organization:) }
  let(:administrator) { create(:user, organization:, last_sign_in_at: login_date, created_at: user_creation_date) }
  let(:valuator) { create(:user, name: "Lorry", email: "test@example.org", organization:, created_at: user_creation_date) }
  let(:collaborator) { create(:user, organization:, created_at: user_creation_date) }
  let(:moderator) { create(:user, organization:, created_at: user_creation_date) }

  let(:resource_controller) { Decidim::DecidimAwesome::Admin::AdminAccountabilityController }

  let!(:participatory_process_user_role1) { create(:participatory_process_user_role, user: administrator, role: "admin", created_at: 4.days.ago) }
  let!(:participatory_process_user_role2) { create(:participatory_process_user_role, user: valuator, role: "valuator", created_at: 3.days.ago) }
  let!(:participatory_process_user_role3) { create(:participatory_process_user_role, user: collaborator, role: "collaborator", created_at: 2.days.ago) }
  let!(:participatory_process_user_role4) { create(:participatory_process_user_role, user: moderator, role: "moderator", created_at: 1.day.ago) }
  let!(:assembly_user_role1) { create(:assembly_user_role, user: administrator, role: "admin", created_at: 4.days.ago) }
  let!(:assembly_user_role2) { create(:assembly_user_role, user: valuator, role: "valuator", created_at: 3.days.ago) }
  let!(:assembly_user_role3) { create(:assembly_user_role, user: collaborator, role: "collaborator", created_at: 2.days.ago) }
  let!(:assembly_user_role4) { create(:assembly_user_role, user: moderator, role: "moderator", created_at: 1.day.ago) }

  include_context "with filterable context"

  before do
    # ensure papertrail has the same created_at date as the object being mocked
    Decidim::DecidimAwesome::PaperTrailVersion.space_role_actions(organization).map { |v| v.update(created_at: v.item.created_at) }

    switch_to_host(organization.host)
    login_as admin, scope: :user

    visit decidim_admin.root_path

    click_link_or_button "Participants"
    click_link_or_button "Admin accountability"
  end

  with_versioning do
    it "shows filters" do
      expect(page).to have_content("Filter")
      expect(page).to have_css("#q_user_name_or_user_email_cont")
      expect(page).to have_css("#q_created_at_gteq_date")
      expect(page).to have_css("#q_created_at_lteq_date")
    end

    it "displays the filter labels" do
      find("a.dropdown").hover
      expect(page).to have_content("Participatory space type")
      expect(page).to have_content("Role type")

      find("a", text: "Participatory space type").hover
      expect(page).to have_content("Participatory processes")
      expect(page).to have_content("Assemblies")

      find("a", text: "Role type").hover
      expect(page).to have_content("Admin")
      expect(page).to have_content("Collaborator")
      expect(page).to have_content("Moderator")
      expect(page).to have_content("Valuator")
    end

    context "when filtering admin_actions by PARTICIPATORY SPACE" do
      it "Assemblies space type" do
        apply_filter("Participatory space type", "Assemblies")

        within "tbody" do
          expect(page).to have_content("Assemblies >", count: 4)
        end
      end

      it "Processes space type" do
        apply_filter("Participatory space type", "Participatory processes")

        within "tbody" do
          expect(page).to have_content("Processes >", count: 4)
        end
      end

      it "exports the result" do
        apply_filter("Participatory space type", "Participatory processes")

        find(".exports.button.tiny").click
        perform_enqueued_jobs { click_link_or_button "Export as CSV" }

        within ".flash.success" do
          expect(page).to have_content("Export job has been enqueued. You will receive an email when it's ready.")
        end

        expect(last_email.subject).to include("Your export", "csv", "is ready")
        expect(last_email.attachments.length).to be_positive
        expect(last_email.attachments.first.filename).to match(/^admin_actions.*\.zip$/)
        expect(current_url).to include(decidim_admin_decidim_awesome.admin_accountability_path)
        expect(current_url).not_to include("admins=true")
      end
    end

    context "when filtering admin_actions by ROLE TYPE" do
      it "Admin role type" do
        apply_filter("Role type", "Admin")

        within "tbody" do
          expect(page).to have_content("Administrator", count: 2)
        end
      end

      it "Collaborator role type" do
        apply_filter("Role type", "Collaborator")

        within "tbody" do
          expect(page).to have_content("Collaborator", count: 2)
        end
      end

      it "Moderator role type" do
        apply_filter("Role type", "Moderator")

        within "tbody" do
          expect(page).to have_content("Moderator", count: 2)
        end
      end

      it "Valuator role type" do
        apply_filter("Role type", "Valuator")

        within "tbody" do
          expect(page).to have_content("Valuator", count: 2)
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
        search_by_text("test@example.org")

        within "tbody" do
          expect(page).to have_content("test@example.org", count: 2)
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
          search_by_date(6.days.ago, "")

          within "tbody" do
            expect(page).to have_css("tr", count: 8)
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
            expect(page).to have_css("tr", count: 8)
          end
        end
      end

      context "when the end date is earlier" do
        it "displays no entries" do
          search_by_date("", 6.days.ago)

          within "tbody" do
            expect(page).to have_css("tr", count: 0)
          end
        end
      end

      context "when searching in range" do
        it "displays entries in range" do
          search_by_date(3.days.ago, 2.days.ago)

          within "tbody" do
            expect(page).to have_css("tr", count: 4)
            expect(page).to have_content("Collaborator", count: 2)
            expect(page).to have_content("Valuator", count: 2)
            expect(page).to have_content(collaborator.name, count: 2)
            expect(page).to have_content(valuator.name, count: 2)
            expect(page).to have_content(participatory_process_user_role2.participatory_space.title["en"])
            expect(page).to have_content(participatory_process_user_role3.participatory_space.title["en"])
            expect(page).to have_content(assembly_user_role2.participatory_space.title["en"])
            expect(page).to have_content(assembly_user_role3.participatory_space.title["en"])
          end
        end
      end
    end
  end
end
