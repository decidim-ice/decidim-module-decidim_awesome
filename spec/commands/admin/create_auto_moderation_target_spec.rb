# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module Admin
    describe CreateAutoModerationTarget do
      subject { described_class.new(form, rule_id, organization) }

      let(:organization) { create(:organization) }
      let(:config) { create(:awesome_config, organization:, var: :auto_moderation_rules, value: { rule_id => rule }) }
      let(:rule) do
        {
          "description" => {
            "en" => "Rule description",
            "ca" => "Descripció de la regla"
          },
          "rule_type" => "word_filter",
          "rule_options" => "badword1, badword2",
          "targets" => {},
          "enabled" => true,
          "counter" => 0
        }
      end
      let(:rule_id) { "rule_1" }
      let(:attributes) do
        {
          object_type: "proposal",
          action_type: "moderate_and_hide",
          action_options: ""
        }
      end
      let(:form) do
        Decidim::DecidimAwesome::Admin::AutoModerationTargetForm.from_params(attributes).with_context(current_organization: organization, auto_moderation_rule: rule_id)
      end

      describe "when valid" do
        it "broadcasts :ok and creates the target" do
          expect { subject.call }.to broadcast(:ok)

          rules = AwesomeConfig.find_by(organization:, var: :auto_moderation_rules).value
          targets = rules[rule_id]["targets"]
          expect(targets.count).to eq(1)

          target = targets.first.second
          expect(target).not_to be_nil
          expect(target["target_type"]).to eq(attributes[:target_type])
          expect(target["target_id"]).to eq(attributes[:target_id])
        end
      end

      describe "when no object_type is provided" do
        let(:attributes) { super().merge(object_type: nil) }

        it "broadcasts :invalid and does not create the target" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end

      describe "when invalid object_type is provided" do
        let(:attributes) { super().merge(object_type: "invalid_type") }

        it "broadcasts :invalid and does not create the target" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end

      describe "when no action_type is provided" do
        let(:attributes) { super().merge(action_type: nil) }

        it "broadcasts :invalid and does not create the target" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end

      describe "when invalid action_type is provided" do
        let(:attributes) { super().merge(action_type: "invalid_action") }

        it "broadcasts :invalid and does not create the target" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end
    end
  end
end
