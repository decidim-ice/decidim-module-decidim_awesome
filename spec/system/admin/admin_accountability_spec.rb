# frozen_string_literal: true

require "spec_helper"

describe "Admin accountability" do
  let(:user_creation_date) { 7.days.ago }
  let(:login_date) { 6.days.ago }
  let(:organization) { create(:organization) }
  let(:external_organization) { create(:organization) }
  let!(:admin) { create(:user, :admin, :confirmed, organization:, created_at: 9.days.ago) }
  let!(:external_admin) { create(:user, :admin, :confirmed, organization: external_organization) }

  let(:administrator) { create(:user, organization:, last_sign_in_at: login_date, created_at: user_creation_date) }
  let(:valuator) { create(:user, organization:, created_at: user_creation_date) }
  let(:collaborator) { create(:user, organization:, created_at: user_creation_date) }
  let(:moderator) { create(:user, organization:, created_at: user_creation_date) }
  let(:participatory_process) { create(:participatory_process, organization:) }

  let(:external_administrator) { create(:user, organization: external_organization, last_sign_in_at: login_date, created_at: user_creation_date) }
  let(:external_valuator) { create(:user, organization: external_organization, created_at: user_creation_date) }
  let(:external_collaborator) { create(:user, organization: external_organization, created_at: user_creation_date) }
  let(:external_moderator) { create(:user, organization: external_organization, created_at: user_creation_date) }
  let(:external_participatory_process) { create(:participatory_process, organization: external_organization) }

  let(:status) { true }

  before do
    # rubocop:disable Rails/SkipsModelValidations:
    Decidim::DecidimAwesome::PaperTrailVersion.find_by(item: admin)&.update_column(:created_at, admin.created_at)
    # rubocop:enable Rails/SkipsModelValidations:
    allow(Decidim::DecidimAwesome.config).to receive(:admin_accountability).and_return(status)
    switch_to_host(organization.host)
    login_as admin, scope: :user

    visit decidim_admin.root_path
  end

  context "when admin accountability is enabled" do
    it "shows the admin accountability link" do
      click_link_or_button "Participants"

      expect(page).to have_content("Admin accountability")
    end
  end

  context "when admin accountability is disabled" do
    let(:status) { :disabled }

    it "does not show the admin accountability link" do
      click_link_or_button "Participants"

      expect(page).to have_no_content("Admin accountability")
    end
  end

  context "when there are admin role actions" do
    before do
      create(:participatory_process_user_role, user: administrator, participatory_process:, role: "admin", created_at: 4.days.ago)
      create(:participatory_process_user_role, user: valuator, participatory_process:, role: "valuator", created_at: 3.days.ago)
      create(:participatory_process_user_role, user: collaborator, participatory_process:, role: "collaborator", created_at: 2.days.ago)
      create(:participatory_process_user_role, user: moderator, participatory_process:, role: "moderator", created_at: 1.day.ago)

      Decidim::ParticipatoryProcessUserRole.find_by(user: collaborator).destroy

      click_link_or_button "Participants"
    end

    it "shows the correct information for each user", :versioning do
      click_link_or_button "Admin accountability"

      expect(page).to have_no_content("NOTE: This list might not include users created/removed before")

      expect(page).to have_link("Processes > #{participatory_process.title["en"]}",
                                href: "/admin/participatory_processes/#{participatory_process.slug}/user_roles", count: 4)

      within all("table tr")[1] do
        expect(page).to have_content("Moderator")
        expect(page).to have_content(moderator.name)
        expect(page).to have_content(moderator.email)
        expect(page).to have_content(1.day.ago.strftime("%d/%m/%Y %H:%M"))
        expect(page).to have_content("Currently active")
        expect(page).to have_no_content(login_date.strftime("%d/%m/%Y %H:%M"))
        expect(page).to have_content("Never logged yet")
        expect(page).to have_no_content(Time.current.strftime("%d/%m/%Y %H:%M"))
      end

      within all("table tr")[2] do
        expect(page).to have_content("Collaborator")
        expect(page).to have_content(collaborator.name)
        expect(page).to have_content(collaborator.email)
        expect(page).to have_content(2.days.ago.strftime("%d/%m/%Y %H:%M"))
        expect(page).to have_no_content(login_date.strftime("%d/%m/%Y %H:%M"))
        expect(page).to have_content("Never logged yet")
        expect(page).to have_content(Time.current.strftime("%d/%m/%Y %H:%M"))
        expect(page).to have_no_content("Currently active")
      end

      within all("table tr")[3] do
        expect(page).to have_content("Valuator")
        expect(page).to have_content(valuator.name)
        expect(page).to have_content(valuator.email)
        expect(page).to have_content(3.days.ago.strftime("%d/%m/%Y %H:%M"))
        expect(page).to have_content("Currently active")
        expect(page).to have_no_content(login_date.strftime("%d/%m/%Y %H:%M"))
        expect(page).to have_content("Never logged yet")
        expect(page).to have_no_content(Time.current.strftime("%d/%m/%Y %H:%M"))
      end

      within all("table tr")[4] do
        expect(page).to have_content("Administrator")
        expect(page).to have_content(administrator.name)
        expect(page).to have_content(administrator.email)
        expect(page).to have_content(4.days.ago.strftime("%d/%m/%Y %H:%M"))
        expect(page).to have_content("Currently active")
        expect(page).to have_content(login_date.strftime("%d/%m/%Y %H:%M"))
        expect(page).to have_no_content("Never logged yet")
        expect(page).to have_no_content(Time.current.strftime("%d/%m/%Y %H:%M"))
      end
    end

    context "when external organization data is present" do
      before do
        create(:participatory_process_user_role, user: external_administrator, participatory_process: external_participatory_process, role: "admin", created_at: 4.days.ago)
        create(:participatory_process_user_role, user: external_valuator, participatory_process: external_participatory_process, role: "valuator", created_at: 3.days.ago)
        create(:participatory_process_user_role, user: external_collaborator, participatory_process: external_participatory_process, role: "collaborator", created_at: 2.days.ago)
        create(:participatory_process_user_role, user: external_moderator, participatory_process: external_participatory_process, role: "moderator", created_at: 1.day.ago)
      end

      it "does not include the other organization", :versioning do
        click_link_or_button "Admin accountability"

        expect(page).to have_link("Processes > #{participatory_process.title["en"]}",
                                  href: "/admin/participatory_processes/#{participatory_process.slug}/user_roles", count: 4)
        expect(page).to have_no_link("Processes > #{external_participatory_process.title["en"]}",
                                     href: "/admin/participatory_processes/#{external_participatory_process.slug}/user_roles")

        expect(page).to have_content(administrator.email)
        expect(page).to have_content(moderator.email)
        expect(page).to have_content(collaborator.email)
        expect(page).to have_content(valuator.email)
        expect(page).to have_no_content(external_administrator.email)
        expect(page).to have_no_content(external_moderator.email)
        expect(page).to have_no_content(external_collaborator.email)
        expect(page).to have_no_content(external_valuator.email)
      end

      context "when visiting the external organization" do
        before do
          switch_to_host(external_organization.host)
          login_as external_admin, scope: :user
          visit decidim_admin.root_path

          Decidim::ParticipatoryProcessUserRole.find_by(user: external_collaborator).destroy

          click_link_or_button "Participants"
          click_link_or_button "Admin accountability"
        end

        it "shows data only for external_organization", :versioning do
          expect(page).to have_no_link("Processes > #{participatory_process.title["en"]}",
                                       href: "/admin/participatory_processes/#{participatory_process.slug}/user_roles")
          expect(page).to have_link("Processes > #{external_participatory_process.title["en"]}",
                                    href: "/admin/participatory_processes/#{external_participatory_process.slug}/user_roles")
          expect(page).to have_no_content(administrator.name)
          expect(page).to have_no_content(valuator.name)
          expect(page).to have_no_content(collaborator.name)
          expect(page).to have_no_content(moderator.name)
          expect(page).to have_content(external_administrator.name)
          expect(page).to have_content(external_valuator.name)
          expect(page).to have_content(external_collaborator.name)
          expect(page).to have_content(external_moderator.name)
        end
      end
    end
  end

  context "when there are multiple assignations for the same user" do
    before do
      create(:participatory_process_user_role, user: collaborator, participatory_process:, role: "collaborator", created_at: 3.days.ago)

      Decidim::ParticipatoryProcessUserRole.find_by(user: collaborator).destroy

      create(:participatory_process_user_role, user: collaborator, participatory_process:, role: "valuator", created_at: 2.days.ago)

      Decidim::ParticipatoryProcessUserRole.find_by(user: collaborator).destroy

      create(:participatory_process_user_role, user: collaborator, participatory_process:, role: "collaborator", created_at: 1.day.ago)

      click_link_or_button "Participants"
      click_link_or_button "Admin accountability"
    end

    it "shows currently active", :versioning do
      within all("table tr")[1] do
        expect(page).to have_content("Collaborator")
        expect(page).to have_content(collaborator.name)
        expect(page).to have_content(collaborator.email)
        expect(page).to have_content(1.day.ago.strftime("%d/%m/%Y %H:%M"))
        expect(page).to have_no_content(Time.current.strftime("%d/%m/%Y %H:%M"))
        expect(page).to have_content("Currently active")
      end

      within all("table tr")[2] do
        expect(page).to have_content("Valuator")
        expect(page).to have_content(collaborator.name)
        expect(page).to have_content(collaborator.email)
        expect(page).to have_content(2.days.ago.strftime("%d/%m/%Y %H:%M"))
        expect(page).to have_content(Time.current.strftime("%d/%m/%Y %H:%M"))
        expect(page).to have_no_content("Currently active")
      end

      within all("table tr")[3] do
        expect(page).to have_content("Collaborator")
        expect(page).to have_content(collaborator.name)
        expect(page).to have_content(collaborator.email)
        expect(page).to have_content(3.days.ago.strftime("%d/%m/%Y %H:%M"))
        expect(page).to have_content(Time.current.strftime("%d/%m/%Y %H:%M"))
        expect(page).to have_no_content("Currently active")
      end
    end
  end

  context "when user listed has been removed" do
    let(:valuator) { create(:user, :deleted, organization:, created_at: user_creation_date) }

    before do
      create(:participatory_process_user_role, user: collaborator, participatory_process:, role: "collaborator", created_at: 3.days.ago)
      collaborator.destroy
      create(:participatory_process_user_role, user: valuator, participatory_process:, role: "valuator", created_at: 2.days.ago)

      click_link_or_button "Participants"
      click_link_or_button "Admin accountability"
    end

    it "shows the user as removed", :versioning do
      within all("table tr")[1] do
        expect(page).to have_content("Valuator")
        expect(page).to have_content("Deleted user")
        expect(page).to have_content(2.days.ago.strftime("%d/%m/%Y %H:%M"))
        expect(page).to have_no_content(Time.current.strftime("%d/%m/%Y %H:%M"))
        expect(page).to have_content("Currently active")
      end

      within all("table tr")[2] do
        expect(page).to have_content("Collaborator")
        expect(page).to have_content("User not in the database")
        expect(page).to have_content(3.days.ago.strftime("%d/%m/%Y %H:%M"))
        expect(page).to have_no_content(Time.current.strftime("%d/%m/%Y %H:%M"))
        expect(page).to have_content("Currently active")
      end
    end
  end

  context "when global admins" do
    let!(:second_admin) { create(:user, :admin, organization:, created_at: 3.days.ago) }

    before do
      click_link_or_button "Participants"
      click_link_or_button "Admin accountability"
    end

    it "shows the current admins", :versioning do
      click_link_or_button "List global admins"

      expect(page).to have_no_content("NOTE: This list might not include users created/removed before")

      expect(page).to have_no_content(external_admin.name)
      expect(page).to have_no_content(external_admin.email)

      within all("table tr")[1] do
        expect(page).to have_content("Super admin")
        expect(page).to have_content(second_admin.name)
        expect(page).to have_content(second_admin.email)
        expect(page).to have_content("Never logged yet")
        expect(page).to have_content(second_admin.created_at.strftime("%d/%m/%Y %H:%M"))
        expect(page).to have_content("Currently active")
      end

      within all("table tr")[2] do
        expect(page).to have_content("Super admin")
        expect(page).to have_content(admin.name)
        expect(page).to have_content(admin.email)
        expect(page).to have_no_content("Never logged yet")
        expect(page).to have_content(admin.created_at.strftime("%d/%m/%Y %H:%M"))
        expect(page).to have_content("Currently active")
      end
    end

    context "when first versioning is newer than the user creation date" do
      let(:missing_date) { 8.days.ago }

      before do
        # rubocop:disable Rails/SkipsModelValidations:
        Decidim::DecidimAwesome::PaperTrailVersion.where(item_type: "Decidim::UserBaseEntity").last.update_column(:created_at, missing_date)
        # rubocop:enable Rails/SkipsModelValidations:
      end

      it "shows a warning message", :versioning do
        click_link_or_button "List global admins"
        expect(page).to have_content("NOTE: This list might not include users created/removed before #{missing_date.strftime("%d/%m/%Y %H:%M")}")
      end
    end
  end
end
