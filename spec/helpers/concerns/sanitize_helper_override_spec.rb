# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe SanitizeHelperOverride do
    subject { Class.new { include Decidim::SanitizeHelper }.new }

    it "keeps the rules of Decidim when there is no page to check, as in the mailers" do
      expect(subject.decidim_sanitize_admin("<style>.hero { color: red; }</style>")).not_to include("<style>")
    end
  end
end
