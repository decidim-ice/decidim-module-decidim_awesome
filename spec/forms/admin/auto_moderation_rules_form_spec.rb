# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe AutoModerationRulesForm do
      subject { described_class.from_params(attributes).with_context(current_organization: organization) }

      let(:organization) { create(:organization) }
      let(:attributes) do
        {
          description:,
          rule_type:,
          rule_options:,
          # targets: ["proposals"],
          enabled:,
          counter:
        }
      end
      let(:description) do
        {
          "en" => "Rule description",
          "ca" => "Descripció de la regla"
        }
      end
      let(:rule_type) { "word_filter" }
      let(:rule_options) { "badword1, badword2" }
      let(:enabled) { true }
      let(:counter) { 0 }

      context "when everything is OK" do
        it { is_expected.to be_valid }

        it "returns normalized values" do
          expect(subject.to_params).to eq(
            "description" => description,
            "rule_type" => rule_type,
            "rule_options" => rule_options,
            # "targets" => ["proposals"],
            "enabled" => enabled,
            "counter" => counter
          )
        end
      end

      context "when description is not a hash" do
        let(:description) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when rule type is empty" do
        let(:rule_type) { "" }

        it { is_expected.not_to be_valid }
      end
    end
  end
end
