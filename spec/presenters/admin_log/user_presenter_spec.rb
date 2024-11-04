# frozen_string_literal: true

require "spec_helper"

module Decidim::AdminLog
  describe UserPresenter, type: :helper do
    subject(:presenter) { described_class.new(action_log, helper) }

    let(:organization) { create(:organization) }
    let(:user) { create(:user, organization:) }
    let(:extra_data) { { handler_name: "Example authorization", user_id: resource.id, reason: "Because I can" } }
    let(:action_log) do
      create(
        :action_log,
        user:,
        action:,
        resource:,
        extra_data:
      )
    end
    let(:action) { "admin_creates_authorization" }
    let(:resource) { create(:user, organization:) }

    before do
      helper.extend(Decidim::ApplicationHelper)
      helper.extend(Decidim::TranslationsHelper)
    end

    describe "#present" do
      subject { presenter.present }

      it "returns an empty diff" do
        puts subject
        expect(subject).not_to include("class=\"logs__log__diff\"")
      end

      it "returns the explanation" do
        expect(subject).to include("class=\"logs__log__explanation\"")
        expect(subject).to include("verified")
        expect(subject).to include("/profiles/#{user.nickname}")
        expect(subject).to include("/profiles/#{resource.nickname}")
        expect(subject).to include("Example authorization")
      end

      context "when the action is admin_forces_authorization" do
        let(:action) { "admin_forces_authorization" }

        it "returns the explanation" do
          expect(subject).to include("class=\"logs__log__explanation\"")
          expect(subject).to include("forced the verification")
          expect(subject).to include("/profiles/#{user.nickname}")
          expect(subject).to include("/profiles/#{resource.nickname}")
          expect(subject).to include("Example authorization")
          expect(subject).to include("Because I can")
        end
      end

      context "when the action is admin_destroys_authorization" do
        let(:action) { "admin_destroys_authorization" }

        it "returns the explanation" do
          expect(subject).to include("class=\"logs__log__explanation\"")
          expect(subject).to include("destroyed the verification")
          expect(subject).to include("/profiles/#{user.nickname}")
          expect(subject).to include("/profiles/#{resource.nickname}")
          expect(subject).to include("Example authorization")
        end
      end
    end
  end
end
