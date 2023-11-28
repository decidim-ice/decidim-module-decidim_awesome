# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe RoleBasePresenter, type: :helper do
    let(:user) { create(:user, organization:) }
    let(:organization) { create(:organization) }
    let(:participatory_space) { create(:participatory_process, organization:) }
    let(:role) { "admin" }
    let(:participatory_process_user_role) { create(:participatory_process_user_role, role:, participatory_process: participatory_space, user:) }
    let(:changes_create) do
      {
        "decidim_user_id" => [nil, user.id],
        "decidim_participatory_process_id" => [nil, participatory_space.id],
        "role" => [nil, role]
      }
    end
    let!(:entry) do
      create(:paper_trail_version, item: participatory_process_user_role,
                                   created_at: 1.week.ago,
                                   event: "create")
    end

    let(:html) { true }

    subject { described_class.new(entry, html:) }

    before do
      allow(entry).to receive(:changeset).and_return(changes_create)
    end

    describe "#role_name" do
      it "raises implementation exception" do
        expect { subject.role_name }.to raise_exception(RuntimeError)
      end
    end

    describe "#user" do
      it "raises implementation exception" do
        expect { subject.user }.to raise_exception(RuntimeError)
      end

      context "when user is missing" do
        before do
          allow(subject).to receive(:user).and_return(nil)
        end

        it "returns emtpy email" do
          expect(subject.user_email).to be_blank
        end

        it "returns missing user" do
          expect(subject.user_name).to include("User not in the database")
        end
      end

      context "when user is deleted" do
        let(:deleted) { double(deleted?: true) }

        before do
          allow(subject).to receive(:user).and_return(deleted)
        end

        it "returns deleted user" do
          expect(subject.user_name).to include("Deleted user")
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
    end

    describe "#participatory_space_name" do
      it "returns the participatory space name" do
        expect(subject.participatory_space_name).to be_blank
      end
    end

    describe "#participatory_space_type" do
      it "returns the participatory space type" do
        expect(subject.participatory_space_type).to be_blank
      end
    end

    describe "#participatory_space_path" do
      it "returns the path to user roles" do
        expect(subject.participatory_space_path).to be_blank
      end
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
  end
end
