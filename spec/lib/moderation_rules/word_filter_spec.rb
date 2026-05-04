# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  module ModerationRules
    describe WordFilter do
      subject { described_class.new(options) }

      let!(:comment) { create(:comment, body:) }
      let(:body) { { "en" => "badword1" } }
      let(:options) { ["badword1"] }

      context "when the resource has a banned word" do
        it "filters the body based on the options" do
          expect(subject.check(comment)).to be_truthy
        end
      end

      context "when the wording is phrased" do
        let(:body) { { "en" => "is this a badword1?" } }
        it "matches the wording" do
          expect(subject.check(comment)).to be_truthy
        end
      end

      context "when the resource does not have a banned word" do
        let(:options) { ["badword2"] }

        it "does not filter the body content" do
          expect(subject.check(comment)).to be_falsey
        end
      end

      context "when there are multiple words to filter" do
        let(:options) { ["badword1", "badword2"]}
        let(:body) { { "en" => "It has badword1 and not badword_2" } }

        it "detecs the word inside" do
          expect(subject.check(comment)).to be_truthy
        end
      end
    end
  end
end
