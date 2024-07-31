# frozen_string_literal: true

require "spec_helper"

module Decidim::AdminLog
  describe ComponentPresenter, type: :helper do
    subject(:presenter) { described_class.new(action_log, helper) }

    let(:organization) { create(:organization) }
    let(:user) { create(:user, organization:) }
    let(:extra_data) { { count: 137 } }
    let(:action_log) do
      create(
        :action_log,
        user:,
        action:,
        resource:,
        extra_data:
      )
    end
    let(:action) { "destroy_private_data" }
    let(:resource) { create(:component, organization:) }

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
        expect(subject).to include("destroyed 137 items of private data for")
      end
    end
  end
end
