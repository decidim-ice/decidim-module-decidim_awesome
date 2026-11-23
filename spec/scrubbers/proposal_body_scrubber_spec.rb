# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe ProposalBodyScrubber do
    subject { ActionController::Base.helpers.sanitize(html, scrubber: described_class.new) }

    let(:html) { '<style>.hero { color: red; }</style><img src="https://www.example.com/someimage.jpeg">' }

    it "keeps the admin tags but not the extra ones" do
      expect(subject).to include('<img src="https://www.example.com/someimage.jpeg">')
      expect(subject).not_to include("<style>")
    end
  end
end
