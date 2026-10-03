# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe DecidimAwesome do
    subject { described_class }

    it "has a voting registry" do
      expect(subject.voting_registry).to be_a(Decidim::ManifestRegistry)
    end

    it "has a moderation rules registry" do
      expect(subject.moderation_rules_registry).to be_a(Decidim::ManifestRegistry)
    end

    it "has a moderation actions registry" do
      expect(subject.moderation_actions_registry).to be_a(Decidim::ManifestRegistry)
    end

    describe ".compatible_moderation_actions" do
      let(:rule_manifest) do
        Decidim::DecidimAwesome::ModerationRuleManifest.new(
          name: :word_filter,
          checker_class: "SomeChecker",
          supported_object_types: [:proposals, :comments]
        )
      end
      let(:proposal_action) do
        Decidim::DecidimAwesome::ModerationActionManifest.new(
          name: :moderate_and_hide,
          handler_class: "SomeHandler",
          supported_object_types: [:proposals]
        )
      end
      let(:comment_action) do
        Decidim::DecidimAwesome::ModerationActionManifest.new(
          name: :flag_only,
          handler_class: "SomeOtherHandler",
          supported_object_types: [:comments]
        )
      end

      before do
        allow(subject.moderation_rules_registry).to receive(:find).with(:word_filter).and_return(rule_manifest)
        allow(subject.moderation_rules_registry).to receive(:find).with(:missing).and_return(nil)
        allow(subject.moderation_actions_registry).to receive(:manifests).and_return([proposal_action, comment_action])
      end

      it "returns actions compatible with the rule and object type" do
        expect(subject.compatible_moderation_actions(:word_filter, :proposals)).to eq([proposal_action])
      end

      it "filters correctly for a different object type" do
        expect(subject.compatible_moderation_actions(:word_filter, :comments)).to eq([comment_action])
      end

      it "returns empty when rule is not found" do
        expect(subject.compatible_moderation_actions(:missing, :proposals)).to eq([])
      end

      it "returns empty when object type is not supported by the rule" do
        expect(subject.compatible_moderation_actions(:word_filter, :debates)).to eq([])
      end

      it "accepts string arguments" do
        expect(subject.compatible_moderation_actions("word_filter", "proposals")).to eq([proposal_action])
      end
    end

    it "returns the database collation" do
      expect(subject.collation_for("en")).to start_with("en")
    end

    describe "#hash_append!" do
      let(:hash) do
        { a: 1, b: 2, c: 3 }
      end

      it "append a value at the second position" do
        subject.hash_append!(hash, :a, :d, 4)
        expect(hash).to eq({ a: 1, d: 4, b: 2, c: 3 })
      end

      it "append a value at the last position" do
        subject.hash_append!(hash, :c, :d, 4)
        expect(hash).to eq({ a: 1, b: 2, c: 3, d: 4 })
      end

      context "when key is not found" do
        it "append a value at the last position" do
          subject.hash_append!(hash, :z, :d, 4)
          expect(hash).to eq({ a: 1, b: 2, c: 3, d: 4 })
        end
      end
    end

    describe "#hash_prepend!" do
      let(:hash) do
        { a: 1, b: 2, c: 3 }
      end

      it "prepend a value at the first position" do
        subject.hash_prepend!(hash, :a, :d, 4)
        expect(hash).to eq({ d: 4, a: 1, b: 2, c: 3 })
      end

      it "prepend a value at the third position" do
        subject.hash_prepend!(hash, :c, :d, 4)
        expect(hash).to eq({ a: 1, b: 2, d: 4, c: 3 })
      end

      context "when key is not found" do
        it "prepend a value at the last position" do
          subject.hash_prepend!(hash, :z, :d, 4)
          expect(hash).to eq({ d: 4, a: 1, b: 2, c: 3 })
        end
      end
    end
  end
end
