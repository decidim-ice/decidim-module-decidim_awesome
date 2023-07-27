# frozen_string_literal: true

require "spec_helper"

describe "Admin accountability", type: :system do
  let(:user_creation_date) { 7.days.ago }
  let(:login_date) { 6.days.ago }
  let(:organization) { create :organization }
  let(:organization2) { create :organization }
  let!(:admin) { create :user, :admin, :confirmed, organization: organization }
  let!(:admin2) { create :user, :admin, :confirmed, organization: organization2 }

  let(:administrator) { create(:user, organization: organization, last_sign_in_at: login_date, created_at: user_creation_date) }
  let(:valuator) { create(:user, organization: organization, created_at: user_creation_date) }
  let(:collaborator) { create(:user, organization: organization, created_at: user_creation_date) }
  let(:moderator) { create(:user, organization: organization, created_at: user_creation_date) }
  let(:participatory_process) { create(:participatory_process, organization: organization) }

  let(:administrator2) { create(:user, organization: organization2, last_sign_in_at: login_date, created_at: user_creation_date) }
  let(:valuator2) { create(:user, organization: organization2, created_at: user_creation_date) }
  let(:collaborator2) { create(:user, organization: organization2, created_at: user_creation_date) }
  let(:moderator2) { create(:user, organization: organization2, created_at: user_creation_date) }
  let(:participatory_process2) { create(:participatory_process, organization: organization2) }

  let(:status) { true }

  before do
    allow(Decidim::DecidimAwesome.config).to receive(:admin_accountability).and_return(status)
    switch_to_host(organization.host)
    login_as admin, scope: :user

    visit decidim_admin.root_path
  end

  context "when admin accountability is enabled" do
    it "shows the admin accountability link" do
      click_link "Participants"

      expect(page).to have_content("Admin accountability")
    end
  end

  context "when admin accountability is disabled" do
    let(:status) { :disabled }

    it "does not show the admin accountability link" do
      click_link "Participants"

      expect(page).not_to have_content("Admin accountability")
    end
  end

  describe "admin action list" do
    context "when there are admin actions" do
      before do
        create(:participatory_process_user_role, user: administrator, participatory_process: participatory_process, role: "admin", created_at: 4.days.ago)
        create(:participatory_process_user_role, user: valuator, participatory_process: participatory_process, role: "valuator", created_at: 3.days.ago)
        create(:participatory_process_user_role, user: collaborator, participatory_process: participatory_process, role: "collaborator", created_at: 2.days.ago)
        create(:participatory_process_user_role, user: moderator, participatory_process: participatory_process, role: "moderator", created_at: 1.day.ago)

        Decidim::ParticipatoryProcessUserRole.find_by(user: collaborator).destroy

        click_link "Participants"
        click_link "Admin accountability"
      end

      it "shows the correct information for each user", versioning: true do
        expect(page).to have_link("Processes > #{participatory_process.title["en"]}",
                                  href: "/admin/participatory_processes/#{participatory_process.slug}/user_roles", count: 4)

        within all("table tr")[1] do
          expect(page).to have_content("Moderator")
          expect(page).to have_content(moderator.name)
          expect(page).to have_content(moderator.email)
          expect(page).to have_content(1.day.ago.strftime("%d/%m/%Y %H:%M"))
          expect(page).to have_content("Currently active")
          expect(page).not_to have_content(login_date.strftime("%d/%m/%Y %H:%M"))
          expect(page).to have_content("Never logged yet")
          expect(page).not_to have_content(Time.current.strftime("%d/%m/%Y %H:%M"))
        end

        within all("table tr")[2] do
          expect(page).to have_content("Collaborator")
          expect(page).to have_content(collaborator.name)
          expect(page).to have_content(collaborator.email)
          expect(page).to have_content(2.days.ago.strftime("%d/%m/%Y %H:%M"))
          expect(page).not_to have_content(login_date.strftime("%d/%m/%Y %H:%M"))
          expect(page).to have_content("Never logged yet")
          expect(page).to have_content(Time.current.strftime("%d/%m/%Y %H:%M"))
          expect(page).not_to have_content("Currently active")
        end

        within all("table tr")[3] do
          expect(page).to have_content("Valuator")
          expect(page).to have_content(valuator.name)
          expect(page).to have_content(valuator.email)
          expect(page).to have_content(3.days.ago.strftime("%d/%m/%Y %H:%M"))
          expect(page).to have_content("Currently active")
          expect(page).not_to have_content(login_date.strftime("%d/%m/%Y %H:%M"))
          expect(page).to have_content("Never logged yet")
          expect(page).not_to have_content(Time.current.strftime("%d/%m/%Y %H:%M"))
        end

        within all("table tr")[4] do
          expect(page).to have_content("Administrator")
          expect(page).to have_content(administrator.name)
          expect(page).to have_content(administrator.email)
          expect(page).to have_content(4.days.ago.strftime("%d/%m/%Y %H:%M"))
          expect(page).to have_content("Currently active")
          expect(page).to have_content(login_date.strftime("%d/%m/%Y %H:%M"))
          expect(page).not_to have_content("Never logged yet")
          expect(page).not_to have_content(Time.current.strftime("%d/%m/%Y %H:%M"))
        end
      end
    end

    context "when there are multiple assignations for the same user" do
      before do
        create(:participatory_process_user_role, user: collaborator, participatory_process: participatory_process, role: "collaborator", created_at: 3.days.ago)

        Decidim::ParticipatoryProcessUserRole.find_by(user: collaborator).destroy

        create(:participatory_process_user_role, user: collaborator, participatory_process: participatory_process, role: "valuator", created_at: 2.days.ago)

        Decidim::ParticipatoryProcessUserRole.find_by(user: collaborator).destroy

        create(:participatory_process_user_role, user: collaborator, participatory_process: participatory_process, role: "collaborator", created_at: 1.day.ago)

        click_link "Participants"
        click_link "Admin accountability"
      end

      it "shows currently active", versioning: true do
        within all("table tr")[1] do
          expect(page).to have_content("Collaborator")
          expect(page).to have_content(collaborator.name)
          expect(page).to have_content(collaborator.email)
          expect(page).to have_content(1.day.ago.strftime("%d/%m/%Y %H:%M"))
          expect(page).not_to have_content(Time.current.strftime("%d/%m/%Y %H:%M"))
          expect(page).to have_content("Currently active")
        end

        within all("table tr")[2] do
          expect(page).to have_content("Valuator")
          expect(page).to have_content(collaborator.name)
          expect(page).to have_content(collaborator.email)
          expect(page).to have_content(2.days.ago.strftime("%d/%m/%Y %H:%M"))
          expect(page).to have_content(Time.current.strftime("%d/%m/%Y %H:%M"))
          expect(page).not_to have_content("Currently active")
        end

        within all("table tr")[3] do
          expect(page).to have_content("Collaborator")
          expect(page).to have_content(collaborator.name)
          expect(page).to have_content(collaborator.email)
          expect(page).to have_content(3.days.ago.strftime("%d/%m/%Y %H:%M"))
          expect(page).to have_content(Time.current.strftime("%d/%m/%Y %H:%M"))
          expect(page).not_to have_content("Currently active")
        end
      end
    end

    context "when user listed has been removed" do
      let(:valuator) { create(:user, :deleted, organization: organization, created_at: user_creation_date) }

      before do
        create(:participatory_process_user_role, user: collaborator, participatory_process: participatory_process, role: "collaborator", created_at: 3.days.ago)
        collaborator.destroy
        create(:participatory_process_user_role, user: valuator, participatory_process: participatory_process, role: "valuator", created_at: 2.days.ago)

        click_link "Participants"
        click_link "Admin accountability"
      end

      it "shows the user as removed", versioning: true do
        within all("table tr")[1] do
          expect(page).to have_content("Valuator")
          expect(page).to have_content("Deleted user")
          expect(page).to have_content(2.days.ago.strftime("%d/%m/%Y %H:%M"))
          expect(page).not_to have_content(Time.current.strftime("%d/%m/%Y %H:%M"))
          expect(page).to have_content("Currently active")
        end

        within all("table tr")[2] do
          expect(page).to have_content("Collaborator")
          expect(page).to have_content("User not in the database")
          expect(page).to have_content(3.days.ago.strftime("%d/%m/%Y %H:%M"))
          expect(page).not_to have_content(Time.current.strftime("%d/%m/%Y %H:%M"))
          expect(page).to have_content("Currently active")
        end
      end
    end
  end

  context "when another organization" do
    before do
      switch_to_host(organization2.host)
      login_as admin2, scope: :user
      visit decidim_admin.root_path

      create(:participatory_process_user_role, user: administrator2, participatory_process: participatory_process2, role: "admin", created_at: 4.days.ago)
      create(:participatory_process_user_role, user: valuator2, participatory_process: participatory_process2, role: "valuator", created_at: 3.days.ago)
      create(:participatory_process_user_role, user: collaborator2, participatory_process: participatory_process2, role: "collaborator", created_at: 2.days.ago)
      create(:participatory_process_user_role, user: moderator2, participatory_process: participatory_process2, role: "moderator", created_at: 1.day.ago)

      Decidim::ParticipatoryProcessUserRole.find_by(user: collaborator2).destroy

      click_link "Participants"
      click_link "Admin accountability"
    end

    it "shows data only for organization2", versioning: true do
      expect(page).not_to have_link("Processes > #{participatory_process.title["en"]}",
                                    href: "/admin/participatory_processes/#{participatory_process.slug}/user_roles")
      expect(page).to have_link("Processes > #{participatory_process2.title["en"]}",
                                href: "/admin/participatory_processes/#{participatory_process2.slug}/user_roles")
      expect(page).not_to have_content(administrator.name)
      expect(page).not_to have_content(valuator.name)
      expect(page).not_to have_content(collaborator.name)
      expect(page).not_to have_content(moderator.name)
      expect(page).to have_content(administrator2.name)
      expect(page).to have_content(valuator2.name)
      expect(page).to have_content(collaborator2.name)
      expect(page).to have_content(moderator2.name)
    end
  end
end
