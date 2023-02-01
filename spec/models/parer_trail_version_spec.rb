# frozen_string_literal: true

require "spec_helper"
module Decidim::DecidimAwesome
  describe PaperTrailVersion, type: :model do
    subject { paper_trail_version }

    let(:organization) { create(:organization) }
    let(:user) { create(:user) }
    let(:participatory_process_user_role) { create(:participatory_process_user_role, participatory_process: participatory_process, user: administrator, role: "admin", created_at: 1.day.ago) }
    let(:paper_trail_version) { create(:paper_trail_version, item_type: "Decidim::AssemblyUserRole", item_id: participatory_process_user_role.id, whodunnit: user.id, event: "create") }
    let(:administrator) { create(:user, organization: organization, last_sign_in_at: 1.day.ago) }
    let(:participatory_process) { create(:participatory_process, organization: organization) }

    it { is_expected.to be_valid }

    it "paper_trail_version is associated with user" do
      expect(subject).to eq(paper_trail_version)
      expect(subject.whodunnit).to eq(user.id.to_s)
    end

    it "returns default_scope ordered by created_at" do
      expect(PaperTrailVersion.all).to eq([paper_trail_version])
    end

    it "returns role_actions scope correctly" do
      expect(PaperTrailVersion.role_actions).to include(paper_trail_version)
    end

    it "present method returns a PaperTrailRolePresenter object" do
      expect(subject.present).to be_a(PaperTrailRolePresenter)
    end
  end
end
