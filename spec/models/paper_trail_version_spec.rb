# frozen_string_literal: true

require "spec_helper"
module Decidim::DecidimAwesome
  describe PaperTrailVersion, type: :model do
    subject { paper_trail_version }

    let(:organization) { create(:organization) }
    let(:user) { create(:user, id: 1, organization:) }

    let(:external_organization) { create(:organization) }
    let(:external_user) { create(:user, id: 11, organization: external_organization) }

    context "when user roles" do
      let(:participatory_process_user_role) { create(:participatory_process_user_role, participatory_process: participatory_process, user: administrator, role: "admin", created_at: 1.day.ago) }
      let(:administrator) { create(:user, id: 111, organization: organization, last_sign_in_at: 1.day.ago) }
      let(:participatory_process) { create(:participatory_process, organization: organization) }
      let!(:paper_trail_version) { create(:paper_trail_version, item_type: "Decidim::ParticipatoryProcessUserRole", item_id: participatory_process_user_role.id, whodunnit: user.id, event: "create") }

      let(:external_participatory_process_user_role) { create(:participatory_process_user_role, participatory_process: external_participatory_process, user: external_valuator, role: "valuator", created_at: 1.day.ago) }
      let(:external_valuator) { create(:user, id: 1111, organization: external_organization, last_sign_in_at: 1.day.ago) }
      let(:external_participatory_process) { create(:participatory_process, organization: external_organization) }
      let!(:external_paper_trail_version) { create(:paper_trail_version, item_type: "Decidim::ParticipatoryProcessUserRole", item_id: external_participatory_process_user_role.id, whodunnit: external_user.id, event: "create") }

      before do
        paper_trail_version.update!(
          object_changes: {
            "decidim_user_id" => [nil, administrator.id],
            "decidim_participatory_process_id" => [nil, participatory_process.id]
          }.to_yaml
        )

        external_paper_trail_version.update!(
          object_changes: {
            "decidim_user_id" => [nil, external_valuator.id],
            "decidim_participatory_process_id" => [nil, external_participatory_process.id]
          }.to_yaml
        )
      end

      it { is_expected.to be_valid }

      it "paper_trail_version is associated with user" do
        expect(subject.whodunnit).to eq(user.id.to_s)
        expect(external_paper_trail_version.whodunnit).to eq(external_user.id.to_s)
      end

      it "returns default_scope ordered by created_at" do
        expect(PaperTrailVersion.all).to eq([external_paper_trail_version, paper_trail_version])
      end

      it "returns space_role_actions scope correctly" do
        expect(PaperTrailVersion.space_role_actions(organization)).to include(paper_trail_version)
        expect(PaperTrailVersion.space_role_actions(organization)).not_to include(external_paper_trail_version)
        expect(PaperTrailVersion.space_role_actions(external_organization)).to include(external_paper_trail_version)
        expect(PaperTrailVersion.space_role_actions(external_organization)).not_to include(paper_trail_version)
      end

      it "present method returns a PaperTrailBasePresenter object" do
        expect(subject.present).to be_a(PaperTrailBasePresenter)
      end

      it "present method returns a ParticipatorySpaceRolePresenter object" do
        expect(subject.present).to be_a(ParticipatorySpaceRolePresenter)
      end
    end

    context "when admin roles" do
      let!(:paper_trail_version) { create(:paper_trail_version, item_type: "Decidim::UserBaseEntity", item_id: user.id, event: "create") }
      let!(:external_paper_trail_version) { create(:paper_trail_version, item_type: "Decidim::UserBaseEntity", item_id: external_user.id, event: "create") }

      before do
        paper_trail_version.update!(
          object_changes: {
            "admin" => [false, true]
          }.to_yaml
        )

        external_paper_trail_version.update!(
          object_changes: {
            "roles" => [[], ["valuator"]]
          }.to_yaml
        )
      end

      it "returns default_scope ordered by created_at" do
        expect(PaperTrailVersion.all).to eq([external_paper_trail_version, paper_trail_version])
        expect(PaperTrailVersion.admin_role_actions).to match_array([external_paper_trail_version, paper_trail_version])
      end

      it "present method returns a UserEntityPresenter object" do
        expect(subject.present).to be_a(UserEntityPresenter)
        expect(external_paper_trail_version.present).to be_a(UserEntityPresenter)
      end

      it "returns admin_role_actions scope correctly" do
        expect(PaperTrailVersion.in_organization(organization).admin_role_actions).to include(paper_trail_version)
        expect(PaperTrailVersion.in_organization(organization).admin_role_actions).not_to include(external_paper_trail_version)
        expect(PaperTrailVersion.in_organization(external_organization).admin_role_actions).to include(external_paper_trail_version)
        expect(PaperTrailVersion.in_organization(external_organization).admin_role_actions).not_to include(paper_trail_version)
      end

      it "filters correctly by role" do
        expect(PaperTrailVersion.in_organization(organization).admin_role_actions("admin")).to include(paper_trail_version)
        expect(PaperTrailVersion.in_organization(organization).admin_role_actions("valuator")).to eq([])
        expect(PaperTrailVersion.in_organization(external_organization).admin_role_actions("valuator")).to include(external_paper_trail_version)
        expect(PaperTrailVersion.in_organization(external_organization).admin_role_actions("admin")).to eq([])
      end

      it "ignores invalid filters" do
        expect(PaperTrailVersion.in_organization(organization).admin_role_actions("%')")).to eq([])
      end
    end
  end
end
