# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/shared_examples/action_log_presenter_examples"

module Decidim::DecidimAwesome
  describe UserEntityPresenter, type: :helper do
    let!(:user) { create(:user, :admin, organization:, last_sign_in_at:) }
    let(:entry) { Decidim::DecidimAwesome::PaperTrailVersion.admin_role_actions.first }
    let(:last_sign_in_at) { nil }
    let(:organization) { create(:organization) }
    let(:destroyed_at) { 2.days.ago }

    let(:html) { true }

    subject { described_class.new(entry, html:) }

    shared_context "with role destroyed" do
      before do
        user.admin = false
        user.roles = []
        user.save!
        Decidim::DecidimAwesome::PaperTrailVersion.first.update!(created_at: destroyed_at)
      end
    end

    with_versioning do
      describe "#roles" do
        it "returns the roles" do
          expect(subject.roles).to eq(["admin"])
        end

        it "returns the role name in html" do
          expect(subject.role_name).to eq("<span class=\"text-alert\">Super admin</span>")
        end

        context "when html is disabled" do
          let(:html) { false }

          it "returns without classes" do
            expect(subject.role_name).to eq("Super admin")
          end
        end
      end

      it_behaves_like "a user presenter"

      context "when the role is a participant manager" do
        let!(:user) { create(:user, :user_manager, organization:, last_sign_in_at:) }
        let(:entry) { Decidim::DecidimAwesome::PaperTrailVersion.admin_role_actions.first }

        describe "#roles" do
          it "returns the roles" do
            expect(subject.roles).to eq(["user_manager"])
          end

          it "returns the role name in html" do
            expect(subject.role_name).to eq("<span class=\"text-secondary\">User manager</span>")
          end

          context "when html is disabled" do
            let(:html) { false }

            it "returns without classes" do
              expect(subject.role_name).to eq("User manager")
            end
          end
        end

        it_behaves_like "a user presenter"
      end
    end
  end
end
