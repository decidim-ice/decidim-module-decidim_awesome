# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe AdminInputScrubber do
    subject { ActionController::Base.helpers.sanitize(html, scrubber: described_class.new) }

    let(:html) { "<style>.hero { color: red; }</style><figure>A caption</figure><script>alert(1)</script>" }

    it "keeps the extra tags allowed by default" do
      expect(subject).to include("<style>.hero { color: red; }</style>")
      expect(subject).not_to include("<figure>")
      expect(subject).not_to include("<script>")
    end

    context "when the extra tags are customized" do
      before do
        allow(Decidim::DecidimAwesome).to receive(:html_code_editor_allowed_tags).and_return(%w(figure))
      end

      it "keeps only the configured ones" do
        expect(subject).to include("<figure>A caption</figure>")
        expect(subject).not_to include("<style>")
        expect(subject).not_to include("<script>")
      end
    end
  end
end
