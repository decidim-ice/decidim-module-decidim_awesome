# frozen_string_literal: true

require "spec_helper"

module Decidim::DecidimAwesome
  describe MenuItemsParser do
    describe ".parse_json" do
      it "parses valid JSON array" do
        json = [{ "name" => "Test", "url" => "#test" }].to_json
        expect(described_class.parse_json(json)).to eq([{ "name" => "Test", "url" => "#test" }])
      end

      it "returns empty array for blank string" do
        expect(described_class.parse_json("")).to eq([])
      end

      it "returns empty array for nil" do
        expect(described_class.parse_json(nil)).to eq([])
      end

      it "returns empty array for invalid JSON" do
        expect(described_class.parse_json("not json")).to eq([])
      end

      it "returns empty array for JSON object (not array)" do
        expect(described_class.parse_json('{"key": "value"}')).to eq([])
      end
    end

    describe "SAFE_URL_PATTERN" do
      subject { described_class::SAFE_URL_PATTERN }

      it { is_expected.to match("#anchor") }
      it { is_expected.to match("#my-section") }
      it { is_expected.to match("/processes") }
      it { is_expected.to match("/processes/my-process") }
      it { is_expected.to match("https://example.com") }
      it { is_expected.to match("https://example.com/path?q=1") }
      it { is_expected.not_to match("javascript:alert(1)") }
      it { is_expected.not_to match("data:text/html,test") }
      it { is_expected.not_to match("http://example.com") }
      it { is_expected.not_to match("//evil.com") }
    end
  end
end
