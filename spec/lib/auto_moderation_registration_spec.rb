# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe DecidimAwesome do
    let(:auto_moderation_rules_manifest) do
      Decidim::DecidimAwesome.moderation_rules_registry.manifests
    end
    let(:auto_moderation_actions_manifest) do
      Decidim::DecidimAwesome.moderation_actions_registry.manifests
    end
    let(:word_filter_manifest) do
      auto_moderation_rules_manifest.find { |r| r.name == :word_filter }
    end
    let(:moderate_and_hide_manifest) do
      auto_moderation_actions_manifest.find { |a| a.name == :moderate_and_hide }
    end

    it "registers the rules and actions for the auto moderation module" do
      expect(auto_moderation_actions_manifest).to be_present
      expect(auto_moderation_rules_manifest).to be_present
    end

    it "the word filter manifest has the correct name and description" do
      expect(word_filter_manifest.name_key).to eq("decidim.decidim_awesome.admin.auto_moderation_rules.rules.word_filter.name")
      expect(word_filter_manifest.description_key).to eq("decidim.decidim_awesome.admin.auto_moderation_rules.rules.word_filter.description")
    end

    it "the moderate and hide manifest has the correct name and description" do
      expect(moderate_and_hide_manifest.name_key).to eq("decidim.decidim_awesome.admin.auto_moderation_targets.actions.moderate_and_hide.name")
      expect(moderate_and_hide_manifest.description_key).to eq("decidim.decidim_awesome.admin.auto_moderation_targets.actions.moderate_and_hide.description")
    end
  end
end
