# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe PaperTrailRolePresenter, type: :helper do
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

    let(:action_log) { create(:action_log, organization: organization, resource_id: entry.reload.changeset["decidim_user_id"].last, action: "create") }
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

      it "returns the role name" do
        expect(subject.role_name).to eq("Administrator")
      end

      it "returns the role class" do
        expect(subject.role_class).to eq("text-alert")
      end

      context "when role is a valuator" do
        let(:role) { "valuator" }

        it "returns the role name" do
          expect(subject.role_name).to eq("Valuator")
        end

        it "returns the role class" do
          expect(subject.role_class).to eq("text-secondary")
        end
      end

      context "when role is a collaborator" do
        let(:role) { "collaborator" }

        it "returns the role name" do
          expect(subject.role_name).to eq("Collaborator")
        end

        it "returns the role class" do
          expect(subject.role_class).to be_blank
        end
      end
    end

    describe "#removal_date" do
      it "returns currently active" do
        expect(subject.removal_date).to eq("<span class=\"text-success\">Currently active</span>")
      end

      context "when html is disabled" do
        let(:html) { false }

        it "returns currently active" do
          expect(subject.removal_date).to eq("Currently active")
        end
      end

      context "when the role was removed" do
        include_context "with role destroyed"

        it "returns the removal date" do
          expect(subject.removal_date).to eq(destroyed_at.strftime("%d/%m/%Y %H:%M"))
        end
      end
    end

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

    describe "#created_date" do
      it "returns the creation date" do
        expect(subject.created_date).to eq(entry.created_at.strftime("%d/%m/%Y %H:%M"))
      end

      context "when date is missing" do
        let(:entry) { nil }

        it "returns the creation date" do
          expect(subject.created_date).to eq("")
        end
      end
    end

    describe "#last_sign_in_date" do
      it "returns never logged in yet" do
        expect(subject.last_sign_in_date).to eq("<span class=\"muted\">Never logged yet</span>")
      end

      context "when no html" do
        let(:html) { false }

        it "returns never logged in yet" do
          expect(subject.last_sign_in_date).to eq("Never logged yet")
        end
      end

      context "when user has logged before" do
        let(:user) { create :user, organization: organization, last_sign_in_at: 1.day.ago }

        it "returns the last sign in date" do
          expect(subject.last_sign_in_date).to eq(1.day.ago.strftime("%d/%m/%Y %H:%M"))
        end
      end
    end

    describe "#user" do
      it "returns the user" do
        expect(subject.user).to eq(user)
      end
    end
  end
end
