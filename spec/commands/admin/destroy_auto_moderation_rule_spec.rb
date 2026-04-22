# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe DestroyAutoModerationRule do
      subject { described_class.new(rule_id, organization) }

      let(:organization) { create(:organization) }
      let(:rule_id) { "rule_1" }
      let(:attributes) do
        {
          "description" => {
            "en" => "Rule description",
            "ca" => "Descripció de la regla"
          },
          "rule_type" => "word_filter",
          "rule_options" => "badword1, badword2",
          # targets: ["proposals"],
          "enabled" => true,
          "counter" => 0
        }
      end
      let!(:config) { create(:awesome_config, organization:, var: :auto_moderation_rules, value: { "rule_1" => attributes }) }

      context "when everything is OK" do
        it "broadcasts :ok and removes the rule" do
          expect { subject.call }.to broadcast(:ok)
        end
      end

      context "when the rule does not exist" do
        let(:rule_id) { 0 }

        it "does not destroy any rule" do
          expect { subject }.not_to(change { config.value.count })
        end
      end
    end
  end
end
