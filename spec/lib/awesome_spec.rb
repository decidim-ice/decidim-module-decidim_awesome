# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe DecidimAwesome do
    subject { described_class }

    it "has a voting registry" do
      expect(subject.voting_registry).to be_a(Decidim::ManifestRegistry)
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
