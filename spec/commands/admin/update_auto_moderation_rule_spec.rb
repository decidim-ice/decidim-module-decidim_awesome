# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe UpdateAutoModerationRule do
      subject { described_class.new(form, rule_id, organization) }

      let(:organization) { create(:organization) }
      let(:existing_rule) do
        {
          "description" => {
            "en" => "Rule description",
            "ca" => "Descripció de la regla"
          },
          "rule_type" => "word_filter",
          "rule_options" => "badword1, badword2",
          # "targets" => ["proposals"],
          "enabled" => true,
          "counter" => 0
        }
      end
      let(:config) { create(:awesome_config, organization:, var: :auto_moderation_rules, value: { rule_id => existing_rule }) }
      let(:rule_id) { "rule_1" }
      let(:attributes) do
        {
          description: {
            "en" => "Updated rule description",
            "ca" => "Descripció actualitzada de la regla"
          },
          rule_type: "word_filter",
          rule_options: "badword1, badword2, badword3",
          # targets: ["proposals"],
          enabled: false,
          counter: 5
        }
      end
      let(:form) do
        Decidim::DecidimAwesome::Admin::AutoModerationRulesForm.from_params(attributes).with_context(current_organization: organization)
      end

      describe "when valid" do
        it "broadcasts :ok and updates the rule" do
          expect { subject.call }.to broadcast(:ok)

          config.reload
          rules = config.value
          expect(rules.count).to eq(1)

          rule = rules.first.second
          expect(rule).not_to be_nil
          expect(rule["description"]).to eq(attributes[:description])
          expect(rule["rule_type"]).to eq(attributes[:rule_type])
          expect(rule["rule_options"]).to eq(attributes[:rule_options])
          # expect(rule["targets"]).to eq(attributes[:targets])
          expect(rule["enabled"]).to eq(attributes[:enabled])
          expect(rule["counter"]).to eq(attributes[:counter])
        end
      end

      describe "when invalid" do
        let(:attributes) { super().merge(description: nil) }

        it "broadcasts :invalid and does not update the rule" do
          expect { subject.call }.to broadcast(:invalid)

          config.reload
          rules = config.value
          expect(rules.count).to eq(1)

          rule = rules.first.second
          expect(rule).not_to be_nil
          expect(rule["description"]).to eq(existing_rule["description"])
          expect(rule["rule_type"]).to eq(existing_rule["rule_type"])
          expect(rule["rule_options"]).to eq(existing_rule["rule_options"])
          # expect(rule["targets"]).to eq(existing_rule["targets"])
          expect(rule["enabled"]).to eq(existing_rule["enabled"])
          expect(rule["counter"]).to eq(existing_rule["counter"])
        end
      end
    end
  end
end
