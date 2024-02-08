# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/shared_examples/action_log_presenter_examples"

module Decidim::DecidimAwesome
  describe ParticipatorySpaceRolePresenter, type: :helper do
    let(:user) { create(:user, organization:, last_sign_in_at:) }
    let(:last_sign_in_at) { nil }
    let(:entry) { Decidim::DecidimAwesome::PaperTrailVersion.space_role_actions(organization).first }
    let!(:organization) { create(:organization) }
    let(:participatory_space) { create(:participatory_process, organization:) }
    let(:role) { "admin" }
    let!(:participatory_process_user_role) { create(:participatory_process_user_role, role:, participatory_process: participatory_space, user:) }
    let(:destroyed_at) { 2.days.ago }

    let(:html) { true }

    subject { described_class.new(entry, html:) }

    shared_context "with role destroyed" do
      before do
        participatory_process_user_role.destroy!
        Decidim::DecidimAwesome::PaperTrailVersion.first.update!(created_at: destroyed_at)
      end
    end

    with_versioning do
      describe "#role" do
        it "returns the role" do
          expect(subject.role).to eq("admin")
        end

        it "returns the role name in html" do
          expect(subject.role_name).to eq("<span class=\"text-alert\">Administrator</span>")
        end

        context "when html is disabled" do
          let(:html) { false }

          it "returns without classes" do
            expect(subject.role_name).to eq("Administrator")
          end
        end

        context "when role is a valuator" do
          let(:role) { "valuator" }

          it "returns the role name in html" do
            expect(subject.role_name).to eq("<span class=\"text-secondary\">Valuator</span>")
          end

          context "when html is disabled" do
            let(:html) { false }

            it "returns without classes" do
              expect(subject.role_name).to eq("Valuator")
            end
          end
        end

        context "when role is a collaborator" do
          let(:role) { "collaborator" }

          it "returns the role name in html" do
            expect(subject.role_name).to eq("Collaborator")
          end

          context "when html is disabled" do
            let(:html) { false }

            it "returns without classes" do
              expect(subject.role_name).to eq("Collaborator")
            end
          end
        end
      end

      it_behaves_like "a user presenter"

      describe "#participatory_space_name" do
        it "returns the participatory space name" do
          expect(subject.participatory_space_name).to include("Processes")
        end
      end

      describe "#participatory_space_type" do
        it "returns the participatory space type" do
          expect(subject.participatory_space_type).to eq("Processes")
        end
      end

      describe "#participatory_space_path" do
        it "returns the path to user roles" do
          expect(subject.participatory_space_path).to eq("/admin/participatory_processes/#{participatory_space.slug}/user_roles")
        end

        context "when role is destroyed" do
          include_context "with role destroyed"

          it "returns the path to user roles" do
            expect(subject.participatory_space_path).to eq("/admin/participatory_processes/#{participatory_space.slug}/user_roles")
          end
        end

        # rubocop:disable RSpec/AnyInstance
        context "when no user roles route exist" do
          before do
            allow_any_instance_of(Decidim::EngineRouter).to receive(:participatory_process_user_roles_path).and_raise(NoMethodError)
          end

          it "returns the path to user roles" do
            expect(subject.participatory_space_path.split("?").first).to eq("/admin/participatory_processes/#{participatory_space.slug}")
          end

          context "when no participatory_space route exist" do
            before do
              allow_any_instance_of(Decidim::EngineRouter).to receive(:participatory_process_path).and_raise(NoMethodError)
            end

            it "returns empty" do
              expect(subject.participatory_space_path).to be_blank
            end
          end
        end
        # rubocop:enable RSpec/AnyInstance
      end
    end
  end
end
