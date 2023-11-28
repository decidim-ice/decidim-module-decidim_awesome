# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe VotingManifest do
    subject { described_class.new(name:) }
    let(:name) { :test }

    it { is_expected.to be_valid }

    context "when no name" do
      let(:name) { nil }

      it { is_expected.to be_invalid }
    end

    it "any weight is valid" do
      expect(subject).to be_valid_weight(0)
      expect(subject).to be_valid_weight(1)
      expect(subject).to be_valid_weight(1.5)
      expect(subject).to be_valid_weight(-1.5)
    end

    it "returns automatic labels" do
      expect(subject.label_for(0)).to eq("weight_0")
      expect(subject.label_for(1)).to eq("weight_1")
      expect(subject.label_for(1.5)).to eq("weight_1.5")
      expect(subject.label_for(-1.5)).to eq("weight_-1.5")
    end

    context "when I18n labels exist" do
      let(:name) { :voting_cards }

      it "returns I18n labels" do
        expect(subject.label_for(0)).to eq("Abstain")
        expect(subject.label_for(1)).to eq("Red")
        expect(subject.label_for(2)).to eq("Yellow")
        expect(subject.label_for(3)).to eq("Green")
        expect(subject.label_for(3.5)).to eq("weight_3.5")
      end
    end

    context "when label_generator block" do
      before do
        subject.label_generator do |weight, _context|
          "custom weight: #{weight.round}"
        end
      end

      it "returns custom labels" do
        expect(subject.label_for(0)).to eq("custom weight: 0")
        expect(subject.label_for(1)).to eq("custom weight: 1")
        expect(subject.label_for(1.5)).to eq("custom weight: 2")
        expect(subject.label_for(-1.5)).to eq("custom weight: -2")
      end
    end

    context "when weight_validator block" do
      before do
        subject.weight_validator do |weight, context|
          next if context && context[:already_voted_this_weight]

          weight.in? [1, 2, 3, 4, 5]
        end
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
end
