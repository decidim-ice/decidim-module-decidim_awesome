# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe AutoModerationTargetForm do
      subject { described_class.from_params(attributes).with_context(current_organization: organization) }

      let(:organization) { create(:organization) }
      let(:attributes) do
        {
          object_type:,
          action_type:,
          action_options:,
          hits:
        }
      end
      let(:object_type) { "comments" }
      let(:action_type) { "moderate_and_hide" }
      let(:action_options) { {} }
      let(:hits) { 3 }

      context "when everything is OK" do
        it { is_expected.to be_valid }

        it "returns normalized values" do
          expect(subject.to_params).to eq(
            "object_type" => object_type,
            "action_type" => action_type,
            "action_options" => action_options,
            "hits" => hits
          )
        end
      end
    end
  end
end
