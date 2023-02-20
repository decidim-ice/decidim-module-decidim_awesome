# frozen_string_literal: true

require "spec_helper"
require "decidim/decidim_awesome/test/shared_examples/action_log_presenter_examples"

module Decidim::DecidimAwesome
  describe UserEntityPresenter, type: :helper do
    let(:user) { create :user, organization: organization }
    let(:organization) { create :organization }
    let(:destroyed_at) { 2.days.ago }
    let(:changes_create) do
      {
        "admin" => [false, true]
      }
    end
    let(:changes_destroy) do
      {
        "admin" => [true, false]
      }
    end
    let!(:entry) do
      create(:paper_trail_version, item: user,
                                   created_at: 1.week.ago,
                                   event: "update")
    end
    let(:html) { true }

    subject { described_class.new(entry, html: html) }

    before do
      allow(entry).to receive(:changeset).and_return(changes_create)
    end

    shared_context "with role destroyed" do
      let!(:destroy_entry) do
        create(:paper_trail_version, item: user,
                                     created_at: destroyed_at,
                                     event: "update")
      end

      before do
        allow(destroy_entry).to receive(:changeset).and_return(changes_destroy)
      end
    end

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

    context "when the role is a participatn manager" do
      let(:changes_create) do
        {
          "roles" => [[], ["user_manager"]]
        }
      end
      let(:changes_destroy) do
        {
          "roles" => [["user_manager"], []]
        }
      end
      let!(:entry) do
        create(:paper_trail_version, item: user,
                                     created_at: 1.week.ago,
                                     event: "update")
      end

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
