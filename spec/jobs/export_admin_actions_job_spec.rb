# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe ExportAdminActionsJob do
    subject { described_class }
    let(:organization) { create :organization }
    let!(:user) { create :user, :admin, :confirmed, organization: organization }
    let!(:manager) { create(:user, :user_manager, organization: organization, last_sign_in_at: 6.days.ago, created_at: 7.days.ago) }
    let(:administrator) { create(:user, organization: organization, last_sign_in_at: 6.days.ago, created_at: 7.days.ago) }
    let(:valuator) { create(:user, name: "Lorry", email: "test@example.org", organization: organization, created_at: 7.days.ago) }
    let(:collaborator) { create(:user, organization: organization, created_at: 7.days.ago) }
    let(:moderator) { create(:user, organization: organization, created_at: 7.days.ago) }
    let!(:participatory_process_user_role1) { create(:participatory_process_user_role, user: administrator, role: "admin", created_at: 4.days.ago) }
    let!(:participatory_process_user_role2) { create(:participatory_process_user_role, user: valuator, role: "valuator", created_at: 3.days.ago) }
    let!(:participatory_process_user_role3) { create(:participatory_process_user_role, user: collaborator, role: "collaborator", created_at: 2.days.ago) }
    let!(:participatory_process_user_role4) { create(:participatory_process_user_role, user: moderator, role: "moderator", created_at: 1.day.ago) }
    let!(:assembly_user_role1) { create(:assembly_user_role, user: administrator, role: "admin", created_at: 4.days.ago) }
    let!(:assembly_user_role2) { create(:assembly_user_role, user: valuator, role: "valuator", created_at: 3.days.ago) }
    let!(:assembly_user_role3) { create(:assembly_user_role, user: collaborator, role: "collaborator", created_at: 2.days.ago) }
    let!(:assembly_user_role4) { create(:assembly_user_role, user: moderator, role: "moderator", created_at: 1.day.ago) }
    let(:collection_ids) { Decidim::DecidimAwesome::PaperTrailVersion.space_role_actions(organization).pluck(:id) }
    let(:format) { "CSV" }
    let(:ext) { "csv" }

    before do
      # ensure papertrail has the same created_at date as the object being mocked
      Decidim::DecidimAwesome::PaperTrailVersion.space_role_actions(organization).map { |v| v.update(created_at: v.item.created_at) }
    end

    shared_examples "an export job" do
      it "sends an email with the result of the export", versioning: true do
        perform_enqueued_jobs do
          subject.perform_now(user, format, collection_ids)
        end

        email = last_email
        expect(email.subject).to match(/Your export "admin_actions-#{Time.current.strftime("%Y-%m-%d")}-([0-9]+).#{ext}" is ready/)
        expect(email.body.encoded).to match("Please find attached a zipped version of your export")
      end
    end

    it_behaves_like "an export job"

    it_behaves_like "an export job" do
      let(:format) { "JSON" }
      let(:ext) { "json" }
    end

    it_behaves_like "an export job" do
      let(:format) { "Excel" }
      let(:ext) { "xlsx" }
    end

    context "when filtered data" do
      let(:collection_ids) { PaperTrailVersion.space_role_actions(organization).where(item_type: "Decidim::AssemblyUserRole").where("created_at > ?", 3.days.ago).pluck(:id) }
      let(:result) do
        [
          {
            last_sign_in_at: "Never logged yet",
            participatory_space_title: assembly_user_role4.assembly.title["en"],
            participatory_space_type: "Assemblies",
            role: "Moderator",
            role_created_at: assembly_user_role4.created_at.strftime("%d/%m/%Y %H:%M"),
            user_email: moderator.email,
            user_name: moderator.name,
            role_removed_at: "Currently active",
            user_role_type: "Decidim::AssemblyUserRole"
          },
          {
            last_sign_in_at: "Never logged yet",
            participatory_space_title: assembly_user_role3.assembly.title["en"],
            participatory_space_type: "Assemblies",
            role: "Collaborator",
            role_created_at: assembly_user_role3.created_at.strftime("%d/%m/%Y %H:%M"),
            user_email: collaborator.email,
            user_name: collaborator.name,
            role_removed_at: "Currently active",
            user_role_type: "Decidim::AssemblyUserRole"
          }
        ]
      end

      subject { described_class.new }

      it "serializes the data", versioning: true do
        expect(subject.send(:serialized_collection, collection_ids)).to eq(result)
      end
    end

    context "when export global admins" do
      let(:collection_ids) { Decidim::DecidimAwesome::PaperTrailVersion.admin_role_actions.pluck(:id) }

      it_behaves_like "an export job"

      it_behaves_like "an export job" do
        let(:format) { "JSON" }
        let(:ext) { "json" }
      end

      it_behaves_like "an export job" do
        let(:format) { "Excel" }
        let(:ext) { "xlsx" }
      end

      context "when filtered data" do
        let(:collection_ids) { PaperTrailVersion.admin_role_actions.where("created_at > ?", 3.days.ago).pluck(:id) }
        let(:result) do
          [
            {
              last_sign_in_at: manager.last_sign_in_at.strftime("%d/%m/%Y %H:%M"),
              participatory_space_title: "",
              participatory_space_type: nil,
              role: "User manager",
              role_created_at: manager.created_at.strftime("%d/%m/%Y %H:%M"),
              user_email: manager.email,
              user_name: manager.name,
              role_removed_at: "Currently active",
              user_role_type: "Decidim::UserBaseEntity"
            },
            {
              last_sign_in_at: "Never logged yet",
              participatory_space_title: "",
              participatory_space_type: nil,
              role: "Super admin",
              role_created_at: user.created_at.strftime("%d/%m/%Y %H:%M"),
              user_email: user.email,
              user_name: user.name,
              role_removed_at: "Currently active",
              user_role_type: "Decidim::UserBaseEntity"
            }
          ]
        end

        subject { described_class.new }

        it "serializes the data", versioning: true do
          expect(subject.send(:serialized_collection, collection_ids)).to eq(result)
        end
      end
    end
  end
end
