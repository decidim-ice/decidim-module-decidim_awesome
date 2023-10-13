# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe VotingManifest do
    subject { described_class.new(name: name) }
    let(:name) { :test }

    before do
      subject.weight_validator do |weight, context|
        next if context && context[:already_voted_this_weight]

        weight.in? [1, 2, 3, 4, 5]
      end
    end

    it { is_expected.to be_valid }

    context "when no name" do
      let(:name) { nil }

      it { is_expected.to be_invalid }
    end

    it "validates weights" do
      expect(subject).to be_valid_weight(1)
      expect(subject).to be_valid_weight(3)
      expect(subject).to be_valid_weight(5)
      expect(subject).not_to be_valid_weight(0)
      expect(subject).not_to be_valid_weight(1.5)
      expect(subject).not_to be_valid_weight(6)
    end

    context "when context is set" do
      let(:voted) { false }
      let(:context) do
        {
          foo: "bar",
          already_voted_this_weight: voted
        }
      end

      it "validates weights" do
        expect(subject).to be_valid_weight(1, context)
        expect(subject).not_to be_valid_weight(0, context)
        expect(subject).to be_valid_weight(5, context)
        expect(subject).not_to be_valid_weight(6, context)
      end

      context "and voted" do
        let(:voted) { true }

        it "validates weights" do
          expect(subject).not_to be_valid_weight(1, context)
          expect(subject).not_to be_valid_weight(0, context)
          expect(subject).not_to be_valid_weight(5, context)
          expect(subject).not_to be_valid_weight(6, context)
        end
      end
    end
  end
end
