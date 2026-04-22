# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
    module Admin
        describe DestroyAutoModerationTarget do
            subject { described_class.new(target_id, rule_id, organization) }

            let(:organization) { create(:organization) }
            let!(:config) { create(:awesome_config, organization:, var: :auto_moderation_rules, value: { rule_id => rule }) }
            let(:rule) do
                {
                    "description" => {
                        "en" => "Rule description",
                        "ca" => "Descripció de la regla"
                    },
                    "rule_type" => "word_filter",
                    "rule_options" => "badword1, badword2",
                    "targets" => {
                        "target_1" => {
                            "object_type" => "proposal",
                            "action_type" => "moderate_and_hide",
                            "action_options" => ""
                        }
                    },
                    "enabled" => true,
                    "counter" => 0
                }
            end
            let(:rule_id) { "rule_1" }
            let(:target_id) { "target_1" }

            describe "when valid" do
                it "broadcasts :ok and destroys the target" do
                    expect { subject.call }.to broadcast(:ok)

                    rules = AwesomeConfig.find_by(organization:, var: :auto_moderation_rules).value
                    targets = rules[rule_id]["targets"]
                    expect(targets).not_to have_key(target_id)
                end
            end

            describe "when target does not exist" do
                let(:target_id) { "non_existent_rule" }

                it "broadcasts :invalid " do
                    expect { subject.call }.to broadcast(:invalid)
                end
            end
        end
    end
end