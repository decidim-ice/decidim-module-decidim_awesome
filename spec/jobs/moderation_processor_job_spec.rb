# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe ModerationProcessorJob do
    subject { described_class }
    let!(:comment) { create(:comment, body:) }
    let(:organization) { comment.author.organization }
    let!(:admin) { create(:user, :confirmed, :admin, organization:) }
    let(:body) { { "en" => "badword1" } }
    let!(:config) { create(:awesome_config, organization: comment.organization, var: :auto_moderation_rules, value: { "rule_1" => rule }) }
    let(:rule) do
      {
        "description" => {
          "en" => "Rule description"
        },
        "rule_type" => "word_filter",
        "rule_options" => %w(badword1 badword2),
        "targets" => {
          "target_1" => {
            "object_type" => "comment",
            "action_type" => "moderate_and_hide",
            "action_options" => "",
            "hits" => 0
          }
        },
        "enabled" => true,
        "counter" => 0
      }
    end

    it "processes the moderation for a comment" do
      expect do
        subject.perform_now(comment)
      end.to change { comment.reports.count }.from(0).to(1)
    end

    it "updates the counter and hits of rules and actions" do
      subject.perform_now(comment)

      config.reload
      expect(config.value["rule_1"]["counter"]).to eq(1)
      expect(config.value["rule_1"]["targets"]["target_1"]["hits"]).to eq(1)
    end

    it "creates a moderation execution log with the correct data" do
      subject.perform_now(comment)

      expect(Decidim::DecidimAwesome::ModerationExecutionLog.count).to eq(1)

      log = Decidim::DecidimAwesome::ModerationExecutionLog.find_by(resource_id: comment.id, resource_type: comment.class.name)
      expect(log).not_to be_nil
      expect(log.resource_id).to eq(comment.id)
      expect(log.rule_type).to eq("word_filter")
      expect(log.action_type).to eq("moderate_and_hide")
    end
  end
end
