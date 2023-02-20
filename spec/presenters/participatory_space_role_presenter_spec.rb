# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/shared_examples/action_log_presenter_examples"

module Decidim::DecidimAwesome
  describe ParticipatorySpaceRolePresenter, type: :helper do
    let(:user) { create :user, organization: organization }
    let(:organization) { create :organization }
    let(:participatory_space) { create(:participatory_process, organization: organization) }
    let(:role) { "admin" }
    let(:participatory_process_user_role) { create(:participatory_process_user_role, role: role, participatory_process: participatory_space, user: user) }
    let(:destroyed_at) { 2.days.ago }
    let(:changes_create) do
      {
        "decidim_user_id" => [nil, user.id],
        "decidim_participatory_process_id" => [nil, participatory_space.id],
        "role" => [nil, role]
      }
    end
    let(:changes_destroy) do
      {
        "decidim_user_id" => [user.id, nil],
        "decidim_participatory_process_id" => [participatory_space.id, nil],
        "role" => [role, nil]
      }
    end
    let!(:entry) do
      create(:paper_trail_version, item: participatory_process_user_role,
                                   created_at: 1.week.ago,
                                   event: "create")
    end

    let(:html) { true }

    subject { described_class.new(entry, html: html) }

    before do
      allow(entry).to receive(:changeset).and_return(changes_create)
    end

    shared_context "with role destroyed" do
      let!(:destroy_entry) do
        create(:paper_trail_version, item: participatory_process_user_role,
                                     created_at: destroyed_at,
                                     event: "destroy")
      end

      before do
        allow(destroy_entry).to receive(:changeset).and_return(changes_destroy)
      end
    end

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
